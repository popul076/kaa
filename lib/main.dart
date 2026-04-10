import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/intro_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screens.dart';
import 'screens/home_screen.dart';
import 'screens/store_screens.dart';
import 'screens/other_screens.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // 상태바: 검정 배경 + 흰색 아이콘 (앱 내용이 뒤로 안 겹침)
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color(0xFF000000),
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));
  runApp(const KaaApp());
}

class KaaApp extends StatelessWidget {
  const KaaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KAA Mobility Platform',
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
        '/coupon': (_) => const CouponScreen(),
        '/cert': (_) => const CertScreen(),
        '/used-car': (_) => const UsedCarScreen(),
        '/my': (_) => const MyScreen(),
        '/notification': (_) => const NotificationScreen(),
        '/quote-request': (_) => const QuoteRequestScreen(),
        '/news': (_) => const NewsScreen(),
        '/emergency': (_) => const EmergencyScreen(),
        '/car-price': (_) => const CarPriceScreen(),
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
    );
  }
}
