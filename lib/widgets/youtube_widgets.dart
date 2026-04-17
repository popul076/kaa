import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  String get thumbnailUrl => 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
}

// 실제 자동차 유튜브 정식 영상 목록
final List<VideoData> kAutoVideos = [
  VideoData(videoId: 'R0KGwmANaBw', title: '2025년 차량 관리 꿀팁 완벽 정리!!',            category: '차량관리',    duration: '12:34'),
  VideoData(videoId: 'mM32L_q-rAI', title: '차량관리 복잡할 것 없습니다. 영상 하나로 끝!', category: '차량관리',    duration: '15:20'),
  VideoData(videoId: '2qqVWiBhhWc', title: '정비사도 깜짝놀란 초간단 차량 관리 5가지',     category: '차량관리',    duration: '10:45'),
  VideoData(videoId: 'R4x_0wykUwM', title: '엔진오일 교환주기 정확하게 알고 하세요!',      category: '엔진/소모품', duration: '9:18'),
  VideoData(videoId: 'FlitOPLibWQ', title: '운전 30년도 모르는 차량관리 꿀팁',             category: '엔진/소모품', duration: '8:52'),
  VideoData(videoId: 'J3YPWAx1g9Y', title: '겨울에 반드시 알아야할 차량관리 꿀팁 5가지!', category: '계절관리',    duration: '11:03'),
  VideoData(videoId: 'Q1ZMv8BifEI', title: '봄맞이 차량관리법 — 염화칼슘 제거부터',       category: '계절관리',    duration: '7:40'),
  VideoData(videoId: '3un7Cc3a_fM', title: '초보운전 필수 차량관리! 엔진오일·타이어',      category: '안전운행',    duration: '13:27'),
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

// ── 유튜브 앱 딥링크 열기 ─────────────────────────
Future<void> _openYoutube(String videoId) async {
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
//    카드 탭 → VideoDetailPage (앱 내 상세 페이지)
//    "재생하기" 버튼 → 유튜브 앱 실행
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
          child: Row(children: [
            Container(
              width: 4, height: 22,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Color(0xFF4FC3F7), Color(0xFF9B7CFF)],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 9),
            const Text('점포 유튜브',
                style: TextStyle(color: Colors.white, fontSize: 17,
                    fontWeight: FontWeight.bold, letterSpacing: -0.3)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(color: Colors.red,
                  borderRadius: BorderRadius.circular(6)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.play_arrow, color: Colors.white, size: 12),
                SizedBox(width: 2),
                Text('YouTube', style: TextStyle(color: Colors.white,
                    fontSize: 10, fontWeight: FontWeight.bold)),
              ]),
            ),
            const Spacer(),
            Text('전체보기',
                style: TextStyle(color: const Color(0xFF4FC3F7).withOpacity(0.8),
                    fontSize: 12, fontWeight: FontWeight.w500)),
            const Icon(Icons.chevron_right, color: Color(0xFF4FC3F7), size: 16),
          ]),
        ),

        // ── 가로형 16:9 카드 슬라이더 ────────────────
        SizedBox(
          height: 230,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(left: 16, right: 8),
            itemCount: kAutoVideos.length,
            itemBuilder: (context, i) => _VideoCard(video: kAutoVideos[i]),
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
      // 카드 탭 → 상세 페이지 (앱 내)
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => VideoDetailPage(video: video))),
      child: Container(
        width: cardW,
        margin: const EdgeInsets.only(right: 12, bottom: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF0A1628),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF1E3A5F).withOpacity(0.7)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4),
              blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── 16:9 썸네일 ───────────────────────────
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: Stack(children: [
              SizedBox(
                width: cardW, height: thumbH,
                child: Image.network(video.thumbnailUrl, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFF0D2040),
                      child: const Center(child: Icon(Icons.play_circle_outline,
                          color: Color(0xFF4FC3F7), size: 48)),
                    )),
              ),
              // 하단 그라디언트
              Positioned.fill(child: Container(
                decoration: BoxDecoration(gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                )),
              )),
              // 중앙 재생 버튼
              Positioned.fill(child: Center(child: Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.85), width: 2),
                ),
                child: const Icon(Icons.play_arrow_rounded,
                    color: Colors.white, size: 30),
              ))),
              // 카테고리 배지
              Positioned(top: 8, left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(color: cc.withOpacity(0.88),
                      borderRadius: BorderRadius.circular(6)),
                  child: Text(video.category,
                      style: const TextStyle(color: Colors.white,
                          fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
              // 영상 길이
              Positioned(bottom: 6, right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(4)),
                  child: Text(video.duration,
                      style: const TextStyle(color: Colors.white,
                          fontSize: 10, fontWeight: FontWeight.w600)),
                ),
              ),
            ]),
          ),
          // ── 제목 ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            child: Text(video.title,
                style: const TextStyle(color: Colors.white, fontSize: 12,
                    fontWeight: FontWeight.w600, height: 1.35),
                maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
        ]),
      ),
    );
  }
}

