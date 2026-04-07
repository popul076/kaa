import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../widgets/bottom_nav.dart';

// ═══════════════════════════════════════════════════════════════
// MOINCAR Home Screen v24.0.0
// ─ 상단바: 스크롤 시 전체 올라감 / 위치띠만 sticky
// ─ 배너 230px, 콘텐츠 top padding 동적 계산(겹침 없음)
// ─ 카테고리: 3×3 그리드 (한 화면에 모두 표시)
// ─ 추천점포: 진짜 무한 캐러셀 (큰배수 initialPage, 6초)
// ─ 하단 BottomNav: 스크롤 중 숨김, 정지 후 나타남
// ─ 하단 업체정보: 배달의민족 스타일 + KAA 실제정보 (딱맞는 크기)
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

  // ── 상단 레이아웃 고정값 ─────────────────────────────────────
  static const double _topBarH = 56.0;   // 로고+검색 영역 높이
  static const double _locBarH = 40.0;   // 위치띠 높이
  // 로고바가 올라갈 최대치 = _topBarH (완전히 사라짐)
  // 위치띠는 로고바와 함께 올라가다가 로고바가 다 올라가면 화면 최상단에 붙음

  // ── 스크롤 ───────────────────────────────────────────────────
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  // BottomNav 숨김/표시 (스크롤 정지 감지)
  bool _navVisible = true;
  Timer? _navTimer;

  // ── 위치 ─────────────────────────────────────────────────────
  String _currentAddress = '위치 확인 중...';
  double _currentLat = 35.8562;
  double _currentLng = 128.6314;

  // ── 배너 (무한 캐러셀) ────────────────────────────────────────
  // 진짜 무한: 큰 배수 initialPage 사용
  static const int _bannerMultiplier = 500; // 충분히 큰 배수
  int _currentBannerIndex = 0;              // 0-based 실제 인덱스
  late PageController _bannerController;
  Timer? _bannerTimer;

  final List<Map<String, dynamic>> _bannerData = [
    {'tag': 'MOINCAR 인증', 'title': '인증점포\n할인 이벤트',      'sub': '인증 점포 방문 시 10% 할인',    'emoji': '🏆'},
    {'tag': '중고차',       'title': '내 차 시세\n무료 확인',       'sub': '전국 딜러 실시간 견적 비교',    'emoji': '🚗'},
    {'tag': '자동차 소식',  'title': '중고차 성능점검\n수요 확대',  'sub': '사고이력·성능점검표 확인 필수', 'emoji': '📰'},
    {'tag': '무료 서비스',  'title': '긴급 출동\n즉시 연결',        'sub': '24시간 긴급출동 서비스',        'emoji': '🚨'},
    {'tag': 'AI 진단',      'title': 'AI 무료\n차량 진단',          'sub': '스마트 AI로 내 차 상태 확인',   'emoji': '🤖'},
    {'tag': '이동리워드',   'title': '이동할수록\n적립되는 리워드', 'sub': '주행 거리당 포인트 지급',       'emoji': '🎁'},
  ];

  // 무한 캐러셀: 전체 길이 = 배너 개수 × multiplier
  int get _infiniteCount => _bannerData.length * _bannerMultiplier;

  // 중간 시작 지점
  int get _initialPage => (_bannerMultiplier ~/ 2) * _bannerData.length;

  // ── 카테고리 (3×3 그리드) ───────────────────────────────────
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

  // ── 퀵 기능 (이동리워드 포함) ───────────────────────────────
  final List<Map<String, dynamic>> _quickItems = [
    {'icon': Icons.local_fire_department_outlined, 'label': '긴급\n출동',   'color': Color(0xFF7B1E2A), 'aColor': Color(0xFFFF6B6B)},
    {'icon': Icons.price_change_outlined,           'label': '내 차\n시세',  'color': Color(0xFF0D2A4A), 'aColor': Color(0xFF4FC3F7)},
    {'icon': Icons.newspaper_outlined,              'label': '자동차\n뉴스', 'color': Color(0xFF0A1E3A), 'aColor': Color(0xFF4FC3F7)},
    {'icon': Icons.card_giftcard_outlined,          'label': '이동\n리워드', 'color': Color(0xFF1A1040), 'aColor': Color(0xFF9B7CFF)},
  ];

  // ── 추천 점포 (6개로 확장) ────────────────────────────────────
  final List<Map<String, dynamic>> _stores = [
    {'tag': 'MOINCAR 인증', 'name': '강남자동차정비센터',  'distance': '1.8km', 'sub': '엔진·미션·판금 전문',   'image': 'assets/images/store_repair.jpg',  'emoji': '🔧'},
    {'tag': '인증중고차',    'name': '서울모터스홀딩스',    'distance': '2.4km', 'sub': '수입차·국산차 전문',   'image': 'assets/images/store_carwash.jpg', 'emoji': '🚗'},
    {'tag': '공식딜러',      'name': '현대자동차 강남점',   'distance': '3.0km', 'sub': '신차·인증중고·시승',   'image': 'assets/images/nearby3.jpg',       'emoji': '🏢'},
    {'tag': 'MOINCAR 인증', 'name': '프리미엄 세차코팅',   'distance': '3.5km', 'sub': '손세차·광택·코팅',     'image': 'assets/images/nearby1.jpg',       'emoji': '🫧'},
    {'tag': 'AI 진단',       'name': 'AI 진단 정비센터',   'distance': '4.2km', 'sub': 'AI 무료 차량 진단',    'image': 'assets/images/store_repair.jpg',  'emoji': '🤖'},
    {'tag': '이동리워드',    'name': '리워드 파트너 정비',  'distance': '5.1km', 'sub': '이동리워드 적립 가능',  'image': 'assets/images/nearby2.jpg',       'emoji': '🎁'},
  ];

  // ── 근처 점포 ────────────────────────────────────────────────
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

  // ── 가까운 점포순 (7개씩 페이지) ─────────────────────────────
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
  ];
  int _closeLoadedPage = 1;
  static const int _pageSize = 7;
  bool _closeFullyLoaded = false;

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
    final offset = _scrollController.offset;
    // 상단바 오프셋 계산 (위로 스크롤 시 올라감)
    setState(() {
      _scrollOffset = offset;
    });

    // BottomNav: 스크롤 중 숨김, 정지 후 나타남
    _navTimer?.cancel();
    if (_navVisible) {
      setState(() => _navVisible = false);
    }
    _navTimer = Timer(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _navVisible = true);
    });


  }

  // 스크롤량에 따른 상단바 오프셋 계산
  // 0 ~ _topBarH 범위 내에서 올라감
  double get _topBarSlide => _scrollOffset.clamp(0.0, _topBarH);
  // 위치띠: 상단바와 함께 올라가다가, 상단바가 다 올라가면 화면 최상단에 붙음
  double get _locBarTop => (_topBarH - _topBarSlide).clamp(0.0, _topBarH);

  // ── 위치 초기화 ──────────────────────────────────────────────
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
      final d = Geolocator.distanceBetween(_currentLat, _currentLng, s['lat'] as double, s['lng'] as double);
      s['distM'] = d;
      s['distLabel'] = d < 1000 ? '${d.toStringAsFixed(0)}m' : '${(d / 1000).toStringAsFixed(1)}km';
    }
    if (mounted) setState(() => _nearbyStores.sort((a, b) => (a['distM'] as double).compareTo(b['distM'] as double)));
  }

  // ── 무한 배너 타이머 (6초) ───────────────────────────────────
  void _startBannerTimer() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 6), (_) {
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
    setState(() {
      _currentBannerIndex = rawPage % _bannerData.length;
    });
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
  // BUILD
  // ══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    // 콘텐츠 상단 여백 = statusBar + 항상 보이는 위치띠 + topBarH (초기)
    // 스크롤 시 topBarH만큼 줄어들되 0보다 작아지지 않음
    final contentTopPad = topPad + _topBarH + _locBarH - _topBarSlide;

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // ── 메인 스크롤 콘텐츠 ──────────────────────────────
          Positioned.fill(
            child: ListView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                top: contentTopPad + 8,
                bottom: 90,
              ),
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

          // ── 상단 로고+검색바 (스크롤 시 위로 사라짐) ────────
          Positioned(
            top: topPad - _topBarSlide,
            left: 0, right: 0,
            child: _buildTopLogoBar(),
          ),

          // ── 위치띠 (로고바가 사라진 후 화면 최상단에 고정) ───
          Positioned(
            top: topPad + _locBarTop,
            left: 0, right: 0,
            child: _buildLocationBar(),
          ),
        ],
      ),
      bottomNavigationBar: AnimatedSlide(
        offset: _navVisible ? Offset.zero : const Offset(0, 1),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        child: AnimatedOpacity(
          opacity: _navVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 250),
          child: const BottomNav(activeTab: 'home'),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // 상단 로고+검색 바
  // ══════════════════════════════════════════════════════════════
  Widget _buildTopLogoBar() {
    return Container(
      height: _topBarH,
      color: const Color(0xFF030C1C),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(children: [
        // M 로고
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFF1A3A8E), Color(0xFF0D1E5A)],
            ),
            borderRadius: BorderRadius.circular(9),
            boxShadow: [BoxShadow(color: _accent.withValues(alpha: 0.3), blurRadius: 8)],
          ),
          child: Center(child: Text('M', style: GoogleFonts.notoSansKr(
              fontSize: 17, fontWeight: FontWeight.w900, color: _accent))),
        ),
        const SizedBox(width: 9),
        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('MOINCAR', style: GoogleFonts.notoSansKr(
              fontSize: 16, fontWeight: FontWeight.w900, color: _t1, letterSpacing: 2)),
          Text('mobility international car', style: GoogleFonts.notoSansKr(
              fontSize: 7.5, color: _t3, letterSpacing: 1.0)),
        ]),
        const Spacer(),
        // 검색바
        Expanded(
          flex: 3,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              height: 36,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: _s1, borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _br),
              ),
              child: Row(children: [
                const SizedBox(width: 10),
                Icon(Icons.search_rounded, color: _t3, size: 16),
                const SizedBox(width: 6),
                Expanded(child: Text('정비소, 중고차 검색...',
                    style: GoogleFonts.notoSansKr(fontSize: 11, color: _t3))),
              ]),
            ),
          ),
        ),
        // 알림
        Stack(clipBehavior: Clip.none, children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: _s1, borderRadius: BorderRadius.circular(50),
              border: Border.all(color: _br),
            ),
            child: const Icon(Icons.notifications_none_rounded, color: _t2, size: 17),
          ),
          Positioned(right: -1, top: -1,
            child: Container(
              width: 13, height: 13,
              decoration: const BoxDecoration(color: Color(0xFFE53935), shape: BoxShape.circle),
              child: const Center(child: Text('2', style: TextStyle(color: Colors.white, fontSize: 7.5, fontWeight: FontWeight.bold))),
            ),
          ),
        ]),
        const SizedBox(width: 6),
        // 프로필
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            color: _s1, borderRadius: BorderRadius.circular(50),
            border: Border.all(color: _br),
          ),
          child: const Icon(Icons.person_outline_rounded, color: _t2, size: 17),
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
          color: Color(0xFF040F22),
          boxShadow: [BoxShadow(color: Color(0x33000000), blurRadius: 4, offset: Offset(0, 2))],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(
              color: _accent, shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: _accent.withValues(alpha: 0.6), blurRadius: 6)],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.location_on_outlined, color: _accent, size: 15),
          const SizedBox(width: 4),
          Expanded(child: Text(_currentAddress,
              style: GoogleFonts.notoSansKr(fontSize: 13, color: _t2, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis)),
          Text('변경  ›', style: GoogleFonts.notoSansKr(fontSize: 11, color: _accent)),
        ]),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // 배너 — 230px 무한 캐러셀 (6초 자동)
  // ══════════════════════════════════════════════════════════════
  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 4, 14, 0),
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
                  // 배경 글로우
                  Positioned(right: -40, top: -40,
                    child: Container(
                      width: 240, height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _accent.withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                  // 이모지 (우측 큰 배경)
                  Positioned(right: 10, bottom: 20,
                    child: Opacity(
                      opacity: 0.18,
                      child: Text(b['emoji'] as String,
                          style: const TextStyle(fontSize: 130)),
                    ),
                  ),
                  // 좌측 텍스트
                  Positioned(left: 22, top: 24, bottom: 24,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      // 태그
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: _accent.withValues(alpha: 0.15),
                          border: Border.all(color: _accent.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('✨  ${b['tag']}',
                            style: GoogleFonts.notoSansKr(fontSize: 11, color: _accent, fontWeight: FontWeight.w600)),
                      ),
                      // 타이틀 + 서브
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(b['title'] as String,
                            style: GoogleFonts.notoSansKr(fontSize: 22, fontWeight: FontWeight.w900, color: _t1, height: 1.25)),
                        const SizedBox(height: 6),
                        Text(b['sub'] as String,
                            style: GoogleFonts.notoSansKr(fontSize: 12, color: _t2)),
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
        Positioned(right: 16, bottom: 12,
          child: Row(mainAxisSize: MainAxisSize.min,
            children: List.generate(_bannerData.length, (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              width: i == _currentBannerIndex ? 20 : 6, height: 6,
              margin: const EdgeInsets.only(left: 4),
              decoration: BoxDecoration(
                color: i == _currentBannerIndex ? _accent : _br,
                borderRadius: BorderRadius.circular(3),
              ),
            )),
          ),
        ),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // 카테고리 — 3×3 그리드 (한 화면에 모두 표시)
  // ══════════════════════════════════════════════════════════════
  Widget _buildCategoryGrid() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHeader('서비스', null),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 14,
            childAspectRatio: 0.9,
          ),
          itemCount: _categories.length,
          itemBuilder: (_, i) {
            final c = _categories[i];
            return GestureDetector(
              onTap: () {},
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  width: 66, height: 66,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _s1,
                    border: Border.all(color: _br, width: 1.5),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Center(
                    child: Text(c['icon'] as String,
                        style: const TextStyle(fontSize: 28)),
                  ),
                ),
                const SizedBox(height: 8),
                Text(c['name'] as String,
                    style: GoogleFonts.notoSansKr(fontSize: 12, color: _t2, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center),
              ]),
            );
          },
        ),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // 추천 점포 — 가로 슬라이드 카드 (6개)
  // ══════════════════════════════════════════════════════════════
  Widget _buildRecommendSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
        child: _sectionHeader('⭐  MOINCAR 추천 점포', '전체보기'),
      ),
      SizedBox(
        height: 270,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          itemCount: _stores.length,
          itemBuilder: (_, i) {
            final s = _stores[i];
            return Container(
              width: 230,
              margin: EdgeInsets.only(right: i < _stores.length - 1 ? 14 : 0),
              decoration: BoxDecoration(
                color: _s1,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _br.withValues(alpha: 0.5)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // 이미지
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Stack(children: [
                    SizedBox(
                      width: double.infinity, height: 140,
                      child: Image.asset(s['image'] as String, fit: BoxFit.cover,
                          errorBuilder: (c, e, st) => Container(
                              color: _s2,
                              child: Center(child: Text(s['emoji'] as String,
                                  style: const TextStyle(fontSize: 54))))),
                    ),
                    Positioned.fill(child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                            colors: [Colors.transparent, _bg.withValues(alpha: 0.55)]),
                      ),
                    )),
                    Positioned(top: 10, left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: _bg.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _accent.withValues(alpha: 0.35)),
                        ),
                        child: Text(s['tag'] as String,
                            style: GoogleFonts.notoSansKr(fontSize: 10, color: _accent, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ]),
                ),
                // 정보
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s['name'] as String,
                        style: GoogleFonts.notoSansKr(fontSize: 15, fontWeight: FontWeight.w700, color: _t1),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(children: [
                      Icon(Icons.location_on, color: _accent, size: 12),
                      const SizedBox(width: 2),
                      Text(s['distance'] as String,
                          style: GoogleFonts.notoSansKr(fontSize: 11, color: _accent, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 6),
                      Expanded(child: Text(s['sub'] as String,
                          style: GoogleFonts.notoSansKr(fontSize: 11, color: _t3),
                          maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ]),
                    const SizedBox(height: 12),
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
  // 퀵 기능 — 4칸
  // ══════════════════════════════════════════════════════════════
  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 18, 14, 0),
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
                padding: const EdgeInsets.fromLTRB(4, 20, 4, 20),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: aColor.withValues(alpha: 0.3)),
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 54, height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.2),
                      border: Border.all(color: aColor.withValues(alpha: 0.35)),
                    ),
                    child: Icon(item['icon'] as IconData, color: aColor, size: 26),
                  ),
                  const SizedBox(height: 10),
                  Text(item['label'] as String,
                      style: GoogleFonts.notoSansKr(fontSize: 11, color: aColor, height: 1.3, fontWeight: FontWeight.w600),
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
      margin: const EdgeInsets.fromLTRB(14, 18, 14, 0),
      height: 210,
      decoration: BoxDecoration(
        color: const Color(0xFF050E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _br.withValues(alpha: 0.4)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(children: [
          Positioned.fill(child: CustomPaint(painter: _NavyGridPainter())),
          Positioned.fill(child: Image.asset('assets/images/map_sample.png', fit: BoxFit.cover,
              errorBuilder: (c, e, s) => const SizedBox())),
          Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.45))),
          Positioned.fill(child: Center(child: Container(
            width: 18, height: 18,
            decoration: BoxDecoration(
              color: _accent, shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: _accent.withValues(alpha: 0.25), blurRadius: 0, spreadRadius: 5),
                BoxShadow(color: _accent.withValues(alpha: 0.12), blurRadius: 0, spreadRadius: 12),
              ],
            ),
          ))),
          _mapPin(left: 55, top: 60, emoji: '🔧'),
          _mapPin(right: 60, top: 45, emoji: '🚗'),
          _mapPin(left: 75, bottom: 55, emoji: '⛽'),
          _mapPin(right: 45, bottom: 48, emoji: '🏢'),
          Positioned(left: 14, right: 14, bottom: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _bg.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _br.withValues(alpha: 0.5)),
              ),
              child: Row(children: [
                Text('📍  반경 5km 이내', style: GoogleFonts.notoSansKr(fontSize: 12, color: _t2)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: _accentS, borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _accent.withValues(alpha: 0.4)),
                  ),
                  child: Text('10개 업체', style: GoogleFonts.notoSansKr(fontSize: 11, color: _accent, fontWeight: FontWeight.w700)),
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
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: _bg.withValues(alpha: 0.8), shape: BoxShape.circle,
          border: Border.all(color: _accent.withValues(alpha: 0.4)),
        ),
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 16))),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // 인근 점포 — 가로 슬라이드
  // ══════════════════════════════════════════════════════════════
  Widget _buildNearbySection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
        child: _sectionHeader('📍  인근 점포', '더보기'),
      ),
      SizedBox(
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          itemCount: _nearbyStores.length,
          itemBuilder: (_, i) {
            final s = _nearbyStores[i];
            final dist = s['distLabel'] as String? ?? s['sub'] as String? ?? '';
            return Container(
              width: 180,
              margin: EdgeInsets.only(right: i < _nearbyStores.length - 1 ? 12 : 0),
              decoration: BoxDecoration(
                color: _s1, borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _br.withValues(alpha: 0.5)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8)],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  child: Stack(children: [
                    SizedBox(
                      width: double.infinity, height: 100,
                      child: Image.asset(s['image'] as String, fit: BoxFit.cover,
                          errorBuilder: (c, e, st) => Container(
                              color: _s2,
                              child: Center(child: Text(s['emoji'] as String,
                                  style: const TextStyle(fontSize: 40))))),
                    ),
                    Positioned(top: 8, left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _bg.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _accent.withValues(alpha: 0.3)),
                        ),
                        child: Text(s['badge'] as String,
                            style: GoogleFonts.notoSansKr(fontSize: 9, color: _accent, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s['name'] as String,
                        style: GoogleFonts.notoSansKr(fontSize: 13, fontWeight: FontWeight.w700, color: _t1),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Row(children: [
                      Icon(Icons.location_on, color: _accent, size: 11),
                      const SizedBox(width: 2),
                      Text(dist, style: GoogleFonts.notoSansKr(fontSize: 11, color: _accent, fontWeight: FontWeight.w600)),
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
      margin: const EdgeInsets.fromLTRB(14, 18, 14, 0),
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF071428), Color(0xFF0D2040), Color(0xFF071428)],
        ),
        border: Border.all(color: _accentS.withValues(alpha: 0.5)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(children: [
          Positioned(right: -20, top: -20,
            child: Container(width: 120, height: 120,
                decoration: BoxDecoration(shape: BoxShape.circle, color: _accent.withValues(alpha: 0.06)))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: _accent.withValues(alpha: 0.3)),
                  ),
                  child: Text('한국자동차협회 KAA', style: GoogleFonts.notoSansKr(fontSize: 10, color: _accent, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 7),
                Text('인증서 발급 신청하러가기', style: GoogleFonts.notoSansKr(fontSize: 14, fontWeight: FontWeight.w800, color: _t1)),
              ])),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentS, foregroundColor: _accent,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: _accent.withValues(alpha: 0.4)),
                  ),
                  elevation: 0,
                ),
                child: Text('신청하기', style: GoogleFonts.notoSansKr(fontSize: 13, color: _accent, fontWeight: FontWeight.w700)),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // 최근 본 점포
  // ══════════════════════════════════════════════════════════════
  Widget _buildRecentSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
        child: _sectionHeader('🕐  최근 본 점포', '더보기'),
      ),
      SizedBox(
        height: 270,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          itemCount: _recentStores.length,
          itemBuilder: (_, i) {
            final s = _recentStores[i];
            return Container(
              width: 230,
              margin: EdgeInsets.only(right: i < _recentStores.length - 1 ? 14 : 0),
              decoration: BoxDecoration(
                color: _s1, borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _br.withValues(alpha: 0.5)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: SizedBox(
                    width: double.infinity, height: 140,
                    child: Image.asset(s['image'] as String, fit: BoxFit.cover,
                        errorBuilder: (c, e, st) => Container(
                            color: _s2,
                            child: Center(child: Text(s['emoji'] as String,
                                style: const TextStyle(fontSize: 54))))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s['name'] as String,
                        style: GoogleFonts.notoSansKr(fontSize: 15, fontWeight: FontWeight.w700, color: _t1),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(s['sub'] as String,
                        style: GoogleFonts.notoSansKr(fontSize: 12, color: _t3),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 12),
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
  // 가까운 점포순 — 7개씩 페이지 로딩
  // ══════════════════════════════════════════════════════════════
  Widget _buildCloseSection() {
    final loadCount = (_closeLoadedPage * _pageSize).clamp(0, _allCloseStores.length);
    final list = _allCloseStores.take(loadCount).toList();
    final canLoadMore = loadCount < _allCloseStores.length && !_closeFullyLoaded;
    final isLastPage = loadCount >= _allCloseStores.length;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
        child: _sectionHeader('📍  가까운 점포순', null),
      ),
      ...list.asMap().entries.map((e) {
        final s = e.value;
        return Container(
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          height: 230,
          decoration: BoxDecoration(
            color: _s1, borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _br.withValues(alpha: 0.5)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Stack(children: [
                SizedBox(
                  width: double.infinity, height: 130,
                  child: Image.asset(s['image'] as String, fit: BoxFit.cover,
                      errorBuilder: (c, e2, st) => Container(
                          color: _s2,
                          child: Center(child: Text(s['emoji'] as String,
                              style: const TextStyle(fontSize: 50))))),
                ),
                Positioned.fill(child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        colors: [Colors.transparent, _bg.withValues(alpha: 0.5)]),
                  ),
                )),
                Positioned(top: 10, left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: _bg.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _accent.withValues(alpha: 0.35)),
                    ),
                    child: Text(s['badge'] as String,
                        style: GoogleFonts.notoSansKr(fontSize: 10, color: _accent, fontWeight: FontWeight.w700)),
                  ),
                ),
                Positioned(top: 10, right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: _bg.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.location_on, color: _accent, size: 11),
                      const SizedBox(width: 2),
                      Text(s['distance'] as String,
                          style: GoogleFonts.notoSansKr(fontSize: 10, color: _accent, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s['name'] as String,
                      style: GoogleFonts.notoSansKr(fontSize: 15, fontWeight: FontWeight.w700, color: _t1),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(s['sub'] as String,
                      style: GoogleFonts.notoSansKr(fontSize: 12, color: _t3)),
                ])),
                const SizedBox(width: 12),
                Row(children: [
                  _callBtn(),
                  const SizedBox(width: 8),
                  _navBtn(),
                ]),
              ]),
            ),
          ]),
        );
      }).toList(),

      if (canLoadMore || isLastPage)
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
          child: GestureDetector(
            onTap: () {
              if (!isLastPage) {
                setState(() => _closeLoadedPage++);
              } else {
                setState(() => _closeFullyLoaded = true);
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _s2, borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _br.withValues(alpha: 0.5)),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(
                  isLastPage ? Icons.check_circle_outline : Icons.keyboard_arrow_down_rounded,
                  color: isLastPage ? _t3 : _t2, size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  isLastPage
                      ? '모든 점포를 불러왔습니다'
                      : '다음 ${(_allCloseStores.length - loadCount).clamp(0, _pageSize)}개 더 보기',
                  style: GoogleFonts.notoSansKr(
                      fontSize: 14, color: isLastPage ? _t3 : _t1, fontWeight: FontWeight.w600),
                ),
              ]),
            ),
          ),
        ),
    ]);
  }

  // ══════════════════════════════════════════════════════════════
  // 하단 업체정보 — 배달의민족 스타일 + KAA 실제정보 (딱맞는 크기)
  // ══════════════════════════════════════════════════════════════
  Widget _buildCompanySection() {
    return Container(
      color: const Color(0xFF010610),
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── MOINCAR 회원 전용 혜택 배너 ───────────────────────────
        GestureDetector(
          onTap: () {},
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 13),
            margin: const EdgeInsets.only(bottom: 18),
            decoration: BoxDecoration(
              color: const Color(0xFF0A1E3A),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _accent.withValues(alpha: 0.3)),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('MOINCAR 회원 전용 혜택 있어요!',
                  style: GoogleFonts.notoSansKr(fontSize: 14, fontWeight: FontWeight.w700, color: _accent)),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded, color: _accent, size: 20),
            ]),
          ),
        ),

        // ── 링크 행 1 ─────────────────────────────────────────────
        _linkRow(['사업자정보확인', '이용약관', '전자금융거래이용약관']),
        const SizedBox(height: 7),
        _linkRow(['개인정보처리방침', '리뷰운영정책', '데이터제공정책']),
        const SizedBox(height: 7),
        _linkRow(['소비자분쟁해결기준']),

        const SizedBox(height: 18),
        Container(height: 1, color: _br.withValues(alpha: 0.3)),
        const SizedBox(height: 16),

        // ── 회사명 ────────────────────────────────────────────────
        Text('(사)한국자동차협회',
            style: GoogleFonts.notoSansKr(fontSize: 13, fontWeight: FontWeight.w700, color: _t2)),
        const SizedBox(height: 10),

        // ── 상세정보 ──────────────────────────────────────────────
        _infoRow('대표이사', '사무총장 성기정'),
        _infoRow('사업자등록번호', '114-82-05386'),
        _infoRow('통신판매업', '제 2016-서울성동-01043호'),
        _infoRow('이메일', 'kaa21@kaa21.or.kr'),
        _infoRow('주소', '서울 성동구 자동차시장1길 70 (용답동)'),
        _infoRow('전자금융분쟁', 'Tel 02-3482-7433'),

        const SizedBox(height: 14),
        Container(height: 1, color: _br.withValues(alpha: 0.2)),
        const SizedBox(height: 14),

        // ── 고객센터 ──────────────────────────────────────────────
        Text('대표 고객센터',
            style: GoogleFonts.notoSansKr(fontSize: 12, fontWeight: FontWeight.w700, color: _t2)),
        const SizedBox(height: 6),
        Row(children: [
          Text('02-3482-7433', style: GoogleFonts.notoSansKr(fontSize: 11, color: _t3)),
          const SizedBox(width: 8),
          Text('AM 10:00 ~ PM 17:00', style: GoogleFonts.notoSansKr(fontSize: 11, color: _t3)),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: _s2, borderRadius: BorderRadius.circular(4),
              border: Border.all(color: _br.withValues(alpha: 0.5)),
            ),
            child: Text('평일', style: GoogleFonts.notoSansKr(fontSize: 9, color: _t3)),
          ),
        ]),

        const SizedBox(height: 14),
        Container(height: 1, color: _br.withValues(alpha: 0.2)),
        const SizedBox(height: 14),

        // ── SNS 링크 ──────────────────────────────────────────────
        Row(children: [
          _snsBadge('IN', const Color(0xFFE1306C)),
          const SizedBox(width: 8),
          _snsBadge('YT', const Color(0xFFFF0000)),
          const SizedBox(width: 8),
          _snsBadge('FB', const Color(0xFF1877F2)),
          const SizedBox(width: 8),
          _snsBadge('KT', const Color(0xFFFEE500)),
        ]),

        const SizedBox(height: 16),
        Container(height: 1, color: _br.withValues(alpha: 0.2)),
        const SizedBox(height: 12),

        // ── 법적고지 ──────────────────────────────────────────────
        Text(
          '(사)한국자동차협회는 통신판매중개자로 거래 당사자가 아니므로,\n'
          '판매자가 등록한 상품 및 거래에 대해 책임을 지지 않습니다.\n'
          '단, (사)한국자동차협회가 판매자로 등록한 상품은\n판매자로서 책임을 부담합니다.',
          style: GoogleFonts.notoSansKr(fontSize: 10, color: _t3.withValues(alpha: 0.7), height: 1.7),
        ),

        const SizedBox(height: 12),
        // ── 저작권 + 이동리워드 ───────────────────────────────────
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
            child: Text('ⓒ 한국자동차협회 All Rights Reserved.',
                style: GoogleFonts.notoSansKr(fontSize: 9, color: _t3.withValues(alpha: 0.5))),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1040),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF6B4EFF).withValues(alpha: 0.4)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.card_giftcard_outlined, size: 12, color: Color(0xFF9B7CFF)),
                const SizedBox(width: 4),
                Text('이동리워드', style: GoogleFonts.notoSansKr(
                    fontSize: 10, color: const Color(0xFF9B7CFF), fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ]),
      ]),
    );
  }

  // 링크 행 헬퍼
  Widget _linkRow(List<String> items) {
    return Row(children: [
      for (int i = 0; i < items.length; i++) ...[
        GestureDetector(
          onTap: () {},
          child: Text(items[i],
              style: GoogleFonts.notoSansKr(fontSize: 11, color: _t3)),
        ),
        if (i < items.length - 1)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text('|', style: GoogleFonts.notoSansKr(fontSize: 10, color: _br)),
          ),
      ],
    ]);
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 100,
          child: Text(label, style: GoogleFonts.notoSansKr(fontSize: 11, color: _t3)),
        ),
        Expanded(
          child: Text(value, style: GoogleFonts.notoSansKr(fontSize: 11, color: _t2, fontWeight: FontWeight.w500)),
        ),
      ]),
    );
  }

  Widget _snsBadge(String label, Color color) {
    return Container(
      width: 34, height: 34,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Center(child: Text(label,
          style: GoogleFonts.notoSansKr(fontSize: 10, color: color, fontWeight: FontWeight.w800))),
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
                  hintText: '동네 이름을 입력하세요',
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
                    color: _accent.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _accent.withValues(alpha: 0.25)),
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
      Text(title, style: GoogleFonts.notoSansKr(fontSize: 17, fontWeight: FontWeight.w800, color: _t1)),
      if (action != null)
        GestureDetector(
          onTap: () {},
          child: Text(action, style: GoogleFonts.notoSansKr(fontSize: 13, color: _accent)),
        ),
    ]);
  }

  Widget _callBtn() => GestureDetector(
    onTap: () {},
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _accent.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _accent.withValues(alpha: 0.25)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.phone_outlined, size: 13, color: _accent),
        const SizedBox(width: 4),
        Text('전화', style: GoogleFonts.notoSansKr(fontSize: 12, color: _accent, fontWeight: FontWeight.w600)),
      ]),
    ),
  );

  Widget _navBtn() => GestureDetector(
    onTap: () {},
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _accentS, borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _accent.withValues(alpha: 0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.navigation_outlined, size: 13, color: _t2),
        const SizedBox(width: 4),
        Text('길찾기', style: GoogleFonts.notoSansKr(fontSize: 12, color: _t2, fontWeight: FontWeight.w600)),
      ]),
    ),
  );
}

// ── 군청색 격자 배경 페인터 ──────────────────────────────────────
class _NavyGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF050E1E));
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
    canvas.drawLine(Offset(0, size.height * 0.5), Offset(size.width, size.height * 0.5), road);
    canvas.drawLine(Offset(size.width * 0.4, 0), Offset(size.width * 0.4, size.height), road);
  }
  @override bool shouldRepaint(_) => false;
}
