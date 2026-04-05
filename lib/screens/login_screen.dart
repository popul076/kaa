import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 뒤로가기
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 14, color: AppColors.textPrimary),
                    label: const Text('뒤로', style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6)),
                  ),
                ],
              ),
            ),

            // 로그인 헤더 카드
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0D2A3E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('K', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.primary)),
                      const Text('AA', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('간편 로그인',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  Text('카카오, 네이버, 구글로 빠르게 로그인하고\nKAA 서비스를 시작하세요.',
                    style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.7), height: 1.5),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 소셜 로그인 버튼들
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _SocialButton(
                    color: AppColors.kakao,
                    textColor: AppColors.kakaoText,
                    label: '카카오로 로그인',
                    letter: 'K',
                    onTap: () => _startSignup(context, 'kakao'),
                  ),
                  const SizedBox(height: 10),
                  _SocialButton(
                    color: AppColors.naver,
                    textColor: Colors.white,
                    label: '네이버로 로그인',
                    letter: 'N',
                    onTap: () => _startSignup(context, 'naver'),
                  ),
                  const SizedBox(height: 10),
                  _SocialButton(
                    color: AppColors.google,
                    textColor: Colors.white,
                    label: '구글로 로그인',
                    letter: 'G',
                    onTap: () => _startSignup(context, 'google'),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // 하단 링크
            TextButton(
              onPressed: () {
                final state = AppState();
                state.setLoggedIn(UserModel(name: '홍길동'));
                Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
              },
              child: const Text('로그인 없이 둘러보기',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  children: [
                    const TextSpan(text: '가입 시 '),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () {},
                        child: const Text('이용약관', style: TextStyle(fontSize: 11, color: AppColors.primary, decoration: TextDecoration.underline)),
                      ),
                    ),
                    const TextSpan(text: ' 및 '),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () {},
                        child: const Text('개인정보처리방침', style: TextStyle(fontSize: 11, color: AppColors.primary, decoration: TextDecoration.underline)),
                      ),
                    ),
                    const TextSpan(text: '에 동의합니다.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _startSignup(BuildContext context, String provider) {
    AppState().signup.provider = provider;
    AppState().signup.agreed = [];
    Navigator.pushNamed(context, '/signup-terms');
  }
}

class _SocialButton extends StatelessWidget {
  final Color color;
  final Color textColor;
  final String label;
  final String letter;
  final VoidCallback onTap;

  const _SocialButton({
    required this.color,
    required this.textColor,
    required this.label,
    required this.letter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: Text(letter,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}
