import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/app_state.dart';

// ── 오토바이 전용 컬러 팔레트 ──────────────────────────────────
const _mbg    = Color(0xFF050A0F);   // 메인 배경 (거의 블랙)
const _mcard  = Color(0xFF0C1520);   // 카드 배경 (다크 네이비)
const _mcard2 = Color(0xFF101C2C);   // 카드 배경 2
const _mred   = Color(0xFFE63946);   // 포인트 레드
const _morange= Color(0xFFFF6B35);   // 포인트 오렌지
const _maccent= Color(0xFF4FC3F7);   // 보조 (라이트 블루)
const _mgreen = Color(0xFF10B981);   // 녹색 (OK/인증)
const _mborder= Color(0xFF1A2A3A);   // 테두리
const _mt1    = Colors.white;        // 텍스트 1
const _mt2    = Color(0xFFB0BEC5);   // 텍스트 2
const _mt3    = Color(0xFF546E7A);   // 텍스트 3

// ══════════════════════════════════════════════════════════════
// 오토바이 메인 화면 (탭: 홈 / 점포 / 사고팔기 / 커뮤니티 / 정보)
// ══════════════════════════════════════════════════════════════
class MotorcycleScreen extends StatefulWidget {
  final int initialTab;
  const MotorcycleScreen({super.key, this.initialTab = 0});
  @override
  State<MotorcycleScreen> createState() => _MotorcycleScreenState();
}

class _MotorcycleScreenState extends State<MotorcycleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 5, vsync: this, initialIndex: widget.initialTab);
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _mbg,
      body: Column(children: [
        // AppBar 영역
        Container(
          color: _mcard,
          child: SafeArea(
            bottom: false,
            child: Column(children: [
              // 상단 바
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: _mt1, size: 20),
                    padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  Row(children: [
                    const Text('🏍️', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 6),
                    Text('MOINCAR 오토바이',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 17, fontWeight: FontWeight.w800,
                        color: _mt1, letterSpacing: -0.3)),
                  ]),
                  const Spacer(),
                  // 협회인증 배지
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _mred.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: _mred.withOpacity(0.5)),
                    ),
                    child: Text('🏆 협회인증',
                      style: GoogleFonts.notoSansKr(
                        color: _mred, fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
                ]),
              ),
              // 탭바
              TabBar(
                controller: _tab,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorColor: _mred,
                indicatorWeight: 2.5,
                labelColor: _mt1,
                unselectedLabelColor: _mt3,
                labelStyle: GoogleFonts.notoSansKr(
                    fontSize: 13, fontWeight: FontWeight.w700),
                unselectedLabelStyle: GoogleFonts.notoSansKr(
                    fontSize: 13, fontWeight: FontWeight.w500),
                tabs: const [
                  Tab(text: '🏠  홈'),
                  Tab(text: '🔧  점포'),
                  Tab(text: '🤝  사고팔기'),
                  Tab(text: '💬  커뮤니티'),
                  Tab(text: 'ℹ️  정보'),
                ],
              ),
            ]),
          ),
        ),
        // 탭 콘텐츠
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: [
              _MotoHomeTab(onTabSwitch: (i) => _tab.animateTo(i)),
              const _MotoShopTab(),
              const _MotoListingsTab(),
              const _MotoCommunityTab(),
              const _MotoInfoTab(),
            ],
          ),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// 탭 0: 홈 (히어로 + 4개 카테고리 카드)
// ══════════════════════════════════════════════════════════════
class _MotoHomeTab extends StatefulWidget {
  final void Function(int) onTabSwitch;
  const _MotoHomeTab({required this.onTabSwitch});
  @override
  State<_MotoHomeTab> createState() => _MotoHomeTabState();
}

class _MotoHomeTabState extends State<_MotoHomeTab> {
  int _heroBanner = 0;
  final PageController _pageCtrl = PageController();

  final _banners = [
    {'img': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&q=80',
     'title': '내 주변\n바이크 점포 찾기', 'sub': '정비 · 검사 · 용품 · 판매'},
    {'img': 'https://images.unsplash.com/photo-1568772585407-9361f9bf3a87?w=800&q=80',
     'title': '우리끼리\n믿고 사고팔기', 'sub': '사고이력 · 검사상태 · 튜닝여부 공개'},
    {'img': 'https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?w=800&q=80',
     'title': '동호회 · 배달라이더\n정보 한곳에', 'sub': '지역모임 · 번개 · 투어 · 커뮤니티'},
    {'img': 'https://images.unsplash.com/photo-1593941707882-a5bba53b0998?w=800&q=80',
     'title': '검사 · 정비 · 전기이륜\n정보 확인', 'sub': '안전 · 교육 · 보조금 · 충전 정보'},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      // ── 히어로 배너 ──
      SizedBox(
        height: 200,
        child: Stack(children: [
          PageView.builder(
            controller: _pageCtrl,
            itemCount: _banners.length,
            onPageChanged: (i) => setState(() => _heroBanner = i),
            itemBuilder: (_, i) {
              final b = _banners[i];
              return Stack(fit: StackFit.expand, children: [
                Image.network(b['img']!, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: _mcard2)),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight, end: Alignment.centerLeft,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.85)],
                    ),
                  ),
                ),
                Positioned(bottom: 24, left: 20, child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(b['title']!,
                      style: GoogleFonts.notoSansKr(
                        color: _mt1, fontSize: 18, fontWeight: FontWeight.w800,
                        height: 1.3)),
                    const SizedBox(height: 4),
                    Text(b['sub']!,
                      style: GoogleFonts.notoSansKr(
                        color: _mt2, fontSize: 11, fontWeight: FontWeight.w500)),
                  ],
                )),
              ]);
            },
          ),
          // 페이지 인디케이터
          Positioned(bottom: 10, right: 16, child: Row(
            children: List.generate(_banners.length, (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(left: 4),
              width: _heroBanner == i ? 18 : 6, height: 4,
              decoration: BoxDecoration(
                color: _heroBanner == i ? _mred : _mt3,
                borderRadius: BorderRadius.circular(2)),
            )),
          )),
        ]),
      ),
      const SizedBox(height: 20),

      // ── 핵심 카테고리 4개 카드 ──
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('바이크 라이프', style: GoogleFonts.notoSansKr(
            color: _mt1, fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Row(children: [
            _categoryCard('🔧', '바이크\n점포', _mred,
              '정비·검사·판매·용품', () => widget.onTabSwitch(1)),
            const SizedBox(width: 10),
            _categoryCard('🤝', '사고\n팔기', _morange,
              '안전거래·검증매물', () => widget.onTabSwitch(2)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            _categoryCard('💬', '동호회\n커뮤니티', const Color(0xFF7C3AED),
              '모임·번개·배달라이더', () => widget.onTabSwitch(3)),
            const SizedBox(width: 10),
            _categoryCard('ℹ️', '검사·정비\n라이더정보', _mgreen,
              '안전·교육·전기이륜', () => widget.onTabSwitch(4)),
          ]),
        ]),
      ),
      const SizedBox(height: 20),

      // ── 오늘의 인기 매물 (상위 3개) ──
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 6),
        child: Row(children: [
          Text('🔥 인기 매물', style: GoogleFonts.notoSansKr(
            color: _mt1, fontSize: 15, fontWeight: FontWeight.w800)),
          const Spacer(),
          GestureDetector(
            onTap: () => widget.onTabSwitch(2),
            child: Text('전체보기 ›', style: GoogleFonts.notoSansKr(
              color: _mred, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ]),
      ),
      ...MotoState().listings.take(3).map((l) => _MotoListingMiniCard(listing: l)),

      const SizedBox(height: 20),

      // ── 인근 점포 TOP 3 ──
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 6),
        child: Row(children: [
          Text('📍 내 주변 점포', style: GoogleFonts.notoSansKr(
            color: _mt1, fontSize: 15, fontWeight: FontWeight.w800)),
          const Spacer(),
          GestureDetector(
            onTap: () => widget.onTabSwitch(1),
            child: Text('전체보기 ›', style: GoogleFonts.notoSansKr(
              color: _mred, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ]),
      ),
      SizedBox(
        height: 130,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          itemCount: MotoState().shops.length,
          itemBuilder: (_, i) => _MotoShopMiniCard(shop: MotoState().shops[i]),
        ),
      ),
      const SizedBox(height: 20),

      // ── 커뮤니티 최신글 ──
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 6),
        child: Row(children: [
          Text('💬 커뮤니티 최신', style: GoogleFonts.notoSansKr(
            color: _mt1, fontSize: 15, fontWeight: FontWeight.w800)),
          const Spacer(),
          GestureDetector(
            onTap: () => widget.onTabSwitch(3),
            child: Text('전체보기 ›', style: GoogleFonts.notoSansKr(
              color: _mred, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ]),
      ),
      ...MotoState().posts.take(2).map((p) => _PostMiniCard(post: p)),
      const SizedBox(height: 32),
    ]);
  }

  Widget _categoryCard(String emoji, String title, Color color,
      String sub, VoidCallback onTap) {
    return Expanded(child: GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [color.withOpacity(0.25), _mcard2],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.5), width: 1.2),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 12),
          ]),
          const Spacer(),
          Text(title,
            style: GoogleFonts.notoSansKr(
              color: _mt1, fontSize: 13, fontWeight: FontWeight.w800, height: 1.25)),
          const SizedBox(height: 2),
          Text(sub,
            style: GoogleFonts.notoSansKr(color: _mt3, fontSize: 9),
            maxLines: 1, overflow: TextOverflow.ellipsis),
        ]),
      ),
    ));
  }
}

