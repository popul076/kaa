import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B1120), Color(0xFF0D2A3E), Color(0xFF0F3D2E)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // KAA MOBILITY PLATFORM 태그
                Text('KAA MOBILITY PLATFORM',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.6),
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 20),

                // 메인 타이틀
                const Text(
                  '자동차 관련\n점포와 중고차\n정보를 한 번에\n찾는 앱',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 24),

                // 설명
                Text(
                  '간편가입 후 동네와 관심도를 고르면 바로 사용할 수 있고, 사업자는 무료 AI 점포상세페이지를 만들 수 있습니다.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                    height: 1.6,
                  ),
                ),

                const Spacer(),

                // 시작하기 버튼
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.textPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('시작하기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 로그인 텍스트
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('이미 계정이 있으신가요? ',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.55),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        final state = AppState();
                        state.setLoggedIn(UserModel(name: '홍길동'));
                        Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
                      },
                      child: const Text('로그인',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
