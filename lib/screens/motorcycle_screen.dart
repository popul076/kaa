import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/app_state.dart';

// ── 컬러 팔레트 ──────────────────────────────────────────────
const _mbg     = Color(0xFF050A0F);
const _mcard   = Color(0xFF0D1721);
const _mcard2  = Color(0xFF111E2C);
const _mred    = Color(0xFFE63946);
const _morange = Color(0xFFFF6B35);
const _maccent = Color(0xFF4FC3F7);
const _mgreen  = Color(0xFF10B981);
const _mborder = Color(0xFF1A2A3A);
const _mt1     = Colors.white;
const _mt2     = Color(0xFFB0BEC5);
const _mt3     = Color(0xFF546E7A);

// ── 공통 텍스트 스타일 헬퍼 ──────────────────────────────────
TextStyle _ts(double sz, FontWeight fw, Color c, {double ls = -0.2}) =>
    GoogleFonts.notoSansKr(fontSize: sz, fontWeight: fw, color: c, letterSpacing: ls);

// ── 공통 배지 ────────────────────────────────────────────────
Widget _badge(String t, Color bg, {Color? tc}) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
  decoration: BoxDecoration(color: bg.withOpacity(0.18),
    borderRadius: BorderRadius.circular(5),
    border: Border.all(color: bg.withOpacity(0.5))),
  child: Text(t, style: _ts(10, FontWeight.w700, tc ?? bg)),
);

// ── 6종 이모지 반응 위젯 ─────────────────────────────────────
class _EmojiBar extends StatelessWidget {
  final List<EmojiReaction> reactions;
  final void Function(int) onTap;
  const _EmojiBar({required this.reactions, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(reactions.length, (i) {
        final r = reactions[i];
        return GestureDetector(
          onTap: () => onTap(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
              color: r.myReacted ? _mred.withOpacity(0.2) : _mcard2,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: r.myReacted ? _mred.withOpacity(0.6) : _mborder),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(r.emoji, style: const TextStyle(fontSize: 13)),
              if (r.count > 0) ...[
                const SizedBox(width: 3),
                Text('${r.count}', style: _ts(11, FontWeight.w600, r.myReacted ? _mred : _mt2)),
              ],
            ]),
          ),
        );
      }),
    );
  }
}

// ── 댓글 시트 ────────────────────────────────────────────────
void _showCommentSheet(BuildContext ctx, List<MotoComment> comments,
    void Function(String) onAdd) {
  final ctrl = TextEditingController();
  showModalBottomSheet(
    context: ctx,
    isScrollControlled: true,
    backgroundColor: _mcard,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (_) => StatefulBuilder(builder: (ctx2, ss) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx2).viewInsets.bottom),
        child: SizedBox(
          height: 420,
          child: Column(children: [
            const SizedBox(height: 12),
            Container(width: 36, height: 3, decoration: BoxDecoration(
                color: _mt3, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 10),
            Text('댓글 ${comments.length}개', style: _ts(14, FontWeight.w700, _mt1)),
            const Divider(color: _mborder),
            Expanded(child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: comments.length,
              itemBuilder: (_, i) {
                final c = comments[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    CircleAvatar(radius: 16, backgroundColor: _mcard2,
                      child: Text(c.authorName.isNotEmpty ? c.authorName[0] : 'U',
                          style: _ts(12, FontWeight.w700, _maccent))),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Text(c.authorName, style: _ts(12, FontWeight.w700, _mt1)),
                        const SizedBox(width: 6),
                        Text(_timeAgo(c.createdAt), style: _ts(10, FontWeight.w400, _mt3)),
                      ]),
                      const SizedBox(height: 3),
                      Text(c.content, style: _ts(13, FontWeight.w400, _mt2)),
                    ])),
                  ]),
                );
              },
            )),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: ctrl,
                    style: _ts(13, FontWeight.w400, _mt1),
                    decoration: InputDecoration(
                      hintText: '댓글을 입력하세요...',
                      hintStyle: _ts(13, FontWeight.w400, _mt3),
                      filled: true, fillColor: _mcard2,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: _mborder)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: _mborder)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: _maccent.withOpacity(0.6))),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    if (ctrl.text.trim().isEmpty) return;
                    onAdd(ctrl.text.trim());
                    ctrl.clear();
                    ss(() {});
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: _mred, shape: BoxShape.circle),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      );
    }),
  );
}

// ── 시간 포맷 ─────────────────────────────────────────────────
String _timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return '방금';
  if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
  if (diff.inHours < 24) return '${diff.inHours}시간 전';
  if (diff.inDays < 7) return '${diff.inDays}일 전';
  return '${dt.month}/${dt.day}';
}

String _dateStr(DateTime dt) =>
    '${dt.year}.${dt.month.toString().padLeft(2,'0')}.${dt.day.toString().padLeft(2,'0')}';

String _fmtPrice(int price) {
  if (price >= 10000) {
    final eok = price ~/ 10000;
    final rem = price % 10000;
    return rem == 0 ? '$eok억' : '$eok억 $rem';
  }
  return price.toString();
}

String _fmtMileage(int km) {
  if (km >= 10000) {
    return '${(km / 10000).toStringAsFixed(1)}만';
  }
  return km.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
}

// ── 사진 선택 공통 (image_picker 사용) ──────────────────────
// 실제 기기에서 작동; 시뮬레이터에서는 빈 리스트 반환
Future<List<String>> _pickImages(BuildContext ctx, {int max = 10}) async {
  // 선택 방식 다이얼로그
  final src = await showModalBottomSheet<String>(
    context: ctx,
    backgroundColor: const Color(0xFF0D1721),
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 36, height: 3,
              decoration: BoxDecoration(color: const Color(0xFF546E7A),
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.camera_alt_rounded, color: Color(0xFF4FC3F7)),
            title: Text('카메라 촬영',
                style: GoogleFonts.notoSansKr(fontSize: 14,
                    fontWeight: FontWeight.w600, color: Colors.white)),
            onTap: () => Navigator.pop(_, 'camera'),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_rounded, color: Color(0xFF4FC3F7)),
            title: Text('앨범에서 선택',
                style: GoogleFonts.notoSansKr(fontSize: 14,
                    fontWeight: FontWeight.w600, color: Colors.white)),
            onTap: () => Navigator.pop(_, 'gallery'),
          ),
        ]),
      ),
    ),
  );
  if (src == null) return [];
  try {
    final picker = ImagePicker();
    if (src == 'camera') {
      final img = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
      return img != null ? [img.path] : [];
    } else {
      final imgs = await picker.pickMultiImage(imageQuality: 85, limit: max);
      return imgs.map((x) => x.path).toList();
    }
  } catch (_) {
    return [];
  }
}

// ── 완료 팝업 (확인 후 콜백 실행) ────────────────────────────
Future<void> _showDone(BuildContext ctx, String msg, {VoidCallback? then}) async {
  await showDialog(
    context: ctx,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF0D1721),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: Row(children: [
        const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 22),
        const SizedBox(width: 8),
        Text('완료', style: GoogleFonts.notoSansKr(
            fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
      ]),
      content: Text(msg, style: GoogleFonts.notoSansKr(
          fontSize: 14, fontWeight: FontWeight.w400, color: const Color(0xFFB0BEC5))),
      actions: [
        TextButton(
          onPressed: () { Navigator.pop(_); if (then != null) then(); },
          child: Text('확인', style: GoogleFonts.notoSansKr(
              fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF4FC3F7))),
        ),
      ],
    ),
  );
}

// ══════════════════════════════════════════════════════════════
// MotorcycleScreen — 메인 (탭 5개)
// ══════════════════════════════════════════════════════════════
class MotorcycleScreen extends StatefulWidget {
  final int initialTab;
  final String? highlightListingId;
  const MotorcycleScreen({super.key, this.initialTab = 0, this.highlightListingId});
  @override
  State<MotorcycleScreen> createState() => _MotorcycleScreenState();
}

class _MotorcycleScreenState extends State<MotorcycleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  // 탭별 독립 Navigator 키
  final _navKeys = List.generate(5, (_) => GlobalKey<NavigatorState>());

  // 뒤로가기 처리
  // 1) 탭 내부 스택(상세페이지 등) 있으면 → 탭내 pop
  // 2) 탭 내부 스택 없고 홈탭(0) 아니면 → 홈탭(0)으로 이동
  // 3) 홈탭(0)이면 → 앱루트 pop (오토바이메인 → 모인카홈)
  Future<bool> _handleBack() async {
    final idx = _tab.index;
    final key = _navKeys[idx];
    // 탭 내부에 상세페이지가 쌓여 있으면 탭내에서만 pop
    if (key.currentState != null && key.currentState!.canPop()) {
      key.currentState!.pop();
      return false;
    }
    // 홈탭 아닌 탭에서 뒤로가기 → 홈탭(0)으로 이동
    if (idx != 0) {
      _tab.animateTo(0);
      return false;
    }
    // 홈탭에서 뒤로가기 → 앱루트 pop (모인카 홈으로)
    return true;
  }

  @override
  void initState() {
    super.initState();
    _tab = TabController(
        length: 5, vsync: this, initialIndex: widget.initialTab);
    // 특정 매물 하이라이트 요청 처리
    if (widget.highlightListingId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final listing = MotoState().listings.firstWhere(
            (l) => l.listingId == widget.highlightListingId,
            orElse: () => MotoState().listings.first);
        Navigator.push(context,
            MaterialPageRoute(
                builder: (_) => _MotoListingDetailScreen(listing: listing)));
      });
    }
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _handleBack();
        if (shouldPop && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: _mbg,
        body: NestedScrollView(
          headerSliverBuilder: (ctx, _) => [
            SliverToBoxAdapter(
              child: Container(
                color: _mcard,
                child: SafeArea(
                  bottom: false,
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 6, 16, 0),
                      child: Row(children: [
                        IconButton(
                          onPressed: () async {
                            final shouldPop = await _handleBack();
                            if (shouldPop && context.mounted) Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: _mt1, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 4),
                        Text('오토바이',
                            style: _ts(18, FontWeight.w800, _mt1, ls: -0.5)),
                        const Spacer(),
                        _badge('협회인증', _mred),
                        const SizedBox(width: 8),
                        _badge('전기이륜 ⚡', _maccent),
                      ]),
                    ),
                    const SizedBox(height: 4),
                    TabBar(
                      controller: _tab,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      indicatorColor: _mred,
                      indicatorWeight: 2.5,
                      labelColor: _mt1,
                      unselectedLabelColor: _mt3,
                      labelStyle: _ts(13, FontWeight.w700, _mt1),
                      unselectedLabelStyle: _ts(13, FontWeight.w500, _mt3),
                      tabs: const [
                        Tab(text: '홈'),
                        Tab(text: '점포'),
                        Tab(text: '사고팔기'),
                        Tab(text: '동호회'),
                        Tab(text: '영상/정보'),
                      ],
                    ),
                  ]),
                ),
              ),
            ),
          ],
          body: TabBarView(
            controller: _tab,
            children: [
              _MotoHomeTab(onTabSwitch: (i) => _tab.animateTo(i)),
              _MotoShopNavTab(navigatorKey: _navKeys[1]),
              _MotoListingsNavTab(navigatorKey: _navKeys[2]),
              _MotoClubNavTab(navigatorKey: _navKeys[3]),
              _MotoVideoNavTab(navigatorKey: _navKeys[4]),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// 탭 0: 홈
// ══════════════════════════════════════════════════════════════
class _MotoHomeTab extends StatefulWidget {
  final void Function(int) onTabSwitch;
  const _MotoHomeTab({required this.onTabSwitch});
  @override
  State<_MotoHomeTab> createState() => _MotoHomeTabState();
}

class _MotoHomeTabState extends State<_MotoHomeTab> {
  int _banner = 0;
  final _pageCtrl = PageController();

  final _banners = [
    {'img': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&q=80',
     'title': '내 주변\n바이크 점포 찾기', 'sub': '정비 · 검사 · 용품 · 판매 · 튜닝'},
    {'img': 'https://images.unsplash.com/photo-1568772585407-9361f9bf3a87?w=800&q=80',
     'title': '우리끼리\n믿고 사고팔기', 'sub': '사고이력 · 검사상태 · 튜닝여부 공개'},
    {'img': 'https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?w=800&q=80',
     'title': '동호회 · 배달라이더\n정보 한곳에', 'sub': '지역모임 · 번개 · 투어 · 커뮤니티'},
    {'img': 'https://images.unsplash.com/photo-1593941707882-a5bba53b0998?w=800&q=80',
     'title': '검사 · 정비 · 전기이륜\n정보 확인', 'sub': '안전 · 교육 · 보조금 · 충전 정보'},
  ];

  @override
  void dispose() { _pageCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final state = MotoState();
    final latestPosts = [
      ...state.clubs.expand((c) => c.posts),
      ...state.posts,
    ]..sort((a, b) {
      final da = a is MotoClubPost ? a.createdAt : (a as MotoCommunityPost).createdAt;
      final db = b is MotoClubPost ? b.createdAt : (b as MotoCommunityPost).createdAt;
      return db.compareTo(da);
    });

    return ListView(children: [
      // ── 히어로 배너 ──
      SizedBox(
        height: 210,
        child: Stack(children: [
          PageView.builder(
            controller: _pageCtrl,
            itemCount: _banners.length,
            onPageChanged: (i) => setState(() => _banner = i),
            itemBuilder: (_, i) {
              final b = _banners[i];
              return Stack(fit: StackFit.expand, children: [
                Image.network(b['img']!, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: _mcard2)),
                Container(decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight, end: Alignment.centerLeft,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.85)]),
                )),
                Positioned(
                  left: 20, bottom: 20, right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(b['title']!, style: _ts(17, FontWeight.w800, _mt1, ls: -0.3),
                          overflow: TextOverflow.visible),
                      const SizedBox(height: 4),
                      Text(b['sub']!, style: _ts(11, FontWeight.w500, _mt2),
                          overflow: TextOverflow.visible),
                    ]),
                  ),
                ),
              ]);
            },
          ),
          // 인디케이터
          Positioned(top: 12, right: 16, child: Row(
            children: List.generate(_banners.length, (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(left: 4),
              width: _banner == i ? 18 : 6, height: 4,
              decoration: BoxDecoration(
                color: _banner == i ? _mred : _mt3,
                borderRadius: BorderRadius.circular(2)),
            )),
          )),
        ]),
      ),

      // ── 4대 기둥 카드 ──
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Text('라이더 플랫폼', style: _ts(13, FontWeight.w700, _mt3)),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        child: GridView.count(
          crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.7,
          children: [
            _pillCard('🔧', '점포', '정비·검사·판매·용품', _morange, () => widget.onTabSwitch(1)),
            _pillCard('🤝', '사고팔기', '직거래·신뢰거래', _maccent, () => widget.onTabSwitch(2)),
            _pillCard('🏆', '동호회', '가입·모임·게시판', _mgreen, () => widget.onTabSwitch(3)),
            _pillCard('▶', '영상/정보', '교육·검사·전기이륜', _mred, () => widget.onTabSwitch(4)),
          ],
        ),
      ),

      // ── 최신 동호회 소식 ──
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        child: Row(children: [
          Text('최신 동호회 소식', style: _ts(14, FontWeight.w700, _mt1)),
          const Spacer(),
          GestureDetector(
            onTap: () => widget.onTabSwitch(3),
            child: Text('더보기', style: _ts(12, FontWeight.w500, _mt3)),
          ),
        ]),
      ),
      SizedBox(
        height: 130,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: latestPosts.take(6).length,
          itemBuilder: (_, i) {
            final item = latestPosts[i];
            final isClub = item is MotoClubPost;
            final content = isClub ? (item as MotoClubPost).content : (item as MotoCommunityPost).title;
            final photos = isClub ? (item as MotoClubPost).photoUrls : (item as MotoCommunityPost).photoUrls;
            final dt = isClub ? (item as MotoClubPost).createdAt : (item as MotoCommunityPost).createdAt;
            final reactions = isClub ? (item as MotoClubPost).reactions : (item as MotoCommunityPost).reactions;
            final totalReactions = reactions.fold(0, (s, r) => s + r.count);
            return GestureDetector(
              onTap: () => widget.onTabSwitch(3),
              child: Container(
                width: 180,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: _mcard, borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _mborder),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (photos.isNotEmpty)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                      child: Image.network(photos[0], height: 70, width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(height: 70, color: _mcard2)),
                    )
                  else
                    Container(height: 70, width: double.infinity,
                        decoration: BoxDecoration(
                          color: _mcard2,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                        ),
                        child: const Center(child: Text('📝', style: TextStyle(fontSize: 28)))),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
                    child: Text(content, style: _ts(11, FontWeight.w500, _mt2),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(children: [
                      Text(_timeAgo(dt), style: _ts(10, FontWeight.w400, _mt3)),
                      const Spacer(),
                      Text('👍 $totalReactions', style: _ts(10, FontWeight.w400, _mt3)),
                    ]),
                  ),
                ]),
              ),
            );
          },
        ),
      ),

      // ── 주변 점포 미리보기 ──
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        child: Row(children: [
          Text('주변 바이크 점포', style: _ts(14, FontWeight.w700, _mt1)),
          const Spacer(),
          GestureDetector(
            onTap: () => widget.onTabSwitch(1),
            child: Text('더보기', style: _ts(12, FontWeight.w500, _mt3)),
          ),
        ]),
      ),
      ...state.shops.take(3).map((s) => _ShopMiniCard(shop: s,
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => _MotoShopDetailScreen(shop: s))))),

      const SizedBox(height: 20),
    ]);
  }

  Widget _pillCard(String icon, String title, String sub, Color accent, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: _mcard, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accent.withOpacity(0.35)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center, children: [
            Row(children: [
              Text(icon, style: TextStyle(fontSize: 18, color: accent)),
              const SizedBox(width: 6),
              Text(title, style: _ts(14, FontWeight.w800, _mt1)),
            ]),
            const SizedBox(height: 4),
            Text(sub, style: _ts(10, FontWeight.w500, _mt3),
                overflow: TextOverflow.ellipsis),
          ]),
        ),
      );
}