// =====================================================
// 2. 앱 내 영상 상세 페이지 — VideoDetailPage
//    - 썸네일 크게 표시
//    - "▶ 유튜브에서 재생" 버튼 → 유튜브 앱 실행
//    - 뒤로가기 → 우리 앱으로 복귀
//    - 하단 다른 영상 목록
// =====================================================
class VideoDetailPage extends StatefulWidget {
  final VideoData video;
  const VideoDetailPage({super.key, required this.video});

  @override
  State<VideoDetailPage> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  late VideoData _current;

  @override
  void initState() {
    super.initState();
    _current = widget.video;
  }

  void _switchTo(VideoData v) => setState(() => _current = v);

  @override
  Widget build(BuildContext context) {
    final cc     = _categoryColor(_current.category);
    final screenW = MediaQuery.of(context).size.width;
    final thumbH  = screenW * 9 / 16; // 16:9 비율

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
      ),
      body: Column(children: [
        // ── 썸네일 + 재생 버튼 영역 ───────────────────
        GestureDetector(
          onTap: () => _openYoutube(_current.videoId),
          child: Stack(children: [
            // 썸네일 (16:9)
            SizedBox(
              width: screenW, height: thumbH,
              child: Image.network(_current.thumbnailUrl, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFF0D1020),
                    child: const Center(child: Icon(Icons.image_not_supported,
                        color: Colors.white24, size: 48)),
                  )),
            ),
            // 어두운 오버레이
            Positioned.fill(child: Container(color: Colors.black.withOpacity(0.35))),
            // 중앙 대형 재생 버튼
            Positioned.fill(child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(
                        color: Colors.red.withOpacity(0.5),
                        blurRadius: 20, spreadRadius: 4)],
                  ),
                  child: const Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: 44),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('▶  유튜브에서 재생',
                      style: TextStyle(color: Colors.white, fontSize: 14,
                          fontWeight: FontWeight.bold, letterSpacing: 0.3)),
                ),
              ]),
            )),
            // 우상단 유튜브 로고
            Positioned(top: 10, right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.play_arrow, color: Colors.white, size: 14),
                  SizedBox(width: 3),
                  Text('YouTube', style: TextStyle(color: Colors.white,
                      fontSize: 11, fontWeight: FontWeight.bold)),
                ]),
              ),
            ),
          ]),
        ),

        // ── 영상 정보 + 재생 버튼 ─────────────────────
        Container(
          color: const Color(0xFF0D0D0D),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // 제목
            Text(_current.title,
                style: const TextStyle(color: Colors.white, fontSize: 15,
                    fontWeight: FontWeight.bold, height: 1.4)),
            const SizedBox(height: 10),
            Row(children: [
              // 카테고리 + 길이
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
              Icon(Icons.access_time, color: Colors.white38, size: 13),
              const SizedBox(width: 3),
              Text(_current.duration,
                  style: const TextStyle(color: Colors.white54, fontSize: 12)),
              const Spacer(),
              // 유튜브로 재생 버튼
              GestureDetector(
                onTap: () => _openYoutube(_current.videoId),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFFFF0000), Color(0xFFCC0000)]),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.3),
                        blurRadius: 8, offset: const Offset(0, 3))],
                  ),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.play_circle_filled, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text('유튜브에서 재생',
                        style: TextStyle(color: Colors.white, fontSize: 13,
                            fontWeight: FontWeight.bold)),
                  ]),
                ),
              ),
            ]),
          ]),
        ),

        // ── 안내 메시지 ───────────────────────────────
        Container(
          width: double.infinity,
          color: const Color(0xFF080808),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(children: [
            const Icon(Icons.info_outline, color: Color(0xFF444444), size: 14),
            const SizedBox(width: 6),
            Expanded(child: Text(
              '썸네일을 탭하거나 "유튜브에서 재생"을 누르면 유튜브 앱으로 이동합니다. 뒤로가기 시 앱으로 돌아옵니다.',
              style: const TextStyle(color: Color(0xFF444444), fontSize: 10, height: 1.4),
            )),
          ]),
        ),

        const Divider(color: Color(0xFF1A1A1A), height: 1),

        // ── 다른 영상 목록 ────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('다른 영상', style: TextStyle(color: cc, fontSize: 12,
                fontWeight: FontWeight.bold)),
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: kAutoVideos.length,
            itemBuilder: (context, i) {
              final v  = kAutoVideos[i];
              final vc = _categoryColor(v.category);
              final isCurrent = v.videoId == _current.videoId;
              return GestureDetector(
                onTap: () => isCurrent ? null : _switchTo(v),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? const Color(0xFF1A2535)
                        : const Color(0xFF0D0D0D),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isCurrent
                          ? vc.withOpacity(0.6)
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
                        // 재생 아이콘 오버레이
                        Positioned.fill(child: Center(child: Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? Colors.red.withOpacity(0.85)
                                : Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isCurrent ? Icons.pause : Icons.play_arrow,
                            color: Colors.white, size: 16,
                          ),
                        ))),
                        // 영상 길이
                        Positioned(bottom: 3, right: 3,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            color: Colors.black.withOpacity(0.75),
                            child: Text(v.duration,
                                style: const TextStyle(color: Colors.white,
                                    fontSize: 9, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(v.title,
                            style: TextStyle(
                              color: isCurrent ? Colors.white : Colors.white70,
                              fontSize: 11, fontWeight: FontWeight.w600, height: 1.35,
                            ),
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: vc.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(v.category,
                              style: TextStyle(color: vc, fontSize: 9,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    )),
                    if (isCurrent)
                      Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Text('재생중', style: TextStyle(color: vc,
                            fontSize: 9, fontWeight: FontWeight.bold)),
                      )
                    else
                      const Icon(Icons.play_circle_outline,
                          color: Color(0xFF333333), size: 20),
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
//    썸네일 표시 + 유튜브 앱 연동
// =====================================================
class YoutubePlayerPage extends StatelessWidget {
  final Store store;
  const YoutubePlayerPage({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    if (store.videoId == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF020810),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0D1B2A),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(store.name,
              style: const TextStyle(color: Colors.white, fontSize: 15,
                  fontWeight: FontWeight.bold)),
        ),
        body: const Center(child: Text('등록된 영상이 없습니다.',
            style: TextStyle(color: Colors.white60))),
      );
    }

    final screenW = MediaQuery.of(context).size.width;
    final thumbH  = screenW * 9 / 16;
    final thumbUrl = 'https://img.youtube.com/vi/${store.videoId}/hqdefault.jpg';

    return Scaffold(
      backgroundColor: const Color(0xFF020810),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(store.name,
            style: const TextStyle(color: Colors.white, fontSize: 15,
                fontWeight: FontWeight.bold)),
        actions: [
          TextButton.icon(
            onPressed: () => _openYoutube(store.videoId!),
            icon: const Icon(Icons.open_in_new, color: Color(0xFF4FC3F7), size: 16),
            label: const Text('유튜브 앱',
                style: TextStyle(color: Color(0xFF4FC3F7), fontSize: 12)),
          ),
        ],
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── 썸네일 + 재생 버튼 ────────────────────────
        GestureDetector(
          onTap: () => _openYoutube(store.videoId!),
          child: Stack(children: [
            SizedBox(
              width: screenW, height: thumbH,
              child: Image.network(thumbUrl, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFF0D1B2A),
                    child: const Center(child: Icon(Icons.videocam_off,
                        color: Colors.white24, size: 48)),
                  )),
            ),
            Positioned.fill(child: Container(color: Colors.black.withOpacity(0.3))),
            Positioned.fill(child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 68, height: 68,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.5),
                        blurRadius: 18, spreadRadius: 3)],
                  ),
                  child: const Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: 42),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('▶  유튜브에서 재생',
                      style: TextStyle(color: Colors.white, fontSize: 13,
                          fontWeight: FontWeight.bold)),
                ),
              ]),
            )),
          ]),
        ),

        // ── 점포명 + 재생 버튼 ────────────────────────
        Container(
          color: const Color(0xFF0D1B2A),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            const Icon(Icons.store, color: Color(0xFF4FC3F7), size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(store.name,
                  style: const TextStyle(color: Colors.white, fontSize: 14,
                      fontWeight: FontWeight.bold)),
            ),
            GestureDetector(
              onTap: () => _openYoutube(store.videoId!),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFFFF0000), Color(0xFFCC0000)]),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.3),
                      blurRadius: 8, offset: const Offset(0, 3))],
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.play_circle_filled, color: Colors.white, size: 15),
                  SizedBox(width: 6),
                  Text('유튜브에서 재생',
                      style: TextStyle(color: Colors.white, fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ]),
              ),
            ),
          ]),
        ),

        // ── 안내 텍스트 ───────────────────────────────
        Container(
          width: double.infinity,
          color: const Color(0xFF080C16),
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Row(children: [
            const Icon(Icons.info_outline, color: Color(0xFF3A5A7A), size: 14),
            const SizedBox(width: 6),
            Expanded(child: Text(
              '유튜브에서 재생 후 뒤로가기를 누르면 앱으로 돌아옵니다.',
              style: const TextStyle(color: Color(0xFF3A5A7A), fontSize: 11, height: 1.4),
            )),
          ]),
        ),
      ]),
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

