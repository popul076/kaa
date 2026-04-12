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

  // ── MOINCAR 다크 컬러 ──
  static const _bg      = Color(0xFF020810);
  static const _card    = Color(0xFF0D1B2A);
  static const _navy    = Color(0xFF0A1628);
  static const _accent  = Color(0xFF4FC3F7);
  static const _orange  = Color(0xFFFF6B35);
  static const _green   = Color(0xFF10B981);
  static const _border  = Color(0xFF1E3A5F);
  static const _textPri = Colors.white;
  static const _textSec = Color(0xFFB0BEC5);

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
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: _bg,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _bg,
        body: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            // ─── 히어로 배너 ───
            SliverToBoxAdapter(child: _buildHero(context, store)),
            // ─── 빠른 액션 3버튼 ───
            SliverToBoxAdapter(child: _buildQuickActions(context, store)),
            // ─── 점포 기본 정보 ───
            SliverToBoxAdapter(child: _buildBasicInfo(store)),
            // ─── 탭 ───
            SliverToBoxAdapter(child: _buildTabBar()),
            SliverToBoxAdapter(child: _buildTabContent(context, store)),
            // 하단 고정 버튼 여백
            SliverToBoxAdapter(child: SizedBox(height: bottomPad + 90)),
          ],
        ),
        // ─── 하단 고정: 전화걸기 + 1:1 채팅 (항상 표시) ───
        bottomNavigationBar: _buildBottomBar(context, store),
      ),
    );
  }

  // ── 히어로 배너 ──
  Widget _buildHero(BuildContext context, Store store) {
    final topPad = MediaQuery.of(context).padding.top;
    return SizedBox(
      height: 220 + topPad,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 배경 이미지
          CachedNetworkImage(
            imageUrl: store.image,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => Container(
              color: _navy,
              child: const Center(child: Text('🏪', style: TextStyle(fontSize: 70))),
            ),
          ),
          // 그라디언트
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x88000000), Color(0xDD000000)],
                stops: [0.3, 1.0],
              ),
            ),
          ),
          // 상단 헤더 행
          Positioned(
            top: topPad + 8, left: 12, right: 12,
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    shape: BoxShape.circle,
                    border: Border.all(color: _border),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, color: _textPri, size: 16),
                ),
              ),
              const Expanded(
                child: Center(
                  child: Text('점포 상세',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _border),
                  ),
                  child: const Text('관리', style: TextStyle(fontSize: 13, color: _textPri, fontWeight: FontWeight.w600)),
                ),
              ),
            ]),
          ),
          // 배너 하단 텍스트
          Positioned(
            bottom: 18, left: 18, right: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _accent.withOpacity(0.5)),
                  ),
                  child: const Text('점포 공개 페이지',
                    style: TextStyle(fontSize: 10, color: _accent, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 6),
                Text(store.name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, height: 1.2)),
                const SizedBox(height: 5),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: _orange.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(store.badge,
                      style: const TextStyle(fontSize: 10, color: _orange, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.place_outlined, color: _textSec, size: 13),
                  const SizedBox(width: 3),
                  Text(store.distance, style: const TextStyle(fontSize: 12, color: _textSec)),
                  const SizedBox(width: 10),
                  Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 13),
                  const SizedBox(width: 3),
                  Text(store.rating.toString(),
                    style: const TextStyle(fontSize: 12, color: _textSec)),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 빠른 액션 3버튼 (전화하기 / 길찾기 / 네비게이션) ──
  Widget _buildQuickActions(BuildContext context, Store store) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        children: [
          _quickBtn(context, Icons.phone_rounded, '전화하기', false,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(backgroundColor: _green, content: Text('☎ ${store.phone} 연결 중...')))),
          const SizedBox(width: 8),
          _quickBtn(context, Icons.directions_rounded, '길찾기', false,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(backgroundColor: _accent, content: Text('🗺 ${store.address} 경로 안내')))),
          const SizedBox(width: 8),
          _quickBtn(context, Icons.navigation_rounded, '네비게이션', true,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(backgroundColor: Color(0xFF1E3A5F), content: Text('🧭 네비게이션 실행 중...')))),
        ],
      ),
    );
  }

  Widget _quickBtn(BuildContext context, IconData icon, String label, bool filled, {required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: filled ? const Color(0xFF0D2040) : _card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: filled ? _accent.withOpacity(0.5) : _border,
              width: filled ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15,
                color: filled ? _accent : _textSec),
              const SizedBox(width: 5),
              Text(label,
                style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700,
                  color: filled ? _accent : _textPri)),
            ],
          ),
        ),
      ),
    );
  }

  // ── 점포 기본 정보 ──
  Widget _buildBasicInfo(Store store) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('점포 기본 정보',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _textPri)),
          const SizedBox(height: 2),
          const Text('주소 · 영업시간 · 소개',
            style: TextStyle(fontSize: 11, color: _textSec)),
          const SizedBox(height: 12),
          // 2x2 그리드
          Row(children: [
            _infoCell('카테고리', store.tags.join(' · ')),
            const SizedBox(width: 8),
            _infoCell('영업시간', store.hours),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            _infoCell('전화번호', store.phone),
            const SizedBox(width: 8),
            _infoCell('방문/문의', '${store.visits} / ${store.inquiries}'),
          ]),
          const SizedBox(height: 12),
          // 소개글
          Text(store.desc,
            style: const TextStyle(fontSize: 13, color: _textSec, height: 1.6)),
        ],
      ),
    );
  }

  Widget _infoCell(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _navy,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: _border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
              style: const TextStyle(fontSize: 10, color: _textSec)),
            const SizedBox(height: 4),
            Text(value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _textPri),
              maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  // ── 탭 바 ──
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      height: 42,
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: TabBar(
        controller: _tabCtrl,
        indicator: BoxDecoration(
          color: _accent.withOpacity(0.18),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _accent.withOpacity(0.5)),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        labelColor: _accent,
        unselectedLabelColor: _textSec,
        tabs: const [
          Tab(text: '대표 서비스'),
          Tab(text: '정보'),
          Tab(text: '리뷰'),
        ],
      ),
    );
  }

  // ── 탭 콘텐츠 ──
  Widget _buildTabContent(BuildContext context, Store store) {
    return SizedBox(
      height: _tabHeight(store),
      child: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildServiceTab(context, store),
          _buildInfoTab(store),
          _buildReviewTab(),
        ],
      ),
    );
  }

  double _tabHeight(Store store) {
    // 서비스 탭 높이 (항목당 약 130px + 쿠폰 섹션 120px)
    final serviceH = store.services.length * 130.0 + 140.0;
    return serviceH > 500 ? serviceH : 500;
  }

  // ── 대표 서비스 탭 ──
  Widget _buildServiceTab(BuildContext context, Store store) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 섹션 타이틀
            const Text('대표 상품 · 서비스',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _textPri)),
            const SizedBox(height: 2),
            const Text('업종별 핵심 항목만 맞춤 구성',
              style: TextStyle(fontSize: 11, color: _textSec)),
            const SizedBox(height: 12),
            // 서비스 카드들
            ...store.services.map((sv) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(sv.name,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textPri)),
                            const SizedBox(height: 4),
                            Text(sv.desc,
                              style: const TextStyle(fontSize: 12, color: _textSec)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(sv.price,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: _accent)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(backgroundColor: _accent.withOpacity(0.9),
                          content: Text('${sv.name} 진행 요청이 접수되었습니다.',
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700)))),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D2040),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                        side: BorderSide(color: _accent.withOpacity(0.4)),
                      ),
                      child: const Text('이 항목 진행하기',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            )).toList(),
            // 쿠폰 섹션
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('쿠폰 받기',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _textPri)),
                  const SizedBox(height: 2),
                  const Text('점포페이지 안에서 바로 저장 후 쿠폰함으로 이동',
                    style: TextStyle(fontSize: 11, color: _textSec)),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: _navy,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: _border, width: 1),
                    ),
                    child: const Center(
                      child: Text('현재 발급된 쿠폰이 없습니다.',
                        style: TextStyle(fontSize: 13, color: _textSec)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 정보 탭 ──
  Widget _buildInfoTab(Store store) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          _DarkInfoRow(icon: Icons.location_on_outlined, label: '주소',    text: store.address),
          _DarkInfoRow(icon: Icons.access_time,          label: '영업시간', text: store.hours),
          _DarkInfoRow(icon: Icons.phone_outlined,       label: '전화번호', text: store.phone),
          _DarkInfoRow(icon: Icons.category_outlined,    label: '업종',    text: store.category),
          _DarkInfoRow(icon: Icons.people_outline,       label: '방문',    text: '${store.visits}회'),
          _DarkInfoRow(icon: Icons.question_answer_outlined, label: '문의', text: '${store.inquiries}건'),
        ]),
      ),
    );
  }

  // ── 리뷰 탭 ──
  Widget _buildReviewTab() {
    final reviews = [
      {'name': '김*현', 'rating': 5, 'date': '2025.03.15', 'text': '친절하고 빠른 서비스! 덕분에 차량 상태가 훨씬 좋아졌어요.'},
      {'name': '박*수', 'rating': 4, 'date': '2025.03.10', 'text': '가격 대비 만족스러운 서비스였습니다. 다음에 또 방문할 것 같아요.'},
      {'name': '이*민', 'rating': 5, 'date': '2025.02.28', 'text': '전문적인 진단과 꼼꼼한 정비 덕분에 안심하고 운전할 수 있게 됐어요!'},
    ];
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: reviews.map((r) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _border),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.2), shape: BoxShape.circle),
                child: Center(child: Text((r['name'] as String)[0],
                  style: const TextStyle(color: _accent, fontWeight: FontWeight.w700))),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(r['name'] as String,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textPri)),
                Text(r['date'] as String,
                  style: const TextStyle(fontSize: 11, color: _textSec)),
              ])),
              Row(children: List.generate(5, (i) => Icon(
                i < (r['rating'] as int) ? Icons.star : Icons.star_border,
                size: 14, color: const Color(0xFFFBBF24),
              ))),
            ]),
            const SizedBox(height: 10),
            Text(r['text'] as String,
              style: const TextStyle(fontSize: 13, color: _textSec, height: 1.5)),
          ]),
        )).toList()),
      ),
    );
  }

  // ── 하단 고정 버튼: 전화걸기 + 1:1 채팅 (항상 표시) ──
  Widget _buildBottomBar(BuildContext context, Store store) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPad),
      decoration: BoxDecoration(
        color: _card,
        border: Border(top: BorderSide(color: _border, width: 1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, -4)),
        ],
      ),
      child: Row(children: [
        // 전화걸기 버튼
        Expanded(
          child: GestureDetector(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: _green,
                content: Row(children: [
                  const Icon(Icons.phone, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text('${store.phone} 연결 중...', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ]),
              )),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: _green.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _green.withOpacity(0.5), width: 1.5),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.phone_rounded, color: _green, size: 18),
                const SizedBox(width: 6),
                Text('전화걸기',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _green)),
              ]),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // 1:1 채팅 버튼
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/chat',
              arguments: {'storeName': store.name, 'storeId': store.id}),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: _accent.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3)),
                ],
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 18),
                SizedBox(width: 6),
                Text('1:1 문의 채팅',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
              ]),
            ),
          ),
        ),
      ]),
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

