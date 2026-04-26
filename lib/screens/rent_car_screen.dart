import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/app_state.dart';

const Color _bg     = Color(0xFF020810);
const Color _card   = Color(0xFF0D1B2A);
const Color _navy   = Color(0xFF0A1628);
const Color _accent = Color(0xFF4FC3F7);
const Color _green  = Color(0xFF10B981);
const Color _orange = Color(0xFFFF6B35);
const Color _purple = Color(0xFF8B5CF6);
const Color _red    = Color(0xFFE53935);
const Color _border = Color(0xFF1E3A5F);
const Color _pri    = Colors.white;
const Color _sec    = Color(0xFFB0BEC5);

String _won(int v) {
  if (v >= 10000) {
    final man = v / 10000;
    return '${man % 1 == 0 ? man.toInt() : man.toStringAsFixed(1)}만원';
  }
  return '${v}원';
}
String _dateStr(DateTime d) =>
    '${d.year}.${d.month.toString().padLeft(2,'0')}.${d.day.toString().padLeft(2,'0')}';
String _dtStr(DateTime d) =>
    '${_dateStr(d)} ${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';

const Map<String, List<String>> _regionData = {
  '서울': ['강남구','강동구','강북구','강서구','관악구','광진구','구로구','금천구','노원구','도봉구','동대문구','동작구','마포구','서대문구','서초구','성동구','성북구','송파구','양천구','영등포구','용산구','은평구','종로구','중구','중랑구'],
  '경기': ['수원시','성남시','의정부시','안양시','부천시','광명시','평택시','안산시','고양시','과천시','구리시','남양주시','오산시','시흥시','군포시','의왕시','하남시','용인시','파주시','이천시','안성시','김포시','화성시','광주시','양주시','포천시'],
  '부산': ['중구','서구','동구','영도구','부산진구','동래구','남구','북구','해운대구','사하구','금정구','강서구','연제구','수영구','사상구','기장군'],
  '대구': ['중구','동구','서구','남구','북구','수성구','달서구','달성군'],
  '인천': ['중구','동구','미추홀구','연수구','남동구','부평구','계양구','서구','강화군','옹진군'],
  '광주': ['동구','서구','남구','북구','광산구'],
  '대전': ['동구','중구','서구','유성구','대덕구'],
  '울산': ['중구','남구','동구','북구','울주군'],
  '세종': ['세종시'],
  '제주': ['제주시','서귀포시'],
  '강원': ['춘천시','원주시','강릉시','동해시','태백시','속초시','삼척시'],
  '충북': ['청주시','충주시','제천시','보은군','옥천군','영동군','진천군'],
  '충남': ['천안시','공주시','보령시','아산시','서산시','논산시','당진시'],
  '전북': ['전주시','군산시','익산시','정읍시','남원시','김제시'],
  '전남': ['목포시','여수시','순천시','나주시','광양시'],
  '경북': ['포항시','경주시','김천시','안동시','구미시','영주시','영천시','상주시'],
  '경남': ['창원시','진주시','통영시','사천시','김해시','밀양시','거제시','양산시'],
};

// ═══════════════════════════════════════════════
// 렌트카 메인 (검색)
// ═══════════════════════════════════════════════
class RentCarScreen extends StatefulWidget {
  const RentCarScreen({super.key});
  @override State<RentCarScreen> createState() => _RentCarScreenState();
}

class _RentCarScreenState extends State<RentCarScreen> {
  String _pickupSido = '', _pickupSg = '';
  String _returnSido = '', _returnSg = '';
  bool _sameReturn = true;
  DateTime _pickupDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _pickupTime = const TimeOfDay(hour: 10, minute: 0);
  DateTime _returnDate = DateTime.now().add(const Duration(days: 2));
  TimeOfDay _returnTime = const TimeOfDay(hour: 10, minute: 0);
  RentCarGrade? _grade;

