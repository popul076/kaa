import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_state.dart';

// ─── 색상 상수 ────────────────────────────────────────────────
const Color _bg      = Color(0xFF020810);
const Color _card    = Color(0xFF0D1B2A);
const Color _navy    = Color(0xFF0A1628);
const Color _accent  = Color(0xFF4FC3F7);
const Color _green   = Color(0xFF10B981);
const Color _orange  = Color(0xFFFF6B35);
const Color _purple  = Color(0xFF8B5CF6);
const Color _red     = Color(0xFFE53935);
const Color _border  = Color(0xFF1E3A5F);
const Color _textPri = Colors.white;
const Color _textSec = Color(0xFFB0BEC5);

// ─── 차량번호 더미 DB ─────────────────────────────────────────
const Map<String, Map<String, String>> _plateDB = {
  '123가4567': {'model': '현대 그랜저 IG 3.0', 'maker': '현대', 'year': '2019년식', 'regDate': '2019-03-15', 'marketMin': '2100', 'marketMax': '2600'},
  '456나7890': {'model': 'BMW 320i (G20)',    'maker': 'BMW',  'year': '2020년식', 'regDate': '2020-07-22', 'marketMin': '3000', 'marketMax': '3600'},
  '789다1234': {'model': '기아 K5 DL3 2.0',   'maker': '기아',  'year': '2021년식', 'regDate': '2021-01-08', 'marketMin': '1900', 'marketMax': '2400'},
  '111라2222': {'model': '현대 아반떼 CN7',    'maker': '현대', 'year': '2022년식', 'regDate': '2022-05-30', 'marketMin': '1600', 'marketMax': '2100'},
  '333마4444': {'model': '테슬라 모델3 LR',    'maker': '테슬라','year': '2023년식', 'regDate': '2023-02-14', 'marketMin': '4200', 'marketMax': '5000'},
  '555바6666': {'model': '벤츠 E220d W213',    'maker': '벤츠', 'year': '2022년식', 'regDate': '2022-11-01', 'marketMin': '5200', 'marketMax': '6100'},
};

// ─── 제조사/모델 데이터 ────────────────────────────────────────
const Map<String, List<String>> _makerModels = {
  '전체': [],
  '현대': ['전체 모델', '아반떼', '소나타', '그랜저', '투싼', '싼타페', '팰리세이드', '코나', '아이오닉5', '아이오닉6'],
  '기아': ['전체 모델', 'K3', 'K5', 'K8', 'K9', '스포티지', '쏘렌토', '카니발', 'EV6', 'EV9', '레이'],
  '제네시스': ['전체 모델', 'G70', 'G80', 'G90', 'GV70', 'GV80', 'GV90'],
  'BMW': ['전체 모델', '3시리즈', '5시리즈', '7시리즈', 'X3', 'X5', 'X7', 'i3', 'i7'],
  '벤츠': ['전체 모델', 'C클래스', 'E클래스', 'S클래스', 'GLC', 'GLE', 'GLS', 'EQE'],
  '아우디': ['전체 모델', 'A4', 'A6', 'A8', 'Q5', 'Q7', 'Q8', 'e-tron'],
  '테슬라': ['전체 모델', '모델3', '모델S', '모델X', '모델Y'],
  '쉐보레': ['전체 모델', '트레일블레이저', '트랙스', '이쿼녹스', '볼트EV'],
  '르노': ['전체 모델', 'SM6', 'QM6', 'XM3', '조에'],
  '쌍용': ['전체 모델', '티볼리', '코란도', '렉스턴', '토레스'],
};

String _formatNum(int n) => n.toString().replaceAllMapped(
  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

String _timeAgo(DateTime dt) {
  final d = DateTime.now().difference(dt);
  if (d.inMinutes < 1) return '방금 전';
  if (d.inMinutes < 60) return '${d.inMinutes}분 전';
  if (d.inHours < 24) return '${d.inHours}시간 전';
  return '${d.inDays}일 전';
}

// ═══════════════════════════════════════════════════════════════
// 메인 화면
// ═══════════════════════════════════════════════════════════════
class UsedCarMainScreen extends StatefulWidget {
  const UsedCarMainScreen({super.key});
  @override
  State<UsedCarMainScreen> createState() => _UsedCarMainScreenState();
}

class _UsedCarMainScreenState extends State<UsedCarMainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: _card,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _bg,
        body: Column(children: [
          // ── AppBar ─────────────────────────────────────────
          Container(
            color: _card,
            padding: EdgeInsets.fromLTRB(4, top + 4, 8, 0),
            child: Column(children: [
              Row(children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: _textPri, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Center(
                    child: Text('중고차',
                        style: TextStyle(
                            color: _textPri,
                            fontSize: 17,
                            fontWeight: FontWeight.w800)),
                  ),
                ),
                // 우측 종 아이콘
                AnimatedBuilder(
                  animation: AppState(),
                  builder: (_, __) {
                    final cnt = AppState().totalBidCount +
                        AppState().inAppNotifications.length;
                    return GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, '/notification'),
                      child: Stack(clipBehavior: Clip.none, children: [
                        Container(
                          width: 38, height: 38,
                          decoration: BoxDecoration(
                            color: _navy,
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: _border),
                          ),
                          child: const Icon(
                              Icons.notifications_none_rounded,
                              color: _textSec, size: 19),
                        ),
                        if (cnt > 0)
                          Positioned(
                            right: -1, top: -1,
                            child: Container(
                              width: 16, height: 16,
                              decoration: const BoxDecoration(
                                  color: _red, shape: BoxShape.circle),
                              child: Center(
                                child: Text(
                                  cnt > 9 ? '9+' : '$cnt',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                      ]),
                    );
                  },
                ),
                const SizedBox(width: 4),
              ]),
              // 2탭
              TabBar(
                controller: _tab,
                indicatorColor: _accent,
                indicatorWeight: 2.5,
                labelColor: _accent,
                unselectedLabelColor: _textSec,
                labelStyle: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w800),
                unselectedLabelStyle: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500),
                tabs: const [
                  Tab(text: '내 차 팔기'),
                  Tab(text: '중고차 사기'),
                ],
              ),
            ]),
          ),

          // ── 탭 콘텐츠 ──────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                _SellMyCarTab(),
                _BuyCarTab(),
              ],
            ),
          ),

          // ── 하단 가까운 중고차 점포 ──────────────────────────
          const _NearbyDealerBar(),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 탭1: 내 차 팔기 (헤이딜러 방식 역경매)
// ═══════════════════════════════════════════════════════════════
class _SellMyCarTab extends StatefulWidget {
  @override
  State<_SellMyCarTab> createState() => _SellMyCarTabState();
}

class _SellMyCarTabState extends State<_SellMyCarTab> {
  // 단계: 0=번호+소유주 입력, 1=상세입력, 2=딜러 투찰 목록
  int _step = 0;

  final _plateCtrl  = TextEditingController();
  final _ownerCtrl  = TextEditingController();
  final _mileCtrl   = TextEditingController();
  final _memoCtrl   = TextEditingController();
  final _phoneCtrl  = TextEditingController();

  bool _plateLoading = false;
  bool _plateFound   = false;
  String? _foundModel, _foundYear, _foundRegDate;
  String? _foundMaketMin, _foundMarketMax;

  bool _hasAccident = false;
  List<File> _photos = [];
  final _picker = ImagePicker();

  String _kmSaved = '';
  bool get _kmChanged =>
      _mileCtrl.text.trim().isNotEmpty &&
      _mileCtrl.text.trim() != _kmSaved;