class _StoreMgrScreenState extends State<StoreMgrScreen> {
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
  final _subCtrl      = TextEditingController(text: '전문 기술과 정성으로 고객 차량을 책임집니다');
  final _typeCtrl     = TextEditingController(text: '자동차 정비');
  final _bizNumCtrl   = TextEditingController(text: '123-45-67890');
  final _phoneCtrl    = TextEditingController(text: '053-123-4567');
  final _addrCtrl     = TextEditingController(text: '대구시 수성구 범어동 123-4');
  String _status      = '🟢 영업중';
  // 영업시간: 요일별
  final Map<String, Map<String, String>> _hours = {
    '월': {'open': '09:00', 'close': '19:00', 'closed': 'false'},
    '화': {'open': '09:00', 'close': '19:00', 'closed': 'false'},
    '수': {'open': '09:00', 'close': '19:00', 'closed': 'false'},
    '목': {'open': '09:00', 'close': '19:00', 'closed': 'false'},
    '금': {'open': '09:00', 'close': '19:00', 'closed': 'false'},
    '토': {'open': '10:00', 'close': '17:00', 'closed': 'false'},
    '일': {'open': '00:00', 'close': '00:00', 'closed': 'true'},
  };

  // 분석 날짜/기간 필터
  String _dateFilter = '일';
  int _graphAnimFrame = 0;

  // 이미지 탭 인덱스
  int _imgIdx = 0;

  // AI 소개문 펼치기/접기
  bool _introExpanded = false;
  final String _aiIntroText =
      'MOINCAR 추천 프리미엄 정비소는 대구 수성구에 위치한 전문 자동차 정비 업체입니다. '
      '10년 이상의 풍부한 경험을 보유한 전문 기술진이 고객님의 차량을 꼼꼼하게 점검하고 '
      '수리합니다. 엔진오일 교환, 브레이크 정비, 타이어 교체 등 모든 서비스를 합리적인 '
      '가격에 제공하며, MOINCAR 공식 인증 점포로서 최고의 서비스 품질을 보장합니다. '
      '예약 없이 방문 가능하며 당일 처리를 원칙으로 합니다. '
      '고객 만족을 최우선으로 하는 MOINCAR 추천 정비소에서 내 차의 건강을 지켜보세요. '
      '친절한 상담과 투명한 견적으로 신뢰를 드리겠습니다.';

  // 서비스 상품 목록 (업종별 기본값)
  List<Map<String, dynamic>> _services = [];
  String _currentCategory = '자동차 정비';

