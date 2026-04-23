import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';
import '../widgets/common_widgets.dart';
import 'quote_screens.dart' show QuoteDetailScreen;
import 'used_car_screen.dart' show UsedCarDetailScreen;
import 'motorcycle_screen.dart' show MotorcycleScreen;

// ── MOINCAR 공통 다크 색상 상수 ──
const Color _mBg      = Color(0xFF020810);
const Color _mCard    = Color(0xFF0D1B2A);
const Color _mAccent  = Color(0xFF4FC3F7);
const Color _mOrange  = Color(0xFFFF6B35);
const Color _mGreen   = Color(0xFF10B981);
const Color _mBorder  = Color(0xFF1E3A5F);
const Color _mTextPri = Colors.white;
const Color _mTextSec = Color(0xFFB0BEC5);

// ==================== 쿠폰 ====================
class CouponScreen extends StatelessWidget {
  const CouponScreen({super.key});

  final coupons = const [
    {'store': 'MOINCAR 추천 프리미엄 정비소', 'title': '엔진오일 교환 20% 할인', 'expires': '2025-06-30', 'discount': '20%', 'used': false},
    {'store': '추천 세차·코팅 전문점', 'title': '프리미엄 손세차 무료', 'expires': '2025-05-31', 'discount': '무료', 'used': false},
    {'store': '프리미엄 타이어 전문점', 'title': '타이어 교체 10,000원 할인', 'expires': '2025-04-30', 'discount': '10,000원', 'used': true},
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: _mBg, statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: _mBg,
        body: Column(
          children: [
            // 상단바
            Container(
              color: _mCard,
              padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 10, 16, 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text('🎟️ 내 쿠폰',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _mOrange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _mOrange.withOpacity(0.4)),
                    ),
                    child: Text('${coupons.where((c) => !(c['used'] as bool)).length}장 보유',
                      style: const TextStyle(fontSize: 11, color: _mOrange, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            // 요약 카드
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_mOrange.withOpacity(0.15), _mAccent.withOpacity(0.08)],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _mOrange.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statItem('전체', '${coupons.length}', '장', _mAccent),
                  Container(width: 1, height: 40, color: _mBorder),
                  _statItem('사용가능', '${coupons.where((c) => !(c['used'] as bool)).length}', '장', _mGreen),
                  Container(width: 1, height: 40, color: _mBorder),
                  _statItem('사용완료', '${coupons.where((c) => c['used'] as bool).length}', '장', _mTextSec),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                itemCount: coupons.length,
                itemBuilder: (_, i) {
                  final c = coupons[i];
                  final used = c['used'] as bool;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: _mCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: used ? _mBorder : _mOrange.withOpacity(0.4)),
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 62,
                                height: 62,
                                decoration: BoxDecoration(
                                  color: used
                                    ? _mBorder.withOpacity(0.3)
                                    : _mOrange.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: used ? _mBorder : _mOrange.withOpacity(0.5)),
                                ),
                                child: Center(
                                  child: Text(c['discount'] as String,
                                    style: TextStyle(
                                      fontSize: 13, fontWeight: FontWeight.w800,
                                      color: used ? _mTextSec : _mOrange),
                                    textAlign: TextAlign.center),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(c['store'] as String,
                                      style: TextStyle(fontSize: 11,
                                        color: used ? _mTextSec.withOpacity(0.5) : _mAccent)),
                                    const SizedBox(height: 4),
                                    Text(c['title'] as String,
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                                        color: used ? _mTextSec : _mTextPri)),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.schedule, size: 11,
                                          color: used ? _mTextSec.withOpacity(0.5) : _mTextSec),
                                        const SizedBox(width: 3),
                                        Text('유효기간: ${c['expires']}',
                                          style: TextStyle(fontSize: 11,
                                            color: used ? _mTextSec.withOpacity(0.5) : _mTextSec)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (used)
                          Positioned(
                            top: 12, right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _mBorder,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('사용완료',
                                style: TextStyle(color: _mTextSec, fontSize: 10, fontWeight: FontWeight.w600)),
                            ),
                          )
                        else
                          Positioned(
                            top: 12, right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _mGreen.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: _mGreen.withOpacity(0.4)),
                              ),
                              child: const Text('사용가능',
                                style: TextStyle(color: _mGreen, fontSize: 10, fontWeight: FontWeight.w600)),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String num, String unit, Color color) {
    return Column(
      children: [
        RichText(text: TextSpan(children: [
          TextSpan(text: num,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
          TextSpan(text: unit,
            style: TextStyle(fontSize: 12, color: color.withOpacity(0.7))),
        ])),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: _mTextSec)),
      ],
    );
  }
}

// ==================== 협회 인증 ====================
class CertScreen extends StatelessWidget {
  const CertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: _mBg, statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: _mBg,
        body: Column(
          children: [
            Container(
              color: _mCard,
              padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 10, 16, 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text('🏅 MOINCAR 인증',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _mGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _mGreen.withOpacity(0.4)),
                    ),
                    child: const Text('공식 인증', style: TextStyle(fontSize: 10, color: _mGreen, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_mGreen.withOpacity(0.15), _mAccent.withOpacity(0.08)],
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _mGreen.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 64, height: 64,
                            decoration: BoxDecoration(
                              color: _mGreen.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(color: _mGreen.withOpacity(0.5), width: 2),
                            ),
                            child: const Icon(Icons.verified_rounded, color: _mGreen, size: 32),
                          ),
                          const SizedBox(height: 12),
                          const Text('MOINCAR 공식 인증',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                          const SizedBox(height: 8),
                          Text('인증된 점포에서 안심하고 서비스를 받으세요.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: _mTextSec)),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('인증 신청 기능 준비중입니다'))),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _mGreen,
                                minimumSize: const Size(double.infinity, 48),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('인증서 발급 신청하기',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _mCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _mBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('인증 혜택',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                          const SizedBox(height: 12),
                          ...[
                            ['✅', '신뢰성 검증', 'MOINCAR 공식 품질 기준 통과 점포'],
                            ['🔍', '투명한 정보', '실시간 가격·서비스 정보 공개'],
                            ['⭐', '우선 노출', '앱 잠금화면 및 메인 화면 우선 표시'],
                            ['🎁', '특별 쿠폰', '인증 점포 전용 할인 쿠폰 제공'],
                          ].map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Text(item[0], style: const TextStyle(fontSize: 18)),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item[1], style: const TextStyle(fontSize: 13,
                                      fontWeight: FontWeight.w600, color: Colors.white)),
                                    Text(item[2], style: TextStyle(fontSize: 11, color: _mTextSec)),
                                  ],
                                ),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('인증 점포 목록',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                    const SizedBox(height: 10),
                    ...AppData.stores.where((s) => s.type == 'certified').map((s) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _mCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _mGreen.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                color: _mGreen.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: _mGreen.withOpacity(0.4)),
                              ),
                              child: const Icon(Icons.verified_rounded, color: _mGreen, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(s.name,
                                    style: const TextStyle(fontSize: 14,
                                      fontWeight: FontWeight.w600, color: Colors.white)),
                                  Text('${s.category} · ${s.distance}',
                                    style: TextStyle(fontSize: 12, color: _mTextSec)),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right, color: _mTextSec.withOpacity(0.5)),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== 중고차 ====================
class UsedCarScreen extends StatefulWidget {
  const UsedCarScreen({super.key});
  @override
  State<UsedCarScreen> createState() => _UsedCarScreenState();
}

class _UsedCarScreenState extends State<UsedCarScreen> {
  String _selectedFilter = '전체';
  final _filters = ['전체', '국산차', '수입차', '전기차', '연식순', '가격순'];

  final _cars = [
    {'name': '2022 현대 아반떼 1.6 가솔린', 'price': '1,850만원', 'km': '32,000km', 'year': '2022년식', 'type': '국산차', 'emoji': '🚗'},
    {'name': '2021 기아 K5 2.0 하이브리드', 'price': '2,300만원', 'km': '48,000km', 'year': '2021년식', 'type': '국산차', 'emoji': '🚙'},
    {'name': '2020 BMW 320i', 'price': '3,200만원', 'km': '55,000km', 'year': '2020년식', 'type': '수입차', 'emoji': '🏎️'},
    {'name': '2023 테슬라 Model 3', 'price': '4,500만원', 'km': '12,000km', 'year': '2023년식', 'type': '전기차', 'emoji': '⚡'},
    {'name': '2019 현대 그랜저 3.0', 'price': '2,750만원', 'km': '72,000km', 'year': '2019년식', 'type': '국산차', 'emoji': '🚗'},
    {'name': '2022 벤츠 E220d', 'price': '5,200만원', 'km': '18,000km', 'year': '2022년식', 'type': '수입차', 'emoji': '🏎️'},
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedFilter == '전체'
      ? _cars
      : _cars.where((c) => c['type'] == _selectedFilter).toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: _mBg, statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: _mBg,
        body: Column(
          children: [
            Container(
              color: _mCard,
              padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 10, 16, 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text('🚗 중고차 매물',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _mAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _mAccent.withOpacity(0.4)),
                        ),
                        child: Text('${filtered.length}건',
                          style: const TextStyle(fontSize: 11, color: _mAccent, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D1B2A),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _mBorder),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: _mTextSec.withOpacity(0.5), size: 18),
                        const SizedBox(width: 8),
                        Text('차량 검색 (제조사, 모델명, 차량번호)',
                          style: TextStyle(color: _mTextSec.withOpacity(0.5), fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // 필터 칩
            Container(
              color: _mCard,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filters.map((f) {
                    final isSelected = f == _selectedFilter;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedFilter = f),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? _mAccent : _mBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? _mAccent : _mBorder),
                        ),
                        child: Text(f,
                          style: TextStyle(
                            fontSize: 12, fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                            color: isSelected ? _mBg : _mTextSec)),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  final car = filtered[i];
                  return GestureDetector(
                    onTap: () {},
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: _mCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _mBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 110, height: 90,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0A1628),
                              borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
                            ),
                            child: Center(
                              child: Text(car['emoji'] as String,
                                style: const TextStyle(fontSize: 40)),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: _mGreen.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(3),
                                          border: Border.all(color: _mGreen.withOpacity(0.4)),
                                        ),
                                        child: const Text('MOINCAR 인증',
                                          style: TextStyle(color: _mGreen, fontSize: 9, fontWeight: FontWeight.w700)),
                                      ),
                                      const SizedBox(width: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: _mAccent.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                        child: Text(car['type'] as String,
                                          style: const TextStyle(color: _mAccent, fontSize: 9, fontWeight: FontWeight.w600)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(car['name'] as String,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                                    maxLines: 2, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 4),
                                  Text('${car['year']} · ${car['km']}',
                                    style: TextStyle(fontSize: 11, color: _mTextSec)),
                                  const SizedBox(height: 4),
                                  Text(car['price'] as String,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _mOrange)),
                                ],
                              ),
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
    );
  }
}

// ==================== 마이 페이지 (MOINCAR 다크 테마) ====================
class MyScreen extends StatefulWidget {
  const MyScreen({super.key});

  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  // MOINCAR 다크 컬러
  static const Color _bg      = Color(0xFF020810);
  static const Color _card    = Color(0xFF0D1B2A);
  static const Color _accent  = Color(0xFF4FC3F7);
  static const Color _orange  = Color(0xFFFF6B35);
  static const Color _green   = Color(0xFF10B981);
  static const Color _textPri = Colors.white;
  static const Color _textSec = Color(0xFFB0BEC5);
  static const Color _border  = Color(0xFF1E3A5F);

  // 점포 등록 여부 (실제는 AppState에서 관리)
  bool get _hasStore => AppState().isLoggedIn; // 로그인 = 점포 있다고 가정 (실제 구현 시 별도 필드)

  // 내 중고차 매물 수 (개인 직거래)
  int get _myListingCount => UsedCarState().listings
      .where((l) => l.sellerType == 'individual' && !l.isSold).length;

  // 내 매물 전체 문의 수
  int get _myInquiryCount {
    final all = UsedCarState().listings;
    final mine = all.any((l) => l.isMyListing)
        ? all.where((l) => l.isMyListing).toList()
        : all.where((l) => l.sellerType == 'individual').toList();
    return mine.fold(0, (sum, l) => sum + l.inquiryCount);
  }

  // 딜러 견적 요청 수
  int get _myBidCount => UsedCarState().saleRequests
      .where((r) => r.status == UsedCarStatus.bidding).length;

  @override
  Widget build(BuildContext context) {
    final user = AppState().user;
    final isLoggedIn = AppState().isLoggedIn;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF020810),
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _bg,
        body: Column(
          children: [
            // ── 상단바 ──
            Container(
              color: _card,
              padding: EdgeInsets.fromLTRB(
                16,
                MediaQuery.of(context).padding.top + 10,
                16,
                14,
              ),
              child: Row(
                children: [
                  // MOINCAR 로고 텍스트
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(text: 'MOIN',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                        TextSpan(text: 'CAR',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFFFF6B35))),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: _accent.withOpacity(0.3)),
                    ),
                    child: const Text('마이페이지',
                      style: TextStyle(fontSize: 10, color: Color(0xFF4FC3F7), fontWeight: FontWeight.w600)),
                  ),
                  const Spacer(),
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
                        onPressed: () => Navigator.pushNamed(context, '/notification'),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      if (AppState().notificationCount > 0)
                        Positioned(
                          right: 0, top: 0,
                          child: Container(
                            width: 14, height: 14,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF6B35),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${AppState().notificationCount}',
                                style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // ── 본문 ──
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 72,
                ),
                child: Column(
                  children: [
                    // 프로필 카드
                    Container(
                      color: _card,
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF4FC3F7), Color(0xFF1E88E5)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(color: _accent.withOpacity(0.5), width: 2),
                            ),
                            child: Center(
                              child: Text(
                                isLoggedIn ? (user?.name.isNotEmpty == true
                                  ? user!.name.substring(0, 1) : 'M') : 'M',
                                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: isLoggedIn
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(user?.name ?? '',
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: _hasStore
                                              ? _green.withOpacity(0.2)
                                              : _accent.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(
                                              color: _hasStore
                                                ? _green.withOpacity(0.5)
                                                : _accent.withOpacity(0.3)),
                                          ),
                                          child: Text(
                                            _hasStore ? '🏪 점포 관리자' : '👤 일반 이용자',
                                            style: TextStyle(
                                              fontSize: 10, fontWeight: FontWeight.w700,
                                              color: _hasStore ? _green : _accent)),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('로그인이 필요합니다',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                                    const SizedBox(height: 4),
                                    GestureDetector(
                                      onTap: () => Navigator.pushNamed(context, '/login'),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: _accent.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: _accent.withOpacity(0.4)),
                                        ),
                                        child: const Text('로그인 / 회원가입',
                                          style: TextStyle(fontSize: 12, color: Color(0xFF4FC3F7),
                                            fontWeight: FontWeight.w700)),
                                      ),
                                    ),
                                  ],
                                ),
                          ),
                          if (isLoggedIn)
                            Icon(Icons.chevron_right, color: _textSec),
                        ],
                      ),
                    ),

                    const SizedBox(height: 1),

                    // ── 내 활동 ──
                    _buildSection('내 활동', [
                      _DarkMenuItem(icon: Icons.receipt_long_outlined, label: '견적 내역',
                        color: _accent,
                        onTap: () => Navigator.pushNamed(context, '/my-quotes')),
                      _DarkMenuItem(
                        icon: Icons.build_circle_outlined,
                        label: '정비 내역',
                        color: _green,
                        badge: AppState().maintenanceHistory.isNotEmpty
                          ? '${AppState().maintenanceHistory.length}건' : null,
                        badgeColor: _green,
                        onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const VehicleMaintenanceScreen())),
                      ),
                      _DarkMenuItem(icon: Icons.favorite_border, label: '즐겨찾기 점포',
                        color: _accent, onTap: () {}),
                      _DarkMenuItem(icon: Icons.confirmation_number_outlined, label: '내 쿠폰',
                        color: _accent,
                        onTap: () => Navigator.pushNamed(context, '/coupon')),
                      _DarkMenuItem(icon: Icons.card_giftcard, label: '리워드 포인트',
                        color: _accent, onTap: () {}),
                    ]),

                    const SizedBox(height: 1),

                    // ── 차량 관리 ──
                    _buildSection('차량 관리', [
                      _DarkMenuItem(icon: Icons.directions_car_outlined, label: '내 차량 등록',
                        color: _orange, onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const VehicleRegisterScreen()))),
                      _DarkMenuItem(icon: Icons.build_outlined, label: '차량 정비 이력',
                        color: _orange, onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const VehicleMaintenanceScreen()))),
                      _DarkMenuItem(icon: Icons.monetization_on_outlined, label: '내차 시세 조회',
                        color: _orange,
                        onTap: () => Navigator.pushNamed(context, '/car-price')),
                      _DarkMenuItem(icon: Icons.sell_rounded, label: '내 중고차 매물',
                        color: const Color(0xFF8B5CF6),
                        badge: _myListingCount > 0 ? '$_myListingCount개' : null,
                        badgeColor: _myInquiryCount > 0
                            ? const Color(0xFFEF4444)   // 문의 있으면 빨간 배지
                            : const Color(0xFF8B5CF6),
                        onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const _MyListingsScreen()))),
                      _DarkMenuItem(icon: Icons.request_quote_outlined, label: '딜러 견적 요청 내역',
                        color: _green,
                        badge: _myBidCount > 0 ? '$_myBidCount건' : null,
                        badgeColor: _green,
                        onTap: () => Navigator.pushNamed(context, '/used-car', arguments: {'initialTab': 0})),
                    ]),

                    const SizedBox(height: 1),

                    // ── 점포 관리 (사용자 유형별 표시) ──
                    _buildSection('점포 관리', [
                      // 점포 등록: 항상 표시 (미등록 사용자 활성화)
                      _DarkMenuItem(
                        icon: Icons.store_outlined,
                        label: '점포 등록',
                        color: _hasStore ? _textSec : _green,
                        badge: _hasStore ? '등록완료' : null,
                        badgeColor: _hasStore ? _green : null,
                        onTap: _hasStore
                          ? () => ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('이미 점포가 등록되어 있습니다')))
                          : () => Navigator.pushNamed(context, '/store-register'),
                      ),
                      // 점포 관리자: 점포 등록 후에만 활성화
                      _DarkMenuItem(
                        icon: Icons.manage_accounts_outlined,
                        label: '점포 관리자',
                        color: _hasStore ? _accent : _textSec.withOpacity(0.4),
                        disabled: !_hasStore,
                        onTap: _hasStore
                          ? () => Navigator.pushNamed(context, '/store-mgr')
                          : () => ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('점포 등록 후 이용 가능합니다'))),
                      ),
                      // 협회 인증 신청: 점포 관리자만 활성화
                      _DarkMenuItem(
                        icon: Icons.verified_outlined,
                        label: '협회 인증 신청',
                        color: _hasStore ? const Color(0xFF8B5CF6) : _textSec.withOpacity(0.4),
                        disabled: !_hasStore,
                        onTap: _hasStore
                          ? () => Navigator.pushNamed(context, '/cert')
                          : () => ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('점포 등록 후 이용 가능합니다'))),
                      ),
                    ]),

                    const SizedBox(height: 1),

                    // ── 설정 ──
                    _buildSection('설정', [
                      _DarkMenuItem(icon: Icons.notifications_outlined, label: '알림 설정',
                        color: _textSec,
                        onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()))),
                      _DarkMenuItem(icon: Icons.lock_outline, label: '개인정보 설정',
                        color: _textSec,
                        onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const PrivacySettingsScreen()))),
                      if (isLoggedIn)
                        _DarkMenuItem(
                          icon: Icons.logout,
                          label: '로그아웃',
                          color: Colors.red.withOpacity(0.8),
                          onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const LogoutScreen())),
                        ),
                    ]),

                    const SizedBox(height: 40),

                    // MOINCAR 버전 정보
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        children: [
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(text: 'MOIN',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
                                    color: Colors.white38)),
                                TextSpan(text: 'CAR',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
                                    color: Color(0xFFFF6B35), letterSpacing: 1)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('v50.0.0 · MOINCAR 모빌리티 플랫폼',
                            style: TextStyle(fontSize: 11, color: _textSec.withOpacity(0.5))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<_DarkMenuItem> items) {
    return Container(
      color: _card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Text(title,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                color: _textSec.withOpacity(0.8), letterSpacing: 0.5)),
          ),
          const Divider(color: Color(0xFF1E3A5F), height: 1, indent: 16, endIndent: 16),
          ...items.map((item) => _buildMenuTile(item)),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildMenuTile(_DarkMenuItem item) {
    return InkWell(
      onTap: item.onTap,
      splashColor: _accent.withOpacity(0.1),
      child: Opacity(
        opacity: item.disabled ? 0.45 : 1.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, size: 18, color: item.color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(item.label,
                  style: TextStyle(
                    fontSize: 14,
                    color: item.disabled ? _textSec.withOpacity(0.4) : _textPri,
                    fontWeight: FontWeight.w500,
                  )),
              ),
              if (item.badge != null)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (item.badgeColor ?? _accent).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: (item.badgeColor ?? _accent).withOpacity(0.4)),
                  ),
                  child: Text(item.badge!,
                    style: TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w700,
                      color: item.badgeColor ?? _accent)),
                ),
              if (item.disabled)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _border.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('점포 등록 후',
                    style: TextStyle(fontSize: 9, color: _textSec.withOpacity(0.5))),
                )
              else
                Icon(Icons.chevron_right, size: 16, color: _textSec.withOpacity(0.4)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DarkMenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final bool disabled;
  final String? badge;
  final Color? badgeColor;
  final VoidCallback onTap;
  _DarkMenuItem({
    required this.icon,
    required this.label,
    required this.color,
    this.disabled = false,
    this.badge,
    this.badgeColor,
    required this.onTap,
  });
}

// _MenuItem 제거됨 (미사용)