  String get _pickupFull => _pickupSg.isNotEmpty ? '$_pickupSido $_pickupSg' : _pickupSido;
  String get _returnFull {
    if (_sameReturn) return _pickupFull;
    return _returnSg.isNotEmpty ? '$_returnSido $_returnSg' : _returnSido;
  }
  int get _days => _returnDate.difference(_pickupDate).inDays.clamp(1, 999);
  bool get _canSearch => _pickupSido.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: _card, statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: _bg,
        body: Column(children: [
          // AppBar
          Container(
            color: _card,
            padding: EdgeInsets.fromLTRB(4, top + 4, 16, 14),
            child: Row(children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _pri, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('렌트카', style: GoogleFonts.notoSansKr(color: _pri, fontSize: 18, fontWeight: FontWeight.w900)),
                Text('지역과 날짜를 선택해 차량을 예약하세요', style: GoogleFonts.notoSansKr(color: _sec, fontSize: 11)),
              ])),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RentMyBookingsScreen())),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(border: Border.all(color: _accent.withOpacity(0.5)), borderRadius: BorderRadius.circular(8)),
                  child: Text('내 예약', style: GoogleFonts.notoSansKr(color: _accent, fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
          ),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _label('📍 인수 지역'),
              const SizedBox(height: 8),
              _regionBtn(_pickupFull.isNotEmpty ? _pickupFull : '인수 지역 선택',
                  _pickupFull.isNotEmpty, () => _showRegion(true)),
              const SizedBox(height: 16),
              _label('📍 반납 장소'),
              const SizedBox(height: 8),
              Row(children: [
                _chip('인수 장소 동일', _sameReturn, () => setState(() => _sameReturn = true)),
                const SizedBox(width: 8),
                _chip('다른 장소', !_sameReturn, () => setState(() => _sameReturn = false)),
              ]),
              if (!_sameReturn) ...[
                const SizedBox(height: 8),
                _regionBtn(_returnFull.isNotEmpty ? _returnFull : '반납 지역 선택',
                    _returnFull.isNotEmpty, () => _showRegion(false)),
              ],
              const SizedBox(height: 16),
              _label('📅 인수 일시'),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: _dateTile(_dateStr(_pickupDate), Icons.calendar_today_rounded, () => _pickDate(true))),
                const SizedBox(width: 8),
                Expanded(child: _dateTile(_pickupTime.format(context), Icons.access_time_rounded, () => _pickTime(true))),
              ]),
              const SizedBox(height: 12),
              _label('📅 반납 일시'),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: _dateTile(_dateStr(_returnDate), Icons.calendar_today_rounded, () => _pickDate(false))),
                const SizedBox(width: 8),
                Expanded(child: _dateTile(_returnTime.format(context), Icons.access_time_rounded, () => _pickTime(false))),
              ]),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(color: _green.withOpacity(0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: _green.withOpacity(0.3))),
                child: Row(children: [
                  const Icon(Icons.timer_outlined, color: _green, size: 16),
                  const SizedBox(width: 8),
                  Text('총 대여 기간: ${_days}일', style: GoogleFonts.notoSansKr(color: _green, fontSize: 13, fontWeight: FontWeight.w700)),
                ]),
              ),
              const SizedBox(height: 16),
              _label('🚗 차량 종류 (선택)'),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: RentCarGrade.values.map((g) {
                final on = _grade == g;
                return GestureDetector(
                  onTap: () => setState(() => _grade = on ? null : g),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: on ? _accent.withOpacity(0.15) : _card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: on ? _accent : _border),
                    ),
                    child: Text(g.label, style: GoogleFonts.notoSansKr(color: on ? _accent : _sec, fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                );
              }).toList()),
              const SizedBox(height: 28),
              GestureDetector(
                onTap: _canSearch ? _doSearch : null,
                child: Container(
                  width: double.infinity, height: 54,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: _canSearch ? [_accent, const Color(0xFF0288D1)] : [_border, _border]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.search_rounded, color: _canSearch ? Colors.black : _sec, size: 22),
                    const SizedBox(width: 8),
                    Text('차량 검색', style: GoogleFonts.notoSansKr(
                        color: _canSearch ? Colors.black : _sec, fontSize: 16, fontWeight: FontWeight.w900)),
                  ]),
                ),
              ),
              const SizedBox(height: 32),
            ]),
          )),
        ]),
      ),
    );
  }

  void _doSearch() {
    final pu = DateTime(_pickupDate.year, _pickupDate.month, _pickupDate.day, _pickupTime.hour, _pickupTime.minute);
    final rt = DateTime(_returnDate.year, _returnDate.month, _returnDate.day, _returnTime.hour, _returnTime.minute);
    Navigator.push(context, MaterialPageRoute(builder: (_) => RentCarListScreen(
      pickupRegion: _pickupFull, returnRegion: _returnFull,
      pickupAt: pu, returnAt: rt, grade: _grade,
    )));
  }

  Widget _label(String t) => Text(t, style: GoogleFonts.notoSansKr(color: _pri, fontSize: 14, fontWeight: FontWeight.w700));

  Widget _regionBtn(String t, bool active, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: active ? _accent.withOpacity(0.5) : _border)),
      child: Row(children: [
        Icon(Icons.location_on_rounded, color: active ? _accent : _sec, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(t, style: GoogleFonts.notoSansKr(
            color: active ? _pri : _sec, fontSize: 15, fontWeight: FontWeight.w600))),
        const Icon(Icons.chevron_right_rounded, color: _sec, size: 20),
      ]),
    ),
  );

  Widget _dateTile(String t, IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(12), border: Border.all(color: _border)),
      child: Row(children: [
        Icon(icon, color: _accent, size: 18),
        const SizedBox(width: 8),
        Text(t, style: GoogleFonts.notoSansKr(color: _pri, fontSize: 14, fontWeight: FontWeight.w600)),
      ]),
    ),
  );

  Widget _chip(String t, bool active, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: active ? _accent.withOpacity(0.15) : _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: active ? _accent : _border),
      ),
      child: Text(t, style: GoogleFonts.notoSansKr(color: active ? _accent : _sec, fontSize: 12, fontWeight: FontWeight.w600)),
    ),
  );

  Future<void> _showRegion(bool isPickup) async {
    final r = await showDialog<Map<String, String>>(context: context, builder: (_) => const _RegionDialog());
    if (r != null && mounted) {
      setState(() {
        if (isPickup) {
          _pickupSido = r['sido'] ?? ''; _pickupSg = r['sg'] ?? '';
          if (_sameReturn) { _returnSido = _pickupSido; _returnSg = _pickupSg; }
        } else {
          _returnSido = r['sido'] ?? ''; _returnSg = r['sg'] ?? '';
        }
      });
    }
  }

  Future<void> _pickDate(bool isPickup) async {
    final now = DateTime.now();
    final init = isPickup ? _pickupDate : _returnDate;
    final first = isPickup ? now : _pickupDate;
    final p = await showDatePicker(
      context: context,
      initialDate: init.isBefore(first) ? first : init,
      firstDate: first,
      lastDate: now.add(const Duration(days: 365)),
      builder: (c, child) => Theme(data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: _accent, surface: _card)), child: child!),
    );
    if (p != null && mounted) setState(() {
      if (isPickup) {
        _pickupDate = p;
        if (_returnDate.isBefore(_pickupDate)) _returnDate = _pickupDate.add(const Duration(days: 1));
      } else {
        _returnDate = p;
      }
    });
  }

  Future<void> _pickTime(bool isPickup) async {
    final p = await showTimePicker(
      context: context,
      initialTime: isPickup ? _pickupTime : _returnTime,
      builder: (c, child) => Theme(data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: _accent, surface: _card)), child: child!),
    );
    if (p != null && mounted) setState(() { if (isPickup) _pickupTime = p; else _returnTime = p; });
  }
}

// ═══════════════════════════════════════════════
// 지역 다이얼로그
// ═══════════════════════════════════════════════
class _RegionDialog extends StatefulWidget {
  const _RegionDialog();
  @override State<_RegionDialog> createState() => _RegionDialogState();
}

class _RegionDialogState extends State<_RegionDialog> {
  String? _sido;
  String _q = '';
  final _ctrl = TextEditingController();

  List<String> get _sidos {
    if (_q.isEmpty) return _regionData.keys.toList();
    return _regionData.keys.where((s) {
      if (s.contains(_q)) return true;
      return (_regionData[s] ?? []).any((sg) => sg.contains(_q));
    }).toList();
  }

  List<String> get _sgs {
    if (_sido == null) return [];
    final list = _regionData[_sido] ?? [];
    if (_q.isEmpty) return list;
    return list.where((s) => s.contains(_q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: _card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.72,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
            child: Row(children: [
              const Icon(Icons.location_on_rounded, color: _accent, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text('지역 선택', style: GoogleFonts.notoSansKr(color: _pri, fontSize: 16, fontWeight: FontWeight.w800))),
              IconButton(icon: const Icon(Icons.close_rounded, color: _sec, size: 20), onPressed: () => Navigator.pop(context)),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Container(
              decoration: BoxDecoration(color: _navy, borderRadius: BorderRadius.circular(10), border: Border.all(color: _border)),
              child: TextField(
                controller: _ctrl,
                style: const TextStyle(color: _pri, fontSize: 14),
                decoration: InputDecoration(
                  hintText: '시/도, 시/군/구 검색',
                  hintStyle: TextStyle(color: _sec.withOpacity(0.6), fontSize: 13),
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.search_rounded, color: _sec, size: 18),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onChanged: (v) => setState(() => _q = v),
              ),
            ),
          ),
          Divider(color: _border, height: 1),
          Expanded(child: _sido == null ? _buildSidos() : _buildSgs()),
        ]),
      ),
    );
  }

  Widget _buildSidos() => ListView.builder(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    itemCount: _sidos.length,
    itemBuilder: (_, i) {
      final s = _sidos[i];
      final sgs = _regionData[s] ?? [];
      return ListTile(
        dense: true,
        title: Text(s, style: GoogleFonts.notoSansKr(color: _pri, fontSize: 14, fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right_rounded, color: _sec, size: 18),
        onTap: () {
          if (sgs.length == 1) {
            Navigator.pop(context, {'sido': s, 'sg': sgs.first});
          } else {
            setState(() { _sido = s; _q = ''; _ctrl.clear(); });
          }
        },
      );
    },
  );

  Widget _buildSgs() => Column(children: [
    GestureDetector(
      onTap: () => setState(() { _sido = null; _q = ''; _ctrl.clear(); }),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
        child: Row(children: [
          const Icon(Icons.arrow_back_rounded, color: _accent, size: 16),
          const SizedBox(width: 4),
          Text('$_sido', style: GoogleFonts.notoSansKr(color: _accent, fontSize: 13, fontWeight: FontWeight.w700)),
          Text(' · 시/군/구 선택', style: GoogleFonts.notoSansKr(color: _sec, fontSize: 12)),
          const Spacer(),
        ]),
      ),
    ),
    Divider(color: _border, height: 1),
    Expanded(child: ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      itemCount: _sgs.length,
      itemBuilder: (_, i) {
        final sg = _sgs[i];
        return ListTile(
          dense: true,
          title: Text(sg, style: GoogleFonts.notoSansKr(color: _pri, fontSize: 14, fontWeight: FontWeight.w600)),
          onTap: () => Navigator.pop(context, {'sido': _sido!, 'sg': sg}),
        );
      },
    )),
  ]);
}

