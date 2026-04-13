import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/intro_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screens.dart';
import 'screens/home_screen.dart';
import 'screens/store_screens.dart';
import 'screens/other_screens.dart';
import 'theme/app_theme.dart';

// 앱 전체 상태바 스타일 상수
const kStatusBarStyle = SystemUiOverlayStyle(
  statusBarColor: Color(0xFF000000),           // 상태바 배경: 검정
  statusBarIconBrightness: Brightness.light,   // Android: 아이콘/시계 흰색
  statusBarBrightness: Brightness.dark,        // iOS: 아이콘/시계 흰색
  systemNavigationBarColor: Color(0xFF000000),
  systemNavigationBarIconBrightness: Brightness.light,
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 방향 잠금 (비동기 완료 대기 없이 백그라운드 처리)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 앱 시작 시점에 상태바 설정
  SystemChrome.setSystemUIOverlayStyle(kStatusBarStyle);

  // 렌더링 최적화: 첫 프레임 이후 이미지 프리캐싱
  runApp(const KaaApp());
}

class KaaApp extends StatelessWidget {
  const KaaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // AnnotatedRegion: 화면 전환 후에도 상태바를 검정+흰글씨로 유지
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: kStatusBarStyle,
      child: MaterialApp(
        title: 'MOINCAR 모빌리티 플랫폼',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        initialRoute: '/intro',
        routes: {
          '/intro': (_) => const IntroScreen(),
          '/login': (_) => const LoginScreen(),
          '/signup-terms': (_) => const SignupTermsScreen(),
          '/signup-profile': (_) => const SignupProfileScreen(),
          '/signup-interest': (_) => const SignupInterestScreen(),
          '/signup-done': (_) => const SignupDoneScreen(),
          '/home': (_) => const HomeScreen(),
          '/store-list': (_) => const StoreListScreen(),
          '/store-detail': (_) => const StoreDetailScreen(),
          '/store-register': (_) => const StoreRegisterScreen(),
          '/store-mgr': (_) => const StoreMgrScreen(),
          '/coupon': (_) => const CouponScreen(),
          '/cert': (_) => const CertScreen(),
          '/used-car': (_) => const UsedCarScreen(),
          '/my': (_) => const MyScreen(),
          '/notification': (_) => const NotificationScreen(),
          '/quote-request': (_) => const QuoteRequestScreen(),
          '/news': (_) => const NewsScreen(),
          '/emergency': (_) => const EmergencyScreen(),
          '/car-price': (_) => const CarPriceScreen(),
          '/reward': (_) => const RewardScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/chat') {
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            return MaterialPageRoute(
              builder: (_) => ChatScreen(
                storeName: args['storeName'] as String? ?? '점포',
                storeId:   args['storeId']   as int?    ?? 0,
              ),
            );
          }
          return null;
        },
        onUnknownRoute: (settings) => MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      ), // MaterialApp
    ); // AnnotatedRegion
  }
}