// =====================================================
// 5. 점포/명소 상세 페이지용 유튜브 섹션
//    - store.youtubeUrl 있으면 표시, 없으면 숨김
//    - 작은 16:9 썸네일 인라인 표시
//    - 탭 → YoutubePlayerPage (앱 내 상세)
//    - "유튜브에서 재생" 버튼 → 유튜브 앱 딥링크
// =====================================================
class StoreVideoSection extends StatelessWidget {
  final Store store;
  const StoreVideoSection({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final vid = store.videoId;
    if (vid == null || vid.isEmpty) return const SizedBox.shrink();

    final thumbUrl  = 'https://img.youtube.com/vi/$vid/hqdefault.jpg';
    final cardW     = MediaQuery.of(context).size.width - 32; // 양쪽 마진 16씩
    final thumbH    = cardW * 9 / 16;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1628),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E3A5F)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── 섹션 헤더 ──────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
          child: Row(children: [
            Container(
              width: 4, height: 18,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Color(0xFFFF0000), Color(0xFFCC0000)],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            const Text('점포 유튜브 영상',
              style: TextStyle(color: Colors.white, fontSize: 14,
                  fontWeight: FontWeight.w800, letterSpacing: -0.3)),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.play_arrow, color: Colors.white, size: 10),
                SizedBox(width: 2),
                Text('YouTube', style: TextStyle(color: Colors.white,
                    fontSize: 9, fontWeight: FontWeight.bold)),
              ]),
            ),
            const Spacer(),
            if (store.videoHits > 0)
              Text('👁 ${store.videoHits}',
                style: const TextStyle(color: Color(0xFF4FC3F7),
                    fontSize: 11, fontWeight: FontWeight.w600)),
          ]),
        ),

        // ── 썸네일 (인라인 소형 플레이어) ──────────
        GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => YoutubePlayerPage(store: store))),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(children: [
                // 썸네일
                SizedBox(
                  width: cardW - 28,
                  height: thumbH,
                  child: Image.network(thumbUrl, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFF0D2040),
                      child: const Center(child: Icon(Icons.videocam_off,
                          color: Colors.white24, size: 48)),
                    )),
                ),
                // 어두운 오버레이
                Positioned.fill(child: Container(
                  decoration: BoxDecoration(gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.55)],
                  )),
                )),
                // 중앙 재생 버튼
                Positioned.fill(child: Center(child: Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(
                        color: Colors.red.withOpacity(0.4),
                        blurRadius: 14, spreadRadius: 2)],
                  ),
                  child: const Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: 34),
                ))),
                // YouTube 배지
                Positioned(top: 8, right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.play_circle_filled,
                          color: Colors.red, size: 12),
                      SizedBox(width: 3),
                      Text('YouTube', style: TextStyle(color: Colors.white,
                          fontSize: 9, fontWeight: FontWeight.bold)),
                    ]),
                  ),
                ),
                // 하단 "탭하여 보기" 힌트
                Positioned(bottom: 8, left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('탭하여 영상 보기',
                      style: TextStyle(color: Colors.white70,
                          fontSize: 10, fontWeight: FontWeight.w500)),
                  ),
                ),
              ]),
            ),
          ),
        ),

        // ── 하단 액션 버튼 ─────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
          child: Row(children: [
            // 앱 내 상세 보기
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => YoutubePlayerPage(store: store))),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D2040),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF1E3A5F)),
                  ),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.smart_display_outlined,
                        color: Color(0xFF4FC3F7), size: 14),
                    SizedBox(width: 5),
                    Text('영상 상세보기',
                      style: TextStyle(color: Color(0xFF4FC3F7), fontSize: 12,
                          fontWeight: FontWeight.w700)),
                  ]),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // 유튜브 앱으로 재생
            Expanded(
              child: GestureDetector(
                onTap: () => _openYoutube(vid),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFFFF0000), Color(0xFFCC0000)]),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.25),
                        blurRadius: 8, offset: const Offset(0, 3))],
                  ),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.open_in_new, color: Colors.white, size: 14),
                    SizedBox(width: 5),
                    Text('유튜브에서 재생',
                      style: TextStyle(color: Colors.white, fontSize: 12,
                          fontWeight: FontWeight.bold)),
                  ]),
                ),
              ),
            ),
          ]),
        ),

        // ── 안내 ──────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
          child: const Text(
            '유튜브에서 재생 후 뒤로가기를 누르면 앱으로 돌아옵니다.',
            style: TextStyle(color: Color(0xFF3A5A7A), fontSize: 10, height: 1.4),
          ),
        ),
      ]),
    );
  }
}

