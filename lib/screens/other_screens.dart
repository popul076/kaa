import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';
import '../widgets/common_widgets.dart';

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
                        color: _accent, onTap: () {}),
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
  final List<Map<String, dynamic>> _notifs = [
    {
      'title': '견적 요청 접수',
      'body': 'MOINCAR 프리미엄 정비소에서 견적이 도착했습니다.\n\n견적 금액: 85,000원\n작업 내용: 엔진오일 교환 + 에어필터 교체\n예상 소요 시간: 1시간\n\n지금 바로 확인하고 예약을 확정하세요.',
      'date': '2025-04-12',
      'time': '방금 전',
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

  int get _unreadCount => _notifs.where((n) => !(n['read'] as bool)).length;

  void _markAllRead() {
    setState(() {
      for (final n in _notifs) n['read'] = true;
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
                  const Text('🔔 알림',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
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
              child: _notifs.isEmpty
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
                    itemCount: _notifs.length,
                    itemBuilder: (_, i) {
                      final n = _notifs[i];
                      final isRead = n['read'] as bool;
                      final isExpanded = _expanded.contains(i);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isExpanded) {
                              _expanded.remove(i);
                            } else {
                              _expanded.add(i);
                              if (!isRead) {
                                n['read'] = true;
                                final unread = _notifs.where((n) => !(n['read'] as bool)).length;
                                AppState().updateNotificationCount(unread);
                              }
                            }
                          });
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

// ==================== 견적 요청 ====================
class QuoteRequestScreen extends StatelessWidget {
  const QuoteRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: AppHeader(showBack: true, title: '견적 요청', notifCount: AppState().notificationCount),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('견적 요청',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  const Text('차량 사진을 업로드하고 근처 정비점에 견적을 요청하세요.',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),

                  // 카테고리 선택
                  const Text('서비스 종류',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['정비', '세차', '타이어', '판금/도색', '내장 수리', '기타'].map((c) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: c == '정비' ? AppColors.primaryLight : AppColors.bgGray,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: c == '정비' ? AppColors.primary : AppColors.border,
                          ),
                        ),
                        child: Text(c,
                          style: TextStyle(
                            fontSize: 13,
                            color: c == '정비' ? AppColors.primary : AppColors.textSecondary,
                            fontWeight: c == '정비' ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // 사진 업로드 영역
                  const Text('차량 사진',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: AppColors.bgGray,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined, size: 40, color: AppColors.textMuted),
                          SizedBox(height: 8),
                          Text('사진 촬영 또는 갤러리에서 선택',
                            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 요청 내용
                  const Text('상세 내용',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: '수리가 필요한 부분이나 증상을 설명해 주세요.',
                      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('견적 요청이 접수되었습니다!')),
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('견적 요청하기',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
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

// ==================== 점포 등록 (다크테마 + AI 애니메이션 + 1~3장 사진) ====================
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
class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final news = [
      {'title': '중고차 성능점검 확인 수요 확대', 'category': '자동차 소식', 'time': '2시간 전', 'image': 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=300&q=80'},
      {'title': '2025년 전기차 보조금 변경 사항 정리', 'category': '전기차·친환경', 'time': '5시간 전', 'image': 'https://images.unsplash.com/photo-1593941707882-a5bba14938c7?w=300&q=80'},
      {'title': '봄철 타이어 관리 필수 체크리스트', 'category': '차량 정비', 'time': '1일 전', 'image': 'https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?w=300&q=80'},
      {'title': 'MOINCAR 인증 점포 확대 안내', 'category': 'MOINCAR 소식', 'time': '2일 전', 'image': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=300&q=80'},
    ];

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: AppHeader(showBack: true, title: '자동차 뉴스', notifCount: AppState().notificationCount),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: news.length,
              itemBuilder: (_, i) {
                final n = news[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                        child: Image.network(
                          n['image'] as String,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 90, height: 90,
                            color: AppColors.bgGray,
                            child: const Icon(Icons.article, color: AppColors.textMuted),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(n['category'] as String,
                                  style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(n['title'] as String,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(n['time'] as String,
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                              ),
                            ],
                          ),
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
    );
  }
}

// ==================== 긴급서비스 ====================
class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: AppHeader(showBack: true, title: '긴급서비스', notifCount: AppState().notificationCount),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.danger.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        const Text('🚨', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        const Text('긴급출동 서비스',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.danger),
                        ),
                        const SizedBox(height: 8),
                        const Text('배터리 방전, 타이어 펑크, 시동불량 등\n긴급 상황에서 도움을 드립니다.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('긴급출동 요청이 접수되었습니다. 잠시만 기다려주세요.')),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.danger,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('긴급출동 요청하기',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...['배터리 방전', '타이어 펑크', '시동 불량', '연료 부족', '잠금 해제'].map((service) {
                    return ListTile(
                      leading: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.danger.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.build, color: AppColors.danger, size: 20),
                      ),
                      title: Text(service, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
                      onTap: () {},
                    );
                  }),
                ],
              ),
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

  final _plateCtrl    = TextEditingController();
  final _makerCtrl    = TextEditingController();
  final _modelCtrl    = TextEditingController();
  final _yearCtrl     = TextEditingController();
  final _kmCtrl       = TextEditingController();
  final _gradeCtrl    = TextEditingController();

  // 시세 결과 (더미 데이터 - 실제 API 연동 가능)
  Map<String, dynamic>? _priceResult;

  void _lookup() async {
    final plate = _plateCtrl.text.trim();
    final maker = _makerCtrl.text.trim();
    final model = _modelCtrl.text.trim();
    final year  = _yearCtrl.text.trim();
    final km    = _kmCtrl.text.trim();

    if (maker.isEmpty || model.isEmpty || year.isEmpty || km.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제조사, 모델명, 연식, 주행거리를 입력해주세요')));
      return;
    }

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1200));

    // 더미 시세 계산 로직
    final yearNum = int.tryParse(year) ?? 2020;
    final kmNum = int.tryParse(km.replaceAll(RegExp(r'[^0-9]'), '')) ?? 50000;
    final base = maker.contains('BMW') || maker.contains('벤츠') || maker.contains('아우디')
      ? 45000000 : 20000000;
    final ageFactor = (2026 - yearNum) * 0.07;
    final kmFactor = (kmNum / 100000) * 0.15;
    final est = (base * (1 - ageFactor - kmFactor)).toInt();
    final low = (est * 0.90).toInt();
    final high = (est * 1.10).toInt();

    setState(() {
      _loading = false;
      _priceResult = {
        'maker': maker,
        'model': model,
        'year': year,
        'km': km,
        'plate': plate,
        'low': low,
        'mid': est,
        'high': high,
        'grade': _grade(yearNum, kmNum),
      };
      _step = 1;
    });
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
                    onTap: () {
                      if (_step == 1) { setState(() { _step = 0; _priceResult = null; }); }
                      else { Navigator.pop(context); }
                    },
                    child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(_step == 0 ? '💰 내차 시세 조회' : '📊 시세 결과',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                  const Spacer(),
                  if (_step == 1)
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

  Widget _buildInputPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            child: Row(
              children: [
                const Text('💰', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AI 기반 내차 시세 조회',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                      SizedBox(height: 4),
                      Text('차량 정보 입력 후 즉시 시세 범위를 확인하세요',
                        style: TextStyle(fontSize: 11, color: _mTextSec)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _darkField('🚗 차량 번호 (선택)', '123가 4567', _plateCtrl),
          const SizedBox(height: 14),
          _darkField('🏭 제조사 *', '현대, 기아, BMW, 벤츠 등', _makerCtrl),
          const SizedBox(height: 14),
          _darkField('🚙 모델명 *', '아반떼, K5, 320i 등', _modelCtrl),
          const SizedBox(height: 14),
          _darkField('📅 연식 *', '2020, 2021, 2022 등', _yearCtrl,
            keyboardType: TextInputType.number),
          const SizedBox(height: 14),
          _darkField('📏 주행거리 *', '50000 (km 단위)', _kmCtrl,
            keyboardType: TextInputType.number),
          const SizedBox(height: 14),
          _darkField('⭐ 등급 (선택)', '무사고, 단순교환 등', _gradeCtrl),
          const SizedBox(height: 24),
          // 조회 버튼
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _loading ? null : _lookup,
              style: ElevatedButton.styleFrom(
                backgroundColor: _mOrange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _loading
                ? const SizedBox(width: 22, height: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text('시세 조회하기',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
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
      padding: const EdgeInsets.all(20),
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
                      Text('주행거리 ${r['km']}km · 등급 ${r['grade']}',
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
                  ['차량 등급', '${r['grade']}', _mGreen, 0.85],
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

          // 내차 팔기 버튼
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('MOINCAR 내차 팔기 서비스 준비중입니다'))),
              style: ElevatedButton.styleFrom(
                backgroundColor: _mGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('🚗 내 차 팔기 신청',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 10),
          Text('* 제공되는 시세는 AI 분석 기반 참고용입니다.',
            style: TextStyle(fontSize: 11, color: _mTextSec.withOpacity(0.6))),
        ],
      ),
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

  @override
  void dispose() {
    _plateCtrl.dispose();
    _makerCtrl.dispose();
    _modelCtrl.dispose();
    _yearCtrl.dispose();
    _kmCtrl.dispose();
    _gradeCtrl.dispose();
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
  final _makerCtrl  = TextEditingController();
  final _modelCtrl  = TextEditingController();
  final _yearCtrl   = TextEditingController();
  final _mileCtrl   = TextEditingController();
  String _fuelType = '가솔린';
  bool _isSaved = false;

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
                          Expanded(child: _VehicleField(ctrl: _makerCtrl, label: '제조사', hint: '현대, 기아...')),
                          const SizedBox(width: 10),
                          Expanded(child: _VehicleField(ctrl: _modelCtrl, label: '모델명', hint: '아반떼, K5...')),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _VehicleField(ctrl: _yearCtrl, label: '연식', hint: '2021', isNum: true)),
                          const SizedBox(width: 10),
                          Expanded(child: _VehicleField(ctrl: _mileCtrl, label: '현재 주행거리(km)', hint: '45000', isNum: true)),
                        ],
                      ),
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
                                  'maker': _makerCtrl.text,
                                  'model': _modelCtrl.text,
                                  'year': _yearCtrl.text,
                                  'fuel': _fuelType,
                                  'mile': _mileCtrl.text,
                                  'lastService': '-',
                                  'color': 0xFFFF6B35,
                                });
                                _plateCtrl.clear(); _makerCtrl.clear();
                                _modelCtrl.clear(); _yearCtrl.clear(); _mileCtrl.clear();
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

  final List<Map<String, dynamic>> _history = [
    {'date': '2024-12-10', 'type': '엔진오일 교환', 'shop': 'MOINCAR 추천 정비소',
     'cost': '89,000원', 'mile': '44,100km', 'next': '45,100km', 'color': 0xFF4FC3F7, 'icon': '🛢️'},
    {'date': '2024-09-05', 'type': '타이어 교체 (앞 2개)', 'shop': '타이어뱅크 수성점',
     'cost': '280,000원', 'mile': '40,200km', 'next': '-', 'color': 0xFFFF6B35, 'icon': '🔄'},
    {'date': '2024-06-22', 'type': '브레이크 패드 교환', 'shop': 'MOINCAR 추천 정비소',
     'cost': '150,000원', 'mile': '37,500km', 'next': '57,500km', 'color': 0xFF10B981, 'icon': '🔧'},
    {'date': '2024-03-11', 'type': '종합 점검 + 에어필터', 'shop': '현대 오토에버',
     'cost': '65,000원', 'mile': '33,000km', 'next': '-', 'color': 0xFF8B5CF6, 'icon': '🔍'},
  ];

  int get _totalCost => _history.fold(0, (s, h) {
    final val = (h['cost'] as String).replaceAll(RegExp(r'[^0-9]'), '');
    return s + (int.tryParse(val) ?? 0);
  });

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('🔧 차량 정비 이력',
                        style: TextStyle(color: _textPri, fontSize: 17, fontWeight: FontWeight.w700)),
                      Text('123가 4567 · 현대 아반떼 2021',
                        style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 11)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _showAddMaintenanceDialog(),
                  child: Container(
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
                // 요약 카드
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
                      Expanded(child: _SummaryItem(label: '총 정비 횟수', value: '${_history.length}회', color: _textPri)),
                      Expanded(child: _SummaryItem(label: '총 비용', value: '${(_totalCost / 10000).toStringAsFixed(0)}만원', color: _orange)),
                      Expanded(child: _SummaryItem(label: '현재 주행', value: '45,200km', color: _accent)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 다음 정비 알림
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
                const SizedBox(height: 16),

                const Text('정비 이력',
                  style: TextStyle(color: _textSec, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),

                // 타임라인
                ..._history.asMap().entries.map((entry) {
                  final i = entry.key;
                  final h = entry.value;
                  final color = Color(h['color'] as int);
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 타임라인 라인
                      Column(
                        children: [
                          Container(
                            width: 32, height: 32,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.15),
                              shape: BoxShape.circle,
                              border: Border.all(color: color.withOpacity(0.4)),
                            ),
                            child: Center(child: Text(h['icon'] as String,
                              style: const TextStyle(fontSize: 14))),
                          ),
                          if (i < _history.length - 1)
                            Container(width: 1, height: 80, color: _border),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(h['date'] as String,
                                    style: const TextStyle(color: _textSec, fontSize: 10)),
                                  const Spacer(),
                                  Text(h['mile'] as String,
                                    style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(h['type'] as String,
                                style: const TextStyle(color: _textPri, fontSize: 14, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 3),
                              Text(h['shop'] as String,
                                style: const TextStyle(color: _textSec, fontSize: 11)),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text('비용: ',
                                    style: const TextStyle(color: _textSec, fontSize: 11)),
                                  Text(h['cost'] as String,
                                    style: const TextStyle(color: _textPri, fontSize: 12, fontWeight: FontWeight.w700)),
                                  const Spacer(),
                                  if (h['next'] != '-') ...[
                                    const Text('다음: ',
                                      style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 10)),
                                    Text(h['next'] as String,
                                      style: const TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.w600)),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('✅ 알림 설정이 저장되었습니다')));
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _mAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('저장', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black)),
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
            activeColor: _mAccent,
            activeTrackColor: _mAccent.withOpacity(0.3),
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

                  _privacySection('계정 관리', [
                    _actionTile('비밀번호 변경', Icons.lock_outline, _mAccent,
                      () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('비밀번호 변경 기능 준비중')))),
                    _actionTile('이메일 변경', Icons.email_outlined, _mAccent,
                      () => ScaffoldMessenger.of(context).showSnackBar(
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

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('✅ 개인정보 설정이 저장되었습니다')));
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _mAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('저장', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black)),
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