  UsedCarSaleRequest? get _activeReq =>
      UsedCarState().saleRequests.isNotEmpty
          ? UsedCarState().saleRequests.first
          : null;

  static const _kPlate = 'uc_plate';
  static const _kOwner = 'uc_owner';
  static const _kKm    = 'uc_km';

  @override
  void initState() {
    super.initState();
    _loadSaved();
    _mileCtrl.addListener(() => setState(() {}));
    if (UsedCarState().saleRequests.isNotEmpty &&
        UsedCarState().saleRequests.first.status == UsedCarStatus.bidding) {
      _step = 2;
    }
  }

  Future<void> _loadSaved() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _plateCtrl.text = p.getString(_kPlate) ?? '';
      _ownerCtrl.text = p.getString(_kOwner) ?? '';
      final km = p.getString(_kKm) ?? '';
      _kmSaved = km;
      // 주행거리는 자동완성 안 함 - 반드시 새로 입력
    });
  }

  Future<void> _savePref() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kPlate, _plateCtrl.text);
    await p.setString(_kOwner, _ownerCtrl.text);
    await p.setString(_kKm, _mileCtrl.text);
  }

  Future<void> _lookupPlate() async {
    final plate = _plateCtrl.text.trim().replaceAll(' ', '');
    if (plate.isEmpty) return;
    setState(() => _plateLoading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    final info = _plateDB[plate];
    setState(() {
      _plateLoading = false;
      _plateFound   = true;
      _foundModel      = info?['model']     ?? '차량 정보 수동 입력';
      _foundYear       = info?['year']      ?? '연식 미확인';
      _foundRegDate    = info?['regDate']   ?? '등록일 미확인';
      _foundMaketMin   = info?['marketMin'] ?? '0';
      _foundMarketMax  = info?['marketMax'] ?? '0';
      _step = 1;
    });
  }

  Future<void> _pickPhoto() async {
    if (_photos.length >= 10) return;
    final xf = await _picker.pickImage(
        source: ImageSource.gallery, imageQuality: 60);
    if (xf != null) setState(() => _photos.add(File(xf.path)));
  }

  Future<void> _submitSale() async {
    if (!_kmChanged) return;
    await _savePref();
    setState(() => _kmSaved = _mileCtrl.text.trim());

    final req = UsedCarSaleRequest(
      requestId: 'SALE-${DateTime.now().millisecondsSinceEpoch}',
      carNumber: _plateCtrl.text.trim(),
      carName: _foundModel ?? '차량 미상',
      regDate: _foundRegDate ?? '',
      modelYear: _foundYear ?? '',
      mileage: int.tryParse(
              _mileCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
      hasAccident: _hasAccident,
      memo: _memoCtrl.text.trim(),
      photoUrls: _photos.map((f) => f.path).toList(),
      createdAt: DateTime.now(),
      status: UsedCarStatus.bidding,
      bids: [
        DealerBid(bidId: 'BID-N01', dealerName: 'KAA 인증 중고차센터',
          dealerBadge: 'KAA인증', dealerPhone: '053-456-7890',
          dealerRating: 4.8, dealerLocation: '대구 수성구 · 2.1km',
          offerPrice: int.parse(_foundMaketMin ?? '2000') - 50 + (DateTime.now().millisecond % 100),
          memo: '무사고 실물 확인 후 금액 조정 가능. 당일 이전 처리 가능.',
          createdAt: DateTime.now(), isRead: false),
        DealerBid(bidId: 'BID-N02', dealerName: '범어 중고차 매매단지',
          dealerBadge: '우수딜러', dealerPhone: '053-567-8901',
          dealerRating: 4.5, dealerLocation: '대구 수성구 · 1.9km',
          offerPrice: int.parse(_foundMaketMin ?? '2000') - 150 + (DateTime.now().millisecond % 80),
          memo: '시세 대비 최고가 매입 보장! 즉시 현금 지급.',
          createdAt: DateTime.now(), isRead: false),
        DealerBid(bidId: 'BID-N03', dealerName: '황금동 오토플라자',
          dealerBadge: '인기딜러', dealerPhone: '053-678-9012',
          dealerRating: 4.3, dealerLocation: '대구 수성구 · 3.2km',
          offerPrice: int.parse(_foundMaketMin ?? '2000') - 250 + (DateTime.now().millisecond % 60),
          memo: '사진 확인 완료. 추가 협의 가능.',
          createdAt: DateTime.now(), isRead: false),
      ],
    );
    UsedCarState().addSaleRequest(req);
    setState(() => _step = 2);

    AppState().addInAppNotification(
      '내 차 팔기 신청 완료',
      '주변 딜러에게 견적 요청이 발송되었습니다.',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('✅ 판매 신청 완료! 딜러들이 견적을 보내고 있습니다.'),
        backgroundColor: _green,
        duration: Duration(seconds: 3),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: UsedCarState(),
      builder: (context, _) {
        if (_step == 2) return _buildDealerBidList();
        if (_step == 1) return _buildDetailForm();
        return _buildStep0();
      },
    );
  }

  // ── STEP0: 차량번호 + 소유주명 ──────────────────────────────
  Widget _buildStep0() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // 헤더
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_accent.withOpacity(0.15), _green.withOpacity(0.08)]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _accent.withOpacity(0.3)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.sell_rounded, color: _accent, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('내 차 팔기',
                    style: GoogleFonts.notoSansKr(
                      color: _textPri, fontSize: 18, fontWeight: FontWeight.w900)),
                  Text('차량번호로 시세 즉시 조회',
                    style: GoogleFonts.notoSansKr(
                      color: _accent, fontSize: 12)),
                ],
              )),
            ]),
            const SizedBox(height: 14),
            _bullet('차량번호 입력 → 시세 즉시 확인'),
            _bullet('주변 딜러가 경쟁적으로 매입가 제시'),
            _bullet('마음에 드는 견적 선택 → 전화 연결'),
          ]),
        ),
        const SizedBox(height: 24),

        // 차량번호
        _sectionTitle('차량번호 *'),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: _inputBox(
              controller: _plateCtrl,
              hint: '예) 123가 4567',
              prefix: Icons.directions_car_outlined,
              caps: TextCapitalization.characters,
              onSubmit: (_) => _lookupPlate(),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _plateLoading ? null : _lookupPlate,
            child: Container(
              width: 60, height: 52,
              decoration: BoxDecoration(
                color: _accent, borderRadius: BorderRadius.circular(12)),
              child: Center(
                child: _plateLoading
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.black, strokeWidth: 2.5))
                    : const Icon(Icons.search_rounded,
                        color: Colors.black, size: 22),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 16),

        // 소유주명
        _sectionTitle('소유주명 *'),
        const SizedBox(height: 8),
        _inputBox(
          controller: _ownerCtrl,
          hint: '차량 등록증상 소유주 이름',
          prefix: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _orange.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _orange.withOpacity(0.25)),
          ),
          child: Row(children: [
            const Icon(Icons.info_outline_rounded, color: _orange, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text(
              '조회 성공 시 연식·최초등록일·모델명이 자동 출력됩니다',
              style: TextStyle(
                color: _orange.withOpacity(0.9), fontSize: 11, height: 1.4),
            )),
          ]),
        ),
      ]),
    );
  }

  // ── STEP1: 상세 입력 폼 ────────────────────────────────────
  Widget _buildDetailForm() {
    final canSubmit = _kmChanged && _plateFound;
    final minP = int.tryParse(_foundMaketMin ?? '0') ?? 0;
    final maxP = int.tryParse(_foundMarketMax ?? '0') ?? 0;

    // 상단 고정 InfoBar: 차량번호 조회 결과를 항상 노출
    Widget infoBar = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF0D2A1E), const Color(0xFF0A1628)]),
        border: Border(
          bottom: BorderSide(color: _green.withOpacity(0.35))),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: _green.withOpacity(0.18),
              borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.check_circle_outline,
                color: _green, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_foundModel ?? '',
                style: const TextStyle(
                    color: _textPri, fontSize: 14, fontWeight: FontWeight.w900,
                    letterSpacing: -0.3)),
              const SizedBox(height: 3),
              Row(children: [
                _chip(_foundYear ?? '', _accent),
                const SizedBox(width: 5),
                _chip('최초등록 ${_foundRegDate ?? ''}', _green),
              ]),
            ],
          )),
          GestureDetector(
            onTap: () => setState(() { _step = 0; _plateFound = false; }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: _border.withOpacity(0.6),
                borderRadius: BorderRadius.circular(7)),
              child: const Text('재조회',
                style: TextStyle(color: _textSec, fontSize: 10,
                    fontWeight: FontWeight.w600)),
            ),
          ),
        ]),
        if (minP > 0) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.07),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: _accent.withOpacity(0.18)),
            ),
            child: Row(children: [
              const Icon(Icons.trending_up_rounded, color: _accent, size: 15),
              const SizedBox(width: 7),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('현재 시세',
                  style: TextStyle(color: _textSec, fontSize: 9)),
                Text('${_formatNum(minP)}만원  ~  ${_formatNum(maxP)}만원',
                  style: const TextStyle(
                      color: _accent, fontSize: 14, fontWeight: FontWeight.w900)),
              ]),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: _green.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(5)),
                child: const Text('실시간',
                  style: TextStyle(color: _green, fontSize: 9,
                      fontWeight: FontWeight.w800)),
              ),
            ]),
          ),
        ],
      ]),
    );

    return Column(children: [
      infoBar,
      Expanded(
        child: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 4),

        // 주행거리 (필수 - 새로 입력)
        _sectionTitle('주행거리 * (반드시 새로 입력)'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _kmChanged ? _green.withOpacity(0.6) : _border,
              width: _kmChanged ? 1.5 : 1),
          ),
          child: TextField(
            controller: _mileCtrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: _textPri, fontSize: 15),
            decoration: InputDecoration(
              hintText: '현재 주행거리 입력 (예: 72000)',
              hintStyle: TextStyle(color: _textSec.withOpacity(0.5)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              suffixText: 'km',
              suffixStyle: const TextStyle(color: _textSec, fontSize: 13),
              prefixIcon: Icon(Icons.speed_rounded,
                  color: _kmChanged ? _green : _textSec, size: 20),
            ),
          ),
        ),
        if (_kmSaved.isNotEmpty && !_kmChanged) ...[
          const SizedBox(height: 6),
          Text('이전 저장값: ${_kmSaved}km · 반드시 현재 거리를 새로 입력해주세요',
            style: const TextStyle(color: _orange, fontSize: 11)),
        ],
        const SizedBox(height: 16),

        // 사고 유무
        _sectionTitle('사고 유무'),
        const SizedBox(height: 8),
        Row(children: [
          _accidentBtn(false, '무사고'),
          const SizedBox(width: 10),
          _accidentBtn(true, '사고 있음'),
        ]),
        const SizedBox(height: 16),

        // 차량 사진
        _sectionTitle('차량 사진 (최대 10장)'),
        const SizedBox(height: 8),
        SizedBox(
          height: 90,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              GestureDetector(
                onTap: _pickPhoto,
                child: Container(
                  width: 80, height: 80,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _photos.length >= 10
                          ? _border.withOpacity(0.3)
                          : _accent.withOpacity(0.4)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined,
                        color: _photos.length >= 10 ? _border : _accent,
                        size: 24),
                      const SizedBox(height: 4),
                      Text('${_photos.length}/10',
                        style: TextStyle(
                          color: _photos.length >= 10 ? _border : _accent,
                          fontSize: 10, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
              ..._photos.asMap().entries.map((e) => Stack(children: [
                Container(
                  width: 80, height: 80,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _border),
                    image: DecorationImage(
                      image: FileImage(e.value), fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  top: 2, right: 10,
                  child: GestureDetector(
                    onTap: () => setState(() => _photos.removeAt(e.key)),
                    child: Container(
                      width: 18, height: 18,
                      decoration: const BoxDecoration(
                          color: _red, shape: BoxShape.circle),
                      child: const Icon(Icons.close,
                          color: Colors.white, size: 12),
                    ),
                  ),
                ),
              ])),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 메모
        _sectionTitle('추가 설명 (선택)'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: _card, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _border)),
          child: TextField(
            controller: _memoCtrl, maxLines: 3,
            style: const TextStyle(color: _textPri, fontSize: 13),
            decoration: InputDecoration(
              hintText: '특이사항, 옵션, 정비이력 등을 자유롭게 입력하세요',
              hintStyle: TextStyle(color: _textSec.withOpacity(0.5), fontSize: 12),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // 전송 버튼
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canSubmit ? _submitSale : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canSubmit ? _green : _border,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: canSubmit ? 4 : 0,
            ),
            child: Text(
              canSubmit ? '딜러에게 판매 신청하기' : '주행거리를 새로 입력해주세요',
              style: TextStyle(
                color: canSubmit ? Colors.white : _textSec,
                fontSize: 15, fontWeight: FontWeight.w800),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ]),
        ),
      ),  // Expanded
    ]);   // Column
  }

  // ── STEP2: 딜러 투찰 목록 ──────────────────────────────────
  Widget _buildDealerBidList() {
    final req = _activeReq;
    if (req == null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('📭', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text('진행중인 판매 신청이 없습니다',
            style: const TextStyle(color: _textSec)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => setState(() => _step = 0),
            style: ElevatedButton.styleFrom(backgroundColor: _accent),
            child: const Text('새로 신청하기',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800)),
          ),
        ]),
      );
    }
    final isMatched = req.status == UsedCarStatus.matched;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // 내 차 요약
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _card, borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border)),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.directions_car_rounded,
                  color: _accent, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(req.carName,
                  style: const TextStyle(
                      color: _textPri, fontSize: 14, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Row(children: [
                  _chip(req.modelYear, _accent),
                  const SizedBox(width: 6),
                  _chip('${_formatNum(req.mileage)}km', _textSec),
                  const SizedBox(width: 6),
                  _chip(req.hasAccident ? '사고 있음' : '무사고',
                      req.hasAccident ? _red : _green),
                ]),
              ],
            )),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isMatched
                    ? _green.withOpacity(0.15)
                    : _accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8)),
              child: Text(
                isMatched ? '🤝 매칭완료' : '📩 ${req.bidCount}건',
                style: TextStyle(
                  color: isMatched ? _green : _accent,
                  fontSize: 11, fontWeight: FontWeight.w800)),
            ),
          ]),
        ),
        const SizedBox(height: 14),

        if (isMatched) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _green.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _green.withOpacity(0.4))),
            child: const Column(children: [
              Text('🎉 거래가 성사되었습니다!',
                style: TextStyle(
                    color: _green, fontSize: 16, fontWeight: FontWeight.w900)),
              SizedBox(height: 4),
              Text('딜러에서 곧 연락드릴 예정입니다.',
                style: TextStyle(color: _textSec, fontSize: 12)),
            ]),
          ),
          const SizedBox(height: 12),
        ],

        Text(
          isMatched ? '딜러 견적 목록 (거래 완료)' : '도착한 딜러 견적 · ${req.bidCount}건',
          style: const TextStyle(
              color: _textSec, fontSize: 12, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),

        ...req.bids.map((bid) => _DealerBidCard(
          request: req, bid: bid,
          onAgree: isMatched ? null : () => _showAgreeDialog(req, bid),
        )),

        if (!isMatched) ...[
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              UsedCarState().saleRequests.clear();
              UsedCarState().notifyListeners();
              setState(() {
                _step = 0;
                _plateCtrl.clear();
                _mileCtrl.clear();
                _plateFound = false;
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _card, borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border)),
              child: const Center(child: Text('새 차량 판매 신청하기',
                style: TextStyle(color: _textSec, fontSize: 13,
                    fontWeight: FontWeight.w600))),
            ),
          ),
        ],
        const SizedBox(height: 20),
      ]),
    );
  }

  // ── 동의 다이얼로그 ──────────────────────────────────────────
  void _showAgreeDialog(UsedCarSaleRequest req, DealerBid bid) {
    _phoneCtrl.clear();
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0D2040), Color(0xFF0A1628)],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _green.withOpacity(0.5), width: 1.5),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: _green.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: _green.withOpacity(0.5))),
              child: const Icon(Icons.handshake_rounded, color: _green, size: 30),
            ),
            const SizedBox(height: 14),
            const Text('딜러 견적 동의',
              style: TextStyle(color: _textPri, fontSize: 18,
                  fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(bid.dealerName,
              style: const TextStyle(color: _accent, fontSize: 14,
                  fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('제안가: ${_formatNum(bid.offerPrice)}만원',
              style: const TextStyle(color: _green, fontSize: 16,
                  fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            const Align(alignment: Alignment.centerLeft,
              child: Text('연락받을 전화번호',
                style: TextStyle(color: _textSec, fontSize: 12))),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: _bg, borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _border)),
              child: TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: _textPri, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: '010-0000-0000',
                  hintStyle: TextStyle(color: _textSec),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.phone_rounded,
                      color: _accent, size: 18),
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _orange.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8)),
              child: const Text(
                '동의하면 해당 딜러에게 연락처가 전달되고\n다른 딜러의 견적은 자동으로 거래종료됩니다.',
                style: TextStyle(color: _orange, fontSize: 11, height: 1.5),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  UsedCarState().matchSaleRequest(
                    req.requestId, bid.bidId,
                    phone: _phoneCtrl.text.trim());
                  setState(() {});
                  _showMatchSuccess(bid);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('동의하고 거래 확정',
                  style: TextStyle(color: Colors.white, fontSize: 15,
                      fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소',
                style: TextStyle(color: _textSec, fontSize: 13)),
            ),
          ]),
        ),
      ),
    );
  }

  void _showMatchSuccess(DealerBid bid) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _card, borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _green.withOpacity(0.5))),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('🎉 거래 성사!',
              style: TextStyle(color: _green, fontSize: 22,
                  fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            Text('${bid.dealerName}\n${_formatNum(bid.offerPrice)}만원 매입 확정',
              textAlign: TextAlign.center,
              style: const TextStyle(color: _textPri, fontSize: 14, height: 1.6)),
            const SizedBox(height: 8),
            const Text('딜러에서 24시간 내 연락드립니다.\n다른 딜러의 견적은 자동으로 거래종료 처리됩니다.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _textSec, fontSize: 11, height: 1.6)),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
                child: const Text('확인',
                  style: TextStyle(color: Colors.white,
                      fontWeight: FontWeight.w800)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ── 헬퍼 ──────────────────────────────────────────────────
  Widget _bullet(String t) => Padding(
    padding: const EdgeInsets.only(top: 5),
    child: Row(children: [
      const Icon(Icons.check_circle_rounded, color: _green, size: 14),
      const SizedBox(width: 6),
      Expanded(child: Text(t,
        style: const TextStyle(color: _textSec, fontSize: 12))),
    ]),
  );

  Widget _sectionTitle(String t) => Text(t,
    style: const TextStyle(
        color: _textPri, fontSize: 13, fontWeight: FontWeight.w700));

  Widget _chip(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6),
      border: Border.all(color: color.withOpacity(0.3))),
    child: Text(text,
      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
  );

  Widget _accidentBtn(bool value, String label) => Expanded(
    child: GestureDetector(
      onTap: () => setState(() => _hasAccident = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: _hasAccident == value
              ? (value ? _red.withOpacity(0.15) : _green.withOpacity(0.12))
              : _card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _hasAccident == value
                ? (value ? _red.withOpacity(0.6) : _green.withOpacity(0.5))
                : _border,
            width: _hasAccident == value ? 1.5 : 1),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(
            value ? Icons.car_crash_rounded : Icons.verified_rounded,
            color: _hasAccident == value
                ? (value ? _red : _green)
                : _textSec,
            size: 16),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(
            color: _hasAccident == value
                ? (value ? _red : _green)
                : _textSec,
            fontSize: 13, fontWeight: FontWeight.w700)),
        ]),
      ),
    ),
  );

  Widget _inputBox({
    required TextEditingController controller,
    required String hint,
    required IconData prefix,
    TextCapitalization caps = TextCapitalization.none,
    void Function(String)? onSubmit,
  }) => Container(
    decoration: BoxDecoration(
      color: _card, borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _border)),
    child: TextField(
      controller: controller,
      textCapitalization: caps,
      onSubmitted: onSubmit,
      style: const TextStyle(color: _textPri, fontSize: 15, letterSpacing: 1.1),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: _textSec.withOpacity(0.5), fontSize: 14),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        prefixIcon: Icon(prefix, color: _accent, size: 20),
      ),
    ),
  );

  @override
  void dispose() {
    _plateCtrl.dispose();
    _ownerCtrl.dispose();
    _mileCtrl.dispose();
    _memoCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }
}

