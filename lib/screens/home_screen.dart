import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';
import '../widgets/common_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentTab = 'home';
  final PageController _bannerCtrl = PageController();
  int _bannerIdx = 0;

  @override
  void dispose() {
    _bannerCtrl.dispose();
    super.dispose();
  }

  void _onTabChange(String tab) {
    if (tab == 'home') {
      setState(() => _currentTab = tab);
    } else {
      final routes = {
        'coupon': '/coupon',
        'cert': '/cert',
        'used-car': '/used-car',
        'my': '/my',
      };
      if (routes.containsKey(tab)) {
        Navigator.pushNamed(context, routes[tab]!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: AppHeader(
              showSearch: true,
              notifCount: AppState().notificationCount,
              onNotification: () => Navigator.pushNamed(context, '/notification'),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLocationBar(),
                  if (AppState().isLoggedIn) _buildStoreNudge(),
                  if (AppState().isLoggedIn) _buildEstimateAlert(),
                  _buildBannerSection(),
                  _buildCategorySection(),
                  _buildRecommendedStores(),
                  _buildQuickFeatures(),
                  _buildNearbyMap(),
                  _buildNearbyStores(),
                  _buildKaaCertBanner(),
                  _buildRecentStores(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          AppBottomNav(currentTab: _currentTab, onTab: _onTabChange),
        ],
      ),
    );
  }

  // ① 위치바
  Widget _buildLocationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white,
      child: Row(
        children: [
          const Icon(Icons.location_on, size: 16, color: AppColors.danger),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text('GPS',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 6),
          Text('${AppState().location} · 내 주변 자동차 서비스',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {},
            child: const Text('위치변경',
              style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // 점포 등록 유도
  Widget _buildStoreNudge() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/store-register'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Text('🏪', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('내 점포를 등록하세요',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  Text('무료로 AI 점포 페이지를 만들어 고객에게 노출하세요',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }

  // 견적 알림 카드
  Widget _buildEstimateAlert() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Text('🔔', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('주변에 견적요청이 있습니다',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                Text('점포 입장 6건이 도착했습니다.',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Row(
            children: [
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/notification'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  side: const BorderSide(color: AppColors.primary),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('알림함', style: TextStyle(fontSize: 11, color: AppColors.primary)),
              ),
              const SizedBox(width: 6),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('바로 보기', style: TextStyle(fontSize: 11, color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ② 메인 배너
  Widget _buildBannerSection() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: PageView.builder(
              controller: _bannerCtrl,
              onPageChanged: (i) => setState(() => _bannerIdx = i),
              itemCount: AppData.banners.length,
              itemBuilder: (_, i) {
                final b = AppData.banners[i];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: b.image,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.bgDark,
                          child: const Icon(Icons.image, color: Colors.white30),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withOpacity(0.65)],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(b.label,
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(b.title,
                              style: const TextStyle(
                                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(b.subtitle,
                              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          SmoothPageIndicator(
            controller: _bannerCtrl,
            count: AppData.banners.length,
            effect: const WormEffect(
              dotWidth: 6,
              dotHeight: 6,
              activeDotColor: AppColors.primary,
              dotColor: AppColors.border,
            ),
          ),
        ],
      ),
    );
  }

  // ③ 카테고리 칩
  Widget _buildCategorySection() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppData.categories.map((c) {
              return GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/store-category', arguments: c['name']),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.bgGray,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(c['name']!,
                    style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ④ 추천 점포 (2열 카드)
  Widget _buildRecommendedStores() {
    return Column(
      children: [
        SectionHeader(
          title: '추천 점포',
          subtitle: '상위 2개 점포 노출',
          actionLabel: '더보기',
          onAction: () => Navigator.pushNamed(context, '/store-list'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: AppData.stores.take(2).map((s) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: s == AppData.stores[0] ? 8 : 0),
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/store-detail', arguments: s.id),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF6366F1), Color(0xFF3B82F6)],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 이미지
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: CachedNetworkImage(
                              imageUrl: s.image,
                              height: 100,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => Container(
                                height: 100,
                                color: Colors.black38,
                                child: const Icon(Icons.store, color: Colors.white30),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text('${s.category} 추천',
                                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(s.name,
                                  style: const TextStyle(
                                    color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {},
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(color: Colors.white54),
                                          padding: const EdgeInsets.symmetric(vertical: 4),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: const Text('전화',
                                          style: TextStyle(color: Colors.white, fontSize: 11),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => Navigator.pushNamed(context, '/store-detail', arguments: s.id),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.textPrimary,
                                          padding: const EdgeInsets.symmetric(vertical: 4),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: const Text('둘러보기',
                                          style: TextStyle(color: Colors.white, fontSize: 11),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text('대표 포인트 ${s.distance}',
                                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ⑤ 빠른 기능 2×2 그리드
  Widget _buildQuickFeatures() {
    final features = [
      {'icon': '🚨', 'title': '긴급서비스', 'sub': '긴급출동', 'route': '/emergency', 'highlight': false},
      {'icon': '💰', 'title': '내차시세', 'sub': '즉시 조회', 'route': '/car-price', 'highlight': true},
      {'icon': '📰', 'title': '자동차뉴스', 'sub': '최신 소식', 'route': '/news', 'highlight': false},
      {'icon': '🎁', 'title': '이동 리워드', 'sub': '이동 포인트 적립', 'route': '/reward', 'highlight': false},
    ];

    return Column(
      children: [
        SectionHeader(
          title: '빠른 기능',
          subtitle: '핵심 진입 기능',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.6,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: features.map((f) {
              final isHighlight = f['highlight'] as bool;
              return GestureDetector(
                onTap: () => Navigator.pushNamed(context, f['route'] as String),
                child: Container(
                  decoration: BoxDecoration(
                    color: isHighlight ? const Color(0xFFFFF9E6) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isHighlight ? const Color(0xFFFFD54A) : AppColors.border,
                    ),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Text(f['icon'] as String, style: const TextStyle(fontSize: 26)),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(f['title'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isHighlight ? const Color(0xFFD4A017) : AppColors.textPrimary,
                            ),
                          ),
                          Text(f['sub'] as String,
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // 내 주변 지도 (placeholder)
  Widget _buildNearbyMap() {
    return Column(
      children: [
        SectionHeader(
          title: '내 주변 자동차 점포',
          subtitle: '내 위치 중심 미리보기',
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          height: 160,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F0FE),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Text('🗺️', style: TextStyle(fontSize: 60)),
              Positioned(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('내 위치',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 근처 점포 (필터 탭)
  Widget _buildNearbyStores() {
    return Column(
      children: [
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _FilterChip(label: '내 위치', color: AppColors.danger, isActive: true),
              const SizedBox(width: 8),
              _FilterChip(label: '인증점포', color: AppColors.primary, isActive: false),
              const SizedBox(width: 8),
              _FilterChip(label: '일반점포', color: AppColors.textSecondary, isActive: false),
            ],
          ),
        ),
        SectionHeader(
          title: '근처 점포',
          subtitle: '가까운 점포 3개씩 보기',
          actionLabel: '더보기',
          onAction: () => Navigator.pushNamed(context, '/store-list'),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: AppData.stores.take(3).length,
            itemBuilder: (_, i) {
              final s = AppData.stores[i];
              return GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/store-detail', arguments: s.id),
                child: Container(
                  width: 150,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: CachedNetworkImage(
                          imageUrl: s.image,
                          height: 100,
                          width: 150,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            height: 100,
                            color: AppColors.bgGray,
                            child: const Icon(Icons.store, color: AppColors.textMuted),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: s.type == 'certified' ? AppColors.badgeCert : AppColors.badgeNormal,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Text('KAA',
                                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                                  ),
                                ),
                                const Spacer(),
                                Text(s.distance,
                                  style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(s.name,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 3,
                              children: s.tags.take(2).map((t) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.bgGray,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(t,
                                  style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
                                ),
                              )).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // KAA 인증서 발급 배너
  Widget _buildKaaCertBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('한국자동차협회',
                  style: TextStyle(fontSize: 11, color: Colors.white60),
                ),
                Text('인증서 발급 신청하러가기',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/cert'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('신청하기', style: TextStyle(color: Colors.white, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  // 내가 본 점포
  Widget _buildRecentStores() {
    return Column(
      children: [
        SectionHeader(
          title: '내가 본 점포',
          subtitle: '최근 확인한 정보',
          actionLabel: '더보기',
          onAction: () => Navigator.pushNamed(context, '/store-list'),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: AppData.stores.skip(1).take(3).length,
            itemBuilder: (_, i) {
              final s = AppData.stores.skip(1).toList()[i];
              return GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/store-detail', arguments: s.id),
                child: Container(
                  width: 150,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: CachedNetworkImage(
                              imageUrl: s.image,
                              height: 100,
                              width: 150,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => Container(
                                height: 100,
                                color: AppColors.bgGray,
                                child: const Icon(Icons.store, color: AppColors.textMuted),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 6,
                            left: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.textPrimary,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: const Text('KAA',
                                style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.name,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(s.tags.take(2).join(' · '),
                              style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isActive;
  const _FilterChip({required this.label, required this.color, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.15) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isActive ? color : AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 4),
          Text(label,
            style: TextStyle(
              fontSize: 11,
              color: isActive ? color : AppColors.textSecondary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