// ==================== 알림 ====================
// ==================== 알림 게시판 ====================
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});
  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> get _allNotifs {
    final List<Map<String, dynamic>> result = [];

    // 1) 신청내역 / 견적도착 → AppState estimateRequests에서 동적 생성
    AppState().initDummyEstimates();
    for (final req in AppState().estimateRequests) {
      if (req.bidCount > 0) {
        result.add({
          'title': '견적서 ${req.bidCount}건 도착!',
          'body': '${req.carName} · ${req.repairType}\n${req.bidCount}개 점포에서 견적을 보냈습니다. 지금 확인하세요!',
          'date': DateTime.now().toString().substring(0, 10),
          'time': '방금 전',
          'icon': '📬',
          'read': false,
          'category': '견적',
          'route': '/quote-received',
        });
      } else {
        result.add({
          'title': '견적 신청 접수됨',
          'body': '${req.carName} · ${req.repairType}\n근처 점포에서 견적을 검토 중입니다.',
          'date': DateTime.now().toString().substring(0, 10),
          'time': '방금 전',
          'icon': '📋',
          'read': false,
          'category': '견적',
          'route': '/quote-received',
        });
      }
    }

    // 2) AppState 실시간 인앱 알림 (기타 알림)
    for (final n in AppState().inAppNotifications) {
      result.add({
        'title': n['title'] ?? '',
        'body': n['body'] ?? '',
        'date': DateTime.now().toString().substring(0, 10),
        'time': '방금 전',
        'icon': '🔔',
        'read': false,
        'category': '알림',
        'route': '/notification',
      });
    }

    // 3) 정적 알림 목록
    result.addAll(_notifs);
    return result;
  }

  final List<Map<String, dynamic>> _notifs = [
    {
      'title': '새로운 견적서가 도착했습니다',
      'body': '주변 정비점포 3곳에서 견적서를 보냈습니다.\n\n• KAA 수성 협회인증 정비센터 — 270,000원\n• 프리미엄 바디케어 정비소 — 380,000원\n• KAA 스피드 경정비 — 180,000원\n\n지금 견적서를 확인하고 예약을 확정하세요!',
      'date': '2026-04-18',
      'time': '방금 전',
      'icon': '📬',
      'read': false,
      'category': '견적',
      'route': '/quote-received',
    },
    {
      'title': '견적 요청 접수',
      'body': 'MOINCAR 프리미엄 정비소에서 견적이 도착했습니다.\n\n견적 금액: 85,000원\n작업 내용: 엔진오일 교환 + 에어필터 교체\n예상 소요 시간: 1시간\n\n지금 바로 확인하고 예약을 확정하세요.',
      'date': '2025-04-12',
      'time': '1시간 전',
      'icon': '📋',
      'read': false,
      'category': '견적',
    },
    {
      'title': '쿠폰 만료 예정',
      'body': '엔진오일 20% 할인 쿠폰이 3일 후 만료됩니다.\n\n• 쿠폰명: 엔진오일 교환 20% 할인\n• 유효기간: 2025-04-15\n• 사용 가능 점포: MOINCAR 추천 전체 점포\n\n만료 전에 꼭 사용하세요!',
      'date': '2025-04-12',
      'time': '1시간 전',
      'icon': '🎟️',
      'read': false,
      'category': '쿠폰',
    },
    {
      'title': 'MOINCAR 인증 완료',
      'body': 'MOINCAR 추천 정비소가 공식 인증 완료되었습니다.\n\n인증 점포명: 대구 수성구 프리미엄 정비소\n인증 유효기간: 2025.04 ~ 2026.04\n인증 등급: MOINCAR 골드 인증\n\n인증 점포에서는 특별 할인 혜택이 제공됩니다.',
      'date': '2025-04-10',
      'time': '2일 전',
      'icon': '✅',
      'read': true,
      'category': '인증',
    },
    {
      'title': '전기차 보조금 변경 안내',
      'body': '2025년 전기차 국고 보조금이 변경되었습니다.\n\n주요 변경사항:\n• 소형 전기차: 최대 500만원 → 400만원\n• 중형 전기차: 최대 800만원 → 700만원\n• 지자체 추가 보조금은 별도 확인 필요\n\n자세한 내용은 환경부 보조금 조회 시스템에서 확인하세요.',
      'date': '2025-04-09',
      'time': '3일 전',
      'icon': '📰',
      'read': true,
      'category': '뉴스',
    },
    {
      'title': '정비 예약 리마인더',
      'body': '내일 오전 10시 정기 점검 예약이 있습니다.\n\n예약 점포: MOINCAR 추천 정비소\n예약 시간: 2025-04-13 10:00\n서비스: 엔진오일 교환 + 타이어 점검\n\n예약 취소/변경은 예약 시간 2시간 전까지 가능합니다.',
      'date': '2025-04-08',
      'time': '4일 전',
      'icon': '🔔',
      'read': true,
      'category': '예약',
    },
  ];

  final Set<int> _expanded = {};

  int get _unreadCount => _allNotifs.where((n) => !(n['read'] as bool)).length;

  void _markAllRead() {
    setState(() {
      for (final n in _allNotifs) n['read'] = true;
    });
    AppState().updateNotificationCount(0);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: _mBg, statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: _mBg,
        body: Column(
          children: [
            // 상단바
            Container(
              color: _mCard,
              padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 10, 16, 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text('알림',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
                  if (_unreadCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: _mOrange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('$_unreadCount',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                  ],
                  const Spacer(),
                  if (_unreadCount > 0)
                    GestureDetector(
                      onTap: _markAllRead,
                      child: Text('모두 읽음',
                        style: TextStyle(fontSize: 12, color: _mAccent, fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
            ),
            Expanded(
              child: _allNotifs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔕', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text('알림이 없습니다', style: TextStyle(fontSize: 16, color: _mTextSec)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _allNotifs.length,
                    itemBuilder: (_, i) {
                      final n = _allNotifs[i];
                      final isRead = n['read'] as bool;
                      final isExpanded = _expanded.contains(i);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (!isRead) {
                              n['read'] = true;
                              final unread = _allNotifs.where((n) => !(n['read'] as bool)).length;
                              AppState().updateNotificationCount(unread);
                            }
                            if (isExpanded) {
                              _expanded.remove(i);
                            } else {
                              _expanded.add(i);
                            }
                          });
                          // route 있으면 해당 페이지로, 없으면 카테고리별 이동
                          final route = n['route'] as String?;
                          if (route != null && route.isNotEmpty && route != '/notification') {
                            Navigator.pushNamed(context, route);
                          } else if (n['category'] == '견적') {
                            Navigator.pushNamed(context, '/quote-received');
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isRead ? _mCard : const Color(0xFF0D1F3A),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isRead ? _mBorder : _mAccent.withOpacity(0.4),
                              width: isRead ? 1 : 1.5),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 아이콘 + 미읽음 도트
                                    Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Text(n['icon'] as String,
                                          style: const TextStyle(fontSize: 22)),
                                        if (!isRead)
                                          Positioned(
                                            right: -4, top: -4,
                                            child: Container(
                                              width: 8, height: 8,
                                              decoration: const BoxDecoration(
                                                color: _mOrange,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              // 카테고리 뱃지
                                              Container(
                                                margin: const EdgeInsets.only(right: 6),
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: _mAccent.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(n['category'] as String,
                                                  style: const TextStyle(fontSize: 9, color: _mAccent,
                                                    fontWeight: FontWeight.w600)),
                                              ),
                                              if (!isRead)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: _mOrange.withOpacity(0.15),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: const Text('NEW',
                                                    style: TextStyle(fontSize: 9, color: _mOrange,
                                                      fontWeight: FontWeight.w700)),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(n['title'] as String,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                                              color: isRead ? _mTextPri : Colors.white)),
                                          const SizedBox(height: 3),
                                          if (!isExpanded)
                                            Text(
                                              (n['body'] as String).split('\n').first,
                                              style: TextStyle(fontSize: 12, color: _mTextSec),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(n['time'] as String,
                                          style: TextStyle(fontSize: 10, color: _mTextSec.withOpacity(0.6))),
                                        const SizedBox(height: 8),
                                        Icon(
                                          isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                          color: _mTextSec.withOpacity(0.5), size: 18),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // 확장 상세 내용
                              if (isExpanded) ...[
                                Divider(color: _mBorder, height: 1),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(n['body'] as String,
                                        style: TextStyle(fontSize: 13, color: _mTextSec, height: 1.7)),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_today, size: 12, color: _mTextSec.withOpacity(0.5)),
                                          const SizedBox(width: 4),
                                          Text(n['date'] as String,
                                            style: TextStyle(fontSize: 11, color: _mTextSec.withOpacity(0.5))),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
    );
  }
}


// ==================== 점포 등록 (다크테마 + AI 애니메이션 + 1~3장 사진) ====================
// ==================== 점포 견적신청함 ====================
class ShopInboxScreen extends StatefulWidget {
  const ShopInboxScreen({super.key});
  @override
  State<ShopInboxScreen> createState() => _ShopInboxScreenState();
}

class _ShopInboxScreenState extends State<ShopInboxScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ── 색상 팔레트 ──
  static const Color _bg    = Color(0xFF020810);
  static const Color _card  = Color(0xFF0D1B2A);
  static const Color _card2 = Color(0xFF1A2D42);
  static const Color _accent= Color(0xFF4FC3F7);
  static const Color _orange= Color(0xFFFF6B35);
  static const Color _green = Color(0xFF10B981);
  static const Color _border= Color(0xFF1E3A5F);
  static const Color _t1    = Colors.white;
  static const Color _t2    = Color(0xFF8FA8C0);
  static const Color _blue  = Color(0xFF2979FF);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── 더미 신청 데이터 ─────────────────────────────────────────
  // category: 'repair' | 'tire' | 'usedcar'
  final List<Map<String, dynamic>> _dummyRequests = [
    // ── 정비 요청 ──
    {
      'id': 'req001', 'category': 'repair',
      'carName': '현대 아반떼', 'carNumber': '123가 4567',
      'repairType': '엔진오일 교환',
      'symptoms': '오일 경고등 점등, 교환 필요',
      'customerName': '김**', 'receivedAt': '방금 전',
      'status': 'new',
      'partCost': null, 'laborCost': null, 'totalCost': null,
      'estimatedTime': null, 'message': null,
      'customerPhone': null, 'schedule': null, 'isFromApp': false,
    },
    {
      'id': 'req002', 'category': 'repair',
      'carName': 'BMW 5시리즈', 'carNumber': '456나 7890',
      'repairType': '브레이크 패드 교환',
      'symptoms': '제동 시 소음 발생',
      'customerName': '이**', 'receivedAt': '30분 전',
      'status': 'quoted',
      'partCost': 150000, 'laborCost': 50000, 'totalCost': 200000,
      'estimatedTime': '약 2시간',
      'message': '정품 패드 사용, 당일 작업 가능합니다.',
      'customerPhone': null, 'schedule': null, 'isFromApp': false,
    },
    {
      'id': 'req003', 'category': 'repair',
      'carName': '기아 K5', 'carNumber': '789다 1234',
      'repairType': '하체 점검',
      'symptoms': '주행 중 이상 소음, 직진 흔들림',
      'customerName': '박**', 'receivedAt': '1시간 전',
      'status': 'confirmed',
      'partCost': 80000, 'laborCost': 40000, 'totalCost': 120000,
      'estimatedTime': '약 1시간',
      'message': '정밀 하체 점검 후 부품 교체 여부 결정합니다.',
      'customerPhone': '010-****-5678', 'schedule': '오늘 오후 3시', 'isFromApp': false,
    },
    // ── 타이어 요청 ──
    {
      'id': 'tire001', 'category': 'tire',
      'carName': '현대 그랜저', 'carNumber': '234라 5678',
      'repairType': '타이어 교체',
      'symptoms': '245/45/R18 · 4개 · 신품 요청',
      'tireSpec': '245/45/R18', 'tireQty': 4, 'isUsed': false,
      'customerName': '최**', 'receivedAt': '15분 전',
      'status': 'new',
      'partCost': null, 'laborCost': null, 'totalCost': null,
      'tireBrand': null, 'estimatedTime': null, 'message': null,
      'customerPhone': null, 'schedule': null, 'isFromApp': false,
    },
    {
      'id': 'tire002', 'category': 'tire',
      'carName': '기아 스팅어', 'carNumber': '567마 8901',
      'repairType': '타이어 재고 문의',
      'symptoms': '225/40/R19 · 2개 · 중고 가능',
      'tireSpec': '225/40/R19', 'tireQty': 2, 'isUsed': true,
      'customerName': '정**', 'receivedAt': '2시간 전',
      'status': 'quoted',
      'partCost': 140000, 'laborCost': 20000, 'totalCost': 160000,
      'tireBrand': '금호 타이어', 'estimatedTime': '약 40분',
      'message': '금호 중고 타이어 재고 있습니다. 상태 양호합니다.',
      'customerPhone': null, 'schedule': null, 'isFromApp': false,
    },
    // ── 중고차 요청 ──
    {
      'id': 'used001', 'category': 'usedcar',
      'carName': '현대 소나타 2022', 'carNumber': '미정',
      'repairType': '중고차 구매 문의',
      'symptoms': '예산 1,500만원 이하, 주행 5만km 이하',
      'customerName': '오**', 'receivedAt': '3시간 전',
      'status': 'new',
      'partCost': null, 'laborCost': null, 'totalCost': null,
      'estimatedTime': null, 'message': null,
      'customerPhone': null, 'schedule': null, 'isFromApp': false,
    },
  ];

  // ── AppState의 실제 요청을 점포 인박스 형식으로 변환 ──
  List<Map<String, dynamic>> get _allRequests {
    final appRequests = AppState().estimateRequests
      .where((r) => r.status == RepairStatus.pending ||
                    r.status == RepairStatus.bidding ||
                    r.status == RepairStatus.received)
      .map((r) => <String, dynamic>{
        'id': r.requestId, 'category': 'repair',
        'carName': r.carName, 'carNumber': r.carNumber,
        'repairType': r.repairType,
        'symptoms': r.symptoms.join(', '),
        'customerName': '앱 사용자',
        'receivedAt': _timeAgoFromDate(r.createdAt),
        'status': r.bids.isNotEmpty ? 'quoted' : 'new',
        'partCost': r.bids.isNotEmpty ? r.bids.first.partsCost : null,
        'laborCost': r.bids.isNotEmpty ? r.bids.first.laborCost : null,
        'totalCost': r.bids.isNotEmpty ? r.bids.first.totalCost : null,
        'estimatedTime': r.bids.isNotEmpty ? r.bids.first.estimatedTime : null,
        'message': r.bids.isNotEmpty ? r.bids.first.ownerMessage : null,
        'customerPhone': null, 'schedule': null, 'isFromApp': true,
        'memo': r.memo,
      }).toList();
    // 타이어 앱 요청 변환
    final tireRequests = AppState().tireRequests
      .where((t) => t.status == TireRequestStatus.bidding ||
                    t.status == TireRequestStatus.received)
      .map((t) => <String, dynamic>{
        'id': t.requestId, 'category': 'tire',
        'carName': t.carName, 'carNumber': '',
        'repairType': '타이어 견적',
        'symptoms': '${t.tireWidth}/${t.tireAspect}/R${t.tireInch} · ${t.isUsed ? '중고' : '신품'}',
        'tireSpec': '${t.tireWidth}/${t.tireAspect}/R${t.tireInch}',
        'tireQty': 4, 'isUsed': t.isUsed,
        'customerName': '앱 사용자',
        'receivedAt': _timeAgoFromDate(t.createdAt),
        'status': t.bids.isNotEmpty ? 'quoted' : 'new',
        'partCost': t.bids.isNotEmpty ? t.bids.first.pricePerTire * t.bids.first.quantity : null,
        'laborCost': t.bids.isNotEmpty ? 20000 : null,
        'totalCost': t.bids.isNotEmpty ? t.bids.first.totalCost : null,
        'tireBrand': t.bids.isNotEmpty ? t.bids.first.tireBrand : null,
        'estimatedTime': t.bids.isNotEmpty ? t.bids.first.estimatedTime : null,
        'message': t.bids.isNotEmpty ? t.bids.first.memo : null,
        'customerPhone': null, 'schedule': null, 'isFromApp': true,
      }).toList();
    return [...appRequests, ...tireRequests, ..._dummyRequests];
  }

  // 탭별 필터된 요청 목록
  List<Map<String, dynamic>> get _currentTabRequests {
    final all = _allRequests;
    switch (_tabController.index) {
      case 0: return all.where((r) => r['category'] == 'repair').toList();
      case 1: return all.where((r) => r['category'] == 'tire').toList();
      case 2: return all.where((r) => r['category'] == 'usedcar').toList();
      default: return all;
    }
  }

  String _timeAgoFromDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    return '${diff.inDays}일 전';
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'new':       return '신규 신청';
      case 'quoted':    return '견적 발송';
      case 'confirmed': return '확정 완료';
      case 'done':      return '거래 완료';
      default:          return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'new':       return _blue;
      case 'quoted':    return _orange;
      case 'confirmed': return _green;
      case 'done':      return const Color(0xFF607D8B);
      default:          return Colors.grey;
    }
  }

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'tire':    return Icons.tire_repair_rounded;
      case 'usedcar': return Icons.directions_car_rounded;
      default:        return Icons.build_circle_rounded;
    }
  }

  // ── 견적 작성 바텀시트 ───────────────────────────────────────
  void _showQuoteDialog(Map<String, dynamic> req) {
    final cat = req['category'] as String? ?? 'repair';
    final partCtrl   = TextEditingController(text: req['partCost']?.toString() ?? '');
    final laborCtrl  = TextEditingController(text: req['laborCost']?.toString() ?? '');
    final timeCtrl   = TextEditingController(text: req['estimatedTime'] ?? '');
    final msgCtrl    = TextEditingController(text: req['message'] ?? '');
    final brandCtrl  = TextEditingController(text: req['tireBrand'] ?? '');
    final schedCtrl  = TextEditingController(text: req['schedule'] ?? '');
    String? selectedSchedule;

    // 일정 후보 (오늘 ~ 3일)
    final now = DateTime.now();
    final schedCandidates = List.generate(4, (i) {
      final d = now.add(Duration(days: i));
      final label = i == 0 ? '오늘' : i == 1 ? '내일' : '${d.month}/${d.day}(${['일','월','화','수','목','금','토'][d.weekday % 7]})';
      return '$label ${['오전 10시', '오후 1시', '오후 3시', '오후 5시'][i % 4]}';
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20,
              MediaQuery.of(context).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              // 헤더
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_categoryIcon(cat), color: _accent, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('견적서 작성', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _t1)),
                  Text('${req['carName']} · ${req['repairType']}',
                    style: TextStyle(fontSize: 12, color: _t2)),
                ])),
              ]),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFF1E3A5F)),
              const SizedBox(height: 12),

              // 타이어: 브랜드 필드
              if (cat == 'tire') ...[
                _inboxLabel('타이어 브랜드'),
                _inboxField(brandCtrl, '예: 한국, 금호, 미쉐린, 넥센', TextInputType.text),
                const SizedBox(height: 12),
              ],

              // 금액 섹션
              _inboxLabel(cat == 'tire' ? '타이어 단가 (원/개)' : '부품비 (원)'),
              _inboxField(partCtrl, '숫자만 입력', TextInputType.number),
              const SizedBox(height: 10),
              _inboxLabel(cat == 'tire' ? '공임비 (원)' : '공임비 (원)'),
              _inboxField(laborCtrl, '숫자만 입력', TextInputType.number),
              const SizedBox(height: 10),
              _inboxLabel('예상 작업 시간'),
              _inboxField(timeCtrl, '예: 약 1시간 30분', TextInputType.text),
              const SizedBox(height: 10),
              _inboxLabel('고객에게 전달할 메시지'),
              _inboxField(msgCtrl, '재고 현황, 특이사항 등', TextInputType.multiline),
              const SizedBox(height: 14),

              // 일정 선택
              _inboxLabel('방문 가능 일정 제안'),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8,
                children: schedCandidates.map((s) => GestureDetector(
                  onTap: () => setSt(() => selectedSchedule = s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: selectedSchedule == s
                          ? _accent.withOpacity(0.2) : _card2,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selectedSchedule == s ? _accent : _border),
                    ),
                    child: Text(s, style: TextStyle(
                      fontSize: 12, color: selectedSchedule == s ? _accent : _t2,
                      fontWeight: selectedSchedule == s
                          ? FontWeight.w700 : FontWeight.w400)),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 8),
              // 직접 입력도 가능
              _inboxField(schedCtrl, '또는 직접 일정 입력', TextInputType.text),
              const SizedBox(height: 20),

              // 발송 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.send_rounded, size: 18, color: Colors.white),
                  label: const Text('견적 발송하기',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                  onPressed: () {
                    final part = int.tryParse(partCtrl.text.replaceAll(',', '')) ?? 0;
                    final labor = int.tryParse(laborCtrl.text.replaceAll(',', '')) ?? 0;
                    final finalSched = selectedSchedule ?? schedCtrl.text;
                    setState(() {
                      req['partCost']      = part;
                      req['laborCost']     = labor;
                      req['totalCost']     = cat == 'tire'
                          ? part * (req['tireQty'] as int? ?? 4) + labor
                          : part + labor;
                      req['estimatedTime'] = timeCtrl.text;
                      req['message']       = msgCtrl.text;
                      if (cat == 'tire') req['tireBrand'] = brandCtrl.text;
                      if (finalSched.isNotEmpty) req['schedule'] = finalSched;
                      req['status']        = 'quoted';
                    });
                    Navigator.pop(ctx);
                    // ── 앱 사용자 요청이면 AppState.shopSendBid() 호출 → 배너 즉시 전환 ──
                    if (req['isFromApp'] == true) {
                      final reqId  = req['id'] as String? ?? '';
                      final totalC = req['totalCost'] as int? ?? 0;
                      final sched  = req['schedule']  as String? ?? '';
                      if (cat == 'tire') {
                        // 타이어 견적 발송
                        final tireSpec = req['tireSpec'] as String? ?? '215/65/R15';
                        final specParts = tireSpec.split('/');
                        final tw = specParts.isNotEmpty ? specParts[0] : '215';
                        final ta = specParts.length > 1 ? specParts[1] : '65';
                        final ti = specParts.length > 2
                            ? specParts[2].replaceAll('R', '')
                            : '15';
                        AppState().shopSendTireBid(
                          requestId: reqId,
                          bid: TireBid(
                            bidId: 'SB-$reqId-${DateTime.now().millisecondsSinceEpoch}',
                            storeId: 1,
                            storeName: '관리자 점포',
                            storeDistance: '0.5km',
                            storeRating: 5.0,
                            tireWidth: tw,
                            tireAspect: ta,
                            tireInch: ti,
                            tireBrand: brandCtrl.text.isNotEmpty ? brandCtrl.text : '미정',
                            isUsed: req['isUsed'] as bool? ?? false,
                            pricePerTire: (req['tireQty'] as int? ?? 4) > 0
                                ? part ~/ (req['tireQty'] as int? ?? 4)
                                : part,
                            quantity: req['tireQty'] as int? ?? 4,
                            totalCost: totalC,
                            estimatedTime: timeCtrl.text.isNotEmpty ? timeCtrl.text : '1시간',
                            memo: msgCtrl.text,
                            storePhone: '',
                            createdAt: DateTime.now(),
                          ),
                        );
                      } else {
                        // 정비 견적 발송
                        AppState().shopSendBid(
                          requestId: reqId,
                          bid: QuoteBid(
                            bidId: 'SB-${reqId}-${DateTime.now().millisecondsSinceEpoch}',
                            storeId: 1,
                            storeName: '관리자 점포',
                            storeDistance: '0.5km',
                            storeRating: 5.0,
                            storeBadge: 'KAA 인증',
                            storeImage: '',
                            partsCost: part,
                            laborCost: labor,
                            totalCost: totalC,
                            estimatedTime: timeCtrl.text.isNotEmpty ? timeCtrl.text : '2시간',
                            memo: msgCtrl.text,
                            ownerMessage: msgCtrl.text,
                            availableSchedules: sched.isNotEmpty ? [sched] : [],
                            selectedSchedule: sched.isNotEmpty ? sched : null,
                            createdAt: DateTime.now(),
                            storePhone: '',
                          ),
                        );
                      }
                    }
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text('🎉 견적서가 고객에게 발송되었습니다'),
                      backgroundColor: _blue,
                      behavior: SnackBarBehavior.floating,
                    ));
                  },
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _inboxLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text,
      style: TextStyle(fontSize: 12, color: _t2, fontWeight: FontWeight.w600)),
  );

  Widget _inboxField(TextEditingController ctrl, String hint, TextInputType type) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      maxLines: type == TextInputType.multiline ? 3 : 1,
      style: TextStyle(color: _t1, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: _t2, fontSize: 13),
        filled: true, fillColor: _card2,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: _border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: _border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: _accent)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  // ── 거래 최종 확인 ────────────────────────────────────────────
  void _confirmDeal(Map<String, dynamic> req) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _card2,
        title: Text('✅ 거래 최종 확인',
            style: TextStyle(color: _t1, fontWeight: FontWeight.w800)),
        content: Text(
          '${req['customerName']} 고객과의 거래를 확정하시겠습니까?\n\n'
          '📅 일정: ${req['schedule'] ?? '미정'}\n'
          '📞 연락처: ${req['customerPhone'] ?? '미공개'}',
          style: TextStyle(color: _t2, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소', style: TextStyle(color: _t2))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _green),
            onPressed: () {
              setState(() => req['status'] = 'done');
              // AppState에 확정 완료 + 정비이력 저장
              if (req['isFromApp'] == true) {
                final appState = AppState();
                appState.updateNotificationCount(appState.notificationCount + 1);
                final reqId = req['id'] as String? ?? '';
                final sched = req['schedule'] as String? ?? '';
                // matchRequest 호출 → 경쟁 견적 거래완료 처리 + 정비이력 저장
                final matchReq = appState.estimateRequests.where((e) => e.requestId == reqId).toList();
                if (matchReq.isNotEmpty) {
                  final bidId = matchReq.first.bids.isNotEmpty
                      ? matchReq.first.bids.first.bidId
                      : 'SB-$reqId';
                  appState.matchRequest(reqId, bidId, selectedSchedule: sched.isNotEmpty ? sched : null);
                }
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('🎊 거래가 확정되었습니다! 정비 이력이 마이페이지에 저장됩니다'),
                backgroundColor: _green,
                behavior: SnackBarBehavior.floating,
              ));
            },
            child: const Text('확정 완료',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ── 금액 포맷 헬퍼 ──
  String _fmt(int n) => n.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  // ── 요청 카드 ──────────────────────────────────────────────
  Widget _buildRequestCard(Map<String, dynamic> req) {
    final status = req['status'] as String;
    final cat    = req['category'] as String? ?? 'repair';
    final isDone = status == 'done';
    final sc     = _statusColor(status);
    return Opacity(
      opacity: isDone ? 0.55 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _card2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: sc.withOpacity(0.35)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── 헤더 ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: sc.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_categoryIcon(cat), color: sc, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(req['carName'] ?? '', style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w800, color: _t1)),
                const SizedBox(height: 2),
                Text('${req['repairType']} · ${req['receivedAt']}',
                  style: TextStyle(fontSize: 11, color: _t2)),
              ])),
              // 상태 배지
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: sc.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: sc.withOpacity(0.5)),
                ),
                child: Text(_statusLabel(status),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: sc)),
              ),
            ]),
          ),

          // ── 증상 / 스펙 ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(children: [
                Icon(Icons.info_outline_rounded, size: 13, color: _t2),
                const SizedBox(width: 6),
                Expanded(child: Text(req['symptoms'] ?? '',
                  style: TextStyle(fontSize: 12, color: _t2))),
              ]),
            ),
          ),

          // ── 견적 내역 (발송 후) ──
          if (req['partCost'] != null) Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _orange.withOpacity(0.25)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (cat == 'tire' && req['tireBrand'] != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('브랜드: ${req['tireBrand']}',
                      style: TextStyle(fontSize: 12, color: _t1, fontWeight: FontWeight.w600)),
                  ),
                Row(children: [
                  Expanded(child: Text(
                    cat == 'tire'
                      ? '단가: ${_fmt(req['partCost'] as int)}원'
                      : '부품비: ${_fmt(req['partCost'] as int)}원',
                    style: TextStyle(fontSize: 12, color: _t2))),
                  Text('공임비: ${_fmt(req['laborCost'] as int)}원',
                    style: TextStyle(fontSize: 12, color: _t2)),
                ]),
                const SizedBox(height: 4),
                Row(children: [
                  Expanded(child: Text(
                    '합계: ${_fmt(req['totalCost'] as int)}원',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _orange))),
                  if (req['estimatedTime'] != null)
                    Text('⏱ ${req['estimatedTime']}',
                      style: TextStyle(fontSize: 11, color: _t2)),
                ]),
                if (req['schedule'] != null) ...[
                  const SizedBox(height: 4),
                  Text('📅 제안 일정: ${req['schedule']}',
                    style: TextStyle(fontSize: 12, color: _accent)),
                ],
                if (req['message'] != null && (req['message'] as String).isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text('"${req['message']}"',
                    style: TextStyle(fontSize: 12, color: _t2, fontStyle: FontStyle.italic)),
                ],
              ]),
            ),
          ),

          // ── 확정 정보 ──
          if (status == 'confirmed' || status == 'done') Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _green.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _green.withOpacity(0.3)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(status == 'done' ? '✅ 거래 완료' : '🔔 고객 확정 완료',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _green)),
                const SizedBox(height: 4),
                Text('📅 일정: ${req['schedule'] ?? '미정'}',
                  style: TextStyle(fontSize: 12, color: _t2)),
                if (req['customerPhone'] != null)
                  Text('📞 연락처: ${req['customerPhone']}',
                    style: TextStyle(fontSize: 12, color: _t2)),
              ]),
            ),
          ),

          // ── 액션 버튼 ──
          if (!isDone) Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Row(children: [
              if (status == 'new') Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _blue,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.edit_note_rounded, size: 16, color: Colors.white),
                  label: const Text('견적 작성',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                  onPressed: () => _showQuoteDialog(req),
                ),
              ),
              if (status == 'quoted') ...[
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _orange.withOpacity(0.15),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: _orange.withOpacity(0.4)),
                      ),
                    ),
                    icon: Icon(Icons.edit_rounded, size: 14, color: _orange),
                    label: Text('수정',
                      style: TextStyle(color: _orange, fontWeight: FontWeight.w700, fontSize: 13)),
                    onPressed: () => _showQuoteDialog(req),
                  ),
                ),
              ],
              if (status == 'confirmed') ...[
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.check_circle_rounded, size: 16, color: Colors.white),
                    label: const Text('거래 완료 확인',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                    onPressed: () => _confirmDeal(req),
                  ),
                ),
              ],
            ]),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _card,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: AnimatedBuilder(
          animation: AppState(),
          builder: (_, __) {
            final newCount = _allRequests.where((r) => r['status'] == 'new').length;
            return Row(mainAxisSize: MainAxisSize.min, children: [
              const Text('점포 신청함',
                style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
              if (newCount > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: _blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('NEW $newCount',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                ),
              ],
            ]);
          },
        ),
        centerTitle: true,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: _accent,
          indicatorWeight: 2.5,
          labelColor: _accent,
          unselectedLabelColor: _t2,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
          tabs: [
            Tab(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.build_circle_rounded, size: 15),
                const SizedBox(width: 4),
                const Text('정비'),
                const SizedBox(width: 4),
                _tabBadge('repair'),
              ]),
            ),
            Tab(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.tire_repair_rounded, size: 15),
                const SizedBox(width: 4),
                const Text('타이어'),
                const SizedBox(width: 4),
                _tabBadge('tire'),
              ]),
            ),
            Tab(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.directions_car_rounded, size: 15),
                const SizedBox(width: 4),
                const Text('중고차'),
                const SizedBox(width: 4),
                _tabBadge('usedcar'),
              ]),
            ),
          ],
        ),
      ),
      body: AnimatedBuilder(
        animation: AppState(),
        builder: (context, _) => TabBarView(
          controller: _tabController,
          children: [
            _buildTabContent('repair'),
            _buildTabContent('tire'),
            _buildTabContent('usedcar'),
          ],
        ),
      ),
    );
  }

  Widget _tabBadge(String cat) {
    final count = _allRequests
        .where((r) => r['category'] == cat && r['status'] == 'new').length;
    if (count == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: _blue, borderRadius: BorderRadius.circular(8)),
      child: Text('$count',
        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildTabContent(String cat) {
    final reqs = _allRequests.where((r) => r['category'] == cat).toList();
    if (reqs.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(_categoryIcon(cat), size: 48, color: _border),
        const SizedBox(height: 12),
        Text('신규 신청이 없습니다',
          style: TextStyle(fontSize: 14, color: _t2, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text('고객이 견적 요청 시 여기에 표시됩니다',
          style: TextStyle(fontSize: 12, color: _t2.withOpacity(0.6))),
      ]));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 100),
      itemCount: reqs.length,
      itemBuilder: (_, i) => _buildRequestCard(reqs[i]),
    );
  }
}

class StoreRegisterScreen extends StatefulWidget {
  const StoreRegisterScreen({super.key});
  @override
  State<StoreRegisterScreen> createState() => _StoreRegisterScreenState();
}