// ── 점포 미니카드 (홈용) ─────────────────────────────────────
class _ShopMiniCard extends StatelessWidget {
  final MotoShop shop;
  final VoidCallback onTap;
  const _ShopMiniCard({required this.shop, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: _mcard, borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _mborder)),
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(shop.imageUrl, width: 60, height: 50, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(width: 60, height: 50, color: _mcard2)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(shop.name, style: _ts(13, FontWeight.w700, _mt1)),
            const SizedBox(height: 2),
            Row(children: [
              _badge(shop.type.label, _morange),
              const SizedBox(width: 4),
              Text(shop.region, style: _ts(11, FontWeight.w400, _mt3)),
            ]),
          ])),
          Row(children: [
            const Icon(Icons.star_rounded, color: Color(0xFFFFD54F), size: 14),
            Text(' ${shop.rating}', style: _ts(12, FontWeight.w600, _mt2)),
          ]),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// 탭 1: 점포
// ── 점포 탭 독립 Navigator 래퍼 ────────────────────────────────
class _MotoShopNavTab extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const _MotoShopNavTab({required this.navigatorKey});
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (_) => const _MotoShopTab(),
      ),
    );
  }
}

// ── 사고팔기 탭 독립 Navigator 래퍼 ─────────────────────────
class _MotoListingsNavTab extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const _MotoListingsNavTab({required this.navigatorKey});
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (_) => const _MotoListingsTab(),
      ),
    );
  }
}

// ── 동호회 탭 독립 Navigator 래퍼 ───────────────────────────
class _MotoClubNavTab extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const _MotoClubNavTab({required this.navigatorKey});
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (_) => const _MotoClubTab(),
      ),
    );
  }
}

// ── 영상/정보 탭 독립 Navigator 래퍼 ────────────────────────
class _MotoVideoNavTab extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const _MotoVideoNavTab({required this.navigatorKey});
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (_) => const _MotoVideoInfoTab(),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
class _MotoShopTab extends StatefulWidget {
  const _MotoShopTab();
  @override
  State<_MotoShopTab> createState() => _MotoShopTabState();
}

class _MotoShopTabState extends State<_MotoShopTab> {
  MotoShopType? _filter;
  String _sort = '가까운순';
  final _searchCtrl = TextEditingController();
  String _keyword = '';

  List<MotoShop> get _shops {
    var list = List<MotoShop>.from(MotoState().shops);
    if (_filter != null) list = list.where((s) => s.type == _filter).toList();
    if (_keyword.isNotEmpty) {
      list = list.where((s) =>
        s.name.contains(_keyword) || s.region.contains(_keyword) ||
        s.services.any((sv) => sv.contains(_keyword))).toList();
    }
    if (_sort == '평점순') list.sort((a, b) => b.rating.compareTo(a.rating));
    return list;
  }

  static const _filterLabels = ['전체', '정비', '검사', '판매', '용품', '튜닝', '사고수리', '탁송'];

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // ── 가상 지도 ──
      Container(
        height: 180,
        color: const Color(0xFF0A1828),
        child: Stack(children: [
          CustomPaint(size: const Size(double.infinity, 180), painter: _MapPainter()),
          // 점포 마커
          ...MotoState().shops.asMap().entries.map((e) {
            final i = e.key;
            final s = e.value;
            final x = 40.0 + (i * 70.0) % 280;
            final y = 30.0 + (i * 43.0) % 110;
            return Positioned(left: x, top: y, child: GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => _MotoShopDetailScreen(shop: s))),
              child: Column(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: s.isCertified ? _mred : _morange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(s.name.length > 6 ? s.name.substring(0, 6) : s.name,
                      style: _ts(9, FontWeight.w700, Colors.white)),
                ),
                Container(width: 2, height: 6, color: s.isCertified ? _mred : _morange),
                Container(width: 6, height: 6, decoration: BoxDecoration(
                    color: s.isCertified ? _mred : _morange, shape: BoxShape.circle)),
              ]),
            ));
          }),
          Positioned(bottom: 8, right: 8, child:
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: _mbg.withOpacity(0.8), borderRadius: BorderRadius.circular(6)),
              child: Row(children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: _mred, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Text('협회인증', style: _ts(9, FontWeight.w600, _mt2)),
                const SizedBox(width: 8),
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: _morange, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Text('일반', style: _ts(9, FontWeight.w600, _mt2)),
              ]),
            ),
          ),
        ]),
      ),

      // ── 검색창 ──
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
        child: TextField(
          controller: _searchCtrl,
          style: _ts(13, FontWeight.w400, _mt1),
          onChanged: (v) => setState(() => _keyword = v),
          decoration: InputDecoration(
            hintText: '점포명·지역·서비스 검색',
            hintStyle: _ts(13, FontWeight.w400, _mt3),
            prefixIcon: const Icon(Icons.search, color: _mt3, size: 18),
            filled: true, fillColor: _mcard,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(color: _mborder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(color: _mborder)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide(color: _maccent.withOpacity(0.5))),
          ),
        ),
      ),

      // ── 필터 ──
      SizedBox(
        height: 36,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: _filterLabels.length + 2,
          itemBuilder: (_, i) {
            if (i < _filterLabels.length) {
              final label = _filterLabels[i];
              final selected = (label == '전체' && _filter == null) ||
                  (label != '전체' && _filter?.label == label);
              return GestureDetector(
                onTap: () => setState(() =>
                    _filter = label == '전체' ? null
                        : MotoShopType.values.firstWhere((t) => t.label == label)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected ? _mred : _mcard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: selected ? _mred : _mborder),
                  ),
                  child: Text(label, style: _ts(12, FontWeight.w600,
                      selected ? Colors.white : _mt2)),
                ),
              );
            }
            // 정렬 버튼
            final sortLabel = i == _filterLabels.length ? '가까운순' : '평점순';
            return GestureDetector(
              onTap: () => setState(() => _sort = sortLabel),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _sort == sortLabel ? _maccent.withOpacity(0.2) : _mcard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: _sort == sortLabel ? _maccent.withOpacity(0.6) : _mborder),
                ),
                child: Text(sortLabel,
                    style: _ts(12, FontWeight.w600,
                        _sort == sortLabel ? _maccent : _mt2)),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 6),

      // ── 점포 리스트 ──
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: _shops.length,
          itemBuilder: (_, i) => _MotoShopCard(
            shop: _shops[i],
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => _MotoShopDetailScreen(shop: _shops[i]))),
          ),
        ),
      ),
    ]);
  }
}

// ── 점포 카드 ────────────────────────────────────────────────
class _MotoShopCard extends StatelessWidget {
  final MotoShop shop;
  final VoidCallback onTap;
  const _MotoShopCard({required this.shop, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: _mcard, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _mborder)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(shop.imageUrl, width: 80, height: 65, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(width: 80, height: 65, color: _mcard2,
                      child: const Icon(Icons.store, color: _mt3, size: 28))),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(shop.name, style: _ts(14, FontWeight.w700, _mt1),
                    overflow: TextOverflow.ellipsis)),
                if (shop.isCertified) _badge('협회인증', _mred),
              ]),
              const SizedBox(height: 4),
              Wrap(spacing: 4, runSpacing: 4, children: [
                _badge(shop.type.label, _morange),
                if (shop.hasInspection) _badge('검사가능', _maccent),
                if (shop.hasElectric) _badge('전기이륜', _mgreen),
                if (shop.isClubPartner) _badge('동호회제휴', _mt3),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.location_on_rounded, color: _mt3, size: 12),
                Text(' ${shop.region}', style: _ts(11, FontWeight.w400, _mt3)),
                const Spacer(),
                const Icon(Icons.star_rounded, color: Color(0xFFFFD54F), size: 13),
                Text(' ${shop.rating} (${shop.reviewCount})', style: _ts(11, FontWeight.w500, _mt2)),
              ]),
            ])),
          ]),
          const SizedBox(height: 10),
          // 서비스 태그
          if (shop.services.isNotEmpty)
            Wrap(spacing: 4, runSpacing: 4, children: shop.services.take(4).map((s) =>
              Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(color: _mcard2, borderRadius: BorderRadius.circular(4)),
                child: Text(s, style: _ts(10, FontWeight.w500, _mt2)))).toList()),
          const SizedBox(height: 10),
          Row(children: [
            _actionBtn(Icons.phone_rounded, '전화', _mgreen, () async {
              final uri = Uri.parse('tel:${shop.phone}');
              if (await canLaunchUrl(uri)) launchUrl(uri);
            }),
            const SizedBox(width: 8),
            _actionBtn(Icons.chat_bubble_outline_rounded, '문의채팅', _maccent, () {
              Navigator.pushNamed(context, '/chat',
                  arguments: {'storeName': shop.name, 'storeId': 0});
            }),
            const SizedBox(width: 8),
            _actionBtn(Icons.calendar_month_rounded, '예약', _morange, onTap),
            const Spacer(),
            _actionBtn(Icons.arrow_forward_ios_rounded, '상세보기', _mt3, onTap),
          ]),
        ]),
      ),
    );
  }

  Widget _actionBtn(IconData icon, String label, Color color, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: color, size: 13),
            const SizedBox(width: 4),
            Text(label, style: _ts(11, FontWeight.w600, color)),
          ]),
        ),
      );
}

// ── 지도 페인터 ───────────────────────────────────────────────
class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFF0A1828);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bg);
    final road = Paint()..color = const Color(0xFF1A2A3A)..strokeWidth = 3..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, size.height * 0.4), Offset(size.width, size.height * 0.4), road);
    canvas.drawLine(Offset(0, size.height * 0.7), Offset(size.width, size.height * 0.7), road);
    canvas.drawLine(Offset(size.width * 0.3, 0), Offset(size.width * 0.3, size.height), road);
    canvas.drawLine(Offset(size.width * 0.65, 0), Offset(size.width * 0.65, size.height), road);
    final block = Paint()..color = const Color(0xFF0D1721);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.35, size.height * 0.1, size.width * 0.25, size.height * 0.25), block);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.05, size.height * 0.5, size.width * 0.2, size.height * 0.15), block);
  }
  @override
  bool shouldRepaint(_) => false;
}

// ══════════════════════════════════════════════════════════════
// 점포 상세 화면
// ══════════════════════════════════════════════════════════════
class _MotoShopDetailScreen extends StatefulWidget {
  final MotoShop shop;
  const _MotoShopDetailScreen({required this.shop});
  @override
  State<_MotoShopDetailScreen> createState() => _MotoShopDetailScreenState();
}

class _MotoShopDetailScreenState extends State<_MotoShopDetailScreen> {
  final _comments = <MotoComment>[];
  bool _liked = false;