// ── 홈탭 매물 미니카드 ──
class _MotoListingMiniCard extends StatelessWidget {
  final MotoListing listing;
  const _MotoListingMiniCard({required this.listing});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => _MotoListingDetailScreen(listing: listing))),
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _mcard, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _mborder),
        ),
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              listing.photoUrls.isNotEmpty ? listing.photoUrls.first : '',
              width: 80, height: 70, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 80, height: 70, color: _mcard2,
                child: const Icon(Icons.two_wheeler_rounded, color: _mt3, size: 30)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${listing.manufacturer} ${listing.model}',
              style: GoogleFonts.notoSansKr(
                color: _mt1, fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 3),
            Text('${listing.displacement}cc · ${listing.year} · ${_fmtMileage(listing.mileage)}km',
              style: GoogleFonts.notoSansKr(color: _mt2, fontSize: 10)),
            const SizedBox(height: 6),
            Row(children: [
              Text('${_fmtPrice(listing.price)}만원',
                style: GoogleFonts.notoSansKr(
                  color: _mt1, fontSize: 15, fontWeight: FontWeight.w900)),
              const Spacer(),
              if (listing.isClubRecommended)
                _badge('동호회추천', _mgreen),
              if (listing.accidentFlag) ...[
                const SizedBox(width: 4), _badge('사고', _mred)],
              if (listing.tuningFlag) ...[
                const SizedBox(width: 4), _badge('튜닝', _morange)],
            ]),
          ])),
        ]),
      ),
    );
  }
  Widget _badge(String t, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
    decoration: BoxDecoration(
      color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(4),
      border: Border.all(color: c.withOpacity(0.5))),
    child: Text(t, style: TextStyle(color: c, fontSize: 8, fontWeight: FontWeight.w800)),
  );
}

// ── 홈탭 점포 미니카드 ──
class _MotoShopMiniCard extends StatelessWidget {
  final MotoShop shop;
  const _MotoShopMiniCard({required this.shop});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => _MotoShopDetailScreen(shop: shop))),
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: _mcard, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _mborder)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(shop.imageUrl,
              height: 68, width: double.infinity, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 68, color: _mcard2,
                child: const Icon(Icons.store_rounded, color: _mt3, size: 28))),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(shop.type.label,
                style: GoogleFonts.notoSansKr(
                  color: _mred, fontSize: 9, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(shop.name,
                style: GoogleFonts.notoSansKr(
                  color: _mt1, fontSize: 11, fontWeight: FontWeight.w700),
                maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Row(children: [
                const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 11),
                const SizedBox(width: 2),
                Text('${shop.rating}', style: GoogleFonts.notoSansKr(
                  color: _mt2, fontSize: 9)),
                if (shop.isCertified) ...[
                  const SizedBox(width: 4),
                  const Text('✓인증', style: TextStyle(color: _mgreen, fontSize: 8)),
                ],
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ── 홈탭 게시글 미니카드 ──
class _PostMiniCard extends StatelessWidget {
  final MotoCommunityPost post;
  const _PostMiniCard({required this.post});
  @override
  Widget build(BuildContext context) {
    final totalReactions = post.reactions.fold<int>(0, (s, r) => s + r.count);
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _mcard, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _mborder)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _mred.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
            child: Text(post.type.label,
              style: GoogleFonts.notoSansKr(color: _mred, fontSize: 9, fontWeight: FontWeight.w700)),
          ),
          const Spacer(),
          Text(_timeAgo(post.createdAt),
            style: GoogleFonts.notoSansKr(color: _mt3, fontSize: 9)),
        ]),
        const SizedBox(height: 6),
        Text(post.title,
          style: GoogleFonts.notoSansKr(
            color: _mt1, fontSize: 13, fontWeight: FontWeight.w700),
          maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 3),
        Text(post.content,
          style: GoogleFonts.notoSansKr(color: _mt2, fontSize: 11),
          maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 8),
        Row(children: [
          Icon(Icons.remove_red_eye_outlined, color: _mt3, size: 11),
          const SizedBox(width: 3),
          Text('${post.viewCount}', style: GoogleFonts.notoSansKr(color: _mt3, fontSize: 10)),
          const SizedBox(width: 10),
          Icon(Icons.chat_bubble_outline, color: _mt3, size: 11),
          const SizedBox(width: 3),
          Text('${post.commentCount}', style: GoogleFonts.notoSansKr(color: _mt3, fontSize: 10)),
          const SizedBox(width: 10),
          Text('반응 $totalReactions', style: GoogleFonts.notoSansKr(color: _mt3, fontSize: 10)),
        ]),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// 탭 1: 오토바이 점포
// ══════════════════════════════════════════════════════════════
class _MotoShopTab extends StatefulWidget {
  const _MotoShopTab();
  @override
  State<_MotoShopTab> createState() => _MotoShopTabState();
}

class _MotoShopTabState extends State<_MotoShopTab> {
  MotoShopType? _selectedType;

  List<MotoShop> get _filtered {
    final all = MotoState().shops;
    if (_selectedType == null) return all;
    return all.where((s) => s.type == _selectedType).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // 유형 필터 칩
      Container(
        color: _mcard,
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            _chip('전체', _selectedType == null, () => setState(() => _selectedType = null)),
            ...MotoShopType.values.map((t) =>
              _chip(t.label, _selectedType == t, () => setState(() => _selectedType = t))),
          ]),
        ),
      ),
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.all(14),
          itemCount: _filtered.length,
          itemBuilder: (_, i) => _MotoShopCard(shop: _filtered[i]),
        ),
      ),
    ]);
  }

  Widget _chip(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? _mred : _mcard2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? _mred : _mborder),
        ),
        child: Text(label, style: GoogleFonts.notoSansKr(
          color: active ? _mt1 : _mt2, fontSize: 12,
          fontWeight: active ? FontWeight.w700 : FontWeight.w500)),
      ),
    );
  }
}

