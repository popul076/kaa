import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';
import '../widgets/common_widgets.dart';

// ==================== 점포 목록 ====================
class StoreListScreen extends StatefulWidget {
  const StoreListScreen({super.key});

  @override
  State<StoreListScreen> createState() => _StoreListScreenState();
}

class _StoreListScreenState extends State<StoreListScreen> {
  String _filter = '전체';
  final List<String> _filters = ['전체', '정비', '세차', '타이어', '중고차'];

  @override
  Widget build(BuildContext context) {
    final filtered = _filter == '전체'
        ? AppData.stores
        : AppData.stores.where((s) => s.category == _filter).toList();

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: AppHeader(
              showBack: true,
              title: '점포 목록',
              notifCount: AppState().notificationCount,
            ),
          ),

          // 필터 탭
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _filters.map((f) {
                  final isActive = _filter == f;
                  return GestureDetector(
                    onTap: () => setState(() => _filter = f),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isActive ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      child: Text(f,
                        style: TextStyle(
                          fontSize: 13,
                          color: isActive ? Colors.white : AppColors.textSecondary,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (_, i) => _StoreListCard(
                store: filtered[i],
                onTap: () => Navigator.pushNamed(context, '/store-detail', arguments: filtered[i].id),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreListCard extends StatelessWidget {
  final Store store;
  final VoidCallback onTap;

  const _StoreListCard({required this.store, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
              child: CachedNetworkImage(
                imageUrl: store.image,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  width: 100,
                  height: 100,
                  color: AppColors.bgGray,
                  child: const Icon(Icons.store, color: AppColors.textMuted),
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
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: store.type == 'certified' ? AppColors.badgeCert : AppColors.badgeNormal,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(store.badge,
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const Spacer(),
                        Text(store.distance,
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(store.name,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text('⭐ ', style: TextStyle(fontSize: 12)),
                        Text('${store.rating}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        Text(' · 방문 ${store.visits}회',
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      children: store.tags.take(3).map((t) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.bgGray,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(t, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      )).toList(),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _callStore(context, store.phone),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              minimumSize: Size.zero,
                            ),
                            child: const Text('전화', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              minimumSize: Size.zero,
                            ),
                            child: const Text('길찾기', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _callStore(BuildContext context, String phone) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('전화: $phone')));
  }
}

// ==================== 점포 상세 (사용자용 - 잠금화면 클릭 진입) ====================
class StoreDetailScreen extends StatefulWidget {
  const StoreDetailScreen({super.key});

  @override
  State<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends State<StoreDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  int _heroIdx = 0;

  // MOINCAR dark theme
  static const Color _bg       = Color(0xFF020810);
  static const Color _card     = Color(0xFF0D1B2A);
  static const Color _accent   = Color(0xFF4FC3F7);
  static const Color _orange   = Color(0xFFFF6B35);
  static const Color _green    = Color(0xFF10B981);
  static const Color _textPri  = Colors.white;
  static const Color _textSec  = Color(0xFFB0BEC5);
  static const Color _border   = Color(0xFF1E3A5F);

  final List<Map<String, dynamic>> _heroImages = [
    {'label': '간판 / 외관', 'emoji': '🏪', 'color': Color(0xFF1A2F4A)},
    {'label': '매장 내부',   'emoji': '🔧', 'color': Color(0xFF1A3A2A)},
    {'label': '대표 차량',   'emoji': '🚗', 'color': Color(0xFF2A1A3A)},
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storeId = ModalRoute.of(context)?.settings.arguments as int? ?? 1;
    final store = AppData.stores.firstWhere(
      (s) => s.id == storeId,
      orElse: () => AppData.stores.first,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF020810),
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _bg,
        body: CustomScrollView(
          slivers: [
            // ─── 히어로 헤더 (사진 슬라이드) ───
            SliverToBoxAdapter(child: _buildHero(store)),

            // ─── 점포명 + 평점 + 태그 ───
            SliverToBoxAdapter(child: _buildTitle(store)),

            // ─── 빠른 액션 버튼 ───
            SliverToBoxAdapter(child: _buildQuickActions(context, store)),

            // ─── AI 소개글 ───
            SliverToBoxAdapter(child: _buildAiIntro(store)),

            // ─── 탭: 서비스 / 정보 / 리뷰 ───
            SliverToBoxAdapter(child: _buildTabBar()),
            SliverToBoxAdapter(child: _buildTabContent(context, store)),

            // ─── 하단 패딩 ───
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),

        // ─── 하단 고정 버튼 ───
        bottomNavigationBar: _buildBottomBar(context),
      ),
    );
  }

  // ── 히어로 슬라이드 ──
  Widget _buildHero(Store store) {
    return SizedBox(
      height: 260,
      child: Stack(
        children: [
          // 메인 이미지 / 이모지
          PageView.builder(
            itemCount: _heroImages.length,
            onPageChanged: (i) => setState(() => _heroIdx = i),
            itemBuilder: (_, i) => Container(
              color: _heroImages[i]['color'] as Color,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (i == 0)
                    CachedNetworkImage(
                      imageUrl: store.image,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Center(
                        child: Text(_heroImages[i]['emoji'] as String,
                          style: const TextStyle(fontSize: 80)),
                      ),
                    )
                  else
                    Center(
                      child: Text(_heroImages[i]['emoji'] as String,
                        style: const TextStyle(fontSize: 80)),
                    ),
                  // 그라디언트 오버레이
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                        stops: const [0.4, 1.0],
                      ),
                    ),
                  ),
                  // 라벨
                  Positioned(
                    bottom: 12, left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _border),
                      ),
                      child: Text(_heroImages[i]['label'] as String,
                        style: const TextStyle(color: _textSec, fontSize: 11),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 뒤로 버튼
          Positioned(
            top: MediaQuery.of(context).padding.top + 8, left: 12,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                  border: Border.all(color: _border),
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: _textPri, size: 18),
              ),
            ),
          ),

          // 페이지 인디케이터
          Positioned(
            bottom: 12, right: 16,
            child: Row(
              children: List.generate(_heroImages.length, (i) => Container(
                width: i == _heroIdx ? 18 : 6,
                height: 6,
                margin: const EdgeInsets.only(left: 4),
                decoration: BoxDecoration(
                  color: i == _heroIdx ? _accent : Colors.white.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(3),
                ),
              )),
            ),
          ),

          // 배지
          Positioned(
            top: MediaQuery.of(context).padding.top + 8, right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: store.type == 'certified' ? _orange : _accent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(store.badge,
                style: const TextStyle(
                  color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 점포명 + 평점 ──
  Widget _buildTitle(Store store) {
    return Container(
      color: _card,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(store.name,
            style: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.w800, color: _textPri),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Text('⭐', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text('${store.rating}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _accent),
              ),
              Text(' · 방문 ${store.visits}회 · 문의 ${store.inquiries}건',
                style: const TextStyle(fontSize: 12, color: _textSec),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6, runSpacing: 6,
            children: store.tags.map((t) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _border),
              ),
              child: Text(t,
                style: const TextStyle(fontSize: 11, color: _textSec)),
            )).toList(),
          ),
        ],
      ),
    );
  }

  // ── 빠른 액션 ──
  Widget _buildQuickActions(BuildContext context, Store store) {
    return Container(
      color: _bg,
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionBtn(icon: Icons.phone, label: '전화',
            color: _green,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('전화: ${store.phone}')))),
          _ActionBtn(icon: Icons.directions, label: '길찾기',
            color: _accent,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('길찾기: ${store.address}')))),
          _ActionBtn(icon: Icons.share, label: '공유',
            color: const Color(0xFF8B5CF6),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('공유 링크 복사됨')))),
          _ActionBtn(icon: Icons.bookmark_border, label: '저장',
            color: _orange,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('점포 저장 완료')))),
        ],
      ),
    );
  }

  // ── AI 소개글 ──
  Widget _buildAiIntro(Store store) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D2040), Color(0xFF0D1B2A)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _accent.withOpacity(0.4)),
                ),
                child: const Row(children: [
                  Text('🤖', style: TextStyle(fontSize: 10)),
                  SizedBox(width: 4),
                  Text('AI 생성 소개글',
                    style: TextStyle(color: _accent, fontSize: 10, fontWeight: FontWeight.w700)),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(store.desc,
            style: const TextStyle(
              fontSize: 14, color: _textSec, height: 1.6),
          ),
        ],
      ),
    );
  }

  // ── 탭바 ──
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      color: _card,
      child: TabBar(
        controller: _tabCtrl,
        labelColor: _accent,
        unselectedLabelColor: _textSec,
        indicatorColor: _accent,
        indicatorWeight: 2,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        tabs: const [
          Tab(text: '서비스'),
          Tab(text: '기본 정보'),
          Tab(text: '리뷰'),
        ],
        onTap: (_) => setState(() {}),
      ),
    );
  }

  // ── 탭 컨텐츠 ──
  Widget _buildTabContent(BuildContext context, Store store) {
    return Container(
      color: _card,
      child: [
        _buildServiceTab(store),
        _buildInfoTab(store),
        _buildReviewTab(),
      ][_tabCtrl.index],
    );
  }

  Widget _buildServiceTab(Store store) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: store.services.map((sv) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sv.name,
                      style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600, color: _textPri)),
                    const SizedBox(height: 4),
                    Text(sv.desc,
                      style: const TextStyle(fontSize: 12, color: _textSec)),
                  ],
                ),
              ),
              Text(sv.price,
                style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: _accent)),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildInfoTab(Store store) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _DarkInfoRow(icon: Icons.location_on_outlined,  label: '주소',     text: store.address),
          _DarkInfoRow(icon: Icons.access_time,           label: '영업시간',  text: store.hours),
          _DarkInfoRow(icon: Icons.phone_outlined,        label: '전화번호',  text: store.phone),
          _DarkInfoRow(icon: Icons.category_outlined,     label: '업종',     text: store.category),
        ],
      ),
    );
  }

  Widget _buildReviewTab() {
    final reviews = [
      {'name': '김*현', 'rating': 5, 'date': '2024.12.15',
       'text': '친절하고 빠른 서비스! 덕분에 차량 상태가 훨씬 좋아졌어요.'},
      {'name': '박*수', 'rating': 4, 'date': '2024.12.10',
       'text': '가격 대비 만족스러운 서비스였습니다. 다음에 또 방문할 것 같아요.'},
      {'name': '이*민', 'rating': 5, 'date': '2024.12.05',
       'text': '전문적인 진단과 꼼꼼한 정비 덕분에 안심하고 운전할 수 있게 됐어요!'},
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: reviews.map((r) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: _accent.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text((r['name'] as String)[0],
                        style: const TextStyle(color: _accent, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r['name'] as String,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textPri)),
                        Text(r['date'] as String,
                          style: const TextStyle(fontSize: 11, color: _textSec)),
                      ],
                    ),
                  ),
                  Row(
                    children: List.generate(5, (i) => Icon(
                      i < (r['rating'] as int) ? Icons.star : Icons.star_border,
                      size: 14,
                      color: const Color(0xFFFBBF24),
                    )),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(r['text'] as String,
                style: const TextStyle(fontSize: 13, color: _textSec, height: 1.5)),
            ],
          ),
        )).toList(),
      ),
    );
  }

  // ── 하단 견적 버튼 ──
  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: _card,
        border: Border(top: BorderSide(color: _border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _accent),
                foregroundColor: _accent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('쿠폰 받기', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/quote-request'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('견적 요청하기',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.label,
    required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.4)),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(label,
            style: const TextStyle(fontSize: 12, color: Color(0xFFB0BEC5))),
        ],
      ),
    );
  }
}