// ═══════════════════════════════════════════════
// 차량 리스트
// ═══════════════════════════════════════════════
class RentCarListScreen extends StatefulWidget {
  final String pickupRegion, returnRegion;
  final DateTime pickupAt, returnAt;
  final RentCarGrade? grade;
  const RentCarListScreen({super.key, required this.pickupRegion, required this.returnRegion,
      required this.pickupAt, required this.returnAt, this.grade});
  @override State<RentCarListScreen> createState() => _RentCarListScreenState();
}

class _RentCarListScreenState extends State<RentCarListScreen> {
  String _sort = 'popular';
  RentCarGrade? _filterGrade;
  RentCarFuel? _filterFuel;
  int? _maxPrice;

  @override
  void initState() { super.initState(); _filterGrade = widget.grade; }

  int get _days => widget.returnAt.difference(widget.pickupAt).inDays.clamp(1, 999);

  List<RentCar> get _cars {
    final region = widget.pickupRegion.split(' ').first;
    return RentCarState().search(region: region, grade: _filterGrade, fuel: _filterFuel, maxPrice: _maxPrice, sort: _sort);
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final cars = _cars;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: _card, statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: _bg,
        body: Column(children: [
          Container(
            color: _card,
            padding: EdgeInsets.fromLTRB(4, top + 4, 16, 8),
            child: Column(children: [
              Row(children: [
                IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _pri, size: 20), onPressed: () => Navigator.pop(context)),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('차량 검색 결과', style: GoogleFonts.notoSansKr(color: _pri, fontSize: 16, fontWeight: FontWeight.w800)),
                  Text('${widget.pickupRegion} · ${_days}일 · ${cars.length}대', style: GoogleFonts.notoSansKr(color: _sec, fontSize: 11)),
                ])),
                GestureDetector(
                  onTap: _showFilter,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(border: Border.all(color: _border), borderRadius: BorderRadius.circular(8)),
                    child: Row(children: [
                      const Icon(Icons.tune_rounded, color: _sec, size: 16),
                      const SizedBox(width: 4),
                      Text('필터', style: GoogleFonts.notoSansKr(color: _sec, fontSize: 12)),
                    ]),
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  _sortChip('인기순', 'popular'), const SizedBox(width: 6),
                  _sortChip('가격순', 'price'), const SizedBox(width: 6),
                  _sortChip('추천순', 'rating'), const SizedBox(width: 6),
                  if (_filterGrade != null) _rmChip(_filterGrade!.label, () => setState(() => _filterGrade = null)),
                  if (_filterFuel != null) _rmChip(_filterFuel!.label, () => setState(() => _filterFuel = null)),
                  if (_maxPrice != null) _rmChip('${_won(_maxPrice!)}이하', () => setState(() => _maxPrice = null)),
                ]),
              ),
              const SizedBox(height: 4),
            ]),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                if (cars.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.directions_car_outlined, color: _sec, size: 48),
                      const SizedBox(height: 12),
                      Text('검색된 차량이 없습니다', style: GoogleFonts.notoSansKr(color: _sec, fontSize: 14)),
                    ])),
                  )
                else
                  ...cars.map((car) => _CarCard(
                    car: car, days: _days,
                    pickupAt: widget.pickupAt, returnAt: widget.returnAt,
                    pickupRegion: widget.pickupRegion, returnRegion: widget.returnRegion,
                  )),
                const SizedBox(height: 20),
                Row(children: [
                  const Icon(Icons.store_rounded, color: _accent, size: 18),
                  const SizedBox(width: 6),
                  Text('내 위치에서 가까운 렌트카 점포',
                      style: GoogleFonts.notoSansKr(color: _pri, fontSize: 15, fontWeight: FontWeight.w800)),
                ]),
                const SizedBox(height: 4),
                Text('가까운 순', style: GoogleFonts.notoSansKr(color: _sec, fontSize: 11)),
                const SizedBox(height: 10),
                ..._sampleShops.map((s) => _ShopCard(
                  shop: s,
                  pickupAt: widget.pickupAt, returnAt: widget.returnAt,
                  pickupRegion: widget.pickupRegion, returnRegion: widget.returnRegion,
                  days: _days,
                  firstCar: cars.isNotEmpty ? cars.first : null,
                )),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _sortChip(String label, String v) {
    final on = _sort == v;
    return GestureDetector(
      onTap: () => setState(() => _sort = v),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: on ? _accent.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: on ? _accent : _border),
        ),
        child: Text(label, style: GoogleFonts.notoSansKr(color: on ? _accent : _sec, fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _rmChip(String t, VoidCallback onRemove) => Padding(
    padding: const EdgeInsets.only(right: 6),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: _orange.withOpacity(0.12), borderRadius: BorderRadius.circular(16), border: Border.all(color: _orange.withOpacity(0.4))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(t, style: GoogleFonts.notoSansKr(color: _orange, fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(width: 4),
        GestureDetector(onTap: onRemove, child: const Icon(Icons.close_rounded, color: _orange, size: 14)),
      ]),
    ),
  );

  void _showFilter() => showModalBottomSheet(
    context: context,
    backgroundColor: _card,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => _FilterSheet(
      grade: _filterGrade, fuel: _filterFuel, maxPrice: _maxPrice,
      onApply: (g, f, p) => setState(() { _filterGrade = g; _filterFuel = f; _maxPrice = p; }),
    ),
  );
}

// ── 샘플 점포 데이터 ──────────────────────────────────────────
class _RentShop {
  final String name, region, phone;
  final double distanceKm;
  final int carCount;
  final bool available;
  const _RentShop({required this.name, required this.region, required this.phone,
      required this.distanceKm, required this.carCount, required this.available});
}

const _sampleShops = [
  _RentShop(name: '모인카렌트 강남점', region: '서울 강남구', phone: '02-1234-5678', distanceKm: 0.8, carCount: 24, available: true),
  _RentShop(name: '서울렌터카 서초점', region: '서울 서초구', phone: '02-2345-6789', distanceKm: 1.4, carCount: 18, available: true),
  _RentShop(name: '나이스렌트카 송파점', region: '서울 송파구', phone: '02-3456-7890', distanceKm: 2.1, carCount: 31, available: true),
  _RentShop(name: '그린렌터카 마포점', region: '서울 마포구', phone: '02-4567-8901', distanceKm: 3.5, carCount: 15, available: false),
  _RentShop(name: '하이렌트카 강서점', region: '서울 강서구', phone: '02-5678-9012', distanceKm: 5.2, carCount: 20, available: true),
];