class _MotoShopCard extends StatelessWidget {
  final MotoShop shop;
  const _MotoShopCard({required this.shop});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => _MotoShopDetailScreen(shop: shop))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _mcard, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _mborder)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // 이미지
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: Stack(children: [
              Image.network(shop.imageUrl,
                height: 130, width: double.infinity, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 130, color: _mcard2,
                  child: const Icon(Icons.store_rounded, color: _mt3, size: 50))),
              // 인증 배지
              if (shop.isCertified)
                Positioned(top: 10, right: 10, child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: _mgreen.withOpacity(0.9), borderRadius: BorderRadius.circular(6)),
                  child: const Text('🏆 협회인증',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                )),
              if (shop.isClubPartner)
                Positioned(top: 10, left: 10, child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(6)),
                  child: const Text('동호회제휴',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                )),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: _mred.withOpacity(0.15), borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: _mred.withOpacity(0.5))),
                  child: Text(shop.type.label,
                    style: TextStyle(color: _mred, fontSize: 10, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 8),
                if (shop.hasElectric)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4)),
                    child: const Text('⚡전기이륜',
                      style: TextStyle(color: _mgreen, fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
                const Spacer(),
                Row(children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 14),
                  const SizedBox(width: 2),
                  Text('${shop.rating} (${shop.reviewCount})',
                    style: GoogleFonts.notoSansKr(color: _mt2, fontSize: 11)),
                ]),
              ]),
              const SizedBox(height: 8),
              Text(shop.name,
                style: GoogleFonts.notoSansKr(
                  color: _mt1, fontSize: 15, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(shop.address,
                style: GoogleFonts.notoSansKr(color: _mt2, fontSize: 11)),
              if (shop.brands.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(spacing: 6, runSpacing: 4, children: shop.brands.map((b) =>
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: _mcard2, borderRadius: BorderRadius.circular(4)),
                    child: Text(b, style: GoogleFonts.notoSansKr(color: _mt2, fontSize: 10)),
                  )).toList()),
              ],
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: OutlinedButton.icon(
                  onPressed: () => _call(shop.phone),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: _mred.withOpacity(0.6)),
                    foregroundColor: _mred,
                    padding: const EdgeInsets.symmetric(vertical: 10)),
                  icon: const Icon(Icons.phone_rounded, size: 14),
                  label: Text('전화', style: GoogleFonts.notoSansKr(
                    fontSize: 12, fontWeight: FontWeight.w700)),
                )),
                const SizedBox(width: 8),
                Expanded(child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => _MotoShopDetailScreen(shop: shop))),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _mred,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  icon: const Icon(Icons.storefront_rounded, size: 14, color: Colors.white),
                  label: Text('상세보기', style: GoogleFonts.notoSansKr(
                    color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                )),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  void _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) launchUrl(uri);
  }
}

// ══════════════════════════════════════════════════════════════
// 탭 2: 오토바이 사고팔기
// ══════════════════════════════════════════════════════════════
class _MotoListingsTab extends StatefulWidget {
  const _MotoListingsTab();
  @override
  State<_MotoListingsTab> createState() => _MotoListingsTabState();
}

class _MotoListingsTabState extends State<_MotoListingsTab> {
  String _sort = '최신순';

  List<MotoListing> get _sorted {
    final list = List<MotoListing>.from(MotoState().listings);
    switch (_sort) {
      case '최신순': list.sort((a, b) => b.createdAt.compareTo(a.createdAt)); break;
      case '가격낮은순': list.sort((a, b) => a.price.compareTo(b.price)); break;
      case '인기순': list.sort((a, b) => b.viewCount.compareTo(a.viewCount)); break;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // 상단: 정렬 + 등록 버튼
      Container(
        color: _mcard,
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        child: Row(children: [
          ...['최신순', '가격낮은순', '인기순'].map((s) => GestureDetector(
            onTap: () => setState(() => _sort = s),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _sort == s ? _mred : _mcard2,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _sort == s ? _mred : _mborder)),
              child: Text(s, style: GoogleFonts.notoSansKr(
                color: _sort == s ? _mt1 : _mt2, fontSize: 11,
                fontWeight: _sort == s ? FontWeight.w700 : FontWeight.w500)),
            ),
          )),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => const _MotoListingRegisterScreen())),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _mred, borderRadius: BorderRadius.circular(8)),
              child: Text('+ 내 바이크 팔기', style: GoogleFonts.notoSansKr(
                color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
      ),
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.all(14),
          itemCount: _sorted.length,
          itemBuilder: (_, i) => _MotoListingCard(
            listing: _sorted[i],
            onRefresh: () => setState(() {}),
          ),
        ),
      ),
    ]);
  }
}