class _StoreRegisterScreenState extends State<StoreRegisterScreen>
    with TickerProviderStateMixin {
  // 스텝: 0=사업자확인, 1=STEP1사진(간판외관), 2=STEP2사진(내부전시장), 3=STEP3사진(대표차량), 4=AI생성중, 5=AI결과, 6=등록완료
  int _step = 0;

  final TextEditingController _bizNumCtrl = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  // 각 단계별 사진 목록 (최대 3장씩)
  final List<File> _photos1 = []; // STEP 1: 간판·외관 (필수)
  final List<File> _photos2 = []; // STEP 2: 내부·전시장 (선택)
  final List<File> _photos3 = []; // STEP 3: 대표차량·서비스 (선택)

  // 현재 스텝의 사진 목록 참조
  List<File> get _currentPhotos {
    if (_step == 1) return _photos1;
    if (_step == 2) return _photos2;
    if (_step == 3) return _photos3;
    return [];
  }

  // 품질 검사 상태
  String? _qualityError;
  bool _isCheckingQuality = false;

  // AI 애니메이션
  late AnimationController _aiAnimCtrl;
  late Animation<double> _aiProgress;
  String _aiStatus = '';
  int _aiPhase = 0;
  static const _aiPhases = [
    '📷  업로드된 사진 분석 중...',
    '🏪  점포 정보 및 업종 추출 중...',
    '✍️  AI 소개글·태그라인 생성 중...',
    '📋  업종별 맞춤 페이지 구성 중...',
    '✅  점포 페이지 완성!',
  ];

  // 다크 테마 색상
  static const _bg = Color(0xFF020810);
  static const _card = Color(0xFF0D1B2A);
  static const _accent = Color(0xFF4FC3F7);
  static const _textPrimary = Colors.white;
  static const _textSecondary = Color(0xFFB0BEC5);
  static const _borderCol = Color(0xFF1E3A5F);

  @override
  void initState() {
    super.initState();
    _aiAnimCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 5));
    _aiProgress = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _aiAnimCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bizNumCtrl.dispose();
    _aiAnimCtrl.dispose();
    super.dispose();
  }

  void _prev() {
    if (_step == 0) { Navigator.pop(context); return; }
    setState(() => _step--);
  }

  Future<void> _pickImage(ImageSource source) async {
    final cur = _currentPhotos;
    if (cur.length >= 3) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이 단계에서 사진은 최대 3장까지 등록할 수 있습니다'), backgroundColor: Color(0xFF1565C0)),
      );
      return;
    }
    try {
      final XFile? picked = await _picker.pickImage(source: source, imageQuality: 85, maxWidth: 1280);
      if (picked == null) return;
      setState(() { _isCheckingQuality = true; _qualityError = null; });
      final file = File(picked.path);
      final size = await file.length();
      if (size < 5 * 1024) {
        setState(() { _isCheckingQuality = false; _qualityError = '사진 용량이 너무 작습니다. 더 선명한 사진을 선택해 주세요.'; });
        return;
      }
      setState(() { cur.add(file); _isCheckingQuality = false; _qualityError = null; });
    } catch (e) {
      setState(() => _isCheckingQuality = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사진을 가져올 수 없습니다: $e'), backgroundColor: Colors.red[700]),
      );
    }
  }

  void _removePhoto(int idx) => setState(() => _currentPhotos.removeAt(idx));

  void _goNextStep() {
    if (_step == 1 && _photos1.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('간판·외관 사진을 최소 1장 등록해 주세요 (필수)'), backgroundColor: Color(0xFFD32F2F)),
      );
      return;
    }
    setState(() => _step++);
  }

  void _startAiGeneration() {
    setState(() { _step = 4; _aiPhase = 0; _aiStatus = _aiPhases[0]; });
    _aiAnimCtrl.reset();
    _aiAnimCtrl.forward();
    for (int i = 1; i < _aiPhases.length; i++) {
      Future.delayed(Duration(milliseconds: 1000 * i), () {
        if (mounted) setState(() { _aiPhase = i; _aiStatus = _aiPhases[i]; });
      });
    }
    Future.delayed(const Duration(milliseconds: 5500), () {
      if (mounted) setState(() => _step = 5);
    });
  }

  List<File> get _allPhotos => [..._photos1, ..._photos2, ..._photos3];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopNav(),
            if (_step >= 1 && _step <= 3) _buildPhotoStepTabs(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNav() {
    const titles = [
      '사업자 확인', 'STEP 1 · 간판·외관 사진', 'STEP 2 · 내부·전시장 사진',
      'STEP 3 · 대표차량·서비스', 'AI 점포 페이지 생성 중', 'AI 결과 확인', '등록 완료',
    ];
    final title = _step < titles.length ? titles[_step] : '점포 등록';
    final progress = (_step + 1) / titles.length;
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
        child: Row(children: [
          GestureDetector(
            onTap: _prev,
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(10), border: Border.all(color: _borderCol)),
              child: const Icon(Icons.arrow_back_ios_new, size: 16, color: _textPrimary),
            ),
          ),
          Expanded(child: Text(title, textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textPrimary))),
          const SizedBox(width: 36),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: progress, minHeight: 3, backgroundColor: _borderCol,
              valueColor: const AlwaysStoppedAnimation<Color>(_accent)),
        ),
      ),
      const SizedBox(height: 4),
    ]);
  }

  Widget _buildPhotoStepTabs() {
    final steps = [
      {'label': 'STEP 1\n간판·외관', 'count': _photos1.length, 'required': true},
      {'label': 'STEP 2\n내부·전시장', 'count': _photos2.length, 'required': false},
      {'label': 'STEP 3\n대표차량', 'count': _photos3.length, 'required': false},
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(children: List.generate(3, (i) {
        final isActive = _step == i + 1;
        final count = steps[i]['count'] as int;
        final isRequired = steps[i]['required'] as bool;
        final isDone = count > 0;
        return Expanded(child: GestureDetector(
          onTap: () { if (i + 1 <= _step) setState(() => _step = i + 1); },
          child: Container(
            margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? _accent.withOpacity(0.15) : _card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isActive ? _accent : (isDone ? const Color(0xFF4CAF50) : _borderCol),
                width: isActive ? 1.5 : 1,
              ),
            ),
            child: Column(children: [
              Text(steps[i]['label'] as String,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, height: 1.3,
                  color: isActive ? _accent : (isDone ? const Color(0xFF81C784) : _textSecondary)),
              ),
              const SizedBox(height: 4),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(isDone ? Icons.check_circle : Icons.circle_outlined, size: 12,
                  color: isDone ? const Color(0xFF4CAF50) : (isRequired ? const Color(0xFFEF5350) : const Color(0xFF607D8B))),
                const SizedBox(width: 3),
                Text(count > 0 ? '${count}장' : (isRequired ? '필수' : '선택'),
                  style: TextStyle(fontSize: 10,
                    color: isDone ? const Color(0xFF81C784) : (isRequired ? const Color(0xFFEF5350) : _textSecondary))),
              ]),
            ]),
          ),
        ));
      })),
    );
  }

  Widget _buildBody() {
    switch (_step) {
      case 0: return _buildBizCheck();
      case 1: return _buildPhotoStep(stepNum: 1, title: '간판·외관 사진', subtitle: '점포 간판과 출입구가 보이는 정면 사진을 등록하세요.\n최소 1장 필수 · 최대 3장까지 등록 가능합니다.', icon: '🏪', accentColor: const Color(0xFF1565C0), isRequired: true, emptyHint: '간판·출입구가 보이는 정면 사진 (필수)', photos: _photos1, labels: const ['정면 외관 (필수)', '간판 클로즈업 (선택)', '야간·측면 외관 (선택)']);
      case 2: return _buildPhotoStep(stepNum: 2, title: '내부·전시장 사진', subtitle: '점포 내부, 상담 공간, 전시 차량 등을 촬영해 주세요.\n선택 사항이지만 등록 시 AI 품질이 높아집니다.', icon: '🏢', accentColor: const Color(0xFF00897B), isRequired: false, emptyHint: '내부 공간·전시장 사진 (선택)', photos: _photos2, labels: const ['내부 전경 (선택)', '전시 차량 (선택)', '상담 공간 (선택)']);
      case 3: return _buildPhotoStep(stepNum: 3, title: '대표차량·서비스 사진', subtitle: '주력 서비스 차량이나 정비 장면을 등록하세요.\n선택 사항이지만 등록 시 AI 품질이 높아집니다.', icon: '🚗', accentColor: const Color(0xFFE65100), isRequired: false, emptyHint: '대표 차량·서비스 사진 (선택)', photos: _photos3, labels: const ['대표 차량 (선택)', '서비스 장면 (선택)', '정비 환경 (선택)']);
      case 4: return _buildAiGenerating();
      case 5: return _buildAiResult();
      case 6: return _buildComplete();
      default: return const SizedBox();
    }
  }

  Widget _buildBizCheck() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 24),
        Container(
          width: double.infinity, padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0D2A4A), Color(0xFF1565C0)]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('🏪', style: TextStyle(fontSize: 38)),
            const SizedBox(height: 14),
            const Text('점포 등록 시작', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 8),
            Text('3단계로 사진을 촬영하면\nAI가 자동으로 업종별 점포 페이지를 만들어 드립니다',
              style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.85), height: 1.5)),
          ]),
        ),
        const SizedBox(height: 16),
        _bizStepCard('01', '간판·외관 사진', '점포 전면 (필수 1~3장)', '🏪', const Color(0xFF1565C0)),
        const SizedBox(height: 8),
        _bizStepCard('02', '내부·전시장 사진', '내부 공간 (선택 0~3장)', '🏢', const Color(0xFF00897B)),
        const SizedBox(height: 8),
        _bizStepCard('03', '대표차량·서비스', '주력 서비스 (선택 0~3장)', '🚗', const Color(0xFFE65100)),
        const SizedBox(height: 20),
        const Text('사업자등록번호', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textSecondary)),
        const SizedBox(height: 8),
        TextField(
          controller: _bizNumCtrl, keyboardType: TextInputType.number,
          style: const TextStyle(color: _textPrimary),
          decoration: InputDecoration(
            hintText: '000-00-00000', hintStyle: const TextStyle(color: Color(0xFF607D8B)),
            prefixIcon: const Icon(Icons.business_outlined, color: _accent, size: 20),
            filled: true, fillColor: _card,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _borderCol)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _borderCol)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _accent, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(10), border: Border.all(color: _borderCol)),
          child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('💡', style: TextStyle(fontSize: 14)), SizedBox(width: 8),
            Expanded(child: Text('사업자등록번호 10자리를 입력하면 국세청 DB에서 점포 정보를 자동으로 불러옵니다.',
              style: TextStyle(fontSize: 12, color: _textSecondary, height: 1.5))),
          ]),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity, height: 54,
          child: ElevatedButton(
            onPressed: () => setState(() => _step = 1),
            style: ElevatedButton.styleFrom(backgroundColor: _accent, foregroundColor: _bg, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
            child: const Text('사업자 조회 후 사진 등록 시작', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF020810))),
          ),
        ),
        const SizedBox(height: 40),
      ]),
    );
  }

  Widget _bizStepCard(String num, String title, String sub, String icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(12), border: Border.all(color: _borderCol)),
      child: Row(children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withOpacity(0.18), borderRadius: BorderRadius.circular(10)),
          child: Center(child: Text(icon, style: const TextStyle(fontSize: 18)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('STEP $num  $title', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _textPrimary)),
          Text(sub, style: const TextStyle(fontSize: 11, color: _textSecondary)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: color.withOpacity(0.18), borderRadius: BorderRadius.circular(8)),
          child: Text(num == '01' ? '필수' : '선택', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ),
      ]),
    );
  }

  Widget _buildPhotoStep({
    required int stepNum, required String title, required String subtitle,
    required String icon, required Color accentColor, required bool isRequired,
    required String emptyHint, required List<File> photos, required List<String> labels,
  }) {
    final totalPhotos = _photos1.length + _photos2.length + _photos3.length;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: accentColor.withOpacity(0.1), borderRadius: BorderRadius.circular(14), border: Border.all(color: accentColor.withOpacity(0.3))),
          child: Row(children: [
            Text(icon, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _textPrimary)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: _textSecondary, height: 1.4)),
            ])),
          ]),
        ),
        const SizedBox(height: 14),
        if (photos.isEmpty)
          _buildEmptySlot(emptyHint, accentColor)
        else ...[
          ...List.generate(photos.length, (i) => _buildPhotoItem(photos, i, i < labels.length ? labels[i] : '추가 사진', accentColor)),
          if (photos.length < 3) ...[const SizedBox(height: 10), _buildAddBtn(accentColor)],
        ],
        if (_qualityError != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.red.withOpacity(0.12), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.red.withOpacity(0.4))),
            child: Row(children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 18), const SizedBox(width: 8),
              Expanded(child: Text(_qualityError!, style: const TextStyle(fontSize: 12, color: Colors.redAccent))),
            ]),
          ),
        ],
        if (_isCheckingQuality) ...[
          const SizedBox(height: 12),
          const Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: _accent)),
            SizedBox(width: 10),
            Text('사진 품질 확인 중...', style: TextStyle(fontSize: 13, color: _textSecondary)),
          ])),
        ],
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(12), border: Border.all(color: _borderCol)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('📸 STEP $stepNum 사진 가이드', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: accentColor)),
            const SizedBox(height: 8),
            _GuideRow(text: stepNum == 1 ? '간판과 출입구가 잘 보이는 정면 사진을 먼저 올려주세요' : stepNum == 2 ? '내부 전경, 전시 차량, 상담 공간 등을 촬영해 주세요' : '주력 차량이나 정비 서비스 장면을 촬영해 주세요'),
            const _GuideRow(text: '밝고 선명한 사진일수록 AI 소개글 품질이 높아집니다'),
            const _GuideRow(text: '최대 3장까지 등록 가능 · 5KB 미만 저품질 사진 자동 차단'),
          ]),
        ),
        const SizedBox(height: 18),
        if (stepNum < 3) ...[
          SizedBox(width: double.infinity, height: 54, child: ElevatedButton(
            onPressed: _goNextStep,
            style: ElevatedButton.styleFrom(backgroundColor: accentColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(stepNum == 1 ? 'STEP 2로 이동 (${photos.length}장 완료)' : 'STEP 3으로 이동 (${photos.length}장 완료)',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(width: 8), const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
            ]),
          )),
          if (isRequired && photos.isEmpty)
            const Padding(padding: EdgeInsets.only(top: 8), child: Center(child: Text('⚠ 최소 1장 등록 필요 (필수)', style: TextStyle(fontSize: 12, color: Color(0xFFEF5350))))),
        ] else ...[
          SizedBox(width: double.infinity, height: 54, child: ElevatedButton(
            onPressed: totalPhotos > 0 ? _startAiGeneration : null,
            style: ElevatedButton.styleFrom(backgroundColor: totalPhotos > 0 ? _accent : _borderCol, disabledBackgroundColor: _borderCol, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('AI 점포 페이지 생성하기 (총 ${totalPhotos}장)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: totalPhotos > 0 ? const Color(0xFF020810) : _textSecondary)),
              const SizedBox(width: 8),
              Icon(Icons.auto_awesome, color: totalPhotos > 0 ? const Color(0xFF020810) : _textSecondary, size: 18),
            ]),
          )),
          if (totalPhotos == 0)
            const Padding(padding: EdgeInsets.only(top: 8), child: Center(child: Text('⚠ STEP 1 사진을 최소 1장 등록해 주세요', style: TextStyle(fontSize: 12, color: Color(0xFFEF5350))))),
          const SizedBox(height: 8),
          SizedBox(width: double.infinity, height: 44, child: OutlinedButton(
            onPressed: () => setState(() => _step = 2),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: _borderCol), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('← STEP 2로 돌아가기', style: TextStyle(fontSize: 13, color: _textSecondary)),
          )),
        ],
        const SizedBox(height: 40),
      ]),
    );
  }

  Widget _buildEmptySlot(String hint, Color accentColor) {
    return GestureDetector(
      onTap: _showPickerDialog,
      child: Container(
        width: double.infinity, height: 150,
        decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(16), border: Border.all(color: accentColor.withOpacity(0.5), width: 1.5)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 54, height: 54, decoration: BoxDecoration(color: accentColor.withOpacity(0.12), shape: BoxShape.circle),
            child: Icon(Icons.add_a_photo_outlined, color: accentColor, size: 24)),
          const SizedBox(height: 10),
          Text(hint, style: TextStyle(color: accentColor, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('탭하여 카메라 또는 갤러리에서 선택', style: TextStyle(color: _textSecondary, fontSize: 11)),
        ]),
      ),
    );
  }

  Widget _buildPhotoItem(List<File> photos, int idx, String label, Color accentColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(14), border: Border.all(color: _borderCol)),
      child: Row(children: [
        ClipRRect(borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
          child: Image.file(photos[idx], width: 88, height: 88, fit: BoxFit.cover)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textPrimary)),
          const SizedBox(height: 4),
          const Row(children: [
            Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 13), SizedBox(width: 4),
            Text('등록 완료', style: TextStyle(fontSize: 11, color: Color(0xFF4CAF50))),
          ]),
        ])),
        GestureDetector(
          onTap: () => _removePhoto(idx),
          child: Container(width: 30, height: 30, margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(color: Colors.red.withOpacity(0.15), shape: BoxShape.circle),
            child: const Icon(Icons.close, color: Colors.redAccent, size: 15)),
        ),
      ]),
    );
  }

  Widget _buildAddBtn(Color accentColor) {
    return GestureDetector(
      onTap: _showPickerDialog,
      child: Container(width: double.infinity, height: 50,
        decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(12), border: Border.all(color: _borderCol)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.add_photo_alternate_outlined, color: accentColor, size: 18), const SizedBox(width: 8),
          Text('사진 추가하기 (+)', style: TextStyle(color: accentColor, fontSize: 13, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }

  void _showPickerDialog() {
    showModalBottomSheet(
      context: context, backgroundColor: _card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 36, height: 4, decoration: BoxDecoration(color: _borderCol, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          const Text('사진 선택', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _textPrimary)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: _PickerOption(icon: Icons.camera_alt_outlined, label: '카메라 촬영', onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); })),
            const SizedBox(width: 12),
            Expanded(child: _PickerOption(icon: Icons.photo_library_outlined, label: '앨범에서 선택', onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); })),
          ]),
          const SizedBox(height: 8),
        ]),
      )),
    );
  }

  Widget _buildAiGenerating() {
    return Center(child: Padding(padding: const EdgeInsets.all(40), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      AnimatedBuilder(animation: _aiAnimCtrl, builder: (_, __) => Container(
        width: 100, height: 100,
        decoration: BoxDecoration(shape: BoxShape.circle,
          gradient: const LinearGradient(colors: [Color(0xFF0D47A1), Color(0xFF4FC3F7)]),
          boxShadow: [BoxShadow(color: _accent.withOpacity(0.2 + 0.2 * _aiProgress.value), blurRadius: 20 + 12 * _aiProgress.value, spreadRadius: 4)]),
        child: const Center(child: Text('🤖', style: TextStyle(fontSize: 44))),
      )),
      const SizedBox(height: 28),
      const Text('AI가 점포 페이지를\n생성하고 있습니다', textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _textPrimary)),
      const SizedBox(height: 16),
      AnimatedSwitcher(duration: const Duration(milliseconds: 400), child: Text(_aiStatus, key: ValueKey(_aiStatus),
        textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: _accent, height: 1.6))),
      const SizedBox(height: 28),
      AnimatedBuilder(animation: _aiProgress, builder: (_, __) => Column(children: [
        ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: _aiProgress.value, minHeight: 6, backgroundColor: _borderCol, valueColor: const AlwaysStoppedAnimation<Color>(_accent))),
        const SizedBox(height: 8),
        Text('${(_aiProgress.value * 100).toInt()}%', style: const TextStyle(fontSize: 13, color: _accent, fontWeight: FontWeight.w600)),
      ])),
      const SizedBox(height: 24),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(_aiPhases.length, (i) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 3), width: 8, height: 8,
        decoration: BoxDecoration(color: i <= _aiPhase ? _accent : _borderCol, shape: BoxShape.circle),
      ))),
      const SizedBox(height: 20),
      Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(10), border: Border.all(color: _borderCol)),
        child: Text('총 ${_allPhotos.length}장 분석 중  ·  S1:${_photos1.length}장  S2:${_photos2.length}장  S3:${_photos3.length}장',
          textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: _textSecondary))),
    ])));
  }

  Widget _buildAiResult() {
    final mainPhoto = _photos1.isNotEmpty ? _photos1[0] : (_photos2.isNotEmpty ? _photos2[0] : null);
    return SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: 20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 16),
      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: const Color(0xFF1B5E20).withOpacity(0.6), borderRadius: BorderRadius.circular(8)),
        child: const Text('✅ AI 생성 완료', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF81C784)))),
      const SizedBox(height: 10),
      const Text('점포 페이지 미리보기', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _textPrimary)),
      const SizedBox(height: 4),
      const Text('마이페이지에 저장되어 언제든 수정할 수 있습니다', style: TextStyle(fontSize: 12, color: _textSecondary)),
      const SizedBox(height: 16),
      Container(decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(16), border: Border.all(color: _borderCol)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: mainPhoto != null ? Image.file(mainPhoto, height: 160, width: double.infinity, fit: BoxFit.cover)
            : Image.network('https://images.unsplash.com/photo-1487958449943-2429e8be8625?w=400&q=80', height: 160, width: double.infinity, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(height: 160, color: const Color(0xFF1E3A5F)))),
        Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: _accent.withOpacity(0.15), borderRadius: BorderRadius.circular(6), border: Border.all(color: _accent.withOpacity(0.4))),
              child: const Text('MOINCAR 인증', style: TextStyle(color: _accent, fontSize: 11, fontWeight: FontWeight.w700))),
            const SizedBox(width: 8),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: const Color(0xFF00897B).withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
              child: const Text('자동차 판매', style: TextStyle(color: Color(0xFF4DB6AC), fontSize: 11, fontWeight: FontWeight.w600))),
          ]),
          const SizedBox(height: 10),
          const Text('MOINCAR 인증 자동차 전문점', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _textPrimary)),
          const SizedBox(height: 4),
          const Text('AI가 분석한 업종별 맞춤 페이지', style: TextStyle(fontSize: 12, color: _textSecondary)),
          const SizedBox(height: 10),
          Container(padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: _borderCol)),
            child: const Text('"고객 신뢰를 최우선으로, MOINCAR 공인 인증 자동차 전문점.\n투명한 가격과 검증된 품질로 최고의 자동차 거래 경험을 제공합니다."',
              style: TextStyle(fontSize: 12, color: _accent, fontStyle: FontStyle.italic, height: 1.5))),
          const SizedBox(height: 12),
          const _DarkResultRow(icon: Icons.location_on_outlined, text: '서울특별시 강남구 테헤란로 123'),
          const _DarkResultRow(icon: Icons.phone_outlined, text: '010-1234-5678'),
          const _DarkResultRow(icon: Icons.access_time, text: '월~토 09:00~18:00 / 일 휴무'),
        ])),
        if (_allPhotos.isNotEmpty)
          Padding(padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('등록된 사진', style: TextStyle(fontSize: 11, color: _textSecondary)),
            const SizedBox(height: 6),
            Row(children: _allPhotos.take(5).toList().asMap().entries.map((e) => Expanded(child: Container(
              margin: EdgeInsets.only(right: e.key < _allPhotos.length - 1 ? 5 : 0),
              child: ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.file(e.value, height: 52, fit: BoxFit.cover)),
            ))).toList()),
          ])),
      ])),
      const SizedBox(height: 14),
      Container(padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: const Color(0xFF1B5E20).withOpacity(0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3))),
        child: const Row(children: [
          Icon(Icons.person_pin_circle_outlined, color: Color(0xFF81C784), size: 22), SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('마이페이지에 자동 저장됩니다', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF81C784))),
            SizedBox(height: 2),
            Text('등록 후 마이페이지에서 점포 정보를 언제든 수정할 수 있습니다', style: TextStyle(fontSize: 11, color: Color(0xFF4CAF50), height: 1.4)),
          ])),
        ])),
      const SizedBox(height: 18),
      SizedBox(width: double.infinity, height: 54, child: ElevatedButton(
        onPressed: () => setState(() => _step = 6),
        style: ElevatedButton.styleFrom(backgroundColor: _accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
        child: const Text('이 페이지로 등록하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF020810))),
      )),
      const SizedBox(height: 10),
      SizedBox(width: double.infinity, height: 44, child: OutlinedButton(
        onPressed: () => setState(() => _step = 1),
        style: OutlinedButton.styleFrom(side: const BorderSide(color: _borderCol), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: const Text('사진 다시 등록하기', style: TextStyle(fontSize: 13, color: _textSecondary)),
      )),
      const SizedBox(height: 40),
    ]));
  }

  Widget _buildComplete() {
    return Container(
      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF020810), Color(0xFF0D2A3E)])),
      child: SafeArea(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 88, height: 88,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _accent, width: 2), color: _accent.withOpacity(0.12)),
          child: const Icon(Icons.check, size: 44, color: _accent)),
        const SizedBox(height: 28),
        const Text('점포 등록 완료!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: _textPrimary)),
        const SizedBox(height: 10),
        Text('MOINCAR 인증 점포', style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.8))),
        const SizedBox(height: 10),
        Text('AI 점포 페이지가 성공적으로 생성되었습니다.\n검토 후 24시간 내 공개될 예정입니다.',
          textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.55), height: 1.6)),
        const SizedBox(height: 24),
        Container(padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(12), border: Border.all(color: _borderCol)),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _CompletionStat(label: 'STEP 1\n간판·외관', count: _photos1.length),
              _CompletionStat(label: 'STEP 2\n내부·전시장', count: _photos2.length),
              _CompletionStat(label: 'STEP 3\n대표차량', count: _photos3.length),
            ]),
            const SizedBox(height: 10),
            const Text('마이페이지 > 내 점포에서 정보를 수정할 수 있습니다',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: _textSecondary)),
          ])),
        const SizedBox(height: 32),
        SizedBox(width: double.infinity, height: 54, child: ElevatedButton(
          onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/my', (_) => false),
          style: ElevatedButton.styleFrom(backgroundColor: _accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
          child: const Text('마이페이지에서 점포 확인하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF020810))),
        )),
        const SizedBox(height: 10),
        SizedBox(width: double.infinity, height: 44, child: OutlinedButton(
          onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false),
          style: OutlinedButton.styleFrom(side: const BorderSide(color: _borderCol), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: const Text('홈으로 돌아가기', style: TextStyle(fontSize: 13, color: _textSecondary)),
        )),
      ]))),
    );
  }
}

class _CompletionStat extends StatelessWidget {
  final String label;
  final int count;
  const _CompletionStat({required this.label, required this.count});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text('${count}장', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: count > 0 ? const Color(0xFF4FC3F7) : const Color(0xFF607D8B))),
      const SizedBox(height: 4),
      Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: Color(0xFFB0BEC5), height: 1.3)),
    ]);
  }
}

// ── _GuideRow ───────────────────────────────────────────────────
class _GuideRow extends StatelessWidget {
  final String text;
  const _GuideRow({required this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('· ', style: TextStyle(color: Color(0xFF4FC3F7), fontSize: 13)),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: Color(0xFFB0BEC5), height: 1.4))),
      ]),
    );
  }
}

// ── _DarkResultRow ──────────────────────────────────────────────
class _DarkResultRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _DarkResultRow({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Icon(icon, size: 15, color: const Color(0xFF607D8B)),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: Color(0xFFB0BEC5)))),
      ]),
    );
  }
}

// ── _PickerOption ───────────────────────────────────────────────
class _PickerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _PickerOption({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF1E3A5F).withOpacity(0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF1E3A5F)),
        ),
        child: Column(children: [
          Icon(icon, color: const Color(0xFF4FC3F7), size: 28),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 13, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }
}

// ==================== 뉴스 ====================
class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});
  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  static const _bg    = Color(0xFF020810);
  static const _card  = Color(0xFF0D1B2A);
  static const _accent = Color(0xFF4FC3F7);
  static const _orange = Color(0xFFFF6B35);
  static const _border = Color(0xFF1E3A5F);
  static const _textPri = Colors.white;
  static const _textSec = Color(0xFFB0BEC5);

  int _selCat = 0;
  final List<String> _cats = ['전체', '자동차 소식', '전기차', '정비 팁', 'MOINCAR'];
  final List<Color> _catColors = [
    Color(0xFF4FC3F7), Color(0xFF0288D1), Color(0xFF10B981),
    Color(0xFFFF6B35), Color(0xFF9B7CFF),
  ];

  final List<Map<String, dynamic>> _allNews = [
    {
      'title': '중고차 성능점검 수요, 올해 30% 급증',
      'summary': '사고이력·성능점검표 확인 의무화 논의로 소비자 관심 폭발. 중고차 플랫폼들도 AI 분석 강화에 나섰다.',
      'category': '자동차 소식',
      'source': '모인카 뉴스',
      'time': '2시간 전',
      'readTime': '3분',
      'image': 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=600&q=80',
      'hot': true,
    },
    {
      'title': '2025 전기차 보조금 개편 완벽 정리',
      'summary': '국고보조금 최대 650만원, 지자체 추가 보조 가능. 승용·SUV 별 지원 기준 및 신청 방법 상세 안내.',
      'category': '전기차',
      'source': '자동차 경제',
      'time': '5시간 전',
      'readTime': '5분',
      'image': 'https://images.unsplash.com/photo-1593941707882-a5bba53b0998?w=600&q=80',
      'hot': true,
    },
    {
      'title': '봄철 필수! 타이어 공기압·마모도 셀프 체크법',
      'summary': '겨울철 저온으로 공기압 저하된 타이어 그대로면 위험. 10분이면 끝나는 타이어 안전 점검 순서.',
      'category': '정비 팁',
      'source': 'MOINCAR 정비팀',
      'time': '1일 전',
      'readTime': '4분',
      'image': 'https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?w=600&q=80',
      'hot': false,
    },
    {
      'title': 'MOINCAR 인증 점포 전국 200호점 달성',
      'summary': '2025년 상반기 기준 전국 200개 점포 인증 완료. 고객 신뢰도 향상과 서비스 품질 기준 강화.',
      'category': 'MOINCAR',
      'source': 'MOINCAR 공식',
      'time': '2일 전',
      'readTime': '2분',
      'image': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600&q=80',
      'hot': false,
    },
    {
      'title': '수입차 엔진오일, 국산 오일 사용해도 될까?',
      'summary': '제조사 권장 규격만 맞으면 국산 오일도 OK. 다만 점도·인증 규격 반드시 확인해야.',
      'category': '정비 팁',
      'source': '카닥 테크',
      'time': '3일 전',
      'readTime': '6분',
      'image': 'https://images.unsplash.com/photo-1632823469850-2f77dd9c7f93?w=600&q=80',
      'hot': false,
    },
    {
      'title': '테슬라 모델Y, 국내 전기차 판매 1위 유지',
      'summary': '연속 3개월 판매 1위. 보조금 혜택·충전 인프라 확장이 핵심 요인으로 분석.',
      'category': '전기차',
      'source': '오토데일리',
      'time': '4일 전',
      'readTime': '3분',
      'image': 'https://images.unsplash.com/photo-1560958089-b8a1929cea89?w=600&q=80',
      'hot': false,
    },
  ];

  List<Map<String, dynamic>> get _filteredNews {
    if (_selCat == 0) return _allNews;
    final cat = _cats[_selCat];
    return _allNews.where((n) => n['category'] == cat).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredNews;
    return Scaffold(
      backgroundColor: _bg,
      body: Column(children: [
        // 상단바
        SafeArea(
          bottom: false,
          child: AppHeader(showBack: true, title: '자동차 뉴스', notifCount: AppState().notificationCount),
        ),

        // 카테고리 탭
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            itemCount: _cats.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final sel = _selCat == i;
              return GestureDetector(
                onTap: () => setState(() => _selCat = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: sel ? _catColors[i] : _card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: sel ? _catColors[i] : _border,
                    ),
                  ),
                  child: Text(_cats[i],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: sel ? FontWeight.w800 : FontWeight.w500,
                      color: sel ? Colors.black : _textSec,
                    )),
                ),
              );
            },
          ),
        ),

        // 뉴스 목록
        Expanded(
          child: filtered.isEmpty
            ? const Center(
                child: Text('해당 카테고리 뉴스가 없습니다.',
                  style: TextStyle(color: _textSec, fontSize: 14)),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  final n = filtered[i];
                  final isHot = n['hot'] as bool;
                  final catIdx = _cats.indexOf(n['category'] as String);
                  final catColor = catIdx >= 0 ? _catColors[catIdx] : _accent;

                  // 첫 번째 뉴스는 큰 카드
                  if (i == 0 && _selCat == 0) {
                    return _buildHeroCard(n, catColor, isHot);
                  }
                  return _buildNewsCard(n, catColor, isHot);
                },
              ),
        ),
      ]),
    );
  }

  Widget _buildHeroCard(Map<String, dynamic> n, Color catColor, bool isHot) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // 이미지 영역
          Stack(children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                n['image'] as String,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 180, color: const Color(0xFF1A2A40),
                  child: const Icon(Icons.newspaper, color: _textSec, size: 40)),
              ),
            ),
            // 그라데이션 오버레이
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                  ),
                ),
              ),
            ),
            // HOT 뱃지
            if (isHot)
              Positioned(top: 12, left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _orange, borderRadius: BorderRadius.circular(6)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('🔥', style: TextStyle(fontSize: 10)),
                    SizedBox(width: 3),
                    Text('HOT', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w900)),
                  ]),
                ),
              ),
          ]),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: catColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: catColor.withOpacity(0.4)),
                  ),
                  child: Text(n['category'] as String,
                    style: TextStyle(fontSize: 10, color: catColor, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 8),
                Text(n['source'] as String,
                  style: const TextStyle(fontSize: 10, color: _textSec)),
                const Spacer(),
                const Icon(Icons.access_time_outlined, size: 11, color: _textSec),
                const SizedBox(width: 2),
                Text('${n['readTime']} 읽기',
                  style: const TextStyle(fontSize: 10, color: _textSec)),
              ]),
              const SizedBox(height: 8),
              Text(n['title'] as String,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: _textPri, height: 1.3)),
              const SizedBox(height: 6),
              Text(n['summary'] as String,
                style: const TextStyle(fontSize: 12, color: _textSec, height: 1.5),
                maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 10),
              Row(children: [
                Text(n['time'] as String,
                  style: const TextStyle(fontSize: 11, color: _textSec)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _accent.withOpacity(0.4)),
                  ),
                  child: const Text('자세히 보기',
                    style: TextStyle(fontSize: 11, color: _accent, fontWeight: FontWeight.w700)),
                ),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildNewsCard(Map<String, dynamic> n, Color catColor, bool isHot) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // 썸네일
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              n['image'] as String,
              width: 86, height: 86,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 86, height: 86, color: const Color(0xFF1A2A40),
                child: const Icon(Icons.newspaper, color: _textSec, size: 28)),
            ),
          ),
          const SizedBox(width: 12),
          // 텍스트
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: catColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: catColor.withOpacity(0.3)),
                ),
                child: Text(n['category'] as String,
                  style: TextStyle(fontSize: 9, color: catColor, fontWeight: FontWeight.w700)),
              ),
              if (isHot) ...[
                const SizedBox(width: 4),
                const Text('🔥', style: TextStyle(fontSize: 10)),
              ],
            ]),
            const SizedBox(height: 5),
            Text(n['title'] as String,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _textPri, height: 1.3),
              maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(n['summary'] as String,
              style: const TextStyle(fontSize: 11, color: _textSec, height: 1.4),
              maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Row(children: [
              Text(n['source'] as String,
                style: const TextStyle(fontSize: 10, color: _textSec)),
              const SizedBox(width: 6),
              const Text('·', style: TextStyle(color: _textSec, fontSize: 10)),
              const SizedBox(width: 6),
              Text(n['time'] as String,
                style: const TextStyle(fontSize: 10, color: _textSec)),
              const Spacer(),
              const Icon(Icons.access_time_outlined, size: 10, color: _textSec),
              const SizedBox(width: 2),
              Text('${n['readTime']}', style: const TextStyle(fontSize: 10, color: _textSec)),
            ]),
          ])),
        ]),
      ),
    );
  }
}