// ── 점포 카드 ─────────────────────────────────────────────────
class _ShopCard extends StatelessWidget {
  final _RentShop shop;
  final DateTime pickupAt, returnAt;
  final String pickupRegion, returnRegion;
  final int days;
  final RentCar? firstCar;
  const _ShopCard({required this.shop, required this.pickupAt, required this.returnAt,
      required this.pickupRegion, required this.returnRegion, required this.days, this.firstCar});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: _accent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.store_rounded, color: _accent, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(shop.name, style: GoogleFonts.notoSansKr(color: _pri, fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(shop.region, style: GoogleFonts.notoSansKr(color: _sec, fontSize: 11)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: shop.available ? _green.withOpacity(0.15) : _red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(shop.available ? '예약가능' : '마감',
                style: GoogleFonts.notoSansKr(color: shop.available ? _green : _red, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          const Icon(Icons.near_me_rounded, color: _sec, size: 13),
          Text(' ${shop.distanceKm}km',
              style: GoogleFonts.notoSansKr(color: _sec, fontSize: 12)),
          const SizedBox(width: 12),
          const Icon(Icons.directions_car_rounded, color: _sec, size: 13),
          Text(' 보유 ${shop.carCount}대',
              style: GoogleFonts.notoSansKr(color: _sec, fontSize: 12)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('${shop.phone} 로 전화 연결합니다'),
                  backgroundColor: _accent.withOpacity(0.9),
                  duration: const Duration(seconds: 2),
                ));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                    border: Border.all(color: _border), borderRadius: BorderRadius.circular(8)),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.phone_rounded, color: _sec, size: 15),
                  const SizedBox(width: 4),
                  Text('전화', style: GoogleFonts.notoSansKr(color: _sec, fontSize: 12, fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('지도 앱으로 길찾기를 시작합니다'),
                  duration: Duration(seconds: 2),
                ));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                    border: Border.all(color: _border), borderRadius: BorderRadius.circular(8)),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.map_rounded, color: _sec, size: 15),
                  const SizedBox(width: 4),
                  Text('길찾기', style: GoogleFonts.notoSansKr(color: _sec, fontSize: 12, fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: shop.available ? () {
                if (firstCar != null) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => RentCarBookingScreen(
                    car: firstCar!,
                    days: days,
                    pickupAt: pickupAt, returnAt: returnAt,
                    pickupRegion: pickupRegion, returnRegion: returnRegion,
                    insurance: RentInsuranceType.standard,
                    extraOptions: const [],
                    totalPrice: firstCar!.pricePerDay * days,
                  )));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('차량을 먼저 선택해 주세요'),
                    duration: Duration(seconds: 2),
                  ));
                }
              } : null,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                    color: shop.available ? _accent.withOpacity(0.15) : _border.withOpacity(0.3),
                    border: Border.all(color: shop.available ? _accent.withOpacity(0.5) : _border),
                    borderRadius: BorderRadius.circular(8)),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.calendar_today_rounded, color: shop.available ? _accent : _sec, size: 15),
                  const SizedBox(width: 4),
                  Text('예약', style: GoogleFonts.notoSansKr(
                      color: shop.available ? _accent : _sec, fontSize: 12, fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
          ),
        ]),
      ]),
    );
  }
}

class _CarCard extends StatelessWidget {
  final RentCar car;
  final int days;
  final DateTime pickupAt, returnAt;
  final String pickupRegion, returnRegion;
  const _CarCard({required this.car, required this.days, required this.pickupAt,
      required this.returnAt, required this.pickupRegion, required this.returnRegion});

  @override
  Widget build(BuildContext context) {
    final disc = car.originalPrice != null && car.originalPrice! > car.dailyPrice;
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RentCarDetailScreen(
        car: car, days: days, pickupAt: pickupAt, returnAt: returnAt,
        pickupRegion: pickupRegion, returnRegion: returnRegion,
      ))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(16), border: Border.all(color: _border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(car.images.first, height: 160, width: double.infinity, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(height: 160, color: _navy, child: const Icon(Icons.directions_car_outlined, color: _sec, size: 48))),
            ),
            Positioned(top: 10, left: 10, child: Row(children: [
              _badge(car.grade.label, _accent),
              const SizedBox(width: 6),
              _badge(car.fuel.label, car.fuel == RentCarFuel.electric ? _green : _orange),
            ])),
            if (disc) Positioned(top: 10, right: 10, child: _badge('특가', _red)),
            if (car.instantBooking) Positioned(bottom: 10, right: 10, child: _badge('즉시예약', _green)),
          ]),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${car.brand} ${car.name}', style: GoogleFonts.notoSansKr(color: _pri, fontSize: 16, fontWeight: FontWeight.w900)),
                  Text('${car.year}년식 · ${car.seats}인승', style: GoogleFonts.notoSansKr(color: _sec, fontSize: 12)),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  if (disc) Text(_won(car.originalPrice!), style: GoogleFonts.notoSansKr(color: _sec, fontSize: 11, decoration: TextDecoration.lineThrough)),
                  Row(children: [
                    Text(_won(car.dailyPrice), style: GoogleFonts.notoSansKr(color: _accent, fontSize: 18, fontWeight: FontWeight.w900)),
                    Text(' /일', style: GoogleFonts.notoSansKr(color: _sec, fontSize: 11)),
                  ]),
                  Text('${days}일 = ${_won(car.dailyPrice * days)}', style: GoogleFonts.notoSansKr(color: _green, fontSize: 11, fontWeight: FontWeight.w700)),
                ]),
              ]),
              const SizedBox(height: 10),
              Wrap(spacing: 6, runSpacing: 4, children: car.options.take(3).map((o) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: _navy, borderRadius: BorderRadius.circular(6)),
                child: Text(o, style: GoogleFonts.notoSansKr(color: _sec, fontSize: 10)),
              )).toList()),
              const SizedBox(height: 10),
              Row(children: [
                const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 14),
                const SizedBox(width: 2),
                Text('${car.rating} (${car.reviewCount})', style: GoogleFonts.notoSansKr(color: _sec, fontSize: 11)),
                const SizedBox(width: 10),
                const Icon(Icons.location_on_rounded, color: _sec, size: 12),
                Text('${car.region} ${car.branchName}', style: GoogleFonts.notoSansKr(color: _sec, fontSize: 11)),
                const Spacer(),
                if (car.insuranceIncluded) _badge('보험포함', _purple),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _badge(String t, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: c.withOpacity(0.2), borderRadius: BorderRadius.circular(6), border: Border.all(color: c.withOpacity(0.5))),
    child: Text(t, style: GoogleFonts.notoSansKr(color: c, fontSize: 10, fontWeight: FontWeight.w700)),
  );
}

class _FilterSheet extends StatefulWidget {
  final RentCarGrade? grade;
  final RentCarFuel? fuel;
  final int? maxPrice;
  final Function(RentCarGrade?, RentCarFuel?, int?) onApply;
  const _FilterSheet({this.grade, this.fuel, this.maxPrice, required this.onApply});
  @override State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  RentCarGrade? _grade;
  RentCarFuel? _fuel;
  int? _maxPrice;

