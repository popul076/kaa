import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/app_state.dart';
import '../theme/app_theme.dart';
import 'store_screens.dart';
import 'quote_screens.dart';

// ── 공통 컬러 ───────────────────────────────────────────
const _bg     = Color(0xFF020810);
const _card   = Color(0xFF0D1B2A);
const _navy   = Color(0xFF0A1628);
const _accent = Color(0xFF4FC3F7);
const _green  = Color(0xFF10B981);
const _orange = Color(0xFFFF6B35);
const _border = Color(0xFF1E3A5F);
const _t1     = Colors.white;
const _t2     = Color(0xFFB0BEC5);

// ══════════════════════════════════════════════════════════════
// 카테고리별 업종 랜딩 화면
// 진입: 홈 카테고리 탭 → CategoryLandingScreen(category, emoji)
// 지도(시뮬레이션) + 근처 업체 목록 + 견적요청 배너
// ══════════════════════════════════════════════════════════════
class CategoryLandingScreen extends StatefulWidget {
  final String category;
  final String emoji;
  const CategoryLandingScreen({
    super.key,
    required this.category,
    required this.emoji,
  });

  @override
  State<CategoryLandingScreen> createState() => _CategoryLandingScreenState();
}

class _CategoryLandingScreenState extends State<CategoryLandingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 필터
  String _sortBy = '거리순';
  final List<String> _sortOptions = ['거리순', '평점순', '리뷰순', '견적빠른순'];
  String _selectedBadge = '전체';
  final List<String> _badges = ['전체', 'MOINCAR 인증', '추천', '신규', '인기'];

  // 가짜 GPS 좌표 (대구 수성구 중심)
  final double _myLat = 35.8565;
  final double _myLng = 128.6340;

  // 지도 핀 애니메이션
  bool _mapExpanded = false;

  @override
  void initState() {
    super.initState();
    // 중고차 카테고리는 UsedCarMainScreen으로 직접 리다이렉트
    if (widget.category == '중고차') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/used-car');
      });
    }
    // 견적 데이터 미리 로드 (배너 즉시 표시용)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppState().initDummyEstimates();
    });
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 카테고리별 업체 목록 생성
  List<Map<String, dynamic>> get _stores {
    final cat = widget.category;
    final base = <Map<String, dynamic>>[
      {
        'badge': 'MOINCAR 인증',
        'name': '$cat 전문 프리미엄센터',
        'sub': '${widget.emoji} MOINCAR 공식인증점',
        'distance': '1.2km',
        'rating': 4.9,
        'reviews': 128,
        'lat': _myLat + 0.005,
        'lng': _myLng + 0.003,
        'image': _catImage(cat, 0),
        'tags': _catTags(cat),
        'hours': '08:00 - 20:00',
        'phone': '053-123-4567',
        'priceRange': _catPriceRange(cat),
        'estimateAvg': '15분',
        'hasVideo': true,
      },
      {
        'badge': '추천',
        'name': '${cat} 빠른견적 전문점',
        'sub': '⚡ 10분 내 견적 완료',
        'distance': '2.1km',
        'rating': 4.7,
        'reviews': 89,
        'lat': _myLat - 0.004,
        'lng': _myLng + 0.006,
        'image': _catImage(cat, 1),
        'tags': _catTags(cat),
        'hours': '09:00 - 19:00',
        'phone': '053-234-5678',
        'priceRange': _catPriceRange(cat),
        'estimateAvg': '8분',
        'hasVideo': false,
      },
      {
        'badge': '인기',
        'name': '합리적 ${cat} 케어샵',
        'sub': '🔥 이번 달 견적 42건',
        'distance': '3.4km',
        'rating': 4.6,
        'reviews': 204,
        'lat': _myLat + 0.008,
        'lng': _myLng - 0.005,
        'image': _catImage(cat, 2),
        'tags': _catTags(cat),
        'hours': '08:30 - 18:30',
        'phone': '053-345-6789',
        'priceRange': _catPriceRange(cat),
        'estimateAvg': '12분',
        'hasVideo': true,
      },
      {
        'badge': 'MOINCAR 인증',
        'name': '${cat} 종합 서비스센터',
        'sub': '🏆 지역 최우수 업체',
        'distance': '4.0km',
        'rating': 4.8,
        'reviews': 156,
        'lat': _myLat - 0.006,
        'lng': _myLng - 0.004,
        'image': _catImage(cat, 3),
        'tags': _catTags(cat),
        'hours': '07:00 - 21:00',
        'phone': '053-456-7890',
        'priceRange': _catPriceRange(cat),
        'estimateAvg': '10분',
        'hasVideo': false,
      },
      {
        'badge': '신규',
        'name': '신개념 ${cat} 스튜디오',
        'sub': '✨ 신규오픈 이벤트 진행중',
        'distance': '5.1km',
        'rating': 4.5,
        'reviews': 34,
        'lat': _myLat + 0.010,
        'lng': _myLng + 0.008,
        'image': _catImage(cat, 4),
        'tags': _catTags(cat),
        'hours': '10:00 - 20:00',
        'phone': '053-567-8901',
        'priceRange': _catPriceRange(cat),
        'estimateAvg': '20분',
        'hasVideo': false,
      },
      {
        'badge': '추천',
        'name': '가성비 최고 ${cat} 샵',
        'sub': '💰 가격 대비 최고 만족도',
        'distance': '6.3km',
        'rating': 4.4,
        'reviews': 311,
        'lat': _myLat - 0.009,
        'lng': _myLng + 0.010,
        'image': _catImage(cat, 0),
        'tags': _catTags(cat),
        'hours': '08:00 - 18:00',
        'phone': '053-678-9012',
        'priceRange': _catPriceRange(cat),
        'estimateAvg': '18분',
        'hasVideo': true,
      },
      {
        'badge': '인기',
        'name': '전문가 ${cat} 클리닉',
        'sub': '👨‍🔧 15년 경력 전문가 직접 시공',
        'distance': '7.8km',
        'rating': 4.9,
        'reviews': 98,
        'lat': _myLat + 0.012,
        'lng': _myLng - 0.009,
        'image': _catImage(cat, 1),
        'tags': _catTags(cat),
        'hours': '09:00 - 18:00',
        'phone': '053-789-0123',
        'priceRange': _catPriceRange(cat),
        'estimateAvg': '25분',
        'hasVideo': false,
      },
    ];

    // 필터 적용
    var result = base;
    if (_selectedBadge != '전체') {
      result = result.where((s) => s['badge'] == _selectedBadge).toList();
    }

    // 정렬
    switch (_sortBy) {
      case '거리순':
        result.sort((a, b) =>
            (double.parse((a['distance'] as String).replaceAll('km', '')))
                .compareTo(double.parse(
                    (b['distance'] as String).replaceAll('km', ''))));
        break;
      case '평점순':
        result.sort((a, b) =>
            (b['rating'] as double).compareTo(a['rating'] as double));
        break;
      case '리뷰순':
        result.sort((a, b) =>
            (b['reviews'] as int).compareTo(a['reviews'] as int));
        break;
      case '견적빠른순':
        result.sort((a, b) =>
            int.parse((a['estimateAvg'] as String).replaceAll('분', ''))
                .compareTo(int.parse(
                    (b['estimateAvg'] as String).replaceAll('분', ''))));
        break;
    }
    return result;
  }

  String _catImage(String cat, int idx) {
    final images = {
      '정비': [
        'https://images.unsplash.com/photo-1632823469850-2f77dd9c7f93?w=400&q=80',
        'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=400&q=80',
        'https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?w=400&q=80',
        'https://images.unsplash.com/photo-1445991842772-097fea258e7b?w=400&q=80',
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&q=80',
      ],
      '세차': [
        'https://images.unsplash.com/photo-1520340356584-f9917d1eea6f?w=400&q=80',
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&q=80',
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&q=80',
        'https://images.unsplash.com/photo-1520340356584-f9917d1eea6f?w=400&q=80',
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&q=80',
      ],
      '타이어': [
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&q=80',
        'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=400&q=80',
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&q=80',
        'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400&q=80',
        'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=400&q=80',
      ],
      '중고차': [
        'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400&q=80',
        'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=400&q=80',
        'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?w=400&q=80',
        'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400&q=80',
        'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=400&q=80',
      ],
    };
    final list = images[cat] ??
        [
          'https://images.unsplash.com/photo-1632823469850-2f77dd9c7f93?w=400&q=80',
          'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=400&q=80',
          'https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?w=400&q=80',
          'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&q=80',
          'https://images.unsplash.com/photo-1445991842772-097fea258e7b?w=400&q=80',
        ];
    return list[idx % list.length];
  }

  List<String> _catTags(String cat) {
    final tags = {
      '정비': ['엔진오일', '브레이크', '미션', '하체점검'],
      '세차': ['손세차', '광택', '코팅', '유리막'],
      '타이어': ['타이어교환', '얼라인먼트', '휠밸런싱'],
      '중고차': ['성능점검', '매입', '직거래'],
      '검사': ['차량검사', '배기가스', '안전검사'],
      '주유소': ['휘발유', '경유', '충전', '세차'],
      '렌트카': ['단기렌트', '장기렌트', '수입차'],
    };
    return tags[cat] ?? [cat, '전문서비스'];
  }

  String _catPriceRange(String cat) {
    final ranges = {
      '정비': '30,000 ~ 500,000원',
      '세차': '15,000 ~ 200,000원',
      '타이어': '50,000 ~ 800,000원',
      '중고차': '500만 ~ 5,000만원',
      '검사': '35,000 ~ 100,000원',
      '주유소': '리터당 1,600원~',
      '렌트카': '일 35,000원~',
    };
    return ranges[cat] ?? '문의 후 안내';
  }

  // 서비스 카테고리 여부 (지도 사이즈 330×270 고정 대상)
  bool get _isServiceCat => ['정비', '세차', '타이어', '검사', '주유소', '주차장', '렌트카']
      .contains(widget.category);

  // 카테고리별 배경색
  Color get _catColor {
    final colors = {
      '정비': const Color(0xFF1B3A6B),
      '세차': const Color(0xFF0D3B6E),
      '타이어': const Color(0xFF1A2E4A),
      '중고차': const Color(0xFF1E3A2F),
      '검사': const Color(0xFF2A1A4A),
      '주유소': const Color(0xFF3A2000),
      '주차장': const Color(0xFF1A3A2A),
      '렌트카': const Color(0xFF2A1A3A),
    };
    return colors[widget.category] ?? const Color(0xFF0A1628);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: AnimatedBuilder(
        animation: AppState(),
        builder: (context, _) => CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(child: _buildMapSection()),
            SliverToBoxAdapter(child: _buildQuoteRequestBanner()),
            // 타이어: 중고타이어 배너 삭제됨 (타이어 사이즈 검색 배너로 통합)
            // 정비: 최근 완료 내역 섹션 (배너 하단)
            if (widget.category == '정비')
              SliverToBoxAdapter(child: _buildRecentCompletedSection()),
            SliverToBoxAdapter(child: _buildFilterBar()),
            SliverToBoxAdapter(child: _buildStoreCount()),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _buildStoreCard(_stores[i], i),
                childCount: _stores.length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: _buildFab(),
    );
  }

  // ── AppBar: leading 화살표 좌측 고정, centerTitle:true ────
  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 44,
      pinned: true,
      backgroundColor: _bg,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      centerTitle: true,
      // leading: 좌측 끝 고정 (화살표가 중앙 타이틀과 절대 겹치지 않음)
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
      title: Text(
        widget.category,
        style: GoogleFonts.notoSansKr(
          fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white),
      ),
    );
  }

  // ── 지도 섹션 (시뮬레이션) 330×270 고정 (모든 업종) ────────
  Widget _buildMapSection() {
    const mapW = 330.0;   // 모든 업종 가로 330px 고정
    const mapH = 270.0;   // 모든 업종 세로 270px 고정

    return Center(
      child: Container(
        width: mapW,
        height: mapH,
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border, width: 1.5),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            // 지도 배경 (그리드 시뮬레이션)
            _buildFakeMap(),
            // 내 위치 핀
            const Positioned(
              left: 0, right: 0, top: 0, bottom: 0,
              child: Center(child: _MyLocationPin()),
            ),
            // 업체 핀들
            ..._buildStorePins(),
            // 하단 정보바
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [_bg, _bg.withOpacity(0.8), Colors.transparent],
                  ),
                ),
                child: Row(children: [
                  const Icon(Icons.my_location, color: _accent, size: 16),
                  const SizedBox(width: 6),
                  Text('대구 수성구 기준',
                      style: GoogleFonts.notoSansKr(fontSize: 12, color: _t2)),
                  const Spacer(),
                  // 전체 업종 330×270 고정 - 확대/접기 버튼 없음
                ]),
              ),
            ),
            // 반경 표시
            Positioned(
              top: 12, right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _navy.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _border),
                ),
                child: Row(children: [
                  const Icon(Icons.radar, color: _accent, size: 13),
                  const SizedBox(width: 4),
                  Text('반경 10km',
                      style: GoogleFonts.notoSansKr(fontSize: 11, color: _t2)),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFakeMap() {
    return Container(
      color: const Color(0xFF0A1628),
      child: CustomPaint(
        painter: _MapGridPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }

  List<Widget> _buildStorePins() {
    final stores = _stores.take(5).toList();
    final positions = [
      [0.35, 0.25], [0.65, 0.30], [0.25, 0.55],
      [0.70, 0.60], [0.50, 0.70],
    ];
    return stores.asMap().entries.map((entry) {
      final i = entry.key;
      if (i >= positions.length) return const SizedBox.shrink();
      final s = entry.value;
      final px = positions[i][0];
      final py = positions[i][1];
      return Positioned(
        left: MediaQuery.of(context).size.width * px - 56,
        top: 270.0 * py - 16,
        child: GestureDetector(
          onTap: () => _goToDetail(s),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
              color: s['badge'] == 'MOINCAR 인증' ? _accent : _orange,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 4, offset: const Offset(0, 2),
              )],
            ),
            child: Text(
              s['name'].toString().length > 6
                  ? s['name'].toString().substring(0, 6)
                  : s['name'].toString(),
              style: GoogleFonts.notoSansKr(
                  fontSize: 9, color: Colors.white,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ),
      );
    }).toList();
  }

  // ── 견적 요청 배너 (정비: 3단계, 타이어: 3단계, 세차/검사: 없음) ───
  Widget _buildQuoteRequestBanner() {
    if (widget.category == '정비') {
      return _buildRepairBanner();
    }
    if (widget.category == '타이어') {
      return _buildTireBannerWithState();
    }
    return const SizedBox.shrink();
  }

  // ── [타이어] 3단계 배너 (정비와 동일한 흐름) ─────────────────
  Widget _buildTireBannerWithState() {
    final active = AppState().activeTireRequest;
    if (active == null) {
      // stage 0: 사이즈 검색 배너
      return _buildTireBanner();
    }
    if (active.status == TireRequestStatus.bidding) {
      // stage 1: 견적 수신 대기
      return _bannerContainer(
        gradient: [const Color(0xFF0A2A1A), const Color(0xFF0D3B28)],
        glowColor: _green,
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.hourglass_top_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('타이어 견적 요청 중',
              style: GoogleFonts.notoSansKr(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 4),
            Text('${active.tireWidth}/${active.tireAspect}/R${active.tireInch} · 상세 내역 보기 →',
              style: GoogleFonts.notoSansKr(fontSize: 12, color: _green)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _green.withOpacity(0.4)),
            ),
            child: Text('대기중', style: GoogleFonts.notoSansKr(fontSize: 11, color: _green, fontWeight: FontWeight.w700)),
          ),
        ]),
      );
    }
    // stage 2: 타이어 견적 도착
    final bidCount = active.bids.length;
    final firstStore = active.bids.isNotEmpty ? active.bids.first.storeName : '';
    return _bannerContainer(
      gradient: [const Color(0xFF1A0A00), const Color(0xFF2A1200)],
      glowColor: _orange,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
          onTap: () => _showTireBidSheet(active),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: _orange.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.tire_repair_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('타이어 견적 도착! (내용 확인하기)',
                style: GoogleFonts.notoSansKr(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 4),
              Text('${active.tireWidth}/${active.tireAspect}/R${active.tireInch} · $bidCount개 점포',
                style: GoogleFonts.notoSansKr(fontSize: 12, color: _orange.withOpacity(0.9))),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _orange.withOpacity(0.2), borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _orange.withOpacity(0.5)),
              ),
              child: Text('$bidCount건', style: GoogleFonts.notoSansKr(fontSize: 12, color: _orange, fontWeight: FontWeight.w800)),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        // ── 점포 상세보기 버튼 → StoreDetail 연동 ──
        Row(children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _showTireBidSheet(active),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _orange.withOpacity(0.4)),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.format_list_bulleted_rounded, color: _orange, size: 16),
                  const SizedBox(width: 6),
                  Text('견적 목록 보기',
                    style: GoogleFonts.notoSansKr(fontSize: 12, color: _orange, fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () {
                // 첫 번째 입찰 점포로 이동
                if (active.bids.isNotEmpty) {
                  final storeId = active.bids.first.storeId;
                  final store = AppData.stores.firstWhere(
                    (s) => s.id == storeId,
                    orElse: () => AppData.stores.first,
                  );
                  Navigator.pushNamed(context, '/store-detail', arguments: store);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _accent.withOpacity(0.4)),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.store_rounded, color: _accent, size: 16),
                  const SizedBox(width: 6),
                  Text(firstStore.isNotEmpty ? '$firstStore' : '점포 상세',
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.notoSansKr(fontSize: 12, color: _accent, fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
          ),
        ]),
      ]),
    );
  }

  // ── 타이어 견적 상세 바텀시트 ────────────────────────────────
  void _showTireBidSheet(TireRequest req) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, ctrl) => Column(children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 40, height: 4,
            decoration: BoxDecoration(color: _border, borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(children: [
              const Icon(Icons.tire_repair_rounded, color: _accent, size: 20),
              const SizedBox(width: 8),
              Text('타이어 견적서 · ${req.tireWidth}/${req.tireAspect}/R${req.tireInch}',
                style: GoogleFonts.notoSansKr(fontSize: 15, fontWeight: FontWeight.w800, color: _t1)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: req.isUsed ? _orange.withOpacity(0.15) : _accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(req.isUsed ? '중고 타이어' : '신품 타이어',
                  style: GoogleFonts.notoSansKr(fontSize: 11,
                    color: req.isUsed ? _orange : _accent, fontWeight: FontWeight.w700)),
              ),
            ]),
          ),
          Divider(color: _border, height: 1),
          Expanded(
            child: ListView.builder(
              controller: ctrl,
              padding: const EdgeInsets.all(16),
              itemCount: req.bids.length,
              itemBuilder: (_, i) {
                final bid = req.bids[i];
                // 확정된 후 비선택 점포: isRead==true → 비활성화 표시
                final isDeactivated = req.status == TireRequestStatus.confirmed && bid.isRead;
                final isConfirmed   = req.status == TireRequestStatus.confirmed && !bid.isRead;
                return Opacity(
                  opacity: isDeactivated ? 0.4 : 1.0,
                  child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _navy,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isConfirmed
                          ? _green.withOpacity(0.7)
                          : i == 0 ? _accent.withOpacity(0.4) : _border,
                      width: isConfirmed ? 2 : 1,
                    ),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      if (isConfirmed) Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: _green.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                        child: Text('✅ 확정', style: GoogleFonts.notoSansKr(fontSize: 10, color: _green, fontWeight: FontWeight.w700)),
                      ),
                      if (isDeactivated) Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: _border, borderRadius: BorderRadius.circular(6)),
                        child: Text('거래 완료', style: GoogleFonts.notoSansKr(fontSize: 10, color: _t2, fontWeight: FontWeight.w700)),
                      ),
                      if (!isConfirmed && !isDeactivated && i == 0) Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: _accent.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                        child: Text('최저가', style: GoogleFonts.notoSansKr(fontSize: 10, color: _accent, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 6),
                      Expanded(child: Text(bid.storeName,
                        style: GoogleFonts.notoSansKr(fontSize: 14, fontWeight: FontWeight.w700, color: _t1))),
                      Row(children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 13),
                        const SizedBox(width: 3),
                        Text(bid.storeRating.toString(),
                          style: GoogleFonts.notoSansKr(fontSize: 12, color: _t1)),
                        const SizedBox(width: 6),
                        Text(bid.storeDistance, style: GoogleFonts.notoSansKr(fontSize: 11, color: _t2)),
                      ]),
                    ]),
                    const SizedBox(height: 10),
                    // 타이어 상세
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(10)),
                      child: Column(children: [
                        _tireBidRow('브랜드', bid.tireBrand),
                        _tireBidRow('1개 가격', '${_fmt(bid.pricePerTire)}원'),
                        _tireBidRow('수량', '${bid.quantity}개'),
                        _tireBidRow('총 합계', '${_fmt(bid.totalCost)}원', valueColor: _orange),
                        _tireBidRow('소요 시간', bid.estimatedTime),
                        if (bid.memo.isNotEmpty) _tireBidRow('메모', bid.memo),
                      ]),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isDeactivated ? null : () {
                          // 확정: 선택한 점포 외 나머지 bids 비활성화
                          for (final other in req.bids) {
                            if (other.bidId != bid.bidId) {
                              other.isRead = true; // 비활성화 마킹
                            }
                          }
                          req.status = TireRequestStatus.confirmed;
                          AppState().notifyListeners();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('✅ ${bid.storeName}으로 확정! 나머지 견적은 자동 종료됩니다'),
                            backgroundColor: _green,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 3),
                          ));
                        },
                        icon: Icon(
                          isConfirmed ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
                          size: 16, color: Colors.black),
                        label: Text(
                          isConfirmed ? '확정 완료' : '이 점포로 확정하기',
                          style: GoogleFonts.notoSansKr(color: Colors.black, fontWeight: FontWeight.w800)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isConfirmed ? _green : _accent,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ]),
                ),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }

  Widget _tireBidRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        SizedBox(width: 72, child: Text(label,
          style: GoogleFonts.notoSansKr(fontSize: 11, color: _t2))),
        Expanded(child: Text(value,
          style: GoogleFonts.notoSansKr(fontSize: 12, color: valueColor ?? _t1, fontWeight: FontWeight.w600))),
      ]),
    );
  }

  String _fmt(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  // ── [정비] 최근 완료 내역 섹션 ────────────────────────────────
  Widget _buildRecentCompletedSection() {
    final records = AppState().maintenanceHistory;
    if (records.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
        child: Row(children: [
          const Icon(Icons.history_rounded, color: _green, size: 16),
          const SizedBox(width: 6),
          Text('최근 완료된 정비 내역',
            style: GoogleFonts.notoSansKr(fontSize: 14, fontWeight: FontWeight.w800, color: _t1)),
          const Spacer(),
          Text('${records.length}건',
            style: GoogleFonts.notoSansKr(fontSize: 12, color: _green, fontWeight: FontWeight.w700)),
        ]),
      ),
      ...records.take(3).map((r) => _buildCompletedRecordCard(r)),
      const SizedBox(height: 6),
    ]);
  }

  Widget _buildCompletedRecordCard(MaintenanceRecord r) {
    final store = AppData.stores.firstWhere(
      (s) => s.id == r.storeId,
      orElse: () => AppData.stores.first,
    );
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/store-detail', arguments: store),
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _green.withOpacity(0.3)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _green.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.check_circle_rounded, color: _green, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r.storeName, style: GoogleFonts.notoSansKr(
                  fontSize: 13, fontWeight: FontWeight.w700, color: _t1)),
              const SizedBox(height: 2),
              Text('${r.repairType} · ${r.carName}',
                style: GoogleFonts.notoSansKr(fontSize: 11, color: _t2)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${_fmt(r.totalCost)}원',
                style: GoogleFonts.notoSansKr(fontSize: 13, fontWeight: FontWeight.w800, color: _orange)),
              const SizedBox(height: 2),
              Text(_fmtDate(r.createdAt).substring(0, 10),
                style: GoogleFonts.notoSansKr(fontSize: 10, color: _t2)),
            ]),
          ]),
          const SizedBox(height: 10),
          // 리뷰 작성 / 다시 신청 버튼
          Row(children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _showReviewDialog(r),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: r.reviewRating != null
                        ? _green.withOpacity(0.12)
                        : _navy,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: r.reviewRating != null
                          ? _green.withOpacity(0.4)
                          : _border),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(
                      r.reviewRating != null
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: r.reviewRating != null ? _green : _t2,
                      size: 14),
                    const SizedBox(width: 5),
                    Text(
                      r.reviewRating != null ? '리뷰 완료 (${r.reviewRating}★)' : '리뷰 작성',
                      style: GoogleFonts.notoSansKr(
                          fontSize: 11,
                          color: r.reviewRating != null ? _green : _t2,
                          fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/store-detail', arguments: store),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _accent.withOpacity(0.3)),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.store_rounded, color: _accent, size: 14),
                    const SizedBox(width: 5),
                    Text('다시 신청하기',
                      style: GoogleFonts.notoSansKr(
                          fontSize: 11, color: _accent, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  // ── 리뷰 작성 다이얼로그 ────────────────────────────────────
  void _showReviewDialog(MaintenanceRecord record) {
    int tempRating = record.reviewRating ?? 5;
    final reviewCtrl = TextEditingController(text: record.reviewText ?? '');
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDlgState) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _accent.withOpacity(0.3)),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('리뷰 작성',
                style: GoogleFonts.notoSansKr(
                  fontSize: 17, fontWeight: FontWeight.w800, color: _t1)),
              const SizedBox(height: 6),
              Text(record.storeName,
                style: GoogleFonts.notoSansKr(fontSize: 13, color: _t2)),
              const SizedBox(height: 16),
              // 별점 선택
              Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) {
                return GestureDetector(
                  onTap: () => setDlgState(() => tempRating = i + 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      i < tempRating ? Icons.star_rounded : Icons.star_border_rounded,
                      color: const Color(0xFFFFC107),
                      size: 36,
                    ),
                  ),
                );
              })),
              const SizedBox(height: 14),
              TextField(
                controller: reviewCtrl,
                maxLines: 3,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: '정비 후기를 남겨주세요',
                  hintStyle: TextStyle(color: _t2.withOpacity(0.6), fontSize: 12),
                  filled: true, fillColor: _navy,
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: _border)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: _border)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _accent)),
                ),
              ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _t2,
                      side: BorderSide(color: _border),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('취소', style: GoogleFonts.notoSansKr(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      record.reviewRating = tempRating;
                      record.reviewText   = reviewCtrl.text.trim();
                      Navigator.pop(ctx);
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text('리뷰가 등록되었습니다!'),
                        backgroundColor: _green,
                        behavior: SnackBarBehavior.floating,
                      ));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('등록하기',
                      style: GoogleFonts.notoSansKr(
                        color: Colors.black, fontWeight: FontWeight.w800)),
                  ),
                ),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  // ── [타이어] 사이즈 검색 배너 ─────────────────────────────
  // ── [타이어] stage 0 배너: 타이어 사이즈 검색 및 재고 문의 ──
  Widget _buildTireBanner() {
    return GestureDetector(
      onTap: () => _showTireSizePickerDialog(),
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D2744), Color(0xFF1A3D6E)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _accent.withOpacity(0.45)),
          boxShadow: [BoxShadow(
            color: _accent.withOpacity(0.2),
            blurRadius: 14, offset: const Offset(0, 4),
          )],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.tire_repair_rounded, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('타이어 사이즈 검색 및 재고 문의',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text('단면폭 / 편평비 / 인치 선택 → 신품 · 중고 모두 문의',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 11, color: Colors.white.withOpacity(0.8))),
                  ],
                )),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                _tireSizeChip('245 / 45 / R18'),
                const SizedBox(width: 6),
                _tireSizeChip('225 / 60 / R16'),
                const SizedBox(width: 6),
                _tireSizeChip('직접 입력'),
              ]),
              const SizedBox(height: 10),
              // 신품/중고 안내 태그
              Row(children: [
                _tireTypeTag(Icons.fiber_new_rounded, '신품 견적', _accent),
                const SizedBox(width: 8),
                _tireTypeTag(Icons.recycling_rounded, '중고 재고 문의', _orange),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tireTypeTag(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.notoSansKr(
            fontSize: 11, color: color, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _tireSizeChip(String label) {
    return GestureDetector(
      onTap: () => _showTireSizePickerDialog(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: _accent.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _accent.withOpacity(0.4)),
        ),
        child: Text(label, style: GoogleFonts.notoSansKr(
            fontSize: 11, color: _accent, fontWeight: FontWeight.w600)),
      ),
    );
  }

  // ── [타이어] 중고 타이어 배너 삭제됨 (타이어 사이즈 검색 배너로 통합)
  // _buildUsedTireBanner 제거 – 사이즈 선택 다이얼로그 내 '중고 타이어 재고 문의' 버튼으로 대체

  // ── [정비] 3단계 상태 배너 ─────────────────────────────────
  Widget _buildRepairBanner() {
    final appState = AppState();
    final requests = appState.estimateRequests;
    final isActive = appState.isRequestActive;

    // 단계 결정
    // 0: 요청 전 (또는 완료 후 리셋)
    // 1: 요청 후 대기 (pending / bidding)
    // 2: 견적 도착 (received / matched / repairing)
    // 3: 수리 완료 (completed) → 배너 리셋 후 최근 내역 섹션 표시
    int stage = 0;
    EstimateRequest? latestReq;
    if (requests.isNotEmpty && isActive) {
      latestReq = requests.first;
      if (latestReq.status == RepairStatus.pending ||
          latestReq.status == RepairStatus.bidding) {
        stage = 1;
      } else if (latestReq.status == RepairStatus.received ||
          latestReq.status == RepairStatus.matched ||
          latestReq.status == RepairStatus.repairing) {
        stage = 2;
      } else if (latestReq.status == RepairStatus.completed) {
        stage = 3; // 완료 → stage 0 (무료요청) 으로 리셋
      }
    }

    switch (stage) {
      case 0: // 요청 전
        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/quote-request'),
          child: _bannerContainer(
            gradient: [const Color(0xFF1565C0), _accent.withOpacity(0.85)],
            glowColor: _accent,
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.build_circle_outlined, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('무료 견적 요청하기',
                    style: GoogleFonts.notoSansKr(
                      fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('사진만 찍으면 주변 정비점에서 견적 발송',
                    style: GoogleFonts.notoSansKr(
                      fontSize: 12, color: Colors.white.withOpacity(0.85))),
                ],
              )),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
            ]),
          ),
        );

      case 1: // 요청 후 대기
        return GestureDetector(
          onTap: () {
            if (latestReq != null) {
              _showMyRequestSheet(latestReq);
            }
          },
          child: _bannerContainer(
            gradient: [const Color(0xFF0A2A1A), const Color(0xFF0D3B28)],
            glowColor: _green,
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.hourglass_top_rounded,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('견적 요청 중',
                    style: GoogleFonts.notoSansKr(
                      fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('상세 내역 보기 →',
                    style: GoogleFonts.notoSansKr(
                      fontSize: 12, color: _green)),
                ],
              )),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _green.withOpacity(0.4)),
                ),
                child: Text('대기중', style: GoogleFonts.notoSansKr(
                    fontSize: 11, color: _green, fontWeight: FontWeight.w700)),
              ),
            ]),
          ),
        );

      case 2: // 견적 도착
        final bidCount = latestReq?.bids.length ?? 0;
        // 첫 번째 견적을 보낸 점포 정보 (상세보기용)
        final firstStoreName = latestReq?.bids.isNotEmpty == true
            ? (latestReq!.bids.first.storeName)
            : '';
        return _bannerContainer(
          gradient: [const Color(0xFF1A0A00), const Color(0xFF2A1200)],
          glowColor: _orange,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 배너 상단 (견적 도착 정보)
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/quote-received'),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.mark_email_unread_rounded,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('견적서 도착! (내용 확인하기)',
                        style: GoogleFonts.notoSansKr(
                          fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text('$bidCount개 점포에서 견적이 왔습니다',
                        style: GoogleFonts.notoSansKr(
                          fontSize: 12, color: _orange.withOpacity(0.9))),
                    ],
                  )),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _orange.withOpacity(0.5)),
                    ),
                    child: Text('$bidCount건', style: GoogleFonts.notoSansKr(
                        fontSize: 12, color: _orange, fontWeight: FontWeight.w800)),
                  ),
                ]),
              ),
              // ── 점포 상세보기 버튼 (별도) ──
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  // 견적 목록에서 첫 점포 상세로 이동
                  Navigator.pushNamed(context, '/quote-received');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _orange.withOpacity(0.4)),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.store_rounded, color: _orange, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      firstStoreName.isNotEmpty
                          ? '[$firstStoreName] 점포 상세보기'
                          : '점포 상세보기',
                      style: GoogleFonts.notoSansKr(
                          fontSize: 13, color: _orange, fontWeight: FontWeight.w700)),
                  ]),
                ),
              ),
            ],
          ),
        );

      case 3: // 수리 완료 → 배너 [무료요청]으로 리셋
      default:
        // 완료 상태: isRequestActive를 false로 해제하여 stage 0 동작
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            AppState().setRequestActive(false);
          }
        });
        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/quote-request'),
          child: _bannerContainer(
            gradient: [const Color(0xFF1565C0), _accent.withOpacity(0.85)],
            glowColor: _accent,
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.build_circle_outlined, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('무료 견적 요청하기',
                    style: GoogleFonts.notoSansKr(
                      fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('이전 정비가 완료되었습니다 ✓',
                    style: GoogleFonts.notoSansKr(
                      fontSize: 12, color: Colors.white.withOpacity(0.85))),
                ],
              )),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
            ]),
          ),
        );
    }
    return const SizedBox.shrink();
  }

  Widget _bannerContainer({
    required List<Color> gradient,
    required Color glowColor,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
          color: glowColor.withOpacity(0.3),
          blurRadius: 12, offset: const Offset(0, 4),
        )],
        border: Border.all(color: glowColor.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: child,
      ),
    );
  }

  // ── 내 요청 상세 바텀시트 ──────────────────────────────────
  void _showMyRequestSheet(EstimateRequest req) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (_, ctrl) => Column(children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 40, height: 4,
            decoration: BoxDecoration(
                color: _border, borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(children: [
              const Icon(Icons.receipt_long_rounded, color: _accent, size: 20),
              const SizedBox(width: 8),
              Text('내 견적 요청서',
                style: GoogleFonts.notoSansKr(
                  fontSize: 16, fontWeight: FontWeight.w800, color: _t1)),
            ]),
          ),
          Divider(color: _border, height: 1),
          Expanded(
            child: ListView(
              controller: ctrl,
              padding: const EdgeInsets.all(16),
              children: [
                _sheetRow('차량', req.carName),
                _sheetRow('차량번호', req.carNumber),
                _sheetRow('지역', req.region),
                _sheetRow('정비유형', req.repairType),
                _sheetRow('증상', req.symptoms.join(', ')),
                if (req.memo.isNotEmpty) _sheetRow('메모', req.memo),
                _sheetRow('요청일시', _fmtDate(req.createdAt)),
                const SizedBox(height: 16),
                // 점포 상세보기 버튼
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.store_rounded, size: 16),
                    label: const Text('점포 상세보기'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _accent,
                      side: BorderSide(color: _accent.withOpacity(0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/quote-received');
                    },
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _sheetRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        width: 72,
        child: Text(label,
          style: GoogleFonts.notoSansKr(fontSize: 12, color: _t2)),
      ),
      Expanded(child: Text(value,
        style: GoogleFonts.notoSansKr(
          fontSize: 12, color: _t1, fontWeight: FontWeight.w600))),
    ]),
  );

  String _fmtDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2,'0')}-${dt.day.toString().padLeft(2,'0')} '
      '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';


  // ── 필터 바 ─────────────────────────────────────────────
  Widget _buildFilterBar() {
    return Column(
      children: [
        // 정렬 탭
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: _sortOptions.map((opt) {
              final selected = _sortBy == opt;
              return GestureDetector(
                onTap: () => setState(() => _sortBy = opt),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: selected ? _accent : _card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: selected ? _accent : _border),
                  ),
                  child: Text(
                    opt,
                    style: GoogleFonts.notoSansKr(
                      fontSize: 12,
                      color: selected ? Colors.black : _t2,
                      fontWeight: selected
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        // 배지 필터
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: _badges.map((b) {
              final selected = _selectedBadge == b;
              return GestureDetector(
                onTap: () => setState(() => _selectedBadge = b),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected ? _orange.withOpacity(0.15) : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: selected ? _orange : _border.withOpacity(0.5)),
                  ),
                  child: Text(
                    b,
                    style: GoogleFonts.notoSansKr(
                      fontSize: 11,
                      color: selected ? _orange : _t2,
                      fontWeight: selected
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildStoreCount() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(children: [
        Text('검색 결과 ',
            style: GoogleFonts.notoSansKr(fontSize: 13, color: _t2)),
        Text('${_stores.length}개',
            style: GoogleFonts.notoSansKr(
                fontSize: 13, color: _accent,
                fontWeight: FontWeight.w700)),
        Text(' 업체',
            style: GoogleFonts.notoSansKr(fontSize: 13, color: _t2)),
        const Spacer(),
        Text('평균 견적 대기 ',
            style: GoogleFonts.notoSansKr(fontSize: 12, color: _t2)),
        Text('12분',
            style: GoogleFonts.notoSansKr(
                fontSize: 12, color: _green,
                fontWeight: FontWeight.w700)),
      ]),
    );
  }

  // ── 업체 카드 ───────────────────────────────────────────
  Widget _buildStoreCard(Map<String, dynamic> store, int index) {
    final badge = store['badge'] as String;
    final badgeColor = badge == 'MOINCAR 인증'
        ? _accent
        : badge == '인기'
            ? _orange
            : badge == '추천'
                ? _green
                : _t2;

    return GestureDetector(
      onTap: () => _goToDetail(store),
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: badge == 'MOINCAR 인증'
                ? _accent.withOpacity(0.3)
                : _border,
          ),
        ),
        child: Column(
          children: [
            // 이미지 + 정보
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 이미지
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: store['image'] as String,
                    width: 110,
                    height: 110,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                        color: _navy,
                        child: const Icon(Icons.store, color: _border)),
                    errorWidget: (_, __, ___) => Container(
                        color: _navy,
                        child: const Icon(Icons.store, color: _border)),
                  ),
                ),
                const SizedBox(width: 12),
                // 텍스트 정보
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 배지
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: badgeColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: badgeColor.withOpacity(0.5)),
                            ),
                            child: Text(badge,
                                style: GoogleFonts.notoSansKr(
                                    fontSize: 10,
                                    color: badgeColor,
                                    fontWeight: FontWeight.w700)),
                          ),
                          if (store['hasVideo'] == true) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: Colors.red.withOpacity(0.4)),
                              ),
                              child: const Row(children: [
                                Icon(Icons.play_circle_filled,
                                    color: Colors.red, size: 10),
                                SizedBox(width: 3),
                                Text('VIDEO',
                                    style: TextStyle(
                                        fontSize: 9,
                                        color: Colors.red,
                                        fontWeight: FontWeight.w700)),
                              ]),
                            ),
                          ],
                        ]),
                        const SizedBox(height: 7),
                        // 이름
                        Text(store['name'] as String,
                            style: GoogleFonts.notoSansKr(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _t1),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 3),
                        Text(store['sub'] as String,
                            style: GoogleFonts.notoSansKr(
                                fontSize: 11, color: _t2),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 8),
                        // 평점·거리
                        Row(children: [
                          const Icon(Icons.star_rounded,
                              color: Color(0xFFFFC107), size: 14),
                          const SizedBox(width: 3),
                          Text(store['rating'].toString(),
                              style: GoogleFonts.notoSansKr(
                                  fontSize: 12, color: _t1,
                                  fontWeight: FontWeight.w600)),
                          Text(' (${store['reviews']})',
                              style: GoogleFonts.notoSansKr(
                                  fontSize: 11, color: _t2)),
                          const SizedBox(width: 10),
                          const Icon(Icons.location_on,
                              color: _accent, size: 13),
                          const SizedBox(width: 2),
                          Text(store['distance'] as String,
                              style: GoogleFonts.notoSansKr(
                                  fontSize: 11, color: _t2)),
                        ]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // 하단 액션 바
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(color: _border.withOpacity(0.5))),
              ),
              child: Row(
                children: [
                  // 영업시간
                  const Icon(Icons.access_time, color: _t2, size: 12),
                  const SizedBox(width: 4),
                  Text(store['hours'] as String,
                      style: GoogleFonts.notoSansKr(
                          fontSize: 11, color: _t2)),
                  const SizedBox(width: 8),
                  // 견적 대기
                  const Icon(Icons.timer_outlined,
                      color: _green, size: 12),
                  const SizedBox(width: 3),
                  Text('평균 ${store['estimateAvg']}',
                      style: GoogleFonts.notoSansKr(
                          fontSize: 11, color: _green)),
                  const Spacer(),
                  // 전화
                  GestureDetector(
                    onTap: () => _callStore(store['phone'] as String),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _green.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: _green.withOpacity(0.3)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.phone,
                            color: _green, size: 13),
                        const SizedBox(width: 4),
                        Text('전화',
                            style: GoogleFonts.notoSansKr(
                                fontSize: 11, color: _green,
                                fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 견적요청
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, '/quote-request'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: _accent.withOpacity(0.3)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.receipt_long,
                            color: _accent, size: 13),
                        const SizedBox(width: 4),
                        Text('견적',
                            style: GoogleFonts.notoSansKr(
                                fontSize: 11, color: _accent,
                                fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
            // 태그
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: Wrap(
                spacing: 6,
                children: (store['tags'] as List<String>)
                    .map((tag) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _navy,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('#$tag',
                              style: GoogleFonts.notoSansKr(
                                  fontSize: 10, color: _t2)),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── FAB (견적 요청) ─────────────────────────────────────
  Widget _buildFab() {
    return FloatingActionButton.extended(
      onPressed: () => Navigator.pushNamed(context, '/quote-request'),
      backgroundColor: _accent,
      icon: const Icon(Icons.request_quote, color: Colors.black),
      label: Text(
        '${widget.category} 견적 요청',
        style: GoogleFonts.notoSansKr(
            fontSize: 13, color: Colors.black,
            fontWeight: FontWeight.w700),
      ),
    );
  }

  // ── 필터 바텀시트 ────────────────────────────────────────
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text('필터 설정',
                  style: GoogleFonts.notoSansKr(
                      fontSize: 16, color: _t1,
                      fontWeight: FontWeight.w700)),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    _sortBy = '거리순';
                    _selectedBadge = '전체';
                  });
                  Navigator.pop(context);
                },
                child: Text('초기화',
                    style: GoogleFonts.notoSansKr(color: _t2)),
              ),
            ]),
            const SizedBox(height: 16),
            Text('가격 범위',
                style: GoogleFonts.notoSansKr(
                    fontSize: 13, color: _t2)),
            const SizedBox(height: 8),
            Text(
              _catPriceRange(widget.category),
              style: GoogleFonts.notoSansKr(
                  fontSize: 14, color: _accent,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text('적용',
                    style: GoogleFonts.notoSansKr(
                        fontSize: 15, color: Colors.black,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 네비게이션 ───────────────────────────────────────────
  void _goToDetail(Map<String, dynamic> store) {
    // AppData.stores 첫 번째 점포로 이동 (시뮬레이션)
    final demoStore = AppData.stores.isNotEmpty ? AppData.stores.first : null;
    if (demoStore != null) {
      Navigator.pushNamed(context, '/store-detail',
          arguments: demoStore);
    }
  }

  void _callStore(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // ════════════════════════════════════════════════════════════
  // [타이어] 3단 Picker 다이얼로그 (단면폭 / 편평비 / 인치)
  // ════════════════════════════════════════════════════════════
  void _showTireSizePickerDialog() {
    // 제조사→모델→연식 자동매칭 또는 직접선택 탭 분기
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _TireSizePickerSheet(
        onSizeSelected: (width, aspect, inch, isUsed) {
          Navigator.pop(context);
          _showTireRequestConfirmDialog(width, aspect, inch, isUsed);
        },
      ),
    );
  }

  // ── 타이어 견적 요청 확인 다이얼로그 ────────────────────────
  void _showTireRequestConfirmDialog(
      String width, String aspect, String inch, bool isUsed) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _accent.withOpacity(0.4)),
            boxShadow: [BoxShadow(color: _accent.withOpacity(0.15), blurRadius: 20)],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(children: [
              const Icon(Icons.tire_repair_rounded, color: _accent, size: 28),
              const SizedBox(width: 10),
              Text(isUsed ? '중고 타이어 재고 문의' : '타이어 견적 요청',
                style: GoogleFonts.notoSansKr(
                  fontSize: 16, fontWeight: FontWeight.w800, color: _t1)),
            ]),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _navy,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _tireSizeTag(width, '단면폭'),
                Text(' / ', style: GoogleFonts.notoSansKr(
                    fontSize: 20, color: _t2, fontWeight: FontWeight.w300)),
                _tireSizeTag(aspect, '편평비'),
                Text(' / ', style: GoogleFonts.notoSansKr(
                    fontSize: 20, color: _t2, fontWeight: FontWeight.w300)),
                _tireSizeTag('R$inch', '인치'),
              ]),
            ),
            const SizedBox(height: 12),
            Text(
              isUsed
                  ? '위 규격의 중고 타이어 재고를\n주변 점포에 문의합니다.'
                  : '위 규격의 타이어 가격을\n주변 점포에서 견적 받습니다.',
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSansKr(fontSize: 13, color: _t2, height: 1.6),
            ),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _t2,
                    side: BorderSide(color: _border),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('취소', style: GoogleFonts.notoSansKr(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                        isUsed
                          ? '중고 타이어($width/$aspect/R$inch) 재고 문의 발송 완료!'
                          : '타이어($width/$aspect/R$inch) 견적 요청 완료!',
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: _green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isUsed ? _orange : _accent,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(isUsed ? '재고 문의 발송' : '견적 요청',
                    style: GoogleFonts.notoSansKr(
                      color: Colors.black,
                      fontWeight: FontWeight.w800, fontSize: 14)),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _tireSizeTag(String value, String label) {
    return Column(children: [
      Text(value, style: GoogleFonts.notoSansKr(
          fontSize: 22, fontWeight: FontWeight.w900, color: _accent)),
      const SizedBox(height: 2),
      Text(label, style: GoogleFonts.notoSansKr(fontSize: 10, color: _t2)),
    ]);
  }

  // ── 중고 타이어 요청 다이얼로그 ──────────────────────────────
  void _showUsedTireRequestDialog() {
    _showTireSizePickerDialog(); // 동일한 Picker에서 isUsed=true로 분기
  }
}

// ══════════════════════════════════════════════════════════════
// 내 위치 핀 위젯
// ══════════════════════════════════════════════════════════════
class _MyLocationPin extends StatefulWidget {
  const _MyLocationPin();

  @override
  State<_MyLocationPin> createState() => __MyLocationPinState();
}

class __MyLocationPinState extends State<_MyLocationPin>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
    _anim = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 40 * _anim.value,
            height: 40 * _anim.value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF4FC3F7).withOpacity(0.2 * (1 - _anim.value + 0.5)),
              border: Border.all(
                  color: const Color(0xFF4FC3F7).withOpacity(0.4),
                  width: 1),
            ),
          ),
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF4FC3F7),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [BoxShadow(
                color: const Color(0xFF4FC3F7).withOpacity(0.5),
                blurRadius: 8,
              )],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// 가짜 지도 그리드 페인터
