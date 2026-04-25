import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/intro_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screens.dart';
import 'screens/home_screen.dart';
import 'screens/store_screens.dart';
import 'screens/other_screens.dart';
import 'screens/quote_screens.dart';
import 'screens/category_landing_screen.dart';
import 'screens/used_car_screen.dart';
import 'screens/motorcycle_screen.dart';
import 'screens/rent_car_screen.dart';
import 'models/app_state.dart';
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
          '/shop-inbox': (_) => const ShopInboxScreen(),
          '/store-mgr': (_) => const StoreMgrScreen(),
          '/coupon': (_) => const CouponScreen(),
          '/cert': (_) => const CertScreen(),
          '/used-car': (ctx) {
            final raw = ModalRoute.of(ctx)?.settings.arguments;
            int tab = 0;
            bool openSearch = false;
            if (raw is int) {
              tab = raw;
            } else if (raw is Map) {
              final m = raw as Map<String, dynamic>;
              tab = m['initialTab'] as int? ?? 0;
              openSearch = m['openSearch'] as bool? ?? false;
            }
            return UsedCarMainScreen(initialTab: tab, openSearch: openSearch);
          },
          '/my': (_) => const MyScreen(),
          '/notification': (_) => const NotificationScreen(),
          '/quote-request': (_) => const QuoteRequestScreen(),
          '/quote-list': (_) => const QuoteReceivedScreen(),
          '/quote-received': (_) => const QuoteReceivedScreen(),
          '/shop-quote': (_) => const ShopQuoteScreen(),
          '/news': (_) => const NewsScreen(),
          '/emergency': (_) => const EmergencyScreen(),
          '/car-price': (_) => const CarPriceScreen(),
          '/my-quotes': (_) => const MyQuotesScreen(),
          '/car-applications': (_) => const CarApplicationHistoryScreen(),
          '/reward': (_) => const RewardScreen(),
          '/motorcycle': (ctx) {
            final raw = ModalRoute.of(ctx)?.settings.arguments;
            int tab = 0;
            if (raw is int) tab = raw;
            else if (raw is Map) tab = (raw as Map<String, dynamic>)['initialTab'] as int? ?? 0;
            return MotorcycleScreen(initialTab: tab);
          },
          '/rent-car': (_) => const RentCarScreen(),
          '/rent-bookings': (_) => const RentMyBookingsScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/category-landing') {
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            return MaterialPageRoute(
              builder: (_) => CategoryLandingScreen(
                category: args['category'] as String? ?? '정비',
                emoji: args['emoji'] as String? ?? '🔧',
              ),
            );
          }
          if (settings.name == '/quote-detail') {
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            final req  = args['request']  as EstimateRequest?;
            final bid  = args['bid']      as QuoteBid?;
            if (req != null && bid != null) {
              return MaterialPageRoute(
                builder: (_) => QuoteDetailScreen(request: req, bid: bid),
              );
            }
            return MaterialPageRoute(builder: (_) => const QuoteReceivedScreen());
          }
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