  @override
  void initState() { super.initState(); _grade = widget.grade; _fuel = widget.fuel; _maxPrice = widget.maxPrice; }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('필터', style: GoogleFonts.notoSansKr(color: _pri, fontSize: 16, fontWeight: FontWeight.w800)),
          const Spacer(),
          TextButton(onPressed: () => setState(() { _grade = null; _fuel = null; _maxPrice = null; }),
              child: Text('초기화', style: GoogleFonts.notoSansKr(color: _sec, fontSize: 13))),
        ]),
        const SizedBox(height: 10),
        Text('차량 종류', style: GoogleFonts.notoSansKr(color: _sec, fontSize: 12)),
        const SizedBox(height: 8),
        Wrap(spacing: 6, runSpacing: 6, children: RentCarGrade.values.map((g) {
          final on = _grade == g;
          return GestureDetector(
            onTap: () => setState(() => _grade = on ? null : g),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(color: on ? _accent.withOpacity(0.15) : _navy, borderRadius: BorderRadius.circular(20), border: Border.all(color: on ? _accent : _border)),
              child: Text(g.label, style: GoogleFonts.notoSansKr(color: on ? _accent : _sec, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          );
        }).toList()),
        const SizedBox(height: 12),
        Text('연료', style: GoogleFonts.notoSansKr(color: _sec, fontSize: 12)),
        const SizedBox(height: 8),
        Wrap(spacing: 6, runSpacing: 6, children: RentCarFuel.values.map((f) {
          final on = _fuel == f;
          return GestureDetector(
            onTap: () => setState(() => _fuel = on ? null : f),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(color: on ? _green.withOpacity(0.15) : _navy, borderRadius: BorderRadius.circular(20), border: Border.all(color: on ? _green : _border)),
              child: Text(f.label, style: GoogleFonts.notoSansKr(color: on ? _green : _sec, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          );
        }).toList()),
        const SizedBox(height: 12),
        Text('최대 일일 요금', style: GoogleFonts.notoSansKr(color: _sec, fontSize: 12)),
        const SizedBox(height: 8),
        Wrap(spacing: 6, runSpacing: 6, children: [50000, 80000, 100000, 150000].map((p) {
          final on = _maxPrice == p;
          return GestureDetector(
            onTap: () => setState(() => _maxPrice = on ? null : p),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(color: on ? _orange.withOpacity(0.15) : _navy, borderRadius: BorderRadius.circular(20), border: Border.all(color: on ? _orange : _border)),
              child: Text('${_won(p)} 이하', style: GoogleFonts.notoSansKr(color: on ? _orange : _sec, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          );
        }).toList()),
        const SizedBox(height: 20),
        SizedBox(width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
            onPressed: () { widget.onApply(_grade, _fuel, _maxPrice); Navigator.pop(context); },
            child: Text('적용하기', style: GoogleFonts.notoSansKr(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w800)),
          ),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════
// 차량 상세
// ═══════════════════════════════════════════════
class RentCarDetailScreen extends StatefulWidget {
  final RentCar car;
  final int days;
  final DateTime pickupAt, returnAt;
  final String pickupRegion, returnRegion;
  const RentCarDetailScreen({super.key, required this.car, required this.days,
      required this.pickupAt, required this.returnAt, required this.pickupRegion, required this.returnRegion});
  @override State<RentCarDetailScreen> createState() => _RentCarDetailScreenState();
}

class _RentCarDetailScreenState extends State<RentCarDetailScreen> {
  RentInsuranceType _ins = RentInsuranceType.basic;
  final Set<String> _extras = {};
  final _optList = const [
    {'name': '카시트', 'price': 10000},
    {'name': '네비게이션', 'price': 5000},
    {'name': '와이파이', 'price': 8000},
    {'name': '블랙박스', 'price': 5000},
  ];

  int get _insTotal => _ins.dailyPrice * widget.days;
  int get _extTotal => _extras.fold(0, (s, n) {
    final item = _optList.firstWhere((o) => o['name'] == n, orElse: () => const {'price': 0});
    return s + ((item['price'] as int) * widget.days);
  });
  int get _base => widget.car.dailyPrice * widget.days;
  int get _total => _base + _insTotal + _extTotal;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: _bg,
        body: Stack(children: [
          CustomScrollView(slivers: [
            SliverAppBar(
              expandedHeight: 230,
              pinned: true,
              backgroundColor: _card,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _pri, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Image.network(widget.car.images.first, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: _navy, child: const Icon(Icons.directions_car_outlined, color: _sec, size: 56))),
              ),
            ),
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // 기본 정보
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Wrap(spacing: 6, children: [
                      _tag(widget.car.grade.label, _accent),
                      _tag(widget.car.fuel.label, widget.car.fuel == RentCarFuel.electric ? _green : _orange),
                    ]),
                    const SizedBox(height: 6),
                    Text('${widget.car.brand} ${widget.car.name}', style: GoogleFonts.notoSansKr(color: _pri, fontSize: 22, fontWeight: FontWeight.w900)),
                    Text('${widget.car.year}년식 · ${widget.car.seats}인승', style: GoogleFonts.notoSansKr(color: _sec, fontSize: 13)),
                  ])),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(_won(widget.car.dailyPrice), style: GoogleFonts.notoSansKr(color: _accent, fontSize: 22, fontWeight: FontWeight.w900)),
                    Text('/일', style: GoogleFonts.notoSansKr(color: _sec, fontSize: 11)),
                    Row(children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 14),
                      Text(' ${widget.car.rating}', style: GoogleFonts.notoSansKr(color: _sec, fontSize: 12)),
                    ]),
                  ]),
                ]),
                const SizedBox(height: 16),

                // 대여 정보
                _sec2('📋 대여 정보'),
                const SizedBox(height: 8),
                _infoBox([
                  _ir('인수 지역', widget.pickupRegion),
                  _ir('반납 지역', widget.returnRegion),
                  _ir('인수 일시', _dtStr(widget.pickupAt)),
                  _ir('반납 일시', _dtStr(widget.returnAt)),
                  _ir('대여 기간', '${widget.days}일'),
                ]),
                const SizedBox(height: 16),

                // 기본 옵션
                _sec2('🔧 기본 옵션'),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 8, children: widget.car.options.map((o) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: _navy, borderRadius: BorderRadius.circular(8), border: Border.all(color: _border)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.check_circle_rounded, color: _green, size: 14),
                    const SizedBox(width: 4),
                    Text(o, style: GoogleFonts.notoSansKr(color: _pri, fontSize: 12)),
                  ]),
                )).toList()),
                const SizedBox(height: 16),

                // 보험
                _sec2('🛡️ 보험 선택'),
                const SizedBox(height: 8),
                ...RentInsuranceType.values.map((ins) {
                  final on = _ins == ins;
                  return GestureDetector(
                    onTap: () => setState(() => _ins = ins),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: on ? _accent.withOpacity(0.08) : _navy,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: on ? _accent : _border, width: on ? 1.5 : 1),
                      ),
                      child: Row(children: [
                        Container(width: 20, height: 20,
                          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: on ? _accent : _border, width: 2), color: on ? _accent : Colors.transparent),
                          child: on ? const Icon(Icons.check_rounded, color: Colors.black, size: 13) : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(ins.label, style: GoogleFonts.notoSansKr(color: on ? _accent : _pri, fontSize: 14, fontWeight: FontWeight.w700)),
                          Text(_insDesc(ins), style: GoogleFonts.notoSansKr(color: _sec, fontSize: 11)),
                        ])),
                        Text(ins.dailyPrice == 0 ? '무료' : '${_won(ins.dailyPrice)}/일',
                            style: GoogleFonts.notoSansKr(color: on ? _accent : _sec, fontSize: 13, fontWeight: FontWeight.w700)),
                      ]),
                    ),
                  );
                }),
                const SizedBox(height: 16),

                // 추가 옵션
                _sec2('➕ 추가 옵션'),
                const SizedBox(height: 8),
                ..._optList.map((opt) {
                  final name = opt['name'] as String;
                  final price = opt['price'] as int;
                  final on = _extras.contains(name);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(color: on ? _purple.withOpacity(0.08) : _navy, borderRadius: BorderRadius.circular(12), border: Border.all(color: on ? _purple : _border)),
                    child: Row(children: [
                      Expanded(child: Text(name, style: GoogleFonts.notoSansKr(color: on ? _pri : _sec, fontSize: 14, fontWeight: FontWeight.w600))),
                      Text('${_won(price)}/일', style: GoogleFonts.notoSansKr(color: on ? _purple : _sec, fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => setState(() { if (on) _extras.remove(name); else _extras.add(name); }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: on ? _purple : Colors.transparent, borderRadius: BorderRadius.circular(8), border: Border.all(color: on ? _purple : _border)),
                          child: Text(on ? '해제' : '추가', style: GoogleFonts.notoSansKr(color: on ? Colors.white : _sec, fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ]),
                  );
                }),
                const SizedBox(height: 16),

                // 요금 상세
                _sec2('💰 요금 상세'),
                const SizedBox(height: 8),
                _infoBox([
                  _pr('기본 대여료', '${_won(widget.car.dailyPrice)} × ${widget.days}일', _won(_base)),
                  _pr('보험료', '${_won(_ins.dailyPrice)} × ${widget.days}일', _won(_insTotal)),
                  if (_extTotal > 0) _pr('추가 옵션', '', _won(_extTotal)),
                  const Divider(color: _border, height: 20),
                  Row(children: [
                    Text('총 결제 금액', style: GoogleFonts.notoSansKr(color: _pri, fontSize: 15, fontWeight: FontWeight.w800)),
                    const Spacer(),
                    Text(_won(_total), style: GoogleFonts.notoSansKr(color: _accent, fontSize: 18, fontWeight: FontWeight.w900)),
                  ]),
                ]),
              ]),
            )),
          ]),

          // 하단 예약 버튼
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              color: _card,
              padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
              child: Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('총 결제 금액', style: GoogleFonts.notoSansKr(color: _sec, fontSize: 11)),
                  Text(_won(_total), style: GoogleFonts.notoSansKr(color: _accent, fontSize: 20, fontWeight: FontWeight.w900)),
                ]),
                const SizedBox(width: 16),
                Expanded(child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RentCarBookingScreen(
                    car: widget.car, days: widget.days,
                    pickupAt: widget.pickupAt, returnAt: widget.returnAt,
                    pickupRegion: widget.pickupRegion, returnRegion: widget.returnRegion,
                    insurance: _ins, extraOptions: _extras.toList(), totalPrice: _total,
                  ))),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(gradient: const LinearGradient(colors: [_accent, Color(0xFF0288D1)]), borderRadius: BorderRadius.circular(12)),
                    child: Center(child: Text('예약하기', style: GoogleFonts.notoSansKr(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w900))),
                  ),
                )),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  String _insDesc(RentInsuranceType ins) {
    switch (ins) {
      case RentInsuranceType.basic: return '사고 시 자기부담금 발생 (최대 50만원)';
      case RentInsuranceType.fullCoverage: return '사고 시 자기부담금 없음 · 완전 보장';
      case RentInsuranceType.none: return '보험 없음 · 사고 시 전액 본인 부담';
    }
  }

  Widget _sec2(String t) => Text(t, style: GoogleFonts.notoSansKr(color: _pri, fontSize: 15, fontWeight: FontWeight.w800));
  Widget _tag(String t, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(6), border: Border.all(color: c.withOpacity(0.4))),
    child: Text(t, style: GoogleFonts.notoSansKr(color: c, fontSize: 11, fontWeight: FontWeight.w700)),
  );
  Widget _infoBox(List<Widget> children) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: _navy, borderRadius: BorderRadius.circular(12), border: Border.all(color: _border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
  );
  Widget _ir(String k, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [
    SizedBox(width: 80, child: Text(k, style: GoogleFonts.notoSansKr(color: _sec, fontSize: 12))),
    Expanded(child: Text(v, style: GoogleFonts.notoSansKr(color: _pri, fontSize: 13, fontWeight: FontWeight.w600))),
  ]));
  Widget _pr(String k, String sub, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(k, style: GoogleFonts.notoSansKr(color: _pri, fontSize: 13)),
      if (sub.isNotEmpty) Text(sub, style: GoogleFonts.notoSansKr(color: _sec, fontSize: 10)),
    ])),
    Text(v, style: GoogleFonts.notoSansKr(color: _pri, fontSize: 13, fontWeight: FontWeight.w600)),
  ]));
}