  @override
  void initState() {
    super.initState();
    _comments.addAll(widget.shop.comments.map((c) => MotoComment(
        id: c.id, authorName: c.authorName, content: c.content, createdAt: c.createdAt)));
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.shop;
    return Scaffold(
      backgroundColor: _mbg,
      appBar: AppBar(
        backgroundColor: _mcard,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _mt1, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(s.name, style: _ts(16, FontWeight.w700, _mt1)),
        actions: [
          if (s.isCertified) Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _badge('협회인증', _mred),
          ),
        ],
      ),
      body: ListView(children: [
        // 대표 이미지
        Image.network(s.imageUrl, height: 200, width: double.infinity, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(height: 200, color: _mcard2)),
        Padding(padding: const EdgeInsets.all(16), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          // 기본 정보
          Row(children: [
            _badge(s.type.label, _morange),
            const SizedBox(width: 6),
            if (s.hasInspection) _badge('검사가능', _maccent),
            if (s.hasElectric) ...[const SizedBox(width: 6), _badge('전기이륜', _mgreen)],
            if (s.isClubPartner) ...[const SizedBox(width: 6), _badge('동호회제휴', _mt3)],
          ]),
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.location_on_rounded, color: _mt3, size: 14),
            Expanded(child: Text(' ${s.address}', style: _ts(13, FontWeight.w400, _mt2))),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.star_rounded, color: Color(0xFFFFD54F), size: 14),
            Text(' ${s.rating} (${s.reviewCount}건)', style: _ts(13, FontWeight.w500, _mt2)),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => setState(() => _liked = !_liked),
              child: Row(children: [
                Icon(_liked ? Icons.favorite : Icons.favorite_border,
                    color: _mred, size: 16),
                const SizedBox(width: 3),
                Text('${s.likeCount + (_liked ? 1 : 0)}', style: _ts(12, FontWeight.w500, _mt2)),
              ]),
            ),
          ]),

          // 취급 서비스
          if (s.services.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('취급 서비스', style: _ts(14, FontWeight.w700, _mt1)),
            const SizedBox(height: 8),
            Wrap(spacing: 6, runSpacing: 6, children: s.services.map((sv) =>
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: _mcard2,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _mborder)),
                child: Text(sv, style: _ts(12, FontWeight.w500, _mt2)))).toList()),
          ],

          // 취급 브랜드
          if (s.brands.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('취급 브랜드', style: _ts(14, FontWeight.w700, _mt1)),
            const SizedBox(height: 8),
            Wrap(spacing: 6, runSpacing: 6, children: s.brands.map((b) =>
              _badge(b, _maccent)).toList()),
          ],

          // 가상 지도
          const SizedBox(height: 16),
          Text('위치', style: _ts(14, FontWeight.w700, _mt1)),
          const SizedBox(height: 8),
          Container(
            height: 120,
            decoration: BoxDecoration(
                color: const Color(0xFF0A1828), borderRadius: BorderRadius.circular(10)),
            child: Stack(children: [
              CustomPaint(size: const Size(double.infinity, 120), painter: _MapPainter()),
              const Center(child: Icon(Icons.location_pin, color: _mred, size: 36)),
            ]),
          ),

          // 액션 버튼
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _fullBtn(Icons.phone_rounded, '전화', _mgreen, () async {
              final uri = Uri.parse('tel:${s.phone}');
              if (await canLaunchUrl(uri)) launchUrl(uri);
            })),
            const SizedBox(width: 8),
            Expanded(child: _fullBtn(Icons.chat_bubble_rounded, '1:1 문의', _maccent, () {
              Navigator.pushNamed(context, '/chat',
                  arguments: {'storeName': s.name, 'storeId': 0});
            })),
            const SizedBox(width: 8),
            Expanded(child: _fullBtn(Icons.calendar_month_rounded, '예약', _morange, () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${s.name} 예약이 요청되었습니다.'),
                    backgroundColor: _morange));
            })),
          ]),

          // 유튜브 소개 영상
          if (s.youtubeUrl != null) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                final uri = Uri.parse(s.youtubeUrl!);
                if (await canLaunchUrl(uri)) launchUrl(uri);
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: _mcard2,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFF0000).withOpacity(0.4))),
                child: Row(children: [
                  const Icon(Icons.play_circle_filled_rounded,
                      color: Color(0xFFFF0000), size: 32),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('점포 소개 영상', style: _ts(13, FontWeight.w700, _mt1)),
                    Text('YouTube에서 보기', style: _ts(11, FontWeight.w400, _mt3)),
                  ])),
                ]),
              ),
            ),
          ],

          // 댓글
          const SizedBox(height: 20),
          Row(children: [
            Text('댓글 ${_comments.length}', style: _ts(14, FontWeight.w700, _mt1)),
            const Spacer(),
            GestureDetector(
              onTap: () => _showCommentSheet(context, _comments, (text) {
                setState(() => _comments.add(MotoComment(
                    id: 'sc-${DateTime.now().millisecondsSinceEpoch}',
                    authorName: '나',
                    content: text,
                    createdAt: DateTime.now())));
              }),
              child: _badge('댓글 작성', _maccent),
            ),
          ]),
          const SizedBox(height: 8),
          ..._comments.take(3).map((c) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CircleAvatar(radius: 14, backgroundColor: _mcard2,
                  child: Text(c.authorName[0], style: _ts(11, FontWeight.w700, _maccent))),
              const SizedBox(width: 8),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(c.authorName, style: _ts(12, FontWeight.w700, _mt1)),
                Text(c.content, style: _ts(12, FontWeight.w400, _mt2)),
              ])),
            ]),
          )),
        ])),
      ]),
    );
  }

  Widget _fullBtn(IconData icon, String label, Color color, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: color, size: 15),
            const SizedBox(width: 4),
            Text(label, style: _ts(12, FontWeight.w700, color)),
          ]),
        ),
      );
}

// ══════════════════════════════════════════════════════════════
// 탭 2: 사고팔기
// ══════════════════════════════════════════════════════════════
class _MotoListingsTab extends StatefulWidget {
  const _MotoListingsTab();
  @override
  State<_MotoListingsTab> createState() => _MotoListingsTabState();
}

class _MotoListingsTabState extends State<_MotoListingsTab> {
  String _keyword = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final state = MotoState();
    final items = state.listings.where((l) {
      if (_keyword.isEmpty) return true;
      return l.manufacturer.contains(_keyword) || l.model.contains(_keyword) ||
          l.region.contains(_keyword);
    }).toList();

    return Column(children: [
      // 검색 + 등록 버튼
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              style: _ts(13, FontWeight.w400, _mt1),
              onChanged: (v) => setState(() => _keyword = v),
              decoration: InputDecoration(
                hintText: '브랜드·모델·지역 검색',
                hintStyle: _ts(13, FontWeight.w400, _mt3),
                prefixIcon: const Icon(Icons.search, color: _mt3, size: 18),
                filled: true, fillColor: _mcard,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: _mborder)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: _mborder)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: _maccent.withOpacity(0.5))),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const _MotoListingRegisterScreen()))
                .then((_) => setState(() {})),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: _mred,
                  borderRadius: BorderRadius.circular(24)),
              child: Row(children: [
                const Icon(Icons.add, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text('매물 등록', style: _ts(12, FontWeight.w700, Colors.white)),
              ]),
            ),
          ),
        ]),
      ),

      // 리스트
      Expanded(
        child: items.isEmpty
            ? Center(child: Text('등록된 매물이 없습니다', style: _ts(14, FontWeight.w500, _mt3)))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: items.length,
                itemBuilder: (_, i) => _MotoListingCard(
                  listing: items[i],
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => _MotoListingDetailScreen(listing: items[i])))
                      .then((_) => setState(() {})),
                ),
              ),
      ),
    ]);
  }
}

// ── 매물 카드 ────────────────────────────────────────────────
// ── 사진 슬라이더 (최대 10장) ────────────────────────────────
class _PhotoSlider extends StatefulWidget {
  final List<String> photos;
  const _PhotoSlider({required this.photos});
  @override
  State<_PhotoSlider> createState() => _PhotoSliderState();
}
class _PhotoSliderState extends State<_PhotoSlider> {
  int _idx = 0;
  @override
  Widget build(BuildContext context) {
    final photos = widget.photos.isNotEmpty
        ? widget.photos
        : ['https://images.unsplash.com/photo-1568772585407-9361f9bf3a87?w=600&q=80'];
    return SizedBox(
      height: 240,
      child: Stack(children: [
        PageView.builder(
          itemCount: photos.length,
          onPageChanged: (i) => setState(() => _idx = i),
          itemBuilder: (_, i) => Image.network(photos[i],
              fit: BoxFit.cover, width: double.infinity,
              errorBuilder: (_, __, ___) => Container(color: _mcard2,
                  child: const Icon(Icons.two_wheeler_rounded, color: _mt3, size: 60))),
        ),
        Positioned(bottom: 12, right: 16, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: Colors.black54,
              borderRadius: BorderRadius.circular(12)),
          child: Text('${_idx + 1} / ${photos.length}',
              style: _ts(11, FontWeight.w600, Colors.white)),
        )),
      ]),
    );
  }
}

class _MotoListingCard extends StatelessWidget {
  final MotoListing listing;
  final VoidCallback onTap;
  const _MotoListingCard({required this.listing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = listing;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: _mcard, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _mborder)),
        child: Row(children: [
          Stack(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: l.photoUrls.isNotEmpty
                  ? Image.network(l.photoUrls[0], width: 90, height: 72, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(width: 90, height: 72, color: _mcard2))
                  : Container(width: 90, height: 72, color: _mcard2,
                      child: const Icon(Icons.motorcycle_rounded, color: _mt3, size: 32)),
            ),
            if (l.photoUrls.length > 1)
              Positioned(bottom: 4, right: 4, child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4)),
                child: Text('+${l.photoUrls.length - 1}',
                    style: _ts(9, FontWeight.w600, Colors.white)),
              )),
          ]),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text('${l.manufacturer} ${l.model}',
                  style: _ts(14, FontWeight.w700, _mt1), overflow: TextOverflow.ellipsis)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: l.status.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: l.status.color.withOpacity(0.5))),
                child: Text(l.status.label, style: _ts(10, FontWeight.w700, l.status.color)),
              ),
            ]),
            const SizedBox(height: 3),
            Text('${l.displacement}cc · ${l.year} · ${_fmt(l.mileage)}km',
                style: _ts(12, FontWeight.w400, _mt2)),
            const SizedBox(height: 3),
            // 신뢰 배지
            Wrap(spacing: 4, runSpacing: 3, children: [
              if (!l.accidentFlag) _badge('무사고', _mgreen),
              if (l.inspectionStatus == '정상') _badge('검사정상', _maccent),
              if (!l.tuningFlag) _badge('순정', _mt2),
              if (l.isClubRecommended) _badge('동호회추천', _morange),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              Text('${_priceStr(l.price)}만원',
                  style: _ts(15, FontWeight.w800, _mred)),
              const Spacer(),
              const Icon(Icons.location_on_outlined, color: _mt3, size: 12),
              Text(l.region, style: _ts(11, FontWeight.w400, _mt3)),
            ]),
          ])),
        ]),
      ),
    );
  }
}

String _fmt(int n) {
  if (n >= 10000) return '${(n / 10000).toStringAsFixed(1)}만';
  return n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
}

String _priceStr(int p) =>
    p.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');

// ── 매물 상세 화면 ────────────────────────────────────────────
class _MotoListingDetailScreen extends StatefulWidget {
  final MotoListing listing;
  const _MotoListingDetailScreen({required this.listing});
  @override
  State<_MotoListingDetailScreen> createState() => _MotoListingDetailScreenState();
}

class _MotoListingDetailScreenState extends State<_MotoListingDetailScreen> {
  bool _liked = false;
  bool _isWishlisted = false;
  final _commentCtrl = TextEditingController();
  final List<String> _comments = [];

  @override
  void initState() {
    super.initState();
    // 조회수 증가
    MotoState().incrementListingView(widget.listing.listingId);
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.listing;
    // 전화번호: phoneable 상태에서만 노출
    final canCall = l.status == MotoListingStatus.phoneable;

    return Scaffold(
      backgroundColor: _mbg,
      appBar: AppBar(
        backgroundColor: _mcard,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _mt1, size: 20)),
        title: Text('${l.manufacturer} ${l.model}', style: _ts(15, FontWeight.w800, _mt1)),
        actions: [
          IconButton(
            icon: Icon(_isWishlisted ? Icons.bookmark : Icons.bookmark_border,
                color: _morange, size: 22),
            onPressed: () => setState(() => _isWishlisted = !_isWishlisted),
          ),
        ],
      ),
      body: Column(children: [
        Expanded(child: ListView(children: [
          // ── 사진 슬라이더 (최대 10장) ──
          _PhotoSlider(photos: l.photoUrls),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // 상태 배지 + 가격
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: l.status.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: l.status.color.withOpacity(0.5))),
                  child: Text(l.status.label, style: _ts(11, FontWeight.w700, l.status.color)),
                ),
                const Spacer(),
                Text('${_fmtPrice(l.price)}만원', style: _ts(22, FontWeight.w900, _mred)),
              ]),
              const SizedBox(height: 8),
              Text('${l.manufacturer} ${l.model}', style: _ts(20, FontWeight.w900, _mt1)),
              const SizedBox(height: 4),
              Text('${l.displacement}cc · ${l.year} · ${_fmtMileage(l.mileage)}km · ${l.color}',
                  style: _ts(13, FontWeight.w400, _mt2)),

