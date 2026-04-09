import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../widgets/bottom_nav.dart';

// ═══════════════════════════════════════════════════════════════
// MOINCAR Home Screen v27.0.0
// ─ 상단바(로고) 스크롤 시 완전히 화면 밖으로 사라짐
// ─ 검색창: 위치띠 바로 아래 고정 배치 (별도 위젯)
// ─ 서비스 10개: 정비·세차·타이어·중고차·검사·주유소·주차장·렌트카·중고차수출·차량용품
// ─ 이모지 기본 TextStyle(fontFamily 미지정)으로 렌더링 문제 해결
// ─ 배너: 300×350px 사진 배경, 점포/기사/주유/협회 콘텐츠, 무한루프
// ─ BottomNav: 스크롤 중 숨김, 600ms 정지 후 복귀
// ─ 하단 사업자 정보 공백 제거
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
  static const double _topBarH    = 56.0;   // 로고바 높이
  static const double _locBarH    = 44.0;   // 위치띠 높이
  static const double _searchBarH = 52.0;   // 검색바 높이

  // ── 스크롤 ───────────────────────────────────────────────────
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  // BottomNav 숨김/표시
  bool _navVisible = true;
  Timer? _navTimer;

  // ── 위치 ─────────────────────────────────────────────────────
  String _currentAddress = '서울특별시 금천구 가산동';
  double _currentLat = 37.4817;  // 가산동 좌표
  double _currentLng = 126.8820;

  // ── 배너 (무한 캐러셀) ────────────────────────────────────────
  static const int _bannerMultiplier = 500;
  int _currentBannerIndex = 0;
  late PageController _bannerController;
  Timer? _bannerTimer;

  // 배너 데이터: 사진 이미지 + 카테고리
  final List<Map<String, dynamic>> _bannerData = [
    {
      'category': '점포 정보',
      'title': 'MOINCAR 인증\n정비센터',
      'sub': '인증 점포 방문 시 10% 할인 혜택',
      'tag': '🏆 MOINCAR 인증',
      'image': 'assets/images/store_repair.jpg',
      'color': Color(0xFF0A2040),
    },
    {
      'category': '기사 정보',
      'title': '중고차 성능점검\n수요 확대',
      'sub': '사고이력·성능점검표 확인이 필수입니다',
      'tag': '📰 자동차 뉴스',
      'image': 'assets/images/store_usedcar.jpg',
      'color': Color(0xFF0A1A30),
    },
    {
      'category': '주유 정보',
      'title': '오늘의 유가\n실시간 확인',
      'sub': '전국 주유소 최저가 실시간 비교',
      'tag': '⛽ 주유 정보',
      'image': 'assets/images/nearby1.jpg',
      'color': Color(0xFF0D1E10),
    },
    {
      'category': '협회 정보',
      'title': 'KAA 인증서\n발급 신청',
      'sub': '한국자동차협회 공식 인증 서비스',
      'tag': '🏅 협회 인증',
      'image': 'assets/images/nearby3.jpg',
      'color': Color(0xFF1A0A20),
    },
    {
      'category': '이동리워드',
      'title': '이동할수록\n적립되는 리워드',
      'sub': '주행 거리당 포인트 지급 서비스',
      'tag': '🎁 이동리워드',
      'image': 'assets/images/store_carwash.jpg',
      'color': Color(0xFF1A1040),
    },
    {
      'category': '긴급 출동',
      'title': '24시간\n긴급 출동',
      'sub': '언제 어디서나 즉시 출동 연결',
      'tag': '🚨 긴급 서비스',
      'image': 'assets/images/nearby2.jpg',
      'color': Color(0xFF200A0A),
    },
  ];

  int get _infiniteCount => _bannerData.length * _bannerMultiplier;
  int get _initialPage => (_bannerMultiplier ~/ 2) * _bannerData.length;

  // ── 서비스 카테고리 10개 ─────────────────────────────────────
  // 이모지 렌더링 문제: TextStyle에 fontFamily 지정 안 함 (기본 시스템 폰트)
  final List<Map<String, dynamic>> _categories = [
    {'name': '정비',     'emoji': '🔧'},
    {'name': '세차',     'emoji': '🫧'},
    {'name': '타이어',   'emoji': '🛞'},
    {'name': '중고차',   'emoji': '🚗'},
    {'name': '검사',     'emoji': '🔍'},
    {'name': '주유소',   'emoji': '⛽'},
    {'name': '주차장',   'emoji': '🅿️'},
    {'name': '렌트카',   'emoji': '🚙'},
    {'name': '중고차수출','emoji': '🌏'},
    {'name': '차량용품', 'emoji': '🛒'},
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

  // ── 인근 점포 ────────────────────────────────────────────────
  List<Map<String, dynamic>> _nearbyStores = [
    {'badge': '신규',    'name': '수입차 브레이크 전문점', 'sub': '브레이크·하체점검', 'emoji': '🛞', 'image': 'assets/images/nearby1.jpg', 'lat': 35.857, 'lng': 128.633},
    {'badge': '인기',    'name': '하이브리드 배터리케어',  'sub': '배터리·전기점검',   'emoji': '⚡', 'image': 'assets/images/nearby2.jpg', 'lat': 35.858, 'lng': 128.630},
    {'badge': 'MOINCAR', 'name': '인증 중고차센터',        'sub': '중고차·성능점검',   'emoji': '🚗', 'image': 'assets/images/nearby3.jpg', 'lat': 35.855, 'lng': 128.635},
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
    {'badge': 'MOINCAR', 'name': '중고차 성능점검센터',      'sub': '중고차·성능점검',   'distance': '6.1km', 'emoji': '🚗', 'image': 'assets/images/nearby3.jpg'},
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

    // BottomNav: 스크롤 중 숨김, 600ms 정지 후 복귀
    _navTimer?.cancel();
    if (_navVisible) setState(() => _navVisible = false);
    _navTimer = Timer(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _navVisible = true);
    });
  }

  // 상단띠 고정 (스크롤과 무관)
  double get _topBarSlide => 0.0;
  double get _locBarSlide => 0.0;
  double get _searchBarSlide => 0.0;

  // 로고바 현재 보이는 높이
  double get _logoVisible => _topBarH - _topBarSlide;

  // 위치띠 top: 상태바 + 로고바 남은 높이 - 위치띠 슬라이드
  double _locBarTop(double topPad) => topPad + _logoVisible - _locBarSlide;

  // 검색바 top: 위치띠 바로 아래, 스크롤 시 함께 올라감
  double _searchBarTop(double topPad) => 
      topPad + _topBarH - _topBarSlide + _locBarH - _locBarSlide - _searchBarSlide;

  // ★ ListView 상단 패딩: 항상 전체 헤더 높이 (스크롤과 무관하게 고정)
  // 스크롤 시 로고바가 올라가므로 콘텐츠가 자연스럽게 올라옴
  double _contentTopPad(double topPad) =>
      topPad + _topBarH + _locBarH + _searchBarH;

  // ── 위치 초기화 ──────────────────────────────────────────────
  Future<void> _initLocation() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.deniedForever || perm == LocationPermission.denied) {
        if (mounted) setState(() => _currentAddress = '서울특별시 금천구 가산동');
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
      if (!mounted) return;
      setState(() { _currentLat = pos.latitude; _currentLng = pos.longitude; });
      await _updateAddress(pos.latitude, pos.longitude);
      _sortNearby();
    } catch (_) {
      if (mounted) setState(() => _currentAddress = '서울특별시 금천구 가산동');
    }
  }

  Future<void> _updateAddress(double lat, double lng) async {
    try {
      final pm = await placemarkFromCoordinates(lat, lng);
      if (pm.isNotEmpty && mounted) {
        final p = pm.first;
        // 시/도 + 구/군 + 동/읍/면 까지 표시
        final parts = <String>[];
        if (p.administrativeArea?.isNotEmpty == true) parts.add(p.administrativeArea!);  // 서울특별시
        if (p.subAdministrativeArea?.isNotEmpty == true) parts.add(p.subAdministrativeArea!); // 성동구
        if (p.locality?.isNotEmpty == true && p.locality != p.administrativeArea) parts.add(p.locality!); // 구
        if (p.subLocality?.isNotEmpty == true) parts.add(p.subLocality!);  // 용답동
        // 중복 제거 후 합치기
        final unique = parts.toSet().toList();
        setState(() => _currentAddress = unique.isNotEmpty ? unique.join(' ') : '현재 위치');
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
  // BUILD
  // ══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    // BottomNav 높이: 60px + SafeArea bottom
    const double navH = 60.0;
    final double navTotalH = navH + bottomPad;

    return Scaffold(
      backgroundColor: _bg,
      // bottomNavigationBar 제거 → Stack 내부로 이동하여 공백 원천 차단
      body: Stack(
        children: [
          // ── 메인 스크롤 콘텐츠 ──────────────────────────────
          Positioned.fill(
            child: ListView(
              controller: _scrollController,
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.only(
                top: _contentTopPad(topPad),
                bottom: navTotalH + 8,  // BottomNav 완전히 가릴 패딩
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

          // ── 로고바 (스크롤 시 위로 슬라이드)
          Positioned(
            top: topPad - _topBarSlide,
            left: 0,
            right: 0,
            child: _buildTopLogoBar(),
          ),

          // ── 위치띠 (스크롤 시 함께 슬라이드)
          Positioned(
            top: topPad + _topBarH - _topBarSlide - _locBarSlide,
            left: 0,
            right: 0,
            child: _buildLocationBar(),
          ),

          // ── 검색바 (스크롤 시 함께 슬라이드) ───────────────────
          Positioned(
            top: _searchBarTop(topPad),
            left: 0,
            right: 0,
            child: _buildSearchBar(),
          ),

          // ── 하단 BottomNav (Stack 내부 → 숨겨도 공백 없음) ───
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSlide(
              offset: _navVisible ? Offset.zero : const Offset(0, 1),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: AnimatedOpacity(
                opacity: _navVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: const BottomNav(activeTab: 'home'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // 로고바 (스크롤 시 위로 사라짐)
  // ══════════════════════════════════════════════════════════════
  Widget _buildTopLogoBar() {
    return Container(
      height: _topBarH,
      color: Colors.black,   // 완전 검정 #000000
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        // 로고 이미지만 (텍스트 삭제) - 크기 확대
        Image.asset(
          'assets/images/moincar_logo.png',
          height: 40,  // 80 → 40 (상단바에 맞게 조정)
          fit: BoxFit.contain,
          errorBuilder: (c, e, s) => Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A3A8E), Color(0xFF0D1E5A)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Text('M',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
                    color: _accent, fontFamily: 'sans-serif'))),
          ),
        ),
        const Spacer(),
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
        const SizedBox(width: 8),
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
          boxShadow: [BoxShadow(color: Color(0x44000000), blurRadius: 3)],
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
          const Icon(Icons.location_on_outlined, color: Color(0xFF4FC3F7), size: 16),
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
  // 검색바 (위치띠 아래 고정)
  // ══════════════════════════════════════════════════════════════
  Widget _buildSearchBar() {
    return Container(
      height: _searchBarH,
      color: const Color(0xFF030C1C),
      padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          decoration: BoxDecoration(
            color: _s1,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _br),
            boxShadow: [BoxShadow(
                color: Colors.black.withValues(alpha: 0.2), blurRadius: 4)],
          ),
          child: Row(children: [
            const SizedBox(width: 14),
            const Icon(Icons.search_rounded, color: Color(0xFF3A6080), size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text('정비소, 세차장, 중고차, 주유소 검색...',
                style: GoogleFonts.notoSansKr(fontSize: 13, color: _t3))),
            Container(
              margin: const EdgeInsets.only(right: 10),
              child: const Icon(Icons.mic_none_rounded, color: Color(0xFF3A6080), size: 18),
            ),
          ]),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // 배너 — 300×350px 사진 배경 무한 캐러셀
  // ══════════════════════════════════════════════════════════════
  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 0),
      height: 330,   // 350 → 330 (20px 축소)
      child: Stack(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: PageView.builder(
            controller: _bannerController,
            itemCount: _infiniteCount,
            onPageChanged: _onBannerPageChanged,
            itemBuilder: (_, rawIndex) {
              final b = _bannerData[rawIndex % _bannerData.length];
              return Stack(fit: StackFit.expand, children: [
                // 배경 사진 이미지
                Image.asset(
                  b['image'] as String,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(color: b['color'] as Color),
                ),
                // 어두운 그라디언트 오버레이 (텍스트 가독성)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.15),
                        Colors.black.withValues(alpha: 0.75),
                      ],
                    ),
                  ),
                ),
                // 좌측 하단 텍스트
                Positioned(left: 22, right: 22, bottom: 28,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                    // 카테고리 태그
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: _accent.withValues(alpha: 0.2),
                        border: Border.all(color: _accent.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(b['tag'] as String,
                          style: GoogleFonts.notoSansKr(
                              fontSize: 12, color: _accent, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 10),
                    Text(b['title'] as String,
                        style: GoogleFonts.notoSansKr(
                            fontSize: 26, fontWeight: FontWeight.w900,
                            color: Colors.white, height: 1.25,
                            shadows: [Shadow(color: Colors.black54, blurRadius: 8)])),
                    const SizedBox(height: 6),
                    Text(b['sub'] as String,
                        style: GoogleFonts.notoSansKr(
                            fontSize: 13, color: Colors.white70,
                            shadows: [Shadow(color: Colors.black45, blurRadius: 4)])),
                  ]),
                ),
              ]);
            },
          ),
        ),
        // 인디케이터
        Positioned(right: 16, top: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(mainAxisSize: MainAxisSize.min,
              children: List.generate(_bannerData.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                width: i == _currentBannerIndex ? 20 : 6, height: 6,
                margin: const EdgeInsets.only(left: 3),
                decoration: BoxDecoration(
                  color: i == _currentBannerIndex ? _accent : Colors.white54,
                  borderRadius: BorderRadius.circular(3),
                ),
              )),
            ),
          ),
        ),
        // 카테고리 라벨 (우하단)
        Positioned(right: 16, bottom: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(_bannerData[_currentBannerIndex]['category'] as String,
                style: GoogleFonts.notoSansKr(
                    fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w600)),
          ),
        ),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // 카테고리 — 10개 (5+5 두 줄) 이모지 렌더링 수정
  // ══════════════════════════════════════════════════════════════
  Widget _buildCategoryGrid() {
    final row1 = _categories.sublist(0, 5);
    final row2 = _categories.sublist(5, 10);

    // 이모지 표시: TextStyle에 fontFamily 지정하지 않음
    Widget catItem(Map<String, dynamic> c) {
      return GestureDetector(
        onTap: () {},
        child: SizedBox(
          width: 64,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _s1,
                border: Border.all(color: _br, width: 1.5),
                boxShadow: [BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 6, offset: const Offset(0, 2))],
              ),
              // ★ 이모지: 원형 유지, 크기 7px 줄여 19px
              child: Center(
                child: Text(
                  c['emoji'] as String,
                  style: const TextStyle(
                    fontSize: 19,   // 26 - 7 = 19
                    height: 1.0,
                    // fontFamily 지정 안 함 → 시스템 이모지 폰트 사용
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(c['name'] as String,
                style: GoogleFonts.notoSansKr(
                    fontSize: 11, color: _t2, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ]),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 26, 14, 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHeader('서비스', null),
        const SizedBox(height: 18),
        // 1행: 5개
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: row1.map(catItem).toList(),
        ),
        const SizedBox(height: 18),
        // 2행: 5개
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: row2.map(catItem).toList(),
        ),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // 추천 점포 — 가로 슬라이드
  // ══════════════════════════════════════════════════════════════
  Widget _buildRecommendSection() {
    const double cardW = 270;
    const double imgH  = 165;
    const double cardH = 305;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 26, 16, 16),
        child: _sectionHeader('⭐  MOINCAR 추천 점포', '전체보기'),
      ),
      SizedBox(
        height: cardH,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          itemCount: _stores.length,
          itemBuilder: (_, i) {
            final s = _stores[i];
            return Container(
              width: cardW,
              margin: EdgeInsets.only(right: i < _stores.length - 1 ? 14 : 0),
              decoration: BoxDecoration(
                color: _s1,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _br.withValues(alpha: 0.5)),
                boxShadow: [BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Stack(children: [
                    SizedBox(
                      width: double.infinity, height: imgH,
                      child: Image.asset(s['image'] as String, fit: BoxFit.cover,
                          errorBuilder: (c, e, st) => Container(
                              color: _s2,
                              child: Center(child: Text(s['emoji'] as String,
                                  style: const TextStyle(fontSize: 60))))),
                    ),
                    Positioned.fill(child: Container(
                      decoration: BoxDecoration(gradient: LinearGradient(
                          begin: Alignment.topCenter, end: Alignment.bottomCenter,
                          colors: [Colors.transparent, _bg.withValues(alpha: 0.55)])),
                    )),
                    Positioned(top: 10, left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: _bg.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _accent.withValues(alpha: 0.35)),
                        ),
                        child: Text(s['tag'] as String,
                            style: GoogleFonts.notoSansKr(
                                fontSize: 10, color: _accent, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s['name'] as String,
                        style: GoogleFonts.notoSansKr(
                            fontSize: 15, fontWeight: FontWeight.w700, color: _t1),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 5),
                    Row(children: [
                      const Icon(Icons.location_on, color: Color(0xFF4FC3F7), size: 12),
                      const SizedBox(width: 3),
                      Text(s['distance'] as String,
                          style: GoogleFonts.notoSansKr(
                              fontSize: 11, color: _accent, fontWeight: FontWeight.w600)),
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
      margin: const EdgeInsets.fromLTRB(14, 26, 14, 0),
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
                padding: const EdgeInsets.fromLTRB(4, 22, 4, 22),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: aColor.withValues(alpha: 0.35)),
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.2),
                      border: Border.all(color: aColor.withValues(alpha: 0.4)),
                    ),
                    child: Icon(item['icon'] as IconData, color: aColor, size: 28),
                  ),
                  const SizedBox(height: 12),
                  Text(item['label'] as String,
                      style: GoogleFonts.notoSansKr(
                          fontSize: 11, color: aColor, height: 1.35,
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
      margin: const EdgeInsets.fromLTRB(14, 26, 14, 0),
      height: 240,  // 220 → 240 (+20px)
      decoration: BoxDecoration(
        color: const Color(0xFF050E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _br.withValues(alpha: 0.4)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(children: [
          Positioned.fill(child: CustomPaint(painter: _NavyGridPainter())),
          Positioned.fill(child: Image.asset('assets/images/map_sample.png',
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => const SizedBox())),
          Positioned.fill(
              child: Container(color: Colors.black.withValues(alpha: 0.45))),
          Positioned.fill(child: Center(child: Container(
            width: 20, height: 20,
            decoration: BoxDecoration(
              color: _accent, shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: _accent.withValues(alpha: 0.3), blurRadius: 0, spreadRadius: 7),
                BoxShadow(color: _accent.withValues(alpha: 0.15), blurRadius: 0, spreadRadius: 15),
              ],
            ),
          ))),
          _mapPin(left: 55, top: 55, emoji: '🔧'),
          _mapPin(right: 55, top: 42, emoji: '🚗'),
          _mapPin(left: 70, bottom: 52, emoji: '⛽'),
          _mapPin(right: 42, bottom: 45, emoji: '🏢'),
          Positioned(left: 14, right: 14, bottom: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              decoration: BoxDecoration(
                color: _bg.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _br.withValues(alpha: 0.5)),
              ),
              child: Row(children: [
                Text('📍  반경 5km 이내',
                    style: GoogleFonts.notoSansKr(fontSize: 13, color: _t2)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: _accentS, borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _accent.withValues(alpha: 0.4)),
                  ),
                  child: Text('10개 업체',
                      style: GoogleFonts.notoSansKr(
                          fontSize: 12, color: _accent, fontWeight: FontWeight.w700)),
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
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: _bg.withValues(alpha: 0.85), shape: BoxShape.circle,
          border: Border.all(color: _accent.withValues(alpha: 0.4)),
        ),
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 18))),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // 인근 점포 — 크기 조정 (화면에 2개 완전히 보이도록)
  // ══════════════════════════════════════════════════════════════
  Widget _buildNearbySection() {
    const double cardW = 150;  // 175 → 150 (화면에 2개 완전히)
    const double imgH  = 120;  // 사진 높이
    const double cardH = 240;  // 카드 전체 높이

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 26, 16, 16),
        child: _sectionHeader('📍  인근 점포', '더보기'),
      ),
      Stack(children: [
        SizedBox(
          height: cardH,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),  // 수동 슬라이드
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: _nearbyStores.length,
            itemBuilder: (_, i) {
            final s = _nearbyStores[i];
            final dist = s['distLabel'] as String? ?? '';
            return Container(
              width: cardW,
              margin: EdgeInsets.only(right: i < _nearbyStores.length - 1 ? 14 : 0),
              decoration: BoxDecoration(
                color: _s1,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _br.withValues(alpha: 0.5)),
                boxShadow: [BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Stack(children: [
                    SizedBox(
                      width: double.infinity, height: imgH,
                      child: Image.asset(s['image'] as String, fit: BoxFit.cover,
                          errorBuilder: (c, e, st) => Container(
                              color: _s2,
                              child: Center(child: Text(s['emoji'] as String,
                                  style: const TextStyle(fontSize: 70))))),
                    ),
                    Positioned.fill(child: Container(
                      decoration: BoxDecoration(gradient: LinearGradient(
                          begin: Alignment.topCenter, end: Alignment.bottomCenter,
                          colors: [Colors.transparent, _bg.withValues(alpha: 0.5)])),
                    )),
                    Positioned(top: 12, left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _bg.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _accent.withValues(alpha: 0.35)),
                        ),
                        child: Text(s['badge'] as String,
                            style: GoogleFonts.notoSansKr(
                                fontSize: 11, color: _accent, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s['name'] as String,
                        style: GoogleFonts.notoSansKr(
                            fontSize: 13, fontWeight: FontWeight.w700, color: _t1),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.location_on, color: Color(0xFF4FC3F7), size: 11),
                      const SizedBox(width: 2),
                      Text(dist.isNotEmpty ? dist : s['sub'] as String,
                          style: GoogleFonts.notoSansKr(
                              fontSize: 10, color: _accent, fontWeight: FontWeight.w600)),
                    ]),
                    const SizedBox(height: 2),
                    Text(s['sub'] as String,
                        style: GoogleFonts.notoSansKr(fontSize: 10, color: _t3),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(child: _callBtnSmall()),
                      const SizedBox(width: 6),
                      Expanded(child: _navBtnSmall()),
                    ]),
                  ]),
                ),
              ]),
            );
          },
        ),
      ),
      // 우측 슬라이드 표시 (페이드 효과)
      Positioned(
        right: 0,
        top: 0,
        bottom: 0,
        child: IgnorePointer(
          child: Container(
            width: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  _bg.withValues(alpha: 0.0),
                  _bg.withValues(alpha: 0.95),
                ],
              ),
            ),
            child: Center(
              child: Icon(
                Icons.chevron_right_rounded,
                color: _t2.withValues(alpha: 0.6),
                size: 32,
              ),
            ),
          ),
        ),
      ),
    ]),
    ]);
  }

  // ══════════════════════════════════════════════════════════════
  // 프로모 밴드
  // ══════════════════════════════════════════════════════════════
  Widget _buildPromoBand() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 26, 14, 0),
      height: 110,
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
            child: Container(width: 130, height: 130,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _accent.withValues(alpha: 0.06)))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            child: Row(children: [
              Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: _accent.withValues(alpha: 0.3)),
                  ),
                  child: Text('한국자동차협회 KAA',
                      style: GoogleFonts.notoSansKr(
                          fontSize: 10, color: _accent, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 8),
                Text('인증서 발급 신청하러가기',
                    style: GoogleFonts.notoSansKr(
                        fontSize: 15, fontWeight: FontWeight.w800, color: _t1)),
              ])),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentS, foregroundColor: _accent,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: _accent.withValues(alpha: 0.4)),
                  ),
                  elevation: 0,
                ),
                child: Text('신청하기',
                    style: GoogleFonts.notoSansKr(
                        fontSize: 13, color: _accent, fontWeight: FontWeight.w700)),
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
    const double cardW = 270;
    const double imgH  = 160;
    const double cardH = 295;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 26, 16, 16),
        child: _sectionHeader('🕐  최근 본 점포', '더보기'),
      ),
      SizedBox(
        height: cardH,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          itemCount: _recentStores.length,
          itemBuilder: (_, i) {
            final s = _recentStores[i];
            return Container(
              width: cardW,
              margin: EdgeInsets.only(right: i < _recentStores.length - 1 ? 14 : 0),
              decoration: BoxDecoration(
                color: _s1,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _br.withValues(alpha: 0.5)),
                boxShadow: [BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: SizedBox(
                    width: double.infinity, height: imgH,
                    child: Image.asset(s['image'] as String, fit: BoxFit.cover,
                        errorBuilder: (c, e, st) => Container(
                            color: _s2,
                            child: Center(child: Text(s['emoji'] as String,
                                style: const TextStyle(fontSize: 60))))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s['name'] as String,
                        style: GoogleFonts.notoSansKr(
                            fontSize: 15, fontWeight: FontWeight.w700, color: _t1),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 5),
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
  // 가까운 점포순 — 전체폭 대형카드 (7개씩 로딩)
  // ══════════════════════════════════════════════════════════════
  Widget _buildCloseSection() {
    final loadCount = (_closeLoadedPage * _pageSize).clamp(0, _allCloseStores.length);
    final list = _allCloseStores.take(loadCount).toList();
    final canLoadMore = loadCount < _allCloseStores.length;
    final isLastPage  = loadCount >= _allCloseStores.length;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 26, 16, 16),
        child: _sectionHeader('📍  가까운 점포순', null),
      ),
      ...list.map((s) {
        return Container(
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 16),
          decoration: BoxDecoration(
            color: _s1,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _br.withValues(alpha: 0.5)),
            boxShadow: [BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Stack(children: [
                SizedBox(
                  width: double.infinity, height: 200,
                  child: Image.asset(s['image'] as String, fit: BoxFit.cover,
                      errorBuilder: (c, e2, st) => Container(
                          color: _s2,
                          child: Center(child: Text(s['emoji'] as String,
                              style: const TextStyle(fontSize: 70))))),
                ),
                Positioned.fill(child: Container(
                  decoration: BoxDecoration(gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [Colors.transparent, _bg.withValues(alpha: 0.5)])),
                )),
                Positioned(top: 12, left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _bg.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _accent.withValues(alpha: 0.35)),
                    ),
                    child: Text(s['badge'] as String,
                        style: GoogleFonts.notoSansKr(
                            fontSize: 11, color: _accent, fontWeight: FontWeight.w700)),
                  ),
                ),
                Positioned(top: 12, right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _bg.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.location_on, color: Color(0xFF4FC3F7), size: 12),
                      const SizedBox(width: 2),
                      Text(s['distance'] as String,
                          style: GoogleFonts.notoSansKr(
                              fontSize: 11, color: _accent, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s['name'] as String,
                    style: GoogleFonts.notoSansKr(
                        fontSize: 17, fontWeight: FontWeight.w700, color: _t1),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 5),
                Text(s['sub'] as String,
                    style: GoogleFonts.notoSansKr(fontSize: 13, color: _t3)),
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
      }).toList(),

      // 더보기 버튼
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
        child: GestureDetector(
          onTap: () {
            if (canLoadMore) setState(() => _closeLoadedPage++);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: _s2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _br.withValues(alpha: 0.5)),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(
                isLastPage ? Icons.check_circle_outline : Icons.keyboard_arrow_down_rounded,
                color: isLastPage ? _t3 : _t2, size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                isLastPage
                    ? '모든 점포를 불러왔습니다'
                    : '다음 ${(_allCloseStores.length - loadCount).clamp(0, _pageSize)}개 더 보기',
                style: GoogleFonts.notoSansKr(
                    fontSize: 14, color: isLastPage ? _t3 : _t1,
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
  // 공백 제거: margin.top 없애고 padding bottom 최소화
  // ══════════════════════════════════════════════════════════════
  Widget _buildCompanySection() {
    return Container(
      color: const Color(0xFF010814),
      margin: EdgeInsets.zero,   // margin 완전 제거
      child: Column(children: [

        // 혜택 배너 띠
        GestureDetector(
          onTap: () {},
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: const Color(0xFF062030),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('🎁  MOINCAR 회원 전용 혜택 있어요!',
                  style: GoogleFonts.notoSansKr(
                      fontSize: 13, fontWeight: FontWeight.w700, color: _accent)),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF4FC3F7), size: 18),
            ]),
          ),
        ),

        Container(height: 1, color: _br.withValues(alpha: 0.3)),

        // 정보 영역
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            _linkRow(['사업자정보확인', '이용약관', '전자금융거래이용약관']),
            const SizedBox(height: 8),
            _linkRow(['개인정보처리방침', '리뷰운영정책', '데이터제공정책']),
            const SizedBox(height: 8),
            _linkRow(['소비자분쟁해결기준']),

            const SizedBox(height: 18),
            Container(height: 1, color: _br.withValues(alpha: 0.25)),
            const SizedBox(height: 16),

            Text('(사)한국자동차협회',
                style: GoogleFonts.notoSansKr(
                    fontSize: 14, fontWeight: FontWeight.w800, color: _t2)),
            const SizedBox(height: 12),

            _infoRow('대표자',      '성백진'),
            _infoRow('사업자등록번호', '114-82-05386'),
            _infoRow('통신판매업',    '제 2016-서울성동-01043호'),
            _infoRow('이메일',        'kaa21@kaa21.or.kr'),
            _infoRow('주소',          '서울 성동구 자동차시장1길 70 (용답동)'),
            _infoRow('대표전화',      '02-3482-7433'),

            const SizedBox(height: 16),
            Container(height: 1, color: _br.withValues(alpha: 0.25)),
            const SizedBox(height: 14),

            Text('대표 고객센터',
                style: GoogleFonts.notoSansKr(
                    fontSize: 13, fontWeight: FontWeight.w700, color: _t2)),
            const SizedBox(height: 8),
            Row(children: [
              Text('02-3482-7433',
                  style: GoogleFonts.notoSansKr(
                      fontSize: 14, color: _t2, fontWeight: FontWeight.w600)),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: _s2, borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _br.withValues(alpha: 0.5)),
                ),
                child: Text('평일 운영',
                    style: GoogleFonts.notoSansKr(fontSize: 11, color: _t3)),
              ),
            ]),
            const SizedBox(height: 5),
            Text('AM 10:00 ~ PM 17:00  (점심 12:00~13:00)',
                style: GoogleFonts.notoSansKr(fontSize: 12, color: _t3)),
            const SizedBox(height: 3),
            Text('주말 및 공휴일 휴무',
                style: GoogleFonts.notoSansKr(
                    fontSize: 12, color: _t3.withValues(alpha: 0.7))),

            const SizedBox(height: 16),
            Container(height: 1, color: _br.withValues(alpha: 0.25)),
            const SizedBox(height: 14),

            Text('공식 채널',
                style: GoogleFonts.notoSansKr(
                    fontSize: 12, color: _t3, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Row(children: [
              _snsBadge('IN', const Color(0xFFE1306C)),
              const SizedBox(width: 10),
              _snsBadge('YT', const Color(0xFFFF0000)),
              const SizedBox(width: 10),
              _snsBadge('FB', const Color(0xFF1877F2)),
              const SizedBox(width: 10),
              _snsBadge('KT', const Color(0xFFFEE500)),
              const SizedBox(width: 10),
              _snsBadge('N', const Color(0xFF03C75A)),
            ]),

            const SizedBox(height: 16),
            Container(height: 1, color: _br.withValues(alpha: 0.2)),
            const SizedBox(height: 12),

            Text(
              '(사)한국자동차협회는 통신판매중개자로 거래 당사자가 아니므로,\n'
              '판매자가 등록한 상품 및 거래에 대해 책임을 지지 않습니다.',
              style: GoogleFonts.notoSansKr(
                  fontSize: 10, color: _t3.withValues(alpha: 0.6), height: 1.8),
            ),

            const SizedBox(height: 12),
            Container(height: 1, color: _br.withValues(alpha: 0.2)),
            const SizedBox(height: 10),

            // 저작권 + 이동리워드
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(
                child: Text('ⓒ 한국자동차협회 All Rights Reserved.',
                    style: GoogleFonts.notoSansKr(
                        fontSize: 10, color: _t3.withValues(alpha: 0.5))),
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1040),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFF6B4EFF).withValues(alpha: 0.5)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.card_giftcard_outlined,
                        size: 12, color: Color(0xFF9B7CFF)),
                    const SizedBox(width: 5),
                    Text('이동리워드',
                        style: GoogleFonts.notoSansKr(
                            fontSize: 11, color: const Color(0xFF9B7CFF),
                            fontWeight: FontWeight.w700)),
                  ]),
                ),
              ),
            ]),
          ]),   // Column 끝 - 패딩 없음
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
                style: GoogleFonts.notoSansKr(fontSize: 12, color: _t3)),
          ),
          if (i < items.length - 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: Text('|', style: GoogleFonts.notoSansKr(fontSize: 11, color: _br)),
            ),
        ],
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 110,
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
      width: 40, height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Center(child: Text(label,
          style: GoogleFonts.notoSansKr(
              fontSize: 11, color: color, fontWeight: FontWeight.w800))),
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
      {'name': '대구 수성구 범어동',     'lat': 35.8562, 'lng': 128.6314},
      {'name': '대전 서구 둔산동',       'lat': 36.3504, 'lng': 127.3845},
      {'name': '인천 남동구 구월동',     'lat': 37.4490, 'lng': 126.7311},
      {'name': '광주 서구 치평동',       'lat': 35.1540, 'lng': 126.8476},
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
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF3A6080)),
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
                onTap: () { Navigator.pop(ctx); _initLocation(); },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _accent.withValues(alpha: 0.25)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.my_location, color: Color(0xFF4FC3F7), size: 18),
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
                    ? Center(child: Text(
                        ctrl.text.isEmpty ? '동네 이름을 입력하세요' : '검색 결과 없음',
                        style: GoogleFonts.notoSansKr(fontSize: 14, color: _t3)))
                    : ListView.separated(
                        controller: sc,
                        itemCount: results.length,
                        separatorBuilder: (_, __) => Divider(height: 1, color: _br),
                        itemBuilder: (_, i) {
                          final r = results[i];
                          return ListTile(
                            leading: const Icon(Icons.location_on_outlined,
                                color: Color(0xFF4FC3F7)),
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
              fontSize: 19, fontWeight: FontWeight.w800, color: _t1)),
      if (action != null)
        GestureDetector(
          onTap: () {},
          child: Text(action,
              style: GoogleFonts.notoSansKr(fontSize: 13, color: _accent)),
        ),
    ]);
  }

  Widget _callBtn() => GestureDetector(
    onTap: () {},
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: _accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _accent.withValues(alpha: 0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.phone_outlined, size: 14, color: Color(0xFF4FC3F7)),
        const SizedBox(width: 4),
        Text('전화', style: GoogleFonts.notoSansKr(
            fontSize: 13, color: _accent, fontWeight: FontWeight.w600)),
      ]),
    ),
  );

  Widget _navBtn() => GestureDetector(
    onTap: () {},
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: _accentS,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _accent.withValues(alpha: 0.35)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.navigation_outlined, size: 14, color: Color(0xFF7AB0D4)),
        const SizedBox(width: 4),
        Text('길찾기', style: GoogleFonts.notoSansKr(
            fontSize: 13, color: _t2, fontWeight: FontWeight.w600)),
      ]),
    ),
  );

  // 작은 버튼 (인근 점포용)
  Widget _callBtnSmall() => GestureDetector(
    onTap: () {},
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: _accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _accent.withValues(alpha: 0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.phone_outlined, size: 11, color: Color(0xFF4FC3F7)),
        const SizedBox(width: 3),
        Text('전화', style: GoogleFonts.notoSansKr(
            fontSize: 10, color: _accent, fontWeight: FontWeight.w600)),
      ]),
    ),
  );

  Widget _navBtnSmall() => GestureDetector(
    onTap: () {},
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: _accentS,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _accent.withValues(alpha: 0.35)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.navigation_outlined, size: 11, color: Color(0xFF7AB0D4)),
        const SizedBox(width: 3),
        Text('길찾기', style: GoogleFonts.notoSansKr(
            fontSize: 10, color: _t2, fontWeight: FontWeight.w600)),
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