// ═══════════════════════════════════════════════
// 예약 정보 입력
// ═══════════════════════════════════════════════
class RentCarBookingScreen extends StatefulWidget {
  final RentCar car;
  final int days;
  final DateTime pickupAt, returnAt;
  final String pickupRegion, returnRegion;
  final RentInsuranceType insurance;
  final List<String> extraOptions;
  final int totalPrice;
  const RentCarBookingScreen({super.key, required this.car, required this.days,
      required this.pickupAt, required this.returnAt, required this.pickupRegion,
      required this.returnRegion, required this.insurance, required this.extraOptions, required this.totalPrice});
  @override State<RentCarBookingScreen> createState() => _RentCarBookingScreenState();
}

class _RentCarBookingScreenState extends State<RentCarBookingScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _license = TextEditingController();
  bool _agree = false;

  bool get _ok => _name.text.trim().isNotEmpty && _phone.text.trim().length >= 10
      && _license.text.trim().length >= 8 && _agree;

  @override
  void dispose() { _name.dispose(); _phone.dispose(); _license.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: _card, statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: _bg,
        body: Column(children: [
          Container(color: _card, padding: EdgeInsets.fromLTRB(4, top + 4, 16, 14),
            child: Row(children: [
              IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _pri, size: 20), onPressed: () => Navigator.pop(context)),
              Text('예약 정보 입력', style: GoogleFonts.notoSansKr(color: _pri, fontSize: 17, fontWeight: FontWeight.w800)),
            ]),
          ),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // 요약
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(14), border: Border.all(color: _accent.withOpacity(0.3))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${widget.car.brand} ${widget.car.name}', style: GoogleFonts.notoSansKr(color: _pri, fontSize: 16, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  _sr('인수', '${widget.pickupRegion} · ${_dtStr(widget.pickupAt)}'),
                  _sr('반납', '${widget.returnRegion} · ${_dtStr(widget.returnAt)}'),
                  _sr('기간', '${widget.days}일'),
                  _sr('보험', widget.insurance.label),
                  const Divider(color: _border, height: 16),
                  Row(children: [
                    Text('총 결제 금액', style: GoogleFonts.notoSansKr(color: _pri, fontSize: 14, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    Text(_won(widget.totalPrice), style: GoogleFonts.notoSansKr(color: _accent, fontSize: 18, fontWeight: FontWeight.w900)),
                  ]),
                ]),
              ),
              const SizedBox(height: 20),
              _fl('이름'), const SizedBox(height: 6),
              _tf(_name, '예약자 이름', TextInputType.name),
              const SizedBox(height: 12),
              _fl('연락처'), const SizedBox(height: 6),
              _tf(_phone, '010-0000-0000', TextInputType.phone),
              const SizedBox(height: 12),
              _fl('운전면허 번호'), const SizedBox(height: 6),
              _tf(_license, '예) 서울 12-345678-00', TextInputType.text),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => setState(() => _agree = !_agree),
                child: Row(children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22, height: 22,
                    decoration: BoxDecoration(color: _agree ? _accent : Colors.transparent, borderRadius: BorderRadius.circular(6), border: Border.all(color: _agree ? _accent : _border, width: 1.5)),
                    child: _agree ? const Icon(Icons.check_rounded, color: Colors.black, size: 15) : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text('렌트카 이용약관 및 개인정보 처리방침에 동의합니다.', style: GoogleFonts.notoSansKr(color: _sec, fontSize: 13))),
                ]),
              ),
              const SizedBox(height: 28),
              GestureDetector(
                onTap: _ok ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => RentCarPaymentScreen(
                  car: widget.car, days: widget.days,
                  pickupAt: widget.pickupAt, returnAt: widget.returnAt,
                  pickupRegion: widget.pickupRegion, returnRegion: widget.returnRegion,
                  insurance: widget.insurance, extraOptions: widget.extraOptions,
                  totalPrice: widget.totalPrice,
                  userName: _name.text.trim(), userPhone: _phone.text.trim(), licenseNo: _license.text.trim(),
                ))) : null,
                child: Container(
                  width: double.infinity, height: 54,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: _ok ? [_accent, const Color(0xFF0288D1)] : [_border, _border]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(child: Text('결제 진행', style: GoogleFonts.notoSansKr(color: _ok ? Colors.black : _sec, fontSize: 16, fontWeight: FontWeight.w900))),
                ),
              ),
            ]),
          )),
        ]),
      ),
    );
  }

  Widget _sr(String k, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(children: [
    SizedBox(width: 40, child: Text(k, style: GoogleFonts.notoSansKr(color: _sec, fontSize: 12))),
    Expanded(child: Text(v, style: GoogleFonts.notoSansKr(color: _pri, fontSize: 12, fontWeight: FontWeight.w600))),
  ]));
  Widget _fl(String t) => Text(t, style: GoogleFonts.notoSansKr(color: _pri, fontSize: 14, fontWeight: FontWeight.w700));
  Widget _tf(TextEditingController c, String hint, TextInputType type) => Container(
    decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(12), border: Border.all(color: _border)),
    child: TextField(
      controller: c, keyboardType: type,
      style: const TextStyle(color: _pri, fontSize: 14),
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: _sec.withOpacity(0.5), fontSize: 13), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14)),
    ),
  );
}