class _DarkInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String text;
  const _DarkInfoRow({required this.icon, required this.label, required this.text});

  static const Color _accent  = Color(0xFF4FC3F7);
  static const Color _textSec = Color(0xFFB0BEC5);
  static const Color _border  = Color(0xFF1E3A5F);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF020810),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: _accent),
          const SizedBox(width: 10),
          Text('$label  ',
            style: const TextStyle(fontSize: 12, color: _accent, fontWeight: FontWeight.w600)),
          Expanded(
            child: Text(text,
              style: const TextStyle(fontSize: 13, color: _textSec)),
          ),
        ],
      ),
    );
  }
}

// ==================== 점포 관리자 페이지 ====================
class StoreMgrScreen extends StatefulWidget {
  const StoreMgrScreen({super.key});

  @override
  State<StoreMgrScreen> createState() => _StoreMgrScreenState();
}

class _StoreMgrScreenState extends State<StoreMgrScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  // MOINCAR dark theme
  static const Color _bg      = Color(0xFF020810);
  static const Color _card    = Color(0xFF0D1B2A);
  static const Color _accent  = Color(0xFF4FC3F7);
  static const Color _orange  = Color(0xFFFF6B35);
  static const Color _green   = Color(0xFF10B981);
  static const Color _purple  = Color(0xFF8B5CF6);
  static const Color _textPri = Colors.white;
  static const Color _textSec = Color(0xFFB0BEC5);
  static const Color _border  = Color(0xFF1E3A5F);

  // 점포 정보 편집 상태
  bool _isEditing = false;
  final _nameCtrl     = TextEditingController(text: 'MOINCAR 추천 프리미엄 정비소');
  final _subCtrl      = TextEditingController(text: '바삭한 치킨의 정석, 가산동 대표 치킨집');
  final _typeCtrl     = TextEditingController(text: '자동차 정비');
  final _bizNumCtrl   = TextEditingController(text: '123-45-67890');
  final _phoneCtrl    = TextEditingController(text: '053-123-4567');
  final _addrCtrl     = TextEditingController(text: '대구시 수성구 범어동 123-4');
  final _hoursCtrl    = TextEditingController(text: '09:00 ~ 19:00');
  String _status      = '🟢 영업중';

  // 분석 날짜 필터
  String _dateFilter = '오늘';

  // 이미지 탭 인덱스
  int _imgIdx = 0;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _nameCtrl.dispose(); _subCtrl.dispose(); _typeCtrl.dispose();
    _bizNumCtrl.dispose(); _phoneCtrl.dispose();
    _addrCtrl.dispose(); _hoursCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF020810),
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _bg,
        body: Column(
          children: [
            // ─── 상단바 ───
            _buildTopBar(context),

            // ─── 탭바 ───
            Container(
              color: _card,
              child: TabBar(
                controller: _tabCtrl,
                labelColor: _accent,
                unselectedLabelColor: _textSec,
                indicatorColor: _accent,
                indicatorWeight: 2,
                tabs: const [
                  Tab(text: '🏪 점포관리'),
                  Tab(text: '📱 SNS 연동'),
                ],
                onTap: (_) => setState(() {}),
              ),
            ),

            // ─── 탭 컨텐츠 ───
            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildMgrTab(),
                  _buildSnsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 상단바 ──
  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: _card,
      padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 8, 16, 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios_new, color: _textPri, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🏪 점포관리자',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _textPri)),
                Text('사업자 인증 완료 · AI 분석 완료 ✅',
                  style: TextStyle(fontSize: 10, color: _textSec)),
              ],
            ),
          ),
          // 플랜 배지
          GestureDetector(
            onTap: () => _showPlanDialog(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A2F4A), Color(0xFF0D1B2A)],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('현재플랜',
                    style: TextStyle(fontSize: 9, color: _textSec.withOpacity(0.7))),
                  const Text('무료',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: _orange)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 점포관리 탭 ──
  Widget _buildMgrTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildPhotoSection(),
        const SizedBox(height: 16),
        _buildQuickActions(),
        const SizedBox(height: 16),
        _buildStoreInfoSection(),
        const SizedBox(height: 16),
        _buildMapSection(),
        const SizedBox(height: 16),
        _buildAnalyticsSection(),
        const SizedBox(height: 16),
        _buildMenuSection(),
        const SizedBox(height: 40),
      ],
    );
  }

  // ── ① 사진 갤러리 ──
  Widget _buildPhotoSection() {
    final photos = [
      {'label': '간판/입구',  'emoji': '🏪', 'expose': true},
      {'label': '매장 내부',  'emoji': '🔧', 'expose': false},
      {'label': '대표 차량',  'emoji': '🚗', 'expose': false},
    ];

    return _MgrSection(
      title: '📸 등록 사진 · 잠금화면 노출 관리',
      child: Column(
        children: [
          // 메인 이미지
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF1A2F4A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Center(
                  child: Text(photos[_imgIdx]['emoji'] as String,
                    style: const TextStyle(fontSize: 60)),
                ),
                Positioned(
                  bottom: 8, left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(photos[_imgIdx]['label'] as String,
                      style: const TextStyle(color: _textSec, fontSize: 11)),
                  ),
                ),
                if (photos[_imgIdx]['expose'] as bool)
                  Positioned(
                    top: 8, right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _green.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('잠금화면 노출중 ●',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // 썸네일 가로 스크롤
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...List.generate(photos.length, (i) => GestureDetector(
                  onTap: () => setState(() => _imgIdx = i),
                  child: Container(
                    width: 70, height: 70,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2F4A),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: i == _imgIdx ? _accent : _border,
                        width: i == _imgIdx ? 2 : 1,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(photos[i]['emoji'] as String,
                          style: const TextStyle(fontSize: 28)),
                        Positioned(
                          bottom: 2,
                          child: Text(photos[i]['label'] as String,
                            style: const TextStyle(fontSize: 8, color: _textSec)),
                        ),
                        if (photos[i]['expose'] as bool)
                          Positioned(
                            top: 3, right: 3,
                            child: Container(
                              width: 8, height: 8,
                              decoration: const BoxDecoration(
                                color: _green, shape: BoxShape.circle),
                            ),
                          ),
                      ],
                    ),
                  ),
                )),
                // 추가 버튼
                GestureDetector(
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('사진 추가 기능 준비중'))),
                  child: Container(
                    width: 70, height: 70,
                    decoration: BoxDecoration(
                      color: _bg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _border, style: BorderStyle.solid),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: _textSec.withOpacity(0.5), size: 24),
                        Text('추가',
                          style: TextStyle(fontSize: 10, color: _textSec.withOpacity(0.5))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // 잠금화면 노출 버튼
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('잠금화면 노출 설정 완료'))),
              icon: const Icon(Icons.push_pin, size: 14),
              label: const Text('이 사진을 잠금화면에 노출', style: TextStyle(fontSize: 13)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _orange),
                foregroundColor: _orange,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // AI 부제 박스
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _accent.withOpacity(0.4)),
                      ),
                      child: const Row(children: [
                        Text('🤖', style: TextStyle(fontSize: 10)),
                        SizedBox(width: 4),
                        Text('AI 생성 부제',
                          style: TextStyle(color: _accent, fontSize: 10, fontWeight: FontWeight.w700)),
                        SizedBox(width: 6),
                        Text('● 잠금화면 노출',
                          style: TextStyle(color: Color(0xFF10B981), fontSize: 9)),
                      ]),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('AI 부제 재생성 중...'))),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _purple.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _purple.withOpacity(0.4)),
                        ),
                        child: const Text('🔄 재생성',
                          style: TextStyle(color: _purple, fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _subCtrl,
                  style: const TextStyle(color: _textPri, fontSize: 14),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: _border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: _border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: _accent),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF0D1B2A),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 6),
                const Text('✅ 이 문구가 잠금화면 이미지 위에 노출됩니다',
                  style: TextStyle(fontSize: 11, color: _green)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── ② 빠른 액션 ──
  Widget _buildQuickActions() {
    return _MgrSection(
      title: '⚡ 빠른 액션',
      child: Row(
        children: [
          _QaBtn(icon: Icons.payment, label: '구독결제',    color: _orange,
            onTap: () => _showPlanDialog()),
          const SizedBox(width: 8),
          _QaBtn(icon: Icons.qr_code, label: 'QR코드',     color: _accent,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('QR코드 생성 기능 준비중')))),
          const SizedBox(width: 8),
          _QaBtn(icon: Icons.share,   label: '공유하기',   color: _green,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('공유 링크 복사됨')))),
          const SizedBox(width: 8),
          _QaBtn(icon: Icons.person_add, label: '관리자초대', color: _purple,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('관리자 초대 기능 준비중')))),
        ],
      ),
    );
  }

  // ── ③ 점포 정보 편집 ──
  Widget _buildStoreInfoSection() {
    return _MgrSection(
      title: '🏪 점포 정보',
      trailing: GestureDetector(
        onTap: () => setState(() => _isEditing = !_isEditing),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _isEditing ? _green.withOpacity(0.2) : _accent.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isEditing ? _green.withOpacity(0.5) : _accent.withOpacity(0.4)),
          ),
          child: Text(_isEditing ? '✅ 저장완료' : '✏️ 수정',
            style: TextStyle(
              color: _isEditing ? _green : _accent,
              fontSize: 11, fontWeight: FontWeight.w700)),
        ),
      ),
      child: Column(
        children: [
          // AI 분석 완료 배너
          Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_accent.withOpacity(0.1), _purple.withOpacity(0.1)],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _accent.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Text('🤖', style: TextStyle(fontSize: 16)),
                SizedBox(width: 8),
                Expanded(
                  child: Text('AI 분석 완료 — 점포명·부제 자동 생성됨',
                    style: TextStyle(fontSize: 12, color: _accent, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),

          _InfoField(label: '점포명',    ctrl: _nameCtrl,   enabled: _isEditing),
          _InfoField(label: '업종',      ctrl: _typeCtrl,   enabled: _isEditing),
          _InfoField(label: '사업자번호', ctrl: _bizNumCtrl,  enabled: false),

          // 영업상태 + 영업시간
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('영업상태',
                  style: TextStyle(fontSize: 11, color: _textSec, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                if (_isEditing)
                  Row(
                    children: ['🟢 영업중', '🔴 영업종료', '🟡 준비중'].map((s) =>
                      GestureDetector(
                        onTap: () => setState(() => _status = s),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _status == s ? _accent.withOpacity(0.2) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _status == s ? _accent : _border),
                          ),
                          child: Text(s,
                            style: TextStyle(
                              fontSize: 12,
                              color: _status == s ? _accent : _textSec,
                              fontWeight: _status == s ? FontWeight.w700 : FontWeight.normal,
                            )),
                        ),
                      )
                    ).toList(),
                  )
                else
                  Text(_status,
                    style: const TextStyle(fontSize: 14, color: _textPri, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                const Divider(color: Color(0xFF1E3A5F), height: 1),
                const SizedBox(height: 8),
                const Text('영업시간',
                  style: TextStyle(fontSize: 11, color: _textSec, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: _hoursCtrl,
                  enabled: _isEditing,
                  style: const TextStyle(color: _textPri, fontSize: 13),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '예: 09:00 ~ 18:00',
                    hintStyle: TextStyle(color: _textSec.withOpacity(0.5)),
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _orange.withOpacity(0.3)),
                  ),
                  child: const Text(
                    '영업시간 설정으로 매일 수동 변경이 필요 없습니다!',
                    style: TextStyle(fontSize: 10, color: _orange, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          _InfoField(label: '전화번호', ctrl: _phoneCtrl, enabled: _isEditing),
          _InfoField(label: '주소',    ctrl: _addrCtrl,  enabled: _isEditing),

          if (_isEditing)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() => _isEditing = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ 점포 정보가 저장되었습니다!')));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('저장하기',
                  style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }

  // ── ④ 지도 섹션 ──
  Widget _buildMapSection() {
    return _MgrSection(
      title: '📍 점포 위치',
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: _orange),
              const SizedBox(width: 6),
              Expanded(
                child: Text(_addrCtrl.text,
                  style: const TextStyle(fontSize: 12, color: _textSec)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF1A2F4A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _border),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.map_outlined, size: 40, color: _border),
                const SizedBox(height: 8),
                Text(
                  '점포 정보에서 주소를 입력하고\n저장하면 지도가 표시됩니다',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: _textSec.withOpacity(0.7)),
                ),
                const SizedBox(height: 8),
                Text(
                  '※ Google Maps / 카카오 Geocoding API 연동 예정',
                  style: TextStyle(fontSize: 10, color: _textSec.withOpacity(0.4)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── ⑤ 점포 분석 ──
  Widget _buildAnalyticsSection() {
    final kpis = [
      {'icon': '📱', 'num': '1,247', 'label': '잠금화면 노출', 'trend': '▲ 12%', 'up': true,  'color': _orange},
      {'icon': '👆', 'num': '93',    'label': '점포 클릭',     'trend': '▲ 8%',  'up': true,  'color': _accent},
      {'icon': '📍', 'num': '14',    'label': '방문 확인',     'trend': '▼ 2%',  'up': false, 'color': _green},
    ];

    final funnelSteps = [
      {'label': '잠금화면 노출', 'num': '1,247', 'rate': '100%', 'w': 1.0, 'color': _orange},
      {'label': '점포 클릭',    'num': '93',    'rate': '7.5%', 'w': 0.74,'color': const Color(0xFFFB923C)},
      {'label': '실제 방문',    'num': '14',    'rate': '1.1%', 'w': 0.5, 'color': _green},
    ];

    return _MgrSection(
      title: '📊 점포 분석',
      child: Column(
        children: [
          // 날짜 필터
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['오늘', '7일', '30일', '전체'].map((d) => GestureDetector(
                onTap: () => setState(() => _dateFilter = d),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _dateFilter == d ? _accent.withOpacity(0.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _dateFilter == d ? _accent : _border),
                  ),
                  child: Text(d,
                    style: TextStyle(
                      fontSize: 12,
                      color: _dateFilter == d ? _accent : _textSec,
                      fontWeight: _dateFilter == d ? FontWeight.w700 : FontWeight.normal,
                    )),
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 14),

          // KPI 카드 3개
          Row(
            children: kpis.map((k) => Expanded(
              child: Container(
                margin: EdgeInsets.only(right: k == kpis.last ? 0 : 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _bg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _border),
                ),
                child: Column(
                  children: [
                    Text(k['icon'] as String, style: const TextStyle(fontSize: 20)),
                    const SizedBox(height: 4),
                    Text(k['num'] as String,
                      style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w900,
                        color: k['color'] as Color)),
                    const SizedBox(height: 2),
                    Text(k['label'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 10, color: _textSec)),
                    const SizedBox(height: 4),
                    Text(k['trend'] as String,
                      style: TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w700,
                        color: (k['up'] as bool) ? _green : const Color(0xFFFF4D4F))),
                  ],
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 14),

          // 퍼널 차트
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('📐 방문 전환 퍼널',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _textPri)),
                const SizedBox(height: 12),
                ...funnelSteps.map((f) => Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(f['label'] as String,
                                    style: const TextStyle(fontSize: 12, color: _textSec)),
                                  const Spacer(),
                                  Text(f['rate'] as String,
                                    style: TextStyle(
                                      fontSize: 11, fontWeight: FontWeight.w700,
                                      color: f['color'] as Color)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              LayoutBuilder(
                                builder: (ctx, bc) => Stack(
                                  children: [
                                    Container(
                                      height: 20,
                                      width: bc.maxWidth,
                                      decoration: BoxDecoration(
                                        color: _border.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    Container(
                                      height: 20,
                                      width: bc.maxWidth * (f['w'] as double),
                                      decoration: BoxDecoration(
                                        color: (f['color'] as Color).withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Center(
                                        child: Text(f['num'] as String,
                                          style: const TextStyle(
                                            fontSize: 11, fontWeight: FontWeight.w700,
                                            color: Colors.white)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (f != funnelSteps.last)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Center(child: Text('▼',
                          style: TextStyle(fontSize: 14, color: _textSec))),
                      ),
                  ],
                )),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // 쿠폰 현황
          _AnalysisCard(
            icon: '🎟️', title: '쿠폰 현황',
            btnLabel: '+ 쿠폰 발급',
            onBtnTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('쿠폰 발급 기능 준비중'))),
            child: Column(
              children: [
                Row(
                  children: [
                    _AcItem(num: '38', label: '발급', color: _orange),
                    const SizedBox(width: 8),
                    _AcItem(num: '21', label: '사용', color: _accent),
                  ],
                ),
                const SizedBox(height: 10),
                _ProgressBar(label: '사용률', value: 0.55, valueText: '55%', color: _orange),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── ⑥ 메뉴/상품 관리 ──
  Widget _buildMenuSection() {
    final menus = [
      {'name': '엔진오일 교환',      'price': '89,000원', 'active': true},
      {'name': '브레이크 점검 패키지','price': '59,000원', 'active': true},
      {'name': '하체 소음 진단',     'price': '35,000원', 'active': false},
    ];

    return _MgrSection(
      title: '🍽️ 서비스 · 상품 관리',
      trailing: GestureDetector(
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('서비스 추가 기능 준비중'))),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _accent.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _accent.withOpacity(0.4)),
          ),
          child: const Text('+ 추가',
            style: TextStyle(color: _accent, fontSize: 11, fontWeight: FontWeight.w700)),
        ),
      ),
      child: Column(
        children: menus.map((m) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _border),
          ),
          child: Row(
            children: [
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(
                  color: (m['active'] as bool) ? _green : _border,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(m['name'] as String,
                  style: const TextStyle(fontSize: 13, color: _textPri, fontWeight: FontWeight.w600)),
              ),
              Text(m['price'] as String,
                style: const TextStyle(fontSize: 13, color: _accent, fontWeight: FontWeight.w700)),
              const SizedBox(width: 10),
              Icon(Icons.edit_outlined, size: 16, color: _textSec.withOpacity(0.5)),
            ],
          ),
        )).toList(),
      ),
    );
  }

  // ── SNS 탭 ──
  Widget _buildSnsTab() {
    final platforms = [
      {'icon': Icons.facebook, 'name': '인스타그램', 'color': const Color(0xFFE1306C), 'connected': false},
      {'icon': Icons.facebook, 'name': '페이스북',   'color': const Color(0xFF1877F2), 'connected': true},
      {'icon': Icons.chat_bubble, 'name': '카카오채널', 'color': const Color(0xFFFEE500), 'connected': false},
      {'icon': Icons.youtube_searched_for, 'name': '유튜브',  'color': const Color(0xFFFF0000), 'connected': false},
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _MgrSection(
          title: '📱 SNS 채널 연동',
          child: Column(
            children: platforms.map((p) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: (p['color'] as Color).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(p['icon'] as IconData,
                      color: p['color'] as Color, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(p['name'] as String,
                      style: const TextStyle(fontSize: 13, color: _textPri, fontWeight: FontWeight.w600)),
                  ),
                  GestureDetector(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${p['name']} 연동 기능 준비중'))),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: (p['connected'] as bool)
                          ? _green.withOpacity(0.2)
                          : _accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: (p['connected'] as bool)
                            ? _green.withOpacity(0.5)
                            : _accent.withOpacity(0.4)),
                      ),
                      child: Text(
                        (p['connected'] as bool) ? '연동됨 ✓' : '연동하기',
                        style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w700,
                          color: (p['connected'] as bool) ? _green : _accent),
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  // ── 구독 플랜 다이얼로그 ──
  void _showPlanDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: _border, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            const Text('💳 구독 플랜 선택',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _textPri)),
            const SizedBox(height: 16),
            ...[
              {'name': '무료', 'price': '0원/월',     'desc': '기본 점포 노출, 사진 3장', 'color': _textSec, 'current': true},
              {'name': '베이직','price': '9,900원/월', 'desc': 'KPI 분석 + 쿠폰 발급',    'color': _accent,   'current': false},
              {'name': '프리미엄','price': '29,900원/월','desc': 'AI 전단지 + 무제한 분석', 'color': _orange,  'current': false},
            ].map((plan) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (plan['current'] as bool) ? _accent : _border,
                  width: (plan['current'] as bool) ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(plan['name'] as String,
                          style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w800,
                            color: plan['color'] as Color)),
                        Text(plan['desc'] as String,
                          style: const TextStyle(fontSize: 12, color: _textSec)),
                      ],
                    ),
                  ),
                  Text(plan['price'] as String,
                    style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700,
                      color: plan['color'] as Color)),
                  if (plan['current'] as bool) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _accent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('현재',
                        style: TextStyle(color: _accent, fontSize: 10, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ],
              ),
            )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ==================== 점포관리 Helper Widgets ====================

class _MgrSection extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  static const Color _card   = Color(0xFF0D1B2A);
  static const Color _accent = Color(0xFF4FC3F7);
  static const Color _textPri = Colors.white;
  static const Color _border = Color(0xFF1E3A5F);

  const _MgrSection({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title,
                style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w800, color: _textPri)),
              if (trailing != null) ...[
                const Spacer(),
                trailing!,
              ],
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFF1E3A5F), height: 1),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _QaBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QaBtn({required this.icon, required this.label,
    required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(label,
                style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final bool enabled;

  static const Color _bg     = Color(0xFF020810);
  static const Color _accent = Color(0xFF4FC3F7);
  static const Color _textPri = Colors.white;
  static const Color _textSec = Color(0xFFB0BEC5);
  static const Color _border = Color(0xFF1E3A5F);

  const _InfoField({required this.label, required this.ctrl, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: enabled ? _accent.withOpacity(0.5) : _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
            style: TextStyle(
              fontSize: 10, color: enabled ? _accent : _textSec,
              fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          TextField(
            controller: ctrl,
            enabled: enabled,
            style: const TextStyle(color: _textPri, fontSize: 13),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalysisCard extends StatelessWidget {
  final String icon;
  final String title;
  final String btnLabel;
  final VoidCallback onBtnTap;
  final Widget child;

  static const Color _bg     = Color(0xFF020810);
  static const Color _accent = Color(0xFF4FC3F7);
  static const Color _textPri = Colors.white;
  static const Color _textSec = Color(0xFFB0BEC5);
  static const Color _border = Color(0xFF1E3A5F);

  const _AnalysisCard({
    required this.icon, required this.title,
    required this.btnLabel, required this.onBtnTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(title,
                style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: _textPri)),
              const Spacer(),
              GestureDetector(
                onTap: onBtnTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _accent.withOpacity(0.4)),
                  ),
                  child: Text(btnLabel,
                    style: const TextStyle(
                      color: _accent, fontSize: 10, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _AcItem extends StatelessWidget {
  final String num;
  final String label;
  final Color color;
  const _AcItem({required this.num, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(num, style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w900, color: color)),
            Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFFB0BEC5))),
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final String label;
  final double value;
  final String valueText;
  final Color color;
  const _ProgressBar({required this.label, required this.value,
    required this.valueText, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(label,
              style: const TextStyle(fontSize: 11, color: Color(0xFFB0BEC5))),
            const Spacer(),
            Text(valueText,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
        const SizedBox(height: 4),
        LayoutBuilder(
          builder: (_, bc) => Stack(
            children: [
              Container(
                height: 6, width: bc.maxWidth,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A5F),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Container(
                height: 6,
                width: bc.maxWidth * value,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


