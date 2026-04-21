import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_state.dart';

// ─── 색상 상수 (모인카 다크 테마 유지) ─────────────────────────────────
const Color _bg       = Color(0xFF020810);
const Color _card     = Color(0xFF0D1B2A);
const Color _navy     = Color(0xFF0A1628);
const Color _accent   = Color(0xFF4FC3F7);
const Color _green    = Color(0xFF10B981);
const Color _orange   = Color(0xFFFF6B35);
const Color _purple   = Color(0xFF8B5CF6);
const Color _red      = Color(0xFFE53935);
const Color _border   = Color(0xFF1E3A5F);
const Color _textPri  = Colors.white;
const Color _textSec  = Color(0xFFB0BEC5);

// ─── 차량번호 → 차량 정보 더미 DB ────────────────────────────────────────
const Map<String, Map<String, String>> _plateDB = {
  '123가4567': {'model': '현대 그랜저 IG 3.0', 'year': '2019년식', 'regDate': '2019-03-15', 'mktMin': '2100', 'mktMax': '2600'},
  '456나7890': {'model': 'BMW 320i (G20)',     'year': '2020년식', 'regDate': '2020-07-22', 'mktMin': '3000', 'mktMax': '3600'},
  '789다1234': {'model': '기아 K5 DL3 2.0',   'year': '2021년식', 'regDate': '2021-01-08', 'mktMin': '1900', 'mktMax': '2400'},
  '111라2222': {'model': '현대 아반떼 CN7',    'year': '2022년식', 'regDate': '2022-05-30', 'mktMin': '1600', 'mktMax': '2100'},
  '333마4444': {'model': '테슬라 모델3 LR',    'year': '2023년식', 'regDate': '2023-02-14', 'mktMin': '4200', 'mktMax': '5000'},
  '555바6666': {'model': '벤츠 E220d W213',    'year': '2022년식', 'regDate': '2022-11-01', 'mktMin': '5200', 'mktMax': '6100'},
};

// ============================================================
// 중고차 메인 화면 (2탭 + 하단 점포)
// ============================================================
class UsedCarMainScreen extends StatefulWidget {
  final int initialTab; // 0=내차팔기, 1=중고차사기
  const UsedCarMainScreen({super.key, this.initialTab = 0});
  @override
  State<UsedCarMainScreen> createState() => _UsedCarMainScreenState();
}

class _UsedCarMainScreenState extends State<UsedCarMainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 2, vsync: this, initialIndex: widget.initialTab);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: _card,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _bg,
        body: Column(
          children: [
            // ── AppBar ──────────────────────────────────────────
            Container(
              color: _card,
              padding: EdgeInsets.fromLTRB(4, topPad + 4, 16, 0),
              child: Column(
                children: [
                  Row(
                    children: [
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
                              fontWeight: FontWeight.w800,
                            )),
                        ),
                      ),
                      // 우측 공간 균형
                      const SizedBox(width: 48),
                    ],
                  ),
                  // ── 2탭 슬라이더 ──
                  TabBar(
                    controller: _tabController,
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
                ],
              ),
            ),

            // ── 탭 콘텐츠 ──────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _SellMyCarTab(),
                  _UsedCarListingsTab(),
                ],
              ),
            ),

            // ── 하단 가까운 중고차 점포 ──────────────────────────
            _NearbyDealerBar(),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 탭1: 내 차 팔기 (헤이딜러 역경매)
// ============================================================
class _SellMyCarTab extends StatefulWidget {
  @override
  State<_SellMyCarTab> createState() => _SellMyCarTabState();
}

class _SellMyCarTabState extends State<_SellMyCarTab> {
  // 단계: 0=번호입력, 1=상세입력, 2=딜러투찰 목록
  int _step = 0;

  final _plateCtrl  = TextEditingController();
  final _mileCtrl   = TextEditingController();
  final _memoCtrl   = TextEditingController();
  final _phoneCtrl  = TextEditingController(); // 동의 팝업용

  bool _plateLoading = false;
  bool _plateFound   = false;
  String? _foundModel;
  String? _foundYear;
  String? _foundRegDate;
  String? _foundMaketMin;
  String? _foundMarketMax;

  bool _hasAccident = false;
  List<File> _photos = [];
  final _picker = ImagePicker();

  // 주행거리: 저장값과 달라야 전송 버튼 활성화
  String _kmSaved = '';
  bool get _kmChanged =>
      _mileCtrl.text.trim().isNotEmpty &&
      _mileCtrl.text.trim() != _kmSaved;

  // 현재 진행중인 판매 요청
  UsedCarSaleRequest? get _activeReq =>
      UsedCarState().saleRequests.isNotEmpty
          ? UsedCarState().saleRequests.first
          : null;

  static const _kPlate = 'uc_plate';
  static const _kKm    = 'uc_km';

  @override
  void initState() {
    super.initState();
    _loadSaved();
    _mileCtrl.addListener(() => setState(() {}));
    // 이미 진행중인 요청 있으면 바로 딜러 목록으로
    if (UsedCarState().saleRequests.isNotEmpty &&
        UsedCarState().saleRequests.first.status == UsedCarStatus.bidding) {
      _step = 2;
    }
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final plate = prefs.getString(_kPlate) ?? '';
    final km    = prefs.getString(_kKm) ?? '';
    setState(() {
      _plateCtrl.text = plate;
      _mileCtrl.text  = km;
      _kmSaved        = km;
    });
  }