// =====================================================
// 6. 카테고리 페이지용 점포 영상 목록 섹션
//    - 해당 카테고리 점포 중 youtubeUrl 있는 것만
//    - 최대 3개 표시, 더보기 버튼으로 전체 영상 페이지 이동
// =====================================================
class CategoryVideoSection extends StatefulWidget {
  final String category;
  final List<Store> stores; // 해당 카테고리 점포 목록

  const CategoryVideoSection({
    super.key,
    required this.category,
    required this.stores,
  });

  @override
  State<CategoryVideoSection> createState() => _CategoryVideoSectionState();
}

class _CategoryVideoSectionState extends State<CategoryVideoSection> {
  bool _expanded = false;
  static const int _previewCount = 3;

  @override
  Widget build(BuildContext context) {
    // youtubeUrl 있는 점포만 필터
    final videoStores = widget.stores
        .where((s) => s.videoId != null && s.videoId!.isNotEmpty)
        .toList();

    if (videoStores.isEmpty) return const SizedBox.shrink();

    final showList = _expanded
        ? videoStores
        : videoStores.take(_previewCount).toList();
    final hasMore = videoStores.length > _previewCount;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── 헤더 ──────────────────────────────────
        Row(children: [
          Container(
            width: 4, height: 20,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          const Text('점포 유튜브 영상',
            style: TextStyle(color: Colors.white, fontSize: 15,
                fontWeight: FontWeight.w800)),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
                color: Colors.red, borderRadius: BorderRadius.circular(5)),
            child: Text('${videoStores.length}',
              style: const TextStyle(color: Colors.white,
                  fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const Spacer(),
          if (hasMore && !_expanded)
            GestureDetector(
              onTap: () => setState(() => _expanded = true),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('전체보기 ${videoStores.length}개',
                  style: const TextStyle(color: Color(0xFF4FC3F7),
                      fontSize: 12, fontWeight: FontWeight.w600)),
                const Icon(Icons.chevron_right,
                    color: Color(0xFF4FC3F7), size: 16),
              ]),
            ),
          if (_expanded)
            GestureDetector(
              onTap: () => setState(() => _expanded = false),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Text('접기', style: TextStyle(color: Color(0xFF4FC3F7),
                    fontSize: 12, fontWeight: FontWeight.w600)),
                Icon(Icons.expand_less, color: Color(0xFF4FC3F7), size: 16),
              ]),
            ),
        ]),
        const SizedBox(height: 10),

        // ── 영상 카드 목록 ─────────────────────────
        ...showList.map((store) => _StoreMiniVideoCard(store: store)),

        // ── 더보기 버튼 (접힌 상태에서 잘린 경우) ──
        if (hasMore && !_expanded) ...[
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => setState(() => _expanded = true),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF0A1628),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF1E3A5F)),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('영상 ${videoStores.length - _previewCount}개 더보기',
                  style: const TextStyle(color: Color(0xFF4FC3F7),
                      fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(width: 4),
                const Icon(Icons.expand_more,
                    color: Color(0xFF4FC3F7), size: 18),
              ]),
            ),
          ),
        ],
        const SizedBox(height: 4),
      ]),
    );
  }
}