// ═══════════════════════════════════════════════
// 결제 화면
// ═══════════════════════════════════════════════
class RentCarPaymentScreen extends StatefulWidget {
  final RentCar car;
  final int days;
  final DateTime pickupAt, returnAt;
  final String pickupRegion, returnRegion;
  final RentInsuranceType insurance;
  final List<String> extraOptions;
  final int totalPrice;
  final String userName, userPhone, licenseNo;
  const RentCarPaymentScreen({super.key, required this.car, required this.days,
      required this.pickupAt, required this.returnAt, required this.pickupRegion,
      required this.returnRegion, required this.insurance, required this.extraOptions,
      required this.totalPrice, required this.userName, required this.userPhone, required this.licenseNo});
  @override State<RentCarPaymentScreen> createState() => _RentCarPaymentScreenState();
}

class _RentCarPaymentScreenState extends State<RentCarPaymentScreen> {
  String _method = 'card';
  bool _processing = false;

  final _methods = const [
    {'key': 'card', 'label': '신용/체크카드'},
    {'key': 'kakao', 'label': '카카오페이'},
    {'key': 'naver', 'label': '네이버페이'},
    {'key': 'toss', 'label': '토스페이'},
  ];

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: _card, statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: _bg,
        body: Column(children: [
          Container(color: _card, padding: EdgeInsets.fromLTRB(4, top + 4, 16, 14),
            child: Row(children: [
              IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _pri, size: 20), onPressed: () => Navigator.pop(context)),
              Text('결제', style: GoogleFonts.notoSansKr(color: _pri, fontSize: 17, fontWeight: FontWeight.w800)),
            ]),
          ),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(14), border: Border.all(color: _border)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('결제 상세', style: GoogleFonts.notoSansKr(color: _sec, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Text('${widget.car.brand} ${widget.car.name}', style: GoogleFonts.notoSansKr(color: _pri, fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('${widget.pickupRegion} → ${widget.returnRegion} · ${widget.days}일', style: GoogleFonts.notoSansKr(color: _sec, fontSize: 12)),
                  const Divider(color: _border, height: 20),
                  Row(children: [
                    Text('예약자', style: GoogleFonts.notoSansKr(color: _sec, fontSize: 12)),
                    const Spacer(),
                    Text(widget.userName, style: GoogleFonts.notoSansKr(color: _pri, fontSize: 13, fontWeight: FontWeight.w600)),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    Text('총 결제 금액', style: GoogleFonts.notoSansKr(color: _pri, fontSize: 15, fontWeight: FontWeight.w800)),
                    const Spacer(),
                    Text(_won(widget.totalPrice), style: GoogleFonts.notoSansKr(color: _accent, fontSize: 20, fontWeight: FontWeight.w900)),
                  ]),
                ]),
              ),
              const SizedBox(height: 20),
              Text('결제 수단', style: GoogleFonts.notoSansKr(color: _pri, fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              ..._methods.map((m) {
                final on = _method == m['key'];
                return GestureDetector(
                  onTap: () => setState(() => _method = m['key']!),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: on ? _accent.withOpacity(0.08) : _card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: on ? _accent : _border, width: on ? 1.5 : 1),
                    ),
                    child: Row(children: [
                      Container(width: 20, height: 20,
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: on ? _accent : _border, width: 2), color: on ? _accent : Colors.transparent),
                        child: on ? const Icon(Icons.check_rounded, color: Colors.black, size: 13) : null,
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.credit_card_rounded, color: _sec, size: 20),
                      const SizedBox(width: 10),
                      Text(m['label']!, style: GoogleFonts.notoSansKr(color: on ? _pri : _sec, fontSize: 14, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                );
              }),
              const SizedBox(height: 28),
              GestureDetector(
                onTap: _processing ? null : _pay,
                child: Container(
                  width: double.infinity, height: 54,
                  decoration: BoxDecoration(gradient: const LinearGradient(colors: [_accent, Color(0xFF0288D1)]), borderRadius: BorderRadius.circular(14)),
                  child: Center(child: _processing
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5))
                      : Text('${_won(widget.totalPrice)} 결제하기', style: GoogleFonts.notoSansKr(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w900))),
                ),
              ),
            ]),
          )),
        ]),
      ),
    );
  }

  Future<void> _pay() async {
    setState(() => _processing = true);
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    final b = RentCarState().addBooking(
      car: widget.car,
      pickupRegion: widget.pickupRegion, pickupBranch: widget.car.branchName,
      returnRegion: widget.returnRegion, returnBranch: widget.car.branchName,
      pickupAt: widget.pickupAt, returnAt: widget.returnAt,
      insurance: widget.insurance, extraOptions: widget.extraOptions,
      totalPrice: widget.totalPrice,
      userName: widget.userName, userPhone: widget.userPhone,
      licenseConfirmed: widget.licenseNo, paymentMethod: _method,
    );
    setState(() => _processing = false);
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => RentCarCompletionScreen(booking: b)),
      (r) => r.isFirst,
    );
  }
}