              // ── 신뢰 정보 ──
              const SizedBox(height: 16),
              Text('신뢰 정보', style: _ts(14, FontWeight.w700, _mt1)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _mcard, borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _mborder)),
                child: Column(children: [
                  _trustRow('사고 이력', l.accidentFlag
                      ? '사고 있음 · ${l.accidentDetail}'
                      : '✅ 무사고', l.accidentFlag ? _mred : _mgreen),
                  _trustRow('검사 상태', l.inspectionStatus == '정상'
                      ? '✅ 정상' : '❌ ${l.inspectionStatus}',
                      l.inspectionStatus == '정상' ? _mgreen : _mred),
                  _trustRow('튜닝 여부', l.tuningFlag
                      ? '⚙️ ${l.tuningDetail}' : '✅ 순정',
                      l.tuningFlag ? _morange : _mgreen),
                  _trustRow('서류 상태', l.documentStatus,
                      l.documentStatus == '완비' ? _mgreen : _morange),
                  if (l.isClubRecommended)
                    _trustRow('동호회 추천', '✅ 추천', _maccent),
                  if (l.isShopChecked)
                    _trustRow('점포 점검', '✅ 완료', _maccent),
                  if (l.recentMaintenance.isNotEmpty)
                    _trustRow('최근 정비', l.recentMaintenance, _maccent),
                ]),
              ),

              // ── 소모품 상태 ──
              const SizedBox(height: 14),
              Text('소모품 상태', style: _ts(14, FontWeight.w700, _mt1)),
              const SizedBox(height: 8),
              Row(children: [
                _condChip('타이어', l.tireCondition),
                const SizedBox(width: 6),
                _condChip('브레이크', l.brakeCondition),
                const SizedBox(width: 6),
                _condChip('배터리', l.batteryCondition),
              ]),
              if (l.recentParts.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.build_circle_outlined, color: _maccent, size: 14),
                  const SizedBox(width: 6),
                  Expanded(child: Text('최근 교체: ${l.recentParts}',
                      style: _ts(12, FontWeight.w400, _mt2))),
                ]),
              ],

              // ── 거래 흐름 ──
              const SizedBox(height: 14),
              Text('거래 흐름', style: _ts(14, FontWeight.w700, _mt1)),
              const SizedBox(height: 8),
              _tradingFlow(l.status),

              // ── 판매자 설명 ──
              const SizedBox(height: 14),
              Text('판매자 설명', style: _ts(14, FontWeight.w700, _mt1)),
              const SizedBox(height: 6),
              Text(l.desc, style: _ts(13, FontWeight.w400, _mt1).copyWith(height: 1.6)),
              const SizedBox(height: 4),
              Text('${l.region} · ${_timeAgo(l.createdAt)}',
                  style: _ts(11, FontWeight.w400, _mt3)),

              // ── 댓글 영역 ──
              const SizedBox(height: 16),
              Text('댓글 ${_comments.length + l.inquiryCount}',
                  style: _ts(14, FontWeight.w700, _mt1)),
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
                      Text('구매 문의자 ${i + 1}', style: _ts(11, FontWeight.w700, _mt1)),
                      Text('차량 상태 문의드립니다. 직거래 가능할까요?',
                          style: _ts(11, FontWeight.w400, _mt2)),
                    ])),
                  ]),
                )),
              ..._comments.map((c) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _mcard, borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _mborder)),
                child: Text(c, style: _ts(12, FontWeight.w400, _mt1)),
              )),
              const SizedBox(height: 16),
            ]),
          ),
        ])),

        // ── 하단 고정 버튼 ──
        Container(
          color: _mcard,
          padding: EdgeInsets.only(
            left: 12, right: 12, top: 10,
            bottom: MediaQuery.of(context).viewInsets.bottom + 14),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // 아이콘 버튼 행: 찜 · 비교 · 좋아요
            Row(children: [
              // 찜 버튼
              GestureDetector(
                onTap: () => setState(() => _isWishlisted = !_isWishlisted),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: _isWishlisted ? _morange.withOpacity(0.2) : _mcard2,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _isWishlisted ? _morange.withOpacity(0.5) : _mborder)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(_isWishlisted ? Icons.bookmark : Icons.bookmark_border,
                        color: _isWishlisted ? _morange : _mt3, size: 16),
                    const SizedBox(width: 4),
                    Text('찜', style: _ts(11, FontWeight.w600,
                        _isWishlisted ? _morange : _mt2)),
                  ]),
                ),
              ),
              const SizedBox(width: 8),
              // 비교 버튼
              GestureDetector(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: const Text('비교함에 추가되었습니다.'),
                        backgroundColor: _mcard2,
                        duration: const Duration(seconds: 1))),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: _mcard2,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _mborder)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.compare_arrows_rounded, color: _mt3, size: 16),
                    const SizedBox(width: 4),
                    Text('비교', style: _ts(11, FontWeight.w600, _mt2)),
                  ]),
                ),
              ),
              const SizedBox(width: 8),
              // 좋아요
              GestureDetector(
                onTap: () => setState(() {
                  _liked = !_liked;
                  if (_liked) l.likeCount++;
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: _liked ? _mred.withOpacity(0.2) : _mcard2,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _liked ? _mred.withOpacity(0.5) : _mborder)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.favorite_rounded,
                        color: _liked ? _mred : _mt3, size: 16),
                    const SizedBox(width: 4),
                    Text('${l.likeCount}', style: _ts(11, FontWeight.w600,
                        _liked ? _mred : _mt2)),
                  ]),
                ),
              ),
              const Spacer(),
              Text('${l.region} · ${_timeAgo(l.createdAt)}',
                  style: _ts(10, FontWeight.w400, _mt3)),
            ]),
            const SizedBox(height: 8),
            // 댓글 입력행
            Row(children: [
              Expanded(child: TextField(
                controller: _commentCtrl,
                style: _ts(13, FontWeight.w400, _mt1),
                decoration: InputDecoration(
                  hintText: '댓글을 입력하세요...',
                  hintStyle: _ts(13, FontWeight.w400, _mt3),
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
                  decoration: const BoxDecoration(color: _mred, shape: BoxShape.circle),
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 18)),
              ),
            ]),
            const SizedBox(height: 8),
            // 주요 버튼 행: 1:1문의 + 협의 후 전화
            Row(children: [
              Expanded(child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/chat',
                    arguments: {'storeName': '${l.manufacturer} ${l.model} 판매자', 'storeId': 0}),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _maccent.withOpacity(0.8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                icon: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 16),
                label: Text('1:1 문의', style: _ts(14, FontWeight.w700, Colors.white)),
              )),
              const SizedBox(width: 8),
              // 협의 후 전화 (phoneable 상태에서만 번호 노출)
              Expanded(child: ElevatedButton.icon(
                onPressed: canCall ? () async {
                  final phone = l.contactPreference.contains('010')
                      ? l.contactPreference : '010-0000-0000';
                  final uri = Uri.parse('tel:$phone');
                  if (await canLaunchUrl(uri)) launchUrl(uri);
                } : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('1:1 문의 → 협의 완료 후 전화가 가능합니다.'),
                      backgroundColor: _mt3,
                      duration: const Duration(seconds: 2),
                    ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: canCall ? _mgreen : _mcard2,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                icon: Icon(canCall ? Icons.phone_rounded : Icons.phone_locked_rounded,
                    color: canCall ? Colors.white : _mt3, size: 16),
                label: Text(canCall ? '협의 후 전화' : '전화(잠김)',
                    style: _ts(14, FontWeight.w700, canCall ? Colors.white : _mt3)),
              )),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _tradingFlow(MotoListingStatus status) {
    final steps = ['게시중', '문의도착', '협의중', '전화가능', '판매완료'];
    final currentIdx = steps.indexOf(status.label);
    return Row(
      children: steps.asMap().entries.map((e) {
        final i = e.key;
        final step = e.value;
        final isActive = i <= (currentIdx < 0 ? 0 : currentIdx);
        return Expanded(child: Row(children: [
          Expanded(child: Column(children: [
            Container(
              width: 26, height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? _mred : _mcard2,
                border: Border.all(color: isActive ? _mred : _mborder)),
              child: Center(child: Text('${i + 1}',
                  style: _ts(10, FontWeight.w700, isActive ? Colors.white : _mt3))),
            ),
            const SizedBox(height: 3),
            Text(step, style: _ts(9, FontWeight.w500, isActive ? _mt1 : _mt3),
                textAlign: TextAlign.center),
          ])),
          if (i < steps.length - 1)
            Container(width: 14, height: 1,
                color: isActive && i < currentIdx ? _mred : _mborder),
        ]));
      }).toList(),
    );
  }

  Widget _trustRow(String label, String value, Color color) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      SizedBox(width: 70, child: Text(label, style: _ts(11, FontWeight.w600, _mt3))),
      Container(width: 1, height: 12, color: _mborder,
          margin: const EdgeInsets.symmetric(horizontal: 8)),
      Expanded(child: Text(value, style: _ts(12, FontWeight.w600, color))),
    ]),
  );

  Widget _condChip(String label, String cond) {
    final color = cond == '최상' ? _mgreen : cond == '양호' ? _maccent : _morange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.4))),
      child: Column(children: [
        Text(label, style: _ts(10, FontWeight.w500, _mt3)),
        Text(cond, style: _ts(11, FontWeight.w700, color)),
      ]),
    );
  }
}
// ── 매물 등록 화면 ────────────────────────────────────────────
class _MotoListingRegisterScreen extends StatefulWidget {
  const _MotoListingRegisterScreen();
  @override
  State<_MotoListingRegisterScreen> createState() => _MotoListingRegisterScreenState();
}

class _MotoListingRegisterScreenState extends State<_MotoListingRegisterScreen> {
  // 다이얼로그 선택형 필드
  String _mfr   = '';
  String _model = '';
  String _cc    = '';
  String _year  = '';

  // 직접 입력 필드
  final _miCtrl       = TextEditingController();
  final _priceCtrl    = TextEditingController();
  final _regionCtrl   = TextEditingController();
  final _descCtrl     = TextEditingController();
  final _colorCtrl    = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  final _acDetailCtrl = TextEditingController();
  final _tuDetailCtrl = TextEditingController();
  final _partsCtrl    = TextEditingController();

  // 사진
  List<String> _photos = [];   // 로컬 파일 경로

  bool _accident = false;
  bool _tuning   = false;
  bool _original = true;
  String _inspect = '정상';
  String _doc     = '완비';
  String _contact = '채팅 우선';
  String _tire    = '양호';
  String _brake   = '양호';
  String _battery = '양호';

  // 제조사 → 모델 매핑
  static const _brands = <String, List<String>>{
    '혼다':    ['CB500F', 'CB500X', 'CBR650R', 'PCX125', 'Forza350', '베나'],
    '야마하':  ['MT-07', 'MT-09', 'YZF-R3', 'XMAX300', 'NMAX125', 'Tenere700'],
    '가와사키':['Z650', 'Z900', 'Ninja400', 'Ninja650', 'Versys650', 'Z50'],
    '스즈키':  ['GSX-S750', 'V-Strom650', 'Hayabusa', 'Burgman400'],
    'BMW':    ['F850GS', 'R1250GS', 'S1000RR', 'G310R', 'C400X'],
    '할리데이비슨':['Sportster S', 'Street Glide', 'Fat Bob', 'Low Rider ST'],
    '두카티':  ['Monster', 'Panigale V4', 'Scrambler', 'Multistrada V4'],
    'KTM':   ['Duke390', 'Duke790', 'Adventure390', 'RC390'],
    '국내/기타':['대림 시티100', 'SYM 클래식', '스캇 전기', '기타'],
  };

  static const _ccList  = ['49cc 이하', '50cc', '100cc', '125cc', '150cc',
                            '250cc', '300cc', '400cc', '500cc', '650cc',
                            '750cc', '900cc', '1000cc 이상'];
  static const _yearList = ['2024', '2023', '2022', '2021', '2020',
                             '2019', '2018', '2017', '2016', '2015', '2015 이전'];

  Future<void> _selectBrand() async {
    final v = await showDialog<String>(
      context: context,
      builder: (_) => _PickerDialog(title: '제조사 선택',
          items: _brands.keys.toList()),
    );
    if (v != null) { setState(() { _mfr = v; _model = ''; }); }
  }

  Future<void> _selectModel() async {
    if (_mfr.isEmpty) { _selectBrand(); return; }
    final v = await showDialog<String>(
      context: context,
      builder: (_) => _PickerDialog(title: '모델 선택 ($_mfr)',
          items: _brands[_mfr]!),
    );
    if (v != null) setState(() => _model = v);
  }

  Future<void> _selectCc() async {
    final v = await showDialog<String>(
      context: context,
      builder: (_) => _PickerDialog(title: '배기량 선택', items: _ccList),
    );
    if (v != null) setState(() => _cc = v);
  }

  Future<void> _selectYear() async {
    final v = await showDialog<String>(
      context: context,
      builder: (_) => _PickerDialog(title: '연식 선택', items: _yearList),
    );
    if (v != null) setState(() => _year = v);
  }