  Future<void> _savePref() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPlate, _plateCtrl.text);
    await prefs.setString(_kKm, _mileCtrl.text);
  }

  // ── 차량번호 조회 ──
  Future<void> _lookupPlate() async {
    final plate = _plateCtrl.text.trim().replaceAll(' ', '');
    if (plate.isEmpty) return;
    setState(() => _plateLoading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    final info = _plateDB[plate];
    setState(() {
      _plateLoading = false;
      if (info != null) {
        _plateFound     = true;
        _foundModel      = info['model'];
        _foundYear       = info['year'];
        _foundRegDate    = info['regDate'];
        _foundMaketMin   = info['mktMin'];
        _foundMarketMax  = info['mktMax'];
        _step = 1;
      } else {
        // 번호 미등록 → 더미로 처리
        _plateFound     = true;
        _foundModel      = '차량 정보 수동 입력';
        _foundYear       = '연식 미확인';
        _foundRegDate    = '등록일 미확인';
        _foundMaketMin   = null;
        _foundMarketMax  = null;
        _step = 1;
      }
    });
  }

  // ── 사진 선택 ──
  Future<void> _pickPhoto() async {
    if (_photos.length >= 10) return;
    final xf = await _picker.pickImage(
        source: ImageSource.gallery, imageQuality: 60);
    if (xf != null) setState(() => _photos.add(File(xf.path)));
  }

  // ── 판매 신청 전송 ──
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
              _mileCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ??
          0,
      hasAccident: _hasAccident,
      memo: _memoCtrl.text.trim(),
      photoUrls: _photos.map((f) => f.path).toList(),
      createdAt: DateTime.now(),
      status: UsedCarStatus.bidding,
      bids: [
        DealerBid(
          bidId: 'NEW-BID-001',
          dealerName: 'KAA 인증 중고차센터',
          dealerBadge: 'KAA인증',
          dealerPhone: '053-456-7890',
          dealerRating: 4.8,
          dealerLocation: '대구 수성구 · 2.1km',
          offerPrice: 2450,
          memo: '사진 검토 완료. 실물 확인 후 최종 가격 확정 가능합니다.',
          createdAt: DateTime.now(),
          isRead: false,
        ),
        DealerBid(
          bidId: 'NEW-BID-002',
          dealerName: '범어 중고차 매매단지',
          dealerBadge: '우수딜러',
          dealerPhone: '053-567-8901',
          dealerRating: 4.5,
          dealerLocation: '대구 수성구 · 1.9km',
          offerPrice: 2320,
          memo: '즉시 현금 매입 가능. 당일 처리 원하시면 연락 주세요.',
          createdAt: DateTime.now(),
          isRead: false,
        ),
      ],
    );
    UsedCarState().addSaleRequest(req);
    setState(() => _step = 2);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ 판매 신청 완료! 딜러들이 견적을 보내고 있습니다.'),
          backgroundColor: _green,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: UsedCarState(),
      builder: (context, _) {
        if (_step == 2) return _buildDealerBidList();
        if (_step == 1) return _buildDetailForm();
        return _buildPlateInput();
      },
    );
  }

  // ── STEP0: 차량번호 입력 ──────────────────────────────────
  Widget _buildPlateInput() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 카드
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_accent.withOpacity(0.15), _green.withOpacity(0.08)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _accent.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _accent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.sell_rounded, color: _accent, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('내 차 팔기',
                        style: GoogleFonts.notoSansKr(
                          color: _textPri, fontSize: 18, fontWeight: FontWeight.w900)),
                      Text('헤이딜러 방식 역경매',
                        style: GoogleFonts.notoSansKr(
                          color: _accent, fontSize: 12)),
                    ],
                  )),
                ]),
                const SizedBox(height: 14),
                _bulletPoint('차량번호만 입력하면 자동으로 차량 정보 조회'),
                _bulletPoint('가까운 딜러들이 경쟁적으로 견적을 제안'),
                _bulletPoint('마음에 드는 견적에 동의하면 거래 성사'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('차량번호 입력',
            style: GoogleFonts.notoSansKr(
              color: _textPri, fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _border),
                ),
                child: TextField(
                  controller: _plateCtrl,
                  style: const TextStyle(color: _textPri, fontSize: 15, letterSpacing: 1.2),
                  decoration: InputDecoration(
                    hintText: '예) 123가 4567',
                    hintStyle: TextStyle(color: _textSec.withOpacity(0.5), fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    prefixIcon: const Icon(Icons.directions_car_outlined, color: _accent, size: 20),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  onSubmitted: (_) => _lookupPlate(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _plateLoading ? null : _lookupPlate,
              child: Container(
                width: 60, height: 52,
                decoration: BoxDecoration(
                  color: _accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: _plateLoading
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.black, strokeWidth: 2.5))
                      : const Icon(Icons.search_rounded, color: Colors.black, size: 22),
                ),
              ),
            ),
          ]),
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
                '차량번호 조회 후 연식/최초등록일이 자동으로 입력됩니다',
                style: TextStyle(color: _orange.withOpacity(0.9), fontSize: 11, height: 1.4),
              )),
            ]),
          ),

          const SizedBox(height: 24),
          const Divider(color: _border),
          const SizedBox(height: 16),

          // 직거래 매물 등록 섹션
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_purple.withOpacity(0.15), _purple.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _purple.withOpacity(0.3)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _purple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.storefront_rounded, color: _purple, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('직거래 매물 등록하기',
                      style: GoogleFonts.notoSansKr(
                        color: _textPri, fontSize: 15, fontWeight: FontWeight.w800)),
                    Text('협회 인증 배지 · 매물 바로 노출',
                      style: GoogleFonts.notoSansKr(
                        color: _purple, fontSize: 11)),
                  ],
                )),
              ]),
              const SizedBox(height: 12),
              _bulletPoint('내 차 정보(시세 기반)를 직거래 매물로 등록'),
              _bulletPoint('[협회 인증] 배지 즉시 부여'),
              _bulletPoint('개인간 거래: 1:1 문의 → 전화번호 교환'),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showRegisterIndividualListing(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _purple,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('직거래 매물 등록',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  void _showRegisterIndividualListing(BuildContext context) {
    final plateData = _plateDB[_plateCtrl.text.trim().replaceAll(' ', '')];
    if (plateData == null && _plateCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('차량번호를 입력하거나 조회 후 등록해 주세요'),
          backgroundColor: _orange),
      );
      return;
    }

    final model = plateData?['model'] ?? '내 차량';
    final year = plateData?['year'] ?? '연식 미상';
    final mktMin = int.tryParse(plateData?['mktMin'] ?? '0') ?? 0;
    final mktMax = int.tryParse(plateData?['mktMax'] ?? '0') ?? 0;

    final newListing = UsedCarListing(
      listingId: 'MY-${DateTime.now().millisecondsSinceEpoch}',
      title: '$year $model (직거래)',
      carName: model,
      modelYear: year,
      mileage: int.tryParse(_mileCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
      price: mktMin > 0 ? ((mktMin + mktMax) ~/ 2) : 1500,
      fuel: '가솔린',
      transmission: '자동',
      color: '기타',
      hasAccident: _hasAccident,
      region: '대구 수성구',
      sellerName: '나',
      sellerPhone: '010-0000-0000',
      sellerType: 'individual',
      photoUrls: _photos.isNotEmpty
          ? _photos.map((f) => f.path).toList()
          : ['https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=600&q=80'],
      desc: _memoCtrl.text.trim().isEmpty
          ? '직거래 매물입니다. 협회 인증 완료.'
          : _memoCtrl.text.trim(),
      createdAt: DateTime.now(),
      isCertified: true, // 협회 인증 즉시 부여
    );

    UsedCarState().addListing(newListing);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ 협회 인증 매물로 등록되었습니다! [중고차 사기] 탭에서 확인하세요.'),
        backgroundColor: _green,
        duration: Duration(seconds: 4),
      ),
    );
  }

  // ── STEP1: 상세 입력 폼 ──────────────────────────────────
  Widget _buildDetailForm() {
    final canSubmit = _kmChanged && _plateFound;
    final minP = int.tryParse(_foundMaketMin ?? '0') ?? 0;
    final maxP = int.tryParse(_foundMarketMax ?? '0') ?? 0;

    // ── 상단 고정 InfoBar (스크롤해도 항상 표시) ──────────
    final infoBar = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D2A1E),
        border: Border(bottom: BorderSide(color: _green.withOpacity(0.35))),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.check_circle_outline, color: _green, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_foundModel ?? '',
              style: const TextStyle(color: _textPri, fontSize: 14, fontWeight: FontWeight.w900)),
            const SizedBox(height: 3),
            Row(children: [
              _infoChip(_foundYear ?? '', _accent),
              const SizedBox(width: 6),
              _infoChip('최초등록 ${_foundRegDate ?? ''}', _green),
            ]),
          ])),
          GestureDetector(
            onTap: () => setState(() { _step = 0; _plateFound = false; }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: _border, borderRadius: BorderRadius.circular(7)),
              child: const Text('재조회', style: TextStyle(color: _textSec, fontSize: 11)),
            ),
          ),
        ]),
        if (minP > 0) ...[
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.trending_up_rounded, color: _accent, size: 14),
            const SizedBox(width: 6),
            Text('현재 시세  ',
              style: const TextStyle(color: _textSec, fontSize: 11)),
            Text('${_formatNum(minP)}만원 ~ ${_formatNum(maxP)}만원',
              style: const TextStyle(color: _accent, fontSize: 14, fontWeight: FontWeight.w900)),
          ]),
        ],
      ]),
    );

    return Column(children: [
      infoBar,
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // 주행거리 (필수 - 새로 입력해야 활성화)
          _sectionTitle('주행거리 * (반드시 새로 입력)'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _kmChanged ? _green.withOpacity(0.6) : _border,
                width: _kmChanged ? 1.5 : 1,
              ),
            ),
            child: TextField(
              controller: _mileCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: _textPri, fontSize: 15),
              decoration: InputDecoration(
                hintText: '현재 주행거리 입력 (예: 72000)',
                hintStyle: TextStyle(color: _textSec.withOpacity(0.5)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                suffixText: 'km',
                suffixStyle: const TextStyle(color: _textSec, fontSize: 13),
                prefixIcon: Icon(
                  Icons.speed_rounded,
                  color: _kmChanged ? _green : _textSec,
                  size: 20,
                ),
              ),
            ),
          ),
          if (_kmSaved.isNotEmpty && !_kmChanged) ...[
            const SizedBox(height: 6),
            Text('이전 저장값: ${_kmSaved}km · 반드시 현재 거리로 새로 입력해 주세요',
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
                            : _accent.withOpacity(0.4),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.add_photo_alternate_outlined,
                        color: _photos.length >= 10 ? _border : _accent, size: 24),
                      const SizedBox(height: 4),
                      Text('${_photos.length}/10',
                        style: TextStyle(
                          color: _photos.length >= 10 ? _border : _accent,
                          fontSize: 10, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ),
                ..._photos.asMap().entries.map((entry) => Stack(
                  children: [
                    Container(
                      width: 80, height: 80,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _border),
                        image: DecorationImage(
                          image: FileImage(entry.value),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 2, right: 10,
                      child: GestureDetector(
                        onTap: () => setState(() => _photos.removeAt(entry.key)),
                        child: Container(
                          width: 18, height: 18,
                          decoration: const BoxDecoration(
                            color: _red, shape: BoxShape.circle),
                          child: const Icon(Icons.close, color: Colors.white, size: 12),
                        ),
                      ),
                    ),
                  ],
                )),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 메모
          _sectionTitle('추가 설명 (선택)'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _border),
            ),
            child: TextField(
              controller: _memoCtrl,
              maxLines: 3,
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
                canSubmit ? '🚀  딜러에게 판매 신청하기' : '주행거리를 새로 입력해 주세요',
                style: TextStyle(
                  color: canSubmit ? Colors.white : _textSec,
                  fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(child: Text('신청 후 가까운 딜러들이 견적을 보내드립니다',
            style: TextStyle(color: _textSec.withOpacity(0.7), fontSize: 11))),
          const SizedBox(height: 20),
        ],
          ),
        ),
      ),
    ]);
  }

  // ── STEP2: 딜러 투찰 목록 ────────────────────────────────
  Widget _buildDealerBidList() {
    final req = _activeReq ?? UsedCarState().saleRequests.first;
    final isMatched = req.status == UsedCarStatus.matched;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 내 차 정보 요약
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _border),
            ),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.directions_car_rounded, color: _accent, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(req.carName,
                    style: const TextStyle(color: _textPri, fontSize: 14, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Row(children: [
                    _infoChip(req.modelYear, _accent),
                    const SizedBox(width: 6),
                    _infoChip('${_formatNum(req.mileage)}km', _textSec),
                    const SizedBox(width: 6),
                    if (!req.hasAccident)
                      _infoChip('무사고', _green)
                    else
                      _infoChip('사고 있음', _red),
                  ]),
                ],
              )),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isMatched ? _green.withOpacity(0.15) : _accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isMatched ? '🤝 매칭완료' : '📩 ${req.bidCount}건',
                  style: TextStyle(
                    color: isMatched ? _green : _accent,
                    fontSize: 11, fontWeight: FontWeight.w800),
                ),
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
                border: Border.all(color: _green.withOpacity(0.4)),
              ),
              child: const Column(children: [
                Text('🎉 거래가 성사되었습니다!',
                  style: TextStyle(color: _green, fontSize: 16, fontWeight: FontWeight.w900)),
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
              color: _textSec, fontSize: 12, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),

          ...req.bids.map((bid) => _DealerBidCard(
            request: req,
            bid: bid,
            onAgree: isMatched ? null : () => _showAgreeDialog(req, bid),
          )),

          if (!isMatched) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => setState(() {
                _step = 0;
                _plateCtrl.clear();
                _mileCtrl.clear();
                _plateFound = false;
              }),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _border),
                ),
                child: const Center(child: Text('새 차량 판매 신청하기',
                  style: TextStyle(color: _textSec, fontSize: 13, fontWeight: FontWeight.w600))),
              ),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── 동의 다이얼로그 (전화번호 입력) ──────────────────────
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
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _green.withOpacity(0.5), width: 1.5),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: _green.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: _green.withOpacity(0.5)),
              ),
              child: const Icon(Icons.handshake_rounded, color: _green, size: 30),
            ),
            const SizedBox(height: 14),
            const Text('딜러 견적 동의',
              style: TextStyle(color: _textPri, fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(bid.dealerName,
              style: const TextStyle(color: _accent, fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('제안가: ${_formatNum(bid.offerPrice)}만원',
              style: const TextStyle(color: _green, fontSize: 16, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            const Align(alignment: Alignment.centerLeft,
              child: Text('연락받을 전화번호',
                style: TextStyle(color: _textSec, fontSize: 12))),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _border),
              ),
              child: TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: _textPri, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: '010-0000-0000',
                  hintStyle: TextStyle(color: _textSec),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.phone_rounded, color: _accent, size: 18),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _orange.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '동의하면 해당 딜러에게 연락처가 전달되고\n다른 딜러의 견적은 자동으로 종료됩니다.',
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
                    phone: _phoneCtrl.text.trim(),
                  );
                  setState(() {});
                  _showMatchSuccessDialog(bid);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('동의하고 거래 확정',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
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

  void _showMatchSuccessDialog(DealerBid bid) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _green.withOpacity(0.5)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('🎉 거래 성사!',
              style: TextStyle(color: _green, fontSize: 22, fontWeight: FontWeight.w900)),
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
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('확인',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ── 헬퍼 위젯 ──
  Widget _bulletPoint(String text) => Padding(
    padding: const EdgeInsets.only(top: 5),
    child: Row(children: [
      const Icon(Icons.check_circle_rounded, color: _green, size: 14),
      const SizedBox(width: 6),
      Expanded(child: Text(text,
        style: const TextStyle(color: _textSec, fontSize: 12))),
    ]),
  );

  Widget _sectionTitle(String t) => Text(t,
    style: const TextStyle(color: _textPri, fontSize: 13, fontWeight: FontWeight.w700));

  Widget _infoChip(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
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
            width: _hasAccident == value ? 1.5 : 1,
          ),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(
            value ? Icons.car_crash_rounded : Icons.verified_rounded,
            color: _hasAccident == value
                ? (value ? _red : _green)
                : _textSec,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(
            color: _hasAccident == value
                ? (value ? _red : _green)
                : _textSec,
            fontSize: 13, fontWeight: FontWeight.w700,
          )),
        ]),
      ),
    ),
  );

  @override
  void dispose() {
    _plateCtrl.dispose();
    _mileCtrl.dispose();
    _memoCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }
}

