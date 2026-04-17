import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/app_state.dart';

// =====================================================
// 실제 자동차 관련 유튜브 정식 영상 데이터 (16:9)
// =====================================================
class VideoData {
  final String videoId;
  final String title;
  final String category;
  final String duration;

  const VideoData({
    required this.videoId,
    required this.title,
    required this.category,
    required this.duration,
  });

  String get youtubeUrl => 'https://www.youtube.com/watch?v=$videoId';
  String get embedUrl =>
      'https://www.youtube.com/embed/$videoId?autoplay=1&playsinline=1&rel=0&modestbranding=1';
  String get thumbnailUrl => 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
}

// 실제 자동차 유튜브 정식 영상 목록
final List<VideoData> kAutoVideos = [
  VideoData(
    videoId: 'R0KGwmANaBw',
    title: '2025년 차량 관리 꿀팁 완벽 정리!!',
    category: '차량관리',
    duration: '12:34',
  ),
  VideoData(
    videoId: 'mM32L_q-rAI',
    title: '차량관리 복잡할 것 없습니다. 영상 하나로 끝!',
    category: '차량관리',
    duration: '15:20',
  ),
  VideoData(
    videoId: '2qqVWiBhhWc',
    title: '정비사도 깜짝놀란 초간단 차량 관리 방법 5가지',
    category: '차량관리',
    duration: '10:45',
  ),
  VideoData(
    videoId: 'R4x_0wykUwM',
    title: '엔진오일 교환주기 정확하게 알고 하세요!',
    category: '엔진/소모품',
    duration: '9:18',
  ),
  VideoData(
    videoId: 'FlitOPLibWQ',
    title: '운전 30년도 모르는 차량관리 꿀팁',
    category: '엔진/소모품',
    duration: '8:52',
  ),
  VideoData(
    videoId: 'J3YPWAx1g9Y',
    title: '겨울에 반드시 알아야할 차량 관리 꿀팁 5가지!',
    category: '계절관리',
    duration: '11:03',
  ),
  VideoData(
    videoId: 'Q1ZMv8BifEI',
    title: '봄맞이 차량 관리법 — 염화칼슘 제거부터 점검까지',
    category: '계절관리',
    duration: '7:40',
  ),
  VideoData(
    videoId: '3un7Cc3a_fM',
    title: '초보운전 필수 차량관리! 엔진오일·타이어·정비소',
    category: '안전운행',
    duration: '13:27',
  ),
];

// ── 카테고리 색상 ──────────────────────────────────
Color _categoryColor(String cat) {
  switch (cat) {
    case '차량관리':    return const Color(0xFF4FC3F7);
    case '엔진/소모품': return const Color(0xFFFFB74D);
    case '계절관리':   return const Color(0xFF81C784);
    case '안전운행':   return const Color(0xFFCE93D8);
    default:          return const Color(0xFF90A4AE);
  }
}