  Future<void> _addPhotos() async {
    if (_photos.length >= 10) return;
    final picked = await _pickImages(context, max: 10 - _photos.length);
    if (picked.isNotEmpty) {
      setState(() => _photos.addAll(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _mbg,
      appBar: AppBar(
        backgroundColor: _mcard,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _mt1, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('매물 등록', style: _ts(16, FontWeight.w700, _mt1)),
        actions: [
          TextButton(
            onPressed: _submit,
            child: Text('등록', style: _ts(14, FontWeight.w700, _mred)),
          ),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // ── 사진 첨부 영역 ──
        GestureDetector(
          onTap: _addPhotos,
          child: Container(
            height: _photos.isEmpty ? 80 : null,
            decoration: BoxDecoration(color: _mcard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _photos.isEmpty ? _mborder : _maccent.withOpacity(0.5))),
            child: _photos.isEmpty
                ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.add_photo_alternate_outlined, color: _maccent, size: 28),
                    const SizedBox(width: 10),
                    Column(mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('사진 추가 (최대 10장)', style: _ts(13, FontWeight.w600, _mt1)),
                      Text('첫 사진이 대표 이미지  |  카메라 / 앨범', style: _ts(11, FontWeight.w400, _mt3)),
                    ]),
                  ])
                : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    SizedBox(
                      height: 110,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.all(8),
                        itemCount: _photos.length + 1,
                        itemBuilder: (_, i) {
                          if (i == _photos.length) {
                            return _photos.length < 10
                                ? GestureDetector(
                                    onTap: _addPhotos,
                                    child: Container(
                                      width: 90, height: 90,
                                      margin: const EdgeInsets.only(right: 6),
                                      decoration: BoxDecoration(color: _mcard2,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: _mborder)),
                                      child: const Column(mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                        Icon(Icons.add_rounded, color: _maccent, size: 24),
                                        Text('추가', style: TextStyle(fontSize: 11, color: _maccent)),
                                      ]),
                                    ),
                                  )
                                : const SizedBox.shrink();
                          }
                          return Stack(children: [
                            Container(
                              width: 90, height: 90,
                              margin: const EdgeInsets.only(right: 6),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(File(_photos[i]), fit: BoxFit.cover),
                              ),
                            ),
                            if (i == 0)
                              Positioned(bottom: 0, left: 0, right: 6,
                                  child: Container(
                                    height: 18,
                                    decoration: BoxDecoration(
                                        color: _mred.withOpacity(0.85),
                                        borderRadius: const BorderRadius.vertical(
                                            bottom: Radius.circular(8))),
                                    child: const Center(child: Text('대표',
                                        style: TextStyle(fontSize: 10,
                                            color: Colors.white, fontWeight: FontWeight.w700))),
                                  )),
                            Positioned(top: 2, right: 8,
                                child: GestureDetector(
                                  onTap: () => setState(() => _photos.removeAt(i)),
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.7),
                                        shape: BoxShape.circle),
                                    child: const Icon(Icons.close, color: Colors.white, size: 12),
                                  ),
                                )),
                          ]);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                      child: Text('${_photos.length}/10장',
                          style: _ts(11, FontWeight.w400, _mt3)),
                    ),
                  ]),
          ),
        ),
        const SizedBox(height: 16),
        // ── 제조사 (다이얼로그 선택) ──
        _selectTile('제조사 *', _mfr.isEmpty ? '선택하세요' : _mfr,
            _mfr.isEmpty, _selectBrand),
        // ── 모델 (다이얼로그 선택) ──
        _selectTile('모델 *', _model.isEmpty ? '제조사 먼저 선택하세요' : _model,
            _model.isEmpty, _selectModel),
        // ── 배기량 (다이얼로그 선택) ──
        _selectTile('배기량', _cc.isEmpty ? '선택하세요' : _cc,
            _cc.isEmpty, _selectCc),
        // ── 연식 (다이얼로그 선택) ──
        _selectTile('연식', _year.isEmpty ? '선택하세요' : _year,
            _year.isEmpty, _selectYear),
        _inputField('주행거리(km)', _miCtrl, '12000', type: TextInputType.number),
        _inputField('가격(만원) *', _priceCtrl, '650', type: TextInputType.number),
        _inputField('지역', _regionCtrl, '대구 수성구'),
        _inputField('색상', _colorCtrl, '블랙, 화이트, 레드...'),
        _inputField('희망 연락처', _phoneCtrl, '010-0000-0000', type: TextInputType.phone),
        const SizedBox(height: 8),
        // 사고·튜닝·순정 토글
        _toggleRow('사고 이력 있음', _accident, (v) => setState(() => _accident = v)),
        if (_accident) _inputField('사고 부위/내용', _acDetailCtrl, '좌측 카울 긁힘...'),
        _toggleRow('튜닝 여부', _tuning, (v) => setState(() => _tuning = v)),
        if (_tuning) _inputField('튜닝 상세', _tuDetailCtrl, '머플러 교체, 핸들바...'),
        _toggleRow('순정 상태', _original, (v) => setState(() => _original = v)),
        _inputField('최근 교체 부품', _partsCtrl, '타이어 전후, 체인...'),
        const SizedBox(height: 12),
        // 소모품 상태
        Text('소모품 상태', style: _ts(12, FontWeight.w600, _mt2)),
        const SizedBox(height: 6),
        _condSelectRow('타이어', _tire, (v) => setState(() => _tire = v)),
        const SizedBox(height: 6),
        _condSelectRow('브레이크', _brake, (v) => setState(() => _brake = v)),
        const SizedBox(height: 6),
        _condSelectRow('배터리', _battery, (v) => setState(() => _battery = v)),
        const SizedBox(height: 12),
        // 검사 상태
        Text('검사 상태', style: _ts(12, FontWeight.w600, _mt2)),
        const SizedBox(height: 6),
        Row(children: ['정상', '불합격', '미검사'].map((s) => GestureDetector(
          onTap: () => setState(() => _inspect = s),
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: _inspect == s ? _maccent.withOpacity(0.2) : _mcard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _inspect == s ? _maccent : _mborder)),
            child: Text(s, style: _ts(12, FontWeight.w600,
                _inspect == s ? _maccent : _mt2)),
          ),
        )).toList()),
        const SizedBox(height: 10),
        // 서류 상태
        Text('서류 상태', style: _ts(12, FontWeight.w600, _mt2)),
        const SizedBox(height: 6),
        Row(children: ['완비', '일부누락'].map((s) => GestureDetector(
          onTap: () => setState(() => _doc = s),
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: _doc == s ? _mgreen.withOpacity(0.2) : _mcard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _doc == s ? _mgreen : _mborder)),
            child: Text(s, style: _ts(12, FontWeight.w600,
                _doc == s ? _mgreen : _mt2)),
          ),
        )).toList()),
        const SizedBox(height: 10),
        // 연락 방식
        Text('희망 연락 방식', style: _ts(12, FontWeight.w600, _mt2)),
        const SizedBox(height: 6),
        Row(children: ['채팅 우선', '전화 우선', '협의 후 전화'].map((s) => GestureDetector(
          onTap: () => setState(() => _contact = s),
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _contact == s ? _morange.withOpacity(0.2) : _mcard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _contact == s ? _morange : _mborder)),
            child: Text(s, style: _ts(11, FontWeight.w600,
                _contact == s ? _morange : _mt2)),
          ),
        )).toList()),
        const SizedBox(height: 10),
        // 설명
        TextField(
          controller: _descCtrl,
          maxLines: 5,
          style: _ts(13, FontWeight.w400, _mt1),
          decoration: InputDecoration(
            hintText: '자세한 설명을 입력하세요...',
            hintStyle: _ts(13, FontWeight.w400, _mt3),
            filled: true, fillColor: _mcard,
            contentPadding: const EdgeInsets.all(14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: _mborder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: _mborder)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: _maccent.withOpacity(0.5))),
          ),
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: _submit,
          child: Container(
            height: 50,
            decoration: BoxDecoration(color: _mred, borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text('매물 등록하기', style: _ts(15, FontWeight.w700, Colors.white))),
          ),
        ),
        const SizedBox(height: 20),
      ]),
    );
  }

  void _submit() {
    if (_mfr.isEmpty || _model.isEmpty || _priceCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('제조사·모델·가격은 필수 항목입니다.'),
              backgroundColor: _mred));
      return;
    }
    final listing = MotoListing(
      listingId: 'ML-\${DateTime.now().millisecondsSinceEpoch}',
      manufacturer: _mfr, model: _model,
      displacement: int.tryParse(_cc.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
      year: _year, mileage: int.tryParse(_miCtrl.text) ?? 0,
      price: int.tryParse(_priceCtrl.text) ?? 0,
      region: _regionCtrl.text, desc: _descCtrl.text,
      accidentFlag: _accident, accidentDetail: _acDetailCtrl.text,
      tuningFlag: _tuning, tuningDetail: _tuDetailCtrl.text,
      isOriginal: _original, recentParts: _partsCtrl.text,
      inspectionStatus: _inspect, documentStatus: _doc,
      contactPreference: _phoneCtrl.text.isNotEmpty ? _phoneCtrl.text : _contact,
      color: _colorCtrl.text.isNotEmpty ? _colorCtrl.text : '미지정',
      tireCondition: _tire, brakeCondition: _brake, batteryCondition: _battery,
      photoUrls: _photos,
      isMyListing: true, ownerId: 'me',
      createdAt: DateTime.now(),
    );
    MotoState().addListing(listing);
    _showDone(context, '매물이 등록되었습니다!\n내 매물 목록에서 확인할 수 있습니다.', then: () {
      Navigator.pop(context);
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => _MotoListingDetailScreen(listing: listing)));
    });
  }

  // ── 다이얼로그 선택 타일 ──
  Widget _selectTile(String label, String value, bool isEmpty, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: _mcard, borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isEmpty ? _mborder : _maccent.withOpacity(0.5)),
          ),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: _ts(11, FontWeight.w500, _mt3)),
              const SizedBox(height: 2),
              Text(value, style: _ts(13, FontWeight.w600,
                  isEmpty ? _mt3 : _mt1)),
            ])),
            Icon(Icons.arrow_drop_down_rounded,
                color: isEmpty ? _mt3 : _maccent, size: 22),
          ]),
        ),
      );

  Widget _inputField(String label, TextEditingController ctrl, String hint,
      {TextInputType type = TextInputType.text}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextField(
          controller: ctrl,
          keyboardType: type,
          style: _ts(13, FontWeight.w400, _mt1),
          decoration: InputDecoration(
            labelText: label, labelStyle: _ts(12, FontWeight.w500, _mt3),
            hintText: hint, hintStyle: _ts(12, FontWeight.w400, _mt3.withOpacity(0.5)),
            filled: true, fillColor: _mcard,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: _mborder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: _mborder)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: _maccent.withOpacity(0.5))),
          ),
        ),
      );

  Widget _toggleRow(String label, bool value, void Function(bool) onChanged) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Text(label, style: _ts(13, FontWeight.w500, _mt2)),
          const Spacer(),
          Switch(value: value, onChanged: onChanged,
              activeColor: _mred, inactiveTrackColor: _mborder),
        ]),
      );

  Widget _condSelectRow(String label, String current, void Function(String) onChange) {
    const opts = ['최상', '양호', '불량'];
    return Row(children: [
      SizedBox(width: 60, child: Text(label, style: _ts(12, FontWeight.w500, _mt2))),
      ...opts.map((o) {
        final c = o == '최상' ? _mgreen : o == '양호' ? _maccent : _mred;
        return GestureDetector(
          onTap: () => onChange(o),
          child: Container(
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: current == o ? c.withOpacity(0.2) : _mcard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: current == o ? c.withOpacity(0.6) : _mborder)),
            child: Text(o, style: _ts(11, FontWeight.w600, current == o ? c : _mt3)),
          ),
        );
      }),
    ]);
  }
}
// ══════════════════════════════════════════════════════════════
// 탭 3: 동호회
// ══════════════════════════════════════════════════════════════
class _MotoClubTab extends StatefulWidget {
  const _MotoClubTab();
  @override
  State<_MotoClubTab> createState() => _MotoClubTabState();
}

class _MotoClubTabState extends State<_MotoClubTab> {
  MotoCommunityType? _filter;
  String _keyword = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  List<MotoClub> get _clubs {
    var list = List<MotoClub>.from(MotoState().clubs);
    if (_filter != null) list = list.where((c) => c.category == _filter).toList();
    if (_keyword.isNotEmpty) {
      list = list.where((c) => c.name.contains(_keyword) || c.region.contains(_keyword)).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final state = MotoState();
    // 최신글 (모든 동호회에서 수집)
    final latestPosts = state.clubs.expand((c) => c.posts.map((p) => (club: c, post: p))).toList()
      ..sort((a, b) => b.post.createdAt.compareTo(a.post.createdAt));

    return Column(children: [
      // 검색창
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              style: _ts(13, FontWeight.w400, _mt1),
              onChanged: (v) => setState(() => _keyword = v),
              decoration: InputDecoration(
                hintText: '동호회 검색 (이름·지역)',
                hintStyle: _ts(13, FontWeight.w400, _mt3),
                prefixIcon: const Icon(Icons.search, color: _mt3, size: 18),
                filled: true, fillColor: _mcard,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: _mborder)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: _mborder)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: _maccent.withOpacity(0.5))),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const _MotoClubCreateScreen()))
                .then((_) => setState(() {})),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: _mgreen,
                  borderRadius: BorderRadius.circular(24)),
              child: Row(children: [
                const Icon(Icons.add, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text('방 개설', style: _ts(12, FontWeight.w700, Colors.white)),
              ]),
            ),
          ),
        ]),
      ),

      // 필터
      SizedBox(
        height: 36,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          children: [
            _filterChip('전체', _filter == null, () => setState(() => _filter = null)),
            ...MotoCommunityType.values.map((t) =>
              _filterChip(t.label, _filter == t, () => setState(() => _filter = t))),
          ],
        ),
      ),
      const SizedBox(height: 6),

      // 최신글 미리보기 (가로 스크롤)
      if (latestPosts.isNotEmpty) ...[
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
          child: Text('최신 동호회 소식', style: _ts(13, FontWeight.w700, _mt1)),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: latestPosts.take(5).length,
            itemBuilder: (_, i) {
              final item = latestPosts[i];
              final p = item.post;
              final c = item.club;
              return GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => _MotoClubDetailScreen(club: c)))
                    .then((_) => setState(() {})),
                child: Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: _mcard,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _mborder)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      _badge(c.category.label, _mgreen),
                      const SizedBox(width: 4),
                      Expanded(child: Text(c.name, style: _ts(11, FontWeight.w600, _mt3),
                          overflow: TextOverflow.ellipsis)),
                    ]),
                    const SizedBox(height: 5),
                    Text(p.content, style: _ts(12, FontWeight.w400, _mt2),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(children: [
                      Text(_timeAgo(p.createdAt), style: _ts(10, FontWeight.w400, _mt3)),
                      const Spacer(),
                      const Text('💬 ', style: TextStyle(fontSize: 10)),
                      Text('${p.comments.length}', style: _ts(10, FontWeight.w400, _mt3)),
                    ]),
                  ]),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 4),
      ],

      // 동호회 목록
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: _clubs.length,
          itemBuilder: (_, i) => _MotoClubCard(
            club: _clubs[i],
            onTap: () => Navigator.push(context,
                MaterialPageRoute(
                    builder: (_) => _MotoClubDetailScreen(club: _clubs[i])))
                .then((_) => setState(() {})),
            onJoin: () {
              final club = _clubs[i];
              MotoState().joinClub(club.clubId);
              setState(() {});
              _showDone(context,
                '${club.name} 동호회에 가입했습니다!\n멤버들에게 인사를 건네보세요.',
                then: () {
                  Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => _MotoClubDetailScreen(club: club)))
                      .then((_) => setState(() {}));
                });
            },
          ),
        ),
      ),
    ]);
  }

  Widget _filterChip(String label, bool selected, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(right: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? _mgreen : _mcard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? _mgreen : _mborder),
          ),
          child: Text(label,
              style: _ts(12, FontWeight.w600, selected ? Colors.white : _mt2)),
        ),
      );
}

// ── 동호회 카드 ───────────────────────────────────────────────
class _MotoClubCard extends StatelessWidget {
  final MotoClub club;
  final VoidCallback onTap;
  final VoidCallback onJoin;
  const _MotoClubCard({required this.club, required this.onTap, required this.onJoin});

  @override
  Widget build(BuildContext context) {
    final c = club;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(color: _mcard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _mborder)),
        child: Column(children: [
          // 커버 이미지
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(c.coverImageUrl, height: 90,
                width: double.infinity, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(height: 90, color: _mcard2)),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                _badge(c.category.label, _mgreen),
                const SizedBox(width: 6),
                _badge(c.joinType.label, _maccent),
                const SizedBox(width: 6),
                if (!c.isPublic) _badge('비공개', _mt3),
                const Spacer(),
                Row(children: [
                  const Icon(Icons.people_rounded, color: _mt3, size: 13),
                  Text(' ${c.memberCount}명',
                      style: _ts(11, FontWeight.w500, _mt3)),
                ]),
              ]),
              const SizedBox(height: 6),
              Text(c.name, style: _ts(15, FontWeight.w700, _mt1)),
              const SizedBox(height: 3),
              Text(c.description, style: _ts(12, FontWeight.w400, _mt2),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.location_on_outlined, color: _mt3, size: 12),
                Text(' ${c.region}', style: _ts(11, FontWeight.w400, _mt3)),
                const Spacer(),
                // 가입 버튼
                GestureDetector(
                  onTap: c.myJoined ? null : (c.myPendingApproval ? null : onJoin),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: c.myJoined
                          ? _mgreen.withOpacity(0.15)
                          : c.myPendingApproval
                              ? _morange.withOpacity(0.15)
                              : _mgreen,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: c.myJoined
                              ? _mgreen.withOpacity(0.5)
                              : c.myPendingApproval
                                  ? _morange.withOpacity(0.5)
                                  : _mgreen),
                    ),
                    child: Text(
                      c.myJoined ? '가입됨' : c.myPendingApproval ? '승인대기' : '가입하기',
                      style: _ts(11, FontWeight.w700,
                          c.myJoined
                              ? _mgreen
                              : c.myPendingApproval
                                  ? _morange
                                  : Colors.white),
                    ),
                  ),
                ),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ── 동호회 상세 ───────────────────────────────────────────────
class _MotoClubDetailScreen extends StatefulWidget {
  final MotoClub club;
  const _MotoClubDetailScreen({required this.club});
  @override
  State<_MotoClubDetailScreen> createState() => _MotoClubDetailScreenState();
}

class _MotoClubDetailScreenState extends State<_MotoClubDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 5, vsync: this);
  }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c = widget.club;
    return Scaffold(
      backgroundColor: _mbg,
      body: Column(children: [
        // 커버 + 앱바
        SizedBox(
          height: 160,
          child: Stack(fit: StackFit.expand, children: [
            Image.network(c.coverImageUrl, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: _mcard2)),
            Container(decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.3), Colors.black.withOpacity(0.8)]))),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  if (c.myJoined)
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.white, size: 22),
                      onPressed: () => _showClubMenu(context, c,
                        onChanged: () => setState(() {})),
                    ),
                ]),
              ),
            ),
            Positioned(bottom: 14, left: 16, right: 80, child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c.name, style: _ts(20, FontWeight.w800, Colors.white)),
              const SizedBox(height: 4),
              Row(children: [
                _badge(c.category.label, _mgreen),
                const SizedBox(width: 6),
                Text('${c.memberCount}명', style: _ts(12, FontWeight.w500, _mt2)),
                const SizedBox(width: 8),
                const Icon(Icons.location_on_outlined, color: _mt2, size: 12),
                Text(c.region, style: _ts(12, FontWeight.w400, _mt2)),
              ]),
            ])),
            // 가입 버튼
            Positioned(bottom: 14, right: 16, child: GestureDetector(
              onTap: c.myJoined ? null : () {
                MotoState().joinClub(c.clubId);
                setState(() {});
                _showDone(context,
                  '${c.name}에 가입했습니다!\n멤버들에게 인사를 건네보세요.', then: () {
                  setState(() {});
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: c.myJoined ? _mgreen : _mred,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(c.myJoined ? '가입됨' : '가입하기',
                    style: _ts(12, FontWeight.w700, Colors.white)),
              ),
            )),
          ]),
        ),
        // 탭바
        Container(
          color: _mcard,
          child: TabBar(
            controller: _tab,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: _mgreen,
            labelColor: _mt1,
            unselectedLabelColor: _mt3,
            labelStyle: _ts(12, FontWeight.w700, _mt1),
            unselectedLabelStyle: _ts(12, FontWeight.w500, _mt3),
            tabs: const [
              Tab(text: '게시글'),
              Tab(text: '사진'),
              Tab(text: '공지'),
              Tab(text: '일정'),
              Tab(text: '멤버'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: [
              _ClubPostsTab(club: c, onChanged: () => setState(() {})),
              _ClubPhotosTab(club: c),
              _ClubNoticesTab(club: c),
              _ClubEventsTab(club: c, onChanged: () => setState(() {})),
              _ClubMembersTab(club: c),
            ],
          ),
        ),
      ]),
      floatingActionButton: c.myJoined ? FloatingActionButton(
        backgroundColor: _mgreen,
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => _MotoPostWriteScreen(clubId: c.clubId)))
            .then((_) => setState(() {})),
        child: const Icon(Icons.edit_rounded, color: Colors.white),
      ) : null,
    );
  }
}