// ==================== 긴급서비스 ====================
class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});
  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> with SingleTickerProviderStateMixin {
  static const _bg    = Color(0xFF020810);
  static const _card  = Color(0xFF0D1B2A);
  static const _red   = Color(0xFFFF4444);
  static const _orange = Color(0xFFFF6B35);
  static const _accent = Color(0xFF4FC3F7);
  static const _border = Color(0xFF1E3A5F);
  static const _textPri = Colors.white;
  static const _textSec = Color(0xFFB0BEC5);

  late TabController _tabCtrl;

  // 보험사 긴급출동 번호
  final List<Map<String, dynamic>> _insurers = [
    {'name': '삼성화재', 'emoji': '🔵', 'color': Color(0xFF1565C0), 'phone': '1588-5114', 'sub': '24시간 긴급출동'},
    {'name': '현대해상', 'emoji': '🟢', 'color': Color(0xFF2E7D32), 'phone': '1588-5656', 'sub': '24시간 긴급출동'},
    {'name': 'KB손해보험', 'emoji': '🟡', 'color': Color(0xFFF57F17), 'phone': '1544-0070', 'sub': '24시간 긴급출동'},
    {'name': 'DB손해보험', 'emoji': '🔴', 'color': Color(0xFFC62828), 'phone': '1588-0100', 'sub': '24시간 긴급출동'},
    {'name': '메리츠화재', 'emoji': '🟠', 'color': Color(0xFFE65100), 'phone': '1566-7711', 'sub': '24시간 긴급출동'},
    {'name': 'AXA손해보험', 'emoji': '🔷', 'color': Color(0xFF00796B), 'phone': '1566-1234', 'sub': '24시간 긴급출동'},
    {'name': '롯데손해보험', 'emoji': '🟣', 'color': Color(0xFF6A1B9A), 'phone': '1588-3344', 'sub': '24시간 긴급출동'},
    {'name': '한화손해보험', 'emoji': '🌙', 'color': Color(0xFF37474F), 'phone': '1566-8000', 'sub': '24시간 긴급출동'},
    {'name': '흥국화재', 'emoji': '⭕', 'color': Color(0xFF880E4F), 'phone': '1588-2288', 'sub': '24시간 긴급출동'},
    {'name': '캐롯손해보험', 'emoji': '🥕', 'color': Color(0xFFBF360C), 'phone': '1566-1566', 'sub': '24시간 긴급출동'},
    {'name': '하나손해보험', 'emoji': '💚', 'color': Color(0xFF1B5E20), 'phone': '1566-3000', 'sub': '24시간 긴급출동'},
    {'name': '무비', 'emoji': '🚗', 'color': Color(0xFF0D47A1), 'phone': '1800-0700', 'sub': '24시간 긴급출동'},
  ];

  // 가까운 파트너 점포
  final List<Map<String, dynamic>> _partners = [
    {'name': 'MOINCAR 인증 정비센터', 'distance': '1.2km', 'phone': '02-1234-5678', 'services': ['배터리', '타이어', '견인'], 'badge': 'MOINCAR'},
    {'name': '강남 24시 자동차 출동', 'distance': '2.3km', 'phone': '010-9876-5432', 'services': ['방전', '잠금', '연료'], 'badge': '파트너'},
    {'name': '서울모터스 긴급출동팀', 'distance': '3.1km', 'phone': '02-3456-7890', 'services': ['타이어', '견인', '정비'], 'badge': '인증'},
    {'name': '현대자동차 강남점 출동', 'distance': '3.8km', 'phone': '02-5678-9012', 'services': ['공식', '보증', '24시'], 'badge': '공식'},
    {'name': '수입차 전문 긴급출동', 'distance': '4.5km', 'phone': '010-1111-2222', 'services': ['수입차', '배터리', '견인'], 'badge': '파트너'},
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          // 상단바
          SafeArea(
            bottom: false,
            child: AppHeader(showBack: true, title: '긴급출동', notifCount: AppState().notificationCount),
          ),

          // SOS 배너
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7B1E2A), Color(0xFF4A0E14)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _red.withOpacity(0.4)),
            ),
            child: Row(children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: _red.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: _red.withOpacity(0.5)),
                ),
                child: const Center(child: Text('🚨', style: TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('긴급출동 SOS',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(height: 3),
                const Text('배터리 방전 · 타이어 펑크 · 시동불량 · 잠금',
                  style: TextStyle(fontSize: 11, color: Color(0xFFFFB3B3), height: 1.3)),
              ])),
              GestureDetector(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Color(0xFFFF4444),
                    content: Text('🚨 긴급출동 요청이 접수되었습니다!\n잠시만 기다려주세요.',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    duration: Duration(seconds: 3),
                  )),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: _red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(mainAxisSize: MainAxisSize.min, children: [
                    Text('📞', style: TextStyle(fontSize: 18)),
                    Text('SOS', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w900)),
                  ]),
                ),
              ),
            ]),
          ),

          // 탭바
          Container(
            margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _border),
            ),
            child: TabBar(
              controller: _tabCtrl,
              indicator: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF4FC3F7), Color(0xFF0288D1)]),
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorPadding: const EdgeInsets.all(3),
              labelColor: Colors.black,
              unselectedLabelColor: _textSec,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: '🏢 보험사 긴급출동'),
                Tab(text: '📍 가까운 파트너'),
              ],
            ),
          ),

          // 탭 컨텐츠
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                // ─ 보험사 탭 ─
                ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  itemCount: _insurers.length,
                  itemBuilder: (_, i) {
                    final ins = _insurers[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _border),
                      ),
                      child: Row(children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: (ins['color'] as Color).withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(color: (ins['color'] as Color).withOpacity(0.4)),
                          ),
                          child: Center(child: Text(ins['emoji'] as String,
                            style: const TextStyle(fontSize: 20))),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(ins['name'] as String,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _textPri)),
                          const SizedBox(height: 2),
                          Text(ins['sub'] as String,
                            style: const TextStyle(fontSize: 11, color: _textSec)),
                        ])),
                        GestureDetector(
                          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: _card,
                              content: Text('📞 ${ins['name']}: ${ins['phone']}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                            )),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                            decoration: BoxDecoration(
                              color: _red.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: _red.withOpacity(0.4)),
                            ),
                            child: Column(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.phone, size: 16, color: _red),
                              const SizedBox(height: 2),
                              Text(ins['phone'] as String,
                                style: const TextStyle(fontSize: 11, color: _red, fontWeight: FontWeight.w800)),
                            ]),
                          ),
                        ),
                      ]),
                    );
                  },
                ),

                // ─ 파트너 점포 탭 ─
                ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  itemCount: _partners.length,
                  itemBuilder: (_, i) {
                    final p = _partners[i];
                    final services = p['services'] as List<String>;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _border),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: _orange.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: _orange.withOpacity(0.4)),
                            ),
                            child: Text(p['badge'] as String,
                              style: const TextStyle(fontSize: 10, color: _orange, fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(p['name'] as String,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _textPri))),
                          Row(children: [
                            const Icon(Icons.location_on_outlined, size: 12, color: _textSec),
                            const SizedBox(width: 2),
                            Text(p['distance'] as String,
                              style: const TextStyle(fontSize: 12, color: _accent, fontWeight: FontWeight.w700)),
                          ]),
                        ]),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6, runSpacing: 4,
                          children: services.map((s) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _accent.withOpacity(0.3)),
                            ),
                            child: Text(s, style: const TextStyle(fontSize: 10, color: _accent)),
                          )).toList(),
                        ),
                        const SizedBox(height: 10),
                        Row(children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: _card,
                                  content: Text('📞 ${p['name']}: ${p['phone']}',
                                    style: const TextStyle(color: Colors.white)),
                                )),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: _red.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(9),
                                  border: Border.all(color: _red.withOpacity(0.35)),
                                ),
                                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  Icon(Icons.phone, size: 14, color: _red),
                                  SizedBox(width: 4),
                                  Text('전화걸기', style: TextStyle(fontSize: 12, color: _red, fontWeight: FontWeight.w700)),
                                ]),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('점포 상세 정보로 이동합니다.'),
                                )),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: _accent.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(9),
                                  border: Border.all(color: _accent.withOpacity(0.35)),
                                ),
                                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  Icon(Icons.store_outlined, size: 14, color: _accent),
                                  SizedBox(width: 4),
                                  Text('점포 보기', style: TextStyle(fontSize: 12, color: _accent, fontWeight: FontWeight.w700)),
                                ]),
                              ),
                            ),
                          ),
                        ]),
                      ]),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 내차 시세 ====================
class CarPriceScreen extends StatefulWidget {
  const CarPriceScreen({super.key});
  @override
  State<CarPriceScreen> createState() => _CarPriceScreenState();
}

class _CarPriceScreenState extends State<CarPriceScreen> {
  // 단계: 0=입력, 1=결과
  int _step = 0;
  bool _loading = false;
  bool _applying = false;

  // 신청서 목록 (각 항목: {storeName, storeRating, storeDistance, storeColor, sentAt, cancelled, carInfo})
  List<Map<String, dynamic>> _applications = [];

  // 신청서 패널 열림 여부
  bool _showApplications = false;

  final _plateCtrl = TextEditingController();
  final _kmCtrl    = TextEditingController();

  // ── 내차 사진 (최대 10장) ──
  final List<File> _carPhotos = [];
  final ImagePicker _carPicker = ImagePicker();
  bool _photoUploading = false;

  // ── 차량번호 자동조회 결과 ──
  String? _plateRegDate;    // 최초등록일
  String? _plateModelYear;  // 연식
  bool _plateLoading = false;
  bool _plateFound = false;  // 조회 성공 시 상세폼 표시

  // 주행거리: 마지막 저장값과 비교해 새 값 입력 시에만 버튼 활성화
  String _kmLastSaved = '';     // SharedPreferences에 저장된 이전 값
  bool get _kmChanged => _kmCtrl.text.trim().isNotEmpty &&
      _kmCtrl.text.trim() != _kmLastSaved;

  // 팝업 선택 값
  String? _selectedMaker;
  String? _selectedModel;
  String? _selectedYear;
  String? _selectedMonth;
  String? _selectedGrade;

  // 시세 결과
  Map<String, dynamic>? _priceResult;

  // ── SharedPreferences 키 ──
  static const _kMaker  = 'cp_maker';
  static const _kModel  = 'cp_model';
  static const _kYear   = 'cp_year';
  static const _kMonth  = 'cp_month';
  static const _kGrade  = 'cp_grade';
  static const _kPlate  = 'cp_plate';
  static const _kKm     = 'cp_km';
  static const _kApps   = 'cp_applications';

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedKm = prefs.getString(_kKm) ?? '';
    setState(() {
      _selectedMaker = prefs.getString(_kMaker);
      _selectedModel = prefs.getString(_kModel);
      _selectedYear  = prefs.getString(_kYear);
      _selectedMonth = prefs.getString(_kMonth);
      _selectedGrade = prefs.getString(_kGrade);
      _plateCtrl.text = prefs.getString(_kPlate) ?? '';
      _kmCtrl.text    = savedKm;
      _kmLastSaved    = savedKm; // 이전 저장값 기억
    });

    // ── 저장된 신청 내역 복원 (JSON 인코딩) ──
    final savedJson = prefs.getString('${_kApps}_json');
    if (savedJson != null && savedJson.isNotEmpty) {
      try {
        final decoded = (savedJson.split('|||')).map((item) {
          final parts = item.split('||');
          if (parts.length < 7) return null;
          return <String, dynamic>{
            'storeName':     parts[0],
            'storeRating':   parts[1],
            'storeDistance': parts[2],
            'storeColor':    int.tryParse(parts[3]) ?? 0xFF4FC3F7,
            'sentAt':        parts[4],
            'cancelled':     parts[5] == 'true',
            'carInfo':       parts[6],
            'priceResult':   null,
            'readStatus':    parts.length > 7 ? parts[7] : 'unread',
            'estimatePrice': 0,
            'estimateNote':  '',
          };
        }).whereType<Map<String, dynamic>>().toList();
        if (decoded.isNotEmpty) {
          setState(() => _applications = decoded);
          return; // 저장된 데이터가 있으면 샘플 세팅 건너뜀
        }
      } catch (_) {}
    }

    // ── 처음 실행 시 샘플 2건 세팅 ──
    final sampleApps = <Map<String, dynamic>>[
      {
        'storeName':     '대구모터스',
        'storeRating':   '★4.8',
        'storeDistance': '0.8km',
        'storeColor':    0xFF4FC3F7,
        'sentAt':        '4/12 09:00',
        'cancelled':     false,
        'carInfo':       '2020 현대 아반떼',
        'priceResult':   {'maker':'현대','model':'아반떼','year':'2020','mid':14500000,'low':13000000,'high':16000000},
        'readStatus':    'read',
        'estimatePrice': 0,
        'estimateNote':  '',
      },
      {
        'storeName':     '수성카딜러',
        'storeRating':   '★4.6',
        'storeDistance': '1.2km',
        'storeColor':    0xFF10B981,
        'sentAt':        '4/12 09:00',
        'cancelled':     false,
        'carInfo':       '2020 현대 아반떼',
        'priceResult':   {'maker':'현대','model':'아반떼','year':'2020','mid':14500000,'low':13000000,'high':16000000},
        'readStatus':    'unread',
        'estimatePrice': 0,
        'estimateNote':  '',
      },
    ];
    setState(() => _applications = sampleApps);
  }

  Future<void> _saveInputData() async {
    final prefs = await SharedPreferences.getInstance();
    if (_selectedMaker != null) await prefs.setString(_kMaker, _selectedMaker!);
    if (_selectedModel != null) await prefs.setString(_kModel, _selectedModel!);
    if (_selectedYear  != null) await prefs.setString(_kYear,  _selectedYear!);
    if (_selectedMonth != null) await prefs.setString(_kMonth, _selectedMonth!);
    if (_selectedGrade != null) await prefs.setString(_kGrade, _selectedGrade!);
    await prefs.setString(_kPlate, _plateCtrl.text);
    await prefs.setString(_kKm,    _kmCtrl.text);
  }

  Future<void> _saveApplications() async {
    final prefs = await SharedPreferences.getInstance();
    // JSON 스타일로 저장 (||| 구분자로 레코드 분리)
    final encoded = _applications.map((a) =>
      '${a['storeName']}||${a['storeRating']}||${a['storeDistance']}||'
      '${a['storeColor']}||${a['sentAt']}||${a['cancelled']}||${a['carInfo']}||${a['readStatus'] ?? 'unread'}'
    ).join('|||');
    await prefs.setString('${_kApps}_json', encoded);
    // 기존 리스트 키도 호환 유지
    final list = _applications.map((a) =>
      '${a['storeName']}||${a['storeRating']}||${a['storeDistance']}||'
      '${a['storeColor']}||${a['sentAt']}||${a['cancelled']}||${a['carInfo']}'
    ).toList();
    await prefs.setStringList(_kApps, list);
  }

  Future<void> _clearInputData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kMaker);
    await prefs.remove(_kModel);
    await prefs.remove(_kYear);
    await prefs.remove(_kMonth);
    await prefs.remove(_kGrade);
    await prefs.remove(_kPlate);
    await prefs.remove(_kKm);
    setState(() {
      _selectedMaker = null;
      _selectedModel = null;
      _selectedYear  = null;
      _selectedMonth = null;
      _selectedGrade = null;
      _plateCtrl.clear();
      _kmCtrl.clear();
      _priceResult = null;
      _step = 0;
    });
  }

  // 차량 데이터
  static const Map<String, List<String>> _makerModels = {
    // ── 국산차 ──
    '현대': [
      '아반떼', '아반떼 N', '쏘나타', '쏘나타 N Line', '그랜저', '아이오닉 5', '아이오닉 6',
      '코나', '코나 Electric', '투싼', '싼타페', '팰리세이드', '스타리아', '캐스퍼',
      '넥쏘', 'i30', '벨로스터', '아슬란', '제네시스 쿠페',
    ],
    '기아': [
      'K3', 'K5', 'K8', 'K9', 'EV3', 'EV6', 'EV9',
      '스토닉', '셀토스', '스포티지', '쏘렌토', '모하비', '카니발',
      '니로', '니로 EV', 'K4', 'PV5', '레이', '모닝',
    ],
    '제네시스': [
      'G70', 'G70 슈팅브레이크', 'G80', 'G80 전동화', 'G90',
      'GV60', 'GV70', 'GV70 전동화', 'GV80',
    ],
    '쉐보레': [
      '스파크', '아베오', '크루즈', '말리부', '임팔라',
      '트랙스', '트레일블레이저', '이쿼녹스', '블레이저', '트래버스', '타호', '서버번',
      '콜로라도', '실버라도', '볼트 EV', '볼트 EUV',
    ],
    '르노코리아': [
      'SM3', 'SM5', 'SM6', 'SM7',
      'QM3', 'QM5', 'QM6', 'XM3',
      '조에', '마스터', '트위지',
    ],
    'KG모빌리티': [
      '티볼리', '티볼리 에어', '코란도', '렉스턴', '렉스턴 스포츠',
      '무쏘', '이스타나', 'O100', 'KR10',
    ],
    '삼성': [
      'SM3', 'SM5', 'SM6', 'SM7', 'QM3', 'QM5', 'QM6',
    ],
    // ── 수입차 (독일) ──
    'BMW': [
      '1시리즈', '2시리즈', '2시리즈 그란쿠페', '3시리즈', '3시리즈 투어링',
      '4시리즈', '4시리즈 그란쿠페', '5시리즈', '5시리즈 투어링',
      '6시리즈', '7시리즈', '8시리즈',
      'X1', 'X2', 'X3', 'X3 M', 'X4', 'X5', 'X5 M', 'X6', 'X7',
      'i3', 'i4', 'i5', 'i7', 'iX', 'iX1', 'iX3',
      'M2', 'M3', 'M4', 'M5', 'M8',
    ],
    '벤츠': [
      'A클래스', 'B클래스', 'C클래스', 'C클래스 왜건',
      'CLA', 'CLS', 'E클래스', 'E클래스 왜건',
      'S클래스', 'G클래스', 'GLA', 'GLB', 'GLC', 'GLC 쿠페',
      'GLE', 'GLE 쿠페', 'GLS',
      'EQA', 'EQB', 'EQC', 'EQE', 'EQS',
      'AMG GT', 'SL', 'SLC', 'Maybach S클래스',
    ],
    '아우디': [
      'A1', 'A3', 'A3 스포츠백', 'A4', 'A4 아반트',
      'A5', 'A5 스포츠백', 'A6', 'A6 아반트', 'A7', 'A8',
      'Q2', 'Q3', 'Q3 스포츠백', 'Q4 e-tron', 'Q5', 'Q7', 'Q8',
      'e-tron', 'e-tron GT', 'e-tron S',
      'R8', 'TT', 'RS3', 'RS5', 'RS6', 'RS7', 'S3', 'S4', 'S5', 'S6', 'S8',
    ],
    '폭스바겐': [
      '폴로', '골프', '골프 GTI', '골프 R', '골프 왜건',
      '제타', '파사트', '파사트 왜건', '아테온',
      '티구안', '티록', '투아렉',
      'ID.3', 'ID.4', 'ID.6',
      '아마록', '멀티밴',
    ],
    '포르쉐': [
      '911', '718 박스터', '718 케이맨',
      '마칸', '마칸 EV', '카이엔', '카이엔 쿠페',
      '타이칸', '타이칸 크로스 투리스모', '파나메라',
    ],
    // ── 수입차 (미국) ──
    '테슬라': [
      'Model 3', 'Model 3 퍼포먼스', 'Model Y', 'Model Y 퍼포먼스',
      'Model S', 'Model S 플레이드', 'Model X', 'Model X 플레이드',
      'Cybertruck',
    ],
    '포드': [
      '피에스타', '포커스', '몬데오', '머스탱', '머스탱 마하-E',
      '이스케이프', '엣지', '익스플로러', '익스페디션',
      '레인저', 'F-150', 'F-150 라이트닝', '브롱코',
    ],
    '지프': [
      '레니게이드', '컴패스', '체로키', '그랜드 체로키', '글래디에이터', '랭글러',
    ],
    '링컨': [
      'MKZ', '코세어', '노틸러스', '에비에이터', '네비게이터',
    ],
    '캐딜락': [
      'CT4', 'CT5', 'XT4', 'XT5', 'XT6', '에스컬레이드', 'LYRIQ',
    ],
    'GMC': [
      '시에라', '유콘', '아카디아', '테레인',
    ],
    // ── 수입차 (일본) ──
    '토요타': [
      '야리스', '코롤라', '코롤라 크로스', '캠리', 'C-HR',
      'RAV4', 'RAV4 PHEV', '하이랜더', '세쿼이아',
      '프리우스', '프리우스 PHEV', '알파드', '시에나',
      'bZ4X', 'GR86', 'GR수프라',
    ],
    '렉서스': [
      'CT', 'ES', 'IS', 'GS', 'LS', 'LC', 'RC',
      'UX', 'NX', 'RX', 'GX', 'LX',
      'UX 300e', 'NX 450h+', 'RX 500h',
    ],
    '혼다': [
      '시빅', '시빅 타입R', '어코드', '어코드 하이브리드',
      'HR-V', 'CR-V', 'CR-V 하이브리드', 'ZR-V', '파일럿', '오딧세이',
      'e:Ny1', '재즈',
    ],
    '닛산': [
      '마이크라', '센트라', '알티마', '막시마',
      '캐시카이', 'X-트레일', '무라노', '패스파인더', 'QX50', 'QX60',
      '아리아', '리프', '370Z',
    ],
    '인피니티': [
      'Q50', 'Q60', 'Q70', 'QX30', 'QX50', 'QX55', 'QX60', 'QX80',
    ],
    '마쓰다': [
      '마쓰다2', '마쓰다3', '마쓰다6', 'CX-3', 'CX-30', 'CX-5', 'CX-8', 'CX-60', 'MX-5',
    ],
    '미쓰비시': [
      '아웃랜더', '아웃랜더 PHEV', '이클립스 크로스', '갤런트', '파제로',
    ],
    '스바루': [
      '임프레자', '레거시', '포레스터', '아웃백', 'XV', 'BRZ', 'WRX',
    ],
    // ── 수입차 (유럽 기타) ──
    '볼보': [
      'S60', 'S90', 'V60', 'V60 크로스컨트리', 'V90', 'V90 크로스컨트리',
      'XC40', 'XC40 Recharge', 'XC60', 'XC90',
      'C40 Recharge', 'EX30', 'EX90',
    ],
    'MINI': [
      '미니 해치', '미니 해치 3도어', '미니 해치 5도어',
      '미니 컨버터블', '미니 클럽맨', '미니 쿠퍼맨',
      '미니 컨트리맨', '미니 페이스맨', '미니 캐브리올레',
      '미니 일렉트릭', '미니 쿠퍼 SE',
    ],
    '푸조': [
      '208', '308', '408', '508', '2008', '3008', '5008',
      'e-208', 'e-2008',
    ],
    '시트로엥': [
      'C3', 'C4', 'C5 X', 'ë-C4', 'DS3 크로스백',
    ],
    '피아트': [
      '500', '500X', '500L', '브라보', '도블로',
    ],
    '알파로메오': [
      '줄리아', '줄리에타', '스텔비오', '토날레',
    ],
    '마세라티': [
      '기블리', '콰트로포르테', '그레칼레', '레반떼',
    ],
    '페라리': [
      '296 GTB', 'SF90', 'F8', '로마', '포르토피노', '퓨로상게',
    ],
    '람보르기니': [
      '우라칸', '아벤타도르', '우루스',
    ],
    '랜드로버': [
      '디스커버리 스포츠', '디스커버리', '디펜더', '레인지로버 이보크',
      '레인지로버 벨라', '레인지로버 스포츠', '레인지로버',
    ],
    '재규어': [
      'XE', 'XF', 'XJ', 'E-PACE', 'F-PACE', 'I-PACE', 'F-TYPE',
    ],
    '벤틀리': [
      '컨티넨탈 GT', '플라잉스퍼', '벤테이가', 'EXP 100 GT',
    ],
    '롤스로이스': [
      '팬텀', '레이스', '고스트', '컬리넌', '스펙터',
    ],
    '볼보트럭': ['FH', 'FM', 'FMX'],
    // ── 중국 브랜드 ──
    'BYD': [
      'Atto 3', 'Seal', 'Dolphin', '한', '탕',
    ],
  };

  static const List<String> _years = ['2024', '2023', '2022', '2021', '2020', '2019', '2018', '2017', '2016', '2015'];
  static const List<String> _months = ['1월', '2월', '3월', '4월', '5월', '6월', '7월', '8월', '9월', '10월', '11월', '12월'];
  static const List<String> _grades = ['무사고', '단순교환', '침수이력없음', '사고수리이력'];

  void _showPickerDialog(String title, List<String> items, String? current, Function(String) onSelect) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: _mCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 16, 12),
              child: Row(children: [
                Text(title, style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: _mTextSec, size: 20),
                  onPressed: () => Navigator.pop(ctx)),
              ]),
            ),
            const Divider(color: _mBorder, height: 1),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final item = items[i];
                  final isSelected = item == current;
                  return ListTile(
                    dense: true,
                    title: Text(item, style: TextStyle(
                      fontSize: 14, color: isSelected ? _mAccent : Colors.white,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal)),
                    trailing: isSelected
                      ? const Icon(Icons.check, color: _mAccent, size: 18) : null,
                    onTap: () { onSelect(item); Navigator.pop(ctx); },
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _lookup() async {
    final km = _kmCtrl.text.trim();
    if (_selectedMaker == null || _selectedModel == null || _selectedYear == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제조사, 모델, 연식을 선택해주세요')));
      return;
    }
    if (km.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('주행거리를 입력해주세요')));
      return;
    }
    if (km == _kmLastSaved && _kmLastSaved.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('주행거리를 새로 입력해 주세요')));
      return;
    }
    setState(() => _loading = true);
    setState(() => _kmLastSaved = km); // 새 값을 기준으로 업데이트
    await _saveInputData(); // 입력값 자동 저장
    await Future.delayed(const Duration(milliseconds: 1200));
    final yearNum = int.tryParse(_selectedYear!) ?? 2020;
    final kmNum = int.tryParse(km.replaceAll(RegExp(r'[^0-9]'), '')) ?? 50000;
    final importBrands = [
      'BMW', '벤츠', '아우디', '폭스바겐', '포르쉐', '테슬라', '포드', '지프',
      '링컨', '캐딜락', 'GMC', '토요타', '렉서스', '혼다', '닛산', '인피니티',
      '마쓰다', '미쓰비시', '스바루', '볼보', 'MINI', '푸조', '시트로엥', '피아트',
      '알파로메오', '마세라티', '페라리', '람보르기니', '랜드로버', '재규어',
      '벤틀리', '롤스로이스', 'BYD',
    ];
    final isImport = importBrands.contains(_selectedMaker);
    final base = isImport ? 45000000 : 20000000;
    final ageFactor = (2026 - yearNum) * 0.07;
    final kmFactor = (kmNum / 100000) * 0.15;
    final est = (base * (1 - ageFactor - kmFactor)).toInt();
    final low = (est * 0.90).toInt();
    final high = (est * 1.10).toInt();
    setState(() {
      _loading = false;
      _priceResult = {
        'maker': _selectedMaker,
        'model': _selectedModel,
        'year': _selectedYear,
        'month': _selectedMonth ?? '1월',
        'km': km,
        'plate': _plateCtrl.text,
        'grade': _selectedGrade ?? '무사고',
        'low': low, 'mid': est, 'high': high,
        'carGrade': _grade(yearNum, kmNum),
      };
      _step = 1;
    });
  }

  // 신청서 발송 (3곳 매장에 추가)
  // 선택한 매장에만 신청서 전달
  Future<void> _sendToSelectedStores(List<Map<String,dynamic>> selectedStores) async {
    if (_priceResult == null) return;
    setState(() => _applying = true);
    await Future.delayed(const Duration(milliseconds: 800));

    final now = DateTime.now();
    final dateStr = '${now.month}/${now.day} ${now.hour}:${now.minute.toString().padLeft(2,'0')}';
    final carInfo = '${_priceResult!['maker']} ${_priceResult!['model']} ${_priceResult!['year']}년';

    final newApps = selectedStores.map((s) => {
      'storeName':     s['name'],
      'storeRating':   s['rating'] ?? '',
      'storeDistance': s['dist'] ?? '',
      'storeColor':    s['color'] ?? 0xFF4FC3F7,
      'sentAt':        dateStr,
      'cancelled':     false,
      'carInfo':       carInfo,
      'priceResult':   Map<String, dynamic>.from(_priceResult!),
      // 읽음 상태: 'unread'=전달됨/미확인, 'read'=점포가 확인함, 'replied'=견적답변옴
      'readStatus':    'unread',
      // 점포 예상 견적 (replied 상태일 때 채움)
      'estimatePrice': 0,
      'estimateNote':  '',
    }).toList();

    setState(() {
      _applications.addAll(newApps);
      _applying = false;
      _showApplications = true;
    });
    await _saveApplications();

    // ── 전송 완료 팝업 ──
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF0D1B2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: _mGreen.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: _mGreen.withOpacity(0.5), width: 2),
              ),
              child: const Icon(Icons.check_circle_rounded, color: _mGreen, size: 36),
            ),
            const SizedBox(height: 16),
            const Text('전송이 완료되었습니다',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('[신청 완료] AI 시세 기반 신청서가 선택 매장으로 발송되었습니다',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('${selectedStores.length}개 매장에 신청서가 전달되었습니다.\n매장에서 확인 후 연락드립니다.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 13, height: 1.6)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _mAccent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                selectedStores.map((s) => s['name'] as String).join(' · '),
                style: const TextStyle(color: _mAccent, fontSize: 12, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // 주행거리 확인 후 매칭 성공 → 동일 차량 다른 신청서 거래종료 처리
                  final carInfo = _priceResult != null
                    ? '${_priceResult!['maker']} ${_priceResult!['model']} ${_priceResult!['year']}년'
                    : '';
                  if (carInfo.isNotEmpty) {
                    setState(() {
                      for (int i = 0; i < _applications.length; i++) {
                        if (!_applications[i]['cancelled'] &&
                            _applications[i]['carInfo'] == carInfo) {
                          // 새로 전송한 것 제외한 기존 것 거래종료
                        }
                      }
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _mGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('확인', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/car-applications');
                },
                icon: const Icon(Icons.list_alt_rounded, size: 16, color: _mAccent),
                label: const Text('신청 내역 보기',
                  style: TextStyle(color: _mAccent, fontWeight: FontWeight.w600, fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: _mAccent.withOpacity(0.4)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // 신청서 취소
  Future<void> _cancelApplication(int idx) async {
    setState(() => _applications[idx]['cancelled'] = true);
    await _saveApplications();
  }

  String _grade(int year, int km) {
    final age = 2026 - year;
    if (age <= 3 && km < 30000) return 'A+ (최상)';
    if (age <= 5 && km < 60000) return 'A (상)';
    if (age <= 8 && km < 100000) return 'B+ (중상)';
    if (age <= 10 && km < 150000) return 'B (중)';
    return 'C (하)';
  }

  String _fmt(int val) {
    final man = val ~/ 10000;
    final rest = val % 10000;
    if (rest == 0) return '$man만원';
    return '$man만${rest ~/ 1000}천원';
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: _mBg, statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: _mBg,
        body: Column(
          children: [
            // 상단바
            Container(
              color: _mCard,
              padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 10, 16, 14),
              child: Row(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (_step == 1) { setState(() { _step = 0; _priceResult = null; }); }
                      else { Navigator.pop(context); }
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      child: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(_step == 0 ? '💰 내차 시세 조회' : '📊 시세 결과',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                  const Spacer(),
                  // 신청 내역 버튼 (항상 표시)
                  GestureDetector(
                    onTap: () => setState(() => _showApplications = !_showApplications),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _mOrange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _mOrange.withOpacity(0.4)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.history_rounded, color: _mOrange, size: 13),
                        const SizedBox(width: 4),
                        Text('신청내역 ${_applications.length}건',
                          style: const TextStyle(fontSize: 11, color: _mOrange, fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ),
                  if (_step == 1) ...[ 
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => setState(() { _step = 0; _priceResult = null; }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _mAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _mAccent.withOpacity(0.4)),
                        ),
                        child: const Text('재조회', style: TextStyle(fontSize: 11, color: _mAccent)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: _step == 0 ? _buildInputPage() : _buildResultPage(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pickerTile(String label, String? value, String hint, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: _mCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: value != null ? _mAccent.withOpacity(0.5) : _mBorder),
        ),
        child: Row(children: [
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: _mTextSec)),
              const SizedBox(height: 2),
              Text(value ?? hint, style: TextStyle(
                fontSize: 14,
                color: value != null ? Colors.white : _mTextSec.withOpacity(0.5),
                fontWeight: value != null ? FontWeight.w600 : FontWeight.normal)),
            ],
          )),
          Icon(Icons.keyboard_arrow_down_rounded,
            color: value != null ? _mAccent : _mTextSec, size: 22),
        ]),
      ),
    );
  }

  Widget _buildInputPage() {
    final models = _selectedMaker != null
      ? (_makerModels[_selectedMaker] ?? <String>[])
      : <String>[];

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 20, 20,
          MediaQuery.of(context).padding.bottom + 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 차량번호 입력창 (항상 최상단 고정) ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _mCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _plateFound ? _mGreen.withOpacity(0.5) : _mBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.directions_car_rounded, color: _mAccent, size: 18),
                  const SizedBox(width: 8),
                  Text('차량번호 입력', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _plateCtrl,
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: '예) 123가 4567',
                        hintStyle: TextStyle(color: _mTextSec.withOpacity(0.4), fontSize: 13),
                        filled: true, fillColor: _mCard,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _mBorder)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _mBorder)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _mAccent)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      onChanged: (_) { if (_plateFound) setState(() { _plateFound = false; _plateRegDate = null; _plateModelYear = null; }); },
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _plateLoading ? null : _lookupPlate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                      decoration: BoxDecoration(
                        color: _mAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _mAccent.withOpacity(0.5)),
                      ),
                      child: _plateLoading
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: _mAccent, strokeWidth: 2))
                        : Text('조회', style: TextStyle(color: _mAccent, fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                  ),
                ]),
                // 조회 성공 시 최초등록일/연식 고정 표시
                if (_plateFound && _plateRegDate != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _mGreen.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _mGreen.withOpacity(0.3)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.check_circle_rounded, color: _mGreen, size: 14),
                      const SizedBox(width: 6),
                      Text('최초등록일: $_plateRegDate  |  연식: ${_plateModelYear}년식',
                        style: const TextStyle(fontSize: 12, color: _mGreen, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ],
                if (!_plateFound) ...[
                  const SizedBox(height: 8),
                  Text('차량번호를 입력하면 최초등록일과 연식이 자동 표시됩니다',
                    style: TextStyle(fontSize: 11, color: _mTextSec)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 조회 전엔 하단 폼 숨김
          if (!_plateFound) ...[
            Center(
              child: Text('차량번호 조회 후 상세 정보를 입력하세요',
                style: TextStyle(fontSize: 13, color: _mTextSec)),
            ),
          ],

          // 조회 성공 후 상세폼 표시
          if (_plateFound) ...[
          // 안내 배너
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_mOrange.withOpacity(0.15), _mAccent.withOpacity(0.08)],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _mOrange.withOpacity(0.3)),
            ),
            child: Row(children: [
              const Text('💰', style: TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              const Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI 기반 내차 시세 조회',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                  SizedBox(height: 4),
                  Text('팝업에서 선택 후 즉시 시세 범위 확인',
                    style: TextStyle(fontSize: 11, color: _mTextSec)),
                ],
              )),
            ]),
          ),
          const SizedBox(height: 20),

          // 차량번호 + 자동조회 버튼
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🚗 차량 번호 (선택)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
              const SizedBox(height: 6),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _plateCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: '123가 4567',
                      hintStyle: TextStyle(color: _mTextSec.withOpacity(0.4), fontSize: 13),
                      filled: true,
                      fillColor: _mCard,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _mBorder)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _mBorder)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _mAccent)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    onChanged: (_) { if (_plateRegDate != null) setState(() { _plateRegDate = null; _plateModelYear = null; }); },
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _plateLoading ? null : _lookupPlate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                    decoration: BoxDecoration(
                      color: _mAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _mAccent.withOpacity(0.5)),
                    ),
                    child: _plateLoading
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: _mAccent, strokeWidth: 2))
                      : const Icon(Icons.search, color: _mAccent, size: 20),
                  ),
                ),
              ]),
              // 조회 결과 표시
              if (_plateRegDate != null) ...[ 
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _mGreen.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _mGreen.withOpacity(0.3)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.check_circle_rounded, color: _mGreen, size: 14),
                    const SizedBox(width: 6),
                    Text('최초등록일: $_plateRegDate  |  연식: ${_plateModelYear}년식',
                      style: const TextStyle(fontSize: 12, color: _mGreen, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),

          // 제조사 팝업
          _pickerTile('🏭 제조사 *', _selectedMaker, '제조사를 선택하세요', () =>
            _showPickerDialog('제조사 선택', _makerModels.keys.toList(), _selectedMaker, (v) {
              setState(() { _selectedMaker = v; _selectedModel = null; });
            })
          ),
          const SizedBox(height: 10),

          // 모델 팝업
          _pickerTile('🚙 모델 *', _selectedModel,
            _selectedMaker == null ? '제조사를 먼저 선택하세요' : '모델을 선택하세요',
            _selectedMaker == null ? () {} : () =>
              _showPickerDialog('모델 선택', models, _selectedModel, (v) =>
                setState(() => _selectedModel = v))
          ),
          const SizedBox(height: 10),

          // 연식 + 월 (두 칸)
          Row(children: [
            Expanded(child: _pickerTile('📅 연식 *', _selectedYear, '연식 선택', () =>
              _showPickerDialog('연식 선택', _years, _selectedYear, (v) =>
                setState(() => _selectedYear = v))
            )),
            const SizedBox(width: 10),
            Expanded(child: _pickerTile('📆 월 (선택)', _selectedMonth, '월 선택', () =>
              _showPickerDialog('월 선택', _months, _selectedMonth, (v) =>
                setState(() => _selectedMonth = v))
            )),
          ]),
          const SizedBox(height: 10),

          // 주행거리 (텍스트 입력)
          _darkField('📏 주행거리 * (km)', '예: 50000', _kmCtrl,
            keyboardType: TextInputType.number),
          const SizedBox(height: 10),

          // 차량 상태
          _pickerTile('⭐ 차량 상태 (선택)', _selectedGrade, '무사고/사고이력 선택', () =>
            _showPickerDialog('차량 상태', _grades, _selectedGrade, (v) =>
              setState(() => _selectedGrade = v))
          ),
          const SizedBox(height: 20),

          // ── 내차 사진 첨부 섹션 ──
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _mCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _mOrange.withOpacity(0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.photo_camera_rounded, color: _mOrange, size: 18),
                  const SizedBox(width: 8),
                  const Text('내차 사진 첨부 (최대 10장)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                  const Spacer(),
                  Text('${_carPhotos.length}/10',
                    style: TextStyle(fontSize: 12, color: _carPhotos.isEmpty ? _mTextSec : _mOrange, fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 4),
                Text('사진이 많을수록 정확한 시세 조회 및 매입 제안을 받을 수 있습니다.',
                  style: TextStyle(fontSize: 11, color: _mTextSec)),
                const SizedBox(height: 12),
                if (_carPhotos.isNotEmpty) ...[ 
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _carPhotos.length + 1,
                      itemBuilder: (ctx, i) {
                        if (i == _carPhotos.length) {
                          // + 추가 버튼
                          if (_carPhotos.length >= 10) return const SizedBox.shrink();
                          return GestureDetector(
                            onTap: _showPhotoSourceSheet,
                            child: Container(
                              width: 80, height: 80,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: _mBg,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: _mBorder, style: BorderStyle.solid),
                              ),
                              child: const Icon(Icons.add_a_photo_rounded, color: _mTextSec, size: 24),
                            ),
                          );
                        }
                        return Stack(
                          children: [
                            Container(
                              width: 80, height: 80,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: FileImage(_carPhotos[i]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 2, right: 10,
                              child: GestureDetector(
                                onTap: () => setState(() => _carPhotos.removeAt(i)),
                                child: Container(
                                  width: 20, height: 20,
                                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                  child: const Icon(Icons.close, color: Colors.white, size: 12),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _carPhotos.length >= 10 ? null : _showPhotoSourceSheet,
                    icon: const Icon(Icons.add_photo_alternate_rounded, size: 18),
                    label: Text(_carPhotos.isEmpty ? '사진 추가하기' : '사진 추가 (${_carPhotos.length}/10)'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _mOrange,
                      side: BorderSide(color: _mOrange.withOpacity(0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // 조회 버튼 (_kmChanged: 새로운 주행거리 입력 시에만 활성화)
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: (_loading || !_kmChanged) ? null : _lookup,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kmChanged ? _mOrange : _mBorder,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _loading
                ? const SizedBox(width: 22, height: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(_kmChanged ? '시세 조회하기' : '주행거리를 입력해주세요',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                    ],
                  ),
            ),
          ),
          const SizedBox(height: 20),
          // 주의사항
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _mCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _mBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('📌 안내사항',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 8),
                ...['제공되는 시세는 참고용이며 실제 거래가와 차이가 있을 수 있습니다.',
                  '차량 상태, 옵션, 사고 이력에 따라 시세가 달라집니다.',
                  '정확한 시세는 MOINCAR 공인 딜러 상담을 이용하세요.']
                  .map((t) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ', style: TextStyle(color: _mTextSec.withOpacity(0.7), fontSize: 11)),
                        Expanded(child: Text(t,
                          style: TextStyle(fontSize: 11, color: _mTextSec.withOpacity(0.7)))),
                      ],
                    ),
                  )),
              ],
            ),
          ),
          ], // if (_plateFound) 닫기
        ],
      ),
    );
  }

  Widget _buildResultPage() {
    final r = _priceResult!;
    final low  = r['low'] as int;
    final mid  = r['mid'] as int;
    final high = r['high'] as int;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 20, 20,
          MediaQuery.of(context).padding.bottom + 20),
      child: Column(
        children: [
          // 차량 정보 카드
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _mCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _mBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: _mAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(child: Text('🚗', style: TextStyle(fontSize: 26))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${r['year']} ${r['maker']} ${r['model']}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text('주행거리 ${r['km']}km · ${r['carGrade']} · ${r['grade']}',
                        style: TextStyle(fontSize: 12, color: _mTextSec)),
                      if ((r['plate'] as String).isNotEmpty)
                        Text('차량번호: ${r['plate']}',
                          style: TextStyle(fontSize: 11, color: _mAccent)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 시세 범위 카드
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_mOrange.withOpacity(0.15), _mAccent.withOpacity(0.08)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _mOrange.withOpacity(0.4)),
            ),
            child: Column(
              children: [
                const Text('AI 분석 시세 범위',
                  style: TextStyle(fontSize: 13, color: _mTextSec)),
                const SizedBox(height: 12),
                Text(_fmt(mid),
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _mCard,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('최저 ${_fmt(low)}',
                        style: const TextStyle(fontSize: 12, color: _mTextSec)),
                    ),
                    const SizedBox(width: 8),
                    const Text('~', style: TextStyle(color: _mTextSec)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _mCard,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('최고 ${_fmt(high)}',
                        style: const TextStyle(fontSize: 12, color: _mTextSec)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 시세 게이지
                Stack(
                  children: [
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: _mCard,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: 0.65,
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_mOrange, _mAccent]),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('하한가 ${_fmt(low)}', style: TextStyle(fontSize: 10, color: _mTextSec)),
                    Text('상한가 ${_fmt(high)}', style: TextStyle(fontSize: 10, color: _mTextSec)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 시세 요인 분석
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _mCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _mBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('📊 시세 영향 요인',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 12),
                ...[
                  ['연식', '${r['year']}년식', _mAccent, 0.7],
                  ['주행거리', '${r['km']}km', _mOrange, 0.5],
                  ['차량 등급', '${r["carGrade"]}', _mGreen, 0.85],
                  ['시장 수요', '보통', const Color(0xFF8B5CF6), 0.6],
                ].map((item) {
                  final pct = item[3] as double;
                  final color = item[2] as Color;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(item[0] as String,
                              style: TextStyle(fontSize: 12, color: _mTextSec)),
                            Text(item[1] as String,
                              style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Stack(children: [
                          Container(height: 6,
                            decoration: BoxDecoration(
                              color: _mBg, borderRadius: BorderRadius.circular(3))),
                          FractionallySizedBox(
                            widthFactor: pct,
                            child: Container(height: 6,
                              decoration: BoxDecoration(
                                color: color, borderRadius: BorderRadius.circular(3))),
                          ),
                        ]),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── 신청서 내역 바로가기 버튼 ──
          GestureDetector(
              onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CarApplicationHistoryScreen())),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _mCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _mAccent.withOpacity(0.4)),
                ),
                child: Row(children: [
                  Icon(Icons.assignment_rounded, color: _mAccent, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('📋 신청서 내역 보기',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                      Text('진행중 ${_applications.where((a) => !(a['cancelled'] as bool)).length}건 · 탭하여 읽음/안읽음 확인',
                        style: TextStyle(fontSize: 11, color: _mTextSec)),
                    ]),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, color: _mAccent, size: 14),
                ]),
              ),
            ),

          // ── 신청서 발송 + 신청 내역 섹션 ──
          _buildApplicationSection(),
          const SizedBox(height: 10),
          Text('* 제공되는 시세는 AI 분석 기반 참고용입니다.',
            style: TextStyle(fontSize: 11, color: _mTextSec.withOpacity(0.6))),
        ],
      ),
    );
  }

  // ── 수동 신청서 UI (체크박스로 매장 선택 후 전송) ──
  bool _storeCheck0 = true;
  bool _storeCheck1 = true;
  bool _storeCheck2 = true;

  Widget _buildApplicationSection() {
    final stores = [
      {'icon': '🔵', 'name': '대구모터스',     'dist': '0.8km', 'rating': '★4.8', 'color': 0xFF4FC3F7},
      {'icon': '🟢', 'name': '수성카딜러',     'dist': '1.2km', 'rating': '★4.6', 'color': 0xFF10B981},
      {'icon': '🟡', 'name': '범어중고차센터',  'dist': '1.9km', 'rating': '★4.5', 'color': 0xFFFF6B35},
    ];
    final checks = [_storeCheck0, _storeCheck1, _storeCheck2];

    return Column(
      children: [
        // ── 매장 선택 + 신청 버튼 컨테이너 ──
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _mCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _mGreen.withOpacity(0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(Icons.send_rounded, color: _mGreen, size: 18),
                const SizedBox(width: 8),
                const Text('신청서 전송 매장 선택',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
              ]),
              const SizedBox(height: 4),
              Text('원하는 매장을 선택하세요 (최대 3곳)',
                style: TextStyle(fontSize: 11, color: _mTextSec)),
              if (_carPhotos.isNotEmpty) ...[ 
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.photo_rounded, color: _mOrange, size: 13),
                  const SizedBox(width: 4),
                  Text('사진 ${_carPhotos.length}장 함께 전송됩니다',
                    style: TextStyle(fontSize: 11, color: _mOrange, fontWeight: FontWeight.w600)),
                ]),
              ] else ...[ 
                const SizedBox(height: 6),
                Row(children: [
                  Icon(Icons.info_outline_rounded, color: _mTextSec.withOpacity(0.6), size: 13),
                  const SizedBox(width: 4),
                  Text('사진 첨부 시 더 정확한 매입 제안을 받을 수 있습니다',
                    style: TextStyle(fontSize: 11, color: _mTextSec.withOpacity(0.6))),
                ]),
              ],
              const SizedBox(height: 12),
              ...stores.asMap().entries.map((e) {
                final i = e.key;
                final s = e.value;
                final checked = checks[i];
                return GestureDetector(
                  onTap: () => setState(() {
                    if (i == 0) _storeCheck0 = !_storeCheck0;
                    if (i == 1) _storeCheck1 = !_storeCheck1;
                    if (i == 2) _storeCheck2 = !_storeCheck2;
                  }),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: checked ? Color(s['color'] as int).withOpacity(0.1) : _mBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: checked ? Color(s['color'] as int).withOpacity(0.5) : _mBorder),
                    ),
                    child: Row(children: [
                      Icon(checked ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                        color: checked ? Color(s['color'] as int) : _mTextSec, size: 20),
                      const SizedBox(width: 10),
                      Text(s['icon'] as String, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s['name'] as String,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                            Text('${s['dist']}  ${s['rating']}',
                              style: TextStyle(fontSize: 11, color: _mTextSec)),
                          ],
                        ),
                      ),
                      if (checked) Icon(Icons.check_circle_rounded,
                        color: Color(s['color'] as int), size: 16),
                    ]),
                  ),
                );
              }).toList(),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: (!_storeCheck0 && !_storeCheck1 && !_storeCheck2) ? null
                    : () {
                        final selected = <Map<String,dynamic>>[];
                        if (_storeCheck0) selected.add(stores[0]);
                        if (_storeCheck1) selected.add(stores[1]);
                        if (_storeCheck2) selected.add(stores[2]);
                        _sendToSelectedStores(selected);
                      },
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: Text(_carPhotos.isEmpty ? '[신청 완료] 신청서 전송' : '[신청 완료] 사진 ${_carPhotos.length}장 포함'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _mGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── 신청서 진행 안내 ──
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _mCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _mAccent.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(Icons.info_outline_rounded, color: _mAccent, size: 16),
                const SizedBox(width: 6),
                const Text('신청서 진행 안내',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
              ]),
              const SizedBox(height: 10),
              _flowStep('1', '전달완료', '신청서가 해당 매장에 전달되었습니다.', Colors.blue, false),
              _flowArrow(),
              _flowStep('2', '매장 확인중', '매장에서 신청서를 읽고 검토 중입니다.\n아직 읽지 않았다면 다른 매장에 추가 신청하세요.', const Color(0xFF4FC3F7), false),
              _flowArrow(),
              _flowStep('3', '예상견적 도착', '매장이 예상 견적서를 보내왔습니다.\n견적을 확인하고 상담 여부를 결정하세요.', _mAccent, false),
              _flowArrow(),
              _flowStep('4', '상담 진행', '1:1 채팅으로 가격 조정 및 상담을 합니다.', _mGreen, false),
              _flowArrow(),
              _flowStep('5', '재신청 가능', '마음에 안 들면 신청 취소 후\n다른 매장에 새로 신청할 수 있습니다.', _mOrange, false),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── 신청서 카드 목록 ──
        ..._applications.asMap().entries.map((entry) {
          final idx = entry.key;
          final app = entry.value;
          final cancelled = app['cancelled'] as bool;
          final color = Color(app['storeColor'] as int);
          final readStatus = app['readStatus'] as String? ?? 'unread';
          final estimatePrice = app['estimatePrice'] as int? ?? 0;
          final estimateNote  = app['estimateNote']  as String? ?? '';

          Color statusColor;
          String statusLabel;
          IconData statusIcon;
          switch (readStatus) {
            case 'read':
              statusColor = _mAccent; statusLabel = '읽음'; statusIcon = Icons.visibility_rounded; break;
            case 'replied':
              statusColor = _mGreen; statusLabel = '견적도착'; statusIcon = Icons.description_rounded; break;
            default:
              statusColor = _mTextSec; statusLabel = '미확인'; statusIcon = Icons.schedule_rounded;
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _mCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: cancelled ? _mBorder
                  : readStatus == 'replied' ? _mGreen.withOpacity(0.5)
                  : readStatus == 'read'    ? _mAccent.withOpacity(0.3)
                  : color.withOpacity(0.4)),
            ),
            child: Opacity(
              opacity: cancelled ? 0.5 : 1.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 헤더
                  Row(children: [
                    Container(width: 8, height: 8,
                      decoration: BoxDecoration(
                        color: cancelled ? _mBorder : color,
                        shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(app['storeName'] as String,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                        color: cancelled ? _mTextSec : Colors.white))),
                    if (!cancelled) Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(statusIcon, size: 11, color: statusColor),
                        const SizedBox(width: 4),
                        Text(statusLabel,
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor)),
                      ]),
                    ),
                    if (cancelled) const Text('취소됨',
                      style: TextStyle(fontSize: 11, color: Colors.red)),
                  ]),
                  const SizedBox(height: 6),
                  Text('${app['carInfo']}', style: TextStyle(fontSize: 12, color: _mTextSec)),
                  Text('전송: ${app['sentAt']}', style: TextStyle(fontSize: 11, color: _mTextSec)),

                  // 견적 도착시 표시
                  if (!cancelled && readStatus == 'replied' && estimatePrice > 0) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _mGreen.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _mGreen.withOpacity(0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Icon(Icons.description_rounded, size: 14, color: _mGreen),
                            const SizedBox(width: 6),
                            const Text('📋 매장 예상 견적서 도착',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
                          ]),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0A1628),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(children: [
                              Text('예상 매입가',
                                style: TextStyle(fontSize: 11, color: _mTextSec)),
                              const SizedBox(height: 4),
                              Text('${(estimatePrice ~/ 10000)}만원',
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _mGreen)),
                            ]),
                          ),
                          if (estimateNote.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text('매장 메모: $estimateNote',
                              style: TextStyle(fontSize: 11, color: _mTextSec, height: 1.4)),
                          ],
                          const SizedBox(height: 4),
                          Text('* 실제 가격은 차량 직접 확인 후 최종 결정됩니다.',
                            style: TextStyle(fontSize: 10, color: _mTextSec.withOpacity(0.6))),
                        ],
                      ),
                    ),
                  ],

                  if (!cancelled) ...[
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            final pr = app['priceResult'] as Map<String, dynamic>?;
                            Navigator.push(context, MaterialPageRoute(
                              builder: (_) => CarConsultScreen(
                                shopName: app['storeName'] as String,
                                carInfo:  app['carInfo']  as String,
                                estimatedPrice: pr?['mid'] as int? ??
                                  (app['estimatePrice'] as int? ?? 0),
                              ),
                            ));
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            decoration: BoxDecoration(
                              color: (readStatus == 'replied' ? _mGreen : _mAccent).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: (readStatus == 'replied' ? _mGreen : _mAccent).withOpacity(0.4)),
                            ),
                            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Icon(readStatus == 'replied' ? Icons.chat_bubble : Icons.handshake_outlined,
                                color: readStatus == 'replied' ? _mGreen : _mAccent, size: 14),
                              const SizedBox(width: 4),
                              Text(readStatus == 'replied' ? '견적 확인·상담' : '협상 요청',
                                style: TextStyle(fontSize: 12,
                                  color: readStatus == 'replied' ? _mGreen : _mAccent,
                                  fontWeight: FontWeight.w700)),
                            ]),
                          ),
                        ),
                      ),
                      if (readStatus == 'unread') ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => setState(() => _applications[idx]['readStatus'] = 'read'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                            decoration: BoxDecoration(
                              color: _mAccent.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _mAccent.withOpacity(0.3)),
                            ),
                            child: Text('읽음확인',
                              style: TextStyle(fontSize: 11, color: _mAccent, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ] else if (readStatus == 'read') ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => setState(() {
                            _applications[idx]['readStatus']    = 'replied';
                            _applications[idx]['estimatePrice'] =
                              (_applications[idx]['priceResult']?['mid'] as int? ?? 18000000) - 1200000;
                            _applications[idx]['estimateNote']  = '차량 상태 양호 시 협의 가능합니다.';
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                            decoration: BoxDecoration(
                              color: _mGreen.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _mGreen.withOpacity(0.3)),
                            ),
                            child: Text('견적시뮬',
                              style: TextStyle(fontSize: 11, color: _mGreen, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: _mCard,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              title: const Text('신청서 취소',
                                style: TextStyle(color: Colors.white, fontSize: 15)),
                              content: Text('\${app[\'storeName\']}에 보낸 신청서를 취소하시겠습니까?',
                                style: TextStyle(color: _mTextSec, fontSize: 13)),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false),
                                  child: Text('아니오', style: TextStyle(color: _mTextSec))),
                                TextButton(onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('취소하기',
                                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700))),
                              ],
                            ),
                          );
                          if (confirm == true) await _cancelApplication(idx);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.withOpacity(0.3)),
                          ),
                          child: const Text('취소',
                            style: TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ]),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  // ── 신청 플로우 UI 헬퍼 ──
  Widget _flowStep(String num, String title, String desc, Color color, bool active) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24, height: 24,
          decoration: BoxDecoration(
            color: active ? color : color.withOpacity(0.25),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(num, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: active ? color : Colors.white)),
              const SizedBox(height: 2),
              Text(desc, style: TextStyle(fontSize: 11, color: _mTextSec, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _flowArrow() {
    return Padding(
      padding: const EdgeInsets.only(left: 11, top: 3, bottom: 3),
      child: Icon(Icons.arrow_downward_rounded, color: _mBorder, size: 14),
    );
  }

  Widget _darkField(String label, String hint, TextEditingController ctrl,
    {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: _mTextSec.withOpacity(0.4), fontSize: 13),
            filled: true,
            fillColor: _mCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _mBorder)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _mBorder)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _mAccent)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  // ── 차량번호 자동조회 (더미 구현) ──
  Future<void> _lookupPlate() async {
    final plate = _plateCtrl.text.trim();
    if (plate.isEmpty) return;
    setState(() => _plateLoading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    final now = DateTime.now();
    setState(() {
      _plateLoading = false;
      _plateFound = true;  // 조회 성공 → 상세폼 표시
      _plateRegDate  = '${now.year - 4}-${(now.month % 12) + 1}-${(now.day % 28) + 1}';
      _plateModelYear = '${now.year - 4}';
      if (_selectedYear == null) _selectedYear = _plateModelYear;
    });
  }

  // ── 사진 추가 (갤러리 / 카메라) ──
  Future<void> _addCarPhoto(ImageSource source) async {
    if (_carPhotos.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사진은 최대 10장까지 첨부 가능합니다')));
      return;
    }
    try {
      final XFile? picked = await _carPicker.pickImage(
        source: source, imageQuality: 82, maxWidth: 1280);
      if (picked != null) {
        setState(() => _carPhotos.add(File(picked.path)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사진 오류: \$e'), backgroundColor: Colors.red[700]));
    }
  }

  void _showPhotoSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D1B2A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('사진 추가', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _photoSourceBtn(Icons.photo_library_rounded, '갤러리', () {
                Navigator.pop(context);
                _addCarPhoto(ImageSource.gallery);
              }),
              _photoSourceBtn(Icons.camera_alt_rounded, '카메라', () {
                Navigator.pop(context);
                _addCarPhoto(ImageSource.camera);
              }),
            ]),
            const SizedBox(height: 10),
          ]),
        ),
      ),
    );
  }

  Widget _photoSourceBtn(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            color: _mAccent.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(color: _mAccent.withOpacity(0.4)),
          ),
          child: Icon(icon, color: _mAccent, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  @override
  void dispose() {
    _plateCtrl.dispose();
    _kmCtrl.dispose();
    super.dispose();
  }
}

