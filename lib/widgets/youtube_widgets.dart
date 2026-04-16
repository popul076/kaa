import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  ShortsData(
    videoId: 'M_ehRbGlwDQ',
    title: '차 오래 타려면 이 4가지 필수!',
    category: '차량관리',
    views: '3.2만',
  ),
  ShortsData(
    videoId: 'pL7ay-zd5Eo',
    title: '소모품 교체주기 총정리 🛠️',
    category: '정비꿀팁',
    views: '5.1만',
  ),
  ShortsData(
    videoId: 'x16Q5CObhQc',
    title: '여름철 차량관리 치트키 5가지',
    category: '여름관리',
    views: '2.7만',
  ),
  ShortsData(
    videoId: 'OI4-OdUIY8A',
    title: '엔진오일 교환 타이밍 완벽정리',
    category: '정비꿀팁',
    views: '4.8만',
  ),
  ShortsData(
    videoId: 'vl7jZcVHJTg',
    title: '여름 타이어 공기압 차종별 관리법',
    category: '안전운행',
    views: '3.9만',
  ),
  ShortsData(
    videoId: 'psNIy8wk4MQ',
    title: '모르면 손해! 계절별 차량관리법',
    category: '차량관리',
    views: '6.3만',
  ),
  ShortsData(
    videoId: 'fya_C7bfbQw',
    title: '차량 고무·쇠부품 관리 꿀팁',
    category: '정비꿀팁',
    views: '1.9만',
  ),
  ShortsData(
    videoId: 'Vs_TsMbE8CA',
    title: '여름 타이어 이러면 무조건 터짐 ⚠️',
    category: '안전운행',
    views: '8.2만',
  ),
];

// 카테고리별 색상
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

