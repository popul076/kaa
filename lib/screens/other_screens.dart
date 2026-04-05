import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';
import '../widgets/common_widgets.dart';

// ==================== 쿠폰 ====================
class CouponScreen extends StatelessWidget {
  const CouponScreen({super.key});

  final coupons = const [
    {'store': 'KAA 추천 프리미엄 정비소', 'title': '엔진오일 교환 20% 할인', 'expires': '2025-06-30', 'discount': '20%', 'used': false},
    {'store': '추천 세차·코팅 전문점', 'title': '프리미엄 손세차 무료', 'expires': '2025-05-31', 'discount': '무료', 'used': false},
    {'store': '프리미엄 타이어 전문점', 'title': '타이어 교체 10,000원 할인', 'expires': '2025-04-30', 'discount': '10,000원', 'used': true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: AppHeader(title: '쿠폰', notifCount: AppState().notificationCount),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: coupons.length,
              itemBuilder: (_, i) {
                final c = coupons[i];
                final used = c['used'] as bool;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: used ? AppColors.bgGray : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: used ? AppColors.border : AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: used ? AppColors.border : AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(c['discount'] as String,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: used ? AppColors.textMuted : AppColors.primary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(c['store'] as String,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: used ? AppColors.textMuted : AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(c['title'] as String,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: used ? AppColors.textMuted : AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('유효기간: ${c['expires']}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: used ? AppColors.textMuted : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (used)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.textMuted,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('사용완료',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 협회 인증 ====================
class CertScreen extends StatelessWidget {
  const CertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: AppHeader(title: '협회 인증', notifCount: AppState().notificationCount),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const KaaLogo(size: 28, dark: true),
                        const SizedBox(height: 12),
                        const Text('한국자동차협회\n공식 인증',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text('인증된 점포에서 안심하고 서비스를 받으세요.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.7)),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('인증서 발급 신청하기',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...AppData.stores.where((s) => s.type == 'certified').map((s) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.textPrimary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.verified, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.name,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                ),
                                Text('${s.category} · ${s.distance}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: AppColors.textMuted),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 중고차 ====================
class UsedCarScreen extends StatelessWidget {
  const UsedCarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: AppHeader(title: '중고차', notifCount: AppState().notificationCount),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 검색 바
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search, color: AppColors.textMuted, size: 18),
                        SizedBox(width: 8),
                        Text('차량 검색 (제조사, 모델명)',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 필터 칩
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['전체', '국산차', '수입차', '전기차', '연식순', '가격순'].map((f) {
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: f == '전체' ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: f == '전체' ? AppColors.primary : AppColors.border,
                            ),
                          ),
                          child: Text(f,
                            style: TextStyle(
                              fontSize: 12,
                              color: f == '전체' ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 중고차 카드 목록
                  ...[
                    {'name': '2022 현대 아반떼 1.6 가솔린', 'price': '1,850만원', 'km': '32,000km', 'year': '2022년식', 'image': 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=400&q=80'},
                    {'name': '2021 기아 K5 2.0 하이브리드', 'price': '2,300만원', 'km': '48,000km', 'year': '2021년식', 'image': 'https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?w=400&q=80'},
                    {'name': '2020 BMW 320i', 'price': '3,200만원', 'km': '55,000km', 'year': '2020년식', 'image': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&q=80'},
                    {'name': '2023 테슬라 Model 3', 'price': '4,500만원', 'km': '12,000km', 'year': '2023년식', 'image': 'https://images.unsplash.com/photo-1593941707882-a5bba14938c7?w=400&q=80'},
                  ].map((car) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
                            child: Image.network(
                              car['image'] as String,
                              width: 120,
                              height: 90,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 120,
                                height: 90,
                                color: AppColors.bgGray,
                                child: const Icon(Icons.directions_car, color: AppColors.textMuted),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.badgeCert,
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                        child: const Text('KAA 인증',
                                          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(car['name'] as String,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text('${car['year']} · ${car['km']}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(car['price'] as String,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 마이 페이지 ====================
class MyScreen extends StatelessWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AppState().user;
    final isLoggedIn = AppState().isLoggedIn;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: AppHeader(title: '마이', notifCount: AppState().notificationCount),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 프로필 카드
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                          ),
                          child: Center(
                            child: Text(
                              isLoggedIn ? (user?.name.substring(0, 1) ?? 'K') : 'K',
                              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: isLoggedIn
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(user?.name ?? '',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                  ),
                                  const Text('일반 이용자',
                                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('로그인 해주세요',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.pushNamed(context, '/login'),
                                    child: const Text('로그인 / 회원가입',
                                      style: TextStyle(fontSize: 12, color: AppColors.primary),
                                    ),
                                  ),
                                ],
                              ),
                        ),
                        if (isLoggedIn)
                          const Icon(Icons.chevron_right, color: AppColors.textMuted),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 메뉴 섹션들
                  _buildSection('내 활동', [
                    _MenuItem(icon: Icons.receipt_long_outlined, label: '견적 내역', onTap: () {}),
                    _MenuItem(icon: Icons.favorite_border, label: '즐겨찾기 점포', onTap: () {}),
                    _MenuItem(icon: Icons.confirmation_number_outlined, label: '내 쿠폰', onTap: () => Navigator.pushNamed(context, '/coupon')),
                    _MenuItem(icon: Icons.card_giftcard, label: '리워드 포인트', onTap: () {}),
                  ]),

                  const SizedBox(height: 8),

                  _buildSection('차량 관리', [
                    _MenuItem(icon: Icons.directions_car_outlined, label: '내 차량 등록', onTap: () {}),
                    _MenuItem(icon: Icons.history, label: '정비 이력', onTap: () {}),
                    _MenuItem(icon: Icons.monetization_on_outlined, label: '내차 시세 조회', onTap: () {}),
                  ]),

                  const SizedBox(height: 8),

                  _buildSection('점포 관리', [
                    _MenuItem(icon: Icons.store_outlined, label: '점포 등록', onTap: () => Navigator.pushNamed(context, '/store-register')),
                    _MenuItem(icon: Icons.verified_outlined, label: '협회 인증 신청', onTap: () => Navigator.pushNamed(context, '/cert')),
                  ]),

                  const SizedBox(height: 8),

                  _buildSection('설정', [
                    _MenuItem(icon: Icons.notifications_outlined, label: '알림 설정', onTap: () {}),
                    _MenuItem(icon: Icons.lock_outline, label: '개인정보 설정', onTap: () {}),
                    if (isLoggedIn)
                      _MenuItem(
                        icon: Icons.logout,
                        label: '로그아웃',
                        color: AppColors.danger,
                        onTap: () {
                          AppState().logout();
                          Navigator.pushNamedAndRemoveUntil(context, '/intro', (_) => false);
                        },
                      ),
                  ]),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<_MenuItem> items) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Text(title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted),
            ),
          ),
          ...items.map((item) => ListTile(
            leading: Icon(item.icon, size: 20, color: item.color ?? AppColors.textSecondary),
            title: Text(item.label,
              style: TextStyle(fontSize: 14, color: item.color ?? AppColors.textPrimary),
            ),
            trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
            onTap: item.onTap,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            dense: true,
          )),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;
  _MenuItem({required this.icon, required this.label, this.color, required this.onTap});
}

// ==================== 알림 ====================
class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {'title': '견적 요청 접수', 'body': '프리미엄 정비소에서 견적이 도착했습니다.', 'time': '방금 전', 'icon': '📋'},
      {'title': '쿠폰 만료 예정', 'body': '엔진오일 20% 할인 쿠폰이 3일 후 만료됩니다.', 'time': '1시간 전', 'icon': '🎟️'},
      {'title': 'KAA 인증 완료', 'body': 'KAA 추천 정비소가 인증 완료되었습니다.', 'time': '2일 전', 'icon': '✅'},
      {'title': '새로운 뉴스', 'body': '전기차 보조금 2025년 변경사항 안내', 'time': '3일 전', 'icon': '📰'},
    ];

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: AppHeader(showBack: true, title: '알림', notifCount: 0),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (_, i) {
                final n = notifications[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(n['icon'] as String, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(n['title'] as String,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 3),
                            Text(n['body'] as String,
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Text(n['time'] as String,
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 견적 요청 ====================
class QuoteRequestScreen extends StatelessWidget {
  const QuoteRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: AppHeader(showBack: true, title: '견적 요청', notifCount: AppState().notificationCount),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('견적 요청',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  const Text('차량 사진을 업로드하고 근처 정비점에 견적을 요청하세요.',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),

                  // 카테고리 선택
                  const Text('서비스 종류',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['정비', '세차', '타이어', '판금/도색', '내장 수리', '기타'].map((c) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: c == '정비' ? AppColors.primaryLight : AppColors.bgGray,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: c == '정비' ? AppColors.primary : AppColors.border,
                          ),
                        ),
                        child: Text(c,
                          style: TextStyle(
                            fontSize: 13,
                            color: c == '정비' ? AppColors.primary : AppColors.textSecondary,
                            fontWeight: c == '정비' ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // 사진 업로드 영역
                  const Text('차량 사진',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: AppColors.bgGray,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined, size: 40, color: AppColors.textMuted),
                          SizedBox(height: 8),
                          Text('사진 촬영 또는 갤러리에서 선택',
                            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 요청 내용
                  const Text('상세 내용',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: '수리가 필요한 부분이나 증상을 설명해 주세요.',
                      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('견적 요청이 접수되었습니다!')),
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('견적 요청하기',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 점포 등록 ====================
class StoreRegisterScreen extends StatelessWidget {
  const StoreRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: AppHeader(showBack: true, title: '점포 등록', notifCount: AppState().notificationCount),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('🤖 AI 점포 페이지 생성',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary),
                        ),
                        SizedBox(height: 6),
                        Text('사진 3장만 올리면 AI가 자동으로 점포 소개 페이지를 만들어 드립니다. 무료로 시작하세요!',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('점포명',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      hintText: '점포명을 입력해 주세요',
                      hintStyle: const TextStyle(color: AppColors.textMuted),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('업종',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      hintText: '업종을 입력해 주세요 (예: 정비, 세차)',
                      hintStyle: const TextStyle(color: AppColors.textMuted),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('주소',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      hintText: '주소를 입력해 주세요',
                      hintStyle: const TextStyle(color: AppColors.textMuted),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('점포 등록 신청이 접수되었습니다!')),
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('점포 등록 신청',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 뉴스 ====================
class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final news = [
      {'title': '중고차 성능점검 확인 수요 확대', 'category': '자동차 소식', 'time': '2시간 전', 'image': 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=300&q=80'},
      {'title': '2025년 전기차 보조금 변경 사항 정리', 'category': '전기차·친환경', 'time': '5시간 전', 'image': 'https://images.unsplash.com/photo-1593941707882-a5bba14938c7?w=300&q=80'},
      {'title': '봄철 타이어 관리 필수 체크리스트', 'category': '차량 정비', 'time': '1일 전', 'image': 'https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?w=300&q=80'},
      {'title': 'KAA 협회 인증 점포 확대 안내', 'category': 'KAA 소식', 'time': '2일 전', 'image': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=300&q=80'},
    ];

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: AppHeader(showBack: true, title: '자동차 뉴스', notifCount: AppState().notificationCount),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: news.length,
              itemBuilder: (_, i) {
                final n = news[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                        child: Image.network(
                          n['image'] as String,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 90, height: 90,
                            color: AppColors.bgGray,
                            child: const Icon(Icons.article, color: AppColors.textMuted),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(n['category'] as String,
                                  style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(n['title'] as String,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(n['time'] as String,
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 긴급서비스 ====================
class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: AppHeader(showBack: true, title: '긴급서비스', notifCount: AppState().notificationCount),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.danger.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        const Text('🚨', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        const Text('긴급출동 서비스',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.danger),
                        ),
                        const SizedBox(height: 8),
                        const Text('배터리 방전, 타이어 펑크, 시동불량 등\n긴급 상황에서 도움을 드립니다.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('긴급출동 요청이 접수되었습니다. 잠시만 기다려주세요.')),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.danger,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('긴급출동 요청하기',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...['배터리 방전', '타이어 펑크', '시동 불량', '연료 부족', '잠금 해제'].map((service) {
                    return ListTile(
                      leading: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.danger.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.build, color: AppColors.danger, size: 20),
                      ),
                      title: Text(service, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
                      onTap: () {},
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 내차 시세 ====================
class CarPriceScreen extends StatelessWidget {
  const CarPriceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: AppHeader(showBack: true, title: '내차 시세', notifCount: AppState().notificationCount),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9E6),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFFD54A)),
                    ),
                    child: const Column(
                      children: [
                        Text('💰', style: TextStyle(fontSize: 40)),
                        SizedBox(height: 8),
                        Text('내 차 시세를 알아보세요',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFFD4A017)),
                        ),
                        SizedBox(height: 6),
                        Text('차량 정보를 입력하면 즉시 시세를 확인할 수 있습니다.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildFormField('차량 번호', '123가 4567'),
                  const SizedBox(height: 16),
                  _buildFormField('제조사', '현대, 기아, BMW 등'),
                  const SizedBox(height: 16),
                  _buildFormField('모델명', '아반떼, K5 등'),
                  const SizedBox(height: 16),
                  _buildFormField('연식', '2020, 2021 등'),
                  const SizedBox(height: 16),
                  _buildFormField('주행거리', '예: 50,000 km'),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('시세 조회 중입니다...')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4A017),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('시세 조회하기',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}