class _MotoListingCard extends StatelessWidget {
  final MotoListing listing;
  final VoidCallback onRefresh;
  const _MotoListingCard({required this.listing, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => _MotoListingDetailScreen(listing: listing))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _mcard, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _mborder)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // 썸네일
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14), bottomLeft: Radius.circular(14)),
              child: Stack(children: [
                Image.network(
                  listing.photoUrls.isNotEmpty ? listing.photoUrls.first : '',
                  width: 110, height: 110, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 110, height: 110, color: _mcard2,
                    child: const Icon(Icons.two_wheeler_rounded, color: _mt3, size: 40))),
                if (listing.isMyListing)
                  Positioned(top: 4, left: 4, child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(4)),
                    child: const Text('내 매물',
                      style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w800)),
                  )),
              ]),
            ),
            // 정보
            Expanded(child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${listing.manufacturer} ${listing.model}',
                  style: GoogleFonts.notoSansKr(
                    color: _mt1, fontSize: 14, fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text('${listing.displacement}cc · ${listing.year}',
                  style: GoogleFonts.notoSansKr(color: _mt2, fontSize: 11)),
                Text('${_fmtMileage(listing.mileage)}km · ${listing.color}',
                  style: GoogleFonts.notoSansKr(color: _mt2, fontSize: 11)),
                const SizedBox(height: 6),
                Text('${_fmtPrice(listing.price)}만원',
                  style: GoogleFonts.notoSansKr(
                    color: _mt1, fontSize: 16, fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                // 신뢰성 배지
                Wrap(spacing: 4, runSpacing: 4, children: [
                  _trustBadge('✅ ${listing.inspectionStatus}', _mgreen),
                  _trustBadge('📄 서류${listing.documentStatus}', _maccent),
                  if (listing.accidentFlag) _trustBadge('⚠️ 사고', _mred),
                  if (listing.tuningFlag) _trustBadge('🔩 튜닝', _morange),
                  if (listing.isClubRecommended) _trustBadge('🏆 동호회추천', const Color(0xFFFFD700)),
                ]),
              ]),
            )),
          ]),
          // 하단 통계
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(children: [
              Icon(Icons.remove_red_eye_outlined, color: _mt3, size: 12),
              const SizedBox(width: 3),
              Text('${listing.viewCount}', style: GoogleFonts.notoSansKr(color: _mt3, fontSize: 10)),
              const SizedBox(width: 10),
              Icon(Icons.chat_bubble_outline, color: _mt3, size: 12),
              const SizedBox(width: 3),
              Text('${listing.inquiryCount}', style: GoogleFonts.notoSansKr(color: _mt3, fontSize: 10)),
              const SizedBox(width: 10),
              Icon(Icons.favorite_border_rounded, color: _mt3, size: 12),
              const SizedBox(width: 3),
              Text('${listing.likeCount}', style: GoogleFonts.notoSansKr(color: _mt3, fontSize: 10)),
              const Spacer(),
              Text(listing.region, style: GoogleFonts.notoSansKr(color: _mt3, fontSize: 10)),
              const SizedBox(width: 6),
              Text(_timeAgo(listing.createdAt),
                style: GoogleFonts.notoSansKr(color: _mt3, fontSize: 10)),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _trustBadge(String t, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
    decoration: BoxDecoration(
      color: c.withOpacity(0.12), borderRadius: BorderRadius.circular(4),
      border: Border.all(color: c.withOpacity(0.4))),
    child: Text(t, style: TextStyle(color: c, fontSize: 8, fontWeight: FontWeight.w700)),
  );
}

// ══════════════════════════════════════════════════════════════
// 탭 3: 커뮤니티 + 영상
// ══════════════════════════════════════════════════════════════
class _MotoCommunityTab extends StatefulWidget {
  const _MotoCommunityTab();
  @override
  State<_MotoCommunityTab> createState() => _MotoCommunityTabState();
}

class _MotoCommunityTabState extends State<_MotoCommunityTab> {
  int _subTab = 0; // 0=전체 1=동호회 2=배달라이더 3=영상 4=교육
  final _tabs = ['전체', '동호회', '배달라이더', '영상', '교육'];

  MotoCommunityType? get _filterType {
    switch (_subTab) {
      case 1: return MotoCommunityType.brand;
      case 2: return MotoCommunityType.delivery;
      default: return null;
    }
  }

  List<MotoCommunityPost> get _posts {
    if (_filterType == null) return MotoState().posts;
    return MotoState().posts.where((p) => p.type == _filterType).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // 서브탭 바
      Container(
        color: _mcard,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(children: List.generate(_tabs.length, (i) => GestureDetector(
            onTap: () => setState(() => _subTab = i),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: _subTab == i ? _mred : _mcard2,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _subTab == i ? _mred : _mborder)),
              child: Text(_tabs[i], style: GoogleFonts.notoSansKr(
                color: _subTab == i ? _mt1 : _mt2,
                fontSize: 12, fontWeight: _subTab == i ? FontWeight.w700 : FontWeight.w500)),
            ),
          ))),
        ),
      ),
      // 콘텐츠
      Expanded(child: Builder(builder: (_) {
        if (_subTab == 3) return _buildVideoList();
        if (_subTab == 4) return _buildEducationList();
        return _buildPostList();
      })),
      // 글쓰기 FAB
      if (_subTab < 3)
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
            child: SizedBox(width: double.infinity, child: ElevatedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const _MotoPostWriteScreen())).then((_) => setState(() {})),
              style: ElevatedButton.styleFrom(
                backgroundColor: _mred,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
              label: Text('글쓰기', style: GoogleFonts.notoSansKr(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
            )),
          ),
        ),
    ]);
  }

  Widget _buildPostList() {
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: _posts.length,
      itemBuilder: (_, i) => _CommunityPostCard(
        post: _posts[i],
        onReact: (idx) { MotoState().toggleReaction(_posts[i].postId, idx); setState(() {}); },
      ),
    );
  }

  Widget _buildVideoList() {
    final videos = MotoState().videos;
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: videos.length + 1,
      itemBuilder: (_, i) {
        if (i == 0) return _videoRegisterCard();
        return _VideoCard(video: videos[i - 1]);
      },
    );
  }

  Widget _buildEducationList() {
    final edu = MotoState().videos
        .where((v) => v.category == MotoVideoCategory.education).toList();
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        _infoCard('🎓 초보자 필수', '라이센스 취득부터 첫 라이딩까지', const Color(0xFF7C3AED)),
        _infoCard('🚴 배달라이더 필수', '소모품 관리·안전운전·사고처리', _mred),
        _infoCard('🔧 정비 기초', '오일교환·타이어·브레이크 직접 점검', _morange),
        const SizedBox(height: 8),
        Text('교육 영상', style: GoogleFonts.notoSansKr(
          color: _mt1, fontSize: 14, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        ...edu.map((v) => _VideoCard(video: v)),
      ],
    );
  }

  Widget _videoRegisterCard() => GestureDetector(
    onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => const _MotoVideoRegisterScreen())),
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _mcard, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _mred.withOpacity(0.4), style: BorderStyle.solid),
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: _mred.withOpacity(0.15), shape: BoxShape.circle),
          child: const Icon(Icons.video_call_rounded, color: _mred, size: 24)),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('영상 등록하기', style: GoogleFonts.notoSansKr(
            color: _mt1, fontSize: 13, fontWeight: FontWeight.w700)),
          Text('유튜브 URL로 바이크 영상을 공유하세요',
            style: GoogleFonts.notoSansKr(color: _mt2, fontSize: 11)),
        ]),
        const Spacer(),
        const Icon(Icons.arrow_forward_ios_rounded, color: _mt3, size: 14),
      ]),
    ),
  );

  Widget _infoCard(String title, String sub, Color color) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [color.withOpacity(0.2), _mcard2]),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.4))),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.notoSansKr(
          color: _mt1, fontSize: 13, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(sub, style: GoogleFonts.notoSansKr(color: _mt2, fontSize: 11)),
      ])),
      Icon(Icons.play_circle_fill_rounded, color: color, size: 32),
    ]),
  );
}

// 커뮤니티 게시글 카드 (이모지 반응 포함)
class _CommunityPostCard extends StatelessWidget {
  final MotoCommunityPost post;
  final void Function(int) onReact;
  const _CommunityPostCard({required this.post, required this.onReact});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _mcard, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _mborder)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // 헤더
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
          child: Row(children: [
            CircleAvatar(radius: 16, backgroundColor: _mcard2,
              child: Text(post.authorName.substring(0, 1),
                style: const TextStyle(color: _mt1, fontSize: 13, fontWeight: FontWeight.w700))),
            const SizedBox(width: 8),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(post.authorName, style: GoogleFonts.notoSansKr(
                color: _mt1, fontSize: 12, fontWeight: FontWeight.w700)),
              Text(_timeAgo(post.createdAt), style: GoogleFonts.notoSansKr(
                color: _mt3, fontSize: 10)),
            ]),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: _mred.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
              child: Text(post.type.label, style: GoogleFonts.notoSansKr(
                color: _mred, fontSize: 9, fontWeight: FontWeight.w700)),
            ),
          ]),
        ),
        // 제목/내용
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(post.title, style: GoogleFonts.notoSansKr(
              color: _mt1, fontSize: 14, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(post.content, style: GoogleFonts.notoSansKr(color: _mt2, fontSize: 12),
              maxLines: 3, overflow: TextOverflow.ellipsis),
          ]),
        ),
        // 이미지
        if (post.photoUrls.isNotEmpty) ...[
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.zero,
            child: Image.network(post.photoUrls.first,
              height: 180, width: double.infinity, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox()),
          ),
        ],
        // 이모지 반응 바
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: Row(children: List.generate(post.reactions.length, (i) {
            final r = post.reactions[i];
            return GestureDetector(
              onTap: () => onReact(i),
              child: Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: r.myReacted ? _mred.withOpacity(0.2) : _mcard2,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: r.myReacted ? _mred.withOpacity(0.7) : _mborder)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(r.emoji, style: const TextStyle(fontSize: 13)),
                  if (r.count > 0) ...[
                    const SizedBox(width: 3),
                    Text('${r.count}', style: GoogleFonts.notoSansKr(
                      color: r.myReacted ? _mred : _mt2, fontSize: 10,
                      fontWeight: FontWeight.w700)),
                  ],
                ]),
              ),
            );
          })),
        ),
        // 조회/댓글
        Container(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          child: Row(children: [
            Icon(Icons.remove_red_eye_outlined, color: _mt3, size: 12),
            const SizedBox(width: 3),
            Text('${post.viewCount}', style: GoogleFonts.notoSansKr(color: _mt3, fontSize: 10)),
            const SizedBox(width: 10),
            Icon(Icons.chat_bubble_outline, color: _mt3, size: 12),
            const SizedBox(width: 3),
            Text('${post.commentCount}', style: GoogleFonts.notoSansKr(color: _mt3, fontSize: 10)),
          ]),
        ),
      ]),
    );
  }
}

