import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

// ═══════════════════════════════════════════════════════════════
// MOINCAR Intro Screen — 시안 5 군청색 다크 스타일
// ═══════════════════════════════════════════════════════════════
class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  static const Color _bg     = Color(0xFF020810);
  static const Color _s1     = Color(0xFF071428);
  static const Color _s2     = Color(0xFF0D1E3C);
  static const Color _br     = Color(0xFF1A3050);
  static const Color _accent = Color(0xFF4FC3F7);
  static const Color _t1     = Color(0xFFE8F4FF);
  static const Color _t2     = Color(0xFF7AB0D4);
  static const Color _t3     = Color(0xFF3A6080);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: _bg),
        child: Stack(
          children: [
            // 배경 아이스블루 글로우 — 좌상단
            Positioned(
              top: -120, left: -100,
              child: Container(
                width: 360, height: 360,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _accent.withOpacity(0.05),
                ),
              ),
            ),
            // 배경 글로우 — 우하단
            Positioned(
              bottom: -80, right: -80,
              child: Container(
                width: 280, height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _accent.withOpacity(0.04),
                ),
              ),
            ),
            // 격자 배경 — 은은하게
            Positioned.fill(
              child: CustomPaint(painter: _IntroGridPainter()),
            ),

            // 메인 콘텐츠
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),

                      // MOINCAR 로고 이미지 (텍스트 삭제, 부제 위로 배치)
                      Image.asset(
                        'assets/images/moincar_logo.png',
                        width: 120,  // 280 → 120 (크기 축소)
                        fit: BoxFit.contain,
                        errorBuilder: (c, e, s) => _buildNavyLogo(),
                      ),

                      const SizedBox(height: 4),  // 5 → 4 (로고와 부제 간격 더 축소)

                      // 부제목 (MOINCAR 텍스트 삭제됨)
                      Text(
                        'mobility international car',
                        style: GoogleFonts.notoSansKr(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: _accent,
                          letterSpacing: 2,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 36),

                      // 구분선 (아이스블루)
                      Container(
                        width: 40, height: 2,
                        decoration: BoxDecoration(
                          color: _accent,
                          borderRadius: BorderRadius.circular(1),
                          boxShadow: [BoxShadow(color: _accent.withOpacity(0.4), blurRadius: 8)],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // 메인 타이틀
                      Text(
                        '모든 자동차 서비스,\n한 곳에서 간편하게',
                        style: GoogleFonts.notoSansKr(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: _t1,
                          height: 1.35,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 14),

                      // 설명
                      Text(
                        '정비·세차·중고차·검사까지\n내 주변 모든 자동차 서비스를\nMOINCAR에서 한 번에 이용하세요',
                        style: GoogleFonts.notoSansKr(
                          fontSize: 14,
                          color: _t3,
                          height: 1.7,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 40),

                      // 기능 3가지 하이라이트
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _featureChip('📍', '위치기반'),
                          const SizedBox(width: 10),
                          _featureChip('🤖', 'AI 점포'),
                          const SizedBox(width: 10),
                          _featureChip('🚗', '중고차'),
                        ],
                      ),

                      const SizedBox(height: 44),

                      // 시작하기 버튼 (아이스블루)
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A3A6E),
                            foregroundColor: _accent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(color: _accent.withOpacity(0.4)),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            '시작하기',
                            style: GoogleFonts.notoSansKr(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _accent,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // 로그인 링크
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '이미 계정이 있으신가요?  ',
                            style: GoogleFonts.notoSansKr(
                              fontSize: 13,
                              color: _t3,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            child: Text(
                              '로그인',
                              style: GoogleFonts.notoSansKr(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _accent,
                                decoration: TextDecoration.underline,
                                decorationColor: _accent,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 기능 칩
  Widget _featureChip(String icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF071428),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1A3050)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 5),
        Text(label, style: GoogleFonts.notoSansKr(
          fontSize: 11, color: _t3, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  // 폴백 로고 — 군청색 M 마크
  Widget _buildNavyLogo() {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 100, height: 100,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF1A3A8E), Color(0xFF0D1E5A)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _accent.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(color: _accent.withOpacity(0.2), blurRadius: 20, spreadRadius: 2),
          ],
        ),
        child: Center(
          child: Text('M', style: GoogleFonts.notoSansKr(
            color: _accent, fontSize: 56,
            fontWeight: FontWeight.w900, letterSpacing: -2,
          )),
        ),
      ),
    ]);
  }
}

// 인트로 격자 배경
class _IntroGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFF0D1E3C).withOpacity(0.5)
      ..strokeWidth = 0.4;
    const sp = 32.0;
    for (double x = 0; x < size.width; x += sp) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += sp) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }
  @override bool shouldRepaint(_) => false;
}