// ============================================================
// 딜러 투찰 카드
// ============================================================
class _DealerBidCard extends StatelessWidget {
  final UsedCarSaleRequest request;
  final DealerBid bid;
  final VoidCallback? onAgree;
  const _DealerBidCard({
    required this.request, required this.bid, this.onAgree});

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
            width: isMatched ? 1.5 : 1,
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // 딜러 정보 헤더
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _accent.withOpacity(0.3)),
                ),
                child: const Icon(Icons.store_rounded, color: _accent, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(bid.dealerName,
                      style: const TextStyle(
                        color: _textPri, fontSize: 13, fontWeight: FontWeight.w800)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(bid.dealerBadge,
                        style: const TextStyle(color: _accent, fontSize: 8, fontWeight: FontWeight.w800)),
                    ),
                  ]),
                  const SizedBox(height: 3),
                  Row(children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 12),
                    Text('  ${bid.dealerRating}', style: const TextStyle(color: _textSec, fontSize: 11)),
                    const SizedBox(width: 8),
                    Text(bid.dealerLocation, style: const TextStyle(color: _textSec, fontSize: 11)),
                  ]),
                ],
              )),
              // 상태 배지
              if (isMatched)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _green, borderRadius: BorderRadius.circular(8)),
                  child: const Text('🤝 매칭완료',
                    style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                )
              else if (isClosed)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _border, borderRadius: BorderRadius.circular(8)),
                  child: const Text('거래종료',
                    style: TextStyle(color: _textSec, fontSize: 9, fontWeight: FontWeight.w800)),
                ),
            ]),
          ),

          // 제안가
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMatched ? _green.withOpacity(0.1) : _bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isMatched ? _green.withOpacity(0.3) : _border),
              ),
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

          // 딜러 메시지
          if (bid.memo.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('💬 ', style: TextStyle(fontSize: 13)),
                    Expanded(child: Text(bid.memo,
                      style: const TextStyle(color: _textSec, fontSize: 11, height: 1.5))),
                  ],
                ),
              ),
            ),

          // 동의 버튼 (매칭 전에만)
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
                    style: TextStyle(
                      color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}