// ── 유튜브 앱 딥링크 (크게 보기용) ────────────────
Future<void> _openYoutubeDeeplink(String videoId) async {
  final appUri = Uri.parse('vnd.youtube://$videoId');
  final webUri = Uri.parse('https://www.youtube.com/watch?v=$videoId');
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
// 1. 홈화면 영상 슬라이더 — "점포 유튜브"
//    카드 탭 → VideoPlayerPage (앱 내 WebView 재생)
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
                '점포 유튜브',
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
                    Text('YouTube',
                        style: TextStyle(color: Colors.white, fontSize: 10,
                            fontWeight: FontWeight.bold)),
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

        // ── 가로형 16:9 카드 슬라이더 ────────────────
        SizedBox(
          height: 230,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(left: 16, right: 8),
            itemCount: kAutoVideos.length,
            itemBuilder: (context, i) =>
                _VideoCard(video: kAutoVideos[i]),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ── 가로형 영상 카드 (16:9 썸네일) ───────────────────
class _VideoCard extends StatelessWidget {
  final VideoData video;
  const _VideoCard({required this.video});

  @override
  Widget build(BuildContext context) {
    final cardW  = MediaQuery.of(context).size.width * 0.72;
    final thumbH = cardW * 9 / 16;
    final cc     = _categoryColor(video.category);

    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => VideoPlayerPage(video: video))),
      child: Container(
        width: cardW,
        margin: const EdgeInsets.only(right: 12, bottom: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF0A1628),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF1E3A5F).withOpacity(0.7)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.4),
                blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 16:9 썸네일 ───────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: Stack(children: [
                SizedBox(
                  width: cardW, height: thumbH,
                  child: Image.network(video.thumbnailUrl, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF0D2040),
                        child: const Center(child: Icon(
                            Icons.play_circle_outline,
                            color: Color(0xFF4FC3F7), size: 48)),
                      )),
                ),
                // 그라디언트
                Positioned.fill(child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                    ),
                  ),
                )),
                // 재생 버튼
                Positioned.fill(child: Center(
                  child: Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.85), width: 2),
                    ),
                    child: const Icon(Icons.play_arrow_rounded,
                        color: Colors.white, size: 30),
                  ),
                )),
                // 카테고리 배지
                Positioned(top: 8, left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: cc.withOpacity(0.88),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(video.category,
                        style: const TextStyle(color: Colors.white,
                            fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
                // 영상 길이
                Positioned(bottom: 6, right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(4)),
                    child: Text(video.duration,
                        style: const TextStyle(color: Colors.white,
                            fontSize: 10, fontWeight: FontWeight.w600)),
                  ),
                ),
              ]),
            ),
            // ── 제목 + YT 버튼 ────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(video.title,
                        style: const TextStyle(color: Colors.white,
                            fontSize: 12, fontWeight: FontWeight.w600,
                            height: 1.35),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => _openYoutubeDeeplink(video.videoId),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.red.withOpacity(0.5)),
                      ),
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.open_in_new, color: Colors.red, size: 10),
                        SizedBox(width: 3),
                        Text('YT', style: TextStyle(color: Colors.red,
                            fontSize: 10, fontWeight: FontWeight.bold)),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// 2. 앱 내 영상 재생 페이지 — VideoPlayerPage