// ── 동호회 게시글 탭 ─────────────────────────────────────────
class _ClubPostsTab extends StatefulWidget {
  final MotoClub club;
  final VoidCallback onChanged;
  const _ClubPostsTab({required this.club, required this.onChanged});
  @override
  State<_ClubPostsTab> createState() => _ClubPostsTabState();
}
class _ClubPostsTabState extends State<_ClubPostsTab> {
  @override
  Widget build(BuildContext context) {
    final posts = widget.club.posts;
    if (posts.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.article_outlined, color: _mt3, size: 48),
        const SizedBox(height: 12),
        Text('아직 게시글이 없습니다', style: _ts(14, FontWeight.w500, _mt3)),
        if (widget.club.myJoined) ...[
          const SizedBox(height: 12),
          Text('첫 게시글을 작성해보세요!', style: _ts(13, FontWeight.w400, _mt3)),
        ],
      ]));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: posts.length,
      itemBuilder: (_, i) => _ClubPostCard(
        post: posts[i],
        clubId: widget.club.clubId,
        onReact: (idx) {
          MotoState().toggleClubPostReaction(widget.club.clubId, posts[i].postId, idx);
          setState(() {});
          widget.onChanged();
        },
        onComment: () {
          _showCommentSheet(context, posts[i].comments, (text) {
            MotoState().addClubComment(widget.club.clubId, posts[i].postId,
                MotoComment(id: 'cc-${DateTime.now().millisecondsSinceEpoch}',
                    authorName: '나', content: text, createdAt: DateTime.now()));
            setState(() {});
          });
        },
      ),
    );
  }
}

// ── 동호회 게시글 카드 ────────────────────────────────────────
class _ClubPostCard extends StatelessWidget {
  final MotoClubPost post;
  final String clubId;
  final void Function(int) onReact;
  final VoidCallback onComment;
  const _ClubPostCard({required this.post, required this.clubId,
      required this.onReact, required this.onComment});

  @override
  Widget build(BuildContext context) {
    final p = post;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: _mcard, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: p.isPinned ? _mred.withOpacity(0.4) : _mborder)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // 작성자 정보
        Row(children: [
          CircleAvatar(radius: 16, backgroundColor: _mcard2,
              child: Text(p.authorName[0], style: _ts(12, FontWeight.w700, _maccent))),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.authorName, style: _ts(13, FontWeight.w700, _mt1)),
            Text(_timeAgo(p.createdAt), style: _ts(10, FontWeight.w400, _mt3)),
          ]),
          const Spacer(),
          if (p.isPinned) _badge('공지', _mred),
          const SizedBox(width: 4),
          Row(children: [
            const Icon(Icons.visibility_outlined, color: _mt3, size: 12),
            Text(' ${p.viewCount}', style: _ts(10, FontWeight.w400, _mt3)),
          ]),
        ]),
        const SizedBox(height: 10),
        // 본문
        Text(p.content, style: _ts(13, FontWeight.w400, _mt2).copyWith(height: 1.6)),
        // 사진
        if (p.photoUrls.isNotEmpty) ...[
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: p.photoUrls.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(p.photoUrls[i], width: 100, height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                          width: 100, height: 100, color: _mcard2)),
                ),
              ),
            ),
          ),
        ],
        // 유튜브
        if (p.videoUrl != null) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final uri = Uri.parse(p.videoUrl!);
              if (await canLaunchUrl(uri)) launchUrl(uri);
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: _mcard2,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFF0000).withOpacity(0.3))),
              child: Row(children: [
                const Icon(Icons.play_circle_filled_rounded,
                    color: Color(0xFFFF0000), size: 24),
                const SizedBox(width: 8),
                Text('영상 보기', style: _ts(12, FontWeight.w600, _mt2)),
              ]),
            ),
          ),
        ],
        const SizedBox(height: 10),
        const Divider(color: _mborder, height: 1),
        const SizedBox(height: 8),
        // 이모지 반응
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _EmojiBar(reactions: p.reactions, onTap: onReact),
        ),
        const SizedBox(height: 8),
        // 댓글 버튼
        GestureDetector(
          onTap: onComment,
          child: Row(children: [
            const Icon(Icons.chat_bubble_outline_rounded, color: _mt3, size: 14),
            const SizedBox(width: 4),
            Text('댓글 ${p.comments.length}',
                style: _ts(12, FontWeight.w500, _mt3)),
          ]),
        ),
        // 댓글 미리보기
        if (p.comments.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...p.comments.take(2).map((c) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(children: [
              CircleAvatar(radius: 10, backgroundColor: _mcard2,
                  child: Text(c.authorName[0], style: _ts(8, FontWeight.w700, _maccent))),
              const SizedBox(width: 6),
              Expanded(child: RichText(text: TextSpan(children: [
                TextSpan(text: '${c.authorName} ', style: _ts(11, FontWeight.w700, _mt1)),
                TextSpan(text: c.content, style: _ts(11, FontWeight.w400, _mt2)),
              ]))),
            ]),
          )),
        ],
      ]),
    );
  }
}

// ── 동호회 사진 탭 ────────────────────────────────────────────
class _ClubPhotosTab extends StatelessWidget {
  final MotoClub club;
  const _ClubPhotosTab({required this.club});
  @override
  Widget build(BuildContext context) {
    final photos = club.posts.expand((p) => p.photoUrls).toList();
    if (photos.isEmpty) {
      return Center(child: Text('등록된 사진이 없습니다', style: _ts(14, FontWeight.w500, _mt3)));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2),
      itemCount: photos.length,
      itemBuilder: (_, i) => Image.network(photos[i], fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: _mcard2)),
    );
  }
}

// ── 동호회 공지 탭 ────────────────────────────────────────────
class _ClubNoticesTab extends StatefulWidget {
  final MotoClub club;
  const _ClubNoticesTab({required this.club});
  @override
  State<_ClubNoticesTab> createState() => _ClubNoticesTabState();
}
class _ClubNoticesTabState extends State<_ClubNoticesTab> {
  @override
  Widget build(BuildContext context) {
    final notices = widget.club.posts.where((p) => p.isPinned).toList();
    final isOwner = widget.club.members.any(
        (m) => m.userId == 'me' && m.role == MotoClubRole.owner);
    if (notices.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.campaign_outlined, color: _mt3, size: 48),
        const SizedBox(height: 12),
        Text('등록된 공지가 없습니다', style: _ts(14, FontWeight.w500, _mt3)),
        if (isOwner) ...[
          const SizedBox(height: 8),
          Text('오른쪽 상단 ⋮ 메뉴에서 공지를 발송할 수 있습니다.',
              style: _ts(12, FontWeight.w400, _mt3)),
        ],
      ]));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: notices.length,
      itemBuilder: (_, i) {
        final p = notices[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: _mcard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _mred.withOpacity(0.35))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              _badge('공지', _mred),
              const SizedBox(width: 8),
              Expanded(child: Text(_timeAgo(p.createdAt),
                  style: _ts(10, FontWeight.w400, _mt3))),
              if (isOwner)
                GestureDetector(
                  onTap: () {
                    MotoState().pinPost(widget.club.clubId, p.postId, false);
                    setState(() {});
                  },
                  child: Icon(Icons.push_pin_rounded, color: _mred, size: 18),
                ),
            ]),
            const SizedBox(height: 8),
            Text(p.content, style: _ts(13, FontWeight.w400, _mt2)),
          ]),
        );
      },
    );
  }
}

class _ClubEventsTab extends StatefulWidget {
  final MotoClub club;
  final VoidCallback onChanged;
  const _ClubEventsTab({required this.club, required this.onChanged});
  @override
  State<_ClubEventsTab> createState() => _ClubEventsTabState();
}
class _ClubEventsTabState extends State<_ClubEventsTab> {
  @override
  Widget build(BuildContext context) {
    final events = widget.club.events;
    if (events.isEmpty) {
      return Center(child: Text('등록된 일정이 없습니다', style: _ts(14, FontWeight.w500, _mt3)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: events.length,
      itemBuilder: (_, i) {
        final e = events[i];
        final dDay = e.eventDate.difference(DateTime.now()).inDays;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: _mcard, borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _mborder)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(e.title, style: _ts(14, FontWeight.w700, _mt1))),
              _badge('D-$dDay', dDay <= 3 ? _mred : _maccent),
            ]),
            const SizedBox(height: 6),
            Text(e.description, style: _ts(12, FontWeight.w400, _mt2)),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.calendar_today_rounded, color: _mt3, size: 12),
              Text(' ${_dateStr(e.eventDate)}', style: _ts(11, FontWeight.w400, _mt3)),
              const SizedBox(width: 10),
              const Icon(Icons.location_on_outlined, color: _mt3, size: 12),
              Text(' ${e.location}', style: _ts(11, FontWeight.w400, _mt3)),
              const Spacer(),
              const Icon(Icons.people_rounded, color: _mt3, size: 12),
              Text(' ${e.participantCount}명', style: _ts(11, FontWeight.w400, _mt3)),
            ]),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                setState(() {
                  e.myJoined = !e.myJoined;
                  e.participantCount += e.myJoined ? 1 : -1;
                });
                widget.onChanged();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: e.myJoined ? _mgreen.withOpacity(0.2) : _mred,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: e.myJoined ? _mgreen.withOpacity(0.6) : _mred),
                ),
                child: Text(e.myJoined ? '참여중 (취소)' : '참여하기',
                    style: _ts(12, FontWeight.w700,
                        e.myJoined ? _mgreen : Colors.white)),
              ),
            ),
          ]),
        );
      },
    );
  }
}

// ── 동호회 멤버 탭 ────────────────────────────────────────────
class _ClubMembersTab extends StatefulWidget {
  final MotoClub club;
  const _ClubMembersTab({required this.club});
  @override
  State<_ClubMembersTab> createState() => _ClubMembersTabState();
}
class _ClubMembersTabState extends State<_ClubMembersTab> {
  @override
  Widget build(BuildContext context) {
    final members = widget.club.members;
    final isOwner = members.any(
        (m) => m.userId == 'me' && m.role == MotoClubRole.owner);
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: members.length,
      itemBuilder: (_, i) {
        final m = members[i];
        final isMe = m.userId == 'me';
        final isOwnerMember = m.role == MotoClubRole.owner;
        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: _mcard, borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _mborder)),
          child: Row(children: [
            CircleAvatar(radius: 18,
                backgroundColor: isOwnerMember
                    ? _mred.withOpacity(0.2)
                    : m.role == MotoClubRole.vice
                        ? _morange.withOpacity(0.2)
                        : _mcard2,
                child: Text(m.name[0], style: _ts(14, FontWeight.w700,
                    isOwnerMember ? _mred
                        : m.role == MotoClubRole.vice ? _morange : _maccent))),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(m.name, style: _ts(13, FontWeight.w700, _mt1)),
                if (isMe) ...[
                  const SizedBox(width: 6),
                  _badge('나', _maccent),
                ],
              ]),
              Text('가입 ${_dateStr(m.joinedAt)}', style: _ts(10, FontWeight.w400, _mt3)),
            ])),
            _badge(m.role.label,
                m.role == MotoClubRole.owner ? _mred
                    : m.role == MotoClubRole.vice ? _morange : _mt3),
            if (isOwner && !isMe && !isOwnerMember) ...[
              const SizedBox(width: 6),
              PopupMenuButton<String>(
                color: _mcard2,
                icon: Icon(Icons.more_vert, color: _mt3, size: 18),
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'vice',
                      child: Text(
                          m.role == MotoClubRole.vice ? '부방장 해제' : '부방장 지정',
                          style: _ts(13, FontWeight.w500, _morange))),
                  PopupMenuItem(value: 'kick',
                      child: Text('내보내기',
                          style: _ts(13, FontWeight.w500, _mred))),
                ],
                onSelected: (v) {
                  if (v == 'kick') {
                    MotoState().kickMember(widget.club.clubId, m.userId);
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('\${m.name}님을 내보냈습니다.'),
                        backgroundColor: _mred));
                  } else {
                    MotoState().toggleVice(widget.club.clubId, m.userId);
                    setState(() {});
                    final lbl = m.role == MotoClubRole.vice ? '멤버' : '부방장';
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('\${m.name}님을 \$lbl로 변경했습니다.'),
                        backgroundColor: _maccent));
                  }
                },
              ),
            ],
          ]),
        );
      },
    );
  }
}

// ── 글쓰기 화면 ───────────────────────────────────────────────
class _MotoPostWriteScreen extends StatefulWidget {
  final String clubId;
  const _MotoPostWriteScreen({required this.clubId});
  @override
  State<_MotoPostWriteScreen> createState() => _MotoPostWriteScreenState();
}
class _MotoPostWriteScreenState extends State<_MotoPostWriteScreen> {
  final _contentCtrl = TextEditingController();
  final _videoCtrl   = TextEditingController();
  List<String> _photos = [];

  @override
  void dispose() { _contentCtrl.dispose(); _videoCtrl.dispose(); super.dispose(); }