// ============================================================
// 탭2: 중고차 매물 (엔카/차차차 방식)
// ============================================================
class _UsedCarListingsTab extends StatefulWidget {
  @override
  State<_UsedCarListingsTab> createState() => _UsedCarListingsTabState();
}

class _UsedCarListingsTabState extends State<_UsedCarListingsTab> {
  String _filter = '전체';
  String _sort = '최신순';
  final _filters = ['전체', '국산차', '수입차', '전기차', '직거래', '딜러', '인증'];
  final _sorts = ['최신순', '가격낮은순', '가격높은순', '주행거리순'];

  // ── 정밀 검색 필터 상태 ──────────────────────────────────────
  String? _psManufacturer;
  String? _psModel;
  String? _psFuel;
  int?    _psMinYear;
  int?    _psMaxYear;
  int?    _psMaxPrice;
  int?    _psMaxMileage;
  String? _psSellerType;

  bool get _hasPreciseFilter =>
      _psManufacturer != null || _psModel != null || _psFuel != null ||
      _psMinYear != null || _psMaxYear != null || _psMaxPrice != null ||
      _psMaxMileage != null || _psSellerType != null;

  void _clearPreciseFilter() => setState(() {
    _psManufacturer = _psModel = _psFuel = _psSellerType = null;
    _psMinYear = _psMaxYear = _psMaxPrice = _psMaxMileage = null;
  });

