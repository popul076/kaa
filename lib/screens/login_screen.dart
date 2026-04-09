import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ═══════════════════════════════════════════════════════════════
// MOINCAR Login Screen — 군청색 다크 테마 (v22.0.0)
// 배경: #020810  포인트: #4FC3F7 (아이스블루)
// ═══════════════════════════════════════════════════════════════
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20, color: Color(0xFF7AB0D4)),
          onPressed: () => Navigator.pop(context),
        ),
        title: null,  // M 로고 + MOINCAR 텍스트 삭제
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 배경 글로우
          Positioned(
            top: -60, right: -60,
            child: Container(
              width: 240, height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _accent.withOpacity(0.04),
              ),
            ),
          ),
          Positioned(
            bottom: -40, left: -40,
            child: Container(
              width: 180, height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _accent.withOpacity(0.03),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // 안내 텍스트
                  Text(
                    '간편하게 시작하세요',
                    style: GoogleFonts.notoSansKr(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: _t1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'SNS 계정으로 MOINCAR를 바로 이용할 수 있습니다',
                    style: GoogleFonts.notoSansKr(
                      fontSize: 13,
                      color: _t3,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // 구분선
                  Container(
                    width: 36, height: 2,
                    decoration: BoxDecoration(
                      color: _accent.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),

                  const SizedBox(height: 44),

                  // 카카오 로그인 버튼
                  _SocialLoginButton(
                    bgColor: const Color(0xFFFEE500),
                    textColor: const Color(0xFF191919),
                    iconWidget: const _KakaoIcon(),
                    label: '카카오로 시작하기',
                    onTap: () {
                      Navigator.pushNamed(context, '/signup-terms');
                    },
                  ),

                  const SizedBox(height: 12),

                  // 네이버 로그인 버튼
                  _SocialLoginButton(
                    bgColor: const Color(0xFF03C75A),
                    textColor: Colors.white,
                    iconWidget: const _NaverIcon(),
                    label: '네이버로 시작하기',
                    onTap: () {
                      Navigator.pushNamed(context, '/signup-terms');
                    },
                  ),

                  const SizedBox(height: 12),

                  // 구글 로그인 버튼 — 다크 테마에 맞게 어두운 테두리
                  _SocialLoginButton(
                    bgColor: const Color(0xFF0D1E3C),
                    textColor: _t1,
                    borderColor: _br,
                    iconWidget: const _GoogleIcon(),
                    label: 'Google로 시작하기',
                    onTap: () {
                      Navigator.pushNamed(context, '/signup-terms');
                    },
                  ),

                  const Spacer(),

                  // 이용약관 (다크 테마)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: _s1.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _br.withOpacity(0.4)),
                    ),
                    child: Text(
                      '로그인 시 이용약관 및 개인정보 처리방침에 동의하게 됩니다',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 11,
                        color: _t3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 공통 소셜 로그인 버튼 ──────────────────────────────────
class _SocialLoginButton extends StatelessWidget {
  final Color bgColor;
  final Color textColor;
  final Color? borderColor;
  final Widget iconWidget;
  final String label;
  final VoidCallback onTap;

  const _SocialLoginButton({
    required this.bgColor,
    required this.textColor,
    this.borderColor,
    required this.iconWidget,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: borderColor != null
                ? BorderSide(color: borderColor!)
                : BorderSide.none,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: iconWidget,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.notoSansKr(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 카카오 아이콘 ─────────────────────────────────────────
class _KakaoIcon extends StatelessWidget {
  const _KakaoIcon();
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 24, height: 24,
      child: CustomPaint(painter: _KakaoPainter()),
    );
  }
}

class _KakaoPainter extends CustomPainter {
  const _KakaoPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF191919);
    canvas.drawOval(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.82), paint);
    final path = Path()
      ..moveTo(size.width * 0.35, size.height * 0.75)
      ..lineTo(size.width * 0.25, size.height)
      ..lineTo(size.width * 0.55, size.height * 0.80)
      ..close();
    canvas.drawPath(path, paint);
  }
  @override bool shouldRepaint(_) => false;
}

// ── 네이버 아이콘 ─────────────────────────────────────────
class _NaverIcon extends StatelessWidget {
  const _NaverIcon();
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 24, height: 24,
      child: Center(
        child: Text('N',
          style: TextStyle(
            color: Colors.white, fontSize: 16,
            fontWeight: FontWeight.w900, fontFamily: 'Arial')),
      ),
    );
  }
}

// ── 구글 아이콘 ────────────────────────────────────────────
class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 24, height: 24,
      child: CustomPaint(painter: _GooglePainter()),
    );
  }
}

class _GooglePainter extends CustomPainter {
  const _GooglePainter();
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    // 반투명 배경 원
    canvas.drawCircle(Offset(cx, cy), r,
      Paint()..color = const Color(0xFF1A3050));

    // 4분면 색상
    final colors = [
      const Color(0xFF4285F4),
      const Color(0xFFEA4335),
      const Color(0xFFFBBC05),
      const Color(0xFF34A853),
    ];
    for (int i = 0; i < 4; i++) {
      final paint = Paint()..color = colors[i];
      final startAngle = (i * 90 - 45) * 3.14159 / 180;
      final sweepAngle = 90 * 3.14159 / 180;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.85),
        startAngle, sweepAngle, true, paint);
    }

    // 가운데 원 (도넛)
    canvas.drawCircle(Offset(cx, cy), r * 0.5,
      Paint()..color = const Color(0xFF0D1E3C));

    // G 가로 막대
    canvas.drawRect(
      Rect.fromLTWH(cx, cy - r * 0.12, r * 0.85, r * 0.24),
      Paint()..color = const Color(0xFF4285F4));
  }
  @override bool shouldRepaint(_) => false;
}