// ==================== 차량 등록 화면 ====================
class VehicleRegisterScreen extends StatefulWidget {
  const VehicleRegisterScreen({super.key});
  @override
  State<VehicleRegisterScreen> createState() => _VehicleRegisterScreenState();
}

class _VehicleRegisterScreenState extends State<VehicleRegisterScreen> {
  static const Color _bg     = Color(0xFF020810);
  static const Color _card   = Color(0xFF0D1B2A);
  static const Color _accent = Color(0xFF4FC3F7);
  static const Color _orange = Color(0xFFFF6B35);
  static const Color _textPri = Colors.white;
  static const Color _textSec = Color(0xFFB0BEC5);
  static const Color _border  = Color(0xFF1E3A5F);

  final _plateCtrl  = TextEditingController();
  final _mileCtrl   = TextEditingController();
  String _selectedMaker = '';
  String _selectedModel = '';
  String _selectedYear  = '';
  String _selectedMonth = '';
  String _fuelType = '가솔린';
  bool _isSaved = false;


  // 제조사-모델 데이터 (CarPriceScreen과 동일)
  static const Map<String, List<String>> _makerModels = {
    '현대': ['아반떼','쏘나타','그랜저','투싼','싼타페','팰리세이드','코나','아이오닉5','아이오닉6','벨로스터','넥쏘'],
    '기아': ['K3','K5','K8','K9','스포티지','쏘렌토','카니발','셀토스','EV6','EV9','스팅어','모하비'],
    '제네시스': ['G70','G80','G90','GV70','GV80','GV60'],
    '쉐보레': ['말리부','트레일블레이저','트래버스','콜로라도','스파크','이쿼녹스'],
    '르노코리아': ['SM6','XM3','QM6','조에','아르카나'],
    'KG모빌리티': ['티볼리','코란도','렉스턴','토레스','무쏘'],
    'BMW': ['3시리즈','5시리즈','7시리즈','X3','X5','X7','i4','iX','M3','M5'],
    '벤츠': ['C클래스','E클래스','S클래스','GLC','GLE','GLS','EQS','AMG GT'],
    '아우디': ['A4','A6','A8','Q3','Q5','Q7','e-tron','RS6'],
    '폭스바겐': ['골프','파사트','티구안','투아렉','ID.4','아테온'],
    '토요타': ['캠리','RAV4','하이랜더','프리우스','C-HR','크라운'],
    '렉서스': ['ES','IS','LS','NX','RX','LX','UX','RZ'],
    '혼다': ['어코드','CR-V','HR-V','파일럿','ZR-V'],
    '테슬라': ['모델3','모델Y','모델S','모델X','사이버트럭'],
    '포르쉐': ['카이엔','마칸','파나메라','911','타이칸'],
    '볼보': ['S60','S90','XC40','XC60','XC90','C40'],
    '재규어': ['F-PACE','E-PACE','I-PACE','XE','XF'],
    '랜드로버': ['디펜더','레인지로버','디스커버리','이보크'],
    '지프': ['랭글러','그랜드체로키','컴패스','글래디에이터'],
    '포드': ['머스탱','익스플로러','레인저','브롱코','F-150'],
    '링컨': ['노틸러스','에비에이터','코르세어','내비게이터'],
    '캐딜락': ['에스컬레이드','CT5','XT4','XT5','LYRIQ'],
    '쉐보레(미국)': ['콜벳','카마로','실버라도'],
    '미니': ['쿠퍼','클럽맨','컨트리맨','페이스맨'],
    '페라리': ['로마','SF90','포르토피노','F8'],
    '람보르기니': ['우라칸','아벤타도르','우루스'],
    '마세라티': ['기블리','콰트로포르테','르반떼'],
    '벤틀리': ['컨티넨탈','플라잉스퍼','벤테이가'],
    '롤스로이스': ['팬텀','고스트','실버스퍼','컬리넌'],
    '애스턴마틴': ['DB11','밴티지','DBS'],
    '인피니티': ['Q50','QX50','QX60','QX80'],
    '시트로엥': ['C3','C4','C5 X'],
  };

  List<String> get _years => List.generate(20, (i) => '${2025-i}년');
  List<String> get _months => List.generate(12, (i) => '${i+1}월');

  void _showPicker(String title, List<String> items, String current, Function(String) onSelect) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: _border))),
            child: Row(children: [
              Expanded(child: Text(title,
                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700))),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, color: Colors.white, size: 20)),
            ]),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (_, i) {
                final item = items[i];
                final isSelected = item == current;
                return ListTile(
                  title: Text(item, style: TextStyle(
                    color: isSelected ? _accent : Colors.white,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                    fontSize: 14)),
                  trailing: isSelected ? Icon(Icons.check_rounded, color: _accent, size: 18) : null,
                  onTap: () { onSelect(item); Navigator.pop(context); },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _pickerField(String label, String value, String hint, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: _textSec, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0A1628),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: value.isNotEmpty ? _accent.withOpacity(0.5) : _border),
            ),
            child: Row(children: [
              Expanded(child: Text(value.isNotEmpty ? value : hint,
                style: TextStyle(
                  color: value.isNotEmpty ? Colors.white : _textSec.withOpacity(0.5),
                  fontSize: 13))),
              Icon(Icons.arrow_drop_down_rounded,
                color: value.isNotEmpty ? _accent : _textSec, size: 22),
            ]),
          ),
        ],
      ),
    );
  }

  final List<Map<String, dynamic>> _myVehicles = [
    {'plate': '123가 4567', 'maker': '현대', 'model': '아반떼', 'year': '2021', 'fuel': '가솔린',
     'mile': '45,200', 'lastService': '2024-12-10', 'color': 0xFF4FC3F7},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          Container(
            color: _card,
            padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 8, 16, 14),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios_new, color: _textPri, size: 20)),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('🚗 내 차량 관리',
                    style: TextStyle(color: _textPri, fontSize: 17, fontWeight: FontWeight.w700))),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 등록된 차량 목록
                if (_myVehicles.isNotEmpty) ...[
                  const Text('등록된 차량',
                    style: TextStyle(color: _textSec, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ..._myVehicles.map((v) => _buildVehicleCard(v)),
                  const SizedBox(height: 20),
                ],

                // 새 차량 등록
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _accent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('+ 새 차량 등록',
                              style: TextStyle(color: _accent, fontSize: 12, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _VehicleField(ctrl: _plateCtrl, label: '차량 번호', hint: '예) 123가 4567'),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _pickerField('제조사', _selectedMaker, '선택하세요', () {
                            _showPicker('제조사 선택', _makerModels.keys.toList(), _selectedMaker, (v) {
                              setState(() { _selectedMaker = v; _selectedModel = ''; });
                            });
                          })),
                          const SizedBox(width: 10),
                          Expanded(child: _pickerField('모델명', _selectedModel, '선택하세요', () {
                            if (_selectedMaker.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('제조사를 먼저 선택해주세요')));
                              return;
                            }
                            _showPicker('모델 선택', _makerModels[_selectedMaker] ?? [], _selectedModel, (v) {
                              setState(() => _selectedModel = v);
                            });
                          })),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _pickerField('연식', _selectedYear, '선택', () {
                            _showPicker('연식 선택', _years, _selectedYear, (v) {
                              setState(() => _selectedYear = v);
                            });
                          })),
                          const SizedBox(width: 10),
                          Expanded(child: _pickerField('등록월', _selectedMonth, '선택', () {
                            _showPicker('등록월 선택', _months, _selectedMonth, (v) {
                              setState(() => _selectedMonth = v);
                            });
                          })),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _VehicleField(ctrl: _mileCtrl, label: '현재 주행거리(km)', hint: '45000', isNum: true),
                      const SizedBox(height: 10),
                      const Text('연료 유형', style: TextStyle(color: _textSec, fontSize: 12)),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: ['가솔린', '디젤', '하이브리드', 'EV', 'LPG'].map((f) =>
                            GestureDetector(
                              onTap: () => setState(() => _fuelType = f),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  color: _fuelType == f ? _accent.withOpacity(0.2) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: _fuelType == f ? _accent : _border),
                                ),
                                child: Text(f,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _fuelType == f ? _accent : _textSec,
                                    fontWeight: _fuelType == f ? FontWeight.w700 : FontWeight.normal,
                                  )),
                              ),
                            )
                          ).toList(),
                        ),
                      ),

                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_plateCtrl.text.isNotEmpty) {
                              setState(() {
                                _myVehicles.add({
                                  'plate': _plateCtrl.text,
                                  'maker': _selectedMaker,
                                  'model': _selectedModel,
                                  'year': _selectedYear,
                                  'month': _selectedMonth,
                                  'fuel': _fuelType,
                                  'mile': _mileCtrl.text,
                                  'lastService': '-',
                                  'color': 0xFFFF6B35,
                                });
                                _plateCtrl.clear(); _mileCtrl.clear();
                                _selectedMaker = ''; _selectedModel = ''; _selectedYear = ''; _selectedMonth = '';
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('✅ 차량이 등록되었습니다')));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('차량 번호를 입력해주세요')));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _accent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('차량 등록하기',
                            style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(Map<String, dynamic> v) {
    final color = Color(v['color'] as int);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: Text('🚗', style: TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${v['maker']} ${v['model']} (${v['year']})',
                  style: const TextStyle(color: _textPri, fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text('${v['plate']}  ·  ${v['fuel']}  ·  ${v['mile']}km',
                  style: const TextStyle(color: _textSec, fontSize: 11)),
                Text('최근 정비: ${v['lastService']}',
                  style: TextStyle(color: color, fontSize: 11)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const VehicleMaintenanceScreen())),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _orange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _orange.withOpacity(0.4)),
              ),
              child: const Text('정비이력',
                style: TextStyle(color: _orange, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label, hint;
  final bool isNum;
  const _VehicleField({required this.ctrl, required this.label, required this.hint, this.isNum = false});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 12)),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl,
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF4A6080), fontSize: 12),
          filled: true,
          fillColor: const Color(0xFF020810),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF1E3A5F)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF1E3A5F)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF4FC3F7)),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    ],
  );
}

