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
// ==================== 점포 등록 메인 (다단계 플로우) ====================
class StoreRegisterScreen extends StatefulWidget {
  const StoreRegisterScreen({super.key});
  @override
  State<StoreRegisterScreen> createState() => _StoreRegisterScreenState();
}

class _StoreRegisterScreenState extends State<StoreRegisterScreen> {
  int _step = 0; // 0:사업자확인, 1:AI안내, 2:사진STEP1, 3:사진STEP2, 4:사진STEP3, 5:AI생성중, 6:결과, 7:완료

  final TextEditingController _bizNumCtrl = TextEditingController();
  final TextEditingController _img1Ctrl = TextEditingController(text: 'https://images.unsplash.com/photo-1487958449943-2429e8be8625?w=400&q=80');
  final TextEditingController _img2Ctrl = TextEditingController(text: 'https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?w=400&q=80');
  final TextEditingController _img3Ctrl = TextEditingController(text: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=400&q=80');

  @override
  void dispose() {
    _bizNumCtrl.dispose();
    _img1Ctrl.dispose();
    _img2Ctrl.dispose();
    _img3Ctrl.dispose();
    super.dispose();
  }

  void _next() => setState(() => _step++);
  void _prev() {
    if (_step == 0) { Navigator.pop(context); return; }
    setState(() => _step--);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 네비
            _buildTopNav(context),
            // 진행 바 (step 2~4)
            if (_step >= 2 && _step <= 4) _buildPhotoProgress(),
            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNav(BuildContext context) {
    final titles = ['사업자 확인', 'AI 점포 페이지', '간판·외관 사진', '전시장·내부 사진', '대표차량·서비스 사진', 'AI 생성 중', 'AI 결과 확인', '등록 완료'];
    final title = _step < titles.length ? titles[_step] : '점포 등록';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: _prev,
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Color(0xFF222222)),
            ),
          ),
          Expanded(
            child: Text(title, textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111111)),
            ),
          ),
          const SizedBox(width: 36),
        ],
      ),
    );
  }

  Widget _buildPhotoProgress() {
    final stepIdx = _step - 2; // 0,1,2
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Row(
        children: List.generate(3, (i) {
          final active = i == stepIdx;
          final done = i < stepIdx;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: (done || active) ? const Color(0xFF1565C0) : const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (i < 2) const SizedBox(width: 4),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_step) {
      case 0: return _buildBizCheck(context);
      case 1: return _buildAiIntro(context);
      case 2: return _buildPhotoStep(context, step: 1, ctrl: _img1Ctrl, title: 'STEP 1', subtitle: '간판·외관 사진', desc: '점포 간판과 출입구가 잘 보이는\n정면 사진을 업로드하세요', icon: '🏪');
      case 3: return _buildPhotoStep(context, step: 2, ctrl: _img2Ctrl, title: 'STEP 2', subtitle: '전시장·내부 사진', desc: '전시장 내부 또는 작업 공간\n전체가 보이는 사진을 올려주세요', icon: '🏢');
      case 4: return _buildPhotoStep(context, step: 3, ctrl: _img3Ctrl, title: 'STEP 3', subtitle: '대표차량·서비스 사진', desc: '주력 차량이나 서비스 장면이\n담긴 대표 사진을 올려주세요', icon: '🚗');
      case 5: return _buildAiGenerating(context);
      case 6: return _buildAiResult(context);
      case 7: return _buildComplete(context);
      default: return const SizedBox();
    }
  }

  // ── STEP 0: 사업자 확인 ──────────────────────────────────────
  Widget _buildBizCheck(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0D2A4A), Color(0xFF1565C0)],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🏪', style: TextStyle(fontSize: 36)),
                const SizedBox(height: 12),
                const Text('점포 등록 시작',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text('사업자 정보를 확인하고\nAI가 자동으로 점포 페이지를 만들어 드립니다',
                  style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.85), height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text('사업자등록번호',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _bizNumCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '000-00-00000',
              hintStyle: const TextStyle(color: Color(0xFFBBBBBB)),
              prefixIcon: const Icon(Icons.business_outlined, color: Color(0xFF1565C0), size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1565C0), width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('💡', style: TextStyle(fontSize: 14)),
                SizedBox(width: 8),
                Expanded(
                  child: Text('사업자등록번호 10자리를 입력하면 국세청 데이터베이스에서 자동으로 점포 정보를 불러옵니다.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF555555), height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _next,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text('사업자 조회하기',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── STEP 1: AI 안내 ──────────────────────────────────────────
  Widget _buildAiIntro(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text('🤖 AI 점포 페이지 자동 생성',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF111111)),
          ),
          const SizedBox(height: 8),
          const Text('사진 3장만 올리면 AI가 자동으로 점포 소개 페이지를 만들어 드립니다. 무료로 시작하세요!',
            style: TextStyle(fontSize: 14, color: Color(0xFF666666), height: 1.6),
          ),
          const SizedBox(height: 28),
          _buildStepCard(num: '01', title: '간판·외관 사진', sub: '점포 전면 사진 1장', icon: '🏪', color: const Color(0xFF1565C0)),
          const SizedBox(height: 12),
          _buildStepCard(num: '02', title: '전시장·내부 사진', sub: '내부 공간 사진 1장', icon: '🏢', color: const Color(0xFF00897B)),
          const SizedBox(height: 12),
          _buildStepCard(num: '03', title: '대표차량·서비스', sub: '주력 서비스 사진 1장', icon: '🚗', color: const Color(0xFFE65100)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF1565C0).withOpacity(0.2)),
            ),
            child: const Column(
              children: [
                _AiFeatureRow(icon: '✨', text: 'AI 태그라인·소개 자동 작성'),
                SizedBox(height: 8),
                _AiFeatureRow(icon: '📍', text: '주소·영업시간·전화번호 자동 설정'),
                SizedBox(height: 8),
                _AiFeatureRow(icon: '🆓', text: '완전 무료 — 추가 비용 없음'),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _next,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('사진 등록 시작하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStepCard({required String num, required String title, required String sub, required String icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('STEP $num  $title',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111111)),
                ),
                const SizedBox(height: 2),
                Text(sub, style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('1장', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          ),
        ],
      ),
    );
  }

  // ── STEP 2~4: 사진 업로드 ────────────────────────────────────
  Widget _buildPhotoStep(BuildContext context, {
    required int step,
    required TextEditingController ctrl,
    required String title,
    required String subtitle,
    required String desc,
    required String icon,
  }) {
    final colors = [const Color(0xFF1565C0), const Color(0xFF00897B), const Color(0xFFE65100)];
    final c = colors[step - 1];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: c.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c)),
          ),
          const SizedBox(height: 10),
          Text(subtitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF111111))),
          const SizedBox(height: 6),
          Text(desc, style: const TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.5)),
          const SizedBox(height: 20),

          // 사진 미리보기
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: ctrl.text.isNotEmpty
                ? Image.network(ctrl.text, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFF0F0F0),
                      child: Center(child: Text(icon, style: const TextStyle(fontSize: 40))),
                    ))
                : Container(
                    color: const Color(0xFFF5F5F5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(icon, style: const TextStyle(fontSize: 40)),
                        const SizedBox(height: 8),
                        const Text('사진을 등록해 주세요', style: TextStyle(fontSize: 14, color: Color(0xFF999999))),
                      ],
                    ),
                  ),
            ),
          ),
          const SizedBox(height: 16),

          // 업로드 버튼 2개
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.camera_alt_outlined, size: 16),
                  label: const Text('사진 촬영'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0xFFDDDDDD)),
                    foregroundColor: const Color(0xFF333333),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.photo_library_outlined, size: 16),
                  label: const Text('갤러리에서 찾기'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0xFFDDDDDD)),
                    foregroundColor: const Color(0xFF333333),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // URL 직접 입력
          TextField(
            controller: ctrl,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: '이미지 URL 직접 입력',
              hintStyle: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 13),
              prefixIcon: const Icon(Icons.link, size: 18, color: Color(0xFF999999)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: c, width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                if (step == 3) {
                  setState(() => _step = 5); // AI 생성 시작
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) setState(() => _step = 6);
                  });
                } else {
                  _next();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: c,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(step == 3 ? 'AI 점포 페이지 생성' : '다음 사진 등록하기',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Icon(step == 3 ? Icons.auto_awesome : Icons.arrow_forward, color: Colors.white, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── STEP 5: AI 생성 중 ────────────────────────────────────────
  Widget _buildAiGenerating(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                ),
                boxShadow: [BoxShadow(color: const Color(0xFF1565C0).withOpacity(0.3), blurRadius: 20, spreadRadius: 4)],
              ),
              child: const Center(
                child: Text('🤖', style: TextStyle(fontSize: 40)),
              ),
            ),
            const SizedBox(height: 28),
            const Text('AI가 점포 페이지를\n생성하고 있습니다',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF111111)),
            ),
            const SizedBox(height: 12),
            const Text('업로드된 사진을 분석하여\n최적의 점포 소개 페이지를 만들고 있어요',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF888888), height: 1.6),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: Color(0xFF1565C0)),
          ],
        ),
      ),
    );
  }

  // ── STEP 6: AI 결과 ──────────────────────────────────────────
  Widget _buildAiResult(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('✅ AI 생성 완료', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1565C0))),
          ),
          const SizedBox(height: 10),
          const Text('점포 페이지 미리보기',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF111111)),
          ),
          const SizedBox(height: 20),

          // 점포 카드
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEEEEEE)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 3))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    _img1Ctrl.text,
                    height: 160, width: double.infinity, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(height: 160, color: const Color(0xFFEEEEEE)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1565C0),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('KAA 수성 인증', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text('KAA 수성 인증 중고차센터',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF111111)),
                      ),
                      const SizedBox(height: 4),
                      const Text('중고차 상품 등록',
                        style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('"고객 신뢰를 최우선으로, KAA 공인 인증 중고차 전문점"',
                          style: TextStyle(fontSize: 12, color: Color(0xFF555555), fontStyle: FontStyle.italic, height: 1.4),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _ResultRow(icon: Icons.location_on_outlined, text: '서울특별시 수성구 범어동 123-45'),
                      _ResultRow(icon: Icons.phone_outlined, text: '010-1234-5678'),
                      _ResultRow(icon: Icons.access_time, text: '월~토 09:00~18:00 / 일 휴무'),
                    ],
                  ),
                ),
                // 업로드된 3장
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: Row(
                    children: [
                      _SmallPhoto(_img1Ctrl.text),
                      const SizedBox(width: 6),
                      _SmallPhoto(_img2Ctrl.text),
                      const SizedBox(width: 6),
                      _SmallPhoto(_img3Ctrl.text),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _next,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text('이 페이지로 등록하기',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton(
              onPressed: () => setState(() => _step = 2),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFDDDDDD)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('사진 다시 등록하기', style: TextStyle(fontSize: 14, color: Color(0xFF666666))),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── STEP 7: 등록 완료 ────────────────────────────────────────
  Widget _buildComplete(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0B1120), Color(0xFF0D2A3E)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF4FC3F7), width: 2),
                  color: const Color(0xFF4FC3F7).withOpacity(0.15),
                ),
                child: const Icon(Icons.check, size: 40, color: Color(0xFF4FC3F7)),
              ),
              const SizedBox(height: 24),
              const Text('점포 등록 완료!',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text('KAA 수성 인증 중고차센터',
                style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.85)),
              ),
              const SizedBox(height: 8),
              Text('AI 점포 페이지가 성공적으로 생성되었습니다.\n검토 후 24시간 내 공개될 예정입니다.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.6), height: 1.6),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text('홈으로 돌아가기',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AiFeatureRow extends StatelessWidget {
  final String icon;
  final String text;
  const _AiFeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        Text(text, style: const TextStyle(fontSize: 13, color: Color(0xFF333333))),
      ],
    );
  }
}

class _ResultRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ResultRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 15, color: const Color(0xFF999999)),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: Color(0xFF666666)))),
        ],
      ),
    );
  }
}

class _SmallPhoto extends StatelessWidget {
  final String url;
  const _SmallPhoto(this.url);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(url, height: 60, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(height: 60, color: const Color(0xFFEEEEEE)),
        ),
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