// ═══════════════════════════════════════════════════════════════
// 딜러 투찰 카드
// ═══════════════════════════════════════════════════════════════
class _DealerBidCard extends StatelessWidget {
  final UsedCarSaleRequest request;
  final DealerBid bid;
  final VoidCallback? onAgree;
  const _DealerBidCard(
      {required this.request, required this.bid, this.onAgree});

  @override
  Widget build(BuildContext context) {
    final isClosed  = bid.status == UsedCarStatus.closed;
    final isMatched = bid.status == UsedCarStatus.matched;

    return Opacity(
      opacity: isClosed ? 0.38 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isMatched ? _green.withOpacity(0.06) : _card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isMatched
                ? _green.withOpacity(0.5)
                : isClosed
                    ? _border.withOpacity(0.3)
                    : _border,
            width: isMatched ? 1.5 : 1),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _accent.withOpacity(0.3))),
                child: const Icon(Icons.store_rounded, color: _accent, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(bid.dealerName,
                      style: const TextStyle(
                          color: _textPri, fontSize: 13,
                          fontWeight: FontWeight.w800)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4)),
                      child: Text(bid.dealerBadge,
                        style: const TextStyle(
                            color: _accent, fontSize: 8,
                            fontWeight: FontWeight.w800)),
                    ),
                  ]),
                  const SizedBox(height: 3),
                  Row(children: [
                    const Icon(Icons.star_rounded,
                        color: Color(0xFFFBBF24), size: 12),
                    Text('  ${bid.dealerRating}',
                      style: const TextStyle(color: _textSec, fontSize: 11)),
                    const SizedBox(width: 8),
                    Text(bid.dealerLocation,
                      style: const TextStyle(color: _textSec, fontSize: 11)),
                  ]),
                ],
              )),
              if (isMatched)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _green, borderRadius: BorderRadius.circular(8)),
                  child: const Text('🤝 매칭완료',
                    style: TextStyle(color: Colors.white, fontSize: 9,
                        fontWeight: FontWeight.w800)),
                )
              else if (isClosed)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _border, borderRadius: BorderRadius.circular(8)),
                  child: const Text('거래종료',
                    style: TextStyle(color: _textSec, fontSize: 9,
                        fontWeight: FontWeight.w800)),
                ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMatched ? _green.withOpacity(0.1) : _bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isMatched ? _green.withOpacity(0.3) : _border)),
              child: Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('제안 매입가',
                    style: TextStyle(color: _textSec, fontSize: 11)),
                  const SizedBox(height: 4),
                  Text('${_formatNum(bid.offerPrice)}만원',
                    style: TextStyle(
                      color: isMatched ? _green : _textPri,
                      fontSize: 22, fontWeight: FontWeight.w900)),
                ]),
                const Spacer(),
                Text(_timeAgo(bid.createdAt),
                  style: const TextStyle(color: _textSec, fontSize: 10)),
              ]),
            ),
          ),
          if (bid.memo.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _border)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('💬 ', style: TextStyle(fontSize: 13)),
                    Expanded(child: Text(bid.memo,
                      style: const TextStyle(
                          color: _textSec, fontSize: 11, height: 1.5))),
                  ],
                ),
              ),
            ),
          if (!isClosed && !isMatched && onAgree != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onAgree,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('이 견적에 동의하기',
                    style: TextStyle(color: Colors.white, fontSize: 13,
                        fontWeight: FontWeight.w800)),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 탭2: 중고차 사기 (엔카/차차차 방식 - 정밀 필터링)
// ═══════════════════════════════════════════════════════════════
class _BuyCarTab extends StatefulWidget {
  @override
  State<_BuyCarTab> createState() => _BuyCarTabState();
}

class _BuyCarTabState extends State<_BuyCarTab> {
  // 필터 상태
  String _filterMaker = '전체';
  String _filterModel = '전체 모델';
  RangeValues _yearRange   = const RangeValues(2015, 2024);
  RangeValues _mileRange   = const RangeValues(0, 200000);
  RangeValues _priceRange  = const RangeValues(500, 8000);
  String _sort = '최신순';

  final _sorts = ['최신순', '가격낮은순', '가격높은순', '주행거리순'];

  List<UsedCarListing> get _filtered {
    var list = List<UsedCarListing>.from(UsedCarState().listings);
    // 제조사
    if (_filterMaker != '전체') {
      list = list.where((l) =>
        l.carName.contains(_filterMaker) ||
        (_makerModels[_filterMaker] ?? []).any((m) => l.carName.contains(m))
      ).toList();
    }
    // 모델
    if (_filterModel != '전체 모델' && _filterModel.isNotEmpty) {
      list = list.where((l) => l.carName.contains(_filterModel)).toList();
    }
    // 연식
    list = list.where((l) {
      final y = int.tryParse(l.modelYear.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return y >= _yearRange.start && y <= _yearRange.end;
    }).toList();
    // 주행거리
    list = list.where((l) =>
      l.mileage >= _mileRange.start && l.mileage <= _mileRange.end
    ).toList();
    // 가격
    list = list.where((l) =>
      l.price >= _priceRange.start && l.price <= _priceRange.end
    ).toList();
    // 정렬
    switch (_sort) {
      case '가격낮은순': list.sort((a, b) => a.price.compareTo(b.price)); break;
      case '가격높은순': list.sort((a, b) => b.price.compareTo(a.price)); break;
      case '주행거리순': list.sort((a, b) => a.mileage.compareTo(b.mileage)); break;
      default: list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return list;
  }

  bool get _hasFilter =>
    _filterMaker != '전체' ||
    _filterModel != '전체 모델' ||
    _yearRange != const RangeValues(2015, 2024) ||
    _mileRange != const RangeValues(0, 200000) ||
    _priceRange != const RangeValues(500, 8000);

  void _resetFilters() => setState(() {
    _filterMaker = '전체';
    _filterModel = '전체 모델';
    _yearRange   = const RangeValues(2015, 2024);
    _mileRange   = const RangeValues(0, 200000);
    _priceRange  = const RangeValues(500, 8000);
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: UsedCarState(),
      builder: (context, _) {
        final items = _filtered;
        return Column(children: [
          // ── 필터 바 ──────────────────────────────────────
          Container(
            color: _card,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    _filterBtn(
                      label: _filterMaker == '전체' ? '제조사' : _filterMaker,
                      active: _filterMaker != '전체',
                      icon: Icons.directions_car_outlined,
                      onTap: () => _showMakerSheet(),
                    ),
                    const SizedBox(width: 6),
                    _filterBtn(
                      label: (_filterModel == '전체 모델' || _filterModel.isEmpty)
                          ? '모델'
                          : _filterModel,
                      active: _filterModel != '전체 모델' && _filterModel.isNotEmpty,
                      icon: Icons.category_outlined,
                      onTap: () => _showModelSheet(),
                    ),
                    const SizedBox(width: 6),
                    _filterBtn(
                      label: _yearRange == const RangeValues(2015, 2024)
                          ? '연식'
                          : '${_yearRange.start.toInt()}~${_yearRange.end.toInt()}년',
                      active: _yearRange != const RangeValues(2015, 2024),
                      icon: Icons.calendar_today_outlined,
                      onTap: () => _showYearSheet(),
                    ),
                    const SizedBox(width: 6),
                    _filterBtn(
                      label: _mileRange == const RangeValues(0, 200000)
                          ? '주행거리'
                          : '~${(_mileRange.end / 10000).toInt()}만km',
                      active: _mileRange != const RangeValues(0, 200000),
                      icon: Icons.speed_outlined,
                      onTap: () => _showMileSheet(),
                    ),
                    const SizedBox(width: 6),
                    _filterBtn(
                      label: _priceRange == const RangeValues(500, 8000)
                          ? '가격'
                          : '${_priceRange.start.toInt()}~${_priceRange.end.toInt()}만',
                      active: _priceRange != const RangeValues(500, 8000),
                      icon: Icons.attach_money_outlined,
                      onTap: () => _showPriceSheet(),
                    ),
                    if (_hasFilter) ...[
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: _resetFilters,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 7),
                          decoration: BoxDecoration(
                            color: _red.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _red.withOpacity(0.4))),
                          child: Row(children: [
                            const Icon(Icons.refresh_rounded,
                                color: _red, size: 12),
                            const SizedBox(width: 4),
                            const Text('초기화',
                              style: TextStyle(color: _red, fontSize: 11,
                                  fontWeight: FontWeight.w700)),
                          ]),
                        ),
                      ),
                    ],
                  ]),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: _showSortSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: _bg, borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _border)),
                  child: Row(children: [
                    const Icon(Icons.sort_rounded, color: _textSec, size: 14),
                    const SizedBox(width: 4),
                    Text(_sort,
                      style: const TextStyle(color: _textSec, fontSize: 11)),
                  ]),
                ),
              ),
            ]),
          ),

          // 결과 수
          Container(
            color: _bg,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(children: [
              Text('총 ${items.length}건',
                style: const TextStyle(
                    color: _textSec, fontSize: 12, fontWeight: FontWeight.w700)),
              if (_hasFilter) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(4)),
                  child: const Text('필터 적용됨',
                    style: TextStyle(
                        color: _accent, fontSize: 10,
                        fontWeight: FontWeight.w700)),
                ),
              ],
            ]),
          ),

          // 매물 목록
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Text('🔍', style: TextStyle(fontSize: 40)),
                      const SizedBox(height: 12),
                      const Text('조건에 맞는 매물이 없습니다',
                        style: TextStyle(color: _textSec, fontSize: 14)),
                      const SizedBox(height: 8),
                      if (_hasFilter)
                        TextButton(
                          onPressed: _resetFilters,
                          child: const Text('필터 초기화',
                            style: TextStyle(color: _accent)),
                        ),
                    ]),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: items.length,
                    itemBuilder: (_, i) => _ListingCard(
                      listing: items[i],
                      onTap: () => Navigator.push(context,
                        MaterialPageRoute(
                          builder: (_) =>
                              UsedCarDetailScreen(listing: items[i]),
                        )),
                    ),
                  ),
          ),
        ]);
      },
    );
  }

  Widget _filterBtn({
    required String label,
    required bool active,
    required IconData icon,
    required VoidCallback onTap,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: active ? _accent.withOpacity(0.15) : _bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active ? _accent : _border,
          width: active ? 1.5 : 1),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12,
            color: active ? _accent : _textSec),
        const SizedBox(width: 4),
        Text(label,
          style: TextStyle(
            color: active ? _accent : _textSec,
            fontSize: 11,
            fontWeight: active ? FontWeight.w800 : FontWeight.w500)),
        if (active) ...[
          const SizedBox(width: 4),
          const Icon(Icons.arrow_drop_down, size: 14, color: _accent),
        ],
      ]),
    ),
  );

  // ── 제조사 선택 ────────────────────────────────────────────
  void _showMakerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          width: 40, height: 4,
          decoration: BoxDecoration(
              color: _border, borderRadius: BorderRadius.circular(2))),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text('제조사 선택',
            style: TextStyle(color: _textPri, fontSize: 16,
                fontWeight: FontWeight.w800)),
        ),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: _makerModels.keys.map((maker) {
              final sel = maker == _filterMaker;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _filterMaker = maker;
                    _filterModel = '전체 모델';
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: sel ? _accent.withOpacity(0.12) : _navy,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: sel ? _accent : _border,
                      width: sel ? 1.5 : 1)),
                  child: Row(children: [
                    Text(maker == '전체' ? '전체 제조사' : maker,
                      style: TextStyle(
                        color: sel ? _accent : _textPri,
                        fontSize: 14, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    if (sel)
                      const Icon(Icons.check_rounded,
                          color: _accent, size: 18),
                  ]),
                ),
              );
            }).toList(),
          ),
        ),
      ]),
    );
  }

  // ── 모델 선택 ──────────────────────────────────────────────
  void _showModelSheet() {
    if (_filterMaker == '전체') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('제조사를 먼저 선택해주세요'),
          backgroundColor: _orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    final models = _makerModels[_filterMaker] ?? ['전체 모델'];
    showModalBottomSheet(
      context: context,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          width: 40, height: 4,
          decoration: BoxDecoration(
              color: _border, borderRadius: BorderRadius.circular(2))),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text('$_filterMaker 모델 선택',
            style: const TextStyle(color: _textPri, fontSize: 16,
                fontWeight: FontWeight.w800)),
        ),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: models.map((model) {
              final sel = model == _filterModel;
              return GestureDetector(
                onTap: () {
                  setState(() => _filterModel = model);
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: sel ? _accent.withOpacity(0.12) : _navy,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: sel ? _accent : _border,
                      width: sel ? 1.5 : 1)),
                  child: Row(children: [
                    Text(model,
                      style: TextStyle(
                        color: sel ? _accent : _textPri,
                        fontSize: 14, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    if (sel)
                      const Icon(Icons.check_rounded,
                          color: _accent, size: 18),
                  ]),
                ),
              );
            }).toList(),
          ),
        ),
      ]),
    );
  }

  // ── 연식 범위 ──────────────────────────────────────────────
  void _showYearSheet() {
    RangeValues temp = _yearRange;
    showModalBottomSheet(
      context: context,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSt) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: _border, borderRadius: BorderRadius.circular(2))),
            const Text('연식 선택',
              style: TextStyle(color: _textPri, fontSize: 16,
                  fontWeight: FontWeight.w800)),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('${temp.start.toInt()}년',
                style: const TextStyle(color: _accent, fontSize: 18,
                    fontWeight: FontWeight.w900)),
              const Text('~',
                style: TextStyle(color: _textSec, fontSize: 16)),
              Text('${temp.end.toInt()}년',
                style: const TextStyle(color: _accent, fontSize: 18,
                    fontWeight: FontWeight.w900)),
            ]),
            const SizedBox(height: 8),
            SliderTheme(
              data: SliderTheme.of(ctx).copyWith(
                activeTrackColor: _accent,
                thumbColor: _accent,
                inactiveTrackColor: _border,
                overlayColor: _accent.withOpacity(0.2),
              ),
              child: RangeSlider(
                values: temp,
                min: 2010, max: 2024, divisions: 14,
                onChanged: (v) => setSt(() => temp = v),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() => _yearRange = temp);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
                child: const Text('적용',
                  style: TextStyle(color: Colors.black,
                      fontWeight: FontWeight.w800)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ── 주행거리 범위 ──────────────────────────────────────────
  void _showMileSheet() {
    RangeValues temp = _mileRange;
    showModalBottomSheet(
      context: context,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSt) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: _border, borderRadius: BorderRadius.circular(2))),
            const Text('주행거리 선택',
              style: TextStyle(color: _textPri, fontSize: 16,
                  fontWeight: FontWeight.w800)),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('${(temp.start / 10000).toStringAsFixed(0)}만km',
                style: const TextStyle(color: _accent, fontSize: 18,
                    fontWeight: FontWeight.w900)),
              const Text('~',
                style: TextStyle(color: _textSec, fontSize: 16)),
              Text('${(temp.end / 10000).toStringAsFixed(0)}만km',
                style: const TextStyle(color: _accent, fontSize: 18,
                    fontWeight: FontWeight.w900)),
            ]),
            const SizedBox(height: 8),
            SliderTheme(
              data: SliderTheme.of(ctx).copyWith(
                activeTrackColor: _green,
                thumbColor: _green,
                inactiveTrackColor: _border,
                overlayColor: _green.withOpacity(0.2),
              ),
              child: RangeSlider(
                values: temp,
                min: 0, max: 200000, divisions: 20,
                onChanged: (v) => setSt(() => temp = v),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() => _mileRange = temp);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
                child: const Text('적용',
                  style: TextStyle(color: Colors.white,
                      fontWeight: FontWeight.w800)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ── 가격 범위 ──────────────────────────────────────────────
  void _showPriceSheet() {
    RangeValues temp = _priceRange;
    showModalBottomSheet(
      context: context,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSt) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: _border, borderRadius: BorderRadius.circular(2))),
            const Text('가격 선택',
              style: TextStyle(color: _textPri, fontSize: 16,
                  fontWeight: FontWeight.w800)),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('${_formatNum(temp.start.toInt())}만원',
                style: const TextStyle(color: _orange, fontSize: 18,
                    fontWeight: FontWeight.w900)),
              const Text('~',
                style: TextStyle(color: _textSec, fontSize: 16)),
              Text('${_formatNum(temp.end.toInt())}만원',
                style: const TextStyle(color: _orange, fontSize: 18,
                    fontWeight: FontWeight.w900)),
            ]),
            const SizedBox(height: 8),
            SliderTheme(
              data: SliderTheme.of(ctx).copyWith(
                activeTrackColor: _orange,
                thumbColor: _orange,
                inactiveTrackColor: _border,
                overlayColor: _orange.withOpacity(0.2),
              ),
              child: RangeSlider(
                values: temp,
                min: 500, max: 8000, divisions: 30,
                onChanged: (v) => setSt(() => temp = v),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() => _priceRange = temp);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _orange,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
                child: const Text('적용',
                  style: TextStyle(color: Colors.white,
                      fontWeight: FontWeight.w800)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ── 정렬 ──────────────────────────────────────────────────
  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Column(mainAxisSize: MainAxisSize.min, children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('정렬 기준',
            style: TextStyle(color: _textPri, fontSize: 15,
                fontWeight: FontWeight.w800)),
        ),
        ..._sorts.map((s) => ListTile(
          title: Text(s, style: TextStyle(
            color: s == _sort ? _accent : _textPri,
            fontWeight: s == _sort ? FontWeight.w800 : FontWeight.w400)),
          trailing: s == _sort
              ? const Icon(Icons.check_rounded, color: _accent) : null,
          onTap: () {
            setState(() => _sort = s);
            Navigator.pop(context);
          },
        )),
        const SizedBox(height: 12),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 매물 카드
// ═══════════════════════════════════════════════════════════════
class _ListingCard extends StatelessWidget {
  final UsedCarListing listing;
  final VoidCallback onTap;
  const _ListingCard({required this.listing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _card, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // 썸네일
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(14),
              bottomLeft: Radius.circular(14)),
            child: Stack(children: [
              Image.network(listing.photoUrls.first,
                width: 120, height: 105, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 120, height: 105, color: _navy,
                  child: const Icon(Icons.directions_car,
                      color: _textSec, size: 32))),
              Positioned(
                top: 6, left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: listing.sellerType == 'dealer'
                        ? _accent.withOpacity(0.85)
                        : _purple.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(4)),
                  child: Text(
                    listing.sellerType == 'dealer' ? '딜러' : '직거래',
                    style: const TextStyle(color: Colors.white,
                        fontSize: 9, fontWeight: FontWeight.w800)),
                ),
              ),
            ]),
          ),
          // 정보
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(listing.title,
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _textPri, fontSize: 12,
                        fontWeight: FontWeight.w700, height: 1.4)),
                  const SizedBox(height: 5),
                  Row(children: [
                    Text('${_formatNum(listing.mileage)}km',
                      style: const TextStyle(color: _textSec, fontSize: 11)),
                    const Text(' · ',
                      style: TextStyle(color: _border)),
                    Text(listing.fuel,
                      style: const TextStyle(color: _textSec, fontSize: 11)),
                    const Text(' · ',
                      style: TextStyle(color: _border)),
                    Text(listing.region,
                      style: const TextStyle(color: _textSec, fontSize: 11)),
                  ]),
                  const SizedBox(height: 4),
                  if (!listing.hasAccident)
                    Row(children: [
                      const Icon(Icons.verified_rounded,
                          color: _green, size: 12),
                      const SizedBox(width: 3),
                      const Text('무사고',
                        style: TextStyle(color: _green, fontSize: 10,
                            fontWeight: FontWeight.w700)),
                    ]),
                  const SizedBox(height: 6),
                  Row(children: [
                    Text('${_formatNum(listing.price)}만원',
                      style: const TextStyle(color: _textPri, fontSize: 16,
                          fontWeight: FontWeight.w900)),
                    const Spacer(),
                    AnimatedBuilder(
                      animation: UsedCarState(),
                      builder: (_, __) => GestureDetector(
                        onTap: () =>
                            UsedCarState().toggleFavorite(listing.listingId),
                        child: Icon(
                          listing.isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: listing.isFavorite ? _red : _textSec,
                          size: 20),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 중고차 매물 상세
// ═══════════════════════════════════════════════════════════════
class UsedCarDetailScreen extends StatefulWidget {
  final UsedCarListing listing;
  const UsedCarDetailScreen({super.key, required this.listing});
  @override
  State<UsedCarDetailScreen> createState() => _UsedCarDetailScreenState();
}

class _UsedCarDetailScreenState extends State<UsedCarDetailScreen> {
  int _photoIndex = 0;
  final _pageCtrl = PageController();

  @override
  void dispose() { _pageCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final l = widget.listing;
    final top = MediaQuery.of(context).padding.top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: _bg,
        body: Stack(children: [
          CustomScrollView(slivers: [
            // 사진 슬라이더
            SliverToBoxAdapter(
              child: SizedBox(
                height: 260,
                child: Stack(children: [
                  PageView.builder(
                    controller: _pageCtrl,
                    itemCount: l.photoUrls.length,
                    onPageChanged: (i) => setState(() => _photoIndex = i),
                    itemBuilder: (_, i) => Image.network(l.photoUrls[i],
                      fit: BoxFit.cover, width: double.infinity,
                      errorBuilder: (_, __, ___) => Container(
                        color: _navy,
                        child: const Icon(Icons.directions_car,
                            color: _textSec, size: 60))),
                  ),
                  Positioned(bottom: 12, left: 0, right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: l.photoUrls.asMap().entries.map((e) =>
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: e.key == _photoIndex ? 16 : 6, height: 6,
                          decoration: BoxDecoration(
                            color: e.key == _photoIndex
                                ? Colors.white
                                : Colors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(3))),
                      ).toList(),
                    ),
                  ),
                  Positioned(
                    top: 12 + top, right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12)),
                      child: Text('${_photoIndex + 1}/${l.photoUrls.length}',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 11)),
                    ),
                  ),
                  Positioned(
                    top: top + 4, left: 4,
                    child: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 16),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ]),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Text(l.title,
                          style: const TextStyle(color: _textPri,
                              fontSize: 16, fontWeight: FontWeight.w900,
                              height: 1.4))),
                        AnimatedBuilder(
                          animation: UsedCarState(),
                          builder: (_, __) => GestureDetector(
                            onTap: () =>
                                UsedCarState().toggleFavorite(l.listingId),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8, top: 2),
                              child: Icon(
                                l.isFavorite
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: l.isFavorite ? _red : _textSec,
                                size: 24),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(children: [
                      _tagChip(l.modelYear, _accent),
                      const SizedBox(width: 6),
                      _tagChip(l.region, _textSec),
                      const SizedBox(width: 6),
                      _tagChip(
                        l.sellerType == 'dealer' ? '딜러' : '직거래',
                        l.sellerType == 'dealer' ? _accent : _purple),
                    ]),
                    const SizedBox(height: 12),
                    Text('${_formatNum(l.price)}만원',
                      style: const TextStyle(color: _textPri, fontSize: 26,
                          fontWeight: FontWeight.w900)),
                    const SizedBox(height: 16),
                    // 차량 제원
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _card, borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _border)),
                      child: Column(children: [
                        _specRow('연식', l.modelYear),
                        _div(),
                        _specRow('주행거리', '${_formatNum(l.mileage)}km'),
                        _div(),
                        _specRow('연료', l.fuel),
                        _div(),
                        _specRow('변속기', l.transmission),
                        _div(),
                        _specRow('색상', l.color),
                        _div(),
                        _specRow('사고유무',
                          l.hasAccident ? '사고 있음' : '무사고',
                          vc: l.hasAccident ? _red : _green),
                        _div(),
                        _specRow('지역', l.region),
                      ]),
                    ),
                    const SizedBox(height: 14),
                    // 설명
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _card, borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _border)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('판매자 설명',
                            style: TextStyle(color: _textSec, fontSize: 12,
                                fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          Text(l.desc, style: const TextStyle(
                              color: _textPri, fontSize: 13, height: 1.7)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    // 판매자
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _card, borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _border)),
                      child: Row(children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: _accent.withOpacity(0.12),
                            shape: BoxShape.circle),
                          child: const Icon(Icons.person_rounded,
                              color: _accent, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.sellerName,
                              style: const TextStyle(color: _textPri,
                                  fontSize: 13, fontWeight: FontWeight.w700)),
                            Text(
                              l.sellerType == 'dealer'
                                  ? 'KAA 인증 딜러 · 정식 등록 매매상사'
                                  : '개인 판매자',
                              style: const TextStyle(
                                  color: _textSec, fontSize: 11)),
                          ],
                        )),
                        if (l.sellerType == 'dealer')
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _accent.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6)),
                            child: const Text('KAA 인증',
                              style: TextStyle(color: _accent, fontSize: 10,
                                  fontWeight: FontWeight.w800)),
                          ),
                      ]),
                    ),
                    const SizedBox(height: 90),
                  ],
                ),
              ),
            ),
          ]),

          // 하단 고정 버튼
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 12, 16,
                  MediaQuery.of(context).padding.bottom + 12),
              decoration: BoxDecoration(
                color: _card,
                border: Border(top: BorderSide(color: _border))),
              child: Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                    label: const Text('1:1 문의'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _accent,
                      side: BorderSide(color: _accent.withOpacity(0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('${l.sellerName}에게 1:1 문의를 보냈습니다.'),
                        backgroundColor: _accent));
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.phone_rounded, size: 16),
                    label: const Text('전화하기'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('📞 ${l.sellerPhone}'),
                        backgroundColor: _green));
                    },
                  ),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _tagChip(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6),
      border: Border.all(color: color.withOpacity(0.3))),
    child: Text(text, style: TextStyle(color: color, fontSize: 10,
        fontWeight: FontWeight.w700)),
  );

  Widget _specRow(String label, String value, {Color? vc}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(children: [
      SizedBox(width: 80, child: Text(label,
        style: const TextStyle(color: _textSec, fontSize: 12))),
      Expanded(child: Text(value, style: TextStyle(
        color: vc ?? _textPri, fontSize: 12, fontWeight: FontWeight.w700))),
    ]),
  );

  Widget _div() => Divider(color: _border.withOpacity(0.5), height: 1);
}