  // 업종별 기본 서비스 상품
  static const Map<String, List<Map<String, dynamic>>> _defaultServices = {
    '자동차 정비': [
      {'name': '엔진오일 교환',       'price': '89,000', 'unit': '원', 'active': true,  'type': '공임비'},
      {'name': '브레이크 패드 교환',   'price': '150,000','unit': '원', 'active': true,  'type': '부품비'},
      {'name': '타이어 교체 (1개)',    'price': '20,000', 'unit': '원', 'active': true,  'type': '공임비'},
      {'name': '에어필터 교환',        'price': '25,000', 'unit': '원', 'active': true,  'type': '부품비'},
      {'name': '냉각수 교환',          'price': '45,000', 'unit': '원', 'active': false, 'type': '서비스비용'},
      {'name': '종합 점검',            'price': '35,000', 'unit': '원', 'active': false, 'type': '서비스비용'},
    ],
    '세차/디테일링': [
      {'name': '기본 세차',            'price': '15,000', 'unit': '원', 'active': true,  'type': '서비스비용'},
      {'name': '실내 청소',            'price': '30,000', 'unit': '원', 'active': true,  'type': '서비스비용'},
      {'name': '유리막 코팅',          'price': '150,000','unit': '원', 'active': true,  'type': '서비스비용'},
      {'name': '광택 (소형)',           'price': '80,000', 'unit': '원', 'active': false, 'type': '서비스비용'},
      {'name': '흠집 제거',            'price': '50,000', 'unit': '원', 'active': false, 'type': '부품비'},
    ],
    '타이어': [
      {'name': '타이어 교체 (1개)',    'price': '20,000', 'unit': '원', 'active': true,  'type': '공임비'},
      {'name': '휠 얼라인먼트',        'price': '40,000', 'unit': '원', 'active': true,  'type': '서비스비용'},
      {'name': '타이어 밸런스',        'price': '15,000', 'unit': '원', 'active': true,  'type': '서비스비용'},
      {'name': '타이어 수리 (펑크)',   'price': '10,000', 'unit': '원', 'active': true,  'type': '서비스비용'},
      {'name': '질소 충전',            'price': '5,000',  'unit': '원', 'active': false, 'type': '서비스비용'},
    ],
    '중고차': [
      {'name': '차량 진단/검사',       'price': '50,000', 'unit': '원', 'active': true,  'type': '서비스비용'},
      {'name': '매매 수수료',          'price': '100,000','unit': '원', 'active': true,  'type': '서비스비용'},
      {'name': '명의 이전 대행',       'price': '80,000', 'unit': '원', 'active': true,  'type': '서비스비용'},
      {'name': '차량 탁송',            'price': '150,000','unit': '원', 'active': false, 'type': '서비스비용'},
    ],
    '기타': [
      {'name': '기본 서비스',          'price': '30,000', 'unit': '원', 'active': true,  'type': '서비스비용'},
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadDefaultServices(_currentCategory);
  }

  void _loadDefaultServices(String category) {
    final defaults = _defaultServices[category] ?? _defaultServices['기타']!;
    _services = defaults.map((s) => Map<String, dynamic>.from(s)).toList();
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _subCtrl.dispose(); _typeCtrl.dispose();
    _bizNumCtrl.dispose(); _phoneCtrl.dispose();
    _addrCtrl.dispose();
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

            // ─── 탭 컨텐츠 (SNS 탭 제거) ───
            Expanded(
              child: _buildMgrTab(),
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
        _buildAiIntroSection(),
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
                  maxLines: 4,
                  minLines: 3,
                  style: const TextStyle(color: _textPri, fontSize: 14, height: 1.6),
                  decoration: InputDecoration(
                    hintText: '잠금화면에 노출할 소개 문구를 2줄 이상 입력하세요\n(예: 대구 수성구 No.1 정비소\n엔진오일·브레이크·타이어 전문)',
                    hintStyle: const TextStyle(color: _textSec, fontSize: 12, height: 1.6),
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: _green, size: 13),
                    const SizedBox(width: 4),
                    const Expanded(child: Text('이 문구가 잠금화면 이미지 위에 전체 노출됩니다 (최대 4줄)',
                      style: TextStyle(fontSize: 11, color: _green))),
                    Builder(builder: (ctx) => GestureDetector(
                      onTap: () {
                        final samples = [
                          '🔧 대구 수성구 No.1 프리미엄 정비소\n엔진오일·브레이크·타이어 전문\n10년 이상 경력 전문 기술진 상주\n당일 처리 · 합리적인 가격',
                          '🚗 MOINCAR 추천 공식 정비소\n전국 최저가 보장 · 예약 우선 처리\n친환경 정비 시스템 도입\n방문 시 쿠폰 즉시 사용 가능',
                          '✅ 지역 1등 자동차 정비 전문점\n수입차 · 국산차 모두 가능\n주행거리 무관 정밀 점검 무료\n재방문 고객 10% 추가 할인',
                        ];
                        final idx = (DateTime.now().millisecond % 3);
                        setState(() => _subCtrl.text = samples[idx]);
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(content: Text('AI 소개문 재생성 완료 ✨'), duration: Duration(seconds: 2)));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _purple.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _purple.withOpacity(0.4)),
                        ),
                        child: const Row(children: [
                          Text('🔄', style: TextStyle(fontSize: 11)),
                          SizedBox(width: 3),
                          Text('AI 재생성', style: TextStyle(color: _purple, fontSize: 11, fontWeight: FontWeight.w600)),
                        ]),
                      ),
                    )),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── ① AI 소개문 전체 표시 ──
  Widget _buildAiIntroSection() {
    return _MgrSection(
      title: '🤖 AI 생성 소개글',
      trailing: GestureDetector(
        onTap: () => setState(() => _introExpanded = !_introExpanded),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _accent.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _accent.withOpacity(0.4)),
          ),
          child: Text(_introExpanded ? '접기 ▲' : '전체보기 ▼',
            style: const TextStyle(color: _accent, fontSize: 11, fontWeight: FontWeight.w700)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_accent.withOpacity(0.08), _purple.withOpacity(0.08)],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _accent.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedCrossFade(
                  firstChild: Text(
                    _aiIntroText,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: _textSec, height: 1.7),
                  ),
                  secondChild: Text(
                    _aiIntroText,
                    style: const TextStyle(fontSize: 13, color: _textSec, height: 1.7),
                  ),
                  crossFadeState: _introExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 250),
                ),
                if (!_introExpanded) ...
                  [
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => setState(() => _introExpanded = true),
                      child: const Text('더 보기...',
                        style: TextStyle(color: _accent, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          // 수정 버튼
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showEditIntroDialog(),
              icon: const Icon(Icons.edit_note, size: 16, color: _accent),
              label: const Text('AI 소개글 수정', style: TextStyle(color: _accent, fontSize: 13)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: _accent.withOpacity(0.4)),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditIntroDialog() {
    final ctrl = TextEditingController(text: _aiIntroText);
    final aiSamples = [
      'MOINCAR 추천 프리미엄 정비소는 대구 수성구에 위치한 전문 자동차 정비 업체입니다. 10년 이상의 풍부한 경험을 보유한 전문 기술진이 고객님의 차량을 꼼꼼하게 점검하고 수리합니다. 엔진오일 교환, 브레이크 정비, 타이어 교체 등 모든 서비스를 합리적인 가격으로 제공합니다.',
      '🔧 대구 수성구 No.1 프리미엄 정비소\n엔진오일·브레이크·타이어 전문\n10년 이상 경력 전문 기술진 상주\n당일 처리 · 합리적인 가격으로 고객 만족 최우선',
      '🚗 MOINCAR 공식 추천 정비소\n전국 최저가 보장 · 예약 우선 처리\n친환경 정비 시스템 도입으로 안전하고 빠른 서비스\n방문 시 쿠폰 즉시 사용 가능합니다',
      '✅ 지역 1등 자동차 정비 전문점\n수입차·국산차 모두 완벽 처리\n주행거리 무관 정밀 점검 무료 제공\n재방문 고객 10% 추가 할인 혜택',
    ];
    int sampleIdx = 0;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          backgroundColor: _card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('AI 소개글 수정',
              style: TextStyle(color: _textPri, fontSize: 16, fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AI 재생성 버튼
              GestureDetector(
                onTap: () {
                  sampleIdx = (sampleIdx + 1) % aiSamples.length;
                  setDlg(() => ctrl.text = aiSamples[sampleIdx]);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✨ AI 소개글 재생성 완료!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_purple.withOpacity(0.25), _accent.withOpacity(0.15)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _purple.withOpacity(0.5)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🔄', style: TextStyle(fontSize: 14)),
                      SizedBox(width: 6),
                      Text('AI 재생성',
                          style: TextStyle(
                              color: _purple,
                              fontSize: 13,
                              fontWeight: FontWeight.w700)),
                      SizedBox(width: 4),
                      Text('(탭할 때마다 새 문구)',
                          style: TextStyle(color: _textSec, fontSize: 10)),
                    ],
                  ),
                ),
              ),
              // 텍스트 편집 필드
              TextField(
                controller: ctrl,
                maxLines: 8,
                style: const TextStyle(color: _textPri, fontSize: 13),
                decoration: InputDecoration(
                  hintText: '점포 소개글을 직접 입력하거나\nAI 재생성 버튼을 눌러보세요',
                  hintStyle: TextStyle(color: _textSec.withOpacity(0.5), fontSize: 12),
                  filled: true,
                  fillColor: _bg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: _border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: _border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: _accent),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('취소', style: TextStyle(color: _textSec)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {});
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('소개글이 저장되었습니다 ✅')));
              },
              style: ElevatedButton.styleFrom(backgroundColor: _accent),
              child: const Text('저장',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
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

          // 영업상태 + 영업시간 → 다이얼로그 방식
          GestureDetector(
            onTap: _isEditing ? () => _showStatusDialog() : null,
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _isEditing ? _accent.withOpacity(0.5) : _border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('영업상태',
                          style: TextStyle(fontSize: 10, color: _isEditing ? _accent : _textSec,
                            fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(_status,
                          style: const TextStyle(fontSize: 14, color: _textPri, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  if (_isEditing)
                    Icon(Icons.arrow_forward_ios, color: _accent, size: 14),
                ],
              ),
            ),
          ),

          // 영업시간 키 → 다이얼로그
          GestureDetector(
            onTap: _isEditing ? () => _showHoursDialog() : null,
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _isEditing ? _accent.withOpacity(0.5) : _border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('영업시간',
                          style: TextStyle(fontSize: 10, color: _isEditing ? _accent : _textSec,
                            fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        ...(_hours.entries.map((e) {
                          final closed = e.value['closed'] == 'true';
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 24,
                                  child: Text(e.key,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: closed ? _textSec.withOpacity(0.4) : _textSec,
                                      fontWeight: FontWeight.w600,
                                    )),
                                ),
                                Text(
                                  closed ? '휴무' : '${e.value['open']} ~ ${e.value['close']}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: closed ? _textSec.withOpacity(0.4) : _textPri,
                                  )),
                              ],
                            ),
                          );
                        })).toList(),
                      ],
                    ),
                  ),
                  if (_isEditing)
                    Icon(Icons.access_time, color: _accent, size: 16),
                ],
              ),
            ),
          ),

          _InfoField(label: '전화번호', ctrl: _phoneCtrl, enabled: _isEditing),

          // 주소 → 주소검색 다이얼로그
          GestureDetector(
            onTap: _isEditing ? () => _showAddressSearchDialog() : null,
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _isEditing ? _accent.withOpacity(0.5) : _border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('주소',
                          style: TextStyle(fontSize: 10, color: _isEditing ? _accent : _textSec,
                            fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(_addrCtrl.text,
                          style: const TextStyle(fontSize: 13, color: _textPri)),
                      ],
                    ),
                  ),
                  if (_isEditing)
                    Icon(Icons.search, color: _accent, size: 16),
                ],
              ),
            ),
          ),

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
    // 기간별 KPI 데이터
    final kpiData = {
      '일': [
        {'icon': '📱', 'num': '127',   'label': '잠금화면 노출', 'trend': '▲ 5%',  'up': true,  'color': _orange},
        {'icon': '👆', 'num': '11',    'label': '점포 클릭',     'trend': '▲ 3%',  'up': true,  'color': _accent},
        {'icon': '📍', 'num': '2',     'label': '방문 확인',     'trend': '▼ 1%',  'up': false, 'color': _green},
      ],
      '주': [
        {'icon': '📱', 'num': '890',   'label': '잠금화면 노출', 'trend': '▲ 8%',  'up': true,  'color': _orange},
        {'icon': '👆', 'num': '67',    'label': '점포 클릭',     'trend': '▲ 12%', 'up': true,  'color': _accent},
        {'icon': '📍', 'num': '9',     'label': '방문 확인',     'trend': '▲ 2%',  'up': true,  'color': _green},
      ],
      '월': [
        {'icon': '📱', 'num': '3,841', 'label': '잠금화면 노출', 'trend': '▲ 12%', 'up': true,  'color': _orange},
        {'icon': '👆', 'num': '293',   'label': '점포 클릭',     'trend': '▲ 8%',  'up': true,  'color': _accent},
        {'icon': '📍', 'num': '41',    'label': '방문 확인',     'trend': '▼ 2%',  'up': false, 'color': _green},
      ],
      '년': [
        {'icon': '📱', 'num': '46,120','label': '잠금화면 노출', 'trend': '▲ 31%', 'up': true,  'color': _orange},
        {'icon': '👆', 'num': '3,521', 'label': '점포 클릭',     'trend': '▲ 22%', 'up': true,  'color': _accent},
        {'icon': '📍', 'num': '502',   'label': '방문 확인',     'trend': '▲ 15%', 'up': true,  'color': _green},
      ],
    };

    // 기간별 그래프 데이터 (노출·클릭·방문)
    final graphData = {
      '일': {
        'labels': ['08시', '10시', '12시', '14시', '16시', '18시', '20시'],
        'exposure': [12.0, 28.0, 35.0, 42.0, 38.0, 21.0, 14.0],
        'click':    [1.0,  3.0,  4.0,  6.0,  5.0,  2.0,  1.0],
        'visit':    [0.0,  0.0,  1.0,  1.0,  0.0,  0.0,  0.0],
      },
      '주': {
        'labels': ['월', '화', '수', '목', '금', '토', '일'],
        'exposure': [80.0, 110.0, 130.0, 145.0, 160.0, 120.0, 55.0],
        'click':    [6.0,  9.0,  11.0, 13.0, 14.0, 10.0, 4.0],
        'visit':    [1.0,  1.0,  2.0,  1.0,  2.0,  1.0,  0.0],
      },
      '월': {
        'labels': ['1주', '2주', '3주', '4주'],
        'exposure': [820.0, 1050.0, 1120.0, 851.0],
        'click':    [62.0,  80.0,   88.0,   63.0],
        'visit':    [8.0,   12.0,   14.0,   7.0],
      },
      '년': {
        'labels': ['1월', '2월', '3월', '4월', '5월', '6월', '7월', '8월', '9월', '10월', '11월', '12월'],
        'exposure': [2800.0, 3100.0, 3800.0, 4200.0, 5100.0, 4800.0, 4300.0, 4600.0, 3900.0, 3600.0, 3200.0, 2820.0],
        'click':    [210.0, 235.0, 290.0, 320.0, 390.0, 365.0, 328.0, 350.0, 298.0, 275.0, 244.0, 216.0],
        'visit':    [28.0,  32.0,  41.0,  45.0,  55.0,  52.0,  47.0,  50.0,  43.0,  40.0,  35.0,  32.0],
      },
    };

    final kpis = kpiData[_dateFilter] ?? kpiData['일']!;
    final gData = graphData[_dateFilter] ?? graphData['일']!;
    final labels   = gData['labels']   as List<String>;
    final exposure = gData['exposure'] as List<double>;
    final click    = gData['click']    as List<double>;
    final visit    = gData['visit']    as List<double>;

    final funnelSteps = [
      {'label': '잠금화면 노출', 'num': kpis[0]['num'] as String, 'rate': '100%', 'w': 1.0, 'color': _orange},
      {'label': '점포 클릭',    'num': kpis[1]['num'] as String, 'rate': '7.5%', 'w': 0.74,'color': const Color(0xFFFB923C)},
      {'label': '실제 방문',    'num': kpis[2]['num'] as String, 'rate': '1.1%', 'w': 0.5, 'color': _green},
    ];

    return _MgrSection(
      title: '📊 점포 분석',
      child: Column(
        children: [
          // 기간 탭 필터 (일/주/월/년)
          Row(
            children: ['일', '주', '월', '년'].map((d) => Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _dateFilter = d),
                child: Container(
                  margin: const EdgeInsets.only(right: 4),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: _dateFilter == d ? _accent.withOpacity(0.2) : _bg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _dateFilter == d ? _accent : _border, width: 1.2),
                  ),
                  child: Center(child: Text(d,
                    style: TextStyle(
                      fontSize: 13,
                      color: _dateFilter == d ? _accent : _textSec,
                      fontWeight: _dateFilter == d ? FontWeight.w800 : FontWeight.normal,
                    ))),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 14),

          // 라인+에리어 트렌드 그래프
          Container(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Text('📈 트렌드 차트',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _textPri)),
                  const Spacer(),
                  _legendDot(_orange, '노출'), const SizedBox(width: 8),
                  _legendDot(_accent, '클릭'),  const SizedBox(width: 8),
                  _legendDot(_green, '방문'),
                ]),
                const SizedBox(height: 12),
                SizedBox(
                  height: 140,
                  child: CustomPaint(
                    painter: _LineAreaChartPainter(
                      labels: labels,
                      series: [
                        _ChartSeries(data: exposure, color: _orange, label: '노출'),
                        _ChartSeries(data: click,    color: _accent,  label: '클릭'),
                        _ChartSeries(data: visit,    color: _green,   label: '방문'),
                      ],
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // KPI 카드 3개 — 년 탭은 세로, 나머지는 가로
          if (_dateFilter == '년')
            Column(
              children: kpis.map((k) => Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _bg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _border),
                ),
                child: Row(
                  children: [
                    Text(k['icon'] as String, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(k['label'] as String,
                            style: const TextStyle(fontSize: 12, color: _textSec)),
                          const SizedBox(height: 2),
                          Text(k['num'] as String,
                            style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w900,
                              color: k['color'] as Color)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: ((k['up'] as bool) ? _green : const Color(0xFFFF4D4F))
                            .withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(k['trend'] as String,
                        style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700,
                          color: (k['up'] as bool) ? _green : const Color(0xFFFF4D4F))),
                    ),
                  ],
                ),
              )).toList(),
            )
          else
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
            onBtnTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const CouponIssuanceScreen())),
            child: Column(
              children: [
                Row(
                  children: [
                    _AcItem(num: '38', label: '발급', color: _orange),
                    const SizedBox(width: 8),
                    _AcItem(num: '21', label: '사용', color: _accent),
                    const SizedBox(width: 8),
                    _AcItem(num: '17', label: '잔여', color: _green),
                  ],
                ),
                const SizedBox(height: 10),
                _ProgressBar(label: '사용률', value: 0.55, valueText: '55%', color: _orange),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CouponIssuanceScreen())),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('발행 현황 보기',
                        style: TextStyle(color: _accent, fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios, size: 10, color: _accent),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── ⑥ 서비스 · 상품 관리 (업종별 기본 + 직접 입력) ──
  Widget _buildMenuSection() {
    final typeColors = <String, Color>{
      '공임비': const Color(0xFF4FC3F7),
      '부품비': const Color(0xFFFF6B35),
      '서비스비용': const Color(0xFF10B981),
    };

    return _MgrSection(
      title: '🔧 서비스 · 상품 관리',
      trailing: GestureDetector(
        onTap: () => _showAddServiceDialog(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _accent.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _accent.withOpacity(0.4)),
          ),
          child: const Text('+ 직접 추가',
            style: TextStyle(color: _accent, fontSize: 11, fontWeight: FontWeight.w700)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 업종 선택 탭
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _defaultServices.keys.map((cat) =>
                GestureDetector(
                  onTap: () => setState(() {
                    _currentCategory = cat;
                    _loadDefaultServices(cat);
                  }),
                  child: Container(
                    margin: const EdgeInsets.only(right: 6, bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _currentCategory == cat
                        ? _accent.withOpacity(0.2) : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _currentCategory == cat ? _accent : _border),
                    ),
                    child: Text(cat,
                      style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600,
                        color: _currentCategory == cat ? _accent : _textSec)),
                  ),
                ),
              ).toList(),
            ),
          ),
          // 상품 목록
          ..._services.asMap().entries.map((entry) {
            final i = entry.key;
            final s = entry.value;
            final typeColor = typeColors[s['type']] ?? _textSec;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _border),
              ),
              child: Row(
                children: [
                  // 활성화 토글
                  GestureDetector(
                    onTap: () => setState(() => s['active'] = !(s['active'] as bool)),
                    child: Container(
                      width: 16, height: 16,
                      decoration: BoxDecoration(
                        color: (s['active'] as bool) ? _green : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: (s['active'] as bool) ? _green : _border, width: 1.5),
                      ),
                      child: (s['active'] as bool)
                        ? const Icon(Icons.check, size: 10, color: Colors.white) : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // 타입 배지
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(s['type'] as String,
                      style: TextStyle(fontSize: 9, color: typeColor, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(s['name'] as String,
                      style: const TextStyle(fontSize: 12, color: _textPri, fontWeight: FontWeight.w600)),
                  ),
                  Text('${s['price']}${s['unit']}',
                    style: const TextStyle(fontSize: 12, color: _accent, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showEditServiceDialog(i),
                    child: Icon(Icons.edit_outlined, size: 14, color: _textSec.withOpacity(0.6)),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => setState(() => _services.removeAt(i)),
                    child: Icon(Icons.delete_outline, size: 14, color: Colors.red.withOpacity(0.6)),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 12, color: _orange),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text('업종 선택 시 기본 상품이 자동 제공됩니다. + 직접 추가로 모든 업종 상품 발행 가능',
                    style: TextStyle(fontSize: 10, color: Color(0xFFFF6B35))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // ── 다이얼로그: 영업상태 ──
  void _showStatusDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('영업 상태 선택',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['🟢 영업중', '🔴 영업종료', '🟡 준비중', '⚫ 임시휴업'].map((s) =>
            GestureDetector(
              onTap: () {
                setState(() => _status = s);
                Navigator.pop(ctx);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _status == s ? _accent.withOpacity(0.2) : _bg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _status == s ? _accent : _border,
                    width: _status == s ? 2 : 1),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(s,
                        style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600,
                          color: _status == s ? _accent : Colors.white)),
                    ),
                    if (_status == s)
                      Icon(Icons.check_circle, color: _accent, size: 18),
                  ],
                ),
              ),
            ),
          ).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('취소', style: TextStyle(color: _textSec)),
          ),
        ],
      ),
    );
  }

  // ── 다이얼로그: 영업시간 설정 ──
  void _showHoursDialog() {
    final days = _hours.keys.toList();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setDlgState) => AlertDialog(
          backgroundColor: _card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('영업시간 설정',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: days.map((day) {
                  final info = _hours[day]!;
                  final isClosed = info['closed'] == 'true';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _bg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _border),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 24,
                          child: Text(day,
                            style: const TextStyle(color: Colors.white,
                              fontSize: 13, fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            setDlgState(() => info['closed'] = isClosed ? 'false' : 'true');
                            setState(() {});
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isClosed ? Colors.red.withOpacity(0.2) : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isClosed ? Colors.red.withOpacity(0.5) : _border),
                            ),
                            child: Text('휴무',
                              style: TextStyle(
                                fontSize: 11,
                                color: isClosed ? Colors.red : _textSec,
                                fontWeight: isClosed ? FontWeight.w700 : FontWeight.normal,
                              )),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (!isClosed) ...[
                          GestureDetector(
                            onTap: () async {
                              final t = await showTimePicker(
                                context: ctx2,
                                initialTime: TimeOfDay(
                                  hour: int.parse(info['open']!.split(':')[0]),
                                  minute: int.parse(info['open']!.split(':')[1]),
                                ),
                                builder: (c, child) => Theme(
                                  data: ThemeData.dark().copyWith(
                                    colorScheme: const ColorScheme.dark(
                                      primary: Color(0xFF4FC3F7)),
                                  ),
                                  child: child!,
                                ),
                              );
                              if (t != null) {
                                setDlgState(() => info['open'] =
                                  '${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}');
                                setState(() {});
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _accent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: _accent.withOpacity(0.3)),
                              ),
                              child: Text(info['open']!,
                                style: const TextStyle(color: Color(0xFF4FC3F7), fontSize: 12,
                                  fontWeight: FontWeight.w700)),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: Text('~', style: TextStyle(color: Colors.white54, fontSize: 12)),
                          ),
                          GestureDetector(
                            onTap: () async {
                              final t = await showTimePicker(
                                context: ctx2,
                                initialTime: TimeOfDay(
                                  hour: int.parse(info['close']!.split(':')[0]),
                                  minute: int.parse(info['close']!.split(':')[1]),
                                ),
                                builder: (c, child) => Theme(
                                  data: ThemeData.dark().copyWith(
                                    colorScheme: const ColorScheme.dark(
                                      primary: Color(0xFF4FC3F7)),
                                  ),
                                  child: child!,
                                ),
                              );
                              if (t != null) {
                                setDlgState(() => info['close'] =
                                  '${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}');
                                setState(() {});
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _accent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: _accent.withOpacity(0.3)),
                              ),
                              child: Text(info['close']!,
                                style: const TextStyle(color: Color(0xFF4FC3F7), fontSize: 12,
                                  fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('취소', style: TextStyle(color: Color(0xFFB0BEC5))),
            ),
            TextButton(
              onPressed: () {
                setState(() {});
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ 영업시간이 저장되었습니다!')));
              },
              child: const Text('저장', style: TextStyle(color: Color(0xFF4FC3F7), fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  // ── 범례 도트 ──
  Widget _legendDot(Color color, String label) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 10, height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 3),
      Text(label, style: TextStyle(fontSize: 10, color: color)),
    ]);
  }

  // ── 다이얼로그: 주소 검색 ──
  void _showAddressSearchDialog() {
    final searchCtrl = TextEditingController();
    final sampleAddresses = [
      '서울시 강남구 테헤란로 123',
      '서울시 삼성동 충무로 45',
      '부산시 해운대구 해운대해변로 789',
      '대구시 수성구 범어동 123-4',
      '대구시 중구 동성로 56',
      '인천시 남동구 소래로 22',
      '광주시 서구 누시각로 88',
    ];
    List<String> filtered = [];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setDlgState) => AlertDialog(
          backgroundColor: _card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.search, color: Color(0xFF4FC3F7), size: 20),
              SizedBox(width: 8),
              Text('주소 검색',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: _bg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _accent.withOpacity(0.4)),
                  ),
                  child: TextField(
                    controller: searchCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: '도로명 주소를 입력하세요',
                      hintStyle: TextStyle(color: _textSec.withOpacity(0.5), fontSize: 12),
                      prefixIcon: Icon(Icons.search, color: _textSec, size: 18),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    ),
                    onChanged: (v) {
                      setDlgState(() {
                        filtered = v.isEmpty ? [] :
                          sampleAddresses.where((a) => a.contains(v)).toList();
                      });
                    },
                  ),
                ),
                const SizedBox(height: 12),
                if (searchCtrl.text.isNotEmpty && filtered.isEmpty)
                  GestureDetector(
                    onTap: () {
                      setState(() => _addrCtrl.text = searchCtrl.text);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _orange.withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.add_location_alt, color: _orange, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text('"${searchCtrl.text}" 직접 입력하기',
                              style: const TextStyle(color: Color(0xFFFF6B35), fontSize: 12,
                                fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ...filtered.map((addr) => GestureDetector(
                  onTap: () {
                    setState(() => _addrCtrl.text = addr);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('주소 설정: $addr')));
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: _bg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Color(0xFF4FC3F7), size: 14),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(addr,
                            style: const TextStyle(color: Colors.white, fontSize: 12))),
                      ],
                    ),
                  ),
                )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('취소', style: TextStyle(color: _textSec)),
            ),
          ],
        ),
      ),
    );
  }

  // ── 다이얼로그: 서비스 추가 ──
  void _showAddServiceDialog() {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    String selectedType = '공임비';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setDlgState) => AlertDialog(
          backgroundColor: _card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('서비스 추가',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dialogField('서비스명', '예: 엔진오일 교환', nameCtrl),
              const SizedBox(height: 10),
              _dialogField('가격 (원)', '예: 89000', priceCtrl,
                inputType: TextInputType.number),
              const SizedBox(height: 12),
              const Text('비용 구분',
                style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 11, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Row(
                children: ['공임비', '부품비', '서비스비용'].map((t) =>
                  GestureDetector(
                    onTap: () => setDlgState(() => selectedType = t),
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: selectedType == t ? _accent.withOpacity(0.2) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selectedType == t ? _accent : _border),
                      ),
                      child: Text(t,
                        style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600,
                          color: selectedType == t ? _accent : _textSec)),
                    ),
                  ),
                ).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('취소', style: TextStyle(color: _textSec)),
            ),
            TextButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty || priceCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('서비스명과 가격을 입력하세요')));
                  return;
                }
                setState(() => _services.add({
                  'name': nameCtrl.text.trim(),
                  'price': priceCtrl.text.trim(),
                  'unit': '원',
                  'active': true,
                  'type': selectedType,
                }));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ 서비스가 추가되었습니다!')));
              },
              child: const Text('추가', style: TextStyle(color: Color(0xFF4FC3F7), fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  // ── 다이얼로그: 서비스 수정 ──
  void _showEditServiceDialog(int index) {
    final s = _services[index];
    final nameCtrl = TextEditingController(text: s['name'] as String);
    final priceCtrl = TextEditingController(text: s['price'] as String);
    String selectedType = s['type'] as String;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setDlgState) => AlertDialog(
          backgroundColor: _card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('서비스 수정',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dialogField('서비스명', '', nameCtrl),
              const SizedBox(height: 10),
              _dialogField('가격 (원)', '', priceCtrl,
                inputType: TextInputType.number),
              const SizedBox(height: 12),
              const Text('비용 구분',
                style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 11, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Row(
                children: ['공임비', '부품비', '서비스비용'].map((t) =>
                  GestureDetector(
                    onTap: () => setDlgState(() => selectedType = t),
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: selectedType == t ? _accent.withOpacity(0.2) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selectedType == t ? _accent : _border),
                      ),
                      child: Text(t,
                        style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600,
                          color: selectedType == t ? _accent : _textSec)),
                    ),
                  ),
                ).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('취소', style: TextStyle(color: _textSec)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _services[index]['name'] = nameCtrl.text.trim();
                  _services[index]['price'] = priceCtrl.text.trim();
                  _services[index]['type'] = selectedType;
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ 수정되었습니다!')));
              },
              child: const Text('저장', style: TextStyle(color: Color(0xFF4FC3F7), fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  // ── 헬퍼: 다이얼로그 입력 필드 ──
  Widget _dialogField(String label, String hint, TextEditingController ctrl,
    {TextInputType inputType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
          style: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _accent.withOpacity(0.3)),
          ),
          child: TextField(
            controller: ctrl,
            keyboardType: inputType,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: _textSec.withOpacity(0.4), fontSize: 12),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ),
      ],
    );
  }

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