// 영상 카드
class _VideoCard extends StatelessWidget {
  final MotoVideo video;
  const _VideoCard({required this.video});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(video.youtubeUrl);
        if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _mcard, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _mborder)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // 썸네일
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Stack(children: [
              Image.network(video.thumbnailUrl,
                height: 160, width: double.infinity, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 160, color: _mcard2,
                  child: const Icon(Icons.play_circle_outline, color: _mt3, size: 48))),
              Positioned.fill(child: Center(child: Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.9), shape: BoxShape.circle),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
              ))),
              Positioned(top: 8, right: 8, child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: _mred, borderRadius: BorderRadius.circular(4)),
                child: Text(video.category.label, style: const TextStyle(
                  color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
              )),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(video.title, style: GoogleFonts.notoSansKr(
                color: _mt1, fontSize: 13, fontWeight: FontWeight.w700),
                maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Row(children: [
                Text(video.channelName, style: GoogleFonts.notoSansKr(
                  color: _mt2, fontSize: 11)),
                const SizedBox(width: 8),
                Text('조회 ${video.viewCountText}', style: GoogleFonts.notoSansKr(
                  color: _mt3, fontSize: 10)),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// 탭 4: 오토바이 정보 (검사/정비/안전/전기이륜)
// ══════════════════════════════════════════════════════════════
class _MotoInfoTab extends StatelessWidget {
  const _MotoInfoTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        // 검사 안내
        _section('🔍 오토바이 검사 안내', _mred, [
          _infoItem('검사 대상', '125cc 초과 이륜차 (이륜자동차)'),
          _infoItem('검사 주기', '최초 검사: 3년 / 이후: 2년마다'),
          _infoItem('검사 항목', '제동장치·조향장치·소음·배출가스'),
          _infoItem('주의', '미검사 시 과태료 최대 50만원'),
        ]),
        const SizedBox(height: 14),
        // 정비 팁
        _section('🔧 정비 가이드', _morange, [
          _infoItem('엔진오일', '3,000km 또는 3개월마다 교환'),
          _infoItem('타이어', '트레드 깊이 1.6mm 이하 시 교체 필수'),
          _infoItem('브레이크 패드', '배달 라이더 기준 8,000km 교체'),
          _infoItem('배터리', '2~3년 주기 점검 권장'),
          _infoItem('체인', '청소+오일링 2,000km마다'),
        ]),
        const SizedBox(height: 14),
        // 안전 정보
        _section('🦺 안전 라이딩', _maccent, [
          _infoItem('헬멧', 'KS·ECE 22.05 인증 필수 착용'),
          _infoItem('빗길 주의', '급제동·급가속 금지, 차선 변경 자제'),
          _infoItem('배달 라이더', '시속 60km 이하 유지, 신호 준수'),
          _infoItem('야간 라이딩', '재귀반사 용품 착용 권장'),
          _infoItem('사고 시', '보험사 즉시 연락 → 경찰 신고'),
        ]),
        const SizedBox(height: 14),
        // 전기이륜차 정보
        _section('⚡ 전기이륜차 정보', _mgreen, [
          _infoItem('보조금', '국가+지자체 합산 최대 200만원 지원'),
          _infoItem('보조금 신청', '지자체 공고 후 선착순 신청'),
          _infoItem('충전', '전용 충전소 또는 일반 220V 충전'),
          _infoItem('배터리교환', '배달용 교환형 배터리 스테이션 확장 중'),
          _infoItem('검사 면제', '최고속도 25km/h 이하 시 검사 면제'),
        ]),
        const SizedBox(height: 14),
        // 전기이륜 취급 점포 바로가기
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => MotorcycleScreen(initialTab: 1))),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [_mgreen.withOpacity(0.2), _mcard2]),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _mgreen.withOpacity(0.5))),
            child: Row(children: [
              const Text('⚡', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('전기이륜 취급 점포 바로가기', style: GoogleFonts.notoSansKr(
                  color: _mt1, fontSize: 13, fontWeight: FontWeight.w800)),
                Text('가까운 전기이륜 전문점을 찾아보세요',
                  style: GoogleFonts.notoSansKr(color: _mt2, fontSize: 11)),
              ])),
              const Icon(Icons.arrow_forward_ios_rounded, color: _mgreen, size: 16),
            ]),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _section(String title, Color color, List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: _mcard, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _mborder)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14))),
          child: Text(title, style: GoogleFonts.notoSansKr(
            color: color, fontSize: 14, fontWeight: FontWeight.w800)),
        ),
        ...items,
      ]),
    );
  }

  Widget _infoItem(String label, String value) => Padding(
    padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
    child: Column(children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 80, child: Text(label, style: GoogleFonts.notoSansKr(
          color: _mt3, fontSize: 11, fontWeight: FontWeight.w600))),
        Expanded(child: Text(value, style: GoogleFonts.notoSansKr(
          color: _mt1, fontSize: 12, fontWeight: FontWeight.w500))),
      ]),
      const SizedBox(height: 10),
      Divider(color: _mborder.withOpacity(0.5), height: 1),
    ]),
  );
}

