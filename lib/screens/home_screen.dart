import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/youtube_widgets.dart';
import '../models/app_state.dart';
import 'store_screens.dart';
import 'category_landing_screen.dart';
import 'quote_screens.dart';

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
  static const double _totalHeaderH = 152.0; // 전체 헤더 높이(56+44+52)

  // ── 검색 ─────────────────────────────────────────────────────
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  bool _isSearchActive = false;
  String _searchQuery = '';

  // ── 스크롤 ───────────────────────────────────────────────────
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  // BottomNav 숨김/표시
  bool _navVisible = true;
  Timer? _navTimer;

  // ── 상태바 높이 캐시 (첫 빌드 점프 방지) ──────────────────────
  double _cachedTopPad = 0.0;  // didChangeDependencies에서 확정
  bool _topPadReady = false;

  // ── 위치 ─────────────────────────────────────────────────────
  String _currentAddress = '서울특별시 금천구 가산동';
  double _currentLat = 37.4817;  // 가산동 좌표
  double _currentLng = 126.8820;

  // ── 주유소 오버레이 표시 로직 ──────────────────────────────────
  // showCount: 0=첫번째 표시중, 1=두번째 표시중, 2=1분잠금
  bool _gasOverlayVisible = true;
  bool _showGasOverlay = false;    // 카테고리 탭으로 열기
  int  _gasShowCount = 0;          // 0→1→2 (2 이상이면 1분 대기)
  DateTime? _gasHideUntil;         // 1분 잠금 해제 시각
  Timer? _gasTimer;
  Timer? _gasRotateTimer;
  int _gasDisplayIndex = 0;

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
      'image': 'https://images.unsplash.com/photo-1632823469850-2f77dd9c7f93?w=600&q=80',
      'color': Color(0xFF0A2040),
      'route': '/store-list',
    },
    {
      'category': '기사 정보',
      'title': '중고차 성능점검\n수요 확대',
      'sub': '사고이력·성능점검표 확인이 필수입니다',
      'tag': '📰 자동차 뉴스',
      'image': 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=600&q=80',
      'color': Color(0xFF0A1A30),
      'route': '/news',
    },
    {
      'category': '주유 정보',
      'title': '오늘의 유가\n실시간 확인',
      'sub': '전국 주유소 최저가 실시간 비교',
      'tag': '⛽ 주유 정보',
      'image': 'https://images.unsplash.com/photo-1565728744382-61accd4aa148?w=600&q=80',
      'color': Color(0xFF0D1E10),
      'route': '',  // 주유 팝업 표시
    },
    {
      'category': '협회 정보',
      'title': 'KAA 인증서\n발급 신청',
      'sub': '한국자동차협회 공식 인증 서비스',
      'tag': '🏅 협회 인증',
      'image': 'https://images.unsplash.com/photo-1449965408869-eaa3f722e40d?w=600&q=80',
      'color': Color(0xFF1A0A20),
      'route': '/cert',
    },
    {
      'category': '이동리워드',
      'title': '이동할수록\n적립되는 리워드',
      'sub': '주행 거리당 포인트 지급 서비스',
      'tag': '🎁 이동리워드',
      'image': 'https://images.unsplash.com/photo-1520340356584-f9917d1eea6f?w=600&q=80',
      'color': Color(0xFF1A1040),
      'route': '/my',
    },
    {
      'category': '긴급 출동',
      'title': '24시간\n긴급 출동',
      'sub': '언제 어디서나 즉시 출동 연결',
      'tag': '🚨 긴급 서비스',
      'image': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600&q=80',
      'color': Color(0xFF200A0A),
      'route': '/emergency',
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
    {'name': '오토바이', 'emoji': '🏍️'},
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
    {'tag': 'MOINCAR 인증', 'name': '강남자동차정비센터',  'distance': '1.8km', 'sub': '엔진·미션·판금 전문',   'image': 'https://images.unsplash.com/photo-1632823469850-2f77dd9c7f93?w=300&q=80',  'emoji': '🔧'},
    {'tag': '인증중고차',    'name': '서울모터스홀딩스',    'distance': '2.4km', 'sub': '수입차·국산차 전문',   'image': 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=300&q=80', 'emoji': '🚗'},
    {'tag': '공식딜러',      'name': '현대자동차 강남점',   'distance': '3.0km', 'sub': '신차·인증중고·시승',   'image': 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=300&q=80',       'emoji': '🏢'},
    {'tag': 'MOINCAR 인증', 'name': '프리미엄 세차코팅',   'distance': '3.5km', 'sub': '손세차·광택·코팅',     'image': 'https://images.unsplash.com/photo-1520340356584-f9917d1eea6f?w=300&q=80',       'emoji': '🫧'},
    {'tag': '이동리워드',    'name': '리워드 파트너 정비',  'distance': '5.1km', 'sub': '이동리워드 적립 가능',  'image': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=300&q=80',       'emoji': '🎁'},
  ];

  // ── 인근 점포 ────────────────────────────────────────────────
  List<Map<String, dynamic>> _nearbyStores = [
    {'badge': '신규',    'name': '수입차 브레이크 전문점', 'sub': '브레이크·하체점검', 'emoji': '🛞', 'image': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=120&q=80', 'lat': 35.857, 'lng': 128.633},
    {'badge': '인기',    'name': '하이브리드 배터리케어',  'sub': '배터리·전기점검',   'emoji': '⚡', 'image': 'https://images.unsplash.com/photo-1593941707882-a5bba53b0998?w=120&q=80', 'lat': 35.858, 'lng': 128.630},
    {'badge': 'MOINCAR', 'name': '인증 중고차센터',        'sub': '중고차·성능점검',   'emoji': '🚗', 'image': 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=120&q=80', 'lat': 35.855, 'lng': 128.635},
    {'badge': '추천',    'name': '프리미엄 엔진오일샵',    'sub': '오일·경정비',        'emoji': '🔧', 'image': 'https://images.unsplash.com/photo-1632823469850-2f77dd9c7f93?w=120&q=80', 'lat': 35.860, 'lng': 128.628},
    {'badge': '인기',    'name': '타이어 교환 전문센터',   'sub': '타이어·얼라인먼트', 'emoji': '🛞', 'image': 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=120&q=80', 'lat': 35.854, 'lng': 128.638},
    {'badge': '신규',    'name': '손세차 디테일링샵',      'sub': '손세차·광택코팅',   'emoji': '✨', 'image': 'https://images.unsplash.com/photo-1520340356584-f9917d1eea6f?w=120&q=80', 'lat': 35.862, 'lng': 128.625},
  ];

  // ── 최근 본 점포 ─────────────────────────────────────────────
  final List<Map<String, dynamic>> _recentStores = [
    {'name': '강남자동차정비',  'sub': '정비·엔진오일', 'emoji': '🔧', 'image': 'https://images.unsplash.com/photo-1632823469850-2f77dd9c7f93?w=400&q=80'},
    {'name': '서울모터스',      'sub': '수입차 중고차', 'emoji': '🚗', 'image': 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400&q=80'},
    {'name': 'BMW 강남전시장',  'sub': '공식딜러 신차', 'emoji': '🏢', 'image': 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=400&q=80'},
    {'name': 'GS칼텍스 강남',  'sub': '주유소 24시간', 'emoji': '⛽', 'image': 'https://images.unsplash.com/photo-1565728744382-61accd4aa148?w=400&q=80'},
    {'name': '프리미엄세차',    'sub': '핸드세차 전문', 'emoji': '🫧', 'image': 'https://images.unsplash.com/photo-1520340356584-f9917d1eea6f?w=400&q=80'},
  ];

  // ── 가까운 점포순 (7개씩 페이지 로딩) ───────────────────────
  final List<Map<String, dynamic>> _allCloseStores = [
    {'badge': 'MOINCAR', 'name': 'MOINCAR 인증 정비센터',  'sub': '정비·엔진오일',     'distance': '1.2km', 'emoji': '🔧', 'image': 'https://images.unsplash.com/photo-1632823469850-2f77dd9c7f93?w=300&q=80'},
    {'badge': '추천',    'name': '프리미엄 디테일링 세차',  'sub': '손세차·코팅',        'distance': '2.1km', 'emoji': '🫧', 'image': 'https://images.unsplash.com/photo-1520340356584-f9917d1eea6f?w=300&q=80'},
    {'badge': 'MOINCAR', 'name': '수입차 타이어 전문점',    'sub': '타이어·휠얼라인',   'distance': '3.4km', 'emoji': '🛞', 'image': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=300&q=80'},
    {'badge': '신규',    'name': '하이브리드 배터리 케어',  'sub': '배터리·전기점검',   'distance': '3.8km', 'emoji': '⚡', 'image': 'https://images.unsplash.com/photo-1593941707882-a5bba53b0998?w=300&q=80'},
    {'badge': '인기',    'name': '수입차 브레이크 전문',    'sub': '브레이크·하체점검', 'distance': '4.2km', 'emoji': '🛞', 'image': 'https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?w=300&q=80'},
    {'badge': 'MOINCAR', 'name': '종합 자동차 정비소',      'sub': '종합정비·검사',     'distance': '4.9km', 'emoji': '🏆', 'image': 'https://images.unsplash.com/photo-1632823469850-2f77dd9c7f93?w=300&q=80'},
    {'badge': '추천',    'name': '엔진오일 전문점',          'sub': '오일·경정비',        'distance': '5.3km', 'emoji': '🔧', 'image': 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=300&q=80'},
    {'badge': '신규',    'name': '프리미엄 세차 코팅',       'sub': '세차·유리막코팅',   'distance': '5.7km', 'emoji': '🫧', 'image': 'https://images.unsplash.com/photo-1520340356584-f9917d1eea6f?w=300&q=80'},
    {'badge': 'MOINCAR', 'name': '중고차 성능점검센터',      'sub': '중고차·성능점검',   'distance': '6.1km', 'emoji': '🚗', 'image': 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=300&q=80'},
    {'badge': '인기',    'name': '타이어 전문 할인점',        'sub': '타이어·얼라인먼트', 'distance': '6.8km', 'emoji': '🛞', 'image': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=300&q=80'},
    {'badge': '추천',    'name': '국산차 정비 전문점',        'sub': '정비·부품교환',     'distance': '7.2km', 'emoji': '🔧', 'image': 'https://images.unsplash.com/photo-1445991842772-097fea258e7b?w=300&q=80'},
    {'badge': 'MOINCAR', 'name': 'MOINCAR 인증 렌트카',     'sub': '렌트카·단기임대',   'distance': '7.9km', 'emoji': '🚗', 'image': 'https://images.unsplash.com/photo-1449965408869-eaa3f722e40d?w=300&q=80'},
    {'badge': '신규',    'name': '전기차 충전 정비소',        'sub': '전기차·충전설비',   'distance': '8.2km', 'emoji': '⚡', 'image': 'https://images.unsplash.com/photo-1593941707882-a5bba53b0998?w=300&q=80'},
    {'badge': '인기',    'name': '수입차 종합 케어센터',      'sub': '수입차·판금·도색',  'distance': '8.9km', 'emoji': '🏢', 'image': 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=300&q=80'},
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
    _scrollController.addListener(_onScroll);
    // 위치는 첫 프레임 이후에 시작 → 레이아웃 확정 뒤 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initLocation();
      _startGasTimer(); // 주유소 오버레이 4초 후 자동 숨김
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 상태바 높이를 한 번만 확정하여 이후 빌드에서 점프 방지
    final pad = MediaQuery.of(context).padding.top;
    if (!_topPadReady && pad > 0) {
      _cachedTopPad = pad;
      _topPadReady = true;
    }
    // 로고 이미지 프리캐시
    precacheImage(const AssetImage('assets/images/moincar_logo.png'), context);
  }

  // ── 스크롤 리스너 ────────────────────────────────────────────
  void _onScroll() {
    final offset = _scrollController.offset.clamp(0.0, double.infinity);
    final prev   = _scrollOffset;

    // 스크롤 변화량이 1px 미만이면 setState 스킵 (불필요한 리빌드 방지)
    if ((offset - prev).abs() < 1.0) return;

    setState(() => _scrollOffset = offset);

    // 스크롤 내릴 때 오버레이 즉시 숨김
    if (offset > 60 && prev <= 60 && _gasOverlayVisible) {
      _gasTimer?.cancel();
      setState(() => _gasOverlayVisible = false);
      // showCount 증가 (스크롤로 숨긴 것도 1회 카운트)
      if (_gasShowCount < 2) {
        _gasShowCount++;
        if (_gasShowCount >= 2) {
          _gasHideUntil = DateTime.now().add(const Duration(minutes: 1));
          _gasTimer = Timer(const Duration(minutes: 1), () {
            if (mounted) setState(() { _gasShowCount = 0; _gasHideUntil = null; });
          });
        }
      }
    }

    // 메인 상단으로 복귀 시 (60px 이하) 주유소 오버레이 재표시
    if (offset < 60 && prev >= 60) {
      _startGasTimer();
    }

    // BottomNav: 스크롤 중 숨김, 600ms 정지 후 복귀
    _navTimer?.cancel();
    if (_navVisible) setState(() => _navVisible = false);
    _navTimer = Timer(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _navVisible = true);
    });
  }

  // ★ 스크롤량만큼 헤더 전체가 올라감 (최대 _totalHeaderH)
  double get _headerSlide => _scrollOffset.clamp(0.0, _totalHeaderH);

  // 검색바 top 계산 (헤더 슬라이드 반영)
  double _searchBarTop(double topPad) =>
      topPad + _topBarH + _locBarH - _headerSlide;

  // ★ ListView 상단 패딩: 헤더 높이 - 슬라이드된 만큼 줄어듦
  double _contentTopPad(double topPad) =>
      topPad + _totalHeaderH - _headerSlide;

  // ── 위치 초기화 ──────────────────────────────────────────────
  Future<void> _initLocation() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.deniedForever || perm == LocationPermission.denied) {
        // 기본값 유지 — setState 불필요 (이미 '서울특별시 금천구 가산동')
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.low,  // low: 빠른 응답, UI 점프 최소화
            timeLimit: Duration(seconds: 5),
          ));
      if (!mounted) return;
      // 좌표만 먼저 저장 (UI 변경 없음)
      _currentLat = pos.latitude;
      _currentLng = pos.longitude;
      await _updateAddress(pos.latitude, pos.longitude);
      _sortNearby();
    } catch (_) {
      // 실패 시 기본값 유지 — setState 불필요
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

  // ── 카테고리 탭 핸들러 ──────────────────────────────────────────
  void _onCategoryTap(Map<String, dynamic> c) {
    final name  = c['name']  as String;
    final emoji = c['emoji'] as String;

    // 특수 처리: 주유소, 주차장, 렌트카, 중고차수출, 차량용품 → 스낵바
    const simpleCategories = ['주차장', '렌트카', '중고차수출', '차량용품'];
    if (simpleCategories.contains(name)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: const Color(0xFF0D1B2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        behavior: SnackBarBehavior.floating,
        content: Row(children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(child: Text('$name 카테고리 페이지 준비 중입니다.',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
        ]),
        duration: const Duration(seconds: 2),
      ));
      return;
    }

    // 주유소 → 기존 주유소 오버레이
    if (name == '주유소') {
      setState(() {
        _showGasOverlay = true;
        _gasShowCount++;
      });
      _startGasTimer();
      return;
    }

    // 오토바이 → MotorcycleScreen
    if (name == '오토바이') {
      Navigator.pushNamed(context, '/motorcycle');
      return;
    }

    // 정비 카테고리에 검사 통합 표시
    if (name == '정비') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CategoryLandingScreen(category: '정비/검사', emoji: '🔧'),
        ),
      );
      return;
    }

    // 중고차 → UsedCarMainScreen 직접 이동
    if (name == '중고차') {
      Navigator.pushNamed(context, '/used-car');
      return;
    }

    // 정비·세차·타이어·검사 → CategoryLandingScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryLandingScreen(category: name, emoji: emoji),
      ),
    );
  }

  // ── 주유소 오버레이 타이머 ──────────────────────────────────────
  // showCount 0,1 → 4초 표시 후 숨김
  // showCount 2    → 1분 잠금 (DateTime 기록)
  void _startGasTimer() {
    _gasTimer?.cancel();
    _gasRotateTimer?.cancel();

    // 1분 잠금 중이면 표시하지 않음
    if (_gasHideUntil != null && DateTime.now().isBefore(_gasHideUntil!)) return;

    // showCount 2 이상이면 1분 잠금 설정 후 종료
    if (_gasShowCount >= 2) {
      _gasHideUntil = DateTime.now().add(const Duration(minutes: 1));
      // 1분 후 자동 재활성화
      _gasTimer = Timer(const Duration(minutes: 1), () {
        if (mounted) setState(() { _gasShowCount = 0; _gasHideUntil = null; });
      });
      return;
    }

    // 표시
    setState(() { _gasOverlayVisible = true; _gasDisplayIndex = 0; });

    // 5초 후 숨김
    _gasTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      setState(() {
        _gasOverlayVisible = false;
        _gasShowCount++;          // 0→1 또는 1→2
        if (_gasShowCount >= 2) {
          // 두 번 다 봤음 → 1분 잠금
          _gasHideUntil = DateTime.now().add(const Duration(minutes: 1));
          // 1분 후 자동 리셋
          _gasTimer = Timer(const Duration(minutes: 1), () {
            if (mounted) setState(() { _gasShowCount = 0; _gasHideUntil = null; });
          });
        }
      });
    });
  }

  // ── 배너 타이머 ──────────────────────────────────────────────
  void _startBannerTimer() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 7), (_) {
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
    _gasTimer?.cancel();
    _gasRotateTimer?.cancel();
    _bannerController.dispose();
    _tabController.dispose();
    _navTimer?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    // 캐시된 topPad 사용 → 매 빌드마다 다른 값으로 점프하는 현상 방지
    final topPad = _topPadReady
        ? _cachedTopPad
        : MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    // BottomNav 높이: 60px + SafeArea bottom
    const double navH = 60.0;
    final double navTotalH = navH + bottomPad;

    return Scaffold(
      backgroundColor: _bg,
      resizeToAvoidBottomInset: false,  // 키보드 등장 시 레이아웃 쉬프트 방지
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
                const YoutubeShortSlider(),
                _buildQuickActions(),
                _buildUsedCarAxisCards(),
                _buildMapPreview(),
                _buildNearbySection(),
                _buildPromoBand(),
                _buildRecentSection(),
                _buildCloseSection(),
                _buildCompanySection(),
              ],
            ),
          ),

          // ── 헤더 전체 (로고+위치+검색) 한몸으로 스크롤 연동
          Positioned(
            top: topPad - _headerSlide,
            left: 0,
            right: 0,
            child: Column(
              children: [
                _buildTopLogoBar(),
                _buildLocationBar(),
                _buildSearchBar(),
              ],
            ),
          ),

          // ⛽ 주유소 오버레이는 배너 내부로 이동

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
        // 로고: 고정 크기 SizedBox로 감싸 로딩 전후 레이아웃 쉬프트 방지
        SizedBox(
          width: 120, height: 40,
          child: Image.asset(
            'assets/images/moincar_logo.png',
            height: 40,
            fit: BoxFit.contain,
            // frameBuilder: 첫 프레임부터 공간 확보 → 깜빡임 없음
            frameBuilder: (c, child, frame, _) => frame == null
                ? SizedBox(width: 120, height: 40,
                    child: Center(child: Text('MOINCAR',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900,
                          color: _accent, letterSpacing: 1))))
                : child,
            errorBuilder: (c, e, s) => SizedBox(
              width: 120, height: 40,
              child: Center(child: Text('MOINCAR',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900,
                    color: _accent, letterSpacing: 1))),
            ),
          ),
        ),
        const Spacer(),
        // 알림 (종 아이콘 - 모든 알림 통합, 배지 동적 표시)
        AnimatedBuilder(
          animation: AppState(),
          builder: (_, __) {
            final badgeCount = AppState().totalBidCount + AppState().inAppNotifications.length;
            return GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/notification'),
              child: Stack(clipBehavior: Clip.none, children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(color: _s1,
                      borderRadius: BorderRadius.circular(50), border: Border.all(color: _br)),
                  child: const Icon(Icons.notifications_none_rounded, color: _t2, size: 19),
                ),
                if (badgeCount > 0)
                  Positioned(right: -1, top: -1,
                    child: Container(
                      width: 16, height: 16,
                      decoration: const BoxDecoration(color: Color(0xFFE53935), shape: BoxShape.circle),
                      child: Center(child: Text(
                        badgeCount > 9 ? '9+' : '$badgeCount',
                        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                      )),
                    ),
                  ),
              ]),
            );
          },
        ),
        const SizedBox(width: 8),
        // 마이버튼 → 마이페이지 이동
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/my'),
          child: Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: _s1,
                borderRadius: BorderRadius.circular(50), border: Border.all(color: _br)),
            child: const Icon(Icons.person_outline_rounded, color: _t2, size: 19),
          ),
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
              boxShadow: [BoxShadow(color: _accent.withOpacity(0.6), blurRadius: 7)],
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
      child: Container(
        decoration: BoxDecoration(
          color: _isSearchActive ? const Color(0xFF0D1E3C) : _s1,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isSearchActive ? _accent.withOpacity(0.6) : _br),
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.2), blurRadius: 4)],
        ),
        child: Row(children: [
          const SizedBox(width: 14),
          GestureDetector(
            onTap: () {
              if (_searchQuery.isNotEmpty) {
                _executeSearch(_searchQuery);
              }
            },
            child: Icon(Icons.search_rounded,
              color: _isSearchActive ? _accent : const Color(0xFF3A6080), size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              focusNode: _searchFocus,
              onTap: () => setState(() => _isSearchActive = true),
              onChanged: (v) => setState(() => _searchQuery = v),
              onSubmitted: (v) => _executeSearch(v),
              style: GoogleFonts.notoSansKr(fontSize: 13, color: _t1),
              decoration: InputDecoration(
                hintText: '정비소, 세차장, 중고차, 주유소 검색...',
                hintStyle: GoogleFonts.notoSansKr(fontSize: 13, color: _t3),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          // 검색어 있을 때 X 버튼
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchCtrl.clear();
                setState(() { _searchQuery = ''; _isSearchActive = false; });
                _searchFocus.unfocus();
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                child: Icon(Icons.cancel, color: _t3, size: 16),
              ),
            ),
          // 마이크 버튼 → AI 음성 채팅
          GestureDetector(
            onTap: () => _showVoiceAiDialog(),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _isSearchActive ? _accent.withOpacity(0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(Icons.mic_rounded,
                color: _isSearchActive ? _accent : const Color(0xFF3A6080), size: 18),
            ),
          ),
        ]),
      ),
    );
  }

  void _executeSearch(String query) {
    if (query.trim().isEmpty) return;
    _searchFocus.unfocus();
    // 검색 결과 → StoreListScreen으로 이동
    Navigator.pushNamed(context, '/store-list');
    setState(() => _isSearchActive = false);
  }

  void _showVoiceAiDialog() {
    bool _isListening = false;
    String _voiceText = '';

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D1B2A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A5F),
                  borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _accent.withOpacity(0.4)),
                    ),
                    child: const Row(children: [
                      Text('🤖', style: TextStyle(fontSize: 12)),
                      SizedBox(width: 4),
                      Text('MOINCAR AI 음성 어시스턴트',
                        style: TextStyle(color: Color(0xFF4FC3F7), fontSize: 11, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // 음성 인식 상태 표시
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF020810),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _isListening
                      ? const Color(0xFF4FC3F7).withOpacity(0.6)
                      : const Color(0xFF1E3A5F)),
                ),
                child: Center(
                  child: _isListening
                    ? Column(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.graphic_eq, color: Color(0xFF4FC3F7), size: 32),
                        const SizedBox(height: 8),
                        Text('듣고 있습니다...',
                          style: GoogleFonts.notoSansKr(color: const Color(0xFF4FC3F7), fontSize: 13)),
                      ])
                    : Text(
                        _voiceText.isEmpty ? '마이크 버튼을 눌러 말씀해 주세요\n예) "가까운 정비소 찾아줘"' : _voiceText,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.notoSansKr(
                          color: _voiceText.isEmpty ? const Color(0xFF3A6080) : Colors.white,
                          fontSize: 13, height: 1.5),
                      ),
                ),
              ),
              const SizedBox(height: 16),
              // AI 빠른 질문 제안
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    '가까운 정비소', '엔진오일 교환', '타이어 점검', '세차장 추천', '중고차 시세'
                  ].map((q) => GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _searchCtrl.text = q;
                        _searchQuery = q;
                      });
                      _executeSearch(q);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A3A6E).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF1E3A5F)),
                      ),
                      child: Text(q,
                        style: GoogleFonts.notoSansKr(
                          color: const Color(0xFF7AB0D4), fontSize: 12)),
                    ),
                  )).toList(),
                ),
              ),
              const SizedBox(height: 20),
              // 마이크 버튼
              GestureDetector(
                onTap: () {
                  setModalState(() => _isListening = !_isListening);
                  if (!_isListening && _voiceText.isEmpty) {
                    setModalState(() => _voiceText = '가까운 엔진오일 교환 정비소 찾아줘');
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isListening
                      ? const Color(0xFF4FC3F7).withOpacity(0.2)
                      : const Color(0xFF1A3A6E),
                    border: Border.all(
                      color: _isListening
                        ? const Color(0xFF4FC3F7)
                        : const Color(0xFF1E3A5F),
                      width: 2),
                  ),
                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: _isListening ? const Color(0xFF4FC3F7) : const Color(0xFF7AB0D4),
                    size: 28),
                ),
              ),
            ],
          ),
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
              return RepaintBoundary(
               child: GestureDetector(
                onTap: () {
                  final route = b['route'] as String? ?? '';
                  if (route.isEmpty) {
                    showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (_) => _buildGasPopupDialog(),
                    );
                  } else {
                    Navigator.pushNamed(context, route);
                  }
                },
                child: Stack(fit: StackFit.expand, children: [
                // 배경 사진 이미지 (네트워크)
                Image.network(
                  b['image'] as String,
                  fit: BoxFit.cover,
                  cacheWidth: 720,  // 메모리 최적화: 720px 이하로 캐시
                  errorBuilder: (c, e, s) => Container(color: b['color'] as Color),
                  loadingBuilder: (c, child, progress) =>
                      progress == null ? child : Container(color: b['color'] as Color),
                ),
                // 어두운 그라디언트 오버레이 (텍스트 가독성)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.15),
                        Colors.black.withOpacity(0.75),
                      ],
                    ),
                  ),
                ),
                // 좌측 하단 텍스트 (클릭 시 해당 페이지 이동)
                Positioned(left: 22, right: 22, bottom: 28,
                  child: GestureDetector(
                    onTap: () {
                      final route = b['route'] as String? ?? '';
                      if (route.isEmpty) {
                        // 주유 배너 → 팝업 표시
                        showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (_) => _buildGasPopupDialog(),
                        );
                      } else {
                        Navigator.pushNamed(context, route);
                      }
                    },
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                      // 카테고리 태그
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: _accent.withOpacity(0.2),
                          border: Border.all(color: _accent.withOpacity(0.5)),
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
                      Row(children: [
                        Expanded(child: Text(b['sub'] as String,
                            style: GoogleFonts.notoSansKr(
                                fontSize: 13, color: Colors.white70,
                                shadows: [Shadow(color: Colors.black45, blurRadius: 4)]))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Text('바로가기', style: GoogleFonts.notoSansKr(
                                fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700)),
                            const SizedBox(width: 3),
                            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 10),
                          ]),
                        ),
                      ]),
                    ]),
                  ),
                ),
                // ⛽ 주유 오버레이 (배너 상단 우측)
                Positioned(
                  top: 12, right: 12,
                  child: AnimatedOpacity(
                    opacity: _gasOverlayVisible ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 400),
                    child: IgnorePointer(
                      ignoring: !_gasOverlayVisible,
                      child: _buildGasMiniOverlay(),
                    ),
                  ),
                ),
              ]))); // RepaintBoundary + GestureDetector + Stack
            },
          ),
        ),
        // 인디케이터 삭제됨
        // 카테고리 라벨 뱃지 삭제됨

        // (주유소 오버레이는 메인 Stack으로 이동)
      ]),
    );
  }

  // ──────────────────────────────────────────────────────────
  // ⛽ 주유소 현황 오버레이 위젯 빌드 (인라인)
  // ──────────────────────────────────────────────────────────
  // 주유소 데이터 — 휘발유 최저가순 정렬
  // gasoline: 휘발유, diesel: 경유, isLowest: 최저가 여부
  // 거리순 정렬 (dist 숫자 오름차순) — 최저가는 gasoline 기준 자동 계산
  static const List<Map<String,dynamic>> _gasList = [
    {'name': 'GS칼텍스 수성점', 'dist': '0.3km', 'distN': 0.3, 'gasoline': 1682, 'diesel': 1571},
    {'name': 'SK에너지 범어점',  'dist': '0.7km', 'distN': 0.7, 'gasoline': 1658, 'diesel': 1542},
    {'name': '현대오일 동성점',  'dist': '1.1km', 'distN': 1.1, 'gasoline': 1671, 'diesel': 1558},
  ];

  // ── 최저가 주유소 인덱스 계산 헬퍼 ───────────────────────────
  int get _lowestGasIdx {
    int idx = 0;
    int lowest = _gasList[0]['gasoline'] as int;
    for (int i = 1; i < _gasList.length; i++) {
      if ((_gasList[i]['gasoline'] as int) < lowest) {
        lowest = _gasList[i]['gasoline'] as int;
        idx = i;
      }
    }
    return idx;
  }

  // ── ⛽ 주유소 팝업 다이얼로그 ─────────────────────────────────
  Widget _buildGasPopupDialog() {
    final lowestGasIdx = _lowestGasIdx;
    return Dialog(
      backgroundColor: const Color(0xFF0D1B2A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 30),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // ─── 헤더 ───
            Row(children: [
              const Text('⛽', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              const Expanded(child: Text('인근 주유소 가격 비교',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white))),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, color: Color(0xFF8BA3BC), size: 20)),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              Text('현재 위치: $_currentAddress',
                style: const TextStyle(fontSize: 11, color: Color(0xFFB0BEC5))),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF4FC3F7).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: const Color(0xFF4FC3F7).withOpacity(0.4)),
                ),
                child: const Text('거리순', style: TextStyle(fontSize: 10, color: Color(0xFF4FC3F7), fontWeight: FontWeight.w700)),
              ),
            ]),
            const SizedBox(height: 14),
            // ─── 주유소 카드 목록 ───
            ...List.generate(_gasList.length, (i) {
              final s = _gasList[i];
              final isLowest = i == lowestGasIdx;
              final Color col = isLowest
                  ? const Color(0xFFFF6B35)
                  : (i == 0 ? const Color(0xFF4FC3F7) : const Color(0xFF10B981));
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: col.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: col.withOpacity(isLowest ? 0.7 : 0.25), width: isLowest ? 1.5 : 1),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A1628),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: col.withOpacity(0.4)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.location_on, color: col, size: 11),
                        const SizedBox(width: 3),
                        Text(s['dist'] as String,
                          style: TextStyle(fontSize: 11, color: col, fontWeight: FontWeight.w700)),
                      ]),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(s['name'] as String,
                      style: TextStyle(fontSize: 13,
                        color: isLowest ? Colors.white : const Color(0xFFE8F4FF),
                        fontWeight: isLowest ? FontWeight.w800 : FontWeight.w600))),
                    if (isLowest) Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: const Color(0xFFFF6B35).withOpacity(0.5)),
                      ),
                      child: const Text('최저가', style: TextStyle(fontSize: 10, color: Color(0xFFFF6B35), fontWeight: FontWeight.w800)),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A1628),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: col.withOpacity(0.3)),
                      ),
                      child: Column(children: [
                        const Text('휘발유', style: TextStyle(fontSize: 10, color: Color(0xFFB0BEC5))),
                        const SizedBox(height: 3),
                        Text('${s['gasoline']}원',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900,
                            color: isLowest ? const Color(0xFFFF6B35) : col)),
                      ]),
                    )),
                    const SizedBox(width: 8),
                    Expanded(child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A1628),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF1E3A5F)),
                      ),
                      child: Column(children: [
                        const Text('경유', style: TextStyle(fontSize: 10, color: Color(0xFFB0BEC5))),
                        const SizedBox(height: 3),
                        Text('${s['diesel']}원',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF7AB0D4))),
                      ]),
                    )),
                    const SizedBox(width: 8),
                    // 카카오맵 길찾기
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: const Color(0xFFFFE000),
                          content: Row(children: [
                            const Text('🗺️', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Expanded(child: Text('카카오맵: ${s['name']}',
                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 12))),
                          ]),
                          duration: const Duration(seconds: 2),
                        ));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE000).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFFE000).withOpacity(0.5)),
                        ),
                        child: const Column(mainAxisSize: MainAxisSize.min, children: [
                          Text('🗺️', style: TextStyle(fontSize: 13)),
                          SizedBox(height: 2),
                          Text('길찾기', style: TextStyle(fontSize: 9, color: Color(0xFFFFE000), fontWeight: FontWeight.w700)),
                        ]),
                      ),
                    ),
                  ]),
                ]),
              );
            }),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    backgroundColor: Color(0xFFFFE000),
                    content: Row(children: [
                      Text('🗺️', style: TextStyle(fontSize: 14)),
                      SizedBox(width: 6),
                      Expanded(child: Text('카카오맵에서 주유소를 검색합니다',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 12))),
                    ]),
                    duration: Duration(seconds: 2),
                  ));
                },
                icon: const Text('🗺️', style: TextStyle(fontSize: 14)),
                label: const Text('카카오맵으로 주유소 찾기',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFE000),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text('※ 오피넷 기준 · 실시간 가격은 앱에서 확인',
              style: TextStyle(fontSize: 10, color: const Color(0xFFB0BEC5).withOpacity(0.6))),
          ]),
        ),
      ),
    );
  }

  // ── ⛽ 배너 내 미니 오버레이 (탭 시 팝업) ────────────────────
  Widget _buildGasMiniOverlay() {
    final lowestGasIdx = _lowestGasIdx;
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => _buildGasPopupDialog(),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.75),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFFF6B35).withOpacity(0.6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              const Text('⛽', style: TextStyle(fontSize: 10)),
              const SizedBox(width: 4),
              const Text('주유소 가격',
                style: TextStyle(fontSize: 9, color: Color(0xFF4FC3F7), fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 4),
            ..._gasList.asMap().entries.map((e) {
              final i = e.key;
              final s = e.value;
              final isLowest = i == lowestGasIdx;
              final col = isLowest ? const Color(0xFFFF6B35) : const Color(0xFFB0BEC5);
              return Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(s['dist'] as String,
                    style: TextStyle(fontSize: 8, color: col.withOpacity(0.8))),
                  const SizedBox(width: 3),
                  if (isLowest)
                    Container(
                      margin: const EdgeInsets.only(right: 3),
                      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(3)),
                      child: const Text('최저', style: TextStyle(fontSize: 7, color: Color(0xFFFF6B35), fontWeight: FontWeight.w800)),
                    )
                  else
                    const SizedBox(width: 20),
                  Text(s['name'] as String,
                    style: TextStyle(fontSize: 9, color: col, fontWeight: isLowest ? FontWeight.w700 : FontWeight.w400)),
                  const SizedBox(width: 4),
                  Text('${s['gasoline']}원',
                    style: TextStyle(fontSize: 10, color: col, fontWeight: isLowest ? FontWeight.w900 : FontWeight.w500)),
                ]),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // ── 주유소 카테고리 페이지 이동 ───────────────────────────────
  void _navigateToGasCategory() {
    // 주유소 카테고리 페이지로 이동 (카테고리 페이지 연동 준비)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFF4FC3F7),
        content: Row(children: [
          Text('⛽', style: TextStyle(fontSize: 16)),
          SizedBox(width: 8),
          Expanded(child: Text('주유소 카테고리 페이지로 이동합니다',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600))),
        ]),
        duration: Duration(seconds: 2),
      ),
    );
    // TODO: 주유소 카테고리 페이지 완성 후 아래 코드로 교체
    // Navigator.push(context, MaterialPageRoute(
    //   builder: (_) => CategoryStoreListScreen(category: '주유소', emoji: '⛽'),
    // ));
  }

  // ══════════════════════════════════════════════════════════════
  // 카테고리 — 10개 (5+5 두 줄) 이모지 렌더링 수정
  // ══════════════════════════════════════════════════════════════
  Widget _buildCategoryGrid() {
    final row1 = _categories.sublist(0, 5);
    final row2 = _categories.sublist(5, 10);

    // 이모지 표시: TextStyle에 fontFamily 지정하지 않음
    Widget catItem(Map<String, dynamic> c) {
      // 주차장은 P 간판 아이콘으로 특별 처리
      final isParking = c['name'] == '주차장';
      return GestureDetector(
        onTap: () => _onCategoryTap(c),
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
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: Center(
                child: isParking
                    ? Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1565C0),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [BoxShadow(
                            color: const Color(0xFF1E88E5).withOpacity(0.5),
                            blurRadius: 6,
                          )],
                        ),
                        child: const Center(
                          child: Text('P',
                            style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w900,
                              color: Colors.white, fontStyle: FontStyle.italic,
                              height: 1.0,
                            ),
                          ),
                        ),
                      )
                    : Text(
                        c['emoji'] as String,
                        style: const TextStyle(fontSize: 19, height: 1.0),
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
            // storeId: 1,2,3... (AppData.stores 인덱스 기준)
            final storeId = (i % AppData.stores.length) + 1;
            return GestureDetector(
              onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const StoreDetailScreen(),
                  settings: RouteSettings(arguments: storeId))),
              child: Container(
              width: cardW,
              margin: EdgeInsets.only(right: i < _stores.length - 1 ? 14 : 0),
              decoration: BoxDecoration(
                color: _s1,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _br.withOpacity(0.5)),
                boxShadow: [BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Stack(children: [
                    SizedBox(
                      width: double.infinity, height: imgH,
                      child: Image.network(s['image'] as String, fit: BoxFit.cover,
                          errorBuilder: (c, e, st) => Container(
                              color: _s2,
                              child: Center(child: Text(s['emoji'] as String,
                                  style: const TextStyle(fontSize: 60)))),
                          loadingBuilder: (c, child, p) =>
                              p == null ? child : Container(color: _s2)),
                    ),
                    Positioned.fill(child: Container(
                      decoration: BoxDecoration(gradient: LinearGradient(
                          begin: Alignment.topCenter, end: Alignment.bottomCenter,
                          colors: [Colors.transparent, _bg.withOpacity(0.55)])),
                    )),
                    Positioned(top: 10, left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: _bg.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _accent.withOpacity(0.35)),
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
            ), // Container
            ); // GestureDetector
          },
        ),
      ),
    ]);
  }

  // ══════════════════════════════════════════════════════════════
  // 빠른기능 — 4칸 (타이틀 포함)
  // ══════════════════════════════════════════════════════════════
  Widget _buildQuickActions() {
    // 4가지 테마 이름
    final List<String> themeNames = ['긴급출동', '내 차 시세', '자동차뉴스', '이동리워드'];
    final List<String> themeSubtitles = ['24시간 긴급', '무료 조회', '최신 정보', '포인트 적립'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── '빠른기능' 섹션 타이틀 ──────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 26, 16, 14),
          child: Row(
            children: [
              Container(
                width: 4, height: 20,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFF6B6B), Color(0xFF9B7CFF)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 9),
              Text(
                '빠른기능',
                style: GoogleFonts.notoSansKr(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '자주 쓰는 서비스',
                style: GoogleFonts.notoSansKr(
                  color: const Color(0xFF556677),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),

        // ── 4개 버튼 그리드 ─────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: _quickItems.asMap().entries.map((e) {
              final idx = e.key;
              final item = e.value;
              final bgColor = item['color'] as Color;
              final aColor = item['aColor'] as Color;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (idx == 0) Navigator.pushNamed(context, '/emergency');
                    else if (idx == 1) Navigator.pushNamed(context, '/car-price');
                    else if (idx == 2) Navigator.pushNamed(context, '/news');
                    else if (idx == 3) Navigator.pushNamed(context, '/reward');
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.fromLTRB(4, 18, 4, 18),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: aColor.withOpacity(0.35)),
                      boxShadow: [
                        BoxShadow(
                          color: aColor.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.2),
                          border: Border.all(color: aColor.withOpacity(0.4)),
                        ),
                        child: Icon(item['icon'] as IconData, color: aColor, size: 26),
                      ),
                      const SizedBox(height: 10),
                      // 테마 이름 (큰 글씨)
                      Text(
                        themeNames[idx],
                        style: GoogleFonts.notoSansKr(
                          fontSize: 10,
                          color: aColor,
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      // 서브타이틀 (작은 글씨)
                      Text(
                        themeSubtitles[idx],
                        style: GoogleFonts.notoSansKr(
                          fontSize: 9,
                          color: aColor.withOpacity(0.6),
                          height: 1.2,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ]),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // 중고차 3축 진입 카드 (헤이딜러형 / 엔카형 / KAA협회형)
  // ══════════════════════════════════════════════════════════════
  Widget _buildUsedCarAxisCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 28, 16, 14),
          child: Row(children: [
            Container(
              width: 4, height: 20,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Color(0xFF4FC3F7), Color(0xFF10B981)],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 9),
            Text('중고차 서비스',
              style: GoogleFonts.notoSansKr(
                color: Colors.white, fontSize: 17,
                fontWeight: FontWeight.bold, letterSpacing: -0.3)),
            const SizedBox(width: 8),
            Text('3가지 방법으로 시작하세요',
              style: GoogleFonts.notoSansKr(
                color: const Color(0xFF556677), fontSize: 12, fontWeight: FontWeight.w400)),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Column(children: [
            // ── 1축: 내차시세조회 / 내차팔기 (헤이딜러형) ──────────
            _usedCarAxisCard(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D2040), Color(0xFF0A3060)],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderColor: const Color(0xFF4FC3F7),
              icon: Icons.sell_rounded,
              iconColor: const Color(0xFF4FC3F7),
              badge: '헤이딜러형',
              badgeColor: const Color(0xFF4FC3F7),
              title: '내 차 시세조회 / 팔기',
              subtitle: '차량번호 입력 → 딜러 역경매 → 최고가 매입',
              bullets: ['차량번호만 입력하면 즉시 시세 확인', '가까운 딜러들이 경쟁적으로 견적 제안', '직거래 매물 등록도 바로 가능'],
              bulletColor: const Color(0xFF4FC3F7),
              onTap: () => Navigator.pushNamed(context, '/used-car', arguments: 0),
              actionLabel: '시세 조회 · 판매 시작',
              actionColor: const Color(0xFF4FC3F7),
              actionTextColor: Colors.black,
            ),
            const SizedBox(height: 10),
            // ── 2축: 중고차 사기 정밀 검색 (엔카형) ────────────────
            _usedCarAxisCard(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D2A1E), Color(0xFF0A2820)],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderColor: const Color(0xFF10B981),
              icon: Icons.search_rounded,
              iconColor: const Color(0xFF10B981),
              badge: '엔카형',
              badgeColor: const Color(0xFF10B981),
              title: '내 차 사기 정밀검색',
              subtitle: '제조사→모델→연식→연료 세부 조건 검색',
              bullets: ['제조사·모델·세대·트림 계층 필터', '연식·주행거리·가격대·연료 상세 조건', '딜러 매물 + 개인 직거래 통합 검색'],
              bulletColor: const Color(0xFF10B981),
              onTap: () => Navigator.pushNamed(context, '/used-car',
                arguments: {'initialTab': 1, 'openSearch': true}),
              actionLabel: '정밀 검색 시작',
              actionColor: const Color(0xFF10B981),
              actionTextColor: Colors.white,
            ),
            const SizedBox(height: 10),
            // ── 3축: KAA 딜러/점포 견적 연결 ──────────────────────
            _usedCarAxisCard(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A0D2E), Color(0xFF200A38)],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderColor: const Color(0xFF8B5CF6),
              icon: Icons.handshake_rounded,
              iconColor: const Color(0xFF8B5CF6),
              badge: 'KAA협회형',
              badgeColor: const Color(0xFF8B5CF6),
              title: 'KAA 딜러/점포 견적연결',
              subtitle: 'KAA 인증 딜러가 직접 견적·방문 서비스',
              bullets: ['KAA 인증 딜러와 직접 연결', '정비·세차·타이어 전문 점포 견적', '1:1 채팅 → 협의 후 전화 연결'],
              bulletColor: const Color(0xFF8B5CF6),
              onTap: () => Navigator.pushNamed(context, '/used-car', arguments: 0),
              actionLabel: '딜러 견적 연결',
              actionColor: const Color(0xFF8B5CF6),
              actionTextColor: Colors.white,
            ),
          ]),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _usedCarAxisCard({
    required Gradient gradient,
    required Color borderColor,
    required IconData icon,
    required Color iconColor,
    required String badge,
    required Color badgeColor,
    required String title,
    required String subtitle,
    required List<String> bullets,
    required Color bulletColor,
    required VoidCallback onTap,
    required String actionLabel,
    required Color actionColor,
    required Color actionTextColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor.withOpacity(0.4), width: 1.5),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: iconColor.withOpacity(0.3)),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: badgeColor.withOpacity(0.4)),
                  ),
                  child: Text(badge,
                    style: TextStyle(color: badgeColor, fontSize: 9, fontWeight: FontWeight.w800)),
                ),
              ]),
              const SizedBox(height: 3),
              Text(title,
                style: GoogleFonts.notoSansKr(
                  color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
              Text(subtitle,
                style: GoogleFonts.notoSansKr(
                  color: const Color(0xFF889BAB), fontSize: 11)),
            ])),
          ]),
          const SizedBox(height: 12),
          ...bullets.map((b) => Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(children: [
              Icon(Icons.check_circle_rounded, color: bulletColor, size: 13),
              const SizedBox(width: 6),
              Expanded(child: Text(b,
                style: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 11))),
            ]),
          )),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: actionColor,
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(actionLabel,
                  style: TextStyle(
                    color: actionTextColor, fontSize: 13, fontWeight: FontWeight.w800)),
                const SizedBox(width: 6),
                Icon(Icons.arrow_forward_ios_rounded, color: actionTextColor, size: 12),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // 지도 미리보기
  // ══════════════════════════════════════════════════════════════
  Widget _buildMapPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 26, 16, 10),
          child: _sectionHeader('🗺️  내주변 점포 지도', ''),
        ),
        Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 0),
      height: 240,  // 220 → 240 (+20px)
      decoration: BoxDecoration(
        color: const Color(0xFF050E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _br.withOpacity(0.4)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(children: [
          Positioned.fill(child: CustomPaint(painter: _NavyGridPainter())),
          Positioned.fill(child: Image.asset('assets/images/map_sample.png',
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => const SizedBox())),
          Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.45))),
          Positioned.fill(child: Center(child: Container(
            width: 20, height: 20,
            decoration: BoxDecoration(
              color: _accent, shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: _accent.withOpacity(0.3), blurRadius: 0, spreadRadius: 7),
                BoxShadow(color: _accent.withOpacity(0.15), blurRadius: 0, spreadRadius: 15),
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
                color: _bg.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _br.withOpacity(0.5)),
              ),
              child: Row(children: [
                Text('📍  반경 5km 이내',
                    style: GoogleFonts.notoSansKr(fontSize: 13, color: _t2)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: _accentS, borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _accent.withOpacity(0.4)),
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
        ),
      ],
    );
  }

  Widget _mapPin({double? left, double? right, double? top, double? bottom, required String emoji}) {
    return Positioned(
      left: left, right: right, top: top, bottom: bottom,
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: _bg.withOpacity(0.85), shape: BoxShape.circle,
          border: Border.all(color: _accent.withOpacity(0.4)),
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
        child: _sectionHeader('📍  주변 점포', '더보기'),
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
            final storeId = (i % AppData.stores.length) + 1;
            return GestureDetector(
              onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const StoreDetailScreen(),
                  settings: RouteSettings(arguments: storeId))),
              child: Container(
              width: cardW,
              margin: EdgeInsets.only(right: i < _nearbyStores.length - 1 ? 14 : 0),
              decoration: BoxDecoration(
                color: _s1,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _br.withOpacity(0.5)),
                boxShadow: [BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Stack(children: [
                    SizedBox(
                      width: double.infinity, height: imgH,
                      child: Image.network(s['image'] as String, fit: BoxFit.cover,
                          errorBuilder: (c, e, st) => Container(
                              color: _s2,
                              child: Center(child: Text(s['emoji'] as String,
                                  style: const TextStyle(fontSize: 70)))),
                          loadingBuilder: (c, child, p) => p == null ? child : Container(color: _s2)),
                    ),
                    Positioned.fill(child: Container(
                      decoration: BoxDecoration(gradient: LinearGradient(
                          begin: Alignment.topCenter, end: Alignment.bottomCenter,
                          colors: [Colors.transparent, _bg.withOpacity(0.5)])),
                    )),
                    Positioned(top: 12, left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _bg.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _accent.withOpacity(0.35)),
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
              ]), // Column
              ), // Container (child of GestureDetector)
            ); // GestureDetector
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
                  _bg.withOpacity(0.0),
                  _bg.withOpacity(0.95),
                ],
              ),
            ),
            child: Center(
              child: Icon(
                Icons.chevron_right_rounded,
                color: _t2.withOpacity(0.6),
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
        border: Border.all(color: _accentS.withOpacity(0.5)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(children: [
          Positioned(right: -20, top: -20,
            child: Container(width: 130, height: 130,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _accent.withOpacity(0.06)))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            child: Row(children: [
              Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: _accent.withOpacity(0.3)),
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
                    side: BorderSide(color: _accent.withOpacity(0.4)),
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
            final storeId = (i % AppData.stores.length) + 1;
            return GestureDetector(
              onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const StoreDetailScreen(),
                  settings: RouteSettings(arguments: storeId))),
              child: Container(
              width: cardW,
              margin: EdgeInsets.only(right: i < _recentStores.length - 1 ? 14 : 0),
              decoration: BoxDecoration(
                color: _s1,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _br.withOpacity(0.5)),
                boxShadow: [BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: SizedBox(
                    width: double.infinity, height: imgH,
                    child: Image.network(s['image'] as String, fit: BoxFit.cover,
                        errorBuilder: (c, e, st) => Container(
                            color: _s2,
                            child: Center(child: Text(s['emoji'] as String,
                                style: const TextStyle(fontSize: 60)))),
                        loadingBuilder: (c, child, p) => p == null ? child : Container(color: _s2)),
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
            ), // Container
            ); // GestureDetector
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
      ...list.asMap().entries.map((entry) {
        final i = entry.key;
        final s = entry.value;
        final storeId = (i % AppData.stores.length) + 1;
        return GestureDetector(
          onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const StoreDetailScreen(),
              settings: RouteSettings(arguments: storeId))),
          child: Container(
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 16),
          decoration: BoxDecoration(
            color: _s1,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _br.withOpacity(0.5)),
            boxShadow: [BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Stack(children: [
                SizedBox(
                  width: double.infinity, height: 200,
                  child: Image.network(s['image'] as String, fit: BoxFit.cover,
                      errorBuilder: (c, e2, st) => Container(
                          color: _s2,
                          child: Center(child: Text(s['emoji'] as String,
                              style: const TextStyle(fontSize: 70)))),
                      loadingBuilder: (c, child, p) => p == null ? child : Container(color: _s2)),
                ),
                Positioned.fill(child: Container(
                  decoration: BoxDecoration(gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [Colors.transparent, _bg.withOpacity(0.5)])),
                )),
                Positioned(top: 12, left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _bg.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _accent.withOpacity(0.35)),
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
                      color: _bg.withOpacity(0.85),
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
          ), // Container
        ); // GestureDetector
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
              border: Border.all(color: _br.withOpacity(0.5)),
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

        Container(height: 1, color: _br.withOpacity(0.3)),

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
            Container(height: 1, color: _br.withOpacity(0.25)),
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
            Container(height: 1, color: _br.withOpacity(0.25)),
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
                  border: Border.all(color: _br.withOpacity(0.5)),
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
                    fontSize: 12, color: _t3.withOpacity(0.7))),

            const SizedBox(height: 16),
            Container(height: 1, color: _br.withOpacity(0.25)),
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
            Container(height: 1, color: _br.withOpacity(0.2)),
            const SizedBox(height: 12),

            Text(
              '(사)한국자동차협회는 통신판매중개자로 거래 당사자가 아니므로,\n'
              '판매자가 등록한 상품 및 거래에 대해 책임을 지지 않습니다.',
              style: GoogleFonts.notoSansKr(
                  fontSize: 10, color: _t3.withOpacity(0.6), height: 1.8),
            ),

            const SizedBox(height: 12),
            Container(height: 1, color: _br.withOpacity(0.2)),
            const SizedBox(height: 10),

            // 저작권 + 이동리워드
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(
                child: Text('ⓒ 한국자동차협회 All Rights Reserved.',
                    style: GoogleFonts.notoSansKr(
                        fontSize: 10, color: _t3.withOpacity(0.5))),
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1040),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFF6B4EFF).withOpacity(0.5)),
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
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.45)),
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
                    color: _accent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _accent.withOpacity(0.25)),
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
        color: _accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _accent.withOpacity(0.3)),
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
        border: Border.all(color: _accent.withOpacity(0.35)),
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
        color: _accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _accent.withOpacity(0.3)),
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
        border: Border.all(color: _accent.withOpacity(0.35)),
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
      ..color = const Color(0xFF142244).withOpacity(0.5)
      ..strokeWidth = 0.5;
    const sp = 28.0;
    for (double x = 0; x < size.width; x += sp) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += sp) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
    final road = Paint()
      ..color = const Color(0xFF1A3A6E).withOpacity(0.35)
      ..strokeWidth = 3;
    canvas.drawLine(Offset(0, size.height * 0.5), Offset(size.width, size.height * 0.5), road);
    canvas.drawLine(Offset(size.width * 0.4, 0), Offset(size.width * 0.4, size.height), road);
  }
  @override bool shouldRepaint(_) => false;
}