// YouTube Shorts URL 열기 (YouTube 앱 → 없으면 브라우저)
Future<void> _openYoutubeShorts(BuildContext context, ShortsData shorts) async {
  // YouTube 앱 딥링크
  final appUri = Uri.parse('vnd.youtube://shorts/${shorts.videoId}');
  // 웹 fallback
  final webUri = Uri.parse(shorts.youtubeUrl);

  try {
    if (await canLaunchUrl(appUri)) {
      await launchUrl(appUri, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  } catch (_) {
    // 모두 실패 시 그냥 웹 브라우저
    try {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('YouTube를 열 수 없습니다. YouTube 앱을 설치해주세요.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// =====================================================
// 1. 홈화면 쇼츠 슬라이더 (추천점포 아래, 빠른기능 위)
//    - 세로형 카드 (9:16 비율)
//    - 옆에 다음 카드 살짝 보임
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
                width: 4, height: 20,
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
                '유튜브 쇼츠',
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
                    Text(
                      'Shorts',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '전체보기',
                style: TextStyle(
                  color: const Color(0xFF4FC3F7).withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF4FC3F7), size: 16),
            ],
          ),
        ),

        // ── 세로형 카드 가로 슬라이더 ─────────────────
        SizedBox(
          height: 248,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(left: 16, right: 8),
            itemCount: kAutoShorts.length,
            itemBuilder: (context, i) {
              final shorts = kAutoShorts[i];
              return _VerticalShortsCard(
                shorts: shorts,
                index: i,
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ── 세로형 (9:16) 쇼츠 카드 ────────────────────────
class _VerticalShortsCard extends StatelessWidget {
  final ShortsData shorts;
  final int index;

  const _VerticalShortsCard({
    required this.shorts,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final cardW = screenW * 0.40;
    final thumbH = cardW * (16 / 9) * 0.72;

    final catColor = _categoryColor(shorts.category);

    return GestureDetector(
      onTap: () => _openYoutubeShorts(context, shorts),
      child: Container(
        width: cardW,
        margin: const EdgeInsets.only(right: 10, bottom: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF0A1628),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF1E3A5F).withOpacity(0.7)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 썸네일 ───────────────────
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: Stack(
                children: [
                  SizedBox(
                    width: cardW,
                    height: thumbH,
                    child: Image.network(
                      shorts.thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: cardW,
                        height: thumbH,
                        color: const Color(0xFF0D2040),
                        child: const Icon(
                          Icons.play_circle_outline,
                          color: Color(0xFF4FC3F7),
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                  // 그라디언트 오버레이
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withOpacity(0.6),
                          ],
                          stops: const [0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // 재생 버튼 (YouTube 앱으로 열기 안내)
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.85),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.5),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                  // 카테고리 배지
                  Positioned(
                    top: 8, left: 7,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: catColor.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        shorts.category,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Shorts 배지
                  Positioned(
                    top: 8, right: 7,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_arrow, color: Colors.white, size: 8),
                          Text(
                            'S',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 조회수
                  Positioned(
                    bottom: 6, right: 7,
                    child: Row(
                      children: [
                        const Icon(Icons.visibility, color: Colors.white70, size: 10),
                        const SizedBox(width: 2),
                        Text(
                          shorts.views,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── 제목 ────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: Text(
                shorts.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
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
// 2. 쇼츠 플레이어 페이지 (YouTube 앱/브라우저로 이동)
//    → youtube_player_flutter 제거, url_launcher 사용
// =====================================================
class ShortsPlayerPage extends StatefulWidget {
  final ShortsData shorts;
  const ShortsPlayerPage({super.key, required this.shorts});

  @override
  State<ShortsPlayerPage> createState() => _ShortsPlayerPageState();
}

class _ShortsPlayerPageState extends State<ShortsPlayerPage> {
  @override
  void initState() {
    super.initState();
    // 페이지 로드 즉시 YouTube 앱/브라우저로 이동
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openYoutubeShorts(context, widget.shorts);
    });
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _categoryColor(widget.shorts.category);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: catColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: catColor.withOpacity(0.5)),
              ),
              child: Text(
                widget.shorts.category,
                style: TextStyle(
                  color: catColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.shorts.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 썸네일
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                widget.shorts.thumbnailUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 200,
                  color: const Color(0xFF0D2040),
                  child: const Icon(Icons.play_circle_outline,
                      color: Color(0xFF4FC3F7), size: 64),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            widget.shorts.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: catColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: catColor.withOpacity(0.5)),
                ),
                child: Text(
                  widget.shorts.category,
                  style: TextStyle(color: catColor, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${widget.shorts.views} 조회',
                style: const TextStyle(color: Color(0xFF888888), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // YouTube 앱으로 열기 버튼
          GestureDetector(
            onTap: () => _openYoutubeShorts(context, widget.shorts),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF0000), Color(0xFFCC0000)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_circle_filled, color: Colors.white, size: 28),
                  SizedBox(width: 10),
                  Text(
                    'YouTube에서 재생',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'YouTube 앱 또는 브라우저에서 재생됩니다',
            style: TextStyle(color: Color(0xFF666666), fontSize: 12),
          ),
          const SizedBox(height: 40),

          // 다른 쇼츠 목록
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                '다른 쇼츠 보기',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 16),
              itemCount: kAutoShorts.length,
              itemBuilder: (context, i) {
                final s = kAutoShorts[i];
                if (s.videoId == widget.shorts.videoId) return const SizedBox.shrink();
                return GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ShortsPlayerPage(shorts: s),
                      ),
                    );
                  },
                  child: Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            s.thumbnailUrl,
                            width: 120, height: 68,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 120, height: 68,
                              color: const Color(0xFF1E1E1E),
                              child: const Icon(Icons.play_circle_outline,
                                  color: Colors.white54, size: 24),
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          s.title,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// 3. 기존 Store 연결 플레이어 (점포 상세에서 사용)
//    → url_launcher로 YouTube 앱/브라우저 열기
// =====================================================
class YoutubePlayerPage extends StatefulWidget {
  final Store store;
  const YoutubePlayerPage({super.key, required this.store});

  @override
  State<YoutubePlayerPage> createState() => _YoutubePlayerPageState();
}

class _YoutubePlayerPageState extends State<YoutubePlayerPage> {
  Future<void> _openStoreVideo() async {
    if (widget.store.videoId == null) return;
    final videoId = widget.store.videoId!;
    final appUri = Uri.parse('vnd.youtube://shorts/$videoId');
    final webUri = Uri.parse('https://www.youtube.com/shorts/$videoId');

    try {
      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      try {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('YouTube를 열 수 없습니다.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openStoreVideo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final thumbUrl = widget.store.videoId != null
        ? 'https://img.youtube.com/vi/${widget.store.videoId}/mqdefault.jpg'
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFF020810),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.store.name,
          style: const TextStyle(
              color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (thumbUrl != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  thumbUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 200,
                    color: const Color(0xFF0D2040),
                    child: const Icon(Icons.play_circle_outline,
                        color: Color(0xFF4FC3F7), size: 64),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 24),
          Text(
            widget.store.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: _openStoreVideo,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4FC3F7), Color(0xFF0288D1)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4FC3F7).withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_circle_filled, color: Colors.white, size: 28),
                  SizedBox(width: 10),
                  Text(
                    'YouTube에서 재생',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'YouTube 앱 또는 브라우저에서 재생됩니다',
            style: TextStyle(color: Color(0xFF666666), fontSize: 12),
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
      _controller.text = 'https://www.youtube.com/shorts/${widget.initialVideoId}';
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
    for (final pattern in patterns) {
      final match = pattern.firstMatch(url);
      if (match != null) return match.group(1);
    }
    if (RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(url.trim())) return url.trim();
    return null;
  }

  void _validateAndSave() {
    final input = _controller.text.trim();
    final id = _extractVideoId(input);
    if (id == null) {
      setState(() {
        _error = '유효한 YouTube Shorts URL 또는 영상 ID를 입력해주세요';
        _videoId = null;
      });
      return;
    }
    setState(() {
      _error = null;
      _videoId = id;
    });
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
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  'https://img.youtube.com/vi/$_videoId/mqdefault.jpg',
                  width: 80, height: 45,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80, height: 45,
                    color: const Color(0xFF1E1E1E),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '영상 ID: $_videoId',
                style: const TextStyle(color: Color(0xFF4FC3F7), fontSize: 12),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