// ==================== 쿠폰 발행 현황 페이지 ====================
class CouponIssuanceScreen extends StatefulWidget {
  const CouponIssuanceScreen({super.key});
  @override
  State<CouponIssuanceScreen> createState() => _CouponIssuanceScreenState();
}

class _CouponIssuanceScreenState extends State<CouponIssuanceScreen> {
  static const Color _bg     = Color(0xFF020810);
  static const Color _card   = Color(0xFF0D1B2A);
  static const Color _accent = Color(0xFF4FC3F7);
  static const Color _orange = Color(0xFFFF6B35);
  static const Color _green  = Color(0xFF10B981);
  static const Color _red    = Color(0xFFEF5350);
  static const Color _textPri = Colors.white;
  static const Color _textSec = Color(0xFFB0BEC5);
  static const Color _border  = Color(0xFF1E3A5F);

  String _filterStatus = '전체';

  final List<Map<String, dynamic>> _coupons = [
    {'id': 'CP001', 'name': '엔진오일 20% 할인', 'discount': '20%', 'type': '할인율',
     'issued': 12, 'used': 8, 'remaining': 4, 'expiry': '2025-05-31', 'status': '진행중', 'color': 0xFF10B981},
    {'id': 'CP002', 'name': '브레이크 패드 5,000원 할인', 'discount': '5,000원', 'type': '정액',
     'issued': 8, 'used': 6, 'remaining': 2, 'expiry': '2025-04-30', 'status': '마감임박', 'color': 0xFFFF6B35},
    {'id': 'CP003', 'name': '타이어 교체 무료점검', 'discount': '무료', 'type': '무료서비스',
     'issued': 15, 'used': 5, 'remaining': 10, 'expiry': '2025-06-30', 'status': '진행중', 'color': 0xFF4FC3F7},
    {'id': 'CP004', 'name': '신규 고객 10% 할인', 'discount': '10%', 'type': '할인율',
     'issued': 3, 'used': 3, 'remaining': 0, 'expiry': '2025-03-31', 'status': '소진', 'color': 0xFF78909C},
  ];