// ==================== 차량 정비 이력 화면 ====================
class VehicleMaintenanceScreen extends StatefulWidget {
  const VehicleMaintenanceScreen({super.key});
  @override
  State<VehicleMaintenanceScreen> createState() => _VehicleMaintenanceScreenState();
}

class _VehicleMaintenanceScreenState extends State<VehicleMaintenanceScreen> {
  static const Color _bg     = Color(0xFF020810);
  static const Color _card   = Color(0xFF0D1B2A);
  static const Color _accent = Color(0xFF4FC3F7);
  static const Color _orange = Color(0xFFFF6B35);
  static const Color _green  = Color(0xFF10B981);
  static const Color _purple = Color(0xFF8B5CF6);
  static const Color _textPri = Colors.white;
  static const Color _textSec = Color(0xFFB0BEC5);
  static const Color _border  = Color(0xFF1E3A5F);

  // ── 날짜 키: 'YYYY-MM' 단위로 그룹화 ─────────────────────────
  String _monthKey(DateTime dt) =>
      '${dt.year}년 ${dt.month.toString().padLeft(2, '0')}월';

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState(),
      builder: (context, _) {
        final allRecords = AppState().maintenanceHistory;
        final totalCost = allRecords.fold(0, (s, r) => s + r.totalCost);

        // ── maintenanceHistory만 사용 (하드코딩 이력 제거) ──
        final allItems = allRecords.map((rec) => <String, dynamic>{
          'isKaa': true,
          'date': '${rec.createdAt.year}-${rec.createdAt.month.toString().padLeft(2,"0")}-${rec.createdAt.day.toString().padLeft(2,"0")}',
          'monthKey': _monthKey(rec.createdAt),
          'rec': rec,
        }).toList()
          ..sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));

        // 월별 그룹화
        final Map<String, List<Map<String, dynamic>>> grouped = {};
        for (final item in allItems) {
          final key = item['monthKey'] as String;
          grouped.putIfAbsent(key, () => []).add(item);
        }
        final groupKeys = grouped.keys.toList(); // 이미 역순 정렬됨

        return Scaffold(
          backgroundColor: _bg,
          body: Column(
            children: [
              // ── AppBar: leading 좌측 고정, centerTitle ──
              Container(
                color: _card,
                padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).padding.top, 16, 0),
                child: AppBar(
                  backgroundColor: _card,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  centerTitle: true,
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _textPri, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  title: const Column(
                    children: [
                      Text('차량 정비 이력',
                        style: TextStyle(color: _textPri, fontSize: 17, fontWeight: FontWeight.w700)),
                      Text('123가 4567 · 현대 아반떼 2021',
                        style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 11)),
                    ],
                  ),
                  actions: [
                    GestureDetector(
                      onTap: () => _showAddMaintenanceDialog(),
                      child: Container(
                        margin: const EdgeInsets.only(right: 4, bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _accent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _accent.withOpacity(0.5)),
                        ),
                        child: const Text('+ 기록 추가',
                          style: TextStyle(color: _accent, fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // ── 요약 카드 ──
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_orange.withOpacity(0.12), _accent.withOpacity(0.08)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _orange.withOpacity(0.25)),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: _SummaryItem(label: '총 정비 횟수', value: '${allItems.length}회', color: _textPri)),
                          Expanded(child: _SummaryItem(label: '총 비용', value: '${(totalCost / 10000).toStringAsFixed(0)}만원', color: _orange)),
                          Expanded(child: _SummaryItem(label: '현재 주행', value: '45,200km', color: _accent)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // ── 다음 정비 알림 ──
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _green.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _green.withOpacity(0.3)),
                      ),
                      child: const Row(
                        children: [
                          Text('⏰', style: TextStyle(fontSize: 16)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('다음 엔진오일 교환 권장',
                                  style: TextStyle(color: Color(0xFF10B981), fontSize: 13, fontWeight: FontWeight.w700)),
                                Text('45,100km 도달 시 (현재 900km 남음)',
                                  style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 11)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── 날짜별 그룹 렌더링 ──────────────────────
                    ...groupKeys.expand((monthKey) {
                      final items = grouped[monthKey]!;
                      return [
                        // 월 헤더
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8, top: 4),
                          child: Row(children: [
                            // 월 레이블 pill
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _accent.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: _accent.withOpacity(0.35)),
                              ),
                              child: Text(monthKey,
                                style: TextStyle(color: _accent, fontSize: 12, fontWeight: FontWeight.w700)),
                            ),
                            const Spacer(),
                            // ── Circle Badge: 해당 월 서비스 건수 (오른쪽 끝) ──
                            Text('${items.length}건',
                              style: TextStyle(color: _textSec.withOpacity(0.7), fontSize: 11)),
                            const SizedBox(width: 6),
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: _accent,
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(
                                  color: _accent.withOpacity(0.45),
                                  blurRadius: 6, offset: const Offset(0, 2),
                                )],
                              ),
                              child: Center(
                                child: Text('${items.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    height: 1.0,
                                  )),
                              ),
                            ),
                          ]),
                        ),
                        // 해당 월 항목들 (모두 KAA 이력)
                        ...items.asMap().entries.map((e) {
                          final idx = e.key;
                          final item = e.value;
                          final isLast = idx == items.length - 1;
                          final rec = item['rec'] as MaintenanceRecord;
                          return _buildKaaRecordCard(context, rec, isLast);
                        }),
                        const SizedBox(height: 8),
                      ];
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── KAA 확정 내역 카드 ─────────────────────────────────────
  Widget _buildKaaRecordCard(BuildContext context, MaintenanceRecord rec, bool isLast) {
    final costStr = rec.totalCost.toString()
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    return GestureDetector(
      onTap: () {
        final store = AppData.stores.firstWhere(
          (s) => s.id == rec.storeId,
          orElse: () => AppData.stores.first);
        Navigator.pushNamed(context, '/store-detail', arguments: store);
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: _green.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: _green.withOpacity(0.4)),
              ),
              child: const Center(child: Text('🔧', style: TextStyle(fontSize: 14))),
            ),
            if (!isLast) Container(width: 1, height: 108, color: _border),
          ]),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _green.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _green.withOpacity(0.3)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(4)),
                    child: const Text('KAA 확정', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right_rounded, color: Color(0xFF10B981), size: 14),
                  const Spacer(),
                  Text('${rec.createdAt.year}-${rec.createdAt.month.toString().padLeft(2,"0")}-${rec.createdAt.day.toString().padLeft(2,"0")}',
                    style: const TextStyle(color: _textSec, fontSize: 10)),
                ]),
                const SizedBox(height: 6),
                Text(rec.repairType,
                  style: const TextStyle(color: _textPri, fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text('${rec.storeName}  ·  ${rec.carName}',
                  style: const TextStyle(color: _textSec, fontSize: 11)),
                const SizedBox(height: 6),
                Row(children: [
                  const Text('비용: ', style: TextStyle(color: _textSec, fontSize: 11)),
                  Text('${costStr}원',
                    style: const TextStyle(color: _textPri, fontSize: 12, fontWeight: FontWeight.w700)),
                  if (rec.schedule.isNotEmpty) ...[
                    const Spacer(),
                    Text(rec.schedule, style: const TextStyle(color: _green, fontSize: 10, fontWeight: FontWeight.w600)),
                  ],
                ]),
                const SizedBox(height: 8),
                // ── 점포 상세보기 + 이력 기반 재견적 ──
                Row(children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(
                        color: _green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _green.withOpacity(0.35)),
                      ),
                      child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.store_rounded, color: _green, size: 13),
                        SizedBox(width: 4),
                        Text('점포 상세보기',
                          style: TextStyle(color: _green, fontSize: 11, fontWeight: FontWeight.w700)),
                      ]),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/quote-request'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        decoration: BoxDecoration(
                          color: _accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _accent.withOpacity(0.35)),
                        ),
                        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.history_rounded, color: _accent, size: 13),
                          SizedBox(width: 4),
                          Text('이력 기반 재견적',
                            style: TextStyle(color: _accent, fontSize: 11, fontWeight: FontWeight.w700)),
                        ]),
                      ),
                    ),
                  ),
                ]),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // _buildHistoryCard 제거 (maintenanceHistory 통합으로 불필요)

  void _showAddMaintenanceDialog() {
    final typeCtrl = TextEditingController();
    final costCtrl = TextEditingController();
    final shopCtrl = TextEditingController();
    final mileCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0D1B2A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20,
          MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🔧 정비 기록 추가',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _VehicleField(ctrl: typeCtrl, label: '정비 항목', hint: '예) 엔진오일 교환'),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _VehicleField(ctrl: costCtrl, label: '비용', hint: '89000', isNum: true)),
              const SizedBox(width: 10),
              Expanded(child: _VehicleField(ctrl: mileCtrl, label: '주행거리(km)', hint: '45000', isNum: true)),
            ]),
            const SizedBox(height: 10),
            _VehicleField(ctrl: shopCtrl, label: '정비점', hint: '예) MOINCAR 추천 정비소'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ 정비 기록이 추가되었습니다')));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4FC3F7),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('기록 저장',
                  style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label, value;
  final Color color;
  const _SummaryItem({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w800)),
    const SizedBox(height: 2),
    Text(label, style: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 10)),
  ]);
}

// ==================== 알림 설정 ====================
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});
  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _allNotif     = true;
  bool _quoteNotif   = true;
  bool _couponNotif  = true;
  bool _newsNotif    = false;
  bool _priceNotif   = true;
  bool _certNotif    = true;
  bool _soundOn      = true;
  bool _vibrationOn  = true;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: _mBg, statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: _mBg,
        body: Column(
          children: [
            Container(
              color: _mCard,
              padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 10, 16, 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text('🔔 알림 설정',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _settingSection('전체 설정', [
                    _switchTile('전체 알림', '모든 알림을 켜거나 끕니다', Icons.notifications_rounded, _allNotif,
                      (v) => setState(() { _allNotif = v; if (!v) { _quoteNotif = false; _couponNotif = false; _newsNotif = false; _priceNotif = false; _certNotif = false; } })),
                  ]),
                  const SizedBox(height: 12),
                  _settingSection('알림 유형', [
                    _switchTile('견적 알림', '견적 요청·결과 알림', Icons.description_outlined, _quoteNotif,
                      (v) => setState(() => _quoteNotif = v)),
                    _switchTile('쿠폰 알림', '쿠폰 발급·만료 알림', Icons.local_offer_outlined, _couponNotif,
                      (v) => setState(() => _couponNotif = v)),
                    _switchTile('시세 알림', '내 차 시세 변동 알림', Icons.trending_up, _priceNotif,
                      (v) => setState(() => _priceNotif = v)),
                    _switchTile('인증 알림', '점포 인증 관련 알림', Icons.verified_outlined, _certNotif,
                      (v) => setState(() => _certNotif = v)),
                    _switchTile('뉴스 알림', '자동차 관련 뉴스 알림', Icons.newspaper_outlined, _newsNotif,
                      (v) => setState(() => _newsNotif = v)),
                  ]),
                  const SizedBox(height: 12),
                  _settingSection('알림 방식', [
                    _switchTile('소리', '알림 소리 켜기', Icons.volume_up_outlined, _soundOn,
                      (v) => setState(() => _soundOn = v)),
                    _switchTile('진동', '알림 진동 켜기', Icons.vibration, _vibrationOn,
                      (v) => setState(() => _vibrationOn = v)),
                  ]),
                  const SizedBox(height: 20),
                  SafeArea(
                    top: false,
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('✅ 알림 설정이 저장되었습니다')));
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.save_rounded, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text('알림 설정 저장', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingSection(String title, List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: _mCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _mBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(title,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                color: _mTextSec.withOpacity(0.8), letterSpacing: 0.5)),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _switchTile(String title, String sub, IconData icon, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: _mAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: _mAccent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
                Text(sub, style: TextStyle(fontSize: 11, color: _mTextSec.withOpacity(0.7))),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.red,
            activeTrackColor: Colors.red.withOpacity(0.35),
            inactiveThumbColor: _mTextSec,
            inactiveTrackColor: _mBorder,
          ),
        ],
      ),
    );
  }
}