  List<UsedCarListing> get _filtered {
    var list = List<UsedCarListing>.from(UsedCarState().listings);
    switch (_filter) {
      case '국산차':
        list = list.where((l) => ['현대', '기아', '쌍용', '르노'].any(
            (b) => l.carName.contains(b))).toList();
        break;
      case '수입차':
        list = list.where((l) => !['현대', '기아', '쌍용', '르노'].any(
            (b) => l.carName.contains(b))).toList();
        break;
      case '전기차':
        list = list.where((l) => l.fuel == '전기').toList();
        break;
      case '직거래':
        list = list.where((l) => l.sellerType == 'individual').toList();
        break;
      case '딜러':
        list = list.where((l) => l.sellerType == 'dealer').toList();
        break;
      case '인증':
        list = list.where((l) => l.isCertified).toList();
        break;
    }
    // ── 정밀검색 필터 ───────────────────────────────────────
    if (_psManufacturer != null)
      list = list.where((l) => l.carName.contains(_psManufacturer!)).toList();
    if (_psModel != null)
      list = list.where((l) => l.carName.contains(_psModel!)).toList();
    if (_psFuel != null)
      list = list.where((l) => l.fuel == _psFuel).toList();
    if (_psMinYear != null)
      list = list.where((l) {
        final y = int.tryParse(l.modelYear.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        return y >= _psMinYear!;
      }).toList();
    if (_psMaxYear != null)
      list = list.where((l) {
        final y = int.tryParse(l.modelYear.replaceAll(RegExp(r'[^0-9]'), '')) ?? 9999;
        return y <= _psMaxYear!;
      }).toList();
    if (_psMaxPrice != null)
      list = list.where((l) => l.price <= _psMaxPrice!).toList();
    if (_psMaxMileage != null)
      list = list.where((l) => l.mileage <= _psMaxMileage!).toList();
    if (_psSellerType != null)
      list = list.where((l) => l.sellerType == _psSellerType).toList();

    switch (_sort) {
      case '가격낮은순': list.sort((a, b) => a.price.compareTo(b.price)); break;
      case '가격높은순': list.sort((a, b) => b.price.compareTo(a.price)); break;
      case '주행거리순': list.sort((a, b) => a.mileage.compareTo(b.mileage)); break;
      default: list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    list.sort((a, b) {
      if (a.isSold && !b.isSold) return 1;
      if (!a.isSold && b.isSold) return -1;
      return 0;
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: UsedCarState(),
      builder: (context, _) {
        final items = _filtered;
        return Column(
          children: [
            // ── 정밀 검색 버튼 바 ─────────────────────────────
            Container(
              color: _card,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
              child: Row(children: [
                GestureDetector(
                  onTap: _showPreciseSearchSheet,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: _hasPreciseFilter ? _green.withOpacity(0.15) : _bg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _hasPreciseFilter ? _green.withOpacity(0.7) : _accent.withOpacity(0.4),
                        width: _hasPreciseFilter ? 1.5 : 1),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.tune_rounded,
                          color: _hasPreciseFilter ? _green : _accent, size: 14),
                      const SizedBox(width: 5),
                      Text(_hasPreciseFilter ? '정밀검색 적용중' : '정밀검색',
                          style: TextStyle(
                              color: _hasPreciseFilter ? _green : _accent,
                              fontSize: 11, fontWeight: FontWeight.w800)),
                      if (_hasPreciseFilter) ...[
                        const SizedBox(width: 5),
                        GestureDetector(
                          onTap: _clearPreciseFilter,
                          child: const Icon(Icons.close_rounded, color: _green, size: 14)),
                      ],
                    ]),
                  ),
                ),
                const SizedBox(width: 8),
                if (_psManufacturer != null) _psTag(_psManufacturer!),
                if (_psModel != null) _psTag(_psModel!),
                if (_psFuel != null) _psTag(_psFuel!),
                const Spacer(),
                Text('${items.length}개',
                    style: const TextStyle(color: _textSec, fontSize: 11, fontWeight: FontWeight.w700)),
              ]),
            ),

            // 필터 + 정렬 바
            Container(
              color: _card,
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: Row(children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filters.map((f) {
                        final sel = f == _filter;
                        return GestureDetector(
                          onTap: () => setState(() => _filter = f),
                          child: Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: sel ? _accent : _bg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: sel ? _accent : _border),
                            ),
                            child: Text(f,
                              style: TextStyle(
                                color: sel ? Colors.black : _textSec,
                                fontSize: 11, fontWeight: FontWeight.w700)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _showSortSheet(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _bg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _border),
                    ),
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

            // 매물 목록
            Expanded(
              child: items.isEmpty
                  ? Center(child: Column(
                      mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(Icons.search_off_rounded, color: _textSec, size: 46),
                        const SizedBox(height: 10),
                        const Text('조건에 맞는 매물이 없습니다',
                            style: TextStyle(color: _textSec, fontSize: 14)),
                        if (_hasPreciseFilter) ...[
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: _clearPreciseFilter,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: _green.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: _green.withOpacity(0.4))),
                              child: const Text('필터 초기화',
                                  style: TextStyle(color: _green, fontSize: 12, fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ],
                      ]))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: items.length,
                      itemBuilder: (_, i) => _ListingCard(
                        listing: items[i],
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                UsedCarDetailScreen(listing: items[i]),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  // ── 정밀검색 필터 태그 위젯 ─────────────────────────────────
  Widget _psTag(String label) => Container(
    margin: const EdgeInsets.only(right: 4),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: _green.withOpacity(0.12),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _green.withOpacity(0.4)),
    ),
    child: Text(label, style: const TextStyle(color: _green, fontSize: 10, fontWeight: FontWeight.w700)),
  );

  // ── 정밀검색 바텀시트 ─────────────────────────────────────
  void _showPreciseSearchSheet() {
    // 로컬 임시 상태
    String? mfr = _psManufacturer;
    String? mdl = _psModel;
    String? fuel = _psFuel;
    int minYear = _psMinYear ?? 2011;
    int maxYear = _psMaxYear ?? DateTime.now().year;
    int maxPrice = _psMaxPrice ?? 10000;
    int maxMileage = _psMaxMileage ?? 300000;
    String? sellerType = _psSellerType;

    const manufacturers = ['현대', '기아', 'BMW', '벤츠', '아우디', '볼보', '렉서스', '토요타', '혼다', '포르쉐', '테슬라'];
    const modelsByMfr = <String, List<String>>{
      '현대': ['소나타', '아반떼', '그랜저', '투싼', '싼타페', '팰리세이드', '아이오닉5', '아이오닉6', '넥쏘'],
      '기아': ['K5', 'K8', 'K9', '스포티지', '쏘렌토', '카니발', 'EV6', 'EV9', '모하비'],
      'BMW': ['3시리즈', '5시리즈', '7시리즈', 'X3', 'X5', 'X7', 'iX'],
      '벤츠': ['C클래스', 'E클래스', 'S클래스', 'GLC', 'GLE', 'GLS', 'EQS'],
      '아우디': ['A4', 'A6', 'A8', 'Q3', 'Q5', 'Q7', 'e-tron'],
      '볼보': ['XC40', 'XC60', 'XC90', 'S60', 'S90'],
      '렉서스': ['IS', 'ES', 'LS', 'RX', 'NX', 'UX'],
      '토요타': ['캠리', '아발론', 'RAV4', '하이랜더', '프리우스'],
      '혼다': ['어코드', '시빅', 'CR-V', '파일럿'],
      '포르쉐': ['카이엔', '마칸', '파나메라', '911'],
      '테슬라': ['Model 3', 'Model Y', 'Model S', 'Model X'],
    };
    const fuels = ['가솔린', '디젤', '하이브리드', '전기', 'LPG'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (bCtx, bSet) {
          final models = mfr != null ? (modelsByMfr[mfr] ?? <String>[]) : <String>[];
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(bCtx).viewInsets.bottom),
            child: SizedBox(
              height: MediaQuery.of(bCtx).size.height * 0.75,
              child: Column(children: [
                // 헤더
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: _border))),
                  child: Row(children: [
                    const Icon(Icons.tune_rounded, color: _accent, size: 20),
                    const SizedBox(width: 8),
                    const Text('정밀 검색',
                        style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    TextButton(
                      onPressed: () => bSet(() {
                        mfr = mdl = fuel = sellerType = null;
                        minYear = 2011; maxYear = DateTime.now().year;
                        maxPrice = 10000; maxMileage = 300000;
                      }),
                      child: Text('초기화', style: TextStyle(color: _textSec, fontSize: 13)),
                    ),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(bCtx)),
                  ]),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                      // 1. 제조사 선택
                      _psSection('제조사'),
                      Wrap(spacing: 6, runSpacing: 6,
                        children: manufacturers.map((m) => GestureDetector(
                          onTap: () => bSet(() { mfr = mfr == m ? null : m; mdl = null; }),
                          child: _psChip(m, mfr == m),
                        )).toList(),
                      ),
                      const SizedBox(height: 16),

                      // 2. 모델 선택 (제조사 선택 후)
                      if (mfr != null && models.isNotEmpty) ...[
                        _psSection('모델 ($mfr)'),
                        Wrap(spacing: 6, runSpacing: 6,
                          children: models.map((m) => GestureDetector(
                            onTap: () => bSet(() => mdl = mdl == m ? null : m),
                            child: _psChip(m, mdl == m),
                          )).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // 3. 연료
                      _psSection('연료'),
                      Wrap(spacing: 6, runSpacing: 6,
                        children: fuels.map((f) => GestureDetector(
                          onTap: () => bSet(() => fuel = fuel == f ? null : f),
                          child: _psChip(f, fuel == f),
                        )).toList(),
                      ),
                      const SizedBox(height: 16),

                      // 4. 연식 범위
                      _psSection('연식 ($minYear년 ~ $maxYear년)'),
                      Row(children: [
                        Expanded(child: Column(children: [
                          Text('최소', style: TextStyle(color: _textSec, fontSize: 11)),
                          Slider(
                            value: minYear.toDouble(),
                            min: 2005, max: DateTime.now().year.toDouble(),
                            divisions: DateTime.now().year - 2005,
                            activeColor: _accent,
                            inactiveColor: _border,
                            label: '$minYear년',
                            onChanged: (v) => bSet(() {
                              minYear = v.toInt();
                              if (minYear > maxYear) maxYear = minYear;
                            }),
                          ),
                        ])),
                        Expanded(child: Column(children: [
                          Text('최대', style: TextStyle(color: _textSec, fontSize: 11)),
                          Slider(
                            value: maxYear.toDouble(),
                            min: 2005, max: DateTime.now().year.toDouble(),
                            divisions: DateTime.now().year - 2005,
                            activeColor: _green,
                            inactiveColor: _border,
                            label: '$maxYear년',
                            onChanged: (v) => bSet(() {
                              maxYear = v.toInt();
                              if (maxYear < minYear) minYear = maxYear;
                            }),
                          ),
                        ])),
                      ]),
                      const SizedBox(height: 8),

                      // 5. 최대 가격
                      _psSection('최대 가격 (${maxPrice >= 10000 ? "제한없음" : "${_formatNum(maxPrice)}만원 이하"})'),
                      Slider(
                        value: maxPrice.toDouble(),
                        min: 500, max: 10000, divisions: 95,
                        activeColor: _accent,
                        inactiveColor: _border,
                        label: maxPrice >= 10000 ? '제한없음' : '${_formatNum(maxPrice)}만원',
                        onChanged: (v) => bSet(() => maxPrice = v.toInt()),
                      ),
                      const SizedBox(height: 8),

                      // 6. 최대 주행거리
                      _psSection('최대 주행거리 (${maxMileage >= 300000 ? "제한없음" : "${_formatNum(maxMileage)}km 이하"})'),
                      Slider(
                        value: maxMileage.toDouble(),
                        min: 10000, max: 300000, divisions: 58,
                        activeColor: _accent,
                        inactiveColor: _border,
                        label: maxMileage >= 300000 ? '제한없음' : '${_formatNum(maxMileage)}km',
                        onChanged: (v) => bSet(() => maxMileage = v.toInt()),
                      ),
                      const SizedBox(height: 8),

                      // 7. 판매자 유형
                      _psSection('판매자 유형'),
                      Row(children: [
                        for (final e in [
                          {'value': null, 'label': '전체'},
                          {'value': 'individual', 'label': '개인직거래'},
                          {'value': 'dealer', 'label': '딜러/점포'},
                        ])
                          Expanded(child: GestureDetector(
                            onTap: () => bSet(() => sellerType = e['value'] as String?),
                            child: Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: sellerType == e['value'] ? _accent : _navy,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: sellerType == e['value'] ? _accent : _border),
                              ),
                              child: Center(child: Text(e['label'] as String,
                                style: TextStyle(
                                  color: sellerType == e['value'] ? Colors.black : _textSec,
                                  fontSize: 12, fontWeight: FontWeight.w700),
                              )),
                            ),
                          )),
                      ]),
                      const SizedBox(height: 24),
                    ]),
                  ),
                ),

                // 검색 적용 버튼
                Container(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(bCtx).padding.bottom + 12),
                  decoration: BoxDecoration(border: Border(top: BorderSide(color: _border))),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.black,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      setState(() {
                        _psManufacturer = mfr;
                        _psModel = mdl;
                        _psFuel = fuel;
                        _psMinYear = minYear > 2005 ? minYear : null;
                        _psMaxYear = maxYear < DateTime.now().year ? maxYear : null;
                        _psMaxPrice = maxPrice < 10000 ? maxPrice : null;
                        _psMaxMileage = maxMileage < 300000 ? maxMileage : null;
                        _psSellerType = sellerType;
                      });
                      Navigator.pop(bCtx);
                    },
                    child: const Text('검색 적용',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }

  // 정밀검색 섹션 제목
  Widget _psSection(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
  );

  // 정밀검색 칩
  Widget _psChip(String label, bool selected) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: selected ? _accent : _navy,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: selected ? _accent : _border),
    ),
    child: Text(label, style: TextStyle(
      color: selected ? Colors.black : _textSec,
      fontSize: 12, fontWeight: selected ? FontWeight.w800 : FontWeight.w400,
    )),
  );

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('정렬 기준',
              style: TextStyle(color: _textPri, fontSize: 15, fontWeight: FontWeight.w800)),
          ),
          ..._sorts.map((s) => ListTile(
            title: Text(s, style: TextStyle(
              color: s == _sort ? _accent : _textPri,
              fontWeight: s == _sort ? FontWeight.w800 : FontWeight.w400,
            )),
            trailing: s == _sort
                ? const Icon(Icons.check_rounded, color: _accent)
                : null,
            onTap: () {
              setState(() => _sort = s);
              Navigator.pop(context);
            },
          )),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