  List<Map<String, dynamic>> get _filtered {
    if (_filterStatus == '전체') return _coupons;
    return _coupons.where((c) => c['status'] == _filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    final total = _coupons.fold(0, (s, c) => s + (c['issued'] as int));
    final used  = _coupons.fold(0, (s, c) => s + (c['used'] as int));
    final remaining = total - used;
    final usageRate = total > 0 ? used / total : 0.0;

    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          // 상단바
          Container(
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
                  child: Text('🎟️ 쿠폰 발행 현황',
                    style: TextStyle(color: _textPri, fontSize: 17, fontWeight: FontWeight.w700)),
                ),
                GestureDetector(
                  onTap: () => _showCreateCouponDialog(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _orange.withOpacity(0.5)),
                    ),
                    child: const Text('+ 쿠폰 발급',
                      style: TextStyle(color: _orange, fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 요약 카드
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_accent.withOpacity(0.12), _orange.withOpacity(0.08)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _accent.withOpacity(0.25)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _StatBox(label: '총 발급', value: '$total', color: _textPri),
                          _StatBox(label: '사용', value: '$used', color: _accent),
                          _StatBox(label: '잔여', value: '$remaining', color: _green),
                          _StatBox(label: '사용률', value: '${(usageRate * 100).toStringAsFixed(0)}%', color: _orange),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(children: [
                        const Text('전체 사용률', style: TextStyle(color: _textSec, fontSize: 12)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: usageRate,
                              backgroundColor: _border,
                              valueColor: AlwaysStoppedAnimation<Color>(_orange),
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${(usageRate * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(color: _orange, fontSize: 12, fontWeight: FontWeight.w700)),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 상태 필터
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['전체', '진행중', '마감임박', '소진'].map((s) =>
                      GestureDetector(
                        onTap: () => setState(() => _filterStatus = s),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: _filterStatus == s ? _accent.withOpacity(0.2) : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _filterStatus == s ? _accent : _border),
                          ),
                          child: Text(s,
                            style: TextStyle(
                              fontSize: 12,
                              color: _filterStatus == s ? _accent : _textSec,
                              fontWeight: _filterStatus == s ? FontWeight.w700 : FontWeight.normal,
                            )),
                        ),
                      )
                    ).toList(),
                  ),
                ),
                const SizedBox(height: 14),

                // 쿠폰 목록
                ..._filtered.map((c) => _buildCouponCard(c)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponCard(Map<String, dynamic> c) {
    final color = Color(c['color'] as int);
    final issued = c['issued'] as int;
    final used = c['used'] as int;
    final usageRate = issued > 0 ? used / issued : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
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
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: color.withOpacity(0.4)),
                ),
                child: Text(c['status'] as String,
                  style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _border.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(c['type'] as String,
                  style: const TextStyle(color: _textSec, fontSize: 10)),
              ),
              const Spacer(),
              Text(c['id'] as String,
                style: const TextStyle(color: _textSec, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c['name'] as String,
                      style: const TextStyle(color: _textPri, fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('할인: ${c['discount']}  ·  만료: ${c['expiry']}',
                      style: const TextStyle(color: _textSec, fontSize: 11)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Text(c['discount'] as String,
                  style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _MiniStat(label: '발급', value: '${c['issued']}', color: _textPri),
              const SizedBox(width: 16),
              _MiniStat(label: '사용', value: '${c['used']}', color: _accent),
              const SizedBox(width: 16),
              _MiniStat(label: '잔여', value: '${c['remaining']}', color: _green),
              const Spacer(),
              Text('${(usageRate * 100).toStringAsFixed(0)}%',
                style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: usageRate,
              backgroundColor: _border,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: _border),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('수정', style: TextStyle(color: _textSec, fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: _red.withOpacity(0.4)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('종료', style: TextStyle(color: _red.withOpacity(0.8), fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCreateCouponDialog() {
    final nameCtrl = TextEditingController();
    final discountCtrl = TextEditingController();
    String selectedType = '할인율';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20,
            MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🎟️ 새 쿠폰 발급',
                style: TextStyle(color: _textPri, fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              _ModalField(ctrl: nameCtrl, label: '쿠폰명', hint: 'ex) 엔진오일 20% 할인'),
              const SizedBox(height: 10),
              _ModalField(ctrl: discountCtrl, label: '할인값', hint: 'ex) 20% 또는 5000원'),
              const SizedBox(height: 10),
              const Text('쿠폰 유형', style: TextStyle(color: _textSec, fontSize: 12)),
              const SizedBox(height: 8),
              Row(
                children: ['할인율', '정액', '무료서비스'].map((t) =>
                  GestureDetector(
                    onTap: () => setModalState(() => selectedType = t),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: selectedType == t ? _accent.withOpacity(0.2) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: selectedType == t ? _accent : _border),
                      ),
                      child: Text(t,
                        style: TextStyle(
                          fontSize: 12,
                          color: selectedType == t ? _accent : _textSec,
                          fontWeight: selectedType == t ? FontWeight.w700 : FontWeight.normal,
                        )),
                    ),
                  )
                ).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ 쿠폰이 발급되었습니다')));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _orange,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('쿠폰 발급하기',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatBox({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(children: [
      Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w800)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 11)),
    ]),
  );
}

class _MiniStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _MiniStat({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(label, style: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 11)),
      const SizedBox(width: 4),
      Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700)),
    ],
  );
}

class _ModalField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label, hint;
  const _ModalField({required this.ctrl, required this.label, required this.hint});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 12)),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF4A6080), fontSize: 13),
          filled: true,
          fillColor: const Color(0xFF020810),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF1E3A5F)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF1E3A5F)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF4FC3F7)),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    ],
  );
}

