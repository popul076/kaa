import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/app_state.dart';

// =====================================================
// 실제 자동차 관련 유튜브 쇼츠 데이터
// =====================================================
class ShortsData {
  final String videoId;
  final String title;
  final String category;
  final String views;

  const ShortsData({
    required this.videoId,
    required this.title,
    required this.category,
    required this.views,
  });

  String get youtubeUrl => 'https://www.youtube.com/shorts/$videoId';
  String get thumbnailUrl => 'https://img.youtube.com/vi/$videoId/mqdefault.jpg';
}

// 실제 자동차 관련 유튜브 쇼츠 영상 목록
final List<ShortsData> kAutoShorts = [
  ShortsData(videoId: 'M_ehRbGlwDQ', title: '차 오래 타려면 이 4가지 필수!',       category: '차량관리', views: '3.2만'),
  ShortsData(videoId: 'pL7ay-zd5Eo', title: '소모품 교체주기 총정리 🛠️',          category: '정비꿀팁', views: '5.1만'),
  ShortsData(videoId: 'x16Q5CObhQc', title: '여름철 차량관리 치트키 5가지',        category: '여름관리', views: '2.7만'),
  ShortsData(videoId: 'OI4-OdUIY8A', title: '엔진오일 교환 타이밍 완벽정리',      category: '정비꿀팁', views: '4.8만'),
  ShortsData(videoId: 'vl7jZcVHJTg', title: '여름 타이어 공기압 차종별 관리법',   category: '안전운행', views: '3.9만'),
  ShortsData(videoId: 'psNIy8wk4MQ', title: '모르면 손해! 계절별 차량관리법',     category: '차량관리', views: '6.3만'),
  ShortsData(videoId: 'fya_C7bfbQw', title: '차량 고무·쇠부품 관리 꿀팁',        category: '정비꿀팁', views: '1.9만'),
  ShortsData(videoId: 'Vs_TsMbE8CA', title: '여름 타이어 이러면 무조건 터짐 ⚠️', category: '안전운행', views: '8.2만'),
];

// ── 카테고리 색상 ──────────────────────────────────
Color _categoryColor(String cat) {
  switch (cat) {
    case '차량관리':  return const Color(0xFF4FC3F7);
    case '정비꿀팁': return const Color(0xFFFFB74D);
    case '여름관리': return const Color(0xFFFF7043);
    case '안전운행': return const Color(0xFF81C784);
    case '중고차':  return const Color(0xFFCE93D8);
    case '구매팁':  return const Color(0xFFFF8A65);
    case '전기차':  return const Color(0xFF4FC3F7);
    case '정비':   return const Color(0xFFFFB74D);
    case '용품':   return const Color(0xFFCE93D8);
    default:      return const Color(0xFF90A4AE);
  }
}

