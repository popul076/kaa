import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

// ==================== 점포 등록 (다크테마 + AI 애니메이션 + 1~3장 사진) ====================
class StoreRegisterScreen extends StatefulWidget {
  const StoreRegisterScreen({super.key});
  @override
  State<StoreRegisterScreen> createState() => _StoreRegisterScreenState();
}

class _StoreRegisterScreenState extends State<StoreRegisterScreen>
    with TickerProviderStateMixin {
  // 0:사업자확인, 1:AI안내, 2:사진업로드(1~3장), 3:AI생성중, 4:결과, 5:완료
  int _step = 0;

  final TextEditingController _bizNumCtrl = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  // 선택된 이미지 파일 목록 (최대 3장)
  final List<File> _photos = [];

  // 품질 검사 상태
  String? _qualityError;
  bool _isCheckingQuality = false;

  // AI 애니메이션 컨트롤러
  late AnimationController _aiAnimCtrl;
  late Animation<double> _aiProgress;
  String _aiStatus = '이미지 분석 중...';
  int _aiPhase = 0;
  static const _aiPhases = [
    '이미지 분석 중...',
    '점포 정보 추출 중...',
    '태그라인 생성 중...',
    '페이지 완성! ✨',
  ];

  // 다크테마 색상
  static const _bg = Color(0xFF020810);
  static const _card = Color(0xFF0D1B2A);
  static const _accent = Color(0xFF4FC3F7);
  static const _accentBtn = Color(0xFF0D47A1);
  static const _textPrimary = Colors.white;
  static const _textSecondary = Color(0xFFB0BEC5);
  static const _borderCol = Color(0xFF1E3A5F);

  @override
  void initState() {
    super.initState();
    _aiAnimCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 4));
    _aiProgress = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _aiAnimCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bizNumCtrl.dispose();
    _aiAnimCtrl.dispose();
    super.dispose();
  }

  void _next() => setState(() => _step++);
  void _prev() {
    if (_step == 0) {
      Navigator.pop(context);
      return;
    }
    setState(() => _step--);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1280,
      );
      if (picked == null) return;

      if (_photos.length >= 3) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('사진은 최대 3장까지 등록할 수 있습니다'),
              backgroundColor: Color(0xFF1565C0),
            ),
          );
        }
        return;
      }

      setState(() {
        _isCheckingQuality = true;
        _qualityError = null;
      });

      final file = File(picked.path);
      final size = await file.length();

      if (size < 5 * 1024) {
        // 5KB 미만 차단
        setState(() {
          _isCheckingQuality = false;
          _qualityError = '사진 용량이 너무 작습니다. 더 선명한 사진을 선택해 주세요.';
        });
        return;
      }

      setState(() {
        _photos.add(file);
        _isCheckingQuality = false;
        _qualityError = null;
      });
    } catch (e) {
      setState(() => _isCheckingQuality = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('사진을 가져올 수 없습니다: $e'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }

  void _removePhoto(int idx) => setState(() => _photos.removeAt(idx));

  void _startAiGeneration() {
    setState(() {
      _step = 3;
      _aiPhase = 0;
      _aiStatus = _aiPhases[0];
    });
    _aiAnimCtrl.reset();
    _aiAnimCtrl.forward();

    for (int i = 1; i < _aiPhases.length; i++) {
      Future.delayed(Duration(milliseconds: 900 * i), () {
        if (mounted) setState(() {
          _aiPhase = i;
          _aiStatus = _aiPhases[i];
        });
      });
    }
    Future.delayed(const Duration(milliseconds: 4300), () {
      if (mounted) setState(() => _step = 4);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopNav(),
            if (_step == 2) _buildPhotoStepIndicator(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  // ── 상단 네비 ────────────────────────────────────────────────
  Widget _buildTopNav() {
    final titles = [
      '사업자 확인',
      'AI 점포 페이지',
      '사진 등록 (1~3장)',
      'AI 생성 중',
      'AI 결과 확인',
      '등록 완료',
    ];
    final title = _step < titles.length ? titles[_step] : '점포 등록';
    final progress = (_step + 1) / titles.length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: _prev,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _borderCol),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new,
                      size: 16, color: _textPrimary),
                ),
              ),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary),
                ),
              ),
              const SizedBox(width: 36),
            ],
          ),
        ),
        // 진행 바
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 3,
              backgroundColor: _borderCol,
              valueColor: const AlwaysStoppedAnimation<Color>(_accent),
            ),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  // ── 사진 단계 표시 (step 2용) ────────────────────────────────
  Widget _buildPhotoStepIndicator() {
    final count = _photos.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Row(
        children: List.generate(3, (i) {
          final filled = i < count;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: filled ? _accent : _borderCol,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── 본문 라우팅 ──────────────────────────────────────────────
  Widget _buildBody() {
    switch (_step) {
      case 0:
        return _buildBizCheck();
      case 1:
        return _buildAiIntro();
      case 2:
        return _buildPhotoUpload();
      case 3:
        return _buildAiGenerating();
      case 4:
        return _buildAiResult();
      case 5:
        return _buildComplete();
      default:
        return const SizedBox();
    }
  }

  // ── STEP 0: 사업자 확인 ──────────────────────────────────────
  Widget _buildBizCheck() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0D2A4A), Color(0xFF1565C0)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🏪', style: TextStyle(fontSize: 38)),
                const SizedBox(height: 14),
                const Text(
                  '점포 등록 시작',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  '사업자 정보를 확인하고\nAI가 자동으로 점포 페이지를 만들어 드립니다',
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.85),
                      height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            '사업자등록번호',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _textSecondary),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _bizNumCtrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: _textPrimary),
            decoration: InputDecoration(
              hintText: '000-00-00000',
              hintStyle: const TextStyle(color: Color(0xFF607D8B)),
              prefixIcon: const Icon(Icons.business_outlined,
                  color: _accent, size: 20),
              filled: true,
              fillColor: _card,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _borderCol)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _borderCol)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _accent, width: 1.5)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _borderCol),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💡', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '사업자등록번호 10자리를 입력하면 국세청 데이터베이스에서 자동으로 점포 정보를 불러옵니다.',
                    style: TextStyle(
                        fontSize: 12,
                        color: _textSecondary,
                        height: 1.5),
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
                backgroundColor: _accent,
                foregroundColor: _bg,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text(
                '사업자 조회하기',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF020810)),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── STEP 1: AI 안내 ──────────────────────────────────────────
  Widget _buildAiIntro() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            '🤖 AI 점포 페이지 자동 생성',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            '사진 1~3장만 올리면 AI가 자동으로 점포 소개 페이지를 만들어 드립니다. 완전 무료!',
            style:
                TextStyle(fontSize: 14, color: _textSecondary, height: 1.6),
          ),
          const SizedBox(height: 28),
          _buildIntroCard(
              num: '01',
              title: '간판·외관 사진',
              sub: '점포 전면 사진 (필수)',
              icon: '🏪',
              color: const Color(0xFF1565C0)),
          const SizedBox(height: 12),
          _buildIntroCard(
              num: '02',
              title: '전시장·내부 사진',
              sub: '내부 공간 사진 (선택)',
              icon: '🏢',
              color: const Color(0xFF00897B)),
          const SizedBox(height: 12),
          _buildIntroCard(
              num: '03',
              title: '대표차량·서비스',
              sub: '주력 서비스 사진 (선택)',
              icon: '🚗',
              color: const Color(0xFFE65100)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _borderCol),
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
                backgroundColor: _accent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '사진 등록 시작하기',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF020810)),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward,
                      color: Color(0xFF020810), size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildIntroCard(
      {required String num,
      required String title,
      required String sub,
      required String icon,
      required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderCol),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STEP $num  $title',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary),
                ),
                const SizedBox(height: 2),
                Text(sub,
                    style: const TextStyle(
                        fontSize: 12, color: _textSecondary)),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.18),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
                num == '01' ? '필수' : '선택',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color)),
          ),
        ],
      ),
    );
  }

  // ── STEP 2: 사진 업로드 (1~3장, 한 화면) ──────────────────────
  Widget _buildPhotoUpload() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            '점포 사진 등록',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            '간판·외관 사진은 필수입니다. 최대 3장까지 등록할 수 있습니다.',
            style: const TextStyle(
                fontSize: 13, color: _textSecondary, height: 1.5),
          ),
          const SizedBox(height: 20),

          // 사진 그리드
          if (_photos.isEmpty)
            _buildEmptyPhotoSlot(0)
          else ...[
            // 등록된 사진 목록
            ...List.generate(_photos.length, (i) => _buildPhotoItem(i)),
            // 추가 슬롯 (3장 미만인 경우)
            if (_photos.length < 3) ...[
              const SizedBox(height: 10),
              _buildAddPhotoButton(),
            ],
          ],

          // 품질 오류 메시지
          if (_qualityError != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Colors.redAccent, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _qualityError!,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.redAccent),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // 품질 검사 로딩
          if (_isCheckingQuality) ...[
            const SizedBox(height: 12),
            const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: _accent)),
                  SizedBox(width: 10),
                  Text('사진 품질 확인 중...',
                      style:
                          TextStyle(fontSize: 13, color: _textSecondary)),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // 사진 업로드 안내
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _borderCol),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('📸 사진 등록 가이드',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _accent)),
                SizedBox(height: 8),
                _GuideRow(text: '간판과 출입구가 잘 보이는 정면 사진을 먼저 올려주세요'),
                _GuideRow(text: '밝고 선명한 사진일수록 AI 결과가 좋아집니다'),
                _GuideRow(text: '사진은 세로·가로 모두 가능합니다'),
                _GuideRow(text: '5KB 미만의 저품질 사진은 자동으로 차단됩니다'),
              ],
            ),
          ),

          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _photos.isEmpty ? null : _startAiGeneration,
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                disabledBackgroundColor: _borderCol,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'AI 점포 페이지 생성 (${_photos.length}장)',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _photos.isEmpty
                            ? _textSecondary
                            : const Color(0xFF020810)),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.auto_awesome,
                      color: _photos.isEmpty
                          ? _textSecondary
                          : const Color(0xFF020810),
                      size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildEmptyPhotoSlot(int idx) {
    return GestureDetector(
      onTap: () => _showPickerDialog(),
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: _accent.withOpacity(0.5),
              width: 1.5,
              style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _accent.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_a_photo_outlined,
                  color: _accent, size: 28),
            ),
            const SizedBox(height: 12),
            const Text('간판·외관 사진 추가 (필수)',
                style: TextStyle(
                    color: _accent,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            const Text('탭하여 카메라 또는 갤러리에서 선택',
                style: TextStyle(color: _textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoItem(int idx) {
    final labels = ['간판·외관 (필수)', '내부·전시장 (선택)', '대표차량·서비스 (선택)'];
    final label = idx < labels.length ? labels[idx] : '추가 사진';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderCol),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(14)),
            child: Image.file(
              _photos[idx],
              width: 90,
              height: 90,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STEP ${idx + 1}  $label',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary),
                ),
                const SizedBox(height: 4),
                const Row(
                  children: [
                    Icon(Icons.check_circle,
                        color: Color(0xFF4CAF50), size: 14),
                    SizedBox(width: 4),
                    Text('등록 완료',
                        style: TextStyle(
                            fontSize: 12, color: Color(0xFF4CAF50))),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _removePhoto(idx),
            child: Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close,
                  color: Colors.redAccent, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPhotoButton() {
    return GestureDetector(
      onTap: () => _showPickerDialog(),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderCol, style: BorderStyle.solid),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined,
                color: _accent, size: 20),
            SizedBox(width: 8),
            Text('사진 추가하기 (+)',
                style: TextStyle(
                    color: _accent,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  void _showPickerDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: _borderCol,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text('사진 선택',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _PickerOption(
                      icon: Icons.camera_alt_outlined,
                      label: '카메라 촬영',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PickerOption(
                      icon: Icons.photo_library_outlined,
                      label: '앨범에서 선택',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ── STEP 3: AI 생성 중 (타이핑 애니메이션) ───────────────────
  Widget _buildAiGenerating() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // AI 아이콘 + 맥동 효과
            AnimatedBuilder(
              animation: _aiAnimCtrl,
              builder: (_, __) {
                return Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0D47A1), Color(0xFF4FC3F7)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _accent
                            .withOpacity(0.2 + 0.2 * _aiProgress.value),
                        blurRadius: 20 + 12 * _aiProgress.value,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🤖', style: TextStyle(fontSize: 44)),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            const Text(
              'AI가 점포 페이지를\n생성하고 있습니다',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _textPrimary),
            ),
            const SizedBox(height: 16),
            // 타이핑 애니메이션 텍스트
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Text(
                _aiStatus,
                key: ValueKey(_aiStatus),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14, color: _accent, height: 1.6),
              ),
            ),
            const SizedBox(height: 32),
            // 진행률 바
            AnimatedBuilder(
              animation: _aiProgress,
              builder: (_, __) => Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _aiProgress.value,
                      minHeight: 6,
                      backgroundColor: _borderCol,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(_accent),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(_aiProgress.value * 100).toInt()}%',
                    style: const TextStyle(
                        fontSize: 13,
                        color: _accent,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // 단계 뱃지
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final done = i <= _aiPhase;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: done ? _accent : _borderCol,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ── STEP 4: AI 결과 ──────────────────────────────────────────
  Widget _buildAiResult() {
    final mainPhoto =
        _photos.isNotEmpty ? _photos[0] : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF1B5E20).withOpacity(0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('✅ AI 생성 완료',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF81C784))),
          ),
          const SizedBox(height: 10),
          const Text(
            '점포 페이지 미리보기',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _textPrimary),
          ),
          const SizedBox(height: 20),

          Container(
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _borderCol),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 대표 사진
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: mainPhoto != null
                      ? Image.file(mainPhoto,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover)
                      : Image.network(
                          'https://images.unsplash.com/photo-1487958449943-2429e8be8625?w=400&q=80',
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                              height: 160, color: const Color(0xFF1E3A5F))),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _accent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: _accent.withOpacity(0.4)),
                            ),
                            child: const Text('MOINCAR 인증',
                                style: TextStyle(
                                    color: _accent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'MOINCAR 인증 점포',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: _textPrimary),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'AI가 분석한 점포 정보',
                        style: TextStyle(
                            fontSize: 13, color: _textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _bg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _borderCol),
                        ),
                        child: const Text(
                          '"고객 신뢰를 최우선으로, MOINCAR 공인 인증 자동차 전문점"',
                          style: TextStyle(
                              fontSize: 12,
                              color: _accent,
                              fontStyle: FontStyle.italic,
                              height: 1.4),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const _DarkResultRow(
                          icon: Icons.location_on_outlined,
                          text: '서울특별시 강남구 테헤란로 123'),
                      const _DarkResultRow(
                          icon: Icons.phone_outlined,
                          text: '010-1234-5678'),
                      const _DarkResultRow(
                          icon: Icons.access_time,
                          text: '월~토 09:00~18:00 / 일 휴무'),
                    ],
                  ),
                ),
                // 등록된 사진 썸네일
                if (_photos.isNotEmpty)
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: Row(
                      children: List.generate(
                        _photos.length,
                        (i) => Expanded(
                          child: Container(
                            margin: EdgeInsets.only(right: i < _photos.length - 1 ? 6 : 0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(_photos[i],
                                  height: 60, fit: BoxFit.cover),
                            ),
                          ),
                        ),
                      ),
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
                backgroundColor: _accent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text(
                '이 페이지로 등록하기',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF020810)),
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
                side: const BorderSide(color: _borderCol),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('사진 다시 등록하기',
                  style:
                      TextStyle(fontSize: 14, color: _textSecondary)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── STEP 5: 등록 완료 ─────────────────────────────────────────
  Widget _buildComplete() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF020810), Color(0xFF0D2A3E)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _accent, width: 2),
                  color: _accent.withOpacity(0.12),
                ),
                child: const Icon(Icons.check, size: 44, color: _accent),
              ),
              const SizedBox(height: 28),
              const Text(
                '점포 등록 완료!',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: _textPrimary),
              ),
              const SizedBox(height: 10),
              Text(
                'MOINCAR 인증 점포',
                style:
                    TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.8)),
              ),
              const SizedBox(height: 10),
              Text(
                'AI 점포 페이지가 성공적으로 생성되었습니다.\n검토 후 24시간 내 공개될 예정입니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.55),
                    height: 1.6),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context, '/home', (_) => false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text(
                    '홈으로 돌아가기',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF020810)),
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
        Text(text,
            style: const TextStyle(
                fontSize: 13,
                color: Color(0xFFB0BEC5))),
      ],
    );
  }
}

class _GuideRow extends StatelessWidget {
  final String text;
  const _GuideRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('· ',
              style: TextStyle(color: Color(0xFF4FC3F7), fontSize: 13)),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFB0BEC5),
                    height: 1.4)),
          ),
        ],
      ),
    );
  }
}

class _DarkResultRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _DarkResultRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 15, color: const Color(0xFF607D8B)),
          const SizedBox(width: 6),
          Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFB0BEC5)))),
        ],
      ),
    );
  }
}

class _PickerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _PickerOption(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF1E3A5F).withOpacity(0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF1E3A5F)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF4FC3F7), size: 28),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(
                    color: Color(0xFFB0BEC5),
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ],
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
