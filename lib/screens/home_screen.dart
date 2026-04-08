import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../widgets/bottom_nav.dart';

// ═══════════════════════════════════════════════════════════════
// MOINCAR Home Screen v26.0.0
// ─ 상단: 로고+검색바 스크롤 시 위로 사라짐
// ─ 위치띠: 로고바 뒤따라 올라가다가 최상단에서 핀 고정
// ─ 배너 230px (겹침 없음 - Stack + SliverPersistentHeader 방식)
// ─ 카테고리 이모지 정상 표시
// ─ BottomNav: 스크롤 중 숨김, 600ms 정지 후 복귀
// ─ 카드 전체 크기 확대, 여백 넉넉하게
// ─ 가까운점포 7개씩 로딩 → 더보기
// ─ 하단 KAA 실제정보 + 배달의민족 레이아웃
// ═══════════════════════════════════════════════════════════════
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {

  // ── 컬러 시스템 ──────────────────────────────────────────────
  static const Color _bg      = Color(0xFF020810);
  static const Color _s1      = Color(0xFF071428);
  static const Color _s2      = Color(0xFF0D1E3C);
  static const Color _br      = Color(0xFF1A3050);
  static const Color _accent  = Color(0xFF4FC3F7);
  static const Color _accentS = Color(0xFF1A3A6E);
  static const Color _t1      = Color(0xFFE8F4FF);
  static const Color _t2      = Color(0xFF7AB0D4);
  static const Color _t3      = Color(0xFF3A6080);

  // ── 상단 레이아웃 상수 ────────────────────────────────────────
  static const double _topBarH = 58.0;   // 로고+검색바 높이
  static const double _locBarH = 44.0;   // 위치띠 높이

  // ── 스크롤 ───────────────────────────────────────────────────
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  // BottomNav 숨김/표시
  bool _navVisible = true;
  Timer? _navTimer;

  // ── 위치 ─────────────────────────────────────────────────────
  String _currentAddress = '위치 확인 중...';
  double _currentLat = 37.5665;
  double _currentLng = 126.9780;

  // ── 배너 (무한 캐러셀) ────────────────────────────────────────
  static const int _bannerMultiplier = 500;
  int _currentBannerIndex = 0;
  late PageController _bannerController;
  Timer? _bannerTimer;

  final List<Map<String, dynamic>> _bannerData = [
    {'tag': 'MOINCAR 인증', 'title': '인증점포\n할인 이벤트',      'sub': '인증 점포 방문 시 10% 할인',    'emoji': '🏆'},
    {'tag': '중고차',       'title': '내 차 시세\n무료 확인',       'sub': '전국 딜러 실시간 견적 비교',    'emoji': '🚗'},
    {'tag': '자동차 소식',  'title': '중고차 성능점검\n수요 확대',  'sub': '사고이력·성능점검표 확인 필수', 'emoji': '📰'},
    {'tag': '무료 서비스',  'title': '긴급 출동\n즉시 연결',        'sub': '24시간 긴급출동 서비스',        'emoji': '🚨'},
    {'tag': '이동리워드',   'title': '이동할수록\n적립되는 리워드', 'sub': '주행 거리당 포인트 지급',       'emoji': '🎁'},
  ];

  int get _infiniteCount => _bannerData.length * _bannerMultiplier;
  int get _initialPage => (_bannerMultiplier ~/ 2) * _bannerData.length;

  // ── 카테고리 (9개) ──────────────────────────────────────────
  final List<Map<String, dynamic>> _categories = [
    {'name': '정비소',  'icon': '🔧'},
    {'name': '중고차',  'icon': '🚙'},
    {'name': '주유소',  'icon': '⛽'},
    {'name': '딜러십',  'icon': '🏢'},
    {'name': 'AI진단',  'icon': '🤖'},
    {'name': '세차장',  'icon': '🫧'},
    {'name': '부품상',  'icon': '🔩'},
    {'name': '뉴스',    'icon': '📰'},
    {'name': '검사소',  'icon': '🔍'},
  ];

  // ── 퀵 기능 (4종) ────────────────────────────────────────────
  final List<Map<String, dynamic>> _quickItems = [
    {'icon': Icons.local_fire_department_outlined, 'label': '긴급\n출동',   'color': Color(0xFF7B1E2A), 'aColor': Color(0xFFFF6B6B)},
    {'icon': Icons.price_change_outlined,           'label': '내 차\n시세',  'color': Color(0xFF0D2A4A), 'aColor': Color(0xFF4FC3F7)},
    {'icon': Icons.newspaper_outlined,              'label': '자동차\n뉴스', 'color': Color(0xFF0A1E3A), 'aColor': Color(0xFF4FC3F7)},
    {'icon': Icons.card_giftcard_outlined,          'label': '이동\n리워드', 'color': Color(0xFF1A1040), 'aColor': Color(0xFF9B7CFF)},
  ];

  // ── 추천 점포 ────────────────────────────────────────────────
  final List<Map<String, dynamic>> _stores = [
    {'tag': 'MOINCAR 인증', 'name': '강남자동차정비센터',  'distance': '1.8km', 'sub': '엔진·미션·판금 전문',   'image': 'assets/images/store_repair.jpg',  'emoji': '🔧'},
    {'tag': '인증중고차',    'name': '서울모터스홀딩스',    'distance': '2.4km', 'sub': '수입차·국산차 전문',   'image': 'assets/images/store_carwash.jpg', 'emoji': '🚗'},
    {'tag': '공식딜러',      'name': '현대자동차 강남점',   'distance': '3.0km', 'sub': '신차·인증중고·시승',   'image': 'assets/images/nearby3.jpg',       'emoji': '🏢'},
    {'tag': 'MOINCAR 인증', 'name': '프리미엄 세차코팅',   'distance': '3.5km', 'sub': '손세차·광택·코팅',     'image': 'assets/images/nearby1.jpg',       'emoji': '🫧'},
    {'tag': '이동리워드',    'name': '리워드 파트너 정비',  'distance': '5.1km', 'sub': '이동리워드 적립 가능',  'image': 'assets/images/nearby2.jpg',       'emoji': '🎁'},
  ];

  // ── 인근 점포 (2배 크기) ────────────────────────────────────
  List<Map<String, dynamic>> _nearbyStores = [
    {'badge': '신규',    'name': '수입차 브레이크 전문점', 'sub': '브레이크·하체점검', 'emoji': '🛞', 'image': 'assets/images/nearby1.jpg', 'lat': 35.857, 'lng': 128.633},
    {'badge': '인기',    'name': '하이브리드 배터리케어',  'sub': '배터리·전기점검',   'emoji': '⚡', 'image': 'assets/images/nearby2.jpg', 'lat': 35.858, 'lng': 128.630},
    {'badge': 'MOINCAR', 'name': '인증 중고차센터',        'sub': '중고차·성능점검',   'emoji': '🚙', 'image': 'assets/images/nearby3.jpg', 'lat': 35.855, 'lng': 128.635},
    {'badge': '추천',    'name': '프리미엄 엔진오일샵',    'sub': '오일·경정비',        'emoji': '🔧', 'image': 'assets/images/store_repair.jpg', 'lat': 35.860, 'lng': 128.628},
    {'badge': '인기',    'name': '타이어 교환 전문센터',   'sub': '타이어·얼라인먼트', 'emoji': '🛞', 'image': 'assets/images/recent2.jpg', 'lat': 35.854, 'lng': 128.638},
    {'badge': '신규',    'name': '손세차 디테일링샵',      'sub': '손세차·광택코팅',   'emoji': '✨', 'image': 'assets/images/store_carwash.jpg', 'lat': 35.862, 'lng': 128.625},
  ];

  // ── 최근 본 점포 ─────────────────────────────────────────────
  final List<Map<String, dynamic>> _recentStores = [
    {'name': '강남자동차정비',  'sub': '정비·엔진오일', 'emoji': '🔧', 'image': 'assets/images/recent1.jpg'},
    {'name': '서울모터스',      'sub': '수입차 중고차', 'emoji': '🚗', 'image': 'assets/images/recent2.jpg'},
    {'name': 'BMW 강남전시장',  'sub': '공식딜러 신차', 'emoji': '🏢', 'image': 'assets/images/recent3.jpg'},
    {'name': 'GS칼텍스 강남',  'sub': '주유소 24시간', 'emoji': '⛽', 'image': 'assets/images/nearby1.jpg'},
    {'name': '프리미엄세차',    'sub': '핸드세차 전문', 'emoji': '🫧', 'image': 'assets/images/nearby2.jpg'},
  ];

  // ── 가까운 점포순 (7개씩 페이지 로딩) ───────────────────────
  final List<Map<String, dynamic>> _allCloseStores = [
    {'badge': 'MOINCAR', 'name': 'MOINCAR 인증 정비센터',  'sub': '정비·엔진오일',     'distance': '1.2km', 'emoji': '🔧', 'image': 'assets/images/store_repair.jpg'},
    {'badge': '추천',    'name': '프리미엄 디테일링 세차',  'sub': '손세차·코팅',        'distance': '2.1km', 'emoji': '🫧', 'image': 'assets/images/store_carwash.jpg'},
    {'badge': 'MOINCAR', 'name': '수입차 타이어 전문점',    'sub': '타이어·휠얼라인',   'distance': '3.4km', 'emoji': '🛞', 'image': 'assets/images/recent2.jpg'},
    {'badge': '신규',    'name': '하이브리드 배터리 케어',  'sub': '배터리·전기점검',   'distance': '3.8km', 'emoji': '⚡', 'image': 'assets/images/nearby2.jpg'},
    {'badge': '인기',    'name': '수입차 브레이크 전문',    'sub': '브레이크·하체점검', 'distance': '4.2km', 'emoji': '🛞', 'image': 'assets/images/nearby1.jpg'},
    {'badge': 'MOINCAR', 'name': '종합 자동차 정비소',      'sub': '종합정비·검사',     'distance': '4.9km', 'emoji': '🏆', 'image': 'assets/images/store_repair.jpg'},
    {'badge': '추천',    'name': '엔진오일 전문점',          'sub': '오일·경정비',        'distance': '5.3km', 'emoji': '🔧', 'image': 'assets/images/nearby3.jpg'},
    {'badge': '신규',    'name': '프리미엄 세차 코팅',       'sub': '세차·유리막코팅',   'distance': '5.7km', 'emoji': '🫧', 'image': 'assets/images/store_carwash.jpg'},
    {'badge': 'MOINCAR', 'name': '중고차 성능점검센터',      'sub': '중고차·성능점검',   'distance': '6.1km', 'emoji': '🚙', 'image': 'assets/images/nearby3.jpg'},
    {'badge': '인기',    'name': '타이어 전문 할인점',        'sub': '타이어·얼라인먼트', 'distance': '6.8km', 'emoji': '🛞', 'image': 'assets/images/recent2.jpg'},
    {'badge': '추천',    'name': '국산차 정비 전문점',        'sub': '정비·부품교환',     'distance': '7.2km', 'emoji': '🔧', 'image': 'assets/images/store_repair.jpg'},
    {'badge': 'MOINCAR', 'name': 'MOINCAR 인증 렌트카',     'sub': '렌트카·단기임대',   'distance': '7.9km', 'emoji': '🚗', 'image': 'assets/images/nearby1.jpg'},
    {'badge': '신규',    'name': '전기차 충전 정비소',        'sub': '전기차·충전설비',   'distance': '8.2km', 'emoji': '⚡', 'image': 'assets/images/nearby2.jpg'},
    {'badge': '인기',    'name': '수입차 종합 케어센터',      'sub': '수입차·판금·도색',  'distance': '8.9km', 'emoji': '🏢', 'image': 'assets/images/nearby3.jpg'},
  ];
  int _closeLoadedPage = 1;
  static const int _pageSize = 7;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _bannerController = PageController(initialPage: _initialPage);
    _currentBannerIndex = 0;
    _startBannerTimer();
    _initLocation();
    _scrollController.addListener(_onScroll);
  }

  // ── 스크롤 리스너 ────────────────────────────────────────────
  void _onScroll() {
    final offset = _scrollController.offset.clamp(0.0, double.infinity);
    setState(() => _scrollOffset = offset);

    // BottomNav: 스크롤 중 숨김, 600ms 정지 → 나타남
    _navTimer?.cancel();
    if (_navVisible) setState(() => _navVisible = false);
    _navTimer = Timer(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _navVisible = true);
    });
  }

  // 로고+검색바: 0 ~ _topBarH 만큼 위로 올라감 (clamp)
  double get _topBarSlide => _scrollOffset.clamp(0.0, _topBarH);

  // 위치띠 top:
  //   스크롤 전 → topPad + _topBarH (로고바 바로 아래)
  //   스크롤 중 → topPad + _topBarH - _topBarSlide (로고바와 함께 올라감)
  //   로고바 완전히 사라진 후 → topPad + 0 = topPad (최상단에 고정)
  double _locBarTop(double topPad) {
    return topPad + (_topBarH - _topBarSlide).clamp(0.0, _topBarH);
  }

  // 스크롤 콘텐츠의 상단 패딩
  // 위치띠가 항상 일정 위치에 있으므로 콘텐츠는 위치띠 아래부터 시작
  // topPad + topBarH + locBarH (고정값) - 스크롤 오프셋만큼 위로
  // → ListView의 padding.top으로 처리하면 스크롤과 함께 올라감
  double _contentInitialPad(double topPad) {
    return topPad + _topBarH + _locBarH;
  }

  // ── 위치 초기화 ──────────────────────────────────────────────
  Future<void> _initLocation() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.deniedForever || perm == LocationPermission.denied) {
        if (mounted) setState(() => _currentAddress = '서울특별시');
        return;
      }
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (!mounted) return;
      setState(() { _currentLat = pos.latitude; _currentLng = pos.longitude; });
      await _updateAddress(pos.latitude, pos.longitude);
      _sortNearby();
    } catch (_) {
      if (mounted) setState(() => _currentAddress = '서울특별시');
    }
  }

  Future<void> _updateAddress(double lat, double lng) async {
    try {
      final pm = await placemarkFromCoordinates(lat, lng);
      if (pm.isNotEmpty && mounted) {
        final p = pm.first;
        final parts = <String>[];
        if (p.administrativeArea?.isNotEmpty == true) parts.add(p.administrativeArea!);
        if (p.subLocality?.isNotEmpty == true) parts.add(p.subLocality!);
        setState(() => _currentAddress = parts.isNotEmpty ? parts.join(' ') : '현재 위치');
      }
    } catch (_) {
      if (mounted) setState(() => _currentAddress = '현재 위치');
    }
  }

  void _sortNearby() {
    for (var s in _nearbyStores) {
      final d = Geolocator.distanceBetween(
          _currentLat, _currentLng, s['lat'] as double, s['lng'] as double);
      s['distM'] = d;
      s['distLabel'] = d < 1000
          ? '${d.toStringAsFixed(0)}m'
          : '${(d / 1000).toStringAsFixed(1)}km';
    }
    if (mounted) {
      setState(() => _nearbyStores
          .sort((a, b) => (a['distM'] as double).compareTo(b['distM'] as double)));
    }
  }

  // ── 배너 타이머 ──────────────────────────────────────────────
  void _startBannerTimer() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      final nextPage = _bannerController.page!.round() + 1;
      _bannerController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _onBannerPageChanged(int rawPage) {
    setState(() => _currentBannerIndex = rawPage % _bannerData.length);
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    _tabController.dispose();
    _navTimer?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════
  // BUILD — CustomScrollView + SliverPersistentHeader 방식
  // ══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final initPad = _contentInitialPad(topPad);

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // ── 메인 스크롤 콘텐츠 ──────────────────────────────
          Positioned.fill(
            child: ListView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              // 초기 padding = 상태바 + 로고바 + 위치띠 높이
              padding: EdgeInsets.only(top: initPad + 12, bottom: 100),
              children: [
                _buildBanner(),
                _buildCategoryGrid(),
                _buildRecommendSection(),
                _buildQuickActions(),
                _buildMapPreview(),
                _buildNearbySection(),
                _buildPromoBand(),
                _buildRecentSection(),
                _buildCloseSection(),
                _buildCompanySection(),
              ],
            ),
          ),

          // ── 로고+검색바 (스크롤 시 위로 슬라이드 아웃) ───────
          Positioned(
            top: topPad - _topBarSlide,
            left: 0,
            right: 0,
            child: _buildTopLogoBar(),
          ),

          // ── 위치띠 (로고바 따라 올라가다 상단 고정) ──────────
          Positioned(
            top: _locBarTop(topPad),
            left: 0,
            right: 0,
            child: _buildLocationBar(),
          ),
        ],
      ),
      // ── 하단 네비게이션 (스크롤 중 숨김, 정지 후 복귀) ───────
      bottomNavigationBar: AnimatedSlide(
        offset: _navVisible ? Offset.zero : const Offset(0, 1),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: AnimatedOpacity(
          opacity: _navVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: const BottomNav(activeTab: 'home'),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // 로고+검색바
  // ══════════════════════════════════════════════════════════════
  Widget _buildTopLogoBar() {
    return Container(
      height: _topBarH,
      color: const Color(0xFF030C1C),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        // M 로고
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFF1A3A8E), Color(0xFF0D1E5A)],
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: _accent.withValues(alpha: 0.3), blurRadius: 8)],
          ),
          child: Center(child: Text('M', style: GoogleFonts.notoSansKr(
              fontSize: 19, fontWeight: FontWeight.w900, color: _accent))),
        ),
        const SizedBox(width: 9),
        Column(crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('MOINCAR', style: GoogleFonts.notoSansKr(
              fontSize: 17, fontWeight: FontWeight.w900, color: _t1, letterSpacing: 2)),
          Text('mobility international car', style: GoogleFonts.notoSansKr(
              fontSize: 7.5, color: _t3, letterSpacing: 0.8)),
        ]),
        const SizedBox(width: 10),
        // 검색바 확장
        Expanded(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                color: _s1, borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _br),
              ),
              child: Row(children: [
                const SizedBox(width: 10),
                Icon(Icons.search_rounded, color: _t3, size: 16),
                const SizedBox(width: 6),
                Expanded(child: Text('정비소, 중고차, 딜러 검색...',
                    style: GoogleFonts.notoSansKr(fontSize: 11, color: _t3))),
              ]),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // 알림
        Stack(clipBehavior: Clip.none, children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: _s1,
                borderRadius: BorderRadius.circular(50), border: Border.all(color: _br)),
            child: const Icon(Icons.notifications_none_rounded, color: _t2, size: 19),
          ),
          Positioned(right: -1, top: -1,
            child: Container(
              width: 15, height: 15,
              decoration: const BoxDecoration(color: Color(0xFFE53935), shape: BoxShape.circle),
              child: const Center(child: Text('2',
                  style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold))),
            ),
          ),
        ]),
        const SizedBox(width: 7),
        // 프로필
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(color: _s1,
              borderRadius: BorderRadius.circular(50), border: Border.all(color: _br)),
          child: const Icon(Icons.person_outline_rounded, color: _t2, size: 19),
        ),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // 위치띠
  // ══════════════════════════════════════════════════════════════
  Widget _buildLocationBar() {
    return GestureDetector(
      onTap: _showLocationSearch,
      child: Container(
        height: _locBarH,
        decoration: const BoxDecoration(
          color: Color(0xFF04111F),
          boxShadow: [BoxShadow(color: Color(0x55000000), blurRadius: 4, offset: Offset(0, 2))],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(children: [
          Container(
            width: 9, height: 9,
            decoration: BoxDecoration(
              color: _accent, shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: _accent.withValues(alpha: 0.6), blurRadius: 7)],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.location_on_outlined, color: _accent, size: 16),
          const SizedBox(width: 5),
          Expanded(child: Text(_currentAddress,
              style: GoogleFonts.notoSansKr(
                  fontSize: 14, color: _t2, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis)),
          Text('변경  ›', style: GoogleFonts.notoSansKr(
              fontSize: 12, color: _accent, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // 배너 — 230px 무한 캐러셀
  // ══════════════════════════════════════════════════════════════
  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      height: 230,
      child: Stack(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: PageView.builder(
            controller: _bannerController,
            itemCount: _infiniteCount,
            onPageChanged: _onBannerPageChanged,
            itemBuilder: (_, rawIndex) {
              final b = _bannerData[rawIndex % _bannerData.length];
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [Color(0xFF071428), Color(0xFF0D2244), Color(0xFF061A38)],
                  ),
                ),
                child: Stack(fit: StackFit.expand, children: [
                  // 배경 원형 글로우
                  Positioned(right: -40, top: -40,
                    child: Container(
                      width: 260, height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _accent.withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                  // 우측 큰 이모지 (배경)
                  Positioned(right: 8, bottom: 16,
                    child: Opacity(
                      opacity: 0.18,
                      child: Text(b['emoji'] as String,
                          style: const TextStyle(fontSize: 140)),
                    ),
                  ),
                  // 좌측 텍스트 영역
                  Positioned(left: 24, top: 28, bottom: 26,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                      // 태그 칩
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
                        decoration: BoxDecoration(
                          color: _accent.withValues(alpha: 0.15),
                          border: Border.all(color: _accent.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('✨  ${b['tag']}',
                            style: GoogleFonts.notoSansKr(
                                fontSize: 12, color: _accent, fontWeight: FontWeight.w600)),
                      ),
                      // 타이틀 + 서브
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(b['title'] as String,
                            style: GoogleFonts.notoSansKr(
                                fontSize: 26, fontWeight: FontWeight.w900,
                                color: _t1, height: 1.25)),
                        const SizedBox(height: 7),
                        Text(b['sub'] as String,
                            style: GoogleFonts.notoSansKr(fontSize: 13, color: _t2)),
                      ]),
                    ]),
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
              border: Border.all(color: _br.withValues(alpha: 0.4)),
            ),
          ),
        ),
        // 인디케이터
        Positioned(right: 18, bottom: 16,
          child: Row(mainAxisSize: MainAxisSize.min,
            children: List.generate(_bannerData.length, (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              width: i == _currentBannerIndex ? 24 : 7, height: 7,
              margin: const EdgeInsets.only(left: 4),
              decoration: BoxDecoration(
                color: i == _currentBannerIndex ? _accent : _br,
                borderRadius: BorderRadius.circular(4),
              ),
            )),
          ),
        ),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // 카테고리 — 5+4 두 줄
  // ══════════════════════════════════════════════════════════════
  Widget _buildCategoryGrid() {
    final row1 = _categories.sublist(0, 5);
    final row2 = _categories.sublist(5, 9);

    Widget catItem(Map<String, dynamic> c) {
      return GestureDetector(
        onTap: () {},
        child: SizedBox(
          width: 66,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 62, height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _s1,
                border: Border.all(color: _br, width: 1.5),
                boxShadow: [BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: Center(
                child: Text(c['icon'] as String,
                    style: const TextStyle(fontSize: 28, height: 1.0)),
              ),
            ),
            const SizedBox(height: 10),
            Text(c['name'] as String,
                style: GoogleFonts.notoSansKr(
                    fontSize: 12, color: _t2, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
                maxLines: 1),
          ]),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHeader('서비스', null),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: row1.map(catItem).toList(),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 33),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: row2.map(catItem).toList(),
          ),
        ),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // 추천 점포 — 가로 슬라이드 (260px 카드)
  // ══════════════════════════════════════════════════════════════
  Widget _buildRecommendSection() {
    const double cardW = 270;
    const double imgH  = 165;
    const double cardH = 305;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(18, 26, 18, 18),
        child: _sectionHeader('⭐  MOINCAR 추천 점포', '전체보기'),
      ),
      SizedBox(
        height: cardH,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _stores.length,
          itemBuilder: (_, i) {
            final s = _stores[i];
            return Container(
              width: cardW,
              margin: EdgeInsets.only(right: i < _stores.length - 1 ? 16 : 0),
              decoration: BoxDecoration(
                color: _s1,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: _br.withValues(alpha: 0.5)),
                boxShadow: [BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                  child: Stack(children: [
                    SizedBox(
                      width: double.infinity, height: imgH,
                      child: Image.asset(s['image'] as String, fit: BoxFit.cover,
                          errorBuilder: (c, e, st) => Container(
                              color: _s2,
                              child: Center(child: Text(s['emoji'] as String,
                                  style: const TextStyle(fontSize: 64))))),
                    ),
                    Positioned.fill(child: Container(
                      decoration: BoxDecoration(gradient: LinearGradient(
                          begin: Alignment.topCenter, end: Alignment.bottomCenter,
                          colors: [Colors.transparent, _bg.withValues(alpha: 0.55)])),
                    )),
                    Positioned(top: 12, left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _bg.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _accent.withValues(alpha: 0.35)),
                        ),
                        child: Text(s['tag'] as String,
                            style: GoogleFonts.notoSansKr(
                                fontSize: 11, color: _accent, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s['name'] as String,
                        style: GoogleFonts.notoSansKr(
                            fontSize: 16, fontWeight: FontWeight.w700, color: _t1),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Row(children: [
                      Icon(Icons.location_on, color: _accent, size: 13),
                      const SizedBox(width: 3),
                      Text(s['distance'] as String,
                          style: GoogleFonts.notoSansKr(
                              fontSize: 12, color: _accent, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(s['sub'] as String,
                          style: GoogleFonts.notoSansKr(fontSize: 12, color: _t3),
                          maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ]),
                    const SizedBox(height: 14),
                    Row(children: [
                      Expanded(child: _callBtn()),
                      const SizedBox(width: 10),
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
  // 퀵 기능 — 4칸
  // ══════════════════════════════════════════════════════════════
  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 28, 16, 0),
      child: Row(
        children: _quickItems.asMap().entries.map((e) {
          final item = e.value;
          final bgColor = item['color'] as Color;
          final aColor = item['aColor'] as Color;
          return Expanded(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.fromLTRB(4, 24, 4, 24),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: aColor.withValues(alpha: 0.35)),
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.2),
                      border: Border.all(color: aColor.withValues(alpha: 0.4)),
                    ),
                    child: Icon(item['icon'] as IconData, color: aColor, size: 30),
                  ),
                  const SizedBox(height: 14),
                  Text(item['label'] as String,
                      style: GoogleFonts.notoSansKr(
                          fontSize: 12, color: aColor, height: 1.35,
                          fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center),
                ]),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // 지도 미리보기
  // ══════════════════════════════════════════════════════════════
  Widget _buildMapPreview() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 28, 16, 0),
      height: 230,
      decoration: BoxDecoration(
        color: const Color(0xFF050E1E),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _br.withValues(alpha: 0.4)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(children: [
          Positioned.fill(child: CustomPaint(painter: _NavyGridPainter())),
          Positioned.fill(child: Image.asset('assets/images/map_sample.png',
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => const SizedBox())),
          Positioned.fill(
              child: Container(color: Colors.black.withValues(alpha: 0.45))),
          Positioned.fill(child: Center(child: Container(
            width: 22, height: 22,
            decoration: BoxDecoration(
              color: _accent, shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: _accent.withValues(alpha: 0.3), blurRadius: 0, spreadRadius: 7),
                BoxShadow(color: _accent.withValues(alpha: 0.15), blurRadius: 0, spreadRadius: 16),
              ],
            ),
          ))),
          _mapPin(left: 55, top: 60, emoji: '🔧'),
          _mapPin(right: 60, top: 45, emoji: '🚗'),
          _mapPin(left: 75, bottom: 55, emoji: '⛽'),
          _mapPin(right: 45, bottom: 48, emoji: '🏢'),
          Positioned(left: 16, right: 16, bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
              decoration: BoxDecoration(
                color: _bg.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _br.withValues(alpha: 0.5)),
              ),
              child: Row(children: [
                Text('📍  반경 5km 이내',
                    style: GoogleFonts.notoSansKr(fontSize: 14, color: _t2)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: _accentS, borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _accent.withValues(alpha: 0.4)),
                  ),
                  child: Text('10개 업체',
                      style: GoogleFonts.notoSansKr(
                          fontSize: 13, color: _accent, fontWeight: FontWeight.w700)),
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
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: _bg.withValues(alpha: 0.85), shape: BoxShape.circle,
          border: Border.all(color: _accent.withValues(alpha: 0.4)),
        ),
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // 인근 점포 — 2배 크기 (360px 폭, 가로 슬라이드)
  // ══════════════════════════════════════════════════════════════
  Widget _buildNearbySection() {
    const double cardW = 360;
    const double imgH  = 210;
    const double cardH = 350;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(18, 28, 18, 18),
        child: _sectionHeader('📍  인근 점포', '더보기'),
      ),
      SizedBox(
        height: cardH,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _nearbyStores.length,
          itemBuilder: (_, i) {
            final s = _nearbyStores[i];
            final dist = s['distLabel'] as String? ?? '';
            return Container(
              width: cardW,
              margin: EdgeInsets.only(right: i < _nearbyStores.length - 1 ? 16 : 0),
              decoration: BoxDecoration(
                color: _s1,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: _br.withValues(alpha: 0.5)),
                boxShadow: [BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                  child: Stack(children: [
                    SizedBox(
                      width: double.infinity, height: imgH,
                      child: Image.asset(s['image'] as String, fit: BoxFit.cover,
                          errorBuilder: (c, e, st) => Container(
                              color: _s2,
                              child: Center(child: Text(s['emoji'] as String,
                                  style: const TextStyle(fontSize: 80))))),
                    ),
                    Positioned.fill(child: Container(
                      decoration: BoxDecoration(gradient: LinearGradient(
                          begin: Alignment.topCenter, end: Alignment.bottomCenter,
                          colors: [Colors.transparent, _bg.withValues(alpha: 0.5)])),
                    )),
                    Positioned(top: 14, left: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _bg.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _accent.withValues(alpha: 0.35)),
                        ),
                        child: Text(s['badge'] as String,
                            style: GoogleFonts.notoSansKr(
                                fontSize: 12, color: _accent, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s['name'] as String,
                        style: GoogleFonts.notoSansKr(
                            fontSize: 18, fontWeight: FontWeight.w700, color: _t1),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 7),
                    Row(children: [
                      Icon(Icons.location_on, color: _accent, size: 15),
                      const SizedBox(width: 3),
                      Text(dist.isNotEmpty ? dist : s['sub'] as String,
                          style: GoogleFonts.notoSansKr(
                              fontSize: 13, color: _accent, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(s['sub'] as String,
                          style: GoogleFonts.notoSansKr(fontSize: 13, color: _t3),
                          maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ]),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(child: _callBtn()),
                      const SizedBox(width: 10),
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
  // 프로모 밴드
  // ══════════════════════════════════════════════════════════════
  Widget _buildPromoBand() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 28, 16, 0),
      height: 116,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF071428), Color(0xFF0D2040), Color(0xFF071428)],
        ),
        border: Border.all(color: _accentS.withValues(alpha: 0.5)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(children: [
          Positioned(right: -20, top: -20,
            child: Container(width: 140, height: 140,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _accent.withValues(alpha: 0.06)))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            child: Row(children: [
              Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: _accent.withValues(alpha: 0.3)),
                  ),
                  child: Text('한국자동차협회 KAA',
                      style: GoogleFonts.notoSansKr(
                          fontSize: 11, color: _accent, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 9),
                Text('인증서 발급 신청하러가기',
                    style: GoogleFonts.notoSansKr(
                        fontSize: 16, fontWeight: FontWeight.w800, color: _t1)),
              ])),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentS, foregroundColor: _accent,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: _accent.withValues(alpha: 0.4)),
                  ),
                  elevation: 0,
                ),
                child: Text('신청하기',
                    style: GoogleFonts.notoSansKr(
                        fontSize: 14, color: _accent, fontWeight: FontWeight.w700)),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // 최근 본 점포 — 추천점포와 동일 크기 (270px)
  // ══════════════════════════════════════════════════════════════
  Widget _buildRecentSection() {
    const double cardW = 270;
    const double imgH  = 165;
    const double cardH = 305;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(18, 28, 18, 18),
        child: _sectionHeader('🕐  최근 본 점포', '더보기'),
      ),
      SizedBox(
        height: cardH,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _recentStores.length,
          itemBuilder: (_, i) {
            final s = _recentStores[i];
            return Container(
              width: cardW,
              margin: EdgeInsets.only(right: i < _recentStores.length - 1 ? 16 : 0),
              decoration: BoxDecoration(
                color: _s1,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: _br.withValues(alpha: 0.5)),
                boxShadow: [BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                  child: SizedBox(
                    width: double.infinity, height: imgH,
                    child: Image.asset(s['image'] as String, fit: BoxFit.cover,
                        errorBuilder: (c, e, st) => Container(
                            color: _s2,
                            child: Center(child: Text(s['emoji'] as String,
                                style: const TextStyle(fontSize: 64))))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s['name'] as String,
                        style: GoogleFonts.notoSansKr(
                            fontSize: 16, fontWeight: FontWeight.w700, color: _t1),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Text(s['sub'] as String,
                        style: GoogleFonts.notoSansKr(fontSize: 13, color: _t3),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 14),
                    Row(children: [
                      Expanded(child: _callBtn()),
                      const SizedBox(width: 10),
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
  // 가까운 점포순 — 전체폭 대형카드 (7개씩 로딩)
  // ══════════════════════════════════════════════════════════════
  Widget _buildCloseSection() {
    final loadCount = (_closeLoadedPage * _pageSize).clamp(0, _allCloseStores.length);
    final list = _allCloseStores.take(loadCount).toList();
    final canLoadMore = loadCount < _allCloseStores.length;
    final isLastPage  = loadCount >= _allCloseStores.length;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(18, 28, 18, 18),
        child: _sectionHeader('📍  가까운 점포순', null),
      ),
      ...list.asMap().entries.map((e) {
        final s = e.value;
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
          decoration: BoxDecoration(
            color: _s1,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _br.withValues(alpha: 0.5)),
            boxShadow: [BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              child: Stack(children: [
                SizedBox(
                  width: double.infinity, height: 210,
                  child: Image.asset(s['image'] as String, fit: BoxFit.cover,
                      errorBuilder: (c, e2, st) => Container(
                          color: _s2,
                          child: Center(child: Text(s['emoji'] as String,
                              style: const TextStyle(fontSize: 80))))),
                ),
                Positioned.fill(child: Container(
                  decoration: BoxDecoration(gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [Colors.transparent, _bg.withValues(alpha: 0.5)])),
                )),
                Positioned(top: 14, left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _bg.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _accent.withValues(alpha: 0.35)),
                    ),
                    child: Text(s['badge'] as String,
                        style: GoogleFonts.notoSansKr(
                            fontSize: 12, color: _accent, fontWeight: FontWeight.w700)),
                  ),
                ),
                Positioned(top: 14, right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _bg.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.location_on, color: _accent, size: 13),
                      const SizedBox(width: 3),
                      Text(s['distance'] as String,
                          style: GoogleFonts.notoSansKr(
                              fontSize: 12, color: _accent, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s['name'] as String,
                    style: GoogleFonts.notoSansKr(
                        fontSize: 18, fontWeight: FontWeight.w700, color: _t1),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Text(s['sub'] as String,
                    style: GoogleFonts.notoSansKr(fontSize: 14, color: _t3)),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: _callBtn()),
                  const SizedBox(width: 12),
                  Expanded(child: _navBtn()),
                ]),
              ]),
            ),
          ]),
        );
      }).toList(),

      // 더보기 버튼
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: GestureDetector(
          onTap: () {
            if (canLoadMore) setState(() => _closeLoadedPage++);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: _s2,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _br.withValues(alpha: 0.5)),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(
                isLastPage ? Icons.check_circle_outline : Icons.keyboard_arrow_down_rounded,
                color: isLastPage ? _t3 : _t2, size: 26,
              ),
              const SizedBox(width: 9),
              Text(
                isLastPage
                    ? '모든 점포를 불러왔습니다'
                    : '다음 ${(_allCloseStores.length - loadCount).clamp(0, _pageSize)}개 더 보기',
                style: GoogleFonts.notoSansKr(
                    fontSize: 15,
                    color: isLastPage ? _t3 : _t1,
                    fontWeight: FontWeight.w600),
              ),
            ]),
          ),
        ),
      ),
    ]);
  }

  // ══════════════════════════════════════════════════════════════
  // 하단 업체정보 — 배달의민족 레이아웃 + KAA 실제 정보
  // ══════════════════════════════════════════════════════════════
  Widget _buildCompanySection() {
    return Container(
      color: const Color(0xFF010814),
      margin: const EdgeInsets.only(top: 28),
      child: Column(children: [

        // ── 전용 혜택 배너 (민트/청록 배너) ─────────────────────
        GestureDetector(
          onTap: () {},
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            color: const Color(0xFF062030),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('🎁  MOINCAR 회원 전용 혜택 있어요!',
                  style: GoogleFonts.notoSansKr(
                      fontSize: 14, fontWeight: FontWeight.w700, color: _accent)),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded, color: _accent, size: 20),
            ]),
          ),
        ),

        Container(height: 1, color: _br.withValues(alpha: 0.3)),

        // ── 링크 & 정보 영역 ──────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // 링크 행 1
            _linkRow(['사업자정보확인', '이용약관', '전자금융거래이용약관']),
            const SizedBox(height: 9),
            // 링크 행 2
            _linkRow(['개인정보처리방침', '리뷰운영정책', '데이터제공정책']),
            const SizedBox(height: 9),
            // 링크 행 3
            _linkRow(['소비자분쟁해결기준']),

            const SizedBox(height: 22),
            Container(height: 1, color: _br.withValues(alpha: 0.25)),
            const SizedBox(height: 20),

            // 회사명
            Text('(사)한국자동차협회',
                style: GoogleFonts.notoSansKr(
                    fontSize: 14, fontWeight: FontWeight.w800, color: _t2)),
            const SizedBox(height: 14),

            // 상세정보 테이블
            _infoRow('대표이사',      '사무총장 성기정'),
            _infoRow('사업자등록번호', '114-82-05386'),
            _infoRow('통신판매업',    '제 2016-서울성동-01043호'),
            _infoRow('이메일',        'kaa21@kaa21.or.kr'),
            _infoRow('주소',          '서울 성동구 자동차시장1길 70 (용답동)'),
            _infoRow('대표전화',      '02-3482-7433'),

            const SizedBox(height: 20),
            Container(height: 1, color: _br.withValues(alpha: 0.25)),
            const SizedBox(height: 18),

            // 고객센터
            Text('대표 고객센터',
                style: GoogleFonts.notoSansKr(
                    fontSize: 13, fontWeight: FontWeight.w700, color: _t2)),
            const SizedBox(height: 10),
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Text('02-3482-7433',
                  style: GoogleFonts.notoSansKr(
                      fontSize: 14, color: _t2, fontWeight: FontWeight.w600)),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _s2, borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _br.withValues(alpha: 0.5)),
                ),
                child: Text('평일 운영',
                    style: GoogleFonts.notoSansKr(fontSize: 11, color: _t3)),
              ),
            ]),
            const SizedBox(height: 6),
            Text('AM 10:00 ~ PM 17:00  (점심 12:00~13:00)',
                style: GoogleFonts.notoSansKr(fontSize: 12, color: _t3)),
            const SizedBox(height: 4),
            Text('주말 및 공휴일 휴무',
                style: GoogleFonts.notoSansKr(fontSize: 12, color: _t3.withValues(alpha: 0.7))),

            const SizedBox(height: 20),
            Container(height: 1, color: _br.withValues(alpha: 0.25)),
            const SizedBox(height: 18),

            // SNS 링크
            Text('공식 채널',
                style: GoogleFonts.notoSansKr(
                    fontSize: 12, color: _t3, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(children: [
              _snsBadge('IN', const Color(0xFFE1306C)),
              const SizedBox(width: 12),
              _snsBadge('YT', const Color(0xFFFF0000)),
              const SizedBox(width: 12),
              _snsBadge('FB', const Color(0xFF1877F2)),
              const SizedBox(width: 12),
              _snsBadge('KT', const Color(0xFFFEE500)),
              const SizedBox(width: 12),
              _snsBadge('N', const Color(0xFF03C75A)),
            ]),

            const SizedBox(height: 20),
            Container(height: 1, color: _br.withValues(alpha: 0.2)),
            const SizedBox(height: 16),

            // 법적고지
            Text(
              '(사)한국자동차협회는 통신판매중개자로 거래 당사자가 아니므로,\n'
              '판매자가 등록한 상품 및 거래에 대해 책임을 지지 않습니다.\n'
              '단, (사)한국자동차협회가 판매자로 등록한 상품은\n'
              '판매자로서 책임을 부담합니다.',
              style: GoogleFonts.notoSansKr(
                  fontSize: 11, color: _t3.withValues(alpha: 0.65), height: 1.9),
            ),

            const SizedBox(height: 16),
            Container(height: 1, color: _br.withValues(alpha: 0.2)),
            const SizedBox(height: 14),

            // 저작권 + 이동리워드 칩
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(
                child: Text('ⓒ 한국자동차협회 All Rights Reserved.',
                    style: GoogleFonts.notoSansKr(
                        fontSize: 11, color: _t3.withValues(alpha: 0.5))),
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1040),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFF6B4EFF).withValues(alpha: 0.5)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.card_giftcard_outlined,
                        size: 14, color: Color(0xFF9B7CFF)),
                    const SizedBox(width: 6),
                    Text('이동리워드',
                        style: GoogleFonts.notoSansKr(
                            fontSize: 12,
                            color: const Color(0xFF9B7CFF),
                            fontWeight: FontWeight.w700)),
                  ]),
                ),
              ),
            ]),
            const SizedBox(height: 8),
          ]),
        ),
      ]),
    );
  }

  // ── 헬퍼 위젯들 ───────────────────────────────────────────────
  Widget _linkRow(List<String> items) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (int i = 0; i < items.length; i++) ...[
          GestureDetector(
            onTap: () {},
            child: Text(items[i],
                style: GoogleFonts.notoSansKr(fontSize: 13, color: _t3)),
          ),
          if (i < items.length - 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text('|', style: GoogleFonts.notoSansKr(fontSize: 12, color: _br)),
            ),
        ],
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 112,
          child: Text(label,
              style: GoogleFonts.notoSansKr(fontSize: 12, color: _t3)),
        ),
        Expanded(
          child: Text(value,
              style: GoogleFonts.notoSansKr(
                  fontSize: 12, color: _t2, fontWeight: FontWeight.w500)),
        ),
      ]),
    );
  }

  Widget _snsBadge(String label, Color color) {
    return Container(
      width: 42, height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Center(child: Text(label,
          style: GoogleFonts.notoSansKr(
              fontSize: 12, color: color, fontWeight: FontWeight.w800))),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // 위치 검색 팝업
  // ══════════════════════════════════════════════════════════════
  void _showLocationSearch() {
    final ctrl = TextEditingController();
    List<Map<String, dynamic>> results = [];
    final List<Map<String, dynamic>> db = [
      {'name': '서울 강남구 역삼동',     'lat': 37.5013, 'lng': 127.0398},
      {'name': '서울 강남구 삼성동',     'lat': 37.5140, 'lng': 127.0571},
      {'name': '서울 서초구 서초동',     'lat': 37.4923, 'lng': 127.0092},
      {'name': '서울 마포구 합정동',     'lat': 37.5503, 'lng': 126.9136},
      {'name': '서울 종로구 종로동',     'lat': 37.5730, 'lng': 126.9794},
      {'name': '서울 송파구 잠실동',     'lat': 37.5145, 'lng': 127.1059},
      {'name': '서울 영등포구 여의도동', 'lat': 37.5219, 'lng': 126.9245},
      {'name': '부산 해운대구 해운대동', 'lat': 35.1628, 'lng': 129.1635},
      {'name': '부산 부산진구 서면동',   'lat': 35.1584, 'lng': 129.0591},
      {'name': '대구 수성구 범어동',     'lat': 35.8562, 'lng': 128.6314},
      {'name': '대구 중구 동성로',       'lat': 35.8714, 'lng': 128.5944},
      {'name': '인천 남동구 구월동',     'lat': 37.4490, 'lng': 126.7311},
      {'name': '광주 서구 치평동',       'lat': 35.1540, 'lng': 126.8476},
      {'name': '대전 서구 둔산동',       'lat': 36.3504, 'lng': 127.3845},
      {'name': '울산 남구 삼산동',       'lat': 35.5381, 'lng': 129.3114},
      {'name': '수원 팔달구 인계동',     'lat': 37.2637, 'lng': 127.0286},
    ];
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: _s1,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setM) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75, maxChildSize: 0.95, minChildSize: 0.5,
          builder: (_, sc) => Padding(
            padding: EdgeInsets.only(
                left: 16, right: 16, top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: _br, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Text('위치 검색',
                  style: GoogleFonts.notoSansKr(
                      fontSize: 18, fontWeight: FontWeight.w800, color: _t1)),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl, autofocus: true,
                style: GoogleFonts.notoSansKr(color: _t1),
                decoration: InputDecoration(
                  hintText: '동네 이름을 입력하세요',
                  hintStyle: GoogleFonts.notoSansKr(fontSize: 14, color: _t3),
                  prefixIcon: Icon(Icons.search, color: _t3),
                  filled: true, fillColor: _s2,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _br)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _br)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _accent)),
                ),
                onChanged: (v) {
                  final q = v.trim();
                  setM(() => results = q.isEmpty
                      ? []
                      : db.where((a) =>
                          (a['name'] as String).contains(q)).toList());
                },
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  _initLocation();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _accent.withValues(alpha: 0.25)),
                  ),
                  child: Row(children: [
                    Icon(Icons.my_location, color: _accent, size: 18),
                    const SizedBox(width: 8),
                    Text('현재 내 위치로',
                        style: GoogleFonts.notoSansKr(
                            fontSize: 14, color: _accent, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: results.isEmpty
                    ? Center(
                        child: Text(
                            ctrl.text.isEmpty ? '동네 이름을 입력하세요' : '검색 결과 없음',
                            style: GoogleFonts.notoSansKr(fontSize: 14, color: _t3)))
                    : ListView.separated(
                        controller: sc,
                        itemCount: results.length,
                        separatorBuilder: (_, __) => Divider(height: 1, color: _br),
                        itemBuilder: (_, i) {
                          final r = results[i];
                          return ListTile(
                            leading: Icon(Icons.location_on_outlined, color: _accent),
                            title: Text(r['name'] as String,
                                style: GoogleFonts.notoSansKr(
                                    fontSize: 14, fontWeight: FontWeight.w600, color: _t1)),
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
      Text(title,
          style: GoogleFonts.notoSansKr(
              fontSize: 20, fontWeight: FontWeight.w800, color: _t1)),
      if (action != null)
        GestureDetector(
          onTap: () {},
          child: Text(action,
              style: GoogleFonts.notoSansKr(fontSize: 14, color: _accent)),
        ),
    ]);
  }

  Widget _callBtn() => GestureDetector(
    onTap: () {},
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: _accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _accent.withValues(alpha: 0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.phone_outlined, size: 15, color: _accent),
        const SizedBox(width: 5),
        Text('전화', style: GoogleFonts.notoSansKr(
            fontSize: 14, color: _accent, fontWeight: FontWeight.w600)),
      ]),
    ),
  );

  Widget _navBtn() => GestureDetector(
    onTap: () {},
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: _accentS,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _accent.withValues(alpha: 0.35)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.navigation_outlined, size: 15, color: _t2),
        const SizedBox(width: 5),
        Text('길찾기', style: GoogleFonts.notoSansKr(
            fontSize: 14, color: _t2, fontWeight: FontWeight.w600)),
      ]),
    ),
  );
}

// ── 군청색 격자 배경 페인터 ──────────────────────────────────────
class _NavyGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        Offset.zero & size, Paint()..color = const Color(0xFF050E1E));
    final p = Paint()
      ..color = const Color(0xFF142244).withValues(alpha: 0.5)
      ..strokeWidth = 0.5;
    const sp = 28.0;
    for (double x = 0; x < size.width; x += sp) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += sp) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
    final road = Paint()
      ..color = const Color(0xFF1A3A6E).withValues(alpha: 0.35)
      ..strokeWidth = 3;
    canvas.drawLine(
        Offset(0, size.height * 0.5), Offset(size.width, size.height * 0.5), road);
    canvas.drawLine(
        Offset(size.width * 0.4, 0), Offset(size.width * 0.4, size.height), road);
  }
  @override bool shouldRepaint(_) => false;
}