// ── 매물 카드 (리스트뷰용) ──────────────────────────────────────
class _ListingCard extends StatelessWidget {
  final UsedCarListing listing;
  final VoidCallback onTap;
  const _ListingCard({required this.listing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSold = listing.isSold;
    return GestureDetector(
      onTap: isSold ? null : onTap,
      child: Opacity(
        opacity: isSold ? 0.55 : 1.0,
        child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSold ? _border.withOpacity(0.3) : _border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 썸네일
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomLeft: Radius.circular(14),
              ),
              child: Stack(
                children: [
                  Image.network(
                    listing.photoUrls.first,
                    width: 120, height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 120, height: 100,
                      color: _navy,
                      child: const Icon(Icons.directions_car, color: _textSec, size: 32),
                    ),
                  ),
                  Positioned(
                    top: 6, left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: listing.sellerType == 'dealer'
                            ? _accent.withOpacity(0.85)
                            : _purple.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        listing.sellerType == 'dealer' ? '딜러' : '직거래',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  // 협회 인증 배지
                  if (listing.isCertified)
                    Positioned(
                      top: 6, right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: _green.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.verified_rounded, color: Colors.white, size: 9),
                          SizedBox(width: 2),
                          Text('협회인증',
                            style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w800)),
                        ]),
                      ),
                    ),
                  // 판매완료 오버레이
                  if (isSold)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.45),
                        child: const Center(
                          child: Text('SOLD', style: TextStyle(
                            color: Colors.white, fontSize: 18,
                            fontWeight: FontWeight.w900, letterSpacing: 2)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // 정보
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(listing.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _textPri, fontSize: 12, fontWeight: FontWeight.w700, height: 1.4)),
                    const SizedBox(height: 6),
                    Row(children: [
                      Text('${_formatNum(listing.mileage)}km',
                        style: const TextStyle(color: _textSec, fontSize: 11)),
                      const Text(' · ', style: TextStyle(color: _border)),
                      Text(listing.fuel,
                        style: const TextStyle(color: _textSec, fontSize: 11)),
                      const Text(' · ', style: TextStyle(color: _border)),
                      Text(listing.region,
                        style: const TextStyle(color: _textSec, fontSize: 11)),
                    ]),
                    const SizedBox(height: 4),
                    if (!listing.hasAccident)
                      Row(children: [
                        const Icon(Icons.verified_rounded, color: _green, size: 12),
                        const SizedBox(width: 3),
                        const Text('무사고',
                          style: TextStyle(color: _green, fontSize: 10, fontWeight: FontWeight.w700)),
                      ]),
                    const SizedBox(height: 6),
                    Row(children: [
                      Text('${_formatNum(listing.price)}만원',
                        style: const TextStyle(
                          color: _textPri, fontSize: 16, fontWeight: FontWeight.w900)),
                      const Spacer(),
                      AnimatedBuilder(
                        animation: UsedCarState(),
                        builder: (_, __) => GestureDetector(
                          onTap: () => UsedCarState().toggleFavorite(listing.listingId),
                          child: Icon(
                            listing.isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: listing.isFavorite ? _red : _textSec,
                            size: 20,
                          ),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
        ), // Container
      ), // Opacity
    );
  }
}

// ============================================================
// 중고차 매물 상세 화면
// ============================================================
class UsedCarDetailScreen extends StatefulWidget {
  final UsedCarListing listing;
  const UsedCarDetailScreen({super.key, required this.listing});
  @override
  State<UsedCarDetailScreen> createState() => _UsedCarDetailScreenState();
}

// 개인거래 연락 단계: chatting → chat_sent → phone_enabled
enum _ContactStage { chatting, chatSent, phoneEnabled }

