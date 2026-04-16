import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
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
}

// 실제 자동차 관련 유튜브 쇼츠 영상 목록 (실제 존재하는 쇼츠 ID)
final List<ShortsData> kAutoShorts = [
  ShortsData(
    videoId: 'M_ehRbGlwDQ', // 차 오래 타고 싶다면 이 4가지는 꼭 챙기세요
    title: '차 오래 타려면 이 4가지 필수!',
    category: '차량관리',
    views: '3.2만',
  ),
  ShortsData(
    videoId: 'pL7ay-zd5Eo', // 내 차 수명 2배! 소모품 교체주기 총정리
    title: '소모품 교체주기 총정리 🛠️',
    category: '정비꿀팁',
    views: '5.1만',
  ),
  ShortsData(
    videoId: 'x16Q5CObhQc', // 여름 차량 관리 꿀팁
    title: '여름철 차량관리 치트키 5가지',
    category: '여름관리',
    views: '2.7만',
  ),
  ShortsData(
    videoId: 'OI4-OdUIY8A', // 엔진오일 교환 타이밍 한방 정리
    title: '엔진오일 교환 타이밍 완벽정리',
    category: '정비꿀팁',
    views: '4.8만',
  ),
  ShortsData(
    videoId: 'vl7jZcVHJTg', // 여름철 타이어 공기압 관리
    title: '여름 타이어 공기압 차종별 관리법',
    category: '안전운행',
    views: '3.9만',
  ),
  ShortsData(
    videoId: 'psNIy8wk4MQ', // 겨울철 차량관리
    title: '모르면 손해! 계절별 차량관리법',
    category: '차량관리',
    views: '6.3만',
  ),
  ShortsData(
    videoId: 'fya_C7bfbQw', // 고무·쇠부품 관리
    title: '차량 고무·쇠부품 관리 꿀팁',
    category: '정비꿀팁',
    views: '1.9만',
  ),
  ShortsData(
    videoId: 'Vs_TsMbE8CA', // 여름철 타이어 공기압 주의
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
              // YouTube 로고 느낌 배지
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
        // 카드 너비를 화면의 ~42%로 설정해 3개 정도 보이게
        SizedBox(
          height: 248, // 카드 전체 높이
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
    // 카드 너비: 화면 너비의 약 40% → 옆에 다음 카드 살짝 보임
    final screenW = MediaQuery.of(context).size.width;
    final cardW = screenW * 0.40;
    // 9:16 비율에서 썸네일 높이 = cardW * (16/9) 이지만 카드 전체 높이 248에 맞춤
    final thumbH = cardW * (16 / 9) * 0.72; // 적절히 조정

    final catColor = _categoryColor(shorts.category);
    final thumbUrl = 'https://img.youtube.com/vi/${shorts.videoId}/mqdefault.jpg';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ShortsPlayerPage(shorts: shorts),
          ),
        );
      },
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
            // ── 썸네일 (세로 비율) ───────────────────
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: Stack(
                children: [
                  // 썸네일 이미지 (세로 비율)
                  SizedBox(
                    width: cardW,
                    height: thumbH,
                    child: Image.network(
                      thumbUrl,
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
                  // 어두운 그라디언트 오버레이
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
                  // 재생 버튼 (중앙)
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.7),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  // 카테고리 배지 (상단 왼쪽)
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
                  // Shorts 배지 (상단 오른쪽)
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
                  // 조회수 (하단)
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
// 2. 쇼츠 전용 플레이어 페이지
// =====================================================
class ShortsPlayerPage extends StatefulWidget {
  final ShortsData shorts;
  const ShortsPlayerPage({super.key, required this.shorts});

  @override
  State<ShortsPlayerPage> createState() => _ShortsPlayerPageState();
}

class _ShortsPlayerPageState extends State<ShortsPlayerPage> {
  late YoutubePlayerController _controller;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.shorts.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: false,
        isLive: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _onEnterFullScreen() {
    setState(() => _isFullScreen = true);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _onExitFullScreen() {
    setState(() => _isFullScreen = false);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _categoryColor(widget.shorts.category);

    return YoutubePlayerBuilder(
      onEnterFullScreen: _onEnterFullScreen,
      onExitFullScreen: _onExitFullScreen,
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.red,
        progressColors: const ProgressBarColors(
          playedColor: Colors.red,
          handleColor: Colors.white,
        ),
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: _isFullScreen
              ? null
              : AppBar(
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
            children: [
              // 세로형 플레이어 (9:16)
              AspectRatio(
                aspectRatio: 9 / 16,
                child: player,
              ),
              if (!_isFullScreen)
                Expanded(
                  child: Container(
                    color: const Color(0xFF0A0A0A),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.shorts.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.visibility_outlined,
                                color: Color(0xFF888888), size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.shorts.views} 조회',
                              style: const TextStyle(
                                color: Color(0xFF888888),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // 다른 쇼츠 보기
                        const Text(
                          '다른 쇼츠 보기',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: ListView.builder(
                            itemCount: kAutoShorts.length,
                            itemBuilder: (context, i) {
                              final s = kAutoShorts[i];
                              if (s.videoId == widget.shorts.videoId) {
                                return const SizedBox.shrink();
                              }
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
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          'https://img.youtube.com/vi/${s.videoId}/mqdefault.jpg',
                                          width: 80, height: 50,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            width: 80, height: 50,
                                            color: const Color(0xFF1E1E1E),
                                            child: const Icon(Icons.play_circle_outline,
                                                color: Colors.white54, size: 24),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              s.title,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              '${s.views} 조회',
                                              style: const TextStyle(
                                                color: Color(0xFF888888),
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
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
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// =====================================================
// 3. 기존 Store 연결 플레이어 (점포 상세에서 사용)
// =====================================================
class YoutubePlayerPage extends StatefulWidget {
  final Store store;
  const YoutubePlayerPage({super.key, required this.store});

  @override
  State<YoutubePlayerPage> createState() => _YoutubePlayerPageState();
}

class _YoutubePlayerPageState extends State<YoutubePlayerPage> {
  late YoutubePlayerController _controller;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.store.videoId!,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _onEnterFullScreen() {
    setState(() => _isFullScreen = true);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _onExitFullScreen() {
    setState(() => _isFullScreen = false);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      onEnterFullScreen: _onEnterFullScreen,
      onExitFullScreen: _onExitFullScreen,
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: const Color(0xFF4FC3F7),
        progressColors: const ProgressBarColors(
          playedColor: Color(0xFF4FC3F7),
          handleColor: Colors.white,
        ),
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: const Color(0xFF020810),
          appBar: _isFullScreen
              ? null
              : AppBar(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 9 / 16,
                child: player,
              ),
              if (!_isFullScreen) ...[
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                widget.store.image,
                                width: 56, height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 56, height: 56,
                                  color: const Color(0xFF1E3A5F),
                                  child: const Icon(Icons.store,
                                      color: Color(0xFF4FC3F7)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.store.name,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF4FC3F7).withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(
                                              color: const Color(0xFF4FC3F7).withOpacity(0.4)),
                                        ),
                                        child: Text(
                                          widget.store.badge,
                                          style: const TextStyle(
                                              color: Color(0xFF4FC3F7), fontSize: 11),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(Icons.visibility_outlined,
                                          color: Color(0xFF8899AA), size: 13),
                                      const SizedBox(width: 3),
                                      Text(
                                        '${widget.store.videoHits}회',
                                        style: const TextStyle(
                                            color: Color(0xFF8899AA), fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: Color(0xFF1E3A5F)),
                        const SizedBox(height: 12),
                        Text(
                          widget.store.desc,
                          style: const TextStyle(
                              color: Color(0xFFB0C4D8), fontSize: 13, height: 1.6),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4FC3F7),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('점포 상세보기',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// =====================================================
// 4. 점포 관리자용 유튜브 URL 입력 위젯
// =====================================================
class YoutubeUrlInputWidget extends StatefulWidget {
  final String? initialUrl;
  final ValueChanged<String?> onChanged;

  const YoutubeUrlInputWidget({
    super.key,
    this.initialUrl,
    required this.onChanged,
  });

  @override
  State<YoutubeUrlInputWidget> createState() => _YoutubeUrlInputWidgetState();
}

class _YoutubeUrlInputWidgetState extends State<YoutubeUrlInputWidget> {
  late TextEditingController _urlController;
  String? _previewVideoId;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.initialUrl ?? '');
    _previewVideoId = extractYoutubeVideoId(widget.initialUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _onUrlChanged(String val) {
    final id = extractYoutubeVideoId(val);
    setState(() => _previewVideoId = id);
    widget.onChanged(val.isEmpty ? null : val);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '유튜브 쇼츠 URL',
          style: TextStyle(color: Color(0xFF8899AA), fontSize: 13),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _urlController,
                onChanged: _onUrlChanged,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'https://youtube.com/shorts/...',
                  hintStyle:
                      const TextStyle(color: Color(0xFF3A5570), fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xFF0D1B2A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF1E3A5F)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF1E3A5F)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF4FC3F7)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  suffixIcon: _urlController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear,
                              color: Color(0xFF8899AA), size: 18),
                          onPressed: () {
                            _urlController.clear();
                            _onUrlChanged('');
                          },
                        )
                      : null,
                ),
              ),
            ),
            if (_previewVideoId != null) ...[
              const SizedBox(width: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    Image.network(
                      'https://img.youtube.com/vi/$_previewVideoId/mqdefault.jpg',
                      width: 80, height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 80, height: 50,
                        color: const Color(0xFF1E3A5F),
                        child: const Icon(Icons.broken_image,
                            color: Color(0xFF4FC3F7), size: 20),
                      ),
                    ),
                    Positioned.fill(
                      child: Center(
                        child: Container(
                          width: 24, height: 24,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.play_arrow,
                              color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        if (_previewVideoId != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF4FC3F7), size: 14),
                const SizedBox(width: 4),
                Text(
                  'ID: $_previewVideoId',
                  style: const TextStyle(
                      color: Color(0xFF4FC3F7), fontSize: 11),
                ),
              ],
            ),
          )
        else if (_urlController.text.isNotEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 14),
                SizedBox(width: 4),
                Text(
                  '유효하지 않은 유튜브 URL입니다',
                  style: TextStyle(color: Colors.red, fontSize: 11),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