// ══════════════════════════════════════════════════════════════
// 점포 상세 화면
// ══════════════════════════════════════════════════════════════
class _MotoShopDetailScreen extends StatelessWidget {
  final MotoShop shop;
  const _MotoShopDetailScreen({required this.shop});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _mbg,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          backgroundColor: _mcard,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _mt1, size: 20)),
          expandedHeight: 200,
          flexibleSpace: FlexibleSpaceBar(
            background: Image.network(shop.imageUrl, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: _mcard2))),
          title: Text(shop.name, style: GoogleFonts.notoSansKr(
            color: _mt1, fontSize: 15, fontWeight: FontWeight.w800)),
          pinned: true,
        ),
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // 배지
            Wrap(spacing: 6, children: [
              if (shop.isCertified) _badge('🏆 협회인증', _mgreen),
              if (shop.isClubPartner) _badge('동호회제휴', const Color(0xFF7C3AED)),
              if (shop.hasInspection) _badge('🔍 검사가능', _maccent),
              if (shop.hasElectric) _badge('⚡ 전기이륜', _mgreen),
            ]),
            const SizedBox(height: 14),
            // 기본 정보
            _row(Icons.location_on_outlined, shop.address),
            const SizedBox(height: 8),
            _row(Icons.phone_outlined, shop.phone),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 16),
              const SizedBox(width: 4),
              Text('${shop.rating} · 리뷰 ${shop.reviewCount}건',
                style: GoogleFonts.notoSansKr(color: _mt1, fontSize: 13)),
            ]),
            const SizedBox(height: 16),
            // 서비스 항목
            if (shop.services.isNotEmpty) ...[
              Text('서비스 항목', style: GoogleFonts.notoSansKr(
                color: _mt1, fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 6, children: shop.services.map((s) =>
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _mcard, borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _mborder)),
                  child: Text(s, style: GoogleFonts.notoSansKr(color: _mt1, fontSize: 12)),
                )).toList()),
              const SizedBox(height: 16),
            ],
            // 취급 브랜드
            if (shop.brands.isNotEmpty) ...[
              Text('취급 브랜드', style: GoogleFonts.notoSansKr(
                color: _mt1, fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 6, children: shop.brands.map((b) =>
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _mred.withOpacity(0.1), borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _mred.withOpacity(0.3))),
                  child: Text(b, style: GoogleFonts.notoSansKr(color: _mred, fontSize: 12)),
                )).toList()),
              const SizedBox(height: 24),
            ],
            // 전화 + 채팅 버튼
            Row(children: [
              Expanded(child: OutlinedButton.icon(
                onPressed: () async {
                  final uri = Uri(scheme: 'tel', path: shop.phone);
                  if (await canLaunchUrl(uri)) launchUrl(uri);
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: _mred.withOpacity(0.6)),
                  foregroundColor: _mred,
                  padding: const EdgeInsets.symmetric(vertical: 14)),
                icon: const Icon(Icons.phone_rounded, size: 16),
                label: Text('전화하기', style: GoogleFonts.notoSansKr(
                  fontSize: 13, fontWeight: FontWeight.w700)),
              )),
              const SizedBox(width: 10),
              Expanded(child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/chat',
                    arguments: {'storeName': shop.name, 'storeId': 0}),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _mred,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                icon: const Icon(Icons.chat_bubble_rounded, size: 16, color: Colors.white),
                label: Text('채팅 문의', style: GoogleFonts.notoSansKr(
                  color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
              )),
            ]),
          ]),
        )),
      ]),
    );
  }

  Widget _badge(String t, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(6),
      border: Border.all(color: c.withOpacity(0.5))),
    child: Text(t, style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w700)),
  );

  Widget _row(IconData icon, String text) => Row(children: [
    Icon(icon, color: _mt3, size: 15),
    const SizedBox(width: 8),
    Expanded(child: Text(text, style: GoogleFonts.notoSansKr(color: _mt1, fontSize: 13))),
  ]);
}

// ══════════════════════════════════════════════════════════════
// 매물 상세 화면 (소통요소 포함)
// ══════════════════════════════════════════════════════════════
class _MotoListingDetailScreen extends StatefulWidget {
  final MotoListing listing;
  const _MotoListingDetailScreen({required this.listing});
  @override
  State<_MotoListingDetailScreen> createState() => _MotoListingDetailScreenState();
}

class _MotoListingDetailScreenState extends State<_MotoListingDetailScreen> {
  bool _liked = false;
  final _commentCtrl = TextEditingController();
  final List<String> _comments = [];

  @override
  Widget build(BuildContext context) {
    final l = widget.listing;
    return Scaffold(
      backgroundColor: _mbg,
      appBar: AppBar(
        backgroundColor: _mcard,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _mt1, size: 20)),
        title: Text('${l.manufacturer} ${l.model}',
          style: GoogleFonts.notoSansKr(color: _mt1, fontSize: 15, fontWeight: FontWeight.w800)),
      ),
      body: Column(children: [
        Expanded(child: ListView(children: [
          // 대표 이미지
          if (l.photoUrls.isNotEmpty)
            Image.network(l.photoUrls.first, height: 240, width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(height: 240, color: _mcard2,
                child: const Icon(Icons.two_wheeler_rounded, color: _mt3, size: 60))),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // 기본 정보
              Text('${l.manufacturer} ${l.model}',
                style: GoogleFonts.notoSansKr(color: _mt1, fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text('${l.displacement}cc · ${l.year} · ${_fmtMileage(l.mileage)}km · ${l.color}',
                style: GoogleFonts.notoSansKr(color: _mt2, fontSize: 12)),
              const SizedBox(height: 8),
              Text('${_fmtPrice(l.price)}만원',
                style: GoogleFonts.notoSansKr(color: _mred, fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              // 신뢰성 정보
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _mcard, borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _mborder)),
                child: Column(children: [
                  _trustRow('검사상태', l.inspectionStatus, _mgreen),
                  _trustRow('서류상태', l.documentStatus, _maccent),
                  _trustRow('사고여부', l.accidentFlag ? '사고 있음 - ${l.accidentDetail}' : '무사고', l.accidentFlag ? _mred : _mgreen),
                  _trustRow('튜닝여부', l.tuningFlag ? '튜닝 있음 - ${l.tuningDetail}' : '순정', l.tuningFlag ? _morange : _mgreen),
                  if (l.recentMaintenance.isNotEmpty)
                    _trustRow('최근정비', l.recentMaintenance, _maccent),
                ]),
              ),
              const SizedBox(height: 14),
              // 설명
              Text('판매자 설명', style: GoogleFonts.notoSansKr(
                color: _mt1, fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(l.desc, style: GoogleFonts.notoSansKr(color: _mt1, fontSize: 13, height: 1.6)),
              const SizedBox(height: 14),
              // 좋아요 + 이모지 반응
              Row(children: [
                GestureDetector(
                  onTap: () { setState(() { _liked = !_liked; if (_liked) l.likeCount++; }); },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: _liked ? _mred.withOpacity(0.2) : _mcard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _liked ? _mred : _mborder)),
                    child: Row(children: [
                      Icon(Icons.favorite_rounded,
                        color: _liked ? _mred : _mt3, size: 16),
                      const SizedBox(width: 4),
                      Text('${l.likeCount}', style: GoogleFonts.notoSansKr(
                        color: _liked ? _mred : _mt2, fontSize: 12, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ),
                const SizedBox(width: 8),
                Text('${l.region} · ${_timeAgo(l.createdAt)}',
                  style: GoogleFonts.notoSansKr(color: _mt3, fontSize: 11)),
              ]),
              const SizedBox(height: 16),
              // 댓글 영역
              Text('댓글 ${_comments.length + l.inquiryCount}',
                style: GoogleFonts.notoSansKr(color: _mt1, fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              if (l.inquiryCount > 0)
                ...List.generate(l.inquiryCount, (i) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _mcard, borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _mborder)),
                  child: Row(children: [
                    const CircleAvatar(radius: 14, backgroundColor: _mcard2,
                      child: Icon(Icons.person_rounded, color: _mt3, size: 16)),
                    const SizedBox(width: 8),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('익명 구매자 ${i + 1}', style: GoogleFonts.notoSansKr(
                        color: _mt1, fontSize: 11, fontWeight: FontWeight.w700)),
                      Text('차량 상태 문의드립니다. 직거래 가능할까요?',
                        style: GoogleFonts.notoSansKr(color: _mt2, fontSize: 11)),
                    ])),
                  ]),
                )),
              ..._comments.map((c) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _mcard, borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _mborder)),
                child: Text(c, style: GoogleFonts.notoSansKr(color: _mt1, fontSize: 12)),
              )),
            ]),
          ),
        ])),
        // 하단: 댓글 입력 + 채팅
        Container(
          color: _mcard,
          padding: EdgeInsets.only(
            left: 14, right: 14, top: 10,
            bottom: MediaQuery.of(context).viewInsets.bottom + 10),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // 댓글 입력
            Row(children: [
              Expanded(child: TextField(
                controller: _commentCtrl,
                style: GoogleFonts.notoSansKr(color: _mt1, fontSize: 13),
                decoration: InputDecoration(
                  hintText: '댓글을 입력하세요...',
                  hintStyle: GoogleFonts.notoSansKr(color: _mt3, fontSize: 13),
                  filled: true, fillColor: _mcard2,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: _mborder)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: _mborder)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              )),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  if (_commentCtrl.text.trim().isNotEmpty) {
                    setState(() {
                      _comments.add(_commentCtrl.text.trim());
                      _commentCtrl.clear();
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: _mred, shape: BoxShape.circle),
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 18)),
              ),
            ]),
            const SizedBox(height: 8),
            SizedBox(width: double.infinity, child: ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/chat',
                  arguments: {'storeName': '${l.manufacturer} ${l.model} 판매자', 'storeId': 0}),
              style: ElevatedButton.styleFrom(
                backgroundColor: _mred,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              icon: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 16),
              label: Text('1:1 채팅 문의', style: GoogleFonts.notoSansKr(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
            )),
          ]),
        ),
      ]),
    );
  }

  Widget _trustRow(String label, String value, Color color) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      SizedBox(width: 70, child: Text(label, style: GoogleFonts.notoSansKr(
        color: _mt3, fontSize: 11, fontWeight: FontWeight.w600))),
      Container(width: 2, height: 12, color: _mborder, margin: const EdgeInsets.symmetric(horizontal: 8)),
      Expanded(child: Text(value, style: GoogleFonts.notoSansKr(
        color: color, fontSize: 12, fontWeight: FontWeight.w600))),
    ]),
  );
}