// ══════════════════════════════════════════════════════════════
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E3A5F).withOpacity(0.4)
      ..strokeWidth = 0.5;

    // 격자 그리기
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // 도로 (굵은 선)
    final roadPaint = Paint()
      ..color = const Color(0xFF1E3A5F).withOpacity(0.7)
      ..strokeWidth = 2.5;

    canvas.drawLine(
        Offset(0, size.height * 0.5),
        Offset(size.width, size.height * 0.5),
        roadPaint);
    canvas.drawLine(
        Offset(size.width * 0.5, 0),
        Offset(size.width * 0.5, size.height),
        roadPaint);
    canvas.drawLine(
        Offset(size.width * 0.3, 0),
        Offset(size.width * 0.3, size.height),
        roadPaint);
    canvas.drawLine(
        Offset(0, size.height * 0.3),
        Offset(size.width, size.height * 0.3),
        roadPaint);
    canvas.drawLine(
        Offset(0, size.height * 0.7),
        Offset(size.width, size.height * 0.7),
        roadPaint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ══════════════════════════════════════════════════════════════
// [타이어] 사이즈 Picker 바텀시트
// 탭 1: 제조사→모델→연식 자동매칭
// 탭 2: 단면폭 / 편평비 / 인치 직접 선택
// ══════════════════════════════════════════════════════════════
class _TireSizePickerSheet extends StatefulWidget {
  final void Function(String width, String aspect, String inch, bool isUsed) onSizeSelected;
  const _TireSizePickerSheet({required this.onSizeSelected});

  @override
  State<_TireSizePickerSheet> createState() => _TireSizePickerSheetState();
}

class _TireSizePickerSheetState extends State<_TireSizePickerSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  bool _isUsed = false;

  // ── 직접 선택 데이터 ───────────────────────────────────────
  final _widths  = ['155','165','175','185','195','205','215','225','235','245','255','265','275','285','295','305'];
  final _aspects = ['30','35','40','45','50','55','60','65','70','75','80'];
  final _inches  = ['13','14','15','16','17','18','19','20','21','22'];

  int _widthIdx  = 7;  // 225
  int _aspectIdx = 4;  // 50
  int _inchIdx   = 3;  // 16

  // ── 제조사→모델→연식 데이터 ────────────────────────────────
  final _makers = ['현대', '기아', 'BMW', '벤츠', '제네시스', '쉐보레', '르노', 'KG 모빌리티'];
  final _modelMap = {
    '현대': ['아반떼', '소나타', '그랜저', '투싼', '팰리세이드', '싼타페'],
    '기아': ['K3', 'K5', 'K8', '스포티지', '쏘렌토', 'EV6'],
    'BMW': ['3시리즈', '5시리즈', '7시리즈', 'X3', 'X5'],
    '벤츠': ['C클래스', 'E클래스', 'S클래스', 'GLE', 'GLC'],
    '제네시스': ['G70', 'G80', 'G90', 'GV70', 'GV80'],
    '쉐보레': ['트레일블레이저', '트랙스', '이쿼녹스', '말리부'],
    '르노': ['SM3', 'SM6', 'QM6', 'XM3'],
    'KG 모빌리티': ['티볼리', '코란도', '렉스턴'],
  };
  // 차종별 표준 타이어 규격 (단면폭/편평비/인치)
  final _tireSizeMap = {
    '아반떼':  {'width': '205', 'aspect': '55', 'inch': '16'},
    '소나타':  {'width': '215', 'aspect': '55', 'inch': '17'},
    '그랜저':  {'width': '235', 'aspect': '50', 'inch': '18'},
    '투싼':    {'width': '225', 'aspect': '60', 'inch': '17'},
    '팰리세이드':{'width': '265', 'aspect': '50', 'inch': '20'},
    '싼타페':  {'width': '235', 'aspect': '60', 'inch': '18'},
    'K3':      {'width': '205', 'aspect': '55', 'inch': '16'},
    'K5':      {'width': '225', 'aspect': '45', 'inch': '18'},
    'K8':      {'width': '235', 'aspect': '50', 'inch': '18'},
    '스포티지': {'width': '225', 'aspect': '55', 'inch': '18'},
    '쏘렌토':  {'width': '235', 'aspect': '55', 'inch': '19'},
    'EV6':     {'width': '235', 'aspect': '45', 'inch': '20'},
    '3시리즈':  {'width': '225', 'aspect': '45', 'inch': '18'},
    '5시리즈':  {'width': '245', 'aspect': '45', 'inch': '18'},
    '7시리즈':  {'width': '255', 'aspect': '40', 'inch': '19'},
    'X3':      {'width': '245', 'aspect': '50', 'inch': '19'},
    'X5':      {'width': '275', 'aspect': '45', 'inch': '20'},
    'C클래스':  {'width': '225', 'aspect': '45', 'inch': '18'},
    'E클래스':  {'width': '245', 'aspect': '45', 'inch': '18'},
    'S클래스':  {'width': '255', 'aspect': '40', 'inch': '19'},
    'GLE':     {'width': '265', 'aspect': '45', 'inch': '20'},
    'GLC':     {'width': '235', 'aspect': '50', 'inch': '19'},
    'G70':     {'width': '225', 'aspect': '45', 'inch': '18'},
    'G80':     {'width': '245', 'aspect': '45', 'inch': '19'},
    'G90':     {'width': '265', 'aspect': '40', 'inch': '20'},
    'GV70':    {'width': '235', 'aspect': '50', 'inch': '19'},
    'GV80':    {'width': '265', 'aspect': '50', 'inch': '20'},
    '트레일블레이저': {'width': '225', 'aspect': '55', 'inch': '18'},
    '트랙스':   {'width': '205', 'aspect': '60', 'inch': '16'},
    '이쿼녹스':  {'width': '235', 'aspect': '50', 'inch': '18'},
    '말리부':   {'width': '215', 'aspect': '50', 'inch': '18'},
    'SM3':     {'width': '195', 'aspect': '55', 'inch': '16'},
    'SM6':     {'width': '225', 'aspect': '45', 'inch': '18'},
    'QM6':     {'width': '235', 'aspect': '55', 'inch': '18'},
    'XM3':     {'width': '215', 'aspect': '55', 'inch': '17'},
    '티볼리':   {'width': '215', 'aspect': '55', 'inch': '17'},
    '코란도':   {'width': '225', 'aspect': '60', 'inch': '17'},
    '렉스턴':   {'width': '265', 'aspect': '60', 'inch': '18'},
  };

  String? _selectedMaker;
  String? _selectedModel;
  String? _selectedYear;

  final _years = ['2018년식', '2019년식', '2020년식', '2021년식', '2022년식', '2023년식', '2024년식'];

  void _applyAutoSize(String model) {
    final size = _tireSizeMap[model];
    if (size == null) return;
    final wi = _widths.indexOf(size['width']!);
    final ai = _aspects.indexOf(size['aspect']!);
    final ii = _inches.indexOf(size['inch']!);
    setState(() {
      if (wi >= 0) _widthIdx  = wi;
      if (ai >= 0) _aspectIdx = ai;
      if (ii >= 0) _inchIdx   = ii;
    });
  }

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, ctrl) => Column(children: [
        // 핸들
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          width: 40, height: 4,
          decoration: BoxDecoration(
              color: const Color(0xFF1E3A5F),
              borderRadius: BorderRadius.circular(2)),
        ),
        // 타이틀
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            const Icon(Icons.tire_repair_rounded, color: Color(0xFF4FC3F7), size: 22),
            const SizedBox(width: 8),
            Text('타이어 사이즈 선택',
              style: GoogleFonts.notoSansKr(
                fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
            const Spacer(),
            // 중고 타이어 토글
            GestureDetector(
              onTap: () => setState(() => _isUsed = !_isUsed),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _isUsed
                      ? const Color(0xFFFF6B35).withOpacity(0.2)
                      : const Color(0xFF0D1B2A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isUsed
                        ? const Color(0xFFFF6B35)
                        : const Color(0xFF1E3A5F),
                  ),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.recycling_rounded,
                    color: _isUsed ? const Color(0xFFFF6B35) : const Color(0xFFB0BEC5),
                    size: 14),
                  const SizedBox(width: 4),
                  Text('중고',
                    style: GoogleFonts.notoSansKr(
                      fontSize: 11,
                      color: _isUsed ? const Color(0xFFFF6B35) : const Color(0xFFB0BEC5),
                      fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 8),
        // 탭
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF0A1628),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TabBar(
            controller: _tab,
            indicator: BoxDecoration(
              color: const Color(0xFF4FC3F7),
              borderRadius: BorderRadius.circular(8),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.black,
            unselectedLabelColor: const Color(0xFFB0BEC5),
            labelStyle: GoogleFonts.notoSansKr(fontWeight: FontWeight.w700, fontSize: 13),
            tabs: const [
              Tab(text: '차종으로 자동 매칭'),
              Tab(text: '직접 사이즈 선택'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // 탭 컨텐츠
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: [
              _buildCarSelectTab(ctrl),
              _buildDirectPickerTab(ctrl),
            ],
          ),
        ),
        // 하단 확인 버튼
        Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).padding.bottom + 12),
          child: Column(children: [
            // 선택된 사이즈 표시
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF0A1628),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF4FC3F7).withOpacity(0.3)),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('선택 사이즈: ',
                  style: GoogleFonts.notoSansKr(fontSize: 13, color: const Color(0xFFB0BEC5))),
                Text(
                  '${_widths[_widthIdx]} / ${_aspects[_aspectIdx]} / R${_inches[_inchIdx]}',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 15, fontWeight: FontWeight.w900,
                    color: const Color(0xFF4FC3F7)),
                ),
              ]),
            ),
            Row(children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => widget.onSizeSelected(
                    _widths[_widthIdx], _aspects[_aspectIdx],
                    _inches[_inchIdx], false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4FC3F7),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('새 타이어 견적 요청',
                    style: GoogleFonts.notoSansKr(
                      color: Colors.black, fontWeight: FontWeight.w800, fontSize: 14)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => widget.onSizeSelected(
                    _widths[_widthIdx], _aspects[_aspectIdx],
                    _inches[_inchIdx], true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('중고 타이어 재고 문의',
                    style: GoogleFonts.notoSansKr(
                      color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                ),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }

  // ── 탭1: 차종 선택 ─────────────────────────────────────────
  Widget _buildCarSelectTab(ScrollController ctrl) {
    return ListView(
      controller: ctrl,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: [
        _carSelectLabel('제조사'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: _makers.map((m) {
            final sel = _selectedMaker == m;
            return GestureDetector(
              onTap: () => setState(() {
                _selectedMaker = m;
                _selectedModel = null;
                _selectedYear  = null;
              }),
              child: _selChip(m, sel, const Color(0xFF4FC3F7)),
            );
          }).toList(),
        ),
        if (_selectedMaker != null) ...[
          const SizedBox(height: 16),
          _carSelectLabel('모델'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: (_modelMap[_selectedMaker!] ?? []).map((m) {
              final sel = _selectedModel == m;
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedModel = m;
                  _selectedYear  = null;
                  _applyAutoSize(m);
                }),
                child: _selChip(m, sel, const Color(0xFF10B981)),
              );
            }).toList(),
          ),
        ],
        if (_selectedModel != null) ...[
          const SizedBox(height: 16),
          _carSelectLabel('연식'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _years.map((y) {
              final sel = _selectedYear == y;
              return GestureDetector(
                onTap: () => setState(() => _selectedYear = y),
                child: _selChip(y, sel, const Color(0xFFFF6B35)),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          // 자동 매칭된 규격 표시
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0A1628),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4)),
            ),
            child: Column(children: [
              Row(children: [
                const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 16),
                const SizedBox(width: 6),
                Text('$_selectedMaker $_selectedModel 표준 규격 자동 매칭',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 12, color: const Color(0xFF10B981), fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _tireNumTag(_widths[_widthIdx], '단면폭(mm)'),
                Text(' / ', style: GoogleFonts.notoSansKr(
                    fontSize: 18, color: const Color(0xFFB0BEC5))),
                _tireNumTag(_aspects[_aspectIdx], '편평비(%)'),
                Text(' / ', style: GoogleFonts.notoSansKr(
                    fontSize: 18, color: const Color(0xFFB0BEC5))),
                _tireNumTag('R${_inches[_inchIdx]}', '인치'),
              ]),
            ]),
          ),
        ],
      ],
    );
  }

  // ── 탭2: 직접 3단 Picker ────────────────────────────────────
  Widget _buildDirectPickerTab(ScrollController ctrl) {
    return Column(children: [
      const SizedBox(height: 8),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _pickerColumnLabel('단면폭 (mm)'),
            _pickerColumnLabel('편평비 (%)'),
            _pickerColumnLabel('인치'),
          ],
        ),
      ),
      const SizedBox(height: 4),
      Expanded(
        child: Row(children: [
          Expanded(child: _scrollPicker(_widths,  _widthIdx,  (i) => setState(() => _widthIdx  = i))),
          Container(width: 1, color: const Color(0xFF1E3A5F)),
          Expanded(child: _scrollPicker(_aspects, _aspectIdx, (i) => setState(() => _aspectIdx = i))),
          Container(width: 1, color: const Color(0xFF1E3A5F)),
          Expanded(child: _scrollPicker(_inches,  _inchIdx,   (i) => setState(() => _inchIdx   = i))),
        ]),
      ),
      const SizedBox(height: 8),
    ]);
  }

  Widget _scrollPicker(List<String> items, int selectedIdx, void Function(int) onChanged) {
    return ListWheelScrollView.useDelegate(
      controller: FixedExtentScrollController(initialItem: selectedIdx),
      itemExtent: 48,
      diameterRatio: 1.5,
      onSelectedItemChanged: onChanged,
      physics: const FixedExtentScrollPhysics(),
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: items.length,
        builder: (_, i) {
          final sel = i == selectedIdx;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            alignment: Alignment.center,
            decoration: sel
              ? BoxDecoration(
                  color: const Color(0xFF4FC3F7).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF4FC3F7).withOpacity(0.5)),
                )
              : null,
            child: Text(items[i],
              style: GoogleFonts.notoSansKr(
                fontSize: sel ? 22 : 16,
                fontWeight: sel ? FontWeight.w900 : FontWeight.w400,
                color: sel ? const Color(0xFF4FC3F7) : const Color(0xFFB0BEC5),
              )),
          );
        },
      ),
    );
  }

  Widget _carSelectLabel(String t) => Text(t,
    style: GoogleFonts.notoSansKr(
      fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFFB0BEC5)));

  Widget _selChip(String label, bool sel, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: sel ? color.withOpacity(0.18) : const Color(0xFF0A1628),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: sel ? color : const Color(0xFF1E3A5F)),
      ),
      child: Text(label, style: GoogleFonts.notoSansKr(
        fontSize: 12,
        color: sel ? color : const Color(0xFFB0BEC5),
        fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
      )),
    );
  }

  Widget _pickerColumnLabel(String t) => Expanded(
    child: Text(t, textAlign: TextAlign.center,
      style: GoogleFonts.notoSansKr(
        fontSize: 11, color: const Color(0xFFB0BEC5), fontWeight: FontWeight.w600)),
  );

  Widget _tireNumTag(String val, String label) {
    return Column(children: [
      Text(val, style: GoogleFonts.notoSansKr(
          fontSize: 20, fontWeight: FontWeight.w900, color: const Color(0xFF4FC3F7))),
      const SizedBox(height: 2),
      Text(label, style: GoogleFonts.notoSansKr(fontSize: 9, color: const Color(0xFFB0BEC5))),
    ]);
  }
}