//    flutter_inappwebview 로 YouTube embed URL 직접 로드
//    → 실제 크롬 엔진 사용 → 버퍼링 없이 재생
//    "유튜브에서 크게 보기" → 유튜브 앱 딥링크
// =====================================================
class VideoPlayerPage extends StatefulWidget {
  final VideoData video;
  const VideoPlayerPage({super.key, required this.video});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoData _current;
  InAppWebViewController? _webCtrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _current = widget.video;
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  // 다른 영상으로 전환
  void _switchTo(VideoData v) {
    setState(() {
      _current = v;
      _isLoading = true;
    });
    _webCtrl?.loadUrl(
      urlRequest: URLRequest(url: WebUri(_current.embedUrl)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cc = _categoryColor(_current.category);
    // 16:9 플레이어 높이 계산
    final playerW = MediaQuery.of(context).size.width;
    final playerH = playerW * 9 / 16;

    return Scaffold(
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
              color: cc.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: cc.withOpacity(0.5)),
            ),
            child: Text(_current.category,
                style: TextStyle(color: cc, fontSize: 11,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(_current.title,
                style: const TextStyle(color: Colors.white, fontSize: 12,
                    fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis),
          ),
        ]),
        actions: [
          TextButton.icon(
            onPressed: () => _openYoutubeDeeplink(_current.videoId),
            icon: const Icon(Icons.open_in_new, color: Colors.red, size: 15),
            label: const Text('크게 보기',
                style: TextStyle(color: Colors.red, fontSize: 12)),
          ),
        ],
      ),
      body: Column(children: [
        // ── WebView 플레이어 (16:9) ────────────────────
        SizedBox(
          width: playerW,
          height: playerH,
          child: Stack(children: [
            // InAppWebView — 실제 크롬 엔진으로 YouTube embed 로드
            InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri(_current.embedUrl),
              ),
              initialSettings: InAppWebViewSettings(
                mediaPlaybackRequiresUserGesture: false, // 자동재생 허용
                allowsInlineMediaPlayback: true,         // 인라인 재생
                javaScriptEnabled: true,
                useWideViewPort: true,
                loadWithOverviewMode: true,
                supportZoom: false,
                builtInZoomControls: false,
                displayZoomControls: false,
                userAgent:
                    'Mozilla/5.0 (Linux; Android 12; Pixel 6) '
                    'AppleWebKit/537.36 (KHTML, like Gecko) '
                    'Chrome/120.0.0.0 Mobile Safari/537.36',
              ),
              onWebViewCreated: (ctrl) => _webCtrl = ctrl,
              onLoadStart: (_, __) => setState(() => _isLoading = true),
              onLoadStop:  (_, __) => setState(() => _isLoading = false),
            ),
            // 로딩 인디케이터
            if (_isLoading)
              Container(
                color: Colors.black,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.red),
                      SizedBox(height: 12),
                      Text('영상 로딩 중...',
                          style: TextStyle(color: Colors.white60, fontSize: 13)),
                    ],
                  ),
                ),
              ),
          ]),
        ),

        // ── 영상 정보 바 ──────────────────────────────
        Container(
          color: const Color(0xFF0D0D0D),
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: cc.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: cc.withOpacity(0.4)),
              ),
              child: Text(_current.category,
                  style: TextStyle(color: cc, fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
            Text(_current.duration,
                style: const TextStyle(color: Color(0xFF888888), fontSize: 11)),
            const Spacer(),
            // 유튜브 앱으로 크게 보기
            GestureDetector(
              onTap: () => _openYoutubeDeeplink(_current.videoId),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFFFF0000), Color(0xFFCC0000)]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.open_in_new, color: Colors.white, size: 12),
                  SizedBox(width: 5),
                  Text('유튜브에서 크게 보기',
                      style: TextStyle(color: Colors.white, fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ]),
              ),
            ),
          ]),
        ),

        const Divider(color: Color(0xFF1A1A1A), height: 1),

        // ── 현재 영상 제목 ────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 2),
          child: Text(_current.title,
              style: const TextStyle(color: Colors.white, fontSize: 13,
                  fontWeight: FontWeight.bold, height: 1.4),
              maxLines: 2),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(14, 2, 14, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '앱 내 재생 중  •  전체화면은 "유튜브에서 크게 보기" 탭',
              style: TextStyle(color: Color(0xFF555555), fontSize: 10),
            ),
          ),
        ),

        const Divider(color: Color(0xFF1A1A1A), height: 1),

        // ── 다른 영상 목록 ────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('다른 영상',
                style: TextStyle(color: cc, fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: kAutoVideos.length,
            itemBuilder: (context, i) {
              final v = kAutoVideos[i];
              if (v.videoId == _current.videoId) return const SizedBox.shrink();
              final vc = _categoryColor(v.category);
              final isSelected = v.videoId == _current.videoId;
              return GestureDetector(
                onTap: () => _switchTo(v),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF1A2535)
                        : const Color(0xFF0D0D0D),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? vc.withOpacity(0.5)
                          : const Color(0xFF1A1A1A),
                    ),
                  ),
                  child: Row(children: [
                    // 썸네일 (16:9)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Stack(children: [
                        Image.network(v.thumbnailUrl,
                            width: 100, height: 56, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 100, height: 56,
                              color: const Color(0xFF1A1A1A),
                              child: const Icon(Icons.play_circle_outline,
                                  color: Colors.white38, size: 24),
                            )),
                        Positioned(bottom: 3, right: 3,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 1),
                            color: Colors.black.withOpacity(0.75),
                            child: Text(v.duration,
                                style: const TextStyle(color: Colors.white,
                                    fontSize: 9, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(v.title,
                              style: const TextStyle(color: Colors.white,
                                  fontSize: 11, fontWeight: FontWeight.w600,
                                  height: 1.35),
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: vc.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(v.category,
                                style: TextStyle(color: vc,
                                    fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.play_circle_outline,
                        color: isSelected ? vc : const Color(0xFF333333),
                        size: 22),
                  ]),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}

// =====================================================
// 3. 점포/명소 유튜브 플레이어 — YoutubePlayerPage
//    InAppWebView 로 embed 재생 + 유튜브 앱 딥링크
// =====================================================
class YoutubePlayerPage extends StatefulWidget {
  final Store store;
  const YoutubePlayerPage({super.key, required this.store});

  @override
  State<YoutubePlayerPage> createState() => _YoutubePlayerPageState();
}

class _YoutubePlayerPageState extends State<YoutubePlayerPage> {
  InAppWebViewController? _webCtrl;
  bool _isLoading = true;

  String get _embedUrl {
    final vid = widget.store.videoId!;
    return 'https://www.youtube.com/embed/$vid?autoplay=0&playsinline=1&rel=0&modestbranding=1';
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.store.videoId == null) {
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

    final playerW = MediaQuery.of(context).size.width;
    final playerH = playerW * 9 / 16;

    return Scaffold(
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
          // ── WebView 플레이어 (16:9) ────────────────
          SizedBox(
            width: playerW,
            height: playerH,
            child: Stack(children: [
              InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(_embedUrl)),
                initialSettings: InAppWebViewSettings(
                  mediaPlaybackRequiresUserGesture: false,
                  allowsInlineMediaPlayback: true,
                  javaScriptEnabled: true,
                  useWideViewPort: true,
                  loadWithOverviewMode: true,
                  supportZoom: false,
                  userAgent:
                      'Mozilla/5.0 (Linux; Android 12; Pixel 6) '
                      'AppleWebKit/537.36 (KHTML, like Gecko) '
                      'Chrome/120.0.0.0 Mobile Safari/537.36',
                ),
                onWebViewCreated: (ctrl) => _webCtrl = ctrl,
                onLoadStart: (_, __) => setState(() => _isLoading = true),
                onLoadStop:  (_, __) => setState(() => _isLoading = false),
              ),
              if (_isLoading)
                Container(
                  color: Colors.black,
                  child: const Center(
                    child: CircularProgressIndicator(color: Color(0xFF4FC3F7)),
                  ),
                ),
            ]),
          ),

          // ── 점포명 + 유튜브 앱 버튼 ──────────────
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
              GestureDetector(
                onTap: () => _openYoutubeDeeplink(widget.store.videoId!),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFFFF0000), Color(0xFFCC0000)]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.open_in_new, color: Colors.white, size: 13),
                    SizedBox(width: 5),
                    Text('유튜브에서 크게 보기',
                        style: TextStyle(color: Colors.white,
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ]),
                ),
              ),
            ]),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              '💡 재생 버튼으로 앱 내에서 감상하거나,\n   "유튜브에서 크게 보기"로 전체화면 시청하세요.',
              style: TextStyle(color: Color(0xFF5A7A9A), fontSize: 12, height: 1.5),
            ),
          ),
        ],
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
      _controller.text = 'https://www.youtube.com/watch?v=${widget.initialVideoId}';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _extractVideoId(String url) {
    final patterns = [
      RegExp(r'youtube\.com/watch\?v=([a-zA-Z0-9_-]{11})'),
      RegExp(r'youtu\.be/([a-zA-Z0-9_-]{11})'),
      RegExp(r'youtube\.com/shorts/([a-zA-Z0-9_-]{11})'),
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
      setState(() { _error = '유효한 YouTube URL 또는 영상 ID를 입력해주세요'; _videoId = null; });
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
            hintText: 'https://www.youtube.com/watch?v=...',
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
