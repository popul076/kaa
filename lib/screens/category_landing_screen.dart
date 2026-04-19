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
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildMapSection()),
          SliverToBoxAdapter(child: _buildQuoteRequestBanner()),
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
      floatingActionButton: _buildFab(),
    );
  }

  // ── AppBar ─────────────────────────────────────────────
  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 44,
      pinned: true,
      backgroundColor: _bg,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Stack(
        alignment: Alignment.center,
        children: [
          // 중앙 '정비' bold - 완전 정중앙
          Text(
            widget.category,
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSansKr(
              fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          // 좌측 뒤로가기
          Positioned(
            left: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.pop(context),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 지도 섹션 (시뮬레이션) ──────────────────────────────
  Widget _buildMapSection() {
    return GestureDetector(
      onTap: () => setState(() => _mapExpanded = !_mapExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _mapExpanded ? 170 : 120,
        margin: const EdgeInsets.all(14),
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
              child: Center(
                child: _MyLocationPin(),
              ),
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
                child: Row(
                  children: [
                    const Icon(Icons.my_location, color: _accent, size: 16),
                    const SizedBox(width: 6),
                    Text('대구 수성구 기준',
                        style: GoogleFonts.notoSansKr(
                            fontSize: 12, color: _t2)),
                    const Spacer(),
                    Text(
                      _mapExpanded ? '지도 접기 ▲' : '지도 확대 ▼',
                      style: GoogleFonts.notoSansKr(
                          fontSize: 12, color: _accent,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
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
                  Text('반경 10km', style: GoogleFonts.notoSansKr(
                      fontSize: 11, color: _t2)),
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
        top: (_mapExpanded ? 170 : 120) * py - 16,
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

  // ── 견적 요청 배너 (요청 전/후 상태 전환) ──────────────
  Widget _buildQuoteRequestBanner() {
    // 배너 표시 전에 더미 데이터 초기화 (비어있으면)
    AppState().initDummyEstimates();

    return AnimatedBuilder(
      animation: AppState(),
      builder: (context, _) {
        final requests = AppState().estimateRequests;
        // matched/completed 제외 - 확정 후엔 무료견적 배너로 복귀
        final activeRequests = requests.where((r) =>
          r.status == RepairStatus.bidding ||
          r.status == RepairStatus.pending  ||
          r.status == RepairStatus.received
        ).toList();
        final totalBids = activeRequests.fold(0, (sum, r) => sum + r.bidCount);
        // ── 핵심: 요청이 있거나 isRequestActive 플래그가 있으면 도착확인 배너 ──
        // matched/completed 는 배너에서 제외 → 무료견적 배너로 복귀
        final hasActiveRequest = AppState().isRequestActive || activeRequests.isNotEmpty;

        if (hasActiveRequest) {
          // ── 도착한 견적서 확인하기 배너 (디자인 시안대로 크고 명확하게) ──
          return GestureDetector(
            onTap: () {
              // 즉시 라우팅 (데이터 없어도 화면 이동)
              Navigator.pushNamed(context, '/quote-received');
            },
            child: Container(
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0D3B1E), Color(0xFF0A2E18)],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _green.withOpacity(0.6), width: 1.5),
                boxShadow: [BoxShadow(
                  color: _green.withOpacity(0.15),
                  blurRadius: 10, offset: const Offset(0, 3),
                )],
              ),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: _green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.mark_email_unread_rounded, color: _green, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        totalBids > 0
                          ? '견적서 ${totalBids}건 도착!'
                          : '도착한 견적서 확인하기',
                        style: GoogleFonts.notoSansKr(
                          fontSize: 14, fontWeight: FontWeight.w800,
                          color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        totalBids > 0
                          ? '${activeRequests.length}개 점포에서 견적을 보냈습니다 · 지금 확인하세요!'
                          : '견적 요청 후 점포에서 답변을 검토 중입니다',
                        style: GoogleFonts.notoSansKr(
                          fontSize: 11, color: Colors.white.withOpacity(0.75)),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: _green, size: 22),
              ]),
            ),
          );
        }

        // ── 요청 전: 견적 요청하기 배너 (크고 명확하게) ──
        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/quote-request'),
          child: Container(
            margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [const Color(0xFF1565C0), _accent.withOpacity(0.85)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(
                color: _accent.withOpacity(0.3),
                blurRadius: 12, offset: const Offset(0, 4),
              )],
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
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
                    Text('${widget.category} 견적 요청하기',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text('근처 점포에서 빠르게 견적을 보내드립니다',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 12, color: Colors.white.withOpacity(0.85))),
                  ],
                )),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
              ]),
            ),
          ),
        );
      },
    );
  }

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