// ── 카테고리 페이지용 점포 미니 영상 카드 ──────────────
class _StoreMiniVideoCard extends StatelessWidget {
  final Store store;
  const _StoreMiniVideoCard({required this.store});

  @override
  Widget build(BuildContext context) {
    final vid      = store.videoId!;
    final thumbUrl = 'https://img.youtube.com/vi/$vid/mqdefault.jpg';

    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => YoutubePlayerPage(store: store))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF0A1628),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1E3A5F).withOpacity(0.7)),
        ),
        child: Row(children: [
          // 썸네일
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(children: [
              Image.network(thumbUrl,
                width: 110, height: 62, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 110, height: 62,
                  color: const Color(0xFF0D2040),
                  child: const Icon(Icons.play_circle_outline,
                      color: Colors.white24, size: 28),
                )),
              // 재생 오버레이
              Positioned.fill(child: Center(child: Container(
                width: 30, height: 30,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.85),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow, color: Colors.white, size: 18),
              ))),
              // 조회수
              if (store.videoHits > 0)
                Positioned(bottom: 3, right: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    color: Colors.black.withOpacity(0.75),
                    child: Text('${store.videoHits}',
                      style: const TextStyle(color: Colors.white,
                          fontSize: 9, fontWeight: FontWeight.w600)),
                  ),
                ),
            ]),
          ),
          const SizedBox(width: 10),
          // 점포 정보
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(store.name,
                style: const TextStyle(color: Colors.white, fontSize: 13,
                    fontWeight: FontWeight.bold),
                maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(store.category,
                style: const TextStyle(color: Color(0xFF4FC3F7),
                    fontSize: 11, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.place_outlined,
                    color: Color(0xFF5A7A9A), size: 11),
                const SizedBox(width: 3),
                Expanded(child: Text(store.address,
                  style: const TextStyle(color: Color(0xFF5A7A9A), fontSize: 10),
                  maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
            ],
          )),
          // 재생 화살표
          const Padding(
            padding: EdgeInsets.only(left: 6),
            child: Icon(Icons.play_circle_outline,
                color: Color(0xFF3A5A7A), size: 22),
          ),
        ]),
      ),
    );
  }
}