// ==================== 개인정보 설정 ====================
class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});
  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _locationConsent = true;
  bool _marketingConsent = false;
  bool _analyticsConsent = true;
  bool _thirdPartyConsent = false;

  // 로그인 타입 감지 (실제 앱에서는 AppState에서 가져옴)
  String get _loginType => AppState().user?.loginType ?? 'social'; // 'normal' or 'social'
  bool get _isSocialLogin => _loginType != 'normal';

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: _mBg, statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: _mBg,
        body: Column(
          children: [
            Container(
              color: _mCard,
              padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 10, 16, 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text('🔒 개인정보 설정',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // 개인정보 요약 카드
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [_mAccent.withOpacity(0.1), _mBg]),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _mAccent.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Text('🛡️', style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('개인정보 보호',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                              SizedBox(height: 3),
                              Text('MOINCAR는 고객님의 개인정보를 안전하게 보호합니다.',
                                style: TextStyle(fontSize: 11, color: _mTextSec)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  _privacySection('동의 항목', [
                    _consentTile('위치 정보 활용', '주변 점포 검색에 사용됩니다', _locationConsent,
                      (v) => setState(() => _locationConsent = v)),
                    _consentTile('마케팅 정보 수신', '혜택 및 이벤트 정보를 받습니다', _marketingConsent,
                      (v) => setState(() => _marketingConsent = v)),
                    _consentTile('서비스 분석 동의', '앱 개선을 위한 익명 데이터 수집', _analyticsConsent,
                      (v) => setState(() => _analyticsConsent = v)),
                    _consentTile('제3자 정보 제공', '파트너사 맞춤 서비스 제공', _thirdPartyConsent,
                      (v) => setState(() => _thirdPartyConsent = v)),
                  ]),
                  const SizedBox(height: 12),

                  // 로그인 타입 안내 배너
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: _isSocialLogin
                        ? const Color(0xFFFEE500).withOpacity(0.1)
                        : _mAccent.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _isSocialLogin
                        ? const Color(0xFFFEE500).withOpacity(0.4)
                        : _mAccent.withOpacity(0.3)),
                    ),
                    child: Row(children: [
                      Text(_isSocialLogin ? '🔑' : '👤', style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(
                          _isSocialLogin ? '간편 로그인 (SNS) 사용자' : '일반 회원 (ID·비밀번호)',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                        Text(
                          _isSocialLogin
                            ? '비밀번호·이메일 변경은 SNS 계정에서 직접 변경하세요'
                            : '아이디·비밀번호·이메일 변경이 가능합니다',
                          style: TextStyle(fontSize: 11, color: _mTextSec)),
                      ])),
                    ]),
                  ),
                  const SizedBox(height: 12),

                  _privacySection('계정 관리', [
                    _actionTileWithDisable('비밀번호 변경', Icons.lock_outline, _mAccent,
                      disabled: _isSocialLogin,
                      disabledMsg: 'SNS 간편 로그인 사용자는\nSNS 계정에서 비밀번호를 변경하세요',
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('비밀번호 변경 기능 준비중')))),
                    _actionTileWithDisable('이메일 변경', Icons.email_outlined, _mAccent,
                      disabled: _isSocialLogin,
                      disabledMsg: 'SNS 간편 로그인 사용자는\n이메일 변경이 제한됩니다',
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('이메일 변경 기능 준비중')))),
                    _actionTile('계정 삭제', Icons.delete_outline, Colors.red,
                      () => _showDeleteAccountDialog(context)),
                  ]),
                  const SizedBox(height: 12),

                  _privacySection('개인정보 문서', [
                    _docTile('개인정보 처리방침', '최종 수정: 2025년 1월', Icons.article_outlined),
                    _docTile('서비스 이용약관', '최종 수정: 2025년 1월', Icons.description_outlined),
                    _docTile('위치기반 서비스 약관', '최종 수정: 2025년 1월', Icons.location_on_outlined),
                  ]),
                  const SizedBox(height: 20),

                  SafeArea(
                    top: false,
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('✅ 개인정보 설정이 저장되었습니다')));
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _mAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.save_rounded, color: Color(0xFF020810), size: 18),
                          SizedBox(width: 8),
                          Text('개인정보 설정 저장', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF020810))),
                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _privacySection(String title, List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: _mCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _mBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(title,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                color: _mTextSec.withOpacity(0.8))),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _consentTile(String title, String sub, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
                Text(sub, style: TextStyle(fontSize: 11, color: _mTextSec.withOpacity(0.7))),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: _mAccent,
            activeTrackColor: _mAccent.withOpacity(0.3),
            inactiveThumbColor: _mTextSec,
            inactiveTrackColor: _mBorder,
          ),
        ],
      ),
    );
  }

  Widget _actionTileWithDisable(String title, IconData icon, Color color,
    {required bool disabled, String disabledMsg = '', required VoidCallback onTap}) {
    return InkWell(
      onTap: disabled
        ? () => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(disabledMsg), duration: const Duration(seconds: 3)))
        : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: disabled ? _mTextSec : color),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: TextStyle(
                fontSize: 14, color: disabled ? _mTextSec : Colors.white,
                fontWeight: FontWeight.w500)),
              if (disabled)
                Text('SNS 계정 설정에서 변경하세요',
                  style: TextStyle(fontSize: 10, color: Colors.orange.shade300)),
            ])),
            Icon(disabled ? Icons.lock_rounded : Icons.arrow_forward_ios,
              size: disabled ? 16 : 14,
              color: disabled ? Colors.orange.shade300 : _mTextSec),
          ],
        ),
      ),
    );
  }

  Widget _actionTile(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w500))),
            Icon(Icons.chevron_right, size: 16, color: _mTextSec.withOpacity(0.4)),
          ],
        ),
      ),
    );
  }

  Widget _docTile(String title, String sub, IconData icon) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: _mTextSec),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
                  Text(sub, style: TextStyle(fontSize: 11, color: _mTextSec.withOpacity(0.6))),
                ],
              ),
            ),
            Icon(Icons.open_in_new, size: 14, color: _mTextSec.withOpacity(0.4)),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _mCard,
        title: const Text('계정 삭제', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        content: Text('계정을 삭제하면 모든 데이터가 영구적으로 삭제됩니다.\n정말 삭제하시겠습니까?',
          style: TextStyle(color: _mTextSec, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소', style: TextStyle(color: _mTextSec)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('계정 삭제 요청이 접수되었습니다')));
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ==================== 로그아웃 확인 ====================
class LogoutScreen extends StatelessWidget {
  const LogoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: _mBg, statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: _mBg,
        body: Column(
          children: [
            Container(
              color: _mCard,
              padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 10, 16, 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text('로그아웃',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.red.withOpacity(0.3), width: 2),
                        ),
                        child: const Icon(Icons.logout, color: Colors.red, size: 36),
                      ),
                      const SizedBox(height: 24),
                      const Text('로그아웃 하시겠습니까?',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                      const SizedBox(height: 12),
                      Text('로그아웃 후 다시 로그인이 필요합니다.\n자동 로그인이 해제됩니다.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: _mTextSec, height: 1.5)),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            AppState().logout();
                            Navigator.pushNamedAndRemoveUntil(context, '/intro', (_) => false);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('로그아웃',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: _mBorder),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text('취소', style: TextStyle(fontSize: 16, color: _mTextSec)),
                        ),
                      ),
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
}

// ══════════════════════════════════════════════════════════════════════════════
// 차량 상담 화면 (가격 조정 + 1:1 채팅)
// ══════════════════════════════════════════════════════════════════════════════
class CarConsultScreen extends StatefulWidget {
  final String shopName;
  final String carInfo;
  final int estimatedPrice;
  const CarConsultScreen({
    super.key,
    this.shopName = '대구모터스',
    this.carInfo = '2022 현대 아반떼',
    this.estimatedPrice = 18000000,
  });

  @override
  State<CarConsultScreen> createState() => _CarConsultScreenState();
}

class _CarConsultScreenState extends State<CarConsultScreen>
    with SingleTickerProviderStateMixin {
  static const Color _bg     = Color(0xFF020810);
  static const Color _card   = Color(0xFF0D1B2A);
  static const Color _br     = Color(0xFF1E3A5F);
  static const Color _accent = Color(0xFF4FC3F7);
  static const Color _orange = Color(0xFFFF6B35);
  static const Color _green  = Color(0xFF10B981);
  static const Color _tPri   = Colors.white;
  static const Color _tSec   = Color(0xFFB0BEC5);

  late TabController _tab;
  late int _offeredPrice;
  double _sliderVal = 0.0;
  bool _agreed = false;
  final _chatCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  final List<Map<String, dynamic>> _messages = [
    {'from': 'shop', 'text': '안녕하세요! 신청서 잘 받았습니다 😊\n차량 상태 사진 몇 장 더 보내주실 수 있을까요?', 'time': '14:02'},
    {'from': 'me',   'text': '네, 사진 보내드릴게요!', 'time': '14:05'},
    {'from': 'shop', 'text': '감사합니다. 내부 상태도 함께 보내주시면 더 정확한 견적을 드릴 수 있어요.', 'time': '14:06'},
  ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _offeredPrice = (widget.estimatedPrice * 0.92).toInt();
    _sliderVal = 0.0;
  }

  // ── 내차팔기 매칭 완료 팝업 (전화번호 입력 → 점포 알림 → 거래종료) ──
  Future<void> _showSellMatchPopup(int finalPrice) async {
    final phoneCtrl = TextEditingController();
    final fmt = _fmt(finalPrice);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => Dialog(
          backgroundColor: const Color(0xFF0D1B2A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: _green.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: _green.withOpacity(0.5), width: 2),
                ),
                child: const Icon(Icons.handshake_rounded, color: _green, size: 28),
              ),
              const SizedBox(height: 14),
              Text('$fmt 매매 동의 완료!',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 4),
              Text('${widget.shopName}에 연락처를 전달합니다.',
                style: const TextStyle(fontSize: 12, color: Color(0xFFB0BEC5))),
              const SizedBox(height: 16),
              // 전화번호 입력
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                decoration: InputDecoration(
                  labelText: '전화번호',
                  labelStyle: const TextStyle(color: Color(0xFFB0BEC5)),
                  hintText: '010-0000-0000',
                  hintStyle: const TextStyle(color: Color(0xFF455A64)),
                  filled: true,
                  fillColor: const Color(0xFF020810),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF1E3A5F))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF1E3A5F))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _green)),
                  prefixIcon: const Icon(Icons.phone_rounded, color: _green, size: 18),
                ),
                onChanged: (_) => setD(() {}),
              ),
              const SizedBox(height: 6),
              Text('* 입력하신 번호는 ${widget.shopName}에게만 전달됩니다.',
                style: const TextStyle(fontSize: 10, color: Color(0xFF607D8B))),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF1E3A5F)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('취소', style: TextStyle(color: Color(0xFFB0BEC5))),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: phoneCtrl.text.trim().length >= 9 ? () async {
                      final phone = phoneCtrl.text.trim();
                      Navigator.pop(ctx);
                      // 다른 점포 거래종료 처리
                      final prefs = await SharedPreferences.getInstance();
                      final savedJson = prefs.getString('cp_applications_json');
                      if (savedJson != null && savedJson.isNotEmpty) {
                        try {
                          final items = savedJson.split('|||');
                          final updated = items.map((item) {
                            final parts = item.split('||');
                            if (parts.length >= 7 && parts[6] == widget.carInfo && parts[0] != widget.shopName) {
                              final newParts = List<String>.from(parts);
                              if (newParts.length > 5) newParts[5] = 'true';
                              return newParts.join('||');
                            }
                            return item;
                          }).join('|||');
                          await prefs.setString('cp_applications_json', updated);
                        } catch (_) {}
                      }
                      if (!mounted) return;
                      // 완료 스낵바
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        backgroundColor: _green,
                        content: Text('✅ 매칭 완료! ${widget.shopName}에 번호 $phone 전달됨. 다른 신청서는 자동 거래종료됩니다.'),
                        duration: const Duration(seconds: 4),
                      ));
                      Navigator.pop(context); // 협상화면 닫기
                    } : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('전송 완료', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tab.dispose();
    _chatCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  String _fmt(int v) {
    final man = v ~/ 10000;
    final rest = v % 10000;
    return rest == 0 ? '$man만원' : '$man만${rest ~/ 1000}천원';
  }

  void _sendMsg() {
    final text = _chatCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({'from': 'me', 'text': text, 'time': '지금'});
      _chatCtrl.clear();
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() {
        _messages.add({'from': 'shop', 'text': '확인했습니다! 잠시 후 연락드리겠습니다. 😊', 'time': '지금'});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final adjustedPrice = (_offeredPrice + (_sliderVal * 2000000)).toInt();

    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          // 상단바
          Container(
            color: _card,
            padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 10, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.shopName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                      Text(widget.carInfo,
                        style: const TextStyle(fontSize: 11, color: _tSec)),
                    ],
                  )),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _green.withOpacity(0.4)),
                    ),
                    child: const Text('● 상담중', style: TextStyle(color: _green, fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                ]),
                const SizedBox(height: 12),
                TabBar(
                  controller: _tab,
                  tabs: const [Tab(text: '💰 가격 조정'), Tab(text: '💬 1:1 채팅')],
                  labelColor: _accent,
                  unselectedLabelColor: _tSec,
                  indicatorColor: _accent,
                  labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                // ── 탭 1: 가격 조정 ──
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // 차량 정보 카드
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _card,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _br),
                        ),
                        child: Row(children: [
                          Container(
                            width: 50, height: 50,
                            decoration: BoxDecoration(
                              color: _accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(child: Text('🚗', style: TextStyle(fontSize: 24))),
                          ),
                          const SizedBox(width: 14),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(widget.carInfo,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _tPri)),
                            Text('${widget.shopName} 제시 견적',
                              style: const TextStyle(fontSize: 11, color: _tSec)),
                          ])),
                        ]),
                      ),
                      const SizedBox(height: 16),

                      // 가격 제안 카드
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_orange.withOpacity(0.15), _accent.withOpacity(0.08)]),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _orange.withOpacity(0.4)),
                        ),
                        child: Column(children: [
                          const Text('매장 제시 가격', style: TextStyle(fontSize: 12, color: _tSec)),
                          const SizedBox(height: 8),
                          Text(_fmt(adjustedPrice),
                            style: const TextStyle(
                              fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white)),
                          const SizedBox(height: 4),
                          Text('AI 시세 ${_fmt(widget.estimatedPrice)} 대비 ${(((adjustedPrice - widget.estimatedPrice) / widget.estimatedPrice) * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 12,
                              color: adjustedPrice >= widget.estimatedPrice ? _green : _orange)),

                          const SizedBox(height: 20),
                          // 가격 조정 슬라이더
                          const Text('가격 협상 요청', style: TextStyle(fontSize: 12, color: _tSec)),
                          const SizedBox(height: 8),
                          Row(children: [
                            Text('-100만', style: TextStyle(fontSize: 10, color: _orange)),
                            Expanded(
                              child: SliderTheme(
                                data: SliderThemeData(
                                  trackHeight: 4,
                                  activeTrackColor: _accent,
                                  inactiveTrackColor: _br,
                                  thumbColor: _accent,
                                  overlayColor: _accent.withOpacity(0.2),
                                ),
                                child: Slider(
                                  value: _sliderVal,
                                  min: -1.0, max: 1.0,
                                  onChanged: (v) => setState(() => _sliderVal = v),
                                ),
                              ),
                            ),
                            Text('+100만', style: TextStyle(fontSize: 10, color: _green)),
                          ]),
                          Text('요청 조정액: ${_sliderVal >= 0 ? '+' : ''}${(_sliderVal * 100).round()}만원',
                            style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700,
                              color: _sliderVal >= 0 ? _green : _orange)),
                        ]),
                      ),
                      const SizedBox(height: 16),

                      // 합의 체크박스
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _br),
                        ),
                        child: Row(children: [
                          Checkbox(
                            value: _agreed,
                            onChanged: (v) => setState(() => _agreed = v!),
                            activeColor: _green,
                            checkColor: _bg,
                            side: BorderSide(color: _br),
                          ),
                          Expanded(child: Text(
                            '${_fmt(adjustedPrice)} 가격에 매매 진행에 동의합니다',
                            style: const TextStyle(fontSize: 13, color: _tPri))),
                        ]),
                      ),
                      const SizedBox(height: 16),

                      // 가격 협상 요청 / 동의 버튼
                      Row(children: [
                        Expanded(child: OutlinedButton(
                          onPressed: () {
                            _tab.animateTo(1);
                            Future.delayed(const Duration(milliseconds: 400), () {
                              if (mounted) setState(() {
                                _messages.add({
                                  'from': 'me',
                                  'text': '가격 ${_fmt(adjustedPrice)}으로 협상 요청드립니다. 검토 부탁드려요!',
                                  'time': '지금'
                                });
                              });
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: _accent.withOpacity(0.5)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text('협상 요청', style: TextStyle(color: _accent, fontWeight: FontWeight.w700)),
                        )),
                        const SizedBox(width: 10),
                        Expanded(child: ElevatedButton(
                          onPressed: _agreed ? () async {
                            final adjustedPrice2 = (_offeredPrice + (_sliderVal * 2000000)).toInt();
                            // 전화번호 팝업 → 점포 알림 → 다른 점포 거래종료
                            await _showSellMatchPopup(adjustedPrice2);
                          } : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _agreed ? _green : _br,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text('동의 완료',
                            style: TextStyle(
                              color: _agreed ? Colors.white : _tSec,
                              fontWeight: FontWeight.w700)),
                        )),
                      ]),
                    ],
                  ),
                ),

                // ── 탭 2: 1:1 채팅 ──
                Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (_, i) {
                          final m = _messages[i];
                          final isMe = m['from'] == 'me';
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              mainAxisAlignment: isMe
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (!isMe) ...[
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: _accent.withOpacity(0.2),
                                    child: const Text('🏪', style: TextStyle(fontSize: 14)),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: isMe
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                    children: [
                                      if (!isMe)
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 4),
                                          child: Text(widget.shopName,
                                            style: const TextStyle(fontSize: 11, color: _tSec)),
                                        ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: isMe ? _accent : _card,
                                          borderRadius: BorderRadius.circular(14).copyWith(
                                            bottomRight: isMe ? const Radius.circular(4) : null,
                                            bottomLeft: isMe ? null : const Radius.circular(4),
                                          ),
                                          border: isMe ? null : Border.all(color: _br),
                                        ),
                                        child: Text(m['text'] as String,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: isMe ? _bg : _tPri,
                                            height: 1.4)),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(m['time'] as String,
                                        style: const TextStyle(fontSize: 10, color: _tSec)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    // 입력창
                    Container(
                      padding: EdgeInsets.fromLTRB(12, 8, 12, MediaQuery.of(context).padding.bottom + 8),
                      decoration: BoxDecoration(
                        color: _card,
                        border: Border(top: BorderSide(color: _br)),
                      ),
                      child: Row(children: [
                        Expanded(
                          child: TextField(
                            controller: _chatCtrl,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: '메시지를 입력하세요...',
                              hintStyle: TextStyle(color: _tSec.withOpacity(0.5), fontSize: 13),
                              filled: true, fillColor: _bg,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: const BorderSide(color: _br)),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: const BorderSide(color: _br)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: const BorderSide(color: _accent)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            ),
                            onSubmitted: (_) => _sendMsg(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _sendMsg,
                          child: Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              color: _accent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.send_rounded, color: Color(0xFF020810), size: 20),
                          ),
                        ),
                      ]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 신청서 내역 페이지 ====================
class CarApplicationHistoryScreen extends StatefulWidget {
  const CarApplicationHistoryScreen({super.key});
  @override
  State<CarApplicationHistoryScreen> createState() => _CarApplicationHistoryScreenState();
}

class _CarApplicationHistoryScreenState extends State<CarApplicationHistoryScreen> {
  static const _kApps   = 'cp_applications';
  static const _mBg     = Color(0xFF020810);
  static const _mCard   = Color(0xFF0D1B2A);
  static const _mAccent = Color(0xFF4FC3F7);
  static const _mGreen  = Color(0xFF10B981);
  static const _mBorder = Color(0xFF1E3A5F);
  static const _mTextSec= Color(0xFF8BA3BC);

  List<Map<String, dynamic>> _applications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kApps) ?? [];
    setState(() {
      _applications = raw.map((e) {
        final parts = e.split('||');
        if (parts.length < 7) return <String, dynamic>{};
        return {
          'storeName':     parts[0],
          'storeRating':   parts[1],
          'storeDistance': parts[2],
          'storeColor':    int.tryParse(parts[3]) ?? 0xFF4FC3F7,
          'sentAt':        parts[4],
          'cancelled':     parts[5] == 'true',
          'carInfo':       parts[6],
        };
      }).where((e) => e.isNotEmpty).toList();
      _loading = false;
    });
  }

  Future<void> _cancelApplication(int idx) async {
    setState(() => _applications[idx]['cancelled'] = true);
    final prefs = await SharedPreferences.getInstance();
    final encoded = _applications.map((a) =>
      '${a['storeName']}||${a['storeRating']}||${a['storeDistance']}||'
      '${a['storeColor']}||${a['sentAt']}||${a['cancelled']}||${a['carInfo']}'
    ).toList();
    await prefs.setStringList(_kApps, encoded);
  }

  @override
  Widget build(BuildContext context) {
    final active   = _applications.where((a) => !(a['cancelled'] as bool)).toList();
    final canceled = _applications.where((a) =>  (a['cancelled'] as bool)).toList();

    return Scaffold(
      backgroundColor: _mBg,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: const BoxDecoration(
                color: _mCard,
                border: Border(bottom: BorderSide(color: _mBorder)),
              ),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios_new, color: _mAccent, size: 20)),
                const SizedBox(width: 12),
                const Text('신청서 내역',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _mAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _mAccent.withOpacity(0.4)),
                  ),
                  child: Text('활성 ${active.length}건',
                    style: const TextStyle(fontSize: 12, color: _mAccent, fontWeight: FontWeight.w600)),
                ),
              ]),
            ),

            // 본문
            Expanded(
              child: _loading
                ? const Center(child: CircularProgressIndicator(color: _mAccent))
                : _applications.isEmpty
                  ? Center(child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('📭', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        const Text('신청 내역이 없습니다',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                        const SizedBox(height: 8),
                        Text('내차 시세 조회 후 인증 매장에\n신청서를 보내보세요!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: _mTextSec, height: 1.5)),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/car-price');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _mAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text('내차 시세 조회하기',
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ))
                  : ListView(
                      padding: EdgeInsets.fromLTRB(16, 16, 16,
                          MediaQuery.of(context).padding.bottom + 16),
                      children: [
                        // 활성 신청서
                        if (active.isNotEmpty) ...[
                          _sectionHeader('🟢 진행 중인 신청서', active.length),
                          ...active.map((app) => _applicationCard(app, false)),
                          const SizedBox(height: 16),
                        ],
                        // 취소된 신청서
                        if (canceled.isNotEmpty) ...[
                          _sectionHeader('⭕ 취소된 신청서', canceled.length),
                          ...canceled.map((app) => _applicationCard(app, true)),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Text(title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: _mBorder,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text('$count', style: const TextStyle(fontSize: 11, color: _mTextSec)),
        ),
      ]),
    );
  }

  Widget _applicationCard(Map<String, dynamic> app, bool isCancelled) {
    final color = Color(app['storeColor'] as int);
    final idx   = _applications.indexOf(app);
    final readStatus    = app['readStatus']    as String? ?? 'unread';
    final estimatePrice = app['estimatePrice'] as int?    ?? 0;
    final estimateNote  = app['estimateNote']  as String? ?? '';

    // 읽음 상태별 설정
    Color  statusColor;
    String statusLabel;
    IconData statusIcon;
    switch (readStatus) {
      case 'read':
        statusColor = const Color(0xFF4FC3F7);
        statusLabel = '매장확인';
        statusIcon  = Icons.visibility_rounded;
        break;
      case 'replied':
        statusColor = _mGreen;
        statusLabel = '견적도착';
        statusIcon  = Icons.price_check_rounded;
        break;
      default:
        statusColor = const Color(0xFFFFB300);
        statusLabel = '전달완료';
        statusIcon  = Icons.schedule_send_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _mCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCancelled
              ? _mBorder
              : (readStatus == 'replied' ? _mGreen.withOpacity(0.5) : color.withOpacity(0.4)),
          width: readStatus == 'replied' ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 읽음/안읽음 상태 배너
          if (!isCancelled)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
                border: Border(bottom: BorderSide(color: statusColor.withOpacity(0.2))),
              ),
              child: Row(children: [
                Icon(statusIcon, color: statusColor, size: 13),
                const SizedBox(width: 5),
                Text(statusLabel,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor)),
                if (readStatus == 'unread') ...[
                  const SizedBox(width: 6),
                  Container(
                    width: 7, height: 7,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB300),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: const Color(0xFFFFB300).withOpacity(0.5), blurRadius: 4)],
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text('미읽음', style: TextStyle(fontSize: 10, color: Color(0xFFFFB300))),
                ],
              ]),
            ),

          // 카드 내용
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 매장명 + 상태
                Row(children: [
                  Container(
                    width: 10, height: 10,
                    decoration: BoxDecoration(
                      color: isCancelled ? _mBorder : color,
                      shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(app['storeName'] as String,
                    style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700,
                      color: isCancelled ? _mTextSec : Colors.white))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCancelled ? Colors.red.withOpacity(0.1) : _mGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(isCancelled ? '취소됨' : '진행중',
                      style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700,
                        color: isCancelled ? Colors.red : _mGreen)),
                  ),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Icon(Icons.directions_car, color: _mTextSec, size: 13),
                  const SizedBox(width: 4),
                  Text(app['carInfo'] as String,
                    style: TextStyle(fontSize: 12, color: _mTextSec)),
                ]),
                const SizedBox(height: 3),
                Row(children: [
                  Icon(Icons.place_outlined, color: _mTextSec, size: 13),
                  const SizedBox(width: 4),
                  Text('${app['storeDistance']}  ·  ${app['storeRating']}',
                    style: TextStyle(fontSize: 12, color: _mTextSec)),
                ]),
                const SizedBox(height: 3),
                Row(children: [
                  Icon(Icons.schedule, color: _mTextSec, size: 13),
                  const SizedBox(width: 4),
                  Text('신청일시: ${app['sentAt']}',
                    style: TextStyle(fontSize: 12, color: _mTextSec)),
                ]),

                // 견적 도착 카드
                if (!isCancelled && readStatus == 'replied' && estimatePrice > 0) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _mGreen.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _mGreen.withOpacity(0.3)),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        const Text('💰', style: TextStyle(fontSize: 13)),
                        const SizedBox(width: 6),
                        const Text('매장 예상 견적가',
                          style: TextStyle(fontSize: 11, color: _mTextSec)),
                        const Spacer(),
                        Text('${(estimatePrice / 10000).toStringAsFixed(0)}만원',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _mGreen)),
                      ]),
                      if (estimateNote.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(estimateNote,
                          style: const TextStyle(fontSize: 11, color: _mTextSec, height: 1.4)),
                      ],
                    ]),
                  ),
                ],

                // 버튼 (취소되지 않은 경우만)
                if (!isCancelled) ...[
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => CarConsultScreen(
                            shopName: app['storeName'] as String,
                            carInfo: app['carInfo'] as String,
                            estimatedPrice: estimatePrice,
                          ),
                        )),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: color.withOpacity(0.4)),
                          ),
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(Icons.chat_bubble_outline, color: color, size: 15),
                            const SizedBox(width: 5),
                            Text('상담하기', style: TextStyle(
                              fontSize: 13, color: color, fontWeight: FontWeight.w600)),
                          ]),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: _mCard,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            title: const Text('신청서 취소',
                              style: TextStyle(color: Colors.white, fontSize: 15)),
                            content: Text('${app['storeName']}에 보낸 신청서를\n취소하시겠습니까?',
                              style: TextStyle(color: _mTextSec, fontSize: 13)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: Text('아니오', style: TextStyle(color: _mTextSec))),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('취소하기',
                                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700))),
                            ],
                          ),
                        );
                        if (confirm == true) await _cancelApplication(idx);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: const Text('취소',
                          style: TextStyle(fontSize: 13, color: Colors.red, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 중고차 점포 상세 (Placeholder) ====================
class UsedCarStoreDetailScreen extends StatelessWidget {
  final String storeName;
  final String storeDistance;
  final String storeRating;
  final Color  storeColor;

  const UsedCarStoreDetailScreen({
    super.key,
    required this.storeName,
    required this.storeDistance,
    required this.storeRating,
    required this.storeColor,
  });

  static const _mBg     = Color(0xFF020810);
  static const _mCard   = Color(0xFF0D1B2A);
  static const _mAccent = Color(0xFF4FC3F7);
  static const _mBorder = Color(0xFF1E3A5F);
  static const _mTextSec= Color(0xFF8BA3BC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _mBg,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              color: _mCard,
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios_new, color: _mAccent, size: 20)),
                const SizedBox(width: 12),
                Expanded(child: Text(storeName,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: storeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: storeColor.withOpacity(0.4)),
                  ),
                  child: const Text('KAA 인증', style: TextStyle(fontSize: 11, color: Colors.white)),
                ),
              ]),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16, 20, 16,
                    MediaQuery.of(context).padding.bottom + 20),
                child: Column(
                  children: [
                    // 대표 이미지 자리
                    Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: _mCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _mBorder),
                      ),
                      child: Center(child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.store, color: storeColor, size: 48),
                          const SizedBox(height: 8),
                          Text(storeName,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                          const SizedBox(height: 4),
                          Text('KAA 공인 인증 중고차 매장',
                            style: TextStyle(fontSize: 12, color: _mTextSec)),
                        ],
                      )),
                    ),
                    const SizedBox(height: 16),

                    // 기본 정보
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _mCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _mBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('📍 기본 정보',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                          const SizedBox(height: 12),
                          _infoRow(Icons.place_outlined, '거리', storeDistance),
                          _infoRow(Icons.star_outline, '평점', storeRating),
                          _infoRow(Icons.verified_outlined, '인증', 'KAA 공인 인증점'),
                          _infoRow(Icons.access_time, '영업', '평일 09:00 ~ 18:00'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 준비중 안내
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: storeColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: storeColor.withOpacity(0.3)),
                      ),
                      child: Column(children: [
                        Icon(Icons.construction_rounded, color: storeColor, size: 36),
                        const SizedBox(height: 12),
                        const Text('상세 페이지 준비중',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                        const SizedBox(height: 8),
                        Text('차량 목록, 가격, 상세 사진 등\n더 많은 정보를 곧 제공할 예정입니다.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: _mTextSec, height: 1.5)),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Icon(icon, color: _mTextSec, size: 16),
        const SizedBox(width: 8),
        Text('$label  ', style: TextStyle(fontSize: 12, color: _mTextSec)),
        Text(value, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}


// ==================== 1:1 채팅 ====================
class ChatScreen extends StatefulWidget {
  final String storeName;
  final int storeId;
  const ChatScreen({super.key, required this.storeName, required this.storeId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl   = TextEditingController();
  final _scroll = ScrollController();
  final List<Map<String, dynamic>> _messages = [
    {'text': '안녕하세요! 무엇을 도와드릴까요?', 'isMe': false, 'time': '방금'},
  ];

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({'text': text, 'isMe': true, 'time': '방금'});
      _ctrl.clear();
    });
    // 자동 응답
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _messages.add({
          'text': '문의 내용을 확인했습니다. 잠시 후 담당자가 답변해 드리겠습니다. 감사합니다!',
          'isMe': false,
          'time': '방금',
        });
      });
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: _mBg, statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: _mBg,
        body: Column(
          children: [
            // 헤더
            Container(
              color: _mCard,
              padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 10, 16, 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: _mAccent.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: _mAccent.withOpacity(0.4)),
                    ),
                    child: const Icon(Icons.store, color: _mAccent, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.storeName,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                        Row(
                          children: [
                            Container(width: 7, height: 7,
                              decoration: const BoxDecoration(color: _mGreen, shape: BoxShape.circle)),
                            const SizedBox(width: 4),
                            Text('온라인', style: TextStyle(fontSize: 11, color: _mTextSec)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.more_vert, color: _mTextSec),
                ],
              ),
            ),

            // 메시지 목록
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (_, i) {
                  final m = _messages[i];
                  final isMe = m['isMe'] as bool;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (!isMe) ...[
                          Container(
                            width: 32, height: 32,
                            margin: const EdgeInsets.only(right: 8, bottom: 4),
                            decoration: BoxDecoration(
                              color: _mAccent.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.store, color: _mAccent, size: 16),
                          ),
                        ],
                        Flexible(
                          child: Column(
                            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isMe ? _mAccent : _mCard,
                                  borderRadius: BorderRadius.only(
                                    topLeft:     const Radius.circular(16),
                                    topRight:    const Radius.circular(16),
                                    bottomLeft:  Radius.circular(isMe ? 16 : 4),
                                    bottomRight: Radius.circular(isMe ? 4 : 16),
                                  ),
                                  border: Border.all(
                                    color: isMe ? _mAccent : _mBorder,
                                  ),
                                ),
                                child: Text(m['text'] as String,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isMe ? Colors.white : Colors.white,
                                    height: 1.5,
                                  )),
                              ),
                              const SizedBox(height: 4),
                              Text(m['time'] as String,
                                style: TextStyle(fontSize: 10, color: _mTextSec)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // 입력창
            Container(
              padding: EdgeInsets.fromLTRB(12, 10, 12, MediaQuery.of(context).padding.bottom + 10),
              decoration: BoxDecoration(
                color: _mCard,
                border: Border(top: BorderSide(color: _mBorder)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: _mBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: _mBorder),
                      ),
                      child: TextField(
                        controller: _ctrl,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: '메시지를 입력하세요...',
                          hintStyle: TextStyle(color: _mTextSec, fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _send,
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: _mAccent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== 이동리워드 ====================
class RewardScreen extends StatefulWidget {
  const RewardScreen({super.key});
  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> with TickerProviderStateMixin {
  // ── 모인카 컬러 ──
  static const _bg     = Color(0xFF020810);
  static const _card   = Color(0xFF0D1B2A);
  static const _accent = Color(0xFF4FC3F7);
  static const _orange = Color(0xFFFF6B35);
  static const _purple = Color(0xFF9B7CFF);
  static const _green  = Color(0xFF10B981);
  static const _gold   = Color(0xFFFBBF24);
  static const _border = Color(0xFF1E3A5F);
  static const _textPri = Colors.white;
  static const _textSec = Color(0xFFB0BEC5);

  // ── 탭 ──
  late TabController _tabCtrl;
  int _modeIdx = 0; // 0=걷기, 1=이동수단

  // ── 적립 상태 ──
  int _todaySteps    = 0;
  int _todayDistance = 0; // 미터 단위
  int _todayPoints   = 0;
  int _totalPoints   = 132;

  // 걷기: 100보 = 1P, 최대 10000보(100P/일)
  // 이동: 500m = 1P, 최대 50000m(100P + 50P = 최대 50P/일)
  int get _walkPoints  => (_todaySteps / 100).floor().clamp(0, 100);
  int get _movePoints  => (_todayDistance / 500).floor().clamp(0, 50);

  // ── 광고 상태 ──
  // 6P마다 광고 1회, 하루 25회 최대
  // 패턴: 5초, 5초, 5초, 15초 반복 → 25번째는 30초
  int _adCount    = 0;  // 오늘 본 광고 수
  int _adTrigPts  = 0;  // 광고 트리거 기준 포인트
  bool _adPlaying = false;
  int _adRemain   = 0;
  late AnimationController _adCtrl;

  // ── 보물상자 ──
  int _chestPts     = 0; // 상자에 쌓인 포인트 (터치로 적립)
  int _maxChestDay  = 50;
  bool _chestOpen   = false;
  final List<_FloatPoint> _floats = [];
  late AnimationController _chestCtrl;

  // ── 히스토리 탭 ──
  int _histIdx = 0;
  final _histTabs = ['일', '주', '월', '연'];

  // 광고 패턴: 인덱스 기준 (0-indexed), 4번마다 15초, 24번은 30초
  int _adDuration(int adIdx) {
    if (adIdx == 24) return 30; // 마지막 25번째
    if ((adIdx + 1) % 4 == 0) return 15;
    return 5;
  }

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _adCtrl   = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _chestCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _adCtrl.dispose();
    _chestCtrl.dispose();
    super.dispose();
  }

  void _addPoints(int pts) {
    setState(() {
      _todayPoints += pts;
      _totalPoints += pts;
    });
    // 광고 트리거: 6P 적립마다
    while (_todayPoints - _adTrigPts >= 6 && _adCount < 25 && !_adPlaying) {
      _adTrigPts += 6;
      _playAd();
      break;
    }
  }

  void _playAd() {
    if (_adCount >= 25) return;
    final dur = _adDuration(_adCount);
    setState(() {
      _adPlaying = true;
      _adRemain  = dur;
      _adCount++;
    });
    // 1초마다 카운트다운
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _adRemain--);
      if (_adRemain <= 0) {
        setState(() => _adPlaying = false);
        return false;
      }
      return true;
    });
  }

  void _tapChest() {
    if (_chestPts >= _maxChestDay) return;
    setState(() {
      _chestPts++;
      _totalPoints++;
      _todayPoints++;
      _chestOpen = true;
      _floats.add(_FloatPoint());
    });
    _chestCtrl.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() {
        _chestOpen = false;
        _floats.removeWhere((f) => f.isDone);
      });
    });
    // 광고 트리거 체크
    while (_todayPoints - _adTrigPts >= 6 && _adCount < 25 && !_adPlaying) {
      _adTrigPts += 6;
      _playAd();
      break;
    }
  }

  // 시뮬레이션: 걷기 +100보
  void _simWalk() {
    if (_todaySteps >= 10000) return;
    final before = _walkPoints;
    setState(() => _todaySteps = (_todaySteps + 100).clamp(0, 10000));
    final after = _walkPoints;
    if (after > before) _addPoints(after - before);
  }

  // 시뮬레이션: 이동 +500m
  void _simMove() {
    if (_todayDistance >= 50000) return;
    final before = _movePoints;
    setState(() => _todayDistance = (_todayDistance + 500).clamp(0, 50000));
    final after = _movePoints;
    if (after > before) _addPoints(after - before);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(children: [
        Column(children: [
          SafeArea(
            bottom: false,
            child: AppHeader(showBack: true, title: '이동리워드', notifCount: AppState().notificationCount),
          ),

          // 탭바
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            decoration: BoxDecoration(
              color: _card, borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _border),
            ),
            child: TabBar(
              controller: _tabCtrl,
              indicator: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF9B7CFF), Color(0xFF4FC3F7)]),
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorPadding: const EdgeInsets.all(3),
              labelColor: Colors.black,
              unselectedLabelColor: _textSec,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
              dividerColor: Colors.transparent,
              tabs: const [Tab(text: '🚶 걷기·이동 적립'), Tab(text: '📊 통계·교환')],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [_buildMainTab(), _buildStatsTab()],
            ),
          ),
        ]),

        // 광고 오버레이
        if (_adPlaying) _buildAdOverlay(),

        // 플로팅 포인트 애니메이션
        ..._floats.map((f) => _buildFloat(f)),
      ]),
    );
  }

  // ── 메인 탭 ──
  Widget _buildMainTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      children: [
        // 총 포인트 카드
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFF1A1040), Color(0xFF0A1628)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _purple.withOpacity(0.4)),
          ),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('🎁 누적 포인트',
                style: TextStyle(fontSize: 13, color: _textSec, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _gold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _gold.withOpacity(0.4)),
                ),
                child: Text('오늘 ${_todayPoints}P',
                  style: const TextStyle(fontSize: 11, color: _gold, fontWeight: FontWeight.w700)),
              ),
            ]),
            const SizedBox(height: 8),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('$_totalPoints',
                style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: _textPri,
                  shadows: [Shadow(color: Color(0xFF9B7CFF), blurRadius: 10)])),
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text('P', style: TextStyle(fontSize: 20, color: _purple, fontWeight: FontWeight.w800)),
              ),
              const Spacer(),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('광고 $_adCount/25회', style: const TextStyle(fontSize: 10, color: _textSec)),
                const SizedBox(height: 2),
                Text('오늘 한도 150P', style: const TextStyle(fontSize: 10, color: _textSec)),
              ]),
            ]),
            const SizedBox(height: 12),
            // 전체 진행 바
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (_todayPoints / 150).clamp(0.0, 1.0),
                backgroundColor: _border,
                valueColor: const AlwaysStoppedAnimation(_purple),
                minHeight: 6,
              ),
            ),
          ]),
        ),
        const SizedBox(height: 14),

        // 모드 선택 (걷기 / 이동수단)
        Row(children: [
          _modeBtn(0, '🚶 걷기 모드'),
          const SizedBox(width: 8),
          _modeBtn(1, '🚗 이동 모드'),
        ]),
        const SizedBox(height: 14),

        // 걷기 적립 카드
        if (_modeIdx == 0) _buildWalkCard(),
        if (_modeIdx == 1) _buildMoveCard(),

        const SizedBox(height: 14),

        // 보물상자
        _buildChestCard(),

        const SizedBox(height: 14),

        // 광고 안내
        _buildAdGuide(),

        const SizedBox(height: 14),

        // 선물 교환
        _buildGiftSection(),
      ],
    );
  }

  Widget _modeBtn(int idx, String label) {
    final sel = _modeIdx == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _modeIdx = idx),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: sel ? _purple.withOpacity(0.2) : _card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: sel ? _purple : _border, width: sel ? 1.5 : 1),
          ),
          child: Center(child: Text(label,
            style: TextStyle(
              fontSize: 13, fontWeight: sel ? FontWeight.w800 : FontWeight.w500,
              color: sel ? _purple : _textSec,
            ))),
        ),
      ),
    );
  }

  Widget _buildWalkCard() {
    final pts = _walkPoints;
    final progress = (_todaySteps / 10000).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('👟', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('걷기 포인트', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _textPri)),
              Text('100보 = 1P · 최대 10,000보(100P/일)', style: TextStyle(fontSize: 10, color: _textSec)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('$pts P', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _green)),
            Text('$_todaySteps 보', style: const TextStyle(fontSize: 11, color: _textSec)),
          ]),
        ]),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('$_todaySteps보', style: const TextStyle(fontSize: 11, color: _textSec)),
          Text('10,000보', style: const TextStyle(fontSize: 11, color: _textSec)),
        ]),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress, backgroundColor: _border,
            valueColor: const AlwaysStoppedAnimation(_green),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 12),
        // 시뮬레이션 버튼
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _todaySteps >= 10000 ? null : _simWalk,
            icon: const Text('👟', style: TextStyle(fontSize: 14)),
            label: Text(_todaySteps >= 10000 ? '오늘 걷기 한도 완료!' : '+100보 (테스트)',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _todaySteps >= 10000 ? _border : _green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildMoveCard() {
    final pts = _movePoints;
    final distKm = (_todayDistance / 1000).toStringAsFixed(1);
    final progress = (_todayDistance / 50000).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('🚗', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('이동 포인트', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _textPri)),
              Text('속도 >10km/h · 500m = 1P · 최대 50km(50P/일)', style: TextStyle(fontSize: 10, color: _textSec)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('$pts P', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _orange)),
            Text('$distKm km', style: const TextStyle(fontSize: 11, color: _textSec)),
          ]),
        ]),
        const SizedBox(height: 12),
        // 속도 표시
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _orange.withOpacity(0.3)),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('현재 속도', style: TextStyle(fontSize: 12, color: _textSec)),
            Text('${_todayDistance > 0 ? "35.2" : "0.0"} km/h',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800,
                color: _todayDistance > 0 ? _orange : _textSec)),
          ]),
        ),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('$distKm km', style: const TextStyle(fontSize: 11, color: _textSec)),
          const Text('50.0 km', style: TextStyle(fontSize: 11, color: _textSec)),
        ]),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress, backgroundColor: _border,
            valueColor: const AlwaysStoppedAnimation(_orange),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _todayDistance >= 50000 ? null : _simMove,
            icon: const Text('🚗', style: TextStyle(fontSize: 14)),
            label: Text(_todayDistance >= 50000 ? '오늘 이동 한도 완료!' : '+500m (테스트)',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _todayDistance >= 50000 ? _border : _orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildChestCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF1A1040), Color(0xFF0D1620)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _gold.withOpacity(0.4)),
      ),
      child: Column(children: [
        Row(children: [
          const Text('💎', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          const Text('보물상자 터치 적립',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _textPri)),
          const Spacer(),
          Text('$_chestPts / $_maxChestDay P',
            style: const TextStyle(fontSize: 12, color: _gold, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 4),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('터치 1회 = 1P · 최대 50P/일 · 빠른 터치 가능',
            style: TextStyle(fontSize: 10, color: _textSec)),
        ),
        const SizedBox(height: 14),
        // 보물상자 버튼
        GestureDetector(
          onTap: _chestPts < _maxChestDay ? _tapChest : null,
          child: AnimatedBuilder(
            animation: _chestCtrl,
            builder: (_, __) {
              final scale = 1.0 + (0.15 * (1 - _chestCtrl.value).abs() *
                (_chestCtrl.isAnimating ? 1 : 0));
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: _chestPts >= _maxChestDay
                        ? [_border, _card]
                        : [_gold.withOpacity(0.3), _gold.withOpacity(0.05)],
                    ),
                    border: Border.all(
                      color: _chestPts >= _maxChestDay ? _border : _gold.withOpacity(0.6),
                      width: 2,
                    ),
                    boxShadow: _chestPts < _maxChestDay ? [
                      BoxShadow(color: _gold.withOpacity(0.3), blurRadius: 20, spreadRadius: 3),
                    ] : [],
                  ),
                  child: Center(child: Text(
                    _chestPts >= _maxChestDay ? '🔒' : (_chestOpen ? '💰' : '🎁'),
                    style: const TextStyle(fontSize: 44),
                  )),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _chestPts >= _maxChestDay ? '오늘 한도를 채웠습니다! 내일 다시 도전하세요.' : '상자를 터치하여 포인트를 획득하세요!',
          style: TextStyle(fontSize: 11, color: _chestPts >= _maxChestDay ? _textSec : _gold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (_chestPts / _maxChestDay).clamp(0.0, 1.0),
            backgroundColor: _border,
            valueColor: const AlwaysStoppedAnimation(_gold),
            minHeight: 6,
          ),
        ),
      ]),
    );
  }

  Widget _buildAdGuide() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('📺', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          const Text('광고 시청 스케줄',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _textPri)),
          const Spacer(),
          Text('$_adCount / 25회',
            style: const TextStyle(fontSize: 12, color: _accent, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 8),
        const Text('6P 적립마다 광고 1회 재생됩니다.',
          style: TextStyle(fontSize: 11, color: _textSec)),
        const SizedBox(height: 8),
        // 광고 패턴 시각화
        Row(children: List.generate(25, (i) {
          final done = i < _adCount;
          final dur = _adDuration(i);
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              height: 24,
              decoration: BoxDecoration(
                color: done
                  ? (dur == 30 ? _purple : dur == 15 ? _orange : _accent).withOpacity(0.8)
                  : _border,
                borderRadius: BorderRadius.circular(3),
              ),
              child: done
                ? null
                : Center(child: Text(
                    dur == 30 ? '30' : dur == 15 ? '15' : '5',
                    style: const TextStyle(fontSize: 7, color: _textSec))),
            ),
          );
        })),
        const SizedBox(height: 6),
        Row(children: [
          _adLegend(_accent, '5초'),
          const SizedBox(width: 10),
          _adLegend(_orange, '15초'),
          const SizedBox(width: 10),
          _adLegend(_purple, '30초'),
        ]),
      ]),
    );
  }

  Widget _adLegend(Color c, String label) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 10, height: 10, color: c.withOpacity(0.8),
        margin: const EdgeInsets.only(right: 3)),
      Text(label, style: const TextStyle(fontSize: 9, color: _textSec)),
    ]);
  }

  Widget _buildGiftSection() {
    final gifts = [
      {'name': 'CU 편의점', 'emoji': '🏪', 'price': 50, 'color': Color(0xFF1565C0)},
      {'name': 'GS25', 'emoji': '🏬', 'price': 50, 'color': Color(0xFF2E7D32)},
      {'name': '스타벅스', 'emoji': '☕', 'price': 100, 'color': Color(0xFF00695C)},
      {'name': 'SK주유소', 'emoji': '⛽', 'price': 200, 'color': Color(0xFFE65100)},
    ];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Text('🎁', style: TextStyle(fontSize: 14)),
          SizedBox(width: 6),
          Text('포인트 선물 교환',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _textPri)),
        ]),
        const SizedBox(height: 4),
        const Text('보유 포인트를 다양한 혜택으로 교환하세요.',
          style: TextStyle(fontSize: 11, color: _textSec)),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10,
          childAspectRatio: 2.5,
          children: gifts.map((g) {
            final canUse = _totalPoints >= (g['price'] as int);
            return GestureDetector(
              onTap: canUse ? () => _useGift(g) : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: canUse
                    ? (g['color'] as Color).withOpacity(0.1)
                    : _bg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: canUse
                      ? (g['color'] as Color).withOpacity(0.4)
                      : _border,
                  ),
                ),
                child: Row(children: [
                  Text(g['emoji'] as String, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 6),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(g['name'] as String,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                        color: canUse ? _textPri : _textSec)),
                    Text('${g['price']}P',
                      style: TextStyle(fontSize: 10,
                        color: canUse ? (g['color'] as Color) : _textSec)),
                  ])),
                ]),
              ),
            );
          }).toList(),
        ),
      ]),
    );
  }

  void _useGift(Map<String, dynamic> g) {
    final price = g['price'] as int;
    if (_totalPoints < price) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('${g['emoji']} ${g['name']} 교환',
          style: const TextStyle(color: _textPri, fontWeight: FontWeight.w800, fontSize: 16)),
        content: Text('${price}P를 사용하여 교환하시겠습니까?\n잔여: ${_totalPoints - price}P',
          style: const TextStyle(color: _textSec, fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: _textSec))),
          ElevatedButton(
            onPressed: () {
              setState(() => _totalPoints -= price);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: _green,
                  content: Text('🎁 ${g['name']} 교환 완료!',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ));
            },
            style: ElevatedButton.styleFrom(backgroundColor: _green),
            child: const Text('교환하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ── 통계 탭 ──
  Widget _buildStatsTab() {
    final weekData = [45, 72, 88, 61, 95, 110, _todayPoints.clamp(0, 150)];
    final days = ['월', '화', '수', '목', '금', '토', '일'];
    final maxVal = weekData.reduce((a, b) => a > b ? a : b).toDouble();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      children: [
        // 기간 탭
        Container(
          decoration: BoxDecoration(
            color: _card, borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _border),
          ),
          child: Row(
            children: List.generate(_histTabs.length, (i) {
              final sel = _histIdx == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _histIdx = i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: sel ? _accent : Colors.transparent,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(_histTabs[i],
                      style: TextStyle(
                        fontSize: 12, fontWeight: sel ? FontWeight.w800 : FontWeight.w500,
                        color: sel ? Colors.black : _textSec,
                      ),
                      textAlign: TextAlign.center),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 14),

        // 바 차트
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _card, borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('📈 주간 포인트 현황',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _textPri)),
            const SizedBox(height: 14),
            SizedBox(
              height: 140,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (i) {
                  final val = weekData[i].toDouble();
                  final h = maxVal > 0 ? (val / maxVal) * 120 : 0.0;
                  final isToday = i == 6;
                  return Expanded(
                    child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                      Text('${weekData[i]}', style: TextStyle(fontSize: 9,
                        color: isToday ? _gold : _textSec, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 3),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        width: double.infinity,
                        height: h,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter, end: Alignment.topCenter,
                            colors: isToday
                              ? [_gold, _gold.withOpacity(0.6)]
                              : [_accent, _accent.withOpacity(0.4)],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(days[i], style: TextStyle(fontSize: 10,
                        color: isToday ? _gold : _textSec,
                        fontWeight: isToday ? FontWeight.w800 : FontWeight.w400)),
                    ]),
                  );
                }),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 12),

        // 건강 지표
        Row(children: [
          _statCard('🦵', '연속 활동', '3일', _orange),
          const SizedBox(width: 10),
          _statCard('⚡', '평균 속도', '4.2km/h', _green),
          const SizedBox(width: 10),
          _statCard('🏆', '건강 점수', '82점', _purple),
        ]),
        const SizedBox(height: 12),

        // 적립 히스토리
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _card, borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('📋 최근 적립 내역',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _textPri)),
            const SizedBox(height: 10),
            ...[
              {'icon': '🚶', 'text': '걷기 적립', 'sub': '3,200보', 'pts': '+32P', 'time': '오늘 14:22'},
              {'icon': '🚗', 'text': '이동 적립', 'sub': '12.5km', 'pts': '+25P', 'time': '오늘 11:05'},
              {'icon': '🎁', 'text': '보물상자', 'sub': '터치 적립', 'pts': '+15P', 'time': '오늘 09:30'},
              {'icon': '📺', 'text': '광고 시청', 'sub': '15초 광고', 'pts': '+0P', 'time': '어제 20:11'},
            ].map((h) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(children: [
                Container(width: 36, height: 36,
                  decoration: BoxDecoration(color: _bg, shape: BoxShape.circle,
                    border: Border.all(color: _border)),
                  child: Center(child: Text(h['icon']!, style: const TextStyle(fontSize: 16)))),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(h['text']!, style: const TextStyle(fontSize: 13, color: _textPri, fontWeight: FontWeight.w600)),
                  Text('${h['sub']} · ${h['time']}', style: const TextStyle(fontSize: 10, color: _textSec)),
                ])),
                Text(h['pts']!,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
                    color: h['pts']!.startsWith('+') ? _green : _textSec)),
              ]),
            )).toList(),
          ]),
        ),
      ],
    );
  }

  Widget _statCard(String emoji, String label, String value, Color c) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _card, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
        ),
        child: Column(children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: c)),
          Text(label, style: const TextStyle(fontSize: 9, color: _textSec)),
        ]),
      ),
    );
  }

  // ── 광고 오버레이 ──
  Widget _buildAdOverlay() {
    final adIdx = _adCount - 1;
    final dur = _adDuration(adIdx);
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.9),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _border),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // 광고 배지
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _orange.withOpacity(0.4)),
                ),
                child: Text('📺 광고 ${_adCount}/${25} · ${dur}초 광고',
                  style: const TextStyle(fontSize: 11, color: _orange, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 20),
              // 광고 영역
              Container(
                height: 180,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_border, _card],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('🚗', style: TextStyle(fontSize: 48)),
                  SizedBox(height: 8),
                  Text('MOINCAR 광고', style: TextStyle(color: _textPri, fontSize: 16, fontWeight: FontWeight.w800)),
                  SizedBox(height: 4),
                  Text('인증 점포에서 최고의 서비스를!', style: TextStyle(color: _textSec, fontSize: 12)),
                ])),
              ),
              const SizedBox(height: 20),
              // 카운트다운
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _accent, width: 3),
                  ),
                  child: Center(child: Text('$_adRemain',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _accent))),
                ),
                const SizedBox(width: 10),
                const Text('초 후 닫힘',
                  style: TextStyle(fontSize: 13, color: _textSec)),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildFloat(_FloatPoint f) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOut,
      left: MediaQuery.of(context).size.width / 2 - 20,
      top: MediaQuery.of(context).size.height * 0.55 - (f.isDone ? 80 : 20),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 700),
        opacity: f.isDone ? 0 : 1,
        child: const Text('+1P',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _gold,
            shadows: [Shadow(color: Colors.black, blurRadius: 4)])),
      ),
    );
  }
}

