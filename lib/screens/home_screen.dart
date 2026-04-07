import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav.dart';

// ═══════════════════════════════════════════════════════════════
// MOINCAR Home Screen — 시안 5 : Apple Maps 미니멀 군청색
// 배경: #020810  포인트: #4FC3F7 (아이스블루)  텍스트: #E8F4FF
// ═══════════════════════════════════════════════════════════════
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {

  // ── 컬러 시스템 (군청색 다크) ─────────────────────────────────
  static const Color _bg       = Color(0xFF020810);  // 최심 다크 네이비
  static const Color _s1       = Color(0xFF071428);  // 카드 배경
  static const Color _s2       = Color(0xFF0D1E3C);  // 보조 배경
  static const Color _s3       = Color(0xFF142244);  // 테두리/구분선
  static const Color _br       = Color(0xFF1A3050);  // 보더
  static const Color _accent   = Color(0xFF4FC3F7);  // 아이스블루 포인트
  static const Color _accentS  = Color(0xFF1A3A6E);  // 포인트 소프트
  static const Color _t1       = Color(0xFFE8F4FF);  // 주 텍스트
  static const Color _t2       = Color(0xFF7AB0D4);  // 보조 텍스트
  static const Color _t3       = Color(0xFF3A6080);  // 약한 텍스트

  // ── 스크롤 컨트롤러 (BottomNav 숨김/표시용) ───────────────────
  final ScrollController _scrollController = ScrollController();

  // ── 위치 ─────────────────────────────────────────────────────
  String _currentAddress = '위치 확인 중...';
  double _currentLat = 35.8562;
  double _currentLng = 128.6314;

  // ── 배너 ─────────────────────────────────────────────────────
  int _currentBanner = 0;
  late PageController _bannerController;
  Timer? _bannerTimer;
  bool _bannerJumping = false;

  final List<Map<String, dynamic>> _bannerData = [
    {'tag': '무료 서비스', 'title': 'AI 차량 상태\n무료 진단',       'sub': '지금 바로 차량 점검을 시작하세요',   'emoji': '🤖'},
    {'tag': 'MOINCAR 인증','title': '인증점포\n할인 이벤트',         'sub': '인증 점포 방문 시 10% 할인',       'emoji': '🏆'},
    {'tag': '중고차',      'title': '내 차 시세\n무료로 확인',        'sub': '전국 딜러 실시간 견적 비교',       'emoji': '🚗'},
    {'tag': '자동차 소식', 'title': '중고차 성능점검\n수요 확대',     'sub': '사고이력 · 성능점검표 확인 필수',  'emoji': '📰'},
  ];
  List<Map<String, dynamic>> get _banners =>
      [_bannerData.last, ..._bannerData, _bannerData.first];

  // ── 카테고리 (원형 아이콘) ───────────────────────────────────
  final List<Map<String, dynamic>> _categories = [
    {'name': '정비소',   'icon': '🔧'},
    {'name': '중고차',   'icon': '🚙'},
    {'name': '주유소',   'icon': '⛽'},
    {'name': '딜러십',   'icon': '🏢'},
    {'name': 'AI진단',   'icon': '🤖'},
    {'name': '세차장',   'icon': '🫧'},
    {'name': '부품상',   'icon': '🔩'},
    {'name': '뉴스',     'icon': '📰'},
  ];

  // ── 퀵 기능 (이동리워드 포함 4종) ──────────────────────────────
  final List<Map<String, dynamic>> _quickItems = [
    {'icon': Icons.local_fire_department_outlined, 'label': '긴급\n출동', 'emoji': '🚨', 'color': Color(0xFF7B1E2A)},
    {'icon': Icons.price_change_outlined,           'label': '내 차\n시세',  'emoji': '🏷', 'color': Color(0xFF0D2A4A)},
    {'icon': Icons.newspaper_outlined,              'label': '자동차\n뉴스',  'emoji': '📰', 'color': Color(0xFF0A1E3A)},
    {'icon': Icons.card_giftcard_outlined,          'label': '이동\n리워드', 'emoji': '🎁', 'color': Color(0xFF1A1040)},
  ];

  // ── 추천 점포 ────────────────────────────────────────────────
  final List<Map<String, dynamic>> _stores = [
    {'tag': 'MOINCAR 인증', 'name': '강남자동차정비센터', 'distance': '1.8km', 'sub': '엔진·미션·판금 전문', 'image': 'assets/images/store_repair.jpg',  'emoji': '🔧'},
    {'tag': '인증중고차',    'name': '서울모터스홀딩스', 'distance': '2.4km', 'sub': '수입차·국산차 전문',  'image': 'assets/images/store_carwash.jpg', 'emoji': '🚗'},
    {'tag': '공식딜러',     'name': '현대자동차 강남점', 'distance': '3.0km', 'sub': '신차·인증중고·시승',   'image': 'assets/images/nearby3.jpg',      'emoji': '🏢'},
  ];

  // ── 근처 점포 ────────────────────────────────────────────────
  List<Map<String, dynamic>> _nearbyStores = [
    {'badge': '신규',    'name': '수입차 브레이크 전문점', 'sub': '브레이크 · 하체점검', 'emoji': '🛞', 'image': 'assets/images/nearby1.jpg', 'lat': 35.857, 'lng': 128.633},
    {'badge': '인기',    'name': '하이브리드 배터리케어',  'sub': '배터리 · 전기점검',   'emoji': '⚡', 'image': 'assets/images/nearby2.jpg', 'lat': 35.858, 'lng': 128.630},
    {'badge': 'MOINCAR', 'name': '인증 중고차센터',       'sub': '중고차 · 성능점검',   'emoji': '🚙', 'image': 'assets/images/nearby3.jpg', 'lat': 35.855, 'lng': 128.635},
    {'badge': '추천',    'name': '프리미엄 엔진오일샵',    'sub': '오일 · 경정비',       'emoji': '🔧', 'image': 'assets/images/store_repair.jpg','lat': 35.860, 'lng': 128.628},
    {'badge': '인기',    'name': '타이어 교환 전문센터',   'sub': '타이어 · 얼라인먼트', 'emoji': '🛞', 'image': 'assets/images/recent2.jpg', 'lat': 35.854, 'lng': 128.638},
    {'badge': '신규',    'name': '손세차 디테일링샵',      'sub': '손세차 · 광택코팅',   'emoji': '✨', 'image': 'assets/images/store_carwash.jpg','lat': 35.862,'lng': 128.625},
  ];

  // ── 최근 본 점포 ─────────────────────────────────────────────
  final List<Map<String, dynamic>> _recentStores = [
    {'name': '강남자동차정비',  'sub': '정비 · 엔진오일', 'emoji': '🔧', 'image': 'assets/images/recent1.jpg'},
    {'name': '서울모터스',      'sub': '수입차 중고차',   'emoji': '🚗', 'image': 'assets/images/recent2.jpg'},
    {'name': 'BMW 강남전시장',  'sub': '공식딜러 신차',   'emoji': '🏢', 'image': 'assets/images/recent3.jpg'},
    {'name': 'GS칼텍스 강남',  'sub': '주유소 24시간',   'emoji': '⛽', 'image': 'assets/images/nearby1.jpg'},
    {'name': '프리미엄세차',    'sub': '핸드세차 전문',   'emoji': '🫧', 'image': 'assets/images/nearby2.jpg'},
  ];

  // ── 가까운 점포순 ─────────────────────────────────────────────
  final List<Map<String, dynamic>> _allCloseStores = [
    {'badge': 'MOINCAR', 'name': 'MOINCAR 인증 정비센터',  'sub': '정비 · 엔진오일',     'distance': '1.2km', 'emoji': '🔧', 'image': 'assets/images/close1.jpg'},
    {'badge': '추천',    'name': '프리미엄 디테일링 세차',  'sub': '손세차 · 코팅',       'distance': '2.1km', 'emoji': '🫧', 'image': 'assets/images/store_carwash.jpg'},
    {'badge': 'MOINCAR', 'name': '수입차 타이어 전문점',    'sub': '타이어 · 휠얼라인',   'distance': '3.4km', 'emoji': '🛞', 'image': 'assets/images/recent2.jpg'},
    {'badge': '신규',    'name': '하이브리드 배터리 케어',  'sub': '배터리 · 전기점검',   'distance': '3.8km', 'emoji': '⚡', 'image': 'assets/images/nearby2.jpg'},
    {'badge': '인기',    'name': '수입차 브레이크 전문',    'sub': '브레이크 · 하체점검', 'distance': '4.2km', 'emoji': '🛞', 'image': 'assets/images/nearby1.jpg'},
    {'badge': 'MOINCAR', 'name': '종합 자동차 정비소',      'sub': '종합정비 · 검사',     'distance': '4.9km', 'emoji': '🏆', 'image': 'assets/images/store_repair.jpg'},
    {'badge': '추천',    'name': '엔진오일 전문점',         'sub': '오일 · 경정비',       'distance': '5.3km', 'emoji': '🔧', 'image': 'assets/images/close1.jpg'},
    {'badge': '신규',    'name': '프리미엄 세차 코팅',      'sub': '세차 · 유리막코팅',   'distance': '5.7km', 'emoji': '🫧', 'image': 'assets/images/store_carwash.jpg'},
    {'badge': 'MOINCAR', 'name': '중고차 성능점검센터',     'sub': '중고차 · 성능점검',   'distance': '6.1km', 'emoji': '🚙', 'image': 'assets/images/nearby3.jpg'},
    {'badge': '인기',    'name': '타이어 전문 할인점',      'sub': '타이어 · 얼라인먼트', 'distance': '6.8km', 'emoji': '🛞', 'image': 'assets/images/recent2.jpg'},
    {'badge': '추천',    'name': '국산차 정비 전문점',      'sub': '정비 · 부품교환',     'distance': '7.2km', 'emoji': '🔧', 'image': 'assets/images/store_repair.jpg'},
    {'badge': 'MOINCAR', 'name': 'MOINCAR 인증 렌트카',    'sub': '렌트카 · 단기임대',   'distance': '7.9km', 'emoji': '🚗', 'image': 'assets/images/nearby1.jpg'},
  ];
  int _closeStoreCount = 5;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _bannerController = PageController(initialPage: 1);
    _startBannerTimer();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.deniedForever || perm == LocationPermission.denied) {
        if (mounted) setState(() => _currentAddress = '위치 권한 없음');
        return;
      }
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (!mounted) return;
      setState(() { _currentLat = pos.latitude; _currentLng = pos.longitude; });
      await _updateAddress(pos.latitude, pos.longitude);
      _sortNearby();
    } catch (_) {
      if (mounted) setState(() => _currentAddress = '대구 수성구 범어동');
    }
  }

  Future<void> _updateAddress(double lat, double lng) async {
    try {
      final pm = await placemarkFromCoordinates(lat, lng);
      if (pm.isNotEmpty && mounted) {
        final p = pm.first;
        final parts = <String>[];
        if (p.administrativeArea?.isNotEmpty == true) parts.add(p.administrativeArea!);
        if (p.subAdministrativeArea?.isNotEmpty == true) parts.add(p.subAdministrativeArea!);
        if (p.locality?.isNotEmpty == true && p.locality != p.subAdministrativeArea) parts.add(p.locality!);
        if (p.subLocality?.isNotEmpty == true) parts.add(p.subLocality!);
        setState(() => _currentAddress = parts.isNotEmpty ? parts.join(' ') : '현재 위치');
      }
    } catch (_) {
      if (mounted) setState(() => _currentAddress = '현재 위치');
    }
  }

  void _sortNearby() {
    for (var s in _nearbyStores) {
      final d = Geolocator.distanceBetween(_currentLat, _currentLng, s['lat'] as double, s['lng'] as double);
      s['distM'] = d;
      s['distLabel'] = d < 1000 ? '${d.toStringAsFixed(0)}m' : '${(d / 1000).toStringAsFixed(1)}km';
    }
    if (mounted) setState(() => _nearbyStores.sort((a, b) => (a['distM'] as double).compareTo(b['distM'] as double)));
  }

  void _startBannerTimer() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || _bannerJumping) return;
      _bannerController.animateToPage(_bannerController.page!.round() + 1,
        duration: const Duration(milliseconds: 450), curve: Curves.easeInOut);
    });
  }

  void _onBannerChanged(int index) {
    final total = _banners.length;
    setState(() => _currentBanner = (index - 1 + _bannerData.length) % _bannerData.length);
    if (index == total - 1 && !_bannerJumping) {
      _bannerJumping = true;
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) { _bannerController.jumpToPage(1); _bannerJumping = false; }
      });
    }
    if (index == 0 && !_bannerJumping) {
      _bannerJumping = true;
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) { _bannerController.jumpToPage(total - 2); _bannerJumping = false; }
      });
    }
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPersistentHeader(
            pinned: false,
            floating: true,
            delegate: _TopBarDelegate(
              height: topPad + 108.0,
              child: _buildTopBar(topPad),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(children: [
              _buildBanner(),
              _buildCategoryCircles(),
              _buildRecommendSection(),
              _buildQuickActions(),
              _buildMapPreview(),
              _buildNearbySection(),
              _buildPromoBand(),
              _buildRecentSection(),
              _buildCloseSection(),
              _buildCompanySection(),
              const SizedBox(height: 90),
            ]),
          ),
        ],
      ),
      bottomNavigationBar: HideOnScrollBottomNav(
        activeTab: 'home',
        scrollController: _scrollController,
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // 상단바 — 로고 M 마크 + 텍스트 + 위치 글로우 + 검색
  // ══════════════════════════════════════════════════════════════
  Widget _buildTopBar(double topPad) {
    return Container(
      color: const Color(0xFF030C1C),
      padding: EdgeInsets.only(top: topPad),
      child: Column(children: [
        // 1행: M마크 + MOINCAR + 아이콘들
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: Row(children: [
            // M 로고 마크
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [Color(0xFF1A3A8E), Color(0xFF0D1E5A)],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: _accent.withOpacity(0.25), blurRadius: 10, spreadRadius: 1)],
              ),
              child: Center(child: Text('M',
                style: GoogleFonts.notoSansKr(fontSize: 18, fontWeight: FontWeight.w900, color: _accent))),
            ),
            const SizedBox(width: 10),
            // 로고 텍스트
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('MOINCAR',
                style: GoogleFonts.notoSansKr(fontSize: 18, fontWeight: FontWeight.w900, color: _t1, letterSpacing: 2)),
              Text('mobility international car',
                style: GoogleFonts.notoSansKr(fontSize: 8, color: _t3, letterSpacing: 1.2)),
            ]),
            const Spacer(),
            // 알림 버튼
            Stack(clipBehavior: Clip.none, children: [
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: _s1, borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: _br),
                  ),
                  child: const Icon(Icons.notifications_none_rounded, color: _t2, size: 18),
                ),
              ),
              Positioned(right: -1, top: -1,
                child: Container(
                  width: 14, height: 14,
                  decoration: const BoxDecoration(color: Color(0xFFE53935), shape: BoxShape.circle),
                  child: const Center(child: Text('2', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold))),
                ),
              ),
            ]),
            const SizedBox(width: 8),
            // 프로필 버튼
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: _s1, borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: _br),
                ),
                child: const Icon(Icons.person_outline_rounded, color: _t2, size: 18),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 10),
        // 2행: 위치 + 검색
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Column(children: [
            // 위치 바
            GestureDetector(
              onTap: _showLocationSearch,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: _s1.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _br.withOpacity(0.5)),
                ),
                child: Row(children: [
                  Container(
                    width: 7, height: 7,
                    decoration: BoxDecoration(
                      color: _accent,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: _accent.withOpacity(0.6), blurRadius: 6)],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_currentAddress,
                    style: GoogleFonts.notoSansKr(fontSize: 12, color: _t2),
                    overflow: TextOverflow.ellipsis)),
                  Text('변경 ›', style: GoogleFonts.notoSansKr(fontSize: 10, color: _t3)),
                ]),
              ),
            ),
            const SizedBox(height: 6),
            // 검색바
            Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: _s1, borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _br),
                    ),
                    child: Row(children: [
                      const SizedBox(width: 12),
                      Icon(Icons.search_rounded, color: _t3, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text('정비소, 중고차, 딜러 검색...',
                        style: GoogleFonts.notoSansKr(fontSize: 12, color: _t3))),
                    ]),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // 마이크 버튼
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: _s1, borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _br),
                  ),
                  child: Icon(Icons.mic_none_rounded, color: _accent, size: 20),
                ),
              ),
            ]),
          ]),
        ),
        const SizedBox(height: 8),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // 배너 — 군청색 그라디언트 + 아이스블루 인디케이터
  // ══════════════════════════════════════════════════════════════
  Widget _buildBanner() {
    final banners = _banners;
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      height: 230,
      child: Stack(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: PageView.builder(
            controller: _bannerController,
            itemCount: banners.length,
            onPageChanged: _onBannerChanged,
            itemBuilder: (_, i) {
              final b = banners[i];
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [Color(0xFF071428), Color(0xFF0D2244), Color(0xFF061A38)],
                  ),
                ),
                child: Stack(fit: StackFit.expand, children: [
                  // 배경 글로우 효과
                  Positioned(right: -30, top: -30,
                    child: Container(
                      width: 220, height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _accent.withOpacity(0.05),
                      ),
                    ),
                  ),
                  // 좌측 텍스트
                  Positioned(left: 18, top: 18, bottom: 18,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      // 태그 칩
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _accent.withOpacity(0.15),
                          border: Border.all(color: _accent.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('✨  ${b['tag']}',
                          style: GoogleFonts.notoSansKr(fontSize: 10, color: _accent, fontWeight: FontWeight.w600)),
                      ),
                      // 타이틀
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(b['title'] as String,
                          style: GoogleFonts.notoSansKr(fontSize: 18, fontWeight: FontWeight.w800, color: _t1, height: 1.3)),
                        const SizedBox(height: 4),
                        Text(b['sub'] as String,
                          style: GoogleFonts.notoSansKr(fontSize: 11, color: _t3)),
                      ]),
                    ]),
                  ),
                  // 우측 이모지
                  Positioned(right: 16, top: 0, bottom: 20,
                    child: Opacity(
                      opacity: 0.20,
                      child: Text(b['emoji'] as String,
                        style: const TextStyle(fontSize: 110)),
                    ),
                  ),
                ]),
              );
            },
          ),
        ),
        // 테두리
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _br.withOpacity(0.4)),
            ),
          ),
        ),
        // 인디케이터 — 우하단
        Positioned(right: 14, bottom: 10,
          child: Row(mainAxisSize: MainAxisSize.min,
            children: List.generate(_bannerData.length, (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              width: i == _currentBanner ? 18 : 5, height: 5,
              margin: const EdgeInsets.only(left: 4),
              decoration: BoxDecoration(
                color: i == _currentBanner ? _accent : _br,
                borderRadius: BorderRadius.circular(3),
              ),
            )),
          ),
        ),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // 카테고리 — 원형 아이콘 1행
  // ══════════════════════════════════════════════════════════════
  Widget _buildCategoryCircles() {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 18, 0, 4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: _sectionHeader('서비스', null),
        ),
        SizedBox(
          height: 85,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            itemBuilder: (_, i) {
              final c = _categories[i];
              return GestureDetector(
                onTap: () {},
                child: Container(
                  width: 68,
                  margin: EdgeInsets.only(right: i < _categories.length - 1 ? 10 : 0),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    // 원형 링 아이콘
                    Container(
                      width: 54, height: 54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _s1,
                        border: Border.all(color: _br),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: Center(child: Text(c['icon'] as String, style: const TextStyle(fontSize: 22))),
                    ),
                    const SizedBox(height: 6),
                    Text(c['name'] as String,
                      style: GoogleFonts.notoSansKr(fontSize: 10, color: _t3, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center),
                  ]),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // 추천 점포 — 큰 가로 슬라이드 카드 (200px 폭)
  // ══════════════════════════════════════════════════════════════
  Widget _buildRecommendSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: _sectionHeader('⭐  MOINCAR 추천 점포', '전체보기'),
      ),
      SizedBox(
        height: 230,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          itemCount: _stores.length,
          itemBuilder: (_, i) {
            final s = _stores[i];
            return Container(
              width: 200,
              margin: EdgeInsets.only(right: i < _stores.length - 1 ? 12 : 0),
              decoration: BoxDecoration(
                color: _s1,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _br.withOpacity(0.5)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // 이미지 영역
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  child: Stack(children: [
                    SizedBox(
                      width: double.infinity, height: 110,
                      child: Image.asset(s['image'] as String, fit: BoxFit.cover,
                        errorBuilder: (c, e, st) => Container(
                          color: _s2,
                          child: Center(child: Text(s['emoji'] as String, style: const TextStyle(fontSize: 46))),
                        )),
                    ),
                    // 다크 그라디언트
                    Positioned.fill(child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter, end: Alignment.bottomCenter,
                          colors: [Colors.transparent, _bg.withOpacity(0.6)],
                        ),
                      ),
                    )),
                    // 뱃지
                    Positioned(top: 8, left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _bg.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _accent.withOpacity(0.3)),
                        ),
                        child: Text(s['tag'] as String,
                          style: GoogleFonts.notoSansKr(fontSize: 9, color: _accent, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ]),
                ),
                // 정보
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s['name'] as String,
                      style: GoogleFonts.notoSansKr(fontSize: 14, fontWeight: FontWeight.w700, color: _t1),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Text(s['sub'] as String,
                      style: GoogleFonts.notoSansKr(fontSize: 11, color: _t3),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 10),
                    // 버튼 2개
                    Row(children: [
                      Expanded(child: _callBtn()),
                      const SizedBox(width: 8),
                      Expanded(child: _navBtn()),
                    ]),
                  ]),
                ),
              ]),
            );
          },
        ),
      ),
    ]);
  }

  // ══════════════════════════════════════════════════════════════
  // 퀵 기능 — 4칸 그리드 (원형 아이콘 스타일)
  // ══════════════════════════════════════════════════════════════
  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 6, 14, 0),
      padding: const EdgeInsets.fromLTRB(4, 14, 4, 14),
      child: Row(
        children: _quickItems.asMap().entries.map((e) {
          final item = e.value;
          final itemColor = item['color'] as Color;
          final isReward = (item['label'] as String).contains('리워드');
          return Expanded(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.fromLTRB(6, 14, 6, 14),
                decoration: BoxDecoration(
                  color: itemColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isReward
                        ? const Color(0xFF6B4EFF).withOpacity(0.5)
                        : _br.withOpacity(0.5),
                  ),
                  gradient: isReward
                      ? const LinearGradient(
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                          colors: [Color(0xFF1A1040), Color(0xFF2D1060)],
                        )
                      : null,
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  // 원형 아이콘
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.2),
                      border: Border.all(
                        color: isReward
                            ? const Color(0xFF9B7CFF).withOpacity(0.4)
                            : _accent.withOpacity(0.25),
                      ),
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      color: isReward ? const Color(0xFF9B7CFF) : _accent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['label'] as String,
                    style: GoogleFonts.notoSansKr(
                      fontSize: 10,
                      color: isReward ? const Color(0xFF9B7CFF) : _t2,
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ]),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // 지도 미리보기 — 격자 + 핀 + 플로팅 인포바
  // ══════════════════════════════════════════════════════════════
  Widget _buildMapPreview() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF050E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _br.withOpacity(0.4)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(children: [
          // 격자 배경
          Positioned.fill(
            child: CustomPaint(painter: _NavyGridPainter()),
          ),
          // 이미지 시도
          Positioned.fill(
            child: Image.asset('assets/images/map_sample.png', fit: BoxFit.cover,
              errorBuilder: (c, e, s) => const SizedBox()),
          ),
          // 다크 오버레이
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.45))),
          // 내 위치 마커 (글로우)
          Positioned.fill(
            child: Center(child: Container(
              width: 16, height: 16,
              decoration: BoxDecoration(
                color: _accent, shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: _accent.withOpacity(0.2), blurRadius: 0, spreadRadius: 4),
                  BoxShadow(color: _accent.withOpacity(0.1), blurRadius: 0, spreadRadius: 10),
                ],
              ),
            )),
          ),
          // 점포 핀들
          _mapPin(left: 55, top: 60, emoji: '🔧'),
          _mapPin(right: 60, top: 45, emoji: '🚗'),
          _mapPin(left: 75, bottom: 55, emoji: '⛽'),
          _mapPin(right: 45, bottom: 48, emoji: '🏢'),
          // 하단 플로팅 인포바
          Positioned(left: 14, right: 14, bottom: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _bg.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _br.withOpacity(0.5)),
              ),
              child: Row(children: [
                Text('📍  반경 5km 이내',
                  style: GoogleFonts.notoSansKr(fontSize: 12, color: _t2)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _accentS,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _accent.withOpacity(0.4)),
                  ),
                  child: Text('10개 업체',
                    style: GoogleFonts.notoSansKr(fontSize: 11, color: _accent, fontWeight: FontWeight.w700)),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _mapPin({double? left, double? right, double? top, double? bottom, required String emoji}) {
    return Positioned(
      left: left, right: right, top: top, bottom: bottom,
      child: Container(
        width: 30, height: 30,
        decoration: BoxDecoration(
          color: _bg.withOpacity(0.8), shape: BoxShape.circle,
          border: Border.all(color: _accent.withOpacity(0.4)),
        ),
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 14))),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // 근처 점포 — 번호 순위 + 가로 정보
  // ══════════════════════════════════════════════════════════════
  Widget _buildNearbySection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      decoration: BoxDecoration(
        color: _s1, borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _br.withOpacity(0.5)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHeader('📍  인근 점포', '더보기'),
        const SizedBox(height: 12),
        ..._nearbyStores.asMap().entries.map((e) {
          final i = e.key;
          final s = e.value;
          final dist = s['distLabel'] as String? ?? '위치 계산 중';
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: i < _nearbyStores.length - 1
                ? Border(bottom: BorderSide(color: _br.withOpacity(0.3)))
                : null,
            ),
            child: Row(children: [
              // 순위 번호
              Container(
                width: 26, height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, color: _s2,
                  border: Border.all(color: _br.withOpacity(0.5)),
                ),
                child: Center(child: Text('${i + 1}',
                  style: GoogleFonts.notoSansKr(fontSize: 11, fontWeight: FontWeight.w700, color: _accent))),
              ),
              const SizedBox(width: 10),
              // 썸네일
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 50, height: 50,
                  child: Image.asset(s['image'] as String, fit: BoxFit.cover,
                    errorBuilder: (c, e2, st) => Container(
                      color: _s2,
                      child: Center(child: Text(s['emoji'] as String, style: const TextStyle(fontSize: 20))),
                    )),
                ),
              ),
              const SizedBox(width: 10),
              // 정보
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // 뱃지
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  margin: const EdgeInsets.only(bottom: 3),
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _accent.withOpacity(0.2)),
                  ),
                  child: Text(s['badge'] as String,
                    style: GoogleFonts.notoSansKr(fontSize: 9, color: _accent)),
                ),
                Text(s['name'] as String,
                  style: GoogleFonts.notoSansKr(fontSize: 13, fontWeight: FontWeight.w700, color: _t1),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 1),
                Text(s['sub'] as String,
                  style: GoogleFonts.notoSansKr(fontSize: 11, color: _t3),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              ])),
              // 우측
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(dist,
                  style: GoogleFonts.notoSansKr(fontSize: 11, color: _accent, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Row(children: [
                  _iconBtnS(Icons.phone_outlined),
                  const SizedBox(width: 5),
                  _iconBtnSAccent(Icons.navigation_outlined),
                ]),
              ]),
            ]),
          );
        }).toList(),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // 프로모 밴드 — 군청색 그라디언트
  // ══════════════════════════════════════════════════════════════
  Widget _buildPromoBand() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      height: 96,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF071428), Color(0xFF0D2040), Color(0xFF071428)],
        ),
        border: Border.all(color: _accentS.withOpacity(0.5)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(children: [
          Positioned(right: -20, top: -20,
            child: Container(
              width: 110, height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _accent.withOpacity(0.06),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: _accent.withOpacity(0.3)),
                  ),
                  child: Text('한국자동차협회',
                    style: GoogleFonts.notoSansKr(fontSize: 10, color: _accent, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 6),
                Text('인증서 발급 신청하러가기',
                  style: GoogleFonts.notoSansKr(fontSize: 14, fontWeight: FontWeight.w800, color: _t1)),
              ])),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentS,
                  foregroundColor: _accent,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: _accent.withOpacity(0.4)),
                  ),
                  elevation: 0,
                ),
                child: Text('신청하기', style: GoogleFonts.notoSansKr(fontSize: 12, color: _accent, fontWeight: FontWeight.w700)),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // 최근 본 점포 — 가로 스크롤 카드
  // ══════════════════════════════════════════════════════════════
  Widget _buildRecentSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      decoration: BoxDecoration(
        color: _s1, borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _br.withOpacity(0.5)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 0, 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: _sectionHeader('🕐  최근 본 점포', '더보기'),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 145,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(right: 14),
            itemCount: _recentStores.length,
            itemBuilder: (_, i) {
              final s = _recentStores[i];
              return Container(
                width: 115,
                margin: EdgeInsets.only(right: i < _recentStores.length - 1 ? 10 : 0),
                decoration: BoxDecoration(
                  color: _s2, borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _br.withOpacity(0.4)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                    child: SizedBox(
                      width: double.infinity, height: 72,
                      child: Image.asset(s['image'] as String, fit: BoxFit.cover,
                        errorBuilder: (c, e, st) => Container(
                          color: _s2,
                          child: Center(child: Text(s['emoji'] as String, style: const TextStyle(fontSize: 28))),
                        )),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(9, 8, 9, 0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(s['name'] as String,
                        style: GoogleFonts.notoSansKr(fontSize: 11, fontWeight: FontWeight.w700, color: _t1),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(s['sub'] as String,
                        style: GoogleFonts.notoSansKr(fontSize: 10, color: _t3),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    ]),
                  ),
                ]),
              );
            },
          ),
        ),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // 가까운 점포순 — 번호 + 거리 + 버튼 + 더보기
  // ══════════════════════════════════════════════════════════════
  Widget _buildCloseSection() {
    final list = _allCloseStores.take(_closeStoreCount).toList();
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      decoration: BoxDecoration(
        color: _s1, borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _br.withOpacity(0.5)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHeader('📍  가까운 점포순', null),
        const SizedBox(height: 12),
        ...list.asMap().entries.map((e) {
          final i = e.key;
          final s = e.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: _s2, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _br.withOpacity(0.4)),
            ),
            child: Row(children: [
              // 이미지/이모지 좌측
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
                child: SizedBox(
                  width: 86, height: 86,
                  child: Image.asset(s['image'] as String, fit: BoxFit.cover,
                    errorBuilder: (c, e2, st) => Container(
                      color: const Color(0xFF0D1E3C),
                      child: Center(child: Text(s['emoji'] as String, style: const TextStyle(fontSize: 30))),
                    )),
                ),
              ),
              // 정보
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Expanded(child: Text(s['name'] as String,
                        style: GoogleFonts.notoSansKr(fontSize: 13, fontWeight: FontWeight.w700, color: _t1),
                        maxLines: 1, overflow: TextOverflow.ellipsis)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _accent.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: _accent.withOpacity(0.2)),
                        ),
                        child: Text(s['badge'] as String,
                          style: GoogleFonts.notoSansKr(fontSize: 9, color: _accent, fontWeight: FontWeight.w700)),
                      ),
                    ]),
                    const SizedBox(height: 3),
                    Text(s['sub'] as String,
                      style: GoogleFonts.notoSansKr(fontSize: 11, color: _t3)),
                    const SizedBox(height: 7),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Row(children: [
                        Icon(Icons.location_on, color: _accent, size: 13),
                        const SizedBox(width: 2),
                        Text(s['distance'] as String,
                          style: GoogleFonts.notoSansKr(fontSize: 13, fontWeight: FontWeight.w800, color: _accent)),
                      ]),
                      Row(children: [
                        _callBtn(),
                        const SizedBox(width: 6),
                        _navBtn(),
                      ]),
                    ]),
                  ]),
                ),
              ),
            ]),
          );
        }).toList(),

        // 더보기 버튼
        if (_closeStoreCount < _allCloseStores.length)
          GestureDetector(
            onTap: () => setState(() =>
              _closeStoreCount = (_closeStoreCount + 5).clamp(0, _allCloseStores.length)),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: _s2, borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _br.withOpacity(0.4)),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.keyboard_arrow_down_rounded, color: _t3, size: 20),
                const SizedBox(width: 6),
                Text('더보기  (${_allCloseStores.length - _closeStoreCount}개 남음)',
                  style: GoogleFonts.notoSansKr(fontSize: 13, color: _t2, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // 회사 정보 푸터 — 배달의민족 스타일 (v22.0.0)
  // ══════════════════════════════════════════════════════════════
  Widget _buildCompanySection() {
    return Container(
      color: const Color(0xFF010610),
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // 로고 + 서비스 링크 행
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // 좌: M 로고
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xFF1A3A8E), Color(0xFF0D1E5A)],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _accent.withOpacity(0.2)),
              boxShadow: [BoxShadow(color: _accent.withOpacity(0.15), blurRadius: 12)],
            ),
            child: Center(child: Text('M',
              style: GoogleFonts.notoSansKr(
                fontSize: 22, fontWeight: FontWeight.w900, color: _accent))),
          ),
          const SizedBox(width: 14),
          // 우: 브랜드명 + 링크
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('MOINCAR',
              style: GoogleFonts.notoSansKr(
                fontSize: 16, fontWeight: FontWeight.w900, color: _t1, letterSpacing: 2)),
            Text('mobility international car',
              style: GoogleFonts.notoSansKr(fontSize: 9, color: _t3, letterSpacing: 0.5)),
            const SizedBox(height: 10),
            // 메뉴 링크들 (배민 스타일 가로 나열)
            Wrap(
              spacing: 0,
              children: ['공지사항', '이용약관', '개인정보처리방침', '사업자정보']
                .asMap().entries.map((e) => Row(mainAxisSize: MainAxisSize.min, children: [
                  GestureDetector(
                    onTap: () {},
                    child: Text(e.value,
                      style: GoogleFonts.notoSansKr(fontSize: 11, color: _t3)),
                  ),
                  if (e.key < 3)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text('|', style: GoogleFonts.notoSansKr(
                        fontSize: 10, color: _br)),
                    ),
              ])).toList(),
            ),
          ])),
        ]),

        const SizedBox(height: 20),
        Container(height: 1, color: _br.withOpacity(0.3)),
        const SizedBox(height: 16),

        // 회사 상세 정보 (배민 스타일 소형 텍스트)
        Text(
          '(주)모인카 | 대표 홍길동',
          style: GoogleFonts.notoSansKr(fontSize: 11, color: _t3),
        ),
        const SizedBox(height: 4),
        Text(
          '사업자등록번호 123-45-67890  |  통신판매업신고 2025-서울강남-0001',
          style: GoogleFonts.notoSansKr(fontSize: 10, color: _t3.withOpacity(0.8)),
        ),
        const SizedBox(height: 4),
        Text(
          '서울특별시 강남구 봉은사로 114  |  고객센터 02-3482-7433',
          style: GoogleFonts.notoSansKr(fontSize: 10, color: _t3.withOpacity(0.8)),
        ),
        const SizedBox(height: 4),
        Text(
          '평일 09:00 ~ 18:00  (주말/공휴일 휴무)',
          style: GoogleFonts.notoSansKr(fontSize: 10, color: _t3.withOpacity(0.8)),
        ),

        const SizedBox(height: 16),
        Container(height: 1, color: _br.withOpacity(0.2)),
        const SizedBox(height: 12),

        // 하단 카피라이트 + 이동리워드 안내
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
            '© 2025 MOINCAR Corp.',
            style: GoogleFonts.notoSansKr(fontSize: 10, color: _t3.withOpacity(0.6)),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1040),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF6B4EFF).withOpacity(0.4)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.card_giftcard_outlined, size: 12,
                  color: Color(0xFF9B7CFF)),
                const SizedBox(width: 4),
                Text('이동리워드',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 10, color: const Color(0xFF9B7CFF),
                    fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ]),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // 위치 검색 팝업
  // ══════════════════════════════════════════════════════════════
  void _showLocationSearch() {
    final ctrl = TextEditingController();
    List<Map<String, dynamic>> results = [];
    final List<Map<String, dynamic>> db = [
      {'name': '서울 강남구 역삼동',    'lat': 37.5013, 'lng': 127.0398},
      {'name': '서울 강남구 삼성동',    'lat': 37.5140, 'lng': 127.0571},
      {'name': '서울 서초구 서초동',    'lat': 37.4923, 'lng': 127.0092},
      {'name': '서울 마포구 합정동',    'lat': 37.5503, 'lng': 126.9136},
      {'name': '서울 종로구 종로동',    'lat': 37.5730, 'lng': 126.9794},
      {'name': '서울 송파구 잠실동',    'lat': 37.5145, 'lng': 127.1059},
      {'name': '서울 영등포구 여의도동','lat': 37.5219, 'lng': 126.9245},
      {'name': '부산 해운대구 해운대동','lat': 35.1628, 'lng': 129.1635},
      {'name': '부산 부산진구 서면동',  'lat': 35.1584, 'lng': 129.0591},
      {'name': '대구 수성구 범어동',    'lat': 35.8562, 'lng': 128.6314},
      {'name': '대구 중구 동성로',      'lat': 35.8714, 'lng': 128.5944},
      {'name': '인천 남동구 구월동',    'lat': 37.4490, 'lng': 126.7311},
      {'name': '광주 서구 치평동',      'lat': 35.1540, 'lng': 126.8476},
      {'name': '대전 서구 둔산동',      'lat': 36.3504, 'lng': 127.3845},
      {'name': '울산 남구 삼산동',      'lat': 35.5381, 'lng': 129.3114},
      {'name': '수원 팔달구 인계동',    'lat': 37.2637, 'lng': 127.0286},
      {'name': '성남 분당구 서현동',    'lat': 37.3838, 'lng': 127.1237},
      {'name': '청주 흥덕구 가경동',    'lat': 36.6377, 'lng': 127.4596},
      {'name': '전주 완산구 효자동',    'lat': 35.8131, 'lng': 127.1134},
    ];
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: _s1,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setM) => DraggableScrollableSheet(
          expand: false, initialChildSize: 0.75, maxChildSize: 0.95, minChildSize: 0.5,
          builder: (_, sc) => Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(ctx).viewInsets.bottom + 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: _br, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Text('위치 검색', style: GoogleFonts.notoSansKr(fontSize: 18, fontWeight: FontWeight.w800, color: _t1)),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl, autofocus: true,
                style: GoogleFonts.notoSansKr(color: _t1),
                decoration: InputDecoration(
                  hintText: '예) 강남구, 수성구, 해운대동',
                  hintStyle: GoogleFonts.notoSansKr(fontSize: 14, color: _t3),
                  prefixIcon: Icon(Icons.search, color: _t3),
                  filled: true, fillColor: _s2,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _br)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _br)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _accent)),
                ),
                onChanged: (v) {
                  final q = v.trim();
                  setM(() => results = q.isEmpty ? [] : db.where((a) => (a['name'] as String).contains(q)).toList());
                },
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () { Navigator.pop(ctx); _initLocation(); },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _accent.withOpacity(0.25)),
                  ),
                  child: Row(children: [
                    Icon(Icons.my_location, color: _accent, size: 18),
                    const SizedBox(width: 8),
                    Text('현재 내 위치로', style: GoogleFonts.notoSansKr(fontSize: 14, color: _accent, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: results.isEmpty
                    ? Center(child: Text(ctrl.text.isEmpty ? '동네 이름을 입력하세요' : '검색 결과 없음',
                        style: GoogleFonts.notoSansKr(fontSize: 14, color: _t3)))
                    : ListView.separated(
                        controller: sc, itemCount: results.length,
                        separatorBuilder: (_, __) => Divider(height: 1, color: _br),
                        itemBuilder: (_, i) {
                          final r = results[i];
                          return ListTile(
                            leading: Icon(Icons.location_on_outlined, color: _accent),
                            title: Text(r['name'] as String,
                              style: GoogleFonts.notoSansKr(fontSize: 14, fontWeight: FontWeight.w600, color: _t1)),
                            onTap: () {
                              Navigator.pop(ctx);
                              setState(() {
                                _currentLat = r['lat'] as double;
                                _currentLng = r['lng'] as double;
                                _currentAddress = r['name'] as String;
                              });
                              _sortNearby();
                            },
                          );
                        },
                      ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  // ── 공용 위젯 ─────────────────────────────────────────────────
  Widget _sectionHeader(String title, String? action) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title, style: GoogleFonts.notoSansKr(fontSize: 15, fontWeight: FontWeight.w800, color: _t1)),
      if (action != null)
        GestureDetector(
          onTap: () {},
          child: Text(action, style: GoogleFonts.notoSansKr(fontSize: 12, color: _accent)),
        ),
    ]);
  }

  // 전화 버튼 (아웃라인)
  Widget _callBtn() => GestureDetector(
    onTap: () {},
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _accent.withOpacity(0.25)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.phone_outlined, size: 12, color: _accent),
        const SizedBox(width: 3),
        Text('전화', style: GoogleFonts.notoSansKr(fontSize: 11, color: _accent, fontWeight: FontWeight.w600)),
      ]),
    ),
  );

  // 길찾기 버튼 (채움)
  Widget _navBtn() => GestureDetector(
    onTap: () {},
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _accentS,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _accent.withOpacity(0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.navigation_outlined, size: 12, color: _t2),
        const SizedBox(width: 3),
        Text('길찾기', style: GoogleFonts.notoSansKr(fontSize: 11, color: _t2, fontWeight: FontWeight.w600)),
      ]),
    ),
  );

  // 아이콘 버튼 소형 (아웃라인)
  Widget _iconBtnS(IconData icon) => Container(
    width: 30, height: 30,
    decoration: BoxDecoration(
      color: _accent.withOpacity(0.08),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: _accent.withOpacity(0.2)),
    ),
    child: Icon(icon, size: 14, color: _accent),
  );

  // 아이콘 버튼 소형 (채움)
  Widget _iconBtnSAccent(IconData icon) => Container(
    width: 30, height: 30,
    decoration: BoxDecoration(
      color: _accentS,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: _accent.withOpacity(0.3)),
    ),
    child: Icon(icon, size: 14, color: _t2),
  );

  Widget _infoLine(IconData icon, String label, String value) {
    return Row(children: [
      Icon(icon, size: 13, color: _t3),
      const SizedBox(width: 6),
      Text('$label  ', style: GoogleFonts.notoSansKr(fontSize: 11, color: _t3)),
      Expanded(child: Text(value,
        style: GoogleFonts.notoSansKr(fontSize: 11, color: _t2, fontWeight: FontWeight.w500),
        overflow: TextOverflow.ellipsis)),
    ]);
  }
}

// ── 상단바 델리게이트 ─────────────────────────────────────────────
class _TopBarDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;
  const _TopBarDelegate({required this.height, required this.child});
  @override double get minExtent => height;
  @override double get maxExtent => height;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => child;
  @override
  bool shouldRebuild(_TopBarDelegate old) => old.height != height || old.child != child;
}

// ── 군청색 격자 배경 페인터 ──────────────────────────────────────
class _NavyGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 전체 배경
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF050E1E));
    // 격자선
    final p = Paint()
      ..color = const Color(0xFF142244).withOpacity(0.5)
      ..strokeWidth = 0.5;
    const sp = 28.0;
    for (double x = 0; x < size.width; x += sp) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += sp) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
    // 도로 라인
    final road = Paint()..color = const Color(0xFF1A3A6E).withOpacity(0.35)..strokeWidth = 3;
    canvas.drawLine(Offset(0, size.height * 0.5), Offset(size.width, size.height * 0.5), road);
    canvas.drawLine(Offset(size.width * 0.4, 0), Offset(size.width * 0.4, size.height), road);
  }
  @override bool shouldRepaint(_) => false;
}