// ══════════════════════════════════════════════════════════════
// 매물 등록 화면
// ══════════════════════════════════════════════════════════════
class _MotoListingRegisterScreen extends StatefulWidget {
  const _MotoListingRegisterScreen();
  @override
  State<_MotoListingRegisterScreen> createState() => _MotoListingRegisterScreenState();
}

class _MotoListingRegisterScreenState extends State<_MotoListingRegisterScreen> {
  final _maker = TextEditingController();
  final _model = TextEditingController();
  final _cc = TextEditingController();
  final _year = TextEditingController();
  final _mileage = TextEditingController();
  final _price = TextEditingController();
  final _desc = TextEditingController();
  final _region = TextEditingController();
  final _color = TextEditingController();
  bool _accident = false;
  bool _tuning = false;
  String _inspectionStatus = '정상';
  String _docStatus = '완비';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _mbg,
      appBar: AppBar(
        backgroundColor: _mcard,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _mt1, size: 20)),
        title: Text('내 바이크 팔기', style: GoogleFonts.notoSansKr(
          color: _mt1, fontSize: 16, fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('기본 정보'),
          _field('제조사', _maker, hint: '혼다, 야마하, 가와사키 등'),
          _field('모델명', _model, hint: 'CB500F, MT-07 등'),
          _field('배기량(cc)', _cc, hint: '예) 471', type: TextInputType.number),
          _field('연식', _year, hint: '예) 2022년식'),
          _field('주행거리(km)', _mileage, hint: '예) 8500', type: TextInputType.number),
          _field('가격(만원)', _price, hint: '예) 650', type: TextInputType.number),
          _field('지역', _region, hint: '예) 대구 수성구'),
          _field('색상', _color, hint: '예) 매트 블랙'),
          const SizedBox(height: 16),
          _section('상태 정보'),
          // 사고 여부
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _mcard, borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _mborder)),
            child: Row(children: [
              Text('사고 여부', style: GoogleFonts.notoSansKr(color: _mt1, fontSize: 13)),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _accident = false),
                child: _toggle('무사고', !_accident, _mgreen)),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => setState(() => _accident = true),
                child: _toggle('사고있음', _accident, _mred)),
            ]),
          ),
          // 튜닝 여부
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _mcard, borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _mborder)),
            child: Row(children: [
              Text('튜닝 여부', style: GoogleFonts.notoSansKr(color: _mt1, fontSize: 13)),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _tuning = false),
                child: _toggle('순정', !_tuning, _mgreen)),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => setState(() => _tuning = true),
                child: _toggle('튜닝있음', _tuning, _morange)),
            ]),
          ),
          // 검사 상태
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _mcard, borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _mborder)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('검사 상태', style: GoogleFonts.notoSansKr(color: _mt1, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Row(children: ['정상', '불합격', '미검사'].map((s) => GestureDetector(
                onTap: () => setState(() => _inspectionStatus = s),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _inspectionStatus == s ? _maccent.withOpacity(0.2) : _mcard2,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _inspectionStatus == s ? _maccent : _mborder)),
                  child: Text(s, style: GoogleFonts.notoSansKr(
                    color: _inspectionStatus == s ? _maccent : _mt2, fontSize: 12)),
                ),
              )).toList()),
            ]),
          ),
          const SizedBox(height: 4),
          _field('설명', _desc, hint: '차량 상태, 특이사항 등', maxLines: 4),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: _mred,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text('매물 등록하기', style: GoogleFonts.notoSansKr(
              color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
          )),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _submit() {
    if (_maker.text.trim().isEmpty || _model.text.trim().isEmpty || _price.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('제조사, 모델, 가격은 필수입니다'),
        backgroundColor: _mred));
      return;
    }
    final newListing = MotoListing(
      listingId: 'ML-NEW-${DateTime.now().millisecondsSinceEpoch}',
      manufacturer: _maker.text.trim(), model: _model.text.trim(),
      displacement: int.tryParse(_cc.text.trim()) ?? 0,
      year: _year.text.trim().isEmpty ? '연식 미입력' : _year.text.trim(),
      mileage: int.tryParse(_mileage.text.trim()) ?? 0,
      price: int.tryParse(_price.text.trim()) ?? 0,
      region: _region.text.trim().isEmpty ? '지역 미입력' : _region.text.trim(),
      desc: _desc.text.trim(), color: _color.text.trim(),
      accidentFlag: _accident, tuningFlag: _tuning,
      inspectionStatus: _inspectionStatus, documentStatus: _docStatus,
      isMyListing: true, ownerId: 'me',
      createdAt: DateTime.now(),
    );
    MotoState().addListing(newListing);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${newListing.manufacturer} ${newListing.model} 매물이 등록되었습니다'),
      backgroundColor: _mgreen));
  }

  Widget _section(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(t, style: GoogleFonts.notoSansKr(
      color: _mt1, fontSize: 14, fontWeight: FontWeight.w800)));

  Widget _field(String label, TextEditingController ctrl,
      {String? hint, TextInputType? type, int maxLines = 1}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: ctrl, maxLines: maxLines,
        keyboardType: type ?? TextInputType.text,
        style: GoogleFonts.notoSansKr(color: _mt1, fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.notoSansKr(color: _mt3, fontSize: 12),
          hintText: hint,
          hintStyle: GoogleFonts.notoSansKr(color: _mt3, fontSize: 12),
          filled: true, fillColor: _mcard,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _mborder)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _mborder)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: _mred.withOpacity(0.7))),
        ),
      ),
    );
  }

  Widget _toggle(String label, bool active, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: active ? color.withOpacity(0.2) : _mcard2,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: active ? color : _mborder)),
    child: Text(label, style: GoogleFonts.notoSansKr(
      color: active ? color : _mt2, fontSize: 12, fontWeight: FontWeight.w700)),
  );
}