// ── 유튜브 앱 딥링크 열기 ─────────────────────────
Future<void> _openYoutubeDeeplink(String videoId) async {
  final appUri = Uri.parse('vnd.youtube://shorts/$videoId');
  final webUri = Uri.parse('https://www.youtube.com/shorts/$videoId');
  try {
    if (await canLaunchUrl(appUri)) {
      await launchUrl(appUri, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  } catch (_) {
    await launchUrl(webUri, mode: LaunchMode.externalApplication);
  }
}

// =====================================================
// 1. 홈화면 쇼츠 슬라이더 — "점포 유튜브 쇼츠"
//    카드 탭 → ShortsPlayerPage (앱 내 임베드 재생)
// =====================================================
class YoutubeShortSlider extends StatelessWidget {
  const YoutubeShortSlider({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 헤더 ──────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 14),
          child: Row(
            children: [
              Container(
                width: 4, height: 22,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF4FC3F7), Color(0xFF9B7CFF)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 9),
              const Text(
                '점포 유튜브 쇼츠',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.play_arrow, color: Colors.white, size: 12),
                    SizedBox(width: 2),
                    Text('Shorts',
                        style: TextStyle(color: Colors.white, fontSize: 10,
                            fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ],
                ),
              ),
              const Spacer(),
              Text('전체보기',
                  style: TextStyle(
                      color: const Color(0xFF4FC3F7).withOpacity(0.8),
                      fontSize: 12, fontWeight: FontWeight.w500)),
              const Icon(Icons.chevron_right, color: Color(0xFF4FC3F7), size: 16),
            ],
          ),
        ),

        // ── 세로형 카드 가로 슬라이더 ─────────────────
        // 카드 크기: 화면 너비의 58% (이전 40% → 58% 확대)
        SizedBox(
          height: 340,   // 이전 248 → 340 (대폭 확대)
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(left: 16, right: 8),
            itemCount: kAutoShorts.length,
            itemBuilder: (context, i) {
              return _ShortsCard(shorts: kAutoShorts[i], index: i);
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ── 쇼츠 카드 (세로형, 큰 사이즈) ──────────────────
class _ShortsCard extends StatelessWidget {
  final ShortsData shorts;
  final int index;
  const _ShortsCard({required this.shorts, required this.index});

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final cardW   = screenW * 0.58;          // 화면의 58%
    final thumbH  = cardW * (16 / 9) * 0.78; // 9:16 비율에 가깝게

    final catColor = _categoryColor(shorts.category);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ShortsPlayerPage(shorts: shorts)),
      ),
      child: Container(
        width: cardW,
        margin: const EdgeInsets.only(right: 12, bottom: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF0A1628),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1E3A5F).withOpacity(0.7)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.4),
                blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 썸네일 영역 ───────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(children: [
                SizedBox(
                  width: cardW, height: thumbH,
                  child: Image.network(
                    shorts.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: cardW, height: thumbH,
                      color: const Color(0xFF0D2040),
                      child: const Icon(Icons.play_circle_outline,
                          color: Color(0xFF4FC3F7), size: 40),
                    ),
                  ),
                ),
                // 재생 아이콘 오버레이
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                      ),
                    ),
                  ),
                ),
                // 중앙 재생 버튼
                Positioned.fill(
                  child: Center(
                    child: Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.8), width: 2),
                      ),
                      child: const Icon(Icons.play_arrow_rounded,
                          color: Colors.white, size: 28),
                    ),
                  ),
                ),
                // 카테고리 배지
                Positioned(
                  top: 8, left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: catColor.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(shorts.category,
                        style: const TextStyle(color: Colors.white,
                            fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
                // 조회수
                Positioned(
                  bottom: 8, right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.visibility_outlined,
                            color: Colors.white70, size: 10),
                        const SizedBox(width: 3),
                        Text(shorts.views,
                            style: const TextStyle(color: Colors.white70,
                                fontSize: 10)),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
            // ── 제목 ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 9, 10, 8),
              child: Text(
                shorts.title,
                style: const TextStyle(color: Colors.white,
                    fontSize: 12, fontWeight: FontWeight.w600, height: 1.3),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// 2. 쇼츠 플레이어 페이지 — 앱 내 임베드 재생
//    재생: youtube_player_flutter (공식 iframe/embed)
//    전체화면 버튼: 유튜브 앱 딥링크
// =====================================================
class ShortsPlayerPage extends StatefulWidget {
  final ShortsData shorts;
  const ShortsPlayerPage({super.key, required this.shorts});

  @override
  State<ShortsPlayerPage> createState() => _ShortsPlayerPageState();
}

class _ShortsPlayerPageState extends State<ShortsPlayerPage> {
  late YoutubePlayerController _ctrl;
  late ShortsData _current;

  @override
  void initState() {
    super.initState();
    _current = widget.shorts;
    _ctrl = _makeController(_current.videoId);
  }

  YoutubePlayerController _makeController(String videoId) {
    return YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: false,
        loop: false,
        useHybridComposition: true,
        forceHD: false,
      ),
    );
  }

  void _switchTo(ShortsData s) {
    setState(() => _current = s);
    _ctrl.load(s.videoId);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _categoryColor(_current.category);

    return YoutubePlayerBuilder(
      onExitFullScreen: () =>
          SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
      player: YoutubePlayer(
        controller: _ctrl,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.red,
        progressColors: const ProgressBarColors(
          playedColor: Colors.red,
          handleColor: Colors.redAccent,
        ),
        topActions: [
          // 오른쪽 상단 — 유튜브 앱으로 전체화면 열기
          Expanded(child: Container()),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.open_in_new, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text('유튜브에서 크게 보기',
                      style: TextStyle(color: Colors.white, fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            onPressed: () => _openYoutubeDeeplink(_current.videoId),
          ),
        ],
        onReady: () => _ctrl.play(),
      ),
      builder: (context, player) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: const Color(0xFF0A0A0A),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: catColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: catColor.withOpacity(0.5)),
              ),
              child: Text(_current.category,
                  style: TextStyle(color: catColor, fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(_current.title,
                  style: const TextStyle(color: Colors.white, fontSize: 13,
                      fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis),
            ),
          ]),
          actions: [
            // 앱바 우측 — 유튜브 앱 열기 버튼
            TextButton.icon(
              onPressed: () => _openYoutubeDeeplink(_current.videoId),
              icon: const Icon(Icons.open_in_new, color: Colors.red, size: 16),
              label: const Text('크게 보기',
                  style: TextStyle(color: Colors.red, fontSize: 12)),
            ),
          ],
        ),
        body: Column(children: [
          // ── 플레이어 (9:16 세로) ──────────────────
          AspectRatio(aspectRatio: 9 / 16, child: player),

          // ── 영상 정보 ──────────────────────────────
          Container(
            color: const Color(0xFF0A0A0A),
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: catColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: catColor.withOpacity(0.4)),
                ),
                child: Text(_current.category,
                    style: TextStyle(color: catColor, fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Text('${_current.views} 조회',
                  style: const TextStyle(color: Color(0xFF888888), fontSize: 11)),
              const Spacer(),
              // 유튜브 앱으로 열기
              GestureDetector(
                onTap: () => _openYoutubeDeeplink(_current.videoId),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red.withOpacity(0.5)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.open_in_new, color: Colors.red, size: 12),
                      SizedBox(width: 4),
                      Text('유튜브 앱',
                          style: TextStyle(color: Colors.red, fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ]),
          ),

          const Divider(color: Color(0xFF1A1A1A), height: 1),

          // ── 다른 쇼츠 목록 ────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('다른 쇼츠',
                  style: TextStyle(color: catColor, fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 14),
              itemCount: kAutoShorts.length,
              itemBuilder: (context, i) {
                final s = kAutoShorts[i];
                if (s.videoId == _current.videoId) return const SizedBox.shrink();
                final isSelected = false;
                return GestureDetector(
                  onTap: () => _switchTo(s),
                  child: Container(
                    width: 110,
                    margin: const EdgeInsets.only(right: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(s.thumbnailUrl,
                              width: 110, height: 62, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 110, height: 62,
                                color: const Color(0xFF1E1E1E),
                                child: const Icon(Icons.play_circle_outline,
                                    color: Colors.white54, size: 24),
                              )),
                        ),
                        const SizedBox(height: 4),
                        Text(s.title,
                            style: const TextStyle(color: Colors.white70,
                                fontSize: 10),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}

// =====================================================
// 3. 점포/명소 유튜브 플레이어 — 인앱 임베드 (작게)
//    전체화면 버튼 → 유튜브 앱 딥링크
// =====================================================
class YoutubePlayerPage extends StatefulWidget {
  final Store store;
  const YoutubePlayerPage({super.key, required this.store});

  @override
  State<YoutubePlayerPage> createState() => _YoutubePlayerPageState();
}

class _YoutubePlayerPageState extends State<YoutubePlayerPage> {
  YoutubePlayerController? _ctrl;

  @override
  void initState() {
    super.initState();
    if (widget.store.videoId != null) {
      _ctrl = YoutubePlayerController(
        initialVideoId: widget.store.videoId!,
        flags: const YoutubePlayerFlags(
          autoPlay: false,           // 자동재생 OFF (점포용은 수동 재생)
          mute: false,
          enableCaption: false,
          useHybridComposition: true,
        ),
      );
    }
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_ctrl == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF020810),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0D1B2A),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(widget.store.name,
              style: const TextStyle(color: Colors.white, fontSize: 15,
                  fontWeight: FontWeight.bold)),
        ),
        body: const Center(
          child: Text('등록된 영상이 없습니다.',
              style: TextStyle(color: Colors.white60)),
        ),
      );
    }

    return YoutubePlayerBuilder(
      onExitFullScreen: () =>
          SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
      player: YoutubePlayer(
        controller: _ctrl!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: const Color(0xFF4FC3F7),
        progressColors: const ProgressBarColors(
          playedColor: Color(0xFF4FC3F7),
          handleColor: Color(0xFF0288D1),
        ),
        // 플레이어 상단 오른쪽 — 유튜브 앱 딥링크
        topActions: [
          Expanded(child: Container()),
          IconButton(
            tooltip: '유튜브 앱에서 크게 보기',
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.65),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.open_in_new, color: Colors.white, size: 13),
                SizedBox(width: 4),
                Text('유튜브에서 크게 보기',
                    style: TextStyle(color: Colors.white, fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ]),
            ),
            onPressed: () => _openYoutubeDeeplink(widget.store.videoId!),
          ),
        ],
        onReady: () {},   // 자동재생 안 함
      ),
      builder: (context, player) => Scaffold(
        backgroundColor: const Color(0xFF020810),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0D1B2A),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(widget.store.name,
              style: const TextStyle(color: Colors.white, fontSize: 15,
                  fontWeight: FontWeight.bold)),
          actions: [
            TextButton.icon(
              onPressed: () => _openYoutubeDeeplink(widget.store.videoId!),
              icon: const Icon(Icons.open_in_new, color: Color(0xFF4FC3F7), size: 16),
              label: const Text('유튜브 앱',
                  style: TextStyle(color: Color(0xFF4FC3F7), fontSize: 12)),
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 임베드 플레이어 (16:9 작은 크기) ─────
            AspectRatio(aspectRatio: 16 / 9, child: player),

            // ── 점포 정보 + 유튜브 앱 버튼 ───────────
            Container(
              color: const Color(0xFF0D1B2A),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(children: [
                const Icon(Icons.store, color: Color(0xFF4FC3F7), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(widget.store.name,
                      style: const TextStyle(color: Colors.white, fontSize: 14,
                          fontWeight: FontWeight.bold)),
                ),
                // 유튜브 앱으로 크게 보기 버튼
                GestureDetector(
                  onTap: () => _openYoutubeDeeplink(widget.store.videoId!),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF0000), Color(0xFFCC0000)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.open_in_new, color: Colors.white, size: 13),
                        SizedBox(width: 5),
                        Text('유튜브에서 크게 보기',
                            style: TextStyle(color: Colors.white,
                                fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ]),
            ),

            // ── 안내 텍스트 ───────────────────────────
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                '💡 재생 버튼을 눌러 앱 내에서 감상하거나,\n   "유튜브에서 크게 보기"로 전체화면 시청하세요.',
                style: TextStyle(color: Color(0xFF5A7A9A), fontSize: 12,
                    height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// 4. YouTube URL 입력 위젯 (관리자용)
// =====================================================
class YoutubeUrlInputWidget extends StatefulWidget {
  final Function(String videoId) onVideoIdSaved;
  final String? initialVideoId;

  const YoutubeUrlInputWidget({
    super.key,
    required this.onVideoIdSaved,
    this.initialVideoId,
  });

  @override
  State<YoutubeUrlInputWidget> createState() => _YoutubeUrlInputWidgetState();
}

class _YoutubeUrlInputWidgetState extends State<YoutubeUrlInputWidget> {
  final _controller = TextEditingController();
  String? _videoId;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialVideoId != null) {
      _videoId = widget.initialVideoId;
      _controller.text =
          'https://www.youtube.com/shorts/${widget.initialVideoId}';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _extractVideoId(String url) {
    final patterns = [
      RegExp(r'youtube\.com/shorts/([a-zA-Z0-9_-]{11})'),
      RegExp(r'youtu\.be/([a-zA-Z0-9_-]{11})'),
      RegExp(r'youtube\.com/watch\?v=([a-zA-Z0-9_-]{11})'),
    ];
    for (final p in patterns) {
      final m = p.firstMatch(url);
      if (m != null) return m.group(1);
    }
    if (RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(url.trim())) return url.trim();
    return null;
  }

  void _validateAndSave() {
    final id = _extractVideoId(_controller.text.trim());
    if (id == null) {
      setState(() { _error = '유효한 YouTube Shorts URL 또는 영상 ID를 입력해주세요'; _videoId = null; });
      return;
    }
    setState(() { _error = null; _videoId = id; });
    widget.onVideoIdSaved(id);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'https://youtube.com/shorts/...',
            hintStyle: const TextStyle(color: Colors.grey),
            errorText: _error,
            filled: true,
            fillColor: const Color(0xFF1A2535),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF2A3F5F)),
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.check, color: Color(0xFF4FC3F7)),
              onPressed: _validateAndSave,
            ),
          ),
        ),
        if (_videoId != null) ...[
          const SizedBox(height: 8),
          Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                'https://img.youtube.com/vi/$_videoId/mqdefault.jpg',
                width: 80, height: 45, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(width: 80, height: 45, color: const Color(0xFF1E1E1E)),
              ),
            ),
            const SizedBox(width: 10),
            Text('영상 ID: $_videoId',
                style: const TextStyle(color: Color(0xFF4FC3F7), fontSize: 12)),
          ]),
        ],
      ],
    );
  }
}