class _FloatPoint {
  bool isDone = false;
  _FloatPoint() {
    Future.delayed(const Duration(milliseconds: 700), () => isDone = true);
  }
}

// ══════════════════════════════════════════════════════════════
// 마이페이지 – 견적받은 내역 화면
// 알림(견적 카테고리) 탭 → 이 화면으로 바로 이동
// ══════════════════════════════════════════════════════════════
class MyQuotesScreen extends StatefulWidget {
  const MyQuotesScreen({super.key});
  @override
  State<MyQuotesScreen> createState() => _MyQuotesScreenState();
}

class _MyQuotesScreenState extends State<MyQuotesScreen> {
  static const _bg     = Color(0xFF020810);
  static const _card   = Color(0xFF0D1B2A);
  static const _navy   = Color(0xFF0A1628);
  static const _accent = Color(0xFF4FC3F7);
  static const _green  = Color(0xFF10B981);
  static const _orange = Color(0xFFFF6B35);
  static const _border = Color(0xFF1E3A5F);
  static const _t1     = Colors.white;
  static const _t2     = Color(0xFFB0BEC5);

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final requests = AppState().estimateRequests;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: _bg, statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: _bg,
        body: Column(children: [
          // ── 헤더 ──────────────────────────────────────────
          Container(
            color: _card,
            padding: EdgeInsets.fromLTRB(16, topPad + 12, 16, 14),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios_new, color: _t1, size: 20)),
              const SizedBox(width: 12),
              const Text('📋 견적받은 내역',
                style: TextStyle(color: _t1, fontSize: 17, fontWeight: FontWeight.w800)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _accent.withOpacity(0.3)),
                ),
                child: Text('총 ${requests.length}건',
                  style: const TextStyle(color: _accent, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ]),
          ),

          // ── 내역 리스트 ────────────────────────────────────
          Expanded(
            child: requests.isEmpty
              ? Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Text('📭', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 16),
                    const Text('아직 견적 내역이 없습니다',
                      style: TextStyle(color: _t2, fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    const Text('카테고리에서 견적을 요청해보세요',
                      style: TextStyle(color: _t2, fontSize: 13)),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/quote-request'),
                      icon: const Icon(Icons.receipt_long),
                      label: const Text('견적 요청하기'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ]),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 80),
                  itemCount: requests.length,
                  itemBuilder: (_, i) => _buildRequestCard(context, requests[i]),
                ),
          ),
        ]),
      ),
    );
  }

  Widget _buildRequestCard(BuildContext ctx, EstimateRequest req) {
    final hasNewBid = req.bids.any((b) => b.status == RepairStatus.bidding);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasNewBid ? _accent.withOpacity(0.4) : _border, width: 1.5),
      ),
      child: Column(children: [
        // ── 요청 요약 헤더 ────────────────────────────────
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _navy,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Row(children: [
            const Text('🚗', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(req.carName.isNotEmpty ? req.carName : '차량 미입력',
                style: const TextStyle(color: _t1, fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text('${req.region}  ·  ${req.repairType}',
                style: const TextStyle(color: _t2, fontSize: 11)),
            ])),
            if (hasNewBid)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _accent.withOpacity(0.5)),
                ),
                child: const Text('새 견적 도착!',
                  style: TextStyle(color: _accent, fontSize: 10, fontWeight: FontWeight.w800)),
              ),
            Container(
              margin: const EdgeInsets.only(left: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _border,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('${req.bidCount}건',
                style: const TextStyle(color: _t2, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ]),
        ),

        // ── 증상 태그 ─────────────────────────────────────
        if (req.symptoms.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Wrap(
              spacing: 6, runSpacing: 4,
              children: req.symptoms.take(4).map((s) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _navy,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(s, style: const TextStyle(color: _t2, fontSize: 10)),
              )).toList(),
            ),
          ),

        // ── 점포별 견적 카드 ──────────────────────────────
        if (req.bids.isNotEmpty) ...[
          const Divider(color: Color(0xFF1E3A5F), height: 20),
          ...req.bids.take(3).map((bid) => _buildBidTile(ctx, req, bid)),
          if (req.bids.length > 3)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(ctx, '/quote-list'),
                child: Text('+ ${req.bids.length - 3}개 더 보기',
                  style: const TextStyle(color: _accent, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ),
        ] else
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.hourglass_empty, color: _t2, size: 14),
              const SizedBox(width: 6),
              Text('견적 대기 중...', style: const TextStyle(color: _t2, fontSize: 12)),
            ]),
          ),
      ]),
    );
  }

  Widget _buildBidTile(BuildContext ctx, EstimateRequest req, QuoteBid bid) {
    return GestureDetector(
      onTap: () => Navigator.push(ctx, MaterialPageRoute(
        builder: (_) => QuoteDetailScreen(request: req, bid: bid),
      )),
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
        ),
        child: Row(children: [
          // 썸네일
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(bid.storeImage,
              width: 50, height: 50, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 50, height: 50, color: _navy,
                child: const Icon(Icons.store, color: _t2, size: 24))),
          ),
          const SizedBox(width: 12),
          // 점포 정보
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(bid.storeBadge,
                  style: const TextStyle(color: _accent, fontSize: 9, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 6),
              Text('${bid.storeDistance}  ·  ⭐ ${bid.storeRating}',
                style: const TextStyle(color: _t2, fontSize: 10)),
            ]),
            const SizedBox(height: 4),
            Text(bid.storeName,
              style: const TextStyle(color: _t1, fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            // 견적 금액 3분할
            Row(children: [
              _costChip('부품', bid.partsCost),
              const SizedBox(width: 4),
              _costChip('공임', bid.laborCost),
              const SizedBox(width: 4),
              _costChip('합계', bid.totalCost, highlight: true),
            ]),
          ])),
          // 화살표 + 전화/문의 버튼
          Column(children: [
            GestureDetector(
              onTap: () async {
                if (!bid.phoneRevealed) {
                  AppState().revealPhone(req.requestId, bid.bidId);
                  bid.phoneRevealed = true;
                }
                final uri = Uri.parse('tel:${bid.storePhone}');
                if (await canLaunchUrl(uri)) launchUrl(uri);
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _green.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _green.withOpacity(0.3)),
                ),
                child: const Icon(Icons.phone, color: _green, size: 16),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _accent.withOpacity(0.3)),
              ),
              child: const Icon(Icons.arrow_forward_ios, color: _accent, size: 14),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _costChip(String label, int amount, {bool highlight = false}) {
    final fmt = amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: highlight ? _accent.withOpacity(0.1) : _navy,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: highlight ? _accent.withOpacity(0.3) : _border),
      ),
      child: Column(children: [
        Text(label, style: TextStyle(color: _t2, fontSize: 8)),
        const SizedBox(height: 2),
        Text('${fmt}원',
          style: TextStyle(
            color: highlight ? _accent : _t1,
            fontSize: 9, fontWeight: FontWeight.w800),
          overflow: TextOverflow.ellipsis),
      ]),
    ));
  }
}

// ============================================================
// 내 중고차 매물 관리 화면
// ============================================================
// ── 내 중고차 매물 관리 화면 ──────────────────────────────
class _MyListingsScreen extends StatefulWidget {
  const _MyListingsScreen();
  @override
  State<_MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<_MyListingsScreen>
    with SingleTickerProviderStateMixin {
  late List<UsedCarListing> _items;
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _loadItems();
    UsedCarState().addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _tab.dispose();
    UsedCarState().removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) { _loadItems(); }
  }

  void _loadItems() {
    final state = UsedCarState();
    // 1순위: isMyListing == true
    var mine = state.listings.where((l) => l.isMyListing).toList();
    // 2순위: 개인직거래 매물 (폴백)
    if (mine.isEmpty) {
      mine = state.listings.where((l) => l.sellerType == 'individual').toList();
    }
    // 3순위: 아무것도 없으면 하드코딩 더미 2개 즉시 표시
    if (mine.isEmpty) {
      mine = _fallbackDummy();
      // 싱글톤에 주입해서 다음 접근 시에도 유지
      for (final l in mine) {
        if (!state.listings.any((x) => x.listingId == l.listingId)) {
          state.listings.add(l);
        }
      }
    }
    if (mounted) setState(() => _items = mine);
  }

  // 혹시 더미데이터가 아직 안 들어온 경우 화면에 즉시 보여줄 항목
  List<UsedCarListing> _fallbackDummy() => [
    UsedCarListing(
      listingId: 'FB-001',
      title: '2020 BMW 320i M스포츠 (G20)',
      carName: 'BMW 320i', modelYear: '2020년식',
      mileage: 52000, price: 3450,
      fuel: '가솔린', transmission: '자동', color: '파랑',
      hasAccident: false, region: '대구 수성구',
      sellerName: '홍길동', sellerPhone: '010-1234-5678',
      sellerType: 'individual',
      isMyListing: true, ownerId: 'me', viewCount: 12, inquiryCount: 2,
      photoUrls: ['https://images.unsplash.com/photo-1555215695-3004980ad54e?w=600&q=80'],
      desc: 'M스포츠패키지 장착. 직거래 선호.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    UsedCarListing(
      listingId: 'FB-002',
      title: '2019 현대 그랜저 IG 3.0 프리미엄',
      carName: '현대 그랜저', modelYear: '2019년식',
      mileage: 68000, price: 2750,
      fuel: '가솔린', transmission: '자동', color: '은색',
      hasAccident: false, region: '대구 수성구',
      sellerName: '내 계정', sellerPhone: '010-0000-0000',
      sellerType: 'individual',
      isMyListing: true, ownerId: 'me', viewCount: 5, inquiryCount: 1,
      photoUrls: ['https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?w=600&q=80'],
      desc: '무사고. 가격 협의 가능.',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final activeCount  = _items.where((l) => !l.isSold).length;
    final totalInquiry = _items.fold<int>(0, (s, l) => s + l.inquiryCount);

    return Scaffold(
      backgroundColor: const Color(0xFF020810),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('내 매물',
          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tab,
          indicatorColor: const Color(0xFF8B5CF6),
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFF546E7A),
          tabs: const [Tab(text: '중고차'), Tab(text: '오토바이')],
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/used-car');
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withOpacity(0.18),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.5)),
              ),
              child: const Text('+ 새 등록',
                style: TextStyle(color: Color(0xFF8B5CF6), fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          // ── 탭 0: 중고차 ──
          Column(
            children: [
              Container(
                color: const Color(0xFF0D1B2A),
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                child: Row(children: [
                  Expanded(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text('$activeCount개', style: const TextStyle(color: Color(0xFF10B981), fontSize: 16, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 2), const Text('판매중', style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 10)),
                  ])),
                  Container(width: 1, height: 28, color: const Color(0xFF1E3A5F)),
                  Expanded(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text('${_items.length}개', style: const TextStyle(color: Color(0xFF4FC3F7), fontSize: 16, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 2), const Text('전체', style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 10)),
                  ])),
                  Container(width: 1, height: 28, color: const Color(0xFF1E3A5F)),
                  Expanded(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text('$totalInquiry건', style: TextStyle(color: totalInquiry > 0 ? const Color(0xFFEF4444) : const Color(0xFFB0BEC5), fontSize: 16, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 2), const Text('1:1 문의', style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 10)),
                  ])),
                ]),
              ),
              Expanded(
                child: _items.isEmpty
                  ? Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.sell_rounded, color: Color(0xFF1E3A5F), size: 64),
                        const SizedBox(height: 16),
                        const Text('등록된 직거래 매물이 없습니다',
                          style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 15, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        const Text('내차팔기 탭에서 직거래 매물로 등록하세요',
                          style: TextStyle(color: Color(0xFF1E3A5F), fontSize: 12)),
                      ]),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(14),
                      itemCount: _items.length,
                      itemBuilder: (ctx, i) => _MyListingEditCard(
                        key: ValueKey(_items[i].listingId),
                        listing: _items[i],
                        onUpdate: _loadItems,
                      ),
                    ),
              ),
            ],
          ),
          // ── 탭 1: 오토바이 매물 ──
          _MyMotoListingsTab(onChanged: () => setState(() {})),
        ],
      ),
    );
  }
}

// ── 내 오토바이 매물 탭 ──────────────────────────────────────
class _MyMotoListingsTab extends StatefulWidget {
  final VoidCallback onChanged;
  const _MyMotoListingsTab({required this.onChanged});
  @override
  State<_MyMotoListingsTab> createState() => _MyMotoListingsTabState();
}
class _MyMotoListingsTabState extends State<_MyMotoListingsTab> {
  @override
  void initState() {
    super.initState();
    MotoState().addListener(_refresh);
  }
  @override
  void dispose() {
    MotoState().removeListener(_refresh);
    super.dispose();
  }
  void _refresh() { if (mounted) setState(() {}); }

  @override
  Widget build(BuildContext context) {
    final myListings = MotoState().listings
        .where((l) => l.isMyListing)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final activeCount = myListings.where((l) =>
        l.status == MotoListingStatus.listing || l.status == MotoListingStatus.posted).length;
    final totalViews = myListings.fold<int>(0, (s, l) => s + l.viewCount);
    final totalInquiry = myListings.fold<int>(0, (s, l) => s + l.inquiryCount);

    if (myListings.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.two_wheeler_rounded,
              color: Color(0xFF1A2A3A), size: 64),
          const SizedBox(height: 16),
          const Text('등록된 오토바이 매물이 없습니다',
              style: TextStyle(color: Color(0xFFB0BEC5),
                  fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('오토바이 > 사고팔기에서 매물을 등록하세요',
              style: TextStyle(color: Color(0xFF546E7A), fontSize: 12)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE63946),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
            label: const Text('오토바이 매물 등록하기',
                style: TextStyle(color: Colors.white,
                    fontWeight: FontWeight.w700, fontSize: 14)),
          ),
        ]),
      );
    }

    return Column(children: [
      // 통계 헤더
      Container(
        color: const Color(0xFF0D1721),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        child: Row(children: [
          Expanded(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('$activeCount개', style: const TextStyle(color: Color(0xFF10B981), fontSize: 14, fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            const Text('판매중', style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 10)),
          ])),
          Container(width: 1, height: 24, color: const Color(0xFF1A2A3A)),
          Expanded(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('${myListings.length}개', style: const TextStyle(color: Color(0xFF4FC3F7), fontSize: 14, fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            const Text('전체', style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 10)),
          ])),
          Container(width: 1, height: 24, color: const Color(0xFF1A2A3A)),
          Expanded(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('$totalViews회', style: const TextStyle(color: Color(0xFFFF6B35), fontSize: 14, fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            const Text('조회수', style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 10)),
          ])),
          Container(width: 1, height: 24, color: const Color(0xFF1A2A3A)),
          Expanded(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('$totalInquiry건', style: TextStyle(color: totalInquiry > 0 ? const Color(0xFFE63946) : const Color(0xFFB0BEC5), fontSize: 14, fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            const Text('문의', style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 10)),
          ])),
        ]),
      ),
      Expanded(child: ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: myListings.length,
      itemBuilder: (_, i) {
        final l = myListings[i];
        return GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(
                  builder: (_) => MotorcycleScreen(
                      initialTab: 2,
                      highlightListingId: l.listingId)))
              .then((_) => setState(() {})),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1721),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1A2A3A)),
            ),
            child: Row(children: [
              // 대표 이미지
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(12)),
                child: l.photoUrls.isNotEmpty
                    ? (l.photoUrls.first.startsWith('http')
                        ? Image.network(l.photoUrls.first,
                            width: 100, height: 90, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Container(width: 100, height: 90,
                                    color: const Color(0xFF111E2C),
                                    child: const Icon(Icons.two_wheeler_rounded,
                                        color: Color(0xFF546E7A), size: 32)))
                        : Image.file(
                            File(l.photoUrls.first),
                            width: 100, height: 90, fit: BoxFit.cover))
                    : Container(width: 100, height: 90,
                        color: const Color(0xFF111E2C),
                        child: const Icon(Icons.two_wheeler_rounded,
                            color: Color(0xFF546E7A), size: 32)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('${l.manufacturer} ${l.model}',
                      style: const TextStyle(color: Colors.white,
                          fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text('${l.displacement}cc · ${l.year} · ${l.mileage}km',
                      style: const TextStyle(color: Color(0xFFB0BEC5),
                          fontSize: 11)),
                  const SizedBox(height: 4),
                  Text('${l.price}만원',
                      style: const TextStyle(color: Color(0xFFE63946),
                          fontSize: 16, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: l.status.color.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                            color: l.status.color.withOpacity(0.5)),
                      ),
                      child: Text(l.status.label,
                          style: TextStyle(color: l.status.color,
                              fontSize: 10, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.visibility_outlined,
                        color: Color(0xFF546E7A), size: 12),
                    Text(' ${l.viewCount}',
                        style: const TextStyle(color: Color(0xFF546E7A),
                            fontSize: 10)),
                    const SizedBox(width: 6),
                    const Icon(Icons.chat_bubble_outline_rounded,
                        color: Color(0xFF546E7A), size: 12),
                    Text(' ${l.inquiryCount}',
                        style: const TextStyle(color: Color(0xFF546E7A),
                            fontSize: 10)),
                  ]),
                ]),
              )),
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.arrow_forward_ios_rounded,
                    color: Color(0xFF546E7A), size: 14),
              ),
            ]),
          ),
        );
      },
      )),  // Expanded close
    ]);  // Column close
  }
}

class _MyListingEditCard extends StatelessWidget {
  final UsedCarListing listing;
  final VoidCallback onUpdate;
  const _MyListingEditCard({super.key, required this.listing, required this.onUpdate});

  static const Color _bg     = Color(0xFF020810);
  static const Color _card   = Color(0xFF0D1B2A);
  static const Color _accent = Color(0xFF4FC3F7);
  static const Color _green  = Color(0xFF10B981);
  static const Color _purple = Color(0xFF8B5CF6);
  static const Color _red    = Color(0xFFEF4444);
  static const Color _border = Color(0xFF1E3A5F);
  static const Color _textPri = Colors.white;
  static const Color _textSec = Color(0xFFB0BEC5);
  static const Color _orange  = Color(0xFFFF6B35);

  @override
  Widget build(BuildContext context) {
    final isSold = listing.isSold;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isSold ? _border.withOpacity(0.3) : _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 썸네일 + 기본 정보 (탭 시 상세 이동)
          GestureDetector(
            onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => UsedCarDetailScreen(listing: listing))),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14), bottomLeft: Radius.circular(0)),
                child: Stack(children: [
                  _thumbImage(listing.photoUrls.isNotEmpty ? listing.photoUrls.first : ''),
                  // 내 게시물 배지
                  Positioned(
                    top: 4, left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: _purple.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(4)),
                      child: const Text('내 매물',
                        style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w800)),
                    ),
                  ),
                  if (isSold)
                    Positioned.fill(child: Container(
                      color: Colors.black.withOpacity(0.55),
                      child: const Center(child: Text('SOLD',
                        style: TextStyle(color: Colors.white, fontSize: 14,
                          fontWeight: FontWeight.w900, letterSpacing: 2))),
                    )),
                ]),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(listing.title,
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: _textPri, fontSize: 12,
                          fontWeight: FontWeight.w700, height: 1.4)),
                      const SizedBox(height: 4),
                      Text('${_fmt(listing.mileage)}km · ${listing.fuel} · ${listing.modelYear}',
                        style: const TextStyle(color: _textSec, fontSize: 10)),
                      const SizedBox(height: 4),
                      Row(children: [
                        Text('${_fmt(listing.price)}만원',
                          style: const TextStyle(color: _textPri, fontSize: 15,
                            fontWeight: FontWeight.w900)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: isSold
                                ? _textSec.withOpacity(0.15)
                                : listing.isCertified
                                    ? _green.withOpacity(0.15)
                                    : _purple.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isSold
                                  ? _textSec.withOpacity(0.3)
                                  : listing.isCertified
                                      ? _green.withOpacity(0.5)
                                      : _purple.withOpacity(0.5)),
                          ),
                          child: Text(
                            isSold ? '판매완료' : listing.isCertified ? 'KAA인증' : '직거래',
                            style: TextStyle(
                              color: isSold ? _textSec : listing.isCertified ? _green : _purple,
                              fontSize: 9, fontWeight: FontWeight.w800)),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
            ],
          ), // Row
          ), // GestureDetector
          // ── 통계 바 (조회수/문의수/등록일) ──
          Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _border.withOpacity(0.5)),
            ),
            child: Row(children: [
              _miniStat(Icons.remove_red_eye_outlined, '${listing.viewCount}회', '조회'),
              _vDivider(),
              // 문의수 + 빨간 배지
              Stack(clipBehavior: Clip.none, children: [
                _miniStat(Icons.chat_bubble_outline, '${listing.inquiryCount}건', '문의'),
                if (listing.inquiryCount > 0)
                  Positioned(
                    top: -4, right: -4,
                    child: Container(
                      width: 14, height: 14,
                      decoration: const BoxDecoration(color: _red, shape: BoxShape.circle),
                      child: Center(child: Text('${listing.inquiryCount}',
                        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900))),
                    ),
                  ),
              ]),
              _vDivider(),
              _miniStat(Icons.access_time_rounded, _listingAgo(listing.createdAt), '등록'),
              _vDivider(),
              // 문의 목록 이동 버튼
              GestureDetector(
                onTap: () => _showInquiryList(context),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.message_rounded,
                    color: listing.inquiryCount > 0 ? _red : _textSec, size: 14),
                  const SizedBox(height: 2),
                  Text('문의 확인',
                    style: TextStyle(
                      color: listing.inquiryCount > 0 ? _red : _textSec,
                      fontSize: 9, fontWeight: FontWeight.w700)),
                ]),
              ),
            ]),
          ),
          // 편집 액션 버튼들
          Container(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(children: [
              // 가격 수정
              Expanded(child: _actionBtn(
                label: '💰 가격 수정',
                color: _accent,
                onTap: () => _editPrice(context),
              )),
              const SizedBox(width: 8),
              // 딜러 견적 재요청
              Expanded(child: _actionBtn(
                label: '🔄 딜러 재요청',
                color: _green,
                onTap: () => _rerequestDealer(context),
              )),
              const SizedBox(width: 8),
              // 판매완료/판매중으로 토글
              Expanded(child: _actionBtn(
                label: isSold ? '🔓 재등록' : '✅ 판매완료',
                color: isSold ? _orange : _red,
                onTap: () {
                  UsedCarState().markSold(listing.listingId);
                  onUpdate();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(isSold ? '다시 판매중으로 변경했습니다' : '판매완료 처리했습니다'),
                    backgroundColor: isSold ? _orange : _red,
                  ));
                },
              )),
            ]),
          ),
        ],
      ),
    ); // Container
  }

  Widget _actionBtn({required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Center(child: Text(label,
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
          overflow: TextOverflow.ellipsis)),
      ),
    );
  }

  void _editPrice(BuildContext context) {
    final ctrl = TextEditingController(text: listing.price.toString());
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0D1B2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('가격 수정', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('현재 가격: ${_fmt(listing.price)}만원',
            style: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 12)),
          const SizedBox(height: 12),
          TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: '새 가격 입력 (만원)',
              hintStyle: TextStyle(color: Colors.grey[600]),
              filled: true, fillColor: const Color(0xFF0A1628),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF1E3A5F))),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF1E3A5F))),
              suffixText: '만원',
              suffixStyle: const TextStyle(color: Color(0xFFB0BEC5)),
            ),
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: Color(0xFFB0BEC5)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4FC3F7),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () {
              final newPrice = int.tryParse(ctrl.text.trim());
              if (newPrice != null && newPrice > 0) {
                listing.price = newPrice;
                UsedCarState().notifyListeners();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('가격이 ${_fmt(newPrice)}만원으로 수정되었습니다'),
                    backgroundColor: const Color(0xFF4FC3F7),
                  ));
              }
            },
            child: const Text('저장', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }

  void _rerequestDealer(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0D1B2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('딜러 견적 재요청', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(listing.title,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('이 차량으로 딜러 견적을 다시 요청하시겠습니까?\n가까운 딜러들에게 새 견적 요청이 발송됩니다.',
            style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 12, height: 1.5)),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: Color(0xFFB0BEC5)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/used-car', arguments: {'initialTab': 0});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('딜러 견적 탭으로 이동합니다. 차량 정보를 입력해 재요청하세요.'),
                  backgroundColor: Color(0xFF10B981),
                ));
            },
            child: const Text('재요청', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }

  String _fmt(int n) {
    if (n >= 10000) {
      final man = n ~/ 10000;
      final thou = (n % 10000) ~/ 1000;
      return thou > 0 ? '$man,${thou}000' : '$man,000';
    }
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  String _listingAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return '방금';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays < 30) return '${diff.inDays}일 전';
    return '${(diff.inDays / 30).floor()}달 전';
  }

  Widget _miniStat(IconData icon, String value, String label) =>
      Expanded(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: _textSec, size: 12),
        const SizedBox(height: 2),
        Text(value,
          style: const TextStyle(color: _textPri, fontSize: 10, fontWeight: FontWeight.w700)),
        Text(label,
          style: const TextStyle(color: _textSec, fontSize: 9)),
      ]));

  Widget _vDivider() => Container(width: 1, height: 28, color: _border.withOpacity(0.6));

  Widget _thumbImage(String url) {
    final errorW = Container(
      width: 100, height: 85, color: const Color(0xFF0A1628),
      child: const Icon(Icons.directions_car, color: _textSec, size: 28));
    if (url.isEmpty) return errorW;
    final isLocal = url.startsWith('/') || url.startsWith('file://');
    if (isLocal) {
      return Image.file(
        File(url.replaceFirst('file://', '')),
        width: 100, height: 85, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => errorW);
    }
    return Image.network(url,
      width: 100, height: 85, fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => errorW);
  }

  void _showInquiryList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D1B2A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            const Icon(Icons.chat_bubble_rounded, color: Color(0xFF4FC3F7), size: 20),
            const SizedBox(width: 8),
            const Text('1:1 문의 목록',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 16),
          if (listing.inquiryCount == 0)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text('아직 문의가 없습니다',
                style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 13)),
            )
          else
            ...List.generate(listing.inquiryCount, (i) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0A1628),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF1E3A5F)),
              ),
              child: Row(children: [
                const CircleAvatar(radius: 16,
                  backgroundColor: Color(0xFF1E3A5F),
                  child: Icon(Icons.person_rounded, color: Colors.white, size: 16)),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('익명 구매자 ${i + 1}',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  const Text('차량 상태 문의드립니다. 직거래 가능할까요?',
                    style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 11),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                ])),
                const Text('방금',
                  style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 10)),
              ]),
            )),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}