// ══════════════════════════════════════════════════════════════
// 글쓰기 화면
// ══════════════════════════════════════════════════════════════
class _MotoPostWriteScreen extends StatefulWidget {
  const _MotoPostWriteScreen();
  @override
  State<_MotoPostWriteScreen> createState() => _MotoPostWriteScreenState();
}

class _MotoPostWriteScreenState extends State<_MotoPostWriteScreen> {
  final _title = TextEditingController();
  final _content = TextEditingController();
  MotoCommunityType _type = MotoCommunityType.brand;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _mbg,
      appBar: AppBar(
        backgroundColor: _mcard,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded, color: _mt1, size: 22)),
        title: Text('커뮤니티 글쓰기', style: GoogleFonts.notoSansKr(
          color: _mt1, fontSize: 16, fontWeight: FontWeight.w800)),
        actions: [
          TextButton(
            onPressed: _submit,
            child: Text('등록', style: GoogleFonts.notoSansKr(
              color: _mred, fontSize: 14, fontWeight: FontWeight.w800))),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // 카테고리 선택
        Text('카테고리', style: GoogleFonts.notoSansKr(
          color: _mt2, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: MotoCommunityType.values.map((t) => GestureDetector(
            onTap: () => setState(() => _type = t),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: _type == t ? _mred : _mcard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _type == t ? _mred : _mborder)),
              child: Text(t.label, style: GoogleFonts.notoSansKr(
                color: _type == t ? _mt1 : _mt2, fontSize: 12,
                fontWeight: _type == t ? FontWeight.w700 : FontWeight.w500)),
            ),
          )).toList()),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _title,
          style: GoogleFonts.notoSansKr(color: _mt1, fontSize: 16, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            hintText: '제목을 입력하세요',
            hintStyle: GoogleFonts.notoSansKr(color: _mt3, fontSize: 16),
            border: InputBorder.none, filled: true, fillColor: _mcard,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _content, maxLines: 10,
          style: GoogleFonts.notoSansKr(color: _mt1, fontSize: 13),
          decoration: InputDecoration(
            hintText: '내용을 입력하세요...',
            hintStyle: GoogleFonts.notoSansKr(color: _mt3, fontSize: 13),
            border: InputBorder.none, filled: true, fillColor: _mcard,
          ),
        ),
      ]),
    );
  }

  void _submit() {
    if (_title.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('제목을 입력하세요'), backgroundColor: _mred));
      return;
    }
    MotoState().addPost(MotoCommunityPost(
      postId: 'MP-${DateTime.now().millisecondsSinceEpoch}',
      type: _type, authorName: '나',
      title: _title.text.trim(), content: _content.text.trim(),
      createdAt: DateTime.now(),
      reactions: [
        EmojiReaction(emoji: '👍', label: '좋아요'),
        EmojiReaction(emoji: '❤️', label: '찜'),
        EmojiReaction(emoji: '🔥', label: '인기'),
        EmojiReaction(emoji: '😮', label: '놀람'),
        EmojiReaction(emoji: '😢', label: '아쉬움'),
        EmojiReaction(emoji: '👎', label: '비추'),
      ],
    ));
    Navigator.pop(context);
  }
}

// ══════════════════════════════════════════════════════════════
// 영상 등록 화면
// ══════════════════════════════════════════════════════════════
class _MotoVideoRegisterScreen extends StatefulWidget {
  const _MotoVideoRegisterScreen();
  @override
  State<_MotoVideoRegisterScreen> createState() => _MotoVideoRegisterScreenState();
}

class _MotoVideoRegisterScreenState extends State<_MotoVideoRegisterScreen> {
  final _url = TextEditingController();
  final _title = TextEditingController();
  final _channel = TextEditingController();
  MotoVideoCategory _cat = MotoVideoCategory.review;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _mbg,
      appBar: AppBar(
        backgroundColor: _mcard,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded, color: _mt1, size: 22)),
        title: Text('영상 등록', style: GoogleFonts.notoSansKr(
          color: _mt1, fontSize: 16, fontWeight: FontWeight.w800)),
        actions: [
          TextButton(
            onPressed: _submit,
            child: Text('등록', style: GoogleFonts.notoSansKr(
              color: _mred, fontSize: 14, fontWeight: FontWeight.w800))),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text('유튜브 URL', style: GoogleFonts.notoSansKr(color: _mt2, fontSize: 12)),
        const SizedBox(height: 6),
        _fld(_url, 'https://www.youtube.com/watch?v=...'),
        const SizedBox(height: 12),
        Text('제목', style: GoogleFonts.notoSansKr(color: _mt2, fontSize: 12)),
        const SizedBox(height: 6),
        _fld(_title, '영상 제목을 입력하세요'),
        const SizedBox(height: 12),
        Text('채널명', style: GoogleFonts.notoSansKr(color: _mt2, fontSize: 12)),
        const SizedBox(height: 6),
        _fld(_channel, '채널명 또는 이름'),
        const SizedBox(height: 12),
        Text('카테고리', style: GoogleFonts.notoSansKr(color: _mt2, fontSize: 12)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: MotoVideoCategory.values.map((c) =>
          GestureDetector(
            onTap: () => setState(() => _cat = c),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: _cat == c ? _mred : _mcard,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _cat == c ? _mred : _mborder)),
              child: Text(c.label, style: GoogleFonts.notoSansKr(
                color: _cat == c ? _mt1 : _mt2, fontSize: 12,
                fontWeight: _cat == c ? FontWeight.w700 : FontWeight.w500)),
            ),
          )).toList()),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, child: ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: _mred,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: Text('영상 등록', style: GoogleFonts.notoSansKr(
            color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
        )),
      ]),
    );
  }

  void _submit() {
    if (_url.text.trim().isEmpty || _title.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('URL과 제목은 필수입니다'), backgroundColor: _mred));
      return;
    }
    MotoState().videos.insert(0, MotoVideo(
      videoId: 'V-${DateTime.now().millisecondsSinceEpoch}',
      youtubeUrl: _url.text.trim(),
      thumbnailUrl: 'https://images.unsplash.com/photo-1568772585407-9361f9bf3a87?w=400&q=80',
      title: _title.text.trim(),
      channelName: _channel.text.trim().isEmpty ? '사용자 등록' : _channel.text.trim(),
      viewCountText: '0회', category: _cat,
    ));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('영상이 등록되었습니다'), backgroundColor: Color(0xFF10B981)));
  }

  Widget _fld(TextEditingController ctrl, String hint) => TextField(
    controller: ctrl,
    style: GoogleFonts.notoSansKr(color: _mt1, fontSize: 13),
    decoration: InputDecoration(
      hintText: hint, hintStyle: GoogleFonts.notoSansKr(color: _mt3, fontSize: 12),
      filled: true, fillColor: _mcard,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _mborder)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _mborder)),
    ),
  );
}

// ══════════════════════════════════════════════════════════════
// 유틸리티
// ══════════════════════════════════════════════════════════════
String _fmtMileage(int m) {
  if (m >= 10000) return '${(m / 10000).toStringAsFixed(1)}만';
  return m.toString();
}

String _fmtPrice(int p) => p.toString().replaceAllMapped(
  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

String _timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
  if (diff.inHours < 24) return '${diff.inHours}시간 전';
  return '${diff.inDays}일 전';
}