class _UsedCarDetailScreenState extends State<UsedCarDetailScreen> {
  int _photoIndex = 0;
  final _pageCtrl = PageController();
  _ContactStage _contactStage = _ContactStage.chatting; // 채팅 우선, 전화는 의향 확인 후

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.listing;
    final topPad = MediaQuery.of(context).padding.top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _bg,
        body: Stack(
          children: [
            // ── 메인 스크롤 콘텐츠 ──
            CustomScrollView(
              slivers: [
                // 사진 슬라이더
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 260,
                    child: Stack(
                      children: [
                        PageView.builder(
                          controller: _pageCtrl,
                          itemCount: l.photoUrls.length,
                          onPageChanged: (i) => setState(() => _photoIndex = i),
                          itemBuilder: (_, i) => Image.network(
                            l.photoUrls[i],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => Container(
                              color: _navy,
                              child: const Icon(Icons.directions_car,
                                  color: _textSec, size: 60),
                            ),
                          ),
                        ),
                        // 사진 인디케이터
                        Positioned(
                          bottom: 12, left: 0, right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: l.photoUrls.asMap().entries.map((e) =>
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                width: e.key == _photoIndex ? 16 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: e.key == _photoIndex
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ).toList(),
                          ),
                        ),
                        // 사진 장수 배지
                        Positioned(
                          top: 12 + topPad, right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_photoIndex + 1}/${l.photoUrls.length}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 11)),
                          ),
                        ),
                        // 뒤로가기 버튼 (슬라이더 위 오버레이)
                        Positioned(
                          top: topPad + 4, left: 4,
                          child: IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white, size: 16),
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 타이틀 + 찜
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: Text(l.title,
                              style: const TextStyle(
                                color: _textPri, fontSize: 16,
                                fontWeight: FontWeight.w900, height: 1.4))),
                            AnimatedBuilder(
                              animation: UsedCarState(),
                              builder: (_, __) => GestureDetector(
                                onTap: () => UsedCarState().toggleFavorite(l.listingId),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8, top: 2),
                                  child: Icon(
                                    l.isFavorite
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    color: l.isFavorite ? _red : _textSec,
                                    size: 24,
                                  ),
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
                            l.sellerType == 'dealer' ? _accent : _purple,
                          ),
                        ]),
                        const SizedBox(height: 12),

                        // 가격
                        Text('${_formatNum(l.price)}만원',
                          style: const TextStyle(
                            color: _textPri, fontSize: 26,
                            fontWeight: FontWeight.w900)),
                        const SizedBox(height: 16),

                        // 차량 제원표
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _border),
                          ),
                          child: Column(children: [
                            _specRow('연식', l.modelYear),
                            _divider(),
                            _specRow('주행거리', '${_formatNum(l.mileage)}km'),
                            _divider(),
                            _specRow('연료', l.fuel),
                            _divider(),
                            _specRow('변속기', l.transmission),
                            _divider(),
                            _specRow('색상', l.color),
                            _divider(),
                            _specRow('사고유무',
                              l.hasAccident ? '사고 있음' : '무사고',
                              valueColor: l.hasAccident ? _red : _green),
                            _divider(),
                            _specRow('지역', l.region),
                          ]),
                        ),
                        const SizedBox(height: 14),

                        // 설명
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('판매자 설명',
                                style: TextStyle(
                                  color: _textSec, fontSize: 12,
                                  fontWeight: FontWeight.w700)),
                              const SizedBox(height: 8),
                              Text(l.desc,
                                style: const TextStyle(
                                  color: _textPri, fontSize: 13, height: 1.7)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // 판매자 정보
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _border),
                          ),
                          child: Row(children: [
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                color: _accent.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.person_rounded,
                                  color: _accent, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l.sellerName,
                                  style: const TextStyle(
                                    color: _textPri, fontSize: 13,
                                    fontWeight: FontWeight.w700)),
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
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text('KAA 인증',
                                  style: TextStyle(
                                    color: _accent, fontSize: 10,
                                    fontWeight: FontWeight.w800)),
                              ),
                          ]),
                        ),
                        // 판매완료 처리 버튼 (개인 직거래 + 미판매 상태에서만)
                        if (l.sellerType == 'individual' && !l.isSold) ...[
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.done_all_rounded, size: 16),
                              label: const Text('판매완료 처리'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _textSec,
                                side: BorderSide(color: _border),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () {
                                UsedCarState().markSold(l.listingId);
                                setState(() {});
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('판매완료로 처리되었습니다.'),
                                    backgroundColor: _green,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                        // 하단 버튼 공간 확보
                        const SizedBox(height: 90),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ── 하단 고정 버튼 ──
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                    16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
                decoration: BoxDecoration(
                  color: _card,
                  border: Border(top: BorderSide(color: _border)),
                ),
                child: _buildContactButtons(context, l),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 채팅우선→전화허용 contactStage 버튼 빌더 ─────────────
  Widget _buildContactButtons(BuildContext ctx, UsedCarListing l) {
    if (l.sellerType == 'individual') {
      // 개인거래: chatting → chatSent → phoneEnabled 단계
      switch (_contactStage) {
        case _ContactStage.chatting:
          return Row(children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.chat_rounded, size: 16),
                label: const Text('1:1 채팅 문의'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: l.isSold ? null : () => _showChatDialog(ctx, l),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                icon: Icon(Icons.phone_disabled_rounded, size: 16, color: _textSec),
                label: Text('전화하기', style: TextStyle(color: _textSec)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _textSec,
                  side: BorderSide(color: _border),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: null, // 채팅 후 전화 허용
              ),
            ),
          ]);

        case _ContactStage.chatSent:
          return Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.chat_rounded, size: 16),
                label: const Text('채팅 계속하기'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _accent,
                  side: BorderSide(color: _accent.withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _showChatDialog(ctx, l),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.phone_rounded, size: 16),
                label: const Text('구매의향 확인'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: l.isSold ? null : () => _showPhoneConfirmDialog(ctx, l),
              ),
            ),
          ]);

        case _ContactStage.phoneEnabled:
          return Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.chat_rounded, size: 16),
                label: const Text('채팅 계속'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _accent,
                  side: BorderSide(color: _accent.withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _showChatDialog(ctx, l),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: l.isSold ? null : () {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                    content: Text('📞 판매자 번호: ${l.sellerPhone}'),
                    backgroundColor: _green,
                    duration: const Duration(seconds: 4),
                  ));
                },
              ),
            ),
          ]);
      }
    } else {
      // 딜러 매물: 점포 신청 + 전화하기
      return Row(children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.storefront_rounded, size: 16),
            label: const Text('점포 신청'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _accent,
              side: BorderSide(color: _accent.withOpacity(0.5)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: l.isSold ? null : () => _showDealerApplyDialog(ctx, l),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: l.isSold ? null : () {
              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                content: Text('📞 ${l.sellerPhone}'),
                backgroundColor: _green,
              ));
            },
          ),
        ),
      ]);
    }
  }

  // ── 1:1 채팅 다이얼로그 (채팅 우선) ─────────────────────
  void _showChatDialog(BuildContext ctx, UsedCarListing l) {
    final msgCtrl = TextEditingController();
    final msgs = <Map<String, String>>[
      {'role': 'seller', 'text': '안녕하세요! ${l.title}에 관심 가져주셔서 감사합니다 😊'},
    ];
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (bCtx, bSet) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(bCtx).viewInsets.bottom),
          child: SizedBox(
            height: MediaQuery.of(bCtx).size.height * 0.65,
            child: Column(children: [
              // 헤더
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: _border))),
                child: Row(children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: _accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(child: Text(l.sellerName[0], style: TextStyle(color: _accent, fontWeight: FontWeight.bold))),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.sellerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('판매자 · ${l.region}', style: TextStyle(fontSize: 12, color: _textSec)),
                    ],
                  )),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(bCtx)),
                ]),
              ),
              // 메시지 목록
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: msgs.length,
                  itemBuilder: (_, i) {
                    final m = msgs[i];
                    final isMe = m['role'] == 'buyer';
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(bCtx).size.width * 0.7),
                        decoration: BoxDecoration(
                          color: isMe ? _accent : _navy,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(m['text']!, style: const TextStyle(color: Colors.white, fontSize: 14)),
                      ),
                    );
                  },
                ),
              ),
              // 빠른 메시지 템플릿
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(children: [
                  for (final t in ['아직 판매중인가요?', '최저가 얼마까지 가능한가요?', '직접 보러 가도 될까요?', '차량 상태 사진 더 보내주실 수 있나요?'])
                    GestureDetector(
                      onTap: () => msgCtrl.text = t,
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _navy,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _border),
                        ),
                        child: Text(t, style: const TextStyle(fontSize: 12, color: Colors.white)),
                      ),
                    ),
                ]),
              ),
              // 입력창
              Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                decoration: BoxDecoration(border: Border(top: BorderSide(color: _border))),
                child: Row(children: [
                  Expanded(
                    child: TextField(
                      controller: msgCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: '메시지를 입력하세요...',
                        hintStyle: TextStyle(color: _textSec),
                        filled: true,
                        fillColor: _navy,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      final text = msgCtrl.text.trim();
                      if (text.isEmpty) return;
                      bSet(() {
                        msgs.add({'role': 'buyer', 'text': text});
                        msgs.add({'role': 'seller', 'text': '네, 확인했습니다! 😊 관심 가져주셔서 감사해요. 조금 더 자세한 내용은 직접 통화로 말씀 드릴게요.'});
                      });
                      msgCtrl.clear();
                      // contactStage 진행
                      setState(() => _contactStage = _ContactStage.chatSent);
                    },
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(color: _accent, borderRadius: BorderRadius.circular(22)),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  // ── 구매의향 확인 후 전화번호 공개 다이얼로그 ─────────────
  void _showPhoneConfirmDialog(BuildContext ctx, UsedCarListing l) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: _card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          Icon(Icons.verified_user_rounded, color: _accent, size: 22),
          const SizedBox(width: 8),
          const Text('구매 의향 확인', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('채팅을 통해 충분히 소통하셨나요?', style: TextStyle(color: _textSec, fontSize: 14)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: _navy, borderRadius: BorderRadius.circular(10)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('📋 ${l.title}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 4),
              Text('판매가: ${_formatNum(l.price)}만원', style: TextStyle(color: _accent, fontSize: 13)),
            ]),
          ),
          const SizedBox(height: 12),
          Text('확인 버튼을 누르면 판매자 전화번호가 공개됩니다.',
              style: TextStyle(color: _textSec, fontSize: 12)),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(_),
            child: Text('취소', style: TextStyle(color: _textSec)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _green, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(_);
              setState(() => _contactStage = _ContactStage.phoneEnabled);
              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                content: Text('✅ 전화번호 공개됨 · 📞 ${l.sellerPhone}'),
                backgroundColor: _green,
                duration: const Duration(seconds: 5),
              ));
            },
            child: const Text('구매의향 확인 → 전화번호 받기'),
          ),
        ],
      ),
    );
  }

  // ── 개인간 1:1 문의: 전화번호 교환 다이얼로그 ─────────────
  void _showIndividualInquiryDialog(BuildContext ctx, UsedCarListing l) {
    final phoneCtrl = TextEditingController();
    showDialog(
      context: ctx,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _accent.withOpacity(0.4)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: _accent.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.verified_user_rounded, color: _accent, size: 26),
            ),
            const SizedBox(height: 14),
            const Text('협회 인증 1:1 거래',
              style: TextStyle(color: _textPri, fontSize: 17, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text('${l.sellerName} 판매자와 연결합니다',
              textAlign: TextAlign.center,
              style: const TextStyle(color: _textSec, fontSize: 12)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _accent.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _accent.withOpacity(0.2)),
              ),
              child: const Text(
                '전화번호를 입력하면 협회에서 인증 후\n판매자에게 연락처를 전달합니다.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _textSec, fontSize: 11, height: 1.5)),
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('내 연락처', style: TextStyle(color: _textSec, fontSize: 12))),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _border),
              ),
              child: TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: _textPri, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: '010-0000-0000',
                  hintStyle: TextStyle(color: _textSec),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.phone_rounded, color: _accent, size: 18),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _showPhoneExchangeSuccess(ctx, l, phoneCtrl.text.trim());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('연락처 전달하기',
                  style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('취소', style: TextStyle(color: _textSec)),
            ),
          ]),
        ),
      ),
    );
  }

  void _showPhoneExchangeSuccess(BuildContext ctx, UsedCarListing l, String myPhone) {
    showDialog(
      context: ctx,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _green.withOpacity(0.4)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.check_circle_rounded, color: _green, size: 52),
            const SizedBox(height: 14),
            const Text('연락처 전달 완료!',
              style: TextStyle(color: _green, fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text('${l.sellerName} 판매자에게 연락처가 전달되었습니다.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: _textSec, fontSize: 12, height: 1.5)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _green.withOpacity(0.07),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _green.withOpacity(0.2)),
              ),
              child: Row(children: [
                const Icon(Icons.phone_rounded, color: _green, size: 16),
                const SizedBox(width: 8),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('판매자 번호', style: TextStyle(color: _textSec, fontSize: 10)),
                  Text(l.sellerPhone,
                    style: const TextStyle(color: _textPri, fontSize: 14, fontWeight: FontWeight.w800)),
                ]),
              ]),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('확인', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ── 점포 역경매 신청 다이얼로그 ──────────────────────────────
  void _showDealerApplyDialog(BuildContext ctx, UsedCarListing l) {
    showDialog(
      context: ctx,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _orange.withOpacity(0.4)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: _orange.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.storefront_rounded, color: _orange, size: 26),
            ),
            const SizedBox(height: 14),
            const Text('점포 방문 신청',
              style: TextStyle(color: _textPri, fontSize: 17, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(l.sellerName,
              style: const TextStyle(color: _accent, fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('${_formatNum(l.price)}만원 매물에 관심을 표시합니다',
              textAlign: TextAlign.center,
              style: const TextStyle(color: _textSec, fontSize: 12)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _orange.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _orange.withOpacity(0.2)),
              ),
              child: const Text(
                '신청 후 점포에서 24시간 내 연락드립니다.\n실물 확인 후 최종 가격을 협의하세요.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _textSec, fontSize: 11, height: 1.5)),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                      content: Text('✅ ${l.sellerName}에 방문 신청이 완료되었습니다!'),
                      backgroundColor: _green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _orange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('신청하기',
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('취소', style: TextStyle(color: _textSec)),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _tagChip(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Text(text,
      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
  );

  Widget _specRow(String label, String value, {Color? valueColor}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          SizedBox(
            width: 80,
            child: Text(label,
              style: const TextStyle(color: _textSec, fontSize: 12))),
          Expanded(child: Text(value,
            style: TextStyle(
              color: valueColor ?? _textPri,
              fontSize: 12, fontWeight: FontWeight.w700))),
        ]),
      );

  Widget _divider() =>
      Divider(color: _border.withOpacity(0.5), height: 1);
}

// ============================================================
// 하단 고정: 가까운 중고차 점포 가로 스크롤
// ============================================================
class _NearbyDealerBar extends StatelessWidget {
  // 중고차 카테고리 점포 필터
  // 거리순 정렬된 점포 목록
  static final List<Map<String, dynamic>> _dealers = [
    {
      'id': 5,
      'name': '범어 중고차 매매단지',
      'dist': '1.9km', 'distKm': 1.9,
      'rating': 4.5,
      'badge': '우수딜러',
      'image': 'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?w=200&q=80',
      'count': 8,
    },
    {
      'id': 4,
      'name': 'KAA 인증 중고차센터',
      'dist': '2.1km', 'distKm': 2.1,
      'rating': 4.6,
      'badge': 'KAA인증',
      'image': 'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?w=200&q=80',
      'count': 12,
    },
    {
      'id': 7,
      'name': '수성 프리미엄 오토',
      'dist': '2.7km', 'distKm': 2.7,
      'rating': 4.4,
      'badge': 'KAA인증',
      'image': 'https://images.unsplash.com/photo-1580273916550-e323be2ae537?w=200&q=80',
      'count': 6,
    },
    {
      'id': 6,
      'name': '황금동 오토플라자',
      'dist': '3.2km', 'distKm': 3.2,
      'rating': 4.3,
      'badge': '인기딜러',
      'image': 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=200&q=80',
      'count': 15,
    },
    {
      'id': 8,
      'name': '동대구 중고차 타운',
      'dist': '4.1km',
      'rating': 4.2,
      'badge': '신규',
      'image': 'https://images.unsplash.com/photo-1617531653332-bd46c16f4d68?w=200&q=80',
      'count': 20,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _card,
        border: Border(top: BorderSide(color: _border, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Row(children: [
              const Icon(Icons.location_on_rounded, color: _accent, size: 14),
              const SizedBox(width: 4),
              const Text('가까운 중고차 점포',
                style: TextStyle(
                  color: _textSec, fontSize: 11, fontWeight: FontWeight.w700)),
              const Spacer(),
              Text('내 위치 · 대구 수성구',
                style: TextStyle(color: _textSec.withOpacity(0.6), fontSize: 10)),
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
                      color: _navy,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _border),
                    ),
                    child: Row(children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                        child: Image.network(
                          d['image'] as String,
                          width: 50, height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 50, color: _border,
                            child: const Icon(Icons.store, color: _textSec, size: 18)),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(d['name'] as String,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: _textPri, fontSize: 10,
                                  fontWeight: FontWeight.w700, height: 1.3)),
                              const SizedBox(height: 3),
                              Text('${d['dist']}  ⭐${d['rating']}',
                                style: const TextStyle(
                                  color: _textSec, fontSize: 9)),
                              const SizedBox(height: 3),
                              Text('매물 ${d['count']}건',
                                style: const TextStyle(
                                  color: _accent, fontSize: 9,
                                  fontWeight: FontWeight.w700)),
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
        ],
      ),
    );
  }

  void _showDealerSheet(BuildContext context, Map<String, dynamic> dealer) {
    // 해당 점포의 매물 필터링
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
        builder: (_, ctrl) => Column(
          children: [
            // 핸들
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: _border, borderRadius: BorderRadius.circular(2)),
            ),
            // 점포 헤더
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Row(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    dealer['image'] as String,
                    width: 56, height: 56, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 56, height: 56,
                      color: _border,
                      child: const Icon(Icons.store, color: _textSec)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dealer['name'] as String,
                      style: const TextStyle(
                        color: _textPri, fontSize: 15, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(dealer['badge'] as String,
                          style: const TextStyle(
                            color: _accent, fontSize: 9, fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(width: 6),
                      Text('${dealer['dist']}  ⭐${dealer['rating']}',
                        style: const TextStyle(color: _textSec, fontSize: 11)),
                    ]),
                  ],
                )),
                Text('매물 ${dealer['count']}건',
                  style: const TextStyle(
                    color: _accent, fontSize: 13, fontWeight: FontWeight.w800)),
              ]),
            ),
            Divider(color: _border, height: 1),
            // 보유 매물 목록
            Expanded(
              child: storeListings.isEmpty
                  ? Center(
                      child: Text(
                        '이 점포의 매물 정보가 없습니다',
                        style: TextStyle(color: _textSec),
                      ),
                    )
                  : ListView.builder(
                      controller: ctrl,
                      padding: const EdgeInsets.all(14),
                      itemCount: storeListings.length,
                      itemBuilder: (ctx, i) => _ListingCard(
                        listing: storeListings[i],
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            ctx,
                            MaterialPageRoute(
                              builder: (_) => UsedCarDetailScreen(
                                  listing: storeListings[i]),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 공통 헬퍼 함수
// ============================================================
String _formatNum(int n) =>
    n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );

String _timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return '방금 전';
  if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
  if (diff.inHours < 24) return '${diff.inHours}시간 전';
  return '${diff.inDays}일 전';
}