// ══════════════════════════════════════════════════════════
// 라인+에리어 차트 페인터
// ══════════════════════════════════════════════════════════
class _ChartSeries {
  final List<double> data;
  final Color color;
  final String label;
  const _ChartSeries({required this.data, required this.color, required this.label});
}

class _LineAreaChartPainter extends CustomPainter {
  final List<String> labels;
  final List<_ChartSeries> series;

  const _LineAreaChartPainter({required this.labels, required this.series});

  @override
  void paint(Canvas canvas, Size size) {
    if (series.isEmpty || labels.isEmpty) return;

    const double padLeft   = 10;
    const double padRight  = 6;
    const double padTop    = 8;
    const double padBottom = 22;

    final chartW = size.width  - padLeft - padRight;
    final chartH = size.height - padTop  - padBottom;
    final n = labels.length;

    // 최대값 계산
    double maxVal = 1;
    for (final s in series) {
      for (final v in s.data) {
        if (v > maxVal) maxVal = v;
      }
    }
    maxVal = maxVal * 1.15;

    // 그리드 라인 (수평 3개)
    final gridPaint = Paint()
      ..color = const Color(0xFF1E3A5F).withOpacity(0.5)
      ..strokeWidth = 0.6;
    for (int i = 0; i <= 3; i++) {
      final y = padTop + chartH - (chartH * i / 3);
      canvas.drawLine(Offset(padLeft, y), Offset(padLeft + chartW, y), gridPaint);
    }

    // 각 시리즈 렌더
    for (final s in series) {
      if (s.data.length != n) continue;

      final pts = List.generate(n, (i) {
        final x = padLeft + (i / (n - 1).clamp(1, 9999)) * chartW;
        final y = padTop + chartH - (s.data[i] / maxVal * chartH);
        return Offset(x, y);
      });

      // 에리어 (반투명 채우기)
      final areaPaint = Paint()
        ..color = s.color.withOpacity(0.12)
        ..style = PaintingStyle.fill;
      final areaPath = Path()..moveTo(padLeft, padTop + chartH);
      for (final p in pts) areaPath.lineTo(p.dx, p.dy);
      areaPath
        ..lineTo(padLeft + chartW, padTop + chartH)
        ..close();
      canvas.drawPath(areaPath, areaPaint);

      // 라인
      final linePaint = Paint()
        ..color = s.color
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round;
      final linePath = Path()..moveTo(pts[0].dx, pts[0].dy);
      for (int i = 1; i < pts.length; i++) {
        // 부드러운 커브
        final cp1x = pts[i - 1].dx + (pts[i].dx - pts[i - 1].dx) / 2;
        linePath.cubicTo(cp1x, pts[i - 1].dy, cp1x, pts[i].dy, pts[i].dx, pts[i].dy);
      }
      canvas.drawPath(linePath, linePaint);

      // 도트
      final dotPaint = Paint()..color = s.color;
      for (final p in pts) {
        canvas.drawCircle(p, 2.8, dotPaint);
        canvas.drawCircle(p, 1.4,
          Paint()..color = const Color(0xFF020810));
      }
    }

    // X축 라벨
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < n; i++) {
      final x = padLeft + (i / (n - 1).clamp(1, 9999)) * chartW;
      tp.text = TextSpan(
        text: labels[i],
        style: const TextStyle(fontSize: 9, color: Color(0xFF7AB0D4)),
      );
      tp.layout();
      tp.paint(canvas, Offset(x - tp.width / 2, size.height - padBottom + 5));
    }
  }

  @override
  bool shouldRepaint(covariant _LineAreaChartPainter old) =>
    old.labels != labels || old.series != series;
}