// ═══════════════════════════════════════════════
// 예약 완료
// ═══════════════════════════════════════════════
class RentCarCompletionScreen extends StatelessWidget {
  final RentCarBooking booking;
  const RentCarCompletionScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: _bg, statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: _bg,
        body: Column(children: [
          SizedBox(height: top + 16),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              const SizedBox(height: 20),
              Container(
                width: 90, height: 90,
                decoration: BoxDecoration(shape: BoxShape.circle, color: _green.withOpacity(0.15), border: Border.all(color: _green, width: 2)),
                child: const Icon(Icons.check_rounded, color: _green, size: 48),
              ),
              const SizedBox(height: 20),
              Text('예약이 완료되었습니다!', style: GoogleFonts.notoSansKr(color: _pri, fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text('예약번호: ${booking.bookingId}', style: GoogleFonts.notoSansKr(color: _sec, fontSize: 12)),
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(16), border: Border.all(color: _green.withOpacity(0.3))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${booking.car.brand} ${booking.car.name}', style: GoogleFonts.notoSansKr(color: _pri, fontSize: 17, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  _r('인수', '${booking.pickupRegion} · ${_dtStr(booking.pickupAt)}'),
                  _r('반납', '${booking.returnRegion} · ${_dtStr(booking.returnAt)}'),
                  _r('기간', '${booking.days}일'),
                  _r('보험', booking.insurance.label),
                  if (booking.extraOptions.isNotEmpty) _r('추가옵션', booking.extraOptions.join(', ')),
                  const Divider(color: _border, height: 20),
                  Row(children: [
                    Text('총 결제 금액', style: GoogleFonts.notoSansKr(color: _pri, fontSize: 14, fontWeight: FontWeight.w800)),
                    const Spacer(),
                    Text(_won(booking.totalPrice), style: GoogleFonts.notoSansKr(color: _accent, fontSize: 18, fontWeight: FontWeight.w900)),
                  ]),
                ]),
              ),
              const SizedBox(height: 24),
              SizedBox(width: double.infinity, child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: _accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RentMyBookingsScreen())),
                child: Text('내 예약 확인', style: GoogleFonts.notoSansKr(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w800)),
              )),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, child: OutlinedButton(
                style: OutlinedButton.styleFrom(side: const BorderSide(color: _border), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                child: Text('홈으로', style: GoogleFonts.notoSansKr(color: _sec, fontSize: 15, fontWeight: FontWeight.w700)),
              )),
            ]),
          )),
        ]),
      ),
    );
  }

  Widget _r(String k, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [
    SizedBox(width: 56, child: Text(k, style: GoogleFonts.notoSansKr(color: _sec, fontSize: 12))),
    Expanded(child: Text(v, style: GoogleFonts.notoSansKr(color: _pri, fontSize: 13, fontWeight: FontWeight.w600))),
  ]));
}

// ═══════════════════════════════════════════════
// 내 렌트 예약 목록
// ═══════════════════════════════════════════════
class RentMyBookingsScreen extends StatelessWidget {
  const RentMyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: _card, statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: _bg,
        body: Column(children: [
          Container(color: _card, padding: EdgeInsets.fromLTRB(4, top + 4, 16, 14),
            child: Row(children: [
              IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _pri, size: 20), onPressed: () => Navigator.pop(context)),
              Text('내 렌트 예약', style: GoogleFonts.notoSansKr(color: _pri, fontSize: 17, fontWeight: FontWeight.w800)),
            ]),
          ),
          Expanded(child: AnimatedBuilder(
            animation: RentCarState(),
            builder: (_, __) {
              final list = RentCarState().bookings;
              if (list.isEmpty) {
                return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.directions_car_outlined, color: _sec, size: 56),
                  const SizedBox(height: 14),
                  Text('예약 내역이 없습니다', style: GoogleFonts.notoSansKr(color: _sec, fontSize: 15)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text('렌트카 예약하러 가기', style: GoogleFonts.notoSansKr(color: _accent, fontSize: 13, fontWeight: FontWeight.w700)),
                  ),
                ]));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(14),
                itemCount: list.length,
                itemBuilder: (_, i) => _BookingCard(booking: list[i]),
              );
            },
          )),
        ]),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final RentCarBooking booking;
  const _BookingCard({required this.booking});

  Color get _sc {
    switch (booking.status) {
      case RentCarBookingStatus.confirmed: return _accent;
      case RentCarBookingStatus.inUse: return _green;
      case RentCarBookingStatus.completed: return _sec;
      case RentCarBookingStatus.cancelled: return _red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(16), border: Border.all(color: _border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(color: _sc.withOpacity(0.08), borderRadius: const BorderRadius.vertical(top: Radius.circular(16)), border: Border(bottom: BorderSide(color: _border))),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: _sc.withOpacity(0.2), borderRadius: BorderRadius.circular(6), border: Border.all(color: _sc.withOpacity(0.4))),
              child: Text(booking.status.label, style: GoogleFonts.notoSansKr(color: _sc, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
            const Spacer(),
            Text(booking.bookingId, style: GoogleFonts.notoSansKr(color: _sec, fontSize: 10)),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${booking.car.brand} ${booking.car.name}', style: GoogleFonts.notoSansKr(color: _pri, fontSize: 16, fontWeight: FontWeight.w900)),
                Text('${booking.car.grade.label} · ${booking.car.fuel.label}', style: GoogleFonts.notoSansKr(color: _sec, fontSize: 12)),
              ])),
              Text(_won(booking.totalPrice), style: GoogleFonts.notoSansKr(color: _accent, fontSize: 16, fontWeight: FontWeight.w900)),
            ]),
            const SizedBox(height: 10),
            _br('인수', '${booking.pickupRegion} · ${_dtStr(booking.pickupAt)}'),
            _br('반납', '${booking.returnRegion} · ${_dtStr(booking.returnAt)}'),
            _br('기간', '${booking.days}일 · ${booking.insurance.label}'),
            if (booking.status == RentCarBookingStatus.confirmed) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: _card,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: Text('예약 취소', style: GoogleFonts.notoSansKr(color: _pri, fontWeight: FontWeight.w800)),
                    content: Text('예약을 취소하시겠습니까?\n환불은 3~5 영업일 내 처리됩니다.', style: GoogleFonts.notoSansKr(color: _sec, fontSize: 13)),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: Text('아니오', style: GoogleFonts.notoSansKr(color: _sec))),
                      TextButton(
                        onPressed: () { RentCarState().cancelBooking(booking.bookingId); Navigator.pop(context); },
                        child: Text('취소하기', style: GoogleFonts.notoSansKr(color: _red, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
                child: Container(
                  width: double.infinity, height: 38,
                  decoration: BoxDecoration(border: Border.all(color: _red.withOpacity(0.5)), borderRadius: BorderRadius.circular(10)),
                  child: Center(child: Text('예약 취소', style: GoogleFonts.notoSansKr(color: _red, fontSize: 13, fontWeight: FontWeight.w700))),
                ),
              ),
            ],
          ]),
        ),
      ]),
    );
  }

  Widget _br(String k, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(children: [
    SizedBox(width: 36, child: Text(k, style: GoogleFonts.notoSansKr(color: _sec, fontSize: 12))),
    Expanded(child: Text(v, style: GoogleFonts.notoSansKr(color: _pri, fontSize: 12, fontWeight: FontWeight.w600))),
  ]));
}