// ═══════════════════════════════════════════════════════════════
// 하단 고정: 가까운 중고차 점포 가로 스크롤
// ═══════════════════════════════════════════════════════════════
class _NearbyDealerBar extends StatelessWidget {
  const _NearbyDealerBar();

  // 거리순(distKm) 정렬된 주변 점포 목록
  static final List<Map<String, dynamic>> _dealers = (() {
    final raw = [
      {'id': 5, 'name': '범어 중고차 매매단지', 'dist': '1.9km', 'distKm': 1.9, 'rating': 4.5,
        'badge': '우수딜러', 'count': 8,
        'image': 'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?w=200&q=80'},
      {'id': 4, 'name': 'KAA 인증 중고차센터', 'dist': '2.1km', 'distKm': 2.1, 'rating': 4.6,
        'badge': 'KAA인증', 'count': 12,
        'image': 'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?w=200&q=80'},
      {'id': 7, 'name': '수성 프리미엄 오토', 'dist': '2.7km', 'distKm': 2.7, 'rating': 4.4,
        'badge': 'KAA인증', 'count': 6,
        'image': 'https://images.unsplash.com/photo-1580273916550-e323be2ae537?w=200&q=80'},
      {'id': 6, 'name': '황금동 오토플라자', 'dist': '3.2km', 'distKm': 3.2, 'rating': 4.3,
        'badge': '인기딜러', 'count': 15,
        'image': 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=200&q=80'},
      {'id': 8, 'name': '동대구 중고차 타운', 'dist': '4.1km', 'distKm': 4.1, 'rating': 4.2,
        'badge': '신규', 'count': 20,
        'image': 'https://images.unsplash.com/photo-1617531653332-bd46c16f4d68?w=200&q=80'},
    ];
    raw.sort((a, b) =>
        (a['distKm'] as double).compareTo(b['distKm'] as double));
    return raw;
  })();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _card,
        border: Border(top: BorderSide(color: _border))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
          child: Row(children: [
            const Icon(Icons.location_on_rounded, color: _accent, size: 14),
            const SizedBox(width: 4),
            const Text('내 주변 중고차 점포',
              style: TextStyle(color: _textSec, fontSize: 11,
                  fontWeight: FontWeight.w700)),
            const Spacer(),
            Text('거리순 · 대구 수성구',
              style: TextStyle(
                  color: _textSec.withOpacity(0.6), fontSize: 10)),
          ]),
        ),
        SizedBox(
          height: 92,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            itemCount: _dealers.length,
            itemBuilder: (context, i) {
              final d = _dealers[i];
              return GestureDetector(
                onTap: () => _showDealerSheet(context, d),
                child: Container(
                  width: 130,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: _navy, borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _border)),
                  child: Row(children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12)),
                      child: Image.network(d['image'] as String,
                        width: 50, height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 50, color: _border,
                          child: const Icon(Icons.store,
                              color: _textSec, size: 18))),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(d['name'] as String,
                              maxLines: 2, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: _textPri,
                                  fontSize: 10, fontWeight: FontWeight.w700,
                                  height: 1.3)),
                            const SizedBox(height: 3),
                            Text('${d['dist']}  ⭐${d['rating']}',
                              style: const TextStyle(
                                  color: _textSec, fontSize: 9)),
                            const SizedBox(height: 3),
                            Text('매물 ${d['count']}건',
                              style: const TextStyle(color: _accent,
                                  fontSize: 9, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }

  void _showDealerSheet(BuildContext context, Map<String, dynamic> dealer) {
    final storeListings = UsedCarState().listings
        .where((l) => l.storeId == dealer['id'])
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, ctrl) => Column(children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 40, height: 4,
            decoration: BoxDecoration(
                color: _border, borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Row(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(dealer['image'] as String,
                  width: 56, height: 56, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 56, height: 56, color: _border,
                    child: const Icon(Icons.store, color: _textSec))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dealer['name'] as String,
                    style: const TextStyle(color: _textPri, fontSize: 15,
                        fontWeight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4)),
                      child: Text(dealer['badge'] as String,
                        style: const TextStyle(color: _accent, fontSize: 9,
                            fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(width: 6),
                    Text('${dealer['dist']}  ⭐${dealer['rating']}',
                      style: const TextStyle(color: _textSec, fontSize: 11)),
                  ]),
                ],
              )),
              Text('매물 ${dealer['count']}건',
                style: const TextStyle(color: _accent, fontSize: 13,
                    fontWeight: FontWeight.w800)),
            ]),
          ),
          Divider(color: _border, height: 1),
          Expanded(
            child: storeListings.isEmpty
                ? Center(child: Text('이 점포의 매물 정보가 없습니다',
                    style: TextStyle(color: _textSec)))
                : ListView.builder(
                    controller: ctrl,
                    padding: const EdgeInsets.all(14),
                    itemCount: storeListings.length,
                    itemBuilder: (ctx, i) => _ListingCard(
                      listing: storeListings[i],
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(ctx, MaterialPageRoute(
                          builder: (_) => UsedCarDetailScreen(
                              listing: storeListings[i])));
                      },
                    ),
                  ),
          ),
        ]),
      ),
    );
  }
}