  Future<void> _addPhotos() async {
    final picked = await _pickImages(context, max: 10 - _photos.length);
    if (picked.isNotEmpty) setState(() => _photos.addAll(picked));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _mbg,
      appBar: AppBar(
        backgroundColor: _mcard,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _mt1, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('글쓰기', style: _ts(16, FontWeight.w700, _mt1)),
        actions: [
          TextButton(
            onPressed: _submit,
            child: Text('등록', style: _ts(14, FontWeight.w700, _mgreen)),
          ),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // ── 사진 첨부 ──
        GestureDetector(
          onTap: _photos.length < 10 ? _addPhotos : null,
          child: Container(
            height: _photos.isEmpty ? 70 : null,
            decoration: BoxDecoration(
              color: _mcard, borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _photos.isEmpty ? _mborder : _maccent.withOpacity(0.4))),
            child: _photos.isEmpty
                ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.add_photo_alternate_outlined, color: _maccent, size: 24),
                    const SizedBox(width: 8),
                    Text('사진 첨부 (카메라/앨범)', style: _ts(13, FontWeight.w600, _mt2)),
                  ])
                : Padding(
                    padding: const EdgeInsets.all(8),
                    child: Wrap(spacing: 6, runSpacing: 6, children: [
                      ..._photos.asMap().entries.map((e) => Stack(children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.file(File(e.value),
                              width: 80, height: 80, fit: BoxFit.cover),
                        ),
                        Positioned(top: 2, right: 2,
                            child: GestureDetector(
                              onTap: () => setState(() => _photos.removeAt(e.key)),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.close, color: Colors.white, size: 12),
                              ),
                            )),
                      ])),
                      if (_photos.length < 10)
                        GestureDetector(
                          onTap: _addPhotos,
                          child: Container(
                            width: 80, height: 80,
                            decoration: BoxDecoration(color: _mcard2,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: _mborder)),
                            child: const Column(mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                              Icon(Icons.add_rounded, color: _maccent, size: 22),
                              Text('추가', style: TextStyle(fontSize: 10, color: _maccent)),
                            ]),
                          ),
                        ),
                    ]),
                  ),
          ),
        ),
        const SizedBox(height: 10),
        // 유튜브 링크
        TextField(
          controller: _videoCtrl,
          style: _ts(13, FontWeight.w400, _mt1),
          decoration: InputDecoration(
            hintText: 'YouTube URL (선택)',
            hintStyle: _ts(13, FontWeight.w400, _mt3),
            prefixIcon: const Icon(Icons.play_circle_outline_rounded,
                color: Color(0xFFFF0000), size: 18),
            filled: true, fillColor: _mcard,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _mborder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _mborder)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: _maccent.withOpacity(0.5))),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _contentCtrl,
          maxLines: 10,
          style: _ts(13, FontWeight.w400, _mt1),
          decoration: InputDecoration(
            hintText: '내용을 입력하세요...',
            hintStyle: _ts(13, FontWeight.w400, _mt3),
            filled: true, fillColor: _mcard,
            contentPadding: const EdgeInsets.all(14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _mborder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _mborder)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: _maccent.withOpacity(0.5))),
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: _submit,
          child: Container(
            height: 50,
            decoration: BoxDecoration(color: _mgreen, borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text('게시글 등록',
                style: _ts(15, FontWeight.w700, Colors.white))),
          ),
        ),
      ]),
    );
  }

  void _submit() {
    if (_contentCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('내용을 입력해주세요.'), backgroundColor: _mred));
      return;
    }
    MotoState().addClubPost(widget.clubId, MotoClubPost(
      postId: 'cp-\${DateTime.now().millisecondsSinceEpoch}',
      clubId: widget.clubId,
      authorName: '나',
      content: _contentCtrl.text.trim(),
      photoUrls: _photos,
      videoUrl: _videoCtrl.text.trim().isEmpty ? null : _videoCtrl.text.trim(),
      reactions: EmojiReaction.defaults(),
      createdAt: DateTime.now(),
    ));
    _showDone(context, '게시글이 등록되었습니다!\n동호회 게시판에서 확인하세요.', then: () {
      Navigator.pop(context);
    });
  }
}

// ── 동호회 개설 화면 ──────────────────────────────────────────
class _MotoClubCreateScreen extends StatefulWidget {
  const _MotoClubCreateScreen();
  @override
  State<_MotoClubCreateScreen> createState() => _MotoClubCreateScreenState();
}
class _MotoClubCreateScreenState extends State<_MotoClubCreateScreen> {
  final _nameCtrl  = TextEditingController();
  final _descCtrl  = TextEditingController();
  final _regionCtrl = TextEditingController();
  MotoCommunityType _category = MotoCommunityType.brand;
  MotoClubJoinType  _joinType = MotoClubJoinType.open;
  bool _isPublic = true;
  String _coverPath = '';   // 로컬 파일 경로

  Future<void> _pickCover() async {
    final picked = await _pickImages(context, max: 1);
    if (picked.isNotEmpty) setState(() => _coverPath = picked.first);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _mbg,
      appBar: AppBar(
        backgroundColor: _mcard,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _mt1, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('동호회 개설', style: _ts(16, FontWeight.w700, _mt1)),
        actions: [
          TextButton(
            onPressed: _submit,
            child: Text('개설', style: _ts(14, FontWeight.w700, _mgreen)),
          ),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // 커버 이미지
        GestureDetector(
          onTap: _pickCover,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: _mcard, borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _coverPath.isEmpty ? _mborder : _mgreen.withOpacity(0.5)),
            ),
            child: _coverPath.isEmpty
                ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.add_photo_alternate_outlined, color: _maccent, size: 28),
                    const SizedBox(width: 8),
                    Column(mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('커버 이미지 선택', style: _ts(13, FontWeight.w600, _mt1)),
                      Text('카메라 / 앨범', style: _ts(11, FontWeight.w400, _mt3)),
                    ]),
                  ])
                : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(fit: StackFit.expand, children: [
                      Image.file(File(_coverPath), fit: BoxFit.cover),
                      Positioned(bottom: 0, left: 0, right: 0,
                          child: Container(
                            color: Colors.black.withOpacity(0.5),
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              const Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text('변경', style: _ts(12, FontWeight.w600, Colors.white)),
                            ]),
                          )),
                    ]),
                  ),
          ),
        ),
        const SizedBox(height: 14),
        _field('동호회명', _nameCtrl, '예: 대구 혼다 라이더즈'),
        _field('소개', _descCtrl, '동호회 소개를 입력하세요', maxLines: 3),
        _field('지역', _regionCtrl, '대구, 서울, 전국...'),
        const SizedBox(height: 10),
        // 카테고리
        Text('카테고리', style: _ts(12, FontWeight.w600, _mt2)),
        const SizedBox(height: 6),
        Wrap(spacing: 6, runSpacing: 6, children: MotoCommunityType.values.map((t) =>
          GestureDetector(
            onTap: () => setState(() => _category = t),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _category == t ? _mgreen.withOpacity(0.2) : _mcard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _category == t ? _mgreen : _mborder),
              ),
              child: Text(t.label, style: _ts(12, FontWeight.w600,
                  _category == t ? _mgreen : _mt2)),
            ),
          )).toList()),
        const SizedBox(height: 12),
        // 가입 방식
        Text('가입 방식', style: _ts(12, FontWeight.w600, _mt2)),
        const SizedBox(height: 6),
        Row(children: MotoClubJoinType.values.map((t) => GestureDetector(
          onTap: () => setState(() => _joinType = t),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _joinType == t ? _maccent.withOpacity(0.2) : _mcard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _joinType == t ? _maccent : _mborder),
            ),
            child: Text(t.label, style: _ts(12, FontWeight.w600,
                _joinType == t ? _maccent : _mt2)),
          ),
        )).toList()),
        const SizedBox(height: 10),
        // 공개 여부
        Row(children: [
          Text('공개 동호회', style: _ts(13, FontWeight.w500, _mt2)),
          const Spacer(),
          Switch(value: _isPublic, onChanged: (v) => setState(() => _isPublic = v),
              activeColor: _mgreen, inactiveTrackColor: _mborder),
        ]),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: _submit,
          child: Container(
            height: 50,
            decoration: BoxDecoration(color: _mgreen, borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text('동호회 개설하기',
                style: _ts(15, FontWeight.w700, Colors.white))),
          ),
        ),
      ]),
    );
  }

  void _submit() {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('동호회명을 입력해주세요.'), backgroundColor: _mred));
      return;
    }
    final club = MotoClub(
      clubId: 'MC-\${DateTime.now().millisecondsSinceEpoch}',
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      category: _category,
      region: _regionCtrl.text.trim().isEmpty ? '전국' : _regionCtrl.text.trim(),
      coverImageUrl: _coverPath.isNotEmpty
          ? _coverPath
          : 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600&q=80',
      joinType: _joinType,
      isPublic: _isPublic,
      myJoined: true,
      members: [
        MotoClubMember(userId: 'me', name: '나',
            role: MotoClubRole.owner, joinedAt: DateTime.now()),
      ],
    );
    MotoState().createClub(club);
    _showDone(context, '\${club.name} 동호회가 개설되었습니다!', then: () {
      Navigator.pop(context);
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => _MotoClubDetailScreen(club: club)));
    });
  }

  Widget _field(String label, TextEditingController ctrl, String hint, {int maxLines = 1}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextField(
          controller: ctrl,
          maxLines: maxLines,
          style: _ts(13, FontWeight.w400, _mt1),
          decoration: InputDecoration(
            labelText: label, labelStyle: _ts(12, FontWeight.w500, _mt3),
            hintText: hint, hintStyle: _ts(12, FontWeight.w400, _mt3.withOpacity(0.6)),
            filled: true, fillColor: _mcard,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _mborder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _mborder)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: _maccent.withOpacity(0.5))),
          ),
        ),
      );
}

// ══════════════════════════════════════════════════════════════
// 탭 4: 영상/정보
// ══════════════════════════════════════════════════════════════
class _MotoVideoInfoTab extends StatefulWidget {
  const _MotoVideoInfoTab();
  @override
  State<_MotoVideoInfoTab> createState() => _MotoVideoInfoTabState();
}
class _MotoVideoInfoTabState extends State<_MotoVideoInfoTab>
    with SingleTickerProviderStateMixin {
  late TabController _sub;
  @override
  void initState() {
    super.initState();
    _sub = TabController(length: 2, vsync: this);
  }
  @override
  void dispose() { _sub.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        color: _mcard,
        child: TabBar(
          controller: _sub,
          indicatorColor: _morange,
          labelColor: _mt1,
          unselectedLabelColor: _mt3,
          labelStyle: _ts(13, FontWeight.w700, _mt1),
          unselectedLabelStyle: _ts(13, FontWeight.w500, _mt3),
          tabs: const [Tab(text: '영상'), Tab(text: '정보/안전')],
        ),
      ),
      Expanded(
        child: TabBarView(
          controller: _sub,
          children: [
            _VideoTab(onChanged: () => setState(() {})),
            const _InfoTab(),
          ],
        ),
      ),
    ]);
  }
}

// ── 영상 탭 ──────────────────────────────────────────────────
class _VideoTab extends StatefulWidget {
  final VoidCallback onChanged;
  const _VideoTab({required this.onChanged});
  @override
  State<_VideoTab> createState() => _VideoTabState();
}
class _VideoTabState extends State<_VideoTab> {
  MotoVideoCategory? _filter;

  @override
  Widget build(BuildContext context) {
    final state = MotoState();
    var videos = state.videos;
    if (_filter != null) videos = videos.where((v) => v.category == _filter).toList();

    return Column(children: [
      // 필터 + 등록 버튼
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
        child: Row(children: [
          Expanded(
            child: SizedBox(
              height: 32,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _chip('전체', _filter == null, () => setState(() => _filter = null)),
                  ...MotoVideoCategory.values.map((c) =>
                    _chip(c.label, _filter == c, () => setState(() => _filter = c))),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const _VideoRegisterScreen()))
                .then((_) => setState(() {})),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFFFF0000).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFF0000).withOpacity(0.5))),
              child: Row(children: [
                const Icon(Icons.add, color: Color(0xFFFF0000), size: 14),
                const SizedBox(width: 4),
                Text('영상 등록', style: _ts(11, FontWeight.w600, const Color(0xFFFF0000))),
              ]),
            ),
          ),
        ]),
      ),
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: videos.length,
          itemBuilder: (_, i) => _VideoCard(video: videos[i]),
        ),
      ),
    ]);
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(right: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: selected ? _morange.withOpacity(0.2) : _mcard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? _morange : _mborder),
          ),
          child: Text(label,
              style: _ts(11, FontWeight.w600, selected ? _morange : _mt2)),
        ),
      );
}

// ── 영상 카드 ────────────────────────────────────────────────
class _VideoCard extends StatelessWidget {
  final MotoVideo video;
  const _VideoCard({required this.video});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(video.youtubeUrl);
        if (await canLaunchUrl(uri)) launchUrl(uri);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(color: _mcard, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _mborder)),
        child: Row(children: [
          Stack(children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              child: Image.network(video.thumbnailUrl, width: 110, height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                      width: 110, height: 80, color: _mcard2)),
            ),
            Positioned.fill(child: Center(child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle),
              child: const Icon(Icons.play_arrow_rounded,
                  color: Colors.white, size: 22),
            ))),
          ]),
          const SizedBox(width: 10),
          Expanded(child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _badge(video.category.label, _morange),
              const SizedBox(height: 4),
              Text(video.title, style: _ts(13, FontWeight.w600, _mt1),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Row(children: [
                Text(video.channelName, style: _ts(10, FontWeight.w400, _mt3)),
                const SizedBox(width: 6),
                const Icon(Icons.visibility_outlined, color: _mt3, size: 11),
                Text(' ${video.viewCountText}', style: _ts(10, FontWeight.w400, _mt3)),
              ]),
            ]),
          )),
          const Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(Icons.open_in_new_rounded, color: _mt3, size: 16),
          ),
        ]),
      ),
    );
  }
}

// ── 영상 등록 화면 ────────────────────────────────────────────
class _VideoRegisterScreen extends StatefulWidget {
  const _VideoRegisterScreen();
  @override
  State<_VideoRegisterScreen> createState() => _VideoRegisterScreenState();
}
class _VideoRegisterScreenState extends State<_VideoRegisterScreen> {
  final _urlCtrl    = TextEditingController();
  final _titleCtrl  = TextEditingController();
  final _chCtrl     = TextEditingController();
  MotoVideoCategory _cat = MotoVideoCategory.review;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _mbg,
      appBar: AppBar(
        backgroundColor: _mcard,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _mt1, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('영상 등록', style: _ts(16, FontWeight.w700, _mt1)),
        actions: [
          TextButton(
            onPressed: _submit,
            child: Text('등록', style: _ts(14, FontWeight.w700, _morange)),
          ),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _field('YouTube URL', _urlCtrl, 'https://www.youtube.com/watch?v=...'),
        _field('제목', _titleCtrl, '영상 제목'),
        _field('채널명', _chCtrl, '채널 이름'),
        const SizedBox(height: 8),
        Text('카테고리', style: _ts(12, FontWeight.w600, _mt2)),
        const SizedBox(height: 6),
        Wrap(spacing: 6, runSpacing: 6, children: MotoVideoCategory.values.map((c) =>
          GestureDetector(
            onTap: () => setState(() => _cat = c),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _cat == c ? _morange.withOpacity(0.2) : _mcard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _cat == c ? _morange : _mborder),
              ),
              child: Text(c.label, style: _ts(12, FontWeight.w600,
                  _cat == c ? _morange : _mt2)),
            ),
          )).toList()),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: _submit,
          child: Container(
            height: 50,
            decoration: BoxDecoration(color: _morange, borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text('영상 등록하기',
                style: _ts(15, FontWeight.w700, Colors.white))),
          ),
        ),
      ]),
    );
  }

  void _submit() {
    if (_urlCtrl.text.trim().isEmpty || _titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('URL과 제목을 입력해주세요.'), backgroundColor: _mred));
      return;
    }
    final vid = MotoVideo(
      videoId: 'V-${DateTime.now().millisecondsSinceEpoch}',
      youtubeUrl: _urlCtrl.text.trim(),
      thumbnailUrl: 'https://images.unsplash.com/photo-1568772585407-9361f9bf3a87?w=400&q=80',
      title: _titleCtrl.text.trim(),
      channelName: _chCtrl.text.trim().isEmpty ? '사용자 등록' : _chCtrl.text.trim(),
      viewCountText: '0회',
      category: _cat,
    );
    MotoState().videos.insert(0, vid);
    Navigator.pop(context);
  }

  Widget _field(String label, TextEditingController ctrl, String hint) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextField(
          controller: ctrl,
          style: _ts(13, FontWeight.w400, _mt1),
          decoration: InputDecoration(
            labelText: label, labelStyle: _ts(12, FontWeight.w500, _mt3),
            hintText: hint, hintStyle: _ts(12, FontWeight.w400, _mt3.withOpacity(0.6)),
            filled: true, fillColor: _mcard,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _mborder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _mborder)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: _maccent.withOpacity(0.5))),
          ),
        ),
      );
}

