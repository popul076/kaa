import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/app_state.dart';

// =====================================================
// 1. 홈화면 가로 슬라이더 (추천점포 아래)
// =====================================================
class YoutubeShortSlider extends StatelessWidget {
  const YoutubeShortSlider({super.key});

  @override
  Widget build(BuildContext context) {
    // videoHits 높은 순 Top3 필터
    final stores = AppData.stores
        .where((s) => s.videoId != null)
        .toList()
      ..sort((a, b) => b.videoHits.compareTo(a.videoHits));

    if (stores.isEmpty) return const SizedBox.shrink();

    final top = stores.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Row(
            children: [
              Container(
                width: 4, height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFF4FC3F7),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '점포 인기 영상',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF4FC3F7).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF4FC3F7).withOpacity(0.4)),
                ),
                child: const Text(
                  'SHORTS',
                  style: TextStyle(
                    color: Color(0xFF4FC3F7),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16),
            itemCount: top.length,
            itemBuilder: (context, i) {
              final store = top[i];
              return _YoutubeShortsCard(
                store: store,
                isLast: i == top.length - 1,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _YoutubeShortsCard extends StatelessWidget {
  final Store store;
  final bool isLast;

  const _YoutubeShortsCard({required this.store, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    final thumbUrl = 'https://img.youtube.com/vi/${store.videoId}/mqdefault.jpg';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => YoutubePlayerPage(store: store),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: EdgeInsets.only(right: isLast ? 16 : 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1B2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1E3A5F)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 썸네일 (16:9)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      thumbUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF1E3A5F),
                        child: const Icon(Icons.play_circle_outline,
                            color: Color(0xFF4FC3F7), size: 40),
                      ),
                    ),
                  ),
                  // 재생 버튼 오버레이
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow,
                            color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                  // SHORTS 배지
                  Positioned(
                    top: 6, right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Shorts',
                        style: TextStyle(color: Colors.white, fontSize: 9,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 점포명 + 조회수
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.visibility_outlined,
                          color: Color(0xFF4FC3F7), size: 12),
                      const SizedBox(width: 3),
                      Text(
                        _formatHits(store.videoHits),
                        style: const TextStyle(
                          color: Color(0xFF4FC3F7),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatHits(int hits) {
    if (hits >= 10000) return '${(hits / 10000).toStringAsFixed(1)}만';
    if (hits >= 1000) return '${(hits / 1000).toStringAsFixed(1)}천';
    return hits.toString();
  }
}

// =====================================================
// 2. 유튜브 플레이어 전체화면 페이지
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
    // 세로모드 복구
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
                    style: const TextStyle(color: Colors.white, fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 영상 (Shorts: 9:16 비율)
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
                        // 점포 정보
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
                                      fontWeight: FontWeight.bold,
                                    ),
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
                                            color: Color(0xFF4FC3F7),
                                            fontSize: 11,
                                          ),
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
                            color: Color(0xFFB0C4D8),
                            fontSize: 13,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // 점포 상세보기 버튼
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4FC3F7),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              '점포 상세보기',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
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
// 3. 점포 관리자용 유튜브 URL 입력 위젯
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
                  hintStyle: const TextStyle(color: Color(0xFF3A5570), fontSize: 13),
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  suffixIcon: _urlController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Color(0xFF8899AA), size: 18),
                          onPressed: () {
                            _urlController.clear();
                            _onUrlChanged('');
                          },
                        )
                      : null,
                ),
              ),
            ),
            // 썸네일 미리보기
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
                  style: const TextStyle(color: Color(0xFF4FC3F7), fontSize: 11),
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