// ── 동호회 메뉴 (방장 권한 + 초대공유) ─────────────────────
void _showClubMenu(BuildContext ctx, MotoClub club, {void Function()? onChanged}) {
  final isOwner = club.members.any(
      (m) => m.userId == 'me' && m.role == MotoClubRole.owner);
  final isViceOrOwner = club.members.any(
      (m) => m.userId == 'me' &&
          (m.role == MotoClubRole.owner || m.role == MotoClubRole.vice));

  showModalBottomSheet(
    context: ctx,
    backgroundColor: const Color(0xFF0D1721),
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (bsCtx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 36, height: 3, margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: const Color(0xFF546E7A),
                  borderRadius: BorderRadius.circular(2))),
          // ── 초대 링크 (모든 멤버)
          ListTile(
            leading: const Icon(Icons.share_rounded, color: Color(0xFF4FC3F7)),
            title: Text('초대 링크 공유',
                style: GoogleFonts.notoSansKr(fontSize: 14,
                    fontWeight: FontWeight.w600, color: Colors.white)),
            subtitle: Text('링크를 복사하여 카카오톡 등으로 공유',
                style: GoogleFonts.notoSansKr(fontSize: 11, color: const Color(0xFF546E7A))),
            onTap: () {
              Navigator.pop(bsCtx);
              final inviteText =
                  '[MOINCAR 동호회 초대]\n'
                  '동호회: \${club.name}\n'
                  '지역: \${club.region}\n'
                  '소개: \${club.description}\n\n'
                  '가입 링크: https://moincar.app/club/\${club.clubId}';
              Clipboard.setData(ClipboardData(text: inviteText));
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(
                  content: Text('초대 링크가 복사되었습니다!'),
                  backgroundColor: Color(0xFF10B981),
                  duration: Duration(seconds: 3),
                ),
              );
            },
          ),
          const Divider(color: Color(0xFF1A2A3A), height: 1),
          // ── 커버 이미지 공유 (모든 멤버)
          ListTile(
            leading: const Icon(Icons.image_rounded, color: Color(0xFF10B981)),
            title: Text('커버 이미지 공유',
                style: GoogleFonts.notoSansKr(fontSize: 14,
                    fontWeight: FontWeight.w600, color: Colors.white)),
            onTap: () {
              Navigator.pop(bsCtx);
              Clipboard.setData(ClipboardData(text: club.coverImageUrl));
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(content: Text('커버 이미지 URL이 복사되었습니다.'),
                    backgroundColor: Color(0xFF10B981)),
              );
            },
          ),
          if (isViceOrOwner) ...[
            const Divider(color: Color(0xFF1A2A3A), height: 1),
            // ── 공지 발송 (부방장 이상)
            ListTile(
              leading: const Icon(Icons.campaign_rounded, color: Color(0xFFFF6B35)),
              title: Text('공지 발송',
                  style: GoogleFonts.notoSansKr(fontSize: 14,
                      fontWeight: FontWeight.w600, color: Colors.white)),
              subtitle: Text('전체 멤버에게 푸시 알림 발송',
                  style: GoogleFonts.notoSansKr(fontSize: 11, color: const Color(0xFF546E7A))),
              onTap: () {
                Navigator.pop(bsCtx);
                _showPushDialog(ctx, club, onChanged: onChanged);
              },
            ),
          ],
          if (isOwner) ...[
            const Divider(color: Color(0xFF1A2A3A), height: 1),
            // ── 멤버 관리 (방장 전용)
            ListTile(
              leading: const Icon(Icons.manage_accounts_rounded, color: Color(0xFFFFD54F)),
              title: Text('멤버 관리',
                  style: GoogleFonts.notoSansKr(fontSize: 14,
                      fontWeight: FontWeight.w600, color: Colors.white)),
              subtitle: Text('내보내기 / 부방장 지정',
                  style: GoogleFonts.notoSansKr(fontSize: 11, color: const Color(0xFF546E7A))),
              onTap: () {
                Navigator.pop(bsCtx);
                _showMemberManageSheet(ctx, club, onChanged: onChanged);
              },
            ),
            const Divider(color: Color(0xFF1A2A3A), height: 1),
            // ── 동호회 탈퇴 (방장 제외)
          ],
          if (!isOwner) ...[
            const Divider(color: Color(0xFF1A2A3A), height: 1),
            ListTile(
              leading: const Icon(Icons.exit_to_app_rounded, color: Color(0xFFE63946)),
              title: Text('동호회 탈퇴',
                  style: GoogleFonts.notoSansKr(fontSize: 14,
                      fontWeight: FontWeight.w600, color: const Color(0xFFE63946))),
              onTap: () {
                Navigator.pop(bsCtx);
                showDialog(
                  context: ctx,
                  builder: (_) => AlertDialog(
                    backgroundColor: const Color(0xFF0D1721),
                    title: Text('동호회 탈퇴', style: GoogleFonts.notoSansKr(
                        fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                    content: Text('\${club.name}에서 탈퇴하시겠습니까?',
                        style: GoogleFonts.notoSansKr(fontSize: 13, color: const Color(0xFFB0BEC5))),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(_),
                          child: Text('취소', style: GoogleFonts.notoSansKr(color: const Color(0xFF546E7A)))),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(_);
                          MotoState().leaveClub(club.clubId);
                          if (onChanged != null) onChanged();
                          ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                            content: Text('동호회에서 탈퇴했습니다.'),
                            backgroundColor: Color(0xFFE63946),
                          ));
                          Navigator.pop(ctx);
                        },
                        child: Text('탈퇴', style: GoogleFonts.notoSansKr(
                            fontWeight: FontWeight.w700, color: const Color(0xFFE63946))),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ]),
      ),
    ),
  );
}

// ── 공지 푸시 다이얼로그 ───────────────────────────────────────
void _showPushDialog(BuildContext ctx, MotoClub club, {void Function()? onChanged}) {
  final ctrl = TextEditingController();
  showDialog(
    context: ctx,
    builder: (dlgCtx) => AlertDialog(
      backgroundColor: const Color(0xFF0D1721),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: Text('공지 발송',
          style: GoogleFonts.notoSansKr(fontSize: 16,
              fontWeight: FontWeight.w700, color: Colors.white)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('${club.name} 전체 멤버(${club.memberCount}명)에게 푸시를 보냅니다.',
            style: GoogleFonts.notoSansKr(fontSize: 12,
                color: const Color(0xFF546E7A))),
        const SizedBox(height: 12),
        TextField(
          controller: ctrl,
          maxLines: 4,
          autofocus: true,
          style: GoogleFonts.notoSansKr(fontSize: 13, color: Colors.white),
          decoration: InputDecoration(
            hintText: '공지 내용을 입력하세요...',
            hintStyle: GoogleFonts.notoSansKr(fontSize: 13,
                color: const Color(0xFF546E7A)),
            filled: true, fillColor: const Color(0xFF111E2C),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF1A2A3A))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF1A2A3A))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: const Color(0xFF4FC3F7).withOpacity(0.5))),
          ),
        ),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dlgCtx),
            child: Text('취소',
                style: GoogleFonts.notoSansKr(color: const Color(0xFF546E7A)))),
        TextButton(
          onPressed: () {
            final txt = ctrl.text.trim();
            if (txt.isEmpty) return;
            // 공지 게시글로 등록
            final post = MotoClubPost(
              postId: 'notice-${DateTime.now().millisecondsSinceEpoch}',
              clubId: club.clubId,
              authorName: '방장',
              content: '[공지] $txt',
              isPinned: true,
              reactions: const [],
              createdAt: DateTime.now(),
            );
            MotoState().addClubPost(club.clubId, post);
            if (onChanged != null) onChanged();
            Navigator.pop(dlgCtx);
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
              content: Text('${club.memberCount}명에게 공지가 발송되었습니다.'),
              backgroundColor: const Color(0xFF10B981),
              duration: const Duration(seconds: 3),
            ));
          },
          child: Text('발송', style: GoogleFonts.notoSansKr(
              fontSize: 14, fontWeight: FontWeight.w700,
              color: const Color(0xFFFF6B35))),
        ),
      ],
    ),
  );
}

// ── 멤버 관리 시트 ────────────────────────────────────────────
void _showMemberManageSheet(BuildContext ctx, MotoClub club,
    {void Function()? onChanged}) {
  showModalBottomSheet(
    context: ctx,
    backgroundColor: const Color(0xFF0D1721),
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (bsCtx) => StatefulBuilder(
      builder: (bsCtx, setBS) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (__, sc) => Column(children: [
          const SizedBox(height: 12),
          Container(width: 36, height: 3,
              decoration: BoxDecoration(color: const Color(0xFF546E7A),
                  borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Text('멤버 관리 (${club.members.length}명)',
                  style: GoogleFonts.notoSansKr(fontSize: 16,
                      fontWeight: FontWeight.w700, color: Colors.white)),
            ]),
          ),
          Expanded(child: ListView.builder(
            controller: sc,
            itemCount: club.members.length,
            itemBuilder: (__, i) {
              final m = club.members[i];
              final isMe = m.userId == 'me';
              final isOwnerMember = m.role == MotoClubRole.owner;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF111E2C),
                  child: Text(m.name[0],
                      style: GoogleFonts.notoSansKr(fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isOwnerMember
                              ? const Color(0xFFE63946)
                              : m.role == MotoClubRole.vice
                                  ? const Color(0xFFFF6B35)
                                  : const Color(0xFF4FC3F7))),
                ),
                title: Text(m.name,
                    style: GoogleFonts.notoSansKr(fontSize: 13,
                        fontWeight: FontWeight.w600, color: Colors.white)),
                subtitle: Text(m.role.label,
                    style: GoogleFonts.notoSansKr(fontSize: 11,
                        color: isOwnerMember
                            ? const Color(0xFFE63946)
                            : m.role == MotoClubRole.vice
                                ? const Color(0xFFFF6B35)
                                : const Color(0xFF546E7A))),
                trailing: isMe || isOwnerMember ? null : PopupMenuButton<String>(
                  color: const Color(0xFF111E2C),
                  icon: const Icon(Icons.more_vert, color: Color(0xFF546E7A)),
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'vice',
                        child: Text(
                            m.role == MotoClubRole.vice ? '부방장 해제' : '부방장 지정',
                            style: GoogleFonts.notoSansKr(
                                color: const Color(0xFFFF6B35)))),
                    PopupMenuItem(value: 'kick',
                        child: Text('내보내기',
                            style: GoogleFonts.notoSansKr(
                                color: const Color(0xFFE63946)))),
                  ],
                  onSelected: (v) {
                    if (v == 'kick') {
                      MotoState().kickMember(club.clubId, m.userId);
                      setBS(() {});
                      if (onChanged != null) onChanged();
                      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                        content: Text('${m.name}님을 내보냈습니다.'),
                        backgroundColor: const Color(0xFFE63946),
                      ));
                    } else if (v == 'vice') {
                      MotoState().toggleVice(club.clubId, m.userId);
                      setBS(() {});
                      if (onChanged != null) onChanged();
                      final newRole = m.role == MotoClubRole.vice ? '멤버' : '부방장';
                      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                        content: Text('${m.name}님을 $newRole로 변경했습니다.'),
                        backgroundColor: const Color(0xFF4FC3F7),
                      ));
                    }
                  },
                ),
              );
            },
          )),
        ]),
      ),
    ),
  );
}

// ── 선택 다이얼로그 (공통) ────────────────────────────────────
class _PickerDialog extends StatelessWidget {
  final String title;
  final List<String> items;
  const _PickerDialog({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0D1721),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(title, style: GoogleFonts.notoSansKr(
              fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
        ),
        const Divider(color: Color(0xFF1A2A3A), height: 1),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 360),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (_, i) => ListTile(
              title: Text(items[i], style: GoogleFonts.notoSansKr(
                  fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
              onTap: () => Navigator.pop(context, items[i]),
            ),
          ),
        ),
        const Divider(color: Color(0xFF1A2A3A), height: 1),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('취소', style: GoogleFonts.notoSansKr(
              fontSize: 14, color: const Color(0xFF546E7A))),
        ),
      ]),
    );
  }
}

// ── 정보/안전 탭 ──────────────────────────────────────────────
class _InfoTab extends StatelessWidget {
  const _InfoTab();

  @override
  Widget build(BuildContext context) {
    final sections = [
      {
        'title': '검사 주기',
        'icon': Icons.fact_check_outlined,
        'color': _maccent,
        'items': [
          '이륜차 최초 검사: 구입 후 3년 이내',
          '이후 정기검사: 1년마다',
          '배달용 이륜차: 6개월마다',
          '전기이륜차: 일반 이륜차와 동일',
        ],
      },
      {
        'title': '안전 수칙',
        'icon': Icons.security_rounded,
        'color': _mgreen,
        'items': [
          '헬멧은 KS/KC 인증 제품 착용',
          '야간 주행 시 야광 조끼 착용 권장',
          '빗길 주행 시 급제동·급가속 금지',
          '고속도로 주행 시 2열 금지',
        ],
      },
      {
        'title': '튜닝 주의사항',
        'icon': Icons.build_rounded,
        'color': _morange,
        'items': [
          '구조변경 튜닝은 반드시 승인 필요',
          '소음 기준 초과 배기관 교체 불법',
          '불법 튜닝 적발 시 과태료 및 운행정지',
          '합법 튜닝 부품은 인증번호 확인',
        ],
      },
      {
        'title': '전기이륜 정보',
        'icon': Icons.electric_bolt_rounded,
        'color': _mred,
        'items': [
          '구매 보조금: 지역별 상이 (최대 150만원)',
          '충전 인프라: 전국 공용 충전소 검색 가능',
          '배터리 교환 서비스 점포 확인 가능',
          '전기이륜차 전용 태그 적용 예정 ⚡',
        ],
      },
      {
        'title': '배달라이더 전용 정보',
        'icon': Icons.delivery_dining_rounded,
        'color': _mt2,
        'items': [
          '제휴 점포 정비 할인 (동호회 회원증 제시)',
          '긴급 지원 요청 게시판 운영 중',
          '배달 전용 소모품 교체 주기 가이드',
          '사고 시 처리 절차 및 보험 안내',
        ],
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(12),
      children: sections.map((s) {
        final color = s['color'] as Color;
        final items = s['items'] as List<String>;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(color: _mcard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3))),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              leading: Icon(s['icon'] as IconData, color: color, size: 22),
              title: Text(s['title'] as String,
                  style: _ts(14, FontWeight.w700, _mt1)),
              iconColor: color,
              collapsedIconColor: _mt3,
              children: items.map((item) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(margin: const EdgeInsets.only(top: 6),
                      width: 4, height: 4, decoration: BoxDecoration(
                          color: color, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item, style: _ts(13, FontWeight.w400, _mt2).copyWith(height: 1.5))),
                ]),
              )).toList(),
            ),
          ),
        );
      }).toList(),
    );
  }
}
