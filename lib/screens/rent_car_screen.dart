import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/app_state.dart';

// ── 색상 상수 ────────────────────────────────────────────────────
const Color _bg      = Color(0xFF020810);
const Color _card    = Color(0xFF0D1B2A);
const Color _navy    = Color(0xFF0A1628);
const Color _accent  = Color(0xFF4FC3F7);
const Color _green   = Color(0xFF10B981);
const Color _orange  = Color(0xFFFF6B35);
const Color _purple  = Color(0xFF8B5CF6);
const Color _red     = Color(0xFFE53935);
const Color _border  = Color(0xFF1E3A5F);
const Color _pri     = Colors.white;
const Color _sec     = Color(0xFFB0BEC5);

// ── 유틸 ────────────────────────────────────────────────────────
String _won(int v) {
  if (v >= 10000) return '${(v / 10000).toStringAsFixed(v % 10000 == 0 ? 0 : 1)}만원';
  return '${v.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원';
}

String _dateStr(DateTime d) =>
    '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';

String _dateTimeStr(DateTime d) =>
    '${_dateStr(d)} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

// ── 전국 지역 데이터 ─────────────────────────────────────────────
const Map<String, List<String>> _regionData = {
  '서울': ['강남구', '강동구', '강북구', '강서구', '관악구', '광진구', '구로구', '금천구', '노원구', '도봉구', '동대문구', '동작구', '마포구', '서대문구', '서초구', '성동구', '성북구', '송파구', '양천구', '영등포구', '용산구', '은평구', '종로구', '중구', '중랑구'],
  '경기': ['수원시', '성남시', '의정부시', '안양시', '부천시', '광명시', '평택시', '안산시', '고양시', '과천시', '구리시', '남양주시', '오산시', '시흥시', '군포시', '의왕시', '하남시', '용인시', '파주시', '이천시', '안성시', '김포시', '화성시', '광주시', '양주시', '포천시', '여주시', '양평군', '동두천시'],
  '부산': ['중구', '서구', '동구', '영도구', '부산진구', '동래구', '남구', '북구', '해운대구', '사하구', '금정구', '강서구', '연제구', '수영구', '사상구', '기장군'],
  '대구': ['중구', '동구', '서구', '남구', '북구', '수성구', '달서구', '달성군'],
  '인천': ['중구', '동구', '미추홀구', '연수구', '남동구', '부평구', '계양구', '서구', '강화군', '옹진군'],
  '광주': ['동구', '서구', '남구', '북구', '광산구'],
  '대전': ['동구', '중구', '서구', '유성구', '대덕구'],
  '울산': ['중구', '남구', '동구', '북구', '울주군'],
  '세종': ['세종시'],
  '제주': ['제주시', '서귀포시'],
  '강원': ['춘천시', '원주시', '강릉시', '동해시', '태백시', '속초시', '삼척시', '홍천군', '횡성군', '영월군', '평창군', '정선군', '철원군', '화천군', '양구군', '인제군', '고성군', '양양군'],
  '충북': ['청주시', '충주시', '제천시', '보은군', '옥천군', '영동군', '증평군', '진천군', '괴산군', '음성군', '단양군'],
  '충남': ['천안시', '공주시', '보령시', '아산시', '서산시', '논산시', '계룡시', '당진시', '금산군', '부여군', '서천군', '청양군', '홍성군', '예산군', '태안군'],
  '전북': ['전주시', '군산시', '익산시', '정읍시', '남원시', '김제시', '완주군', '진안군', '무주군', '장수군', '임실군', '순창군', '고창군', '부안군'],
  '전남': ['목포시', '여수시', '순천시', '나주시', '광양시', '담양군', '곡성군', '구례군', '고흥군', '보성군', '화순군', '장흥군', '강진군', '해남군', '영암군', '무안군', '함평군', '영광군', '장성군', '완도군', '진도군', '신안군'],
  '경북': ['포항시', '경주시', '김천시', '안동시', '구미시', '영주시', '영천시', '상주시', '문경시', '경산시', '군위군', '의성군', '청송군', '영양군', '영덕군', '청도군', '고령군', '성주군', '칠곡군', '예천군', '봉화군', '울진군', '울릉군'],
  '경남': ['창원시', '진주시', '통영시', '사천시', '김해시', '밀양시', '거제시', '양산시', '의령군', '함안군', '창녕군', '고성군', '남해군', '하동군', '산청군', '함양군', '거창군', '합천군'],
};

// ══════════════════════════════════════════════════════════════
// 렌트카 메인 화면 (검색 중심)
// ══════════════════════════════════════════════════════════════
class RentCarScreen extends StatefulWidget {
  const RentCarScreen({super.key});
  @override
  State<RentCarScreen> createState() => _RentCarScreenState();
}

class _RentCarScreenState extends State<RentCarScreen> {
  // 검색 조건
  String _pickupRegion = '';
  String _pickupDistrict = '';
  String _returnRegion = '';
  String _returnDistrict = '';
  bool _sameReturn = true;

  DateTime _pickupDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _pickupTime = const TimeOfDay(hour: 10, minute: 0);
  DateTime _returnDate = DateTime.now().add(const Duration(days: 2));
  TimeOfDay _returnTime = const TimeOfDay(hour: 10, minute: 0);

  RentCarGrade? _selectedGrade;

  String get _pickupFull => _pickupDistrict.isNotEmpty
      ? '$_pickupRegion $_pickupDistrict'
      : _pickupRegion.isNotEmpty ? _pickupRegion : '';

  String get _returnFull {
    if (_sameReturn) return _pickupFull;
    return _returnDistrict.isNotEmpty
        ? '$_returnRegion $_returnDistrict'
        : _returnRegion.isNotEmpty ? _returnRegion : '';
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
              padding: EdgeInsets.fromLTRB(4, topPad + 4, 16, 14),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _pri, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('렌트카', style: GoogleFonts.notoSansKr(
                          color: _pri, fontSize: 18, fontWeight: FontWeight.w900)),
                        Text('지역과 날짜를 선택해 차량을 예약하세요',
                          style: GoogleFonts.notoSansKr(color: _sec, fontSize: 12)),
                      ],
                    ),
                  ),
                  // 내 예약 버튼
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const RentMyBookingsScreen())),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: _accent.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('내 예약', style: GoogleFonts.notoSansKr(
                          color: _accent, fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),

            // ── 검색 폼 ─────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 인수 지역
                    _sectionLabel('📍 인수 지역'),
                    const SizedBox(height: 8),
                    _regionSelector(
                      value: _pickupFull,
                      hint: '인수 지역 선택',
                      onTap: () => _showRegionDialog(isPickup: true),
                    ),
                    const SizedBox(height: 16),

                    // 반납 장소
                    _sectionLabel('📍 반납 장소'),
                    const SizedBox(height: 8),
                    Row(children: [
                      GestureDetector(
                        onTap: () => setState(() => _sameReturn = true),
                        child: _toggleChip('인수 장소와 동일', _sameReturn),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => setState(() => _sameReturn = false),
                        child: _toggleChip('다른 장소 반납', !_sameReturn),
                      ),
                    ]),
                    if (!_sameReturn) ...[
                      const SizedBox(height: 8),
                      _regionSelector(
                        value: _returnFull,
                        hint: '반납 지역 선택',
                        onTap: () => _showRegionDialog(isPickup: false),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // 날짜/시간
                    _sectionLabel('📅 인수 일시'),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(child: _dateTile(
                        label: _dateStr(_pickupDate),
                        icon: Icons.calendar_today_rounded,
                        onTap: () => _pickDate(isPickup: true),
                      )),
                      const SizedBox(width: 8),
                      Expanded(child: _dateTile(
                        label: _pickupTime.format(context),
                        icon: Icons.access_time_rounded,
                        onTap: () => _pickTime(isPickup: true),
                      )),
                    ]),
                    const SizedBox(height: 12),
                    _sectionLabel('📅 반납 일시'),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(child: _dateTile(
                        label: _dateStr(_returnDate),
                        icon: Icons.calendar_today_rounded,
                        onTap: () => _pickDate(isPickup: false),
                      )),
                      const SizedBox(width: 8),
                      Expanded(child: _dateTile(
                        label: _returnTime.format(context),
                        icon: Icons.access_time_rounded,
                        onTap: () => _pickTime(isPickup: false),
                      )),
                    ]),
                    const SizedBox(height: 16),

                    // 대여 기간 표시
                    _daysBadge(),
                    const SizedBox(height: 16),

                    // 차량 종류 필터
                    _sectionLabel('🚗 차량 종류 (선택)'),
                    const SizedBox(height: 8),
                    _gradeFilter(),
                    const SizedBox(height: 28),

                    // 검색 버튼
                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: _canSearch ? _doSearch : null,
                        child: Container(
                          height: 54,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _canSearch
                                  ? [_accent, const Color(0xFF0288D1)]
                                  : [_border, _border],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_rounded,
                                  color: _canSearch ? Colors.black : _sec, size: 22),
                              const SizedBox(width: 8),
                              Text('차량 검색',
                                style: GoogleFonts.notoSansKr(
                                  color: _canSearch ? Colors.black : _sec,
                                  fontSize: 16, fontWeight: FontWeight.w900,
                                )),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _canSearch => _pickupRegion.isNotEmpty;

  void _doSearch() {
    final pickupDt = DateTime(
      _pickupDate.year, _pickupDate.month, _pickupDate.day,
      _pickupTime.hour, _pickupTime.minute,
    );
    final returnDt = DateTime(
      _returnDate.year, _returnDate.month, _returnDate.day,
      _returnTime.hour, _returnTime.minute,
    );
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => RentCarListScreen(
        pickupRegion: _pickupFull,
        returnRegion: _returnFull,
        pickupAt: pickupDt,
        returnAt: returnDt,
        grade: _selectedGrade,
      ),
    ));
  }

  Widget _sectionLabel(String t) => Text(t,
      style: GoogleFonts.notoSansKr(color: _pri, fontSize: 14, fontWeight: FontWeight.w700));

  Widget _regionSelector({required String value, required String hint, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: value.isNotEmpty ? _accent.withOpacity(0.5) : _border),
        ),
        child: Row(children: [
          Icon(Icons.location_on_rounded,
              color: value.isNotEmpty ? _accent : _sec, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(
            value.isNotEmpty ? value : hint,
            style: GoogleFonts.notoSansKr(
              color: value.isNotEmpty ? _pri : _sec,
              fontSize: 15, fontWeight: FontWeight.w600,
            ),
          )),
          Icon(Icons.chevron_right_rounded, color: _sec, size: 20),
        ]),
      ),
    );
  }

  Widget _dateTile({required String label, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
        ),
        child: Row(children: [
          Icon(icon, color: _accent, size: 18),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.notoSansKr(
              color: _pri, fontSize: 14, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  Widget _toggleChip(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: active ? _accent.withOpacity(0.15) : _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: active ? _accent : _border),
      ),
      child: Text(label, style: GoogleFonts.notoSansKr(
          color: active ? _accent : _sec, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _daysBadge() {
    final diff = _returnDate.difference(_pickupDate).inDays.clamp(0, 999);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _green.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _green.withOpacity(0.3)),
      ),
      child: Row(children: [
        const Icon(Icons.timer_outlined, color: _green, size: 16),
        const SizedBox(width: 8),
        Text('총 대여 기간: ${diff}일',
          style: GoogleFonts.notoSansKr(color: _green, fontSize: 13, fontWeight: FontWeight.w700)),
        const Spacer(),
        Text('${_dateTimeStr(DateTime(_pickupDate.year,_pickupDate.month,_pickupDate.day,_pickupTime.hour,_pickupTime.minute))} ~ ${_dateTimeStr(DateTime(_returnDate.year,_returnDate.month,_returnDate.day,_returnTime.hour,_returnTime.minute))}',
          style: GoogleFonts.notoSansKr(color: _sec, fontSize: 10)),
      ]),
    );
  }

  Widget _gradeFilter() {
    final grades = RentCarGrade.values;
    return Wrap(spacing: 8, runSpacing: 8, children: grades.map((g) {
      final active = _selectedGrade == g;
      return GestureDetector(
        onTap: () => setState(() => _selectedGrade = active ? null : g),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: active ? _accent.withOpacity(0.15) : _card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: active ? _accent : _border),
          ),
          child: Text(g.label, style: GoogleFonts.notoSansKr(
              color: active ? _accent : _sec, fontSize: 13, fontWeight: FontWeight.w600)),
        ),
      );
    }).toList());
  }

  Future<void> _showRegionDialog({required bool isPickup}) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const _RegionDialog(),
    );
    if (result != null && mounted) {
      setState(() {
        if (isPickup) {
          _pickupRegion = result['sido'] ?? '';
          _pickupDistrict = result['sigungu'] ?? '';
          if (_sameReturn) {
            _returnRegion = _pickupRegion;
            _returnDistrict = _pickupDistrict;
          }
        } else {
          _returnRegion = result['sido'] ?? '';
          _returnDistrict = result['sigungu'] ?? '';
        }
      });
    }
  }

  Future<void> _pickDate({required bool isPickup}) async {
    final now = DateTime.now();
    final initial = isPickup ? _pickupDate : _returnDate;
    final first = isPickup ? now : _pickupDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(first) ? first : initial,
      firstDate: first,
      lastDate: now.add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: _accent, surface: _card),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        if (isPickup) {
          _pickupDate = picked;
          if (_returnDate.isBefore(_pickupDate)) {
            _returnDate = _pickupDate.add(const Duration(days: 1));
          }
        } else {
          _returnDate = picked;
        }
      });
    }
  }

  Future<void> _pickTime({required bool isPickup}) async {
    final initial = isPickup ? _pickupTime : _returnTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: _accent, surface: _card),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        if (isPickup) _pickupTime = picked;
        else _returnTime = picked;
      });
    }
  }
}

// ══════════════════════════════════════════════════════════════
// 지역 선택 다이얼로그
// ══════════════════════════════════════════════════════════════
class _RegionDialog extends StatefulWidget {
  const _RegionDialog();
  @override
  State<_RegionDialog> createState() => _RegionDialogState();
}

class _RegionDialogState extends State<_RegionDialog> {
  String? _selectedSido;
  String _query = '';
  final _ctrl = TextEditingController();

  List<String> get _sidos => _regionData.keys.toList();

  List<String> get _sigunguList {
    if (_selectedSido == null) return [];
    final list = _regionData[_selectedSido] ?? [];
    if (_query.isEmpty) return list;
    return list.where((s) => s.contains(_query)).toList();
  }

  List<String> get _filteredSidos {
    if (_query.isEmpty) return _sidos;
    return _sidos.where((s) {
      if (s.contains(_query)) return true;
      final sgList = _regionData[s] ?? [];
      return sgList.any((sg) => sg.contains(_query));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: _card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.72,
        child: Column(
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 12),
              child: Row(children: [
                const Icon(Icons.location_on_rounded, color: _accent, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text('지역 선택',
                    style: GoogleFonts.notoSansKr(color: _pri, fontSize: 16, fontWeight: FontWeight.w800))),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: _sec, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ]),
            ),
            // 검색창
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: Container(
                decoration: BoxDecoration(
                  color: _navy, borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _border),
                ),
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
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
            ),
            Divider(color: _border, height: 1),
            // 내용
            Expanded(
              child: _selectedSido == null
                  ? _buildSidoList()
                  : _buildSigunguList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidoList() {
    final list = _filteredSidos;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 0, 6),
          child: Text('시/도 선택', style: GoogleFonts.notoSansKr(
              color: _sec, fontSize: 11, fontWeight: FontWeight.w600)),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final sido = list[i];
              return ListTile(
                dense: true,
                title: Text(sido, style: GoogleFonts.notoSansKr(
                    color: _pri, fontSize: 14, fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.chevron_right_rounded, color: _sec, size: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                onTap: () {
                  final sgs = _regionData[sido] ?? [];
                  if (sgs.length == 1) {
                    Navigator.pop(context, {'sido': sido, 'sigungu': sgs.first});
                  } else {
                    setState(() { _selectedSido = sido; _query = ''; _ctrl.clear(); });
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSigunguList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() { _selectedSido = null; _query = ''; _ctrl.clear(); }),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 0, 6),
            child: Row(children: [
              const Icon(Icons.arrow_back_rounded, color: _accent, size: 16),
              const SizedBox(width: 4),
              Text('$_selectedSido',
                  style: GoogleFonts.notoSansKr(color: _accent, fontSize: 13, fontWeight: FontWeight.w700)),
              Text(' 시/군/구 선택',
                  style: GoogleFonts.notoSansKr(color: _sec, fontSize: 12)),
            ]),
          ),
        ),
        Divider(color: _border, height: 1),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: _sigunguList.length,
            itemBuilder: (_, i) {
              final sg = _sigunguList[i];
              return ListTile(
                dense: true,
                title: Text(sg, style: GoogleFonts.notoSansKr(
                    color: _pri, fontSize: 14, fontWeight: FontWeight.w600)),
                onTap: () => Navigator.pop(context, {'sido': _selectedSido!, 'sigungu': sg}),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// 차량 리스트 화면
// ══════════════════════════════════════════════════════════════
class RentCarListScreen extends StatefulWidget {
  final String pickupRegion;
  final String returnRegion;
  final DateTime pickupAt;
  final DateTime returnAt;
  final RentCarGrade? grade;

  const RentCarListScreen({
    super.key,
    required this.pickupRegion,
    required this.returnRegion,
    required this.pickupAt,
    required this.returnAt,
    this.grade,
  });
  @override
  State<RentCarListScreen> createState() => _RentCarListScreenState();
}

class _RentCarListScreenState extends State<RentCarListScreen> {
  String _sort = 'popular';
  RentCarGrade? _filterGrade;
  RentCarFuel? _filterFuel;
  int? _maxPrice;

  int get _days => widget.returnAt.difference(widget.pickupAt).inDays.clamp(1, 999);

  @override
  void initState() {
    super.initState();
    _filterGrade = widget.grade;
  }

  List<RentCar> get _cars {
    final region = widget.pickupRegion.split(' ').first;
    return RentCarState().search(
      region: region,
      grade: _filterGrade,
      fuel: _filterFuel,
      maxPrice: _maxPrice,
      sort: _sort,
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final cars = _cars;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: _card, statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: _bg,
        body: Column(
          children: [
            // AppBar
            Container(
              color: _card,
              padding: EdgeInsets.fromLTRB(4, topPad + 4, 16, 10),
              child: Column(children: [
                Row(children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _pri, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('차량 검색 결과', style: GoogleFonts.notoSansKr(
                          color: _pri, fontSize: 16, fontWeight: FontWeight.w800)),
                      Text('${widget.pickupRegion} · ${_days}일 · ${cars.length}대',
                          style: GoogleFonts.notoSansKr(color: _sec, fontSize: 11)),
                    ],
                  )),
                  // 필터 버튼
                  GestureDetector(
                    onTap: _showFilterSheet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: _border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(children: [
                        const Icon(Icons.tune_rounded, color: _sec, size: 16),
                        const SizedBox(width: 4),
                        Text('필터', style: GoogleFonts.notoSansKr(color: _sec, fontSize: 12)),
                      ]),
                    ),
                  ),
                ]),
                const SizedBox(height: 10),
                // 정렬 칩
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    _sortChip('인기순', 'popular'),
                    const SizedBox(width: 6),
                    _sortChip('가격순', 'price'),
                    const SizedBox(width: 6),
                    _sortChip('추천순', 'rating'),
                    const SizedBox(width: 6),
                    if (_filterGrade != null)
                      _activeFilterChip(_filterGrade!.label, () => setState(() => _filterGrade = null)),
                    if (_filterFuel != null)
                      _activeFilterChip(_filterFuel!.label, () => setState(() => _filterFuel = null)),
                    if (_maxPrice != null)
                      _activeFilterChip('${_won(_maxPrice!)} 이하', () => setState(() => _maxPrice = null)),
                  ]),
                ),
              ]),
            ),
            // 리스트
            Expanded(
              child: cars.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.directions_car_outlined, color: _sec, size: 48),
                          const SizedBox(height: 12),
                          Text('검색된 차량이 없습니다',
                              style: GoogleFonts.notoSansKr(color: _sec, fontSize: 14)),
                          const SizedBox(height: 8),
                          Text('필터를 조정해 보세요',
                              style: GoogleFonts.notoSansKr(color: _sec.withOpacity(0.6), fontSize: 12)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: cars.length,
                      itemBuilder: (_, i) => _CarCard(
                        car: cars[i],
                        days: _days,
                        pickupAt: widget.pickupAt,
                        returnAt: widget.returnAt,
                        pickupRegion: widget.pickupRegion,
                        returnRegion: widget.returnRegion,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sortChip(String label, String value) {
    final active = _sort == value;
    return GestureDetector(
      onTap: () => setState(() => _sort = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? _accent.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: active ? _accent : _border),
        ),
        child: Text(label, style: GoogleFonts.notoSansKr(
            color: active ? _accent : _sec, fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _activeFilterChip(String label, VoidCallback onRemove) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _orange.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _orange.withOpacity(0.4)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(label, style: GoogleFonts.notoSansKr(color: _orange, fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(width: 4),
          GestureDetector(onTap: onRemove,
              child: const Icon(Icons.close_rounded, color: _orange, size: 14)),
        ]),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _FilterSheet(
        grade: _filterGrade,
        fuel: _filterFuel,
        maxPrice: _maxPrice,
        onApply: (g, f, p) => setState(() { _filterGrade = g; _filterFuel = f; _maxPrice = p; }),
      ),
    );
  }
}

// ── 차량 카드 ────────────────────────────────────────────────────
class _CarCard extends StatelessWidget {
  final RentCar car;
  final int days;
  final DateTime pickupAt;
  final DateTime returnAt;
  final String pickupRegion;
  final String returnRegion;

  const _CarCard({
    required this.car,
    required this.days,
    required this.pickupAt,
    required this.returnAt,
    required this.pickupRegion,
    required this.returnRegion,
  });

  @override
  Widget build(BuildContext context) {
    final discounted = car.originalPrice != null && car.originalPrice! > car.dailyPrice;
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => RentCarDetailScreen(
          car: car,
          days: days,
          pickupAt: pickupAt,
          returnAt: returnAt,
          pickupRegion: pickupRegion,
          returnRegion: returnRegion,
        ),
      )),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지
            Stack(children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  car.images.first,
                  height: 160, width: double.infinity, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(height: 160, color: _navy,
                      child: const Icon(Icons.directions_car_outlined, color: _sec, size: 48)),
                ),
              ),
              // 배지
              Positioned(top: 10, left: 10, child: Row(children: [
                _badge(car.grade.label, _accent),
                const SizedBox(width: 6),
                _badge(car.fuel.label,
                    car.fuel == RentCarFuel.electric ? _green : _orange),
              ])),
              if (discounted)
                Positioned(top: 10, right: 10,
                    child: _badge('특가', _red)),
              if (car.instantBooking)
                Positioned(bottom: 10, right: 10,
                    child: _badge('즉시예약', _green)),
            ]),
            // 정보
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${car.brand} ${car.name}',
                            style: GoogleFonts.notoSansKr(
                                color: _pri, fontSize: 16, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 2),
                        Text('${car.year}년식 · ${car.seats}인승',
                            style: GoogleFonts.notoSansKr(color: _sec, fontSize: 12)),
                      ],
                    )),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      if (discounted)
                        Text(_won(car.originalPrice!),
                            style: GoogleFonts.notoSansKr(
                                color: _sec, fontSize: 11,
                                decoration: TextDecoration.lineThrough)),
                      Row(children: [
                        Text(_won(car.dailyPrice),
                            style: GoogleFonts.notoSansKr(
                                color: _accent, fontSize: 18, fontWeight: FontWeight.w900)),
                        Text(' /일', style: GoogleFonts.notoSansKr(color: _sec, fontSize: 11)),
                      ]),
                      Text('${days}일 = ${_won(car.dailyPrice * days)}',
                          style: GoogleFonts.notoSansKr(color: _green, fontSize: 11, fontWeight: FontWeight.w700)),
                    ]),
                  ]),
                  const SizedBox(height: 10),
                  // 옵션 태그
                  Wrap(spacing: 6, runSpacing: 4,
                      children: car.options.take(3).map((o) => _optTag(o)).toList()),
                  const SizedBox(height: 10),
                  // 하단 정보
                  Row(children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 14),
                    const SizedBox(width: 2),
                    Text('${car.rating} (${car.reviewCount})',
                        style: GoogleFonts.notoSansKr(color: _sec, fontSize: 11)),
                    const SizedBox(width: 10),
                    const Icon(Icons.location_on_rounded, color: _sec, size: 12),
                    Text('${car.region} ${car.branchName}',
                        style: GoogleFonts.notoSansKr(color: _sec, fontSize: 11)),
                    const Spacer(),
                    if (car.insuranceIncluded)
                      _badge('보험포함', _purple),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String t, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: c.withOpacity(0.2), borderRadius: BorderRadius.circular(6),
      border: Border.all(color: c.withOpacity(0.5)),
    ),
    child: Text(t, style: GoogleFonts.notoSansKr(color: c, fontSize: 10, fontWeight: FontWeight.w700)),
  );

  Widget _optTag(String t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: _navy, borderRadius: BorderRadius.circular(6)),
    child: Text(t, style: GoogleFonts.notoSansKr(color: _sec, fontSize: 10)),
  );
}

// ── 필터 바텀시트 ─────────────────────────────────────────────────
class _FilterSheet extends StatefulWidget {
  final RentCarGrade? grade;
  final RentCarFuel? fuel;
  final int? maxPrice;
  final Function(RentCarGrade?, RentCarFuel?, int?) onApply;

  const _FilterSheet({
    this.grade, this.fuel, this.maxPrice, required this.onApply,
  });
  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  RentCarGrade? _grade;
  RentCarFuel? _fuel;
  int? _maxPrice;

  @override
  void initState() {
    super.initState();
    _grade = widget.grade;
    _fuel = widget.fuel;
    _maxPrice = widget.maxPrice;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('필터', style: GoogleFonts.notoSansKr(color: _pri, fontSize: 16, fontWeight: FontWeight.w800)),
            const Spacer(),
            TextButton(
              onTap: () => setState(() { _grade = null; _fuel = null; _maxPrice = null; }),
              onPressed: () => setState(() { _grade = null; _fuel = null; _maxPrice = null; }),
              child: Text('초기화', style: GoogleFonts.notoSansKr(color: _sec, fontSize: 13)),
            ),
          ]),
          const SizedBox(height: 12),
          Text('차량 종류', style: GoogleFonts.notoSansKr(color: _sec, fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 6,
            children: RentCarGrade.values.map((g) {
              final active = _grade == g;
              return GestureDetector(
                onTap: () => setState(() => _grade = active ? null : g),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: active ? _accent.withOpacity(0.15) : _navy,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: active ? _accent : _border),
                  ),
                  child: Text(g.label, style: GoogleFonts.notoSansKr(
                      color: active ? _accent : _sec, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Text('연료', style: GoogleFonts.notoSansKr(color: _sec, fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 6,
            children: RentCarFuel.values.map((f) {
              final active = _fuel == f;
              return GestureDetector(
                onTap: () => setState(() => _fuel = active ? null : f),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: active ? _green.withOpacity(0.15) : _navy,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: active ? _green : _border),
                  ),
                  child: Text(f.label, style: GoogleFonts.notoSansKr(
                      color: active ? _green : _sec, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Text('최대 일일 요금', style: GoogleFonts.notoSansKr(color: _sec, fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 6,
            children: [50000, 80000, 100000, 150000].map((p) {
              final active = _maxPrice == p;
              return GestureDetector(
                onTap: () => setState(() => _maxPrice = active ? null : p),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: active ? _orange.withOpacity(0.15) : _navy,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: active ? _orange : _border),
                  ),
                  child: Text('${_won(p)} 이하', style: GoogleFonts.notoSansKr(
                      color: active ? _orange : _sec, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                widget.onApply(_grade, _fuel, _maxPrice);
                Navigator.pop(context);
              },
              child: Text('적용하기', style: GoogleFonts.notoSansKr(
                  color: Colors.black, fontSize: 15, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// 차량 상세 화면
// ══════════════════════════════════════════════════════════════
class RentCarDetailScreen extends StatefulWidget {
  final RentCar car;
  final int days;
  final DateTime pickupAt;
  final DateTime returnAt;
  final String pickupRegion;
  final String returnRegion;

  const RentCarDetailScreen({
    super.key,
    required this.car,
    required this.days,
    required this.pickupAt,
    required this.returnAt,
    required this.pickupRegion,
    required this.returnRegion,
  });
  @override
  State<RentCarDetailScreen> createState() => _RentCarDetailScreenState();
}

class _RentCarDetailScreenState extends State<RentCarDetailScreen> {
  int _imgIndex = 0;
  RentInsuranceType _insurance = RentInsuranceType.basic;
  final Set<String> _extraOpts = {};

  final List<Map<String, dynamic>> _optionList = [
    {'name': '카시트', 'price': 10000, 'icon': Icons.child_friendly_rounded},
    {'name': '네비게이션', 'price': 5000, 'icon': Icons.navigation_rounded},
    {'name': '와이파이', 'price': 8000, 'icon': Icons.wifi_rounded},
    {'name': '블랙박스', 'price': 5000, 'icon': Icons.videocam_rounded},
  ];

  int get _insuranceTotal => _insurance.dailyPrice * widget.days;
  int get _optTotal => _extraOpts.fold(0, (sum, opt) {
    final item = _optionList.firstWhere((o) => o['name'] == opt, orElse: () => {'price': 0});
    return sum + ((item['price'] as int) * widget.days);
  });
  int get _baseTotal => widget.car.dailyPrice * widget.days;
  int get _total => _baseTotal + _insuranceTotal + _optTotal;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: _bg,
        body: Stack(children: [
          CustomScrollView(slivers: [
            // 이미지 영역
            SliverAppBar(
              expandedHeight: 240,
              pinned: true,
              backgroundColor: _card,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _pri, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(children: [
                  PageView.builder(
                    itemCount: widget.car.images.length,
                    onPageChanged: (i) => setState(() => _imgIndex = i),
                    itemBuilder: (_, i) => Image.network(
                      widget.car.images[i],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: _navy,
                          child: const Icon(Icons.directions_car_outlined, color: _sec, size: 56)),
                    ),
                  ),
                  if (widget.car.images.length > 1)
                    Positioned(bottom: 12, right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.black54, borderRadius: BorderRadius.circular(12)),
                        child: Text('${_imgIndex + 1}/${widget.car.images.length}',
                            style: const TextStyle(color: Colors.white, fontSize: 11)),
                      ),
                    ),
                ]),
              ),
            ),
            // 상세 내용
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 차량 기본 정보
                    Row(children: [
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            _tag(widget.car.grade.label, _accent),
                            const SizedBox(width: 6),
                            _tag(widget.car.fuel.label,
                                widget.car.fuel == RentCarFuel.electric ? _green : _orange),
                          ]),
                          const SizedBox(height: 6),
                          Text('${widget.car.brand} ${widget.car.name}',
                              style: GoogleFonts.notoSansKr(
                                  color: _pri, fontSize: 22, fontWeight: FontWeight.w900)),
                          Text('${widget.car.year}년식 · ${widget.car.seats}인승',
                              style: GoogleFonts.notoSansKr(color: _sec, fontSize: 13)),
                        ],
                      )),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text(_won(widget.car.dailyPrice),
                            style: GoogleFonts.notoSansKr(
                                color: _accent, fontSize: 22, fontWeight: FontWeight.w900)),
                        Text('/일', style: GoogleFonts.notoSansKr(color: _sec, fontSize: 11)),
                        Row(children: [
                          const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 14),
                          Text(' ${widget.car.rating}',
                              style: GoogleFonts.notoSansKr(color: _sec, fontSize: 12)),
                        ]),
                      ]),
                    ]),
                    const SizedBox(height: 16),

                    // 대여 정보
                    _sectionTitle('📋 대여 정보'),
                    const SizedBox(height: 10),
                    _infoCard(children: [
                      _infoRow('인수 지역', widget.pickupRegion),
                      _infoRow('반납 지역', widget.returnRegion),
                      _infoRow('인수 일시', _dateTimeStr(widget.pickupAt)),
                      _infoRow('반납 일시', _dateTimeStr(widget.returnAt)),
                      _infoRow('대여 기간', '${widget.days}일'),
                    ]),
                    const SizedBox(height: 16),

                    // 차량 옵션
                    _sectionTitle('🔧 차량 기본 옵션'),
                    const SizedBox(height: 10),
                    Wrap(spacing: 8, runSpacing: 8,
                      children: widget.car.options.map((o) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _navy, borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _border),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.check_circle_rounded, color: _green, size: 14),
                          const SizedBox(width: 4),
                          Text(o, style: GoogleFonts.notoSansKr(color: _pri, fontSize: 12)),
                        ]),
                      )).toList(),
                    ),
                    const SizedBox(height: 16),

                    // 보험 선택
                    _sectionTitle('🛡️ 보험 선택'),
                    const SizedBox(height: 10),
                    ...RentInsuranceType.values.map((ins) => _insuranceCard(ins)),
                    const SizedBox(height: 16),

                    // 추가 옵션
                    _sectionTitle('➕ 추가 옵션'),
                    const SizedBox(height: 10),
                    ..._optionList.map((opt) => _extraOptionRow(opt)),
                    const SizedBox(height: 16),

                    // 요금 상세
                    _sectionTitle('💰 요금 상세'),
                    const SizedBox(height: 10),
                    _infoCard(children: [
                      _priceRow('기본 대여료', '${_won(widget.car.dailyPrice)} × ${widget.days}일',
                          _won(_baseTotal)),
                      _priceRow('보험료', '${_won(_insurance.dailyPrice)} × ${widget.days}일',
                          _won(_insuranceTotal)),
                      if (_optTotal > 0)
                        _priceRow('추가 옵션', '', _won(_optTotal)),
                      Divider(color: _border, height: 20),
                      Row(children: [
                        Text('총 결제 금액',
                            style: GoogleFonts.notoSansKr(
                                color: _pri, fontSize: 15, fontWeight: FontWeight.w800)),
                        const Spacer(),
                        Text(_won(_total),
                            style: GoogleFonts.notoSansKr(
                                color: _accent, fontSize: 18, fontWeight: FontWeight.w900)),
                      ]),
                    ]),
                  ],
                ),
              ),
            ),
          ]),

          // 예약하기 버튼
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              color: _card,
              padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
              child: Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('총 결제 금액', style: GoogleFonts.notoSansKr(color: _sec, fontSize: 11)),
                  Text(_won(_total), style: GoogleFonts.notoSansKr(
                      color: _accent, fontSize: 20, fontWeight: FontWeight.w900)),
                ]),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => RentCarBookingScreen(
                        car: widget.car,
                        days: widget.days,
                        pickupAt: widget.pickupAt,
                        returnAt: widget.returnAt,
                        pickupRegion: widget.pickupRegion,
                        returnRegion: widget.returnRegion,
                        insurance: _insurance,
                        extraOptions: _extraOpts.toList(),
                        totalPrice: _total,
                      ),
                    )),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [_accent, Color(0xFF0288D1)]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text('예약하기',
                          style: GoogleFonts.notoSansKr(
                              color: Colors.black, fontSize: 16, fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _insuranceCard(RentInsuranceType ins) {
    final active = _insurance == ins;
    return GestureDetector(
      onTap: () => setState(() => _insurance = ins),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: active ? _accent.withOpacity(0.08) : _navy,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: active ? _accent : _border, width: active ? 1.5 : 1),
        ),
        child: Row(children: [
          Container(
            width: 20, height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: active ? _accent : _border, width: 2),
              color: active ? _accent : Colors.transparent,
            ),
            child: active ? const Icon(Icons.check_rounded, color: Colors.black, size: 13) : null,
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ins.label, style: GoogleFonts.notoSansKr(
                  color: active ? _accent : _pri, fontSize: 14, fontWeight: FontWeight.w700)),
              Text(_insDescription(ins), style: GoogleFonts.notoSansKr(color: _sec, fontSize: 11)),
            ],
          )),
          Text(ins.dailyPrice == 0 ? '무료' : '${_won(ins.dailyPrice)}/일',
              style: GoogleFonts.notoSansKr(
                  color: active ? _accent : _sec, fontSize: 13, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }

  String _insDescription(RentInsuranceType ins) {
    switch (ins) {
      case RentInsuranceType.basic: return '사고 시 자기 부담금 발생 (최대 50만원)';
      case RentInsuranceType.fullCoverage: return '사고 시 자기 부담금 없음, 완전 보장';
      case RentInsuranceType.none: return '보험 없음 (사고 시 전액 본인 부담)';
    }
  }

  Widget _extraOptionRow(Map<String, dynamic> opt) {
    final name = opt['name'] as String;
    final price = opt['price'] as int;
    final icon = opt['icon'] as IconData;
    final active = _extraOpts.contains(name);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: active ? _purple.withOpacity(0.08) : _navy,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: active ? _purple : _border),
      ),
      child: Row(children: [
        Icon(icon, color: active ? _purple : _sec, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(name, style: GoogleFonts.notoSansKr(
            color: active ? _pri : _sec, fontSize: 14, fontWeight: FontWeight.w600))),
        Text('${_won(price)}/일', style: GoogleFonts.notoSansKr(
            color: active ? _purple : _sec, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => setState(() {
            if (active) _extraOpts.remove(name);
            else _extraOpts.add(name);
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: active ? _purple : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: active ? _purple : _border),
            ),
            child: Text(active ? '해제' : '추가',
              style: GoogleFonts.notoSansKr(
                  color: active ? Colors.white : _sec, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    );
  }

  Widget _sectionTitle(String t) => Text(t,
      style: GoogleFonts.notoSansKr(color: _pri, fontSize: 15, fontWeight: FontWeight.w800));

  Widget _tag(String t, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(6),
      border: Border.all(color: c.withOpacity(0.4)),
    ),
    child: Text(t, style: GoogleFonts.notoSansKr(color: c, fontSize: 11, fontWeight: FontWeight.w700)),
  );

  Widget _infoCard({required List<Widget> children}) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: _navy, borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _border),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
  );

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      SizedBox(width: 90, child: Text(label,
          style: GoogleFonts.notoSansKr(color: _sec, fontSize: 12))),
      Expanded(child: Text(value,
          style: GoogleFonts.notoSansKr(color: _pri, fontSize: 13, fontWeight: FontWeight.w600))),
    ]),
  );

  Widget _priceRow(String label, String sub, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.notoSansKr(color: _pri, fontSize: 13)),
          if (sub.isNotEmpty)
            Text(sub, style: GoogleFonts.notoSansKr(color: _sec, fontSize: 10)),
        ],
      )),
      Text(value, style: GoogleFonts.notoSansKr(color: _pri, fontSize: 13, fontWeight: FontWeight.w600)),
    ]),
  );
}

// ══════════════════════════════════════════════════════════════
// 예약 화면
// ══════════════════════════════════════════════════════════════
class RentCarBookingScreen extends StatefulWidget {
  final RentCar car;
  final int days;
  final DateTime pickupAt;
  final DateTime returnAt;
  final String pickupRegion;
  final String returnRegion;
  final RentInsuranceType insurance;
  final List<String> extraOptions;
  final int totalPrice;

  const RentCarBookingScreen({
    super.key,
    required this.car,
    required this.days,
    required this.pickupAt,
    required this.returnAt,
    required this.pickupRegion,
    required this.returnRegion,
    required this.insurance,
    required this.extraOptions,
    required this.totalPrice,
  });
  @override
  State<RentCarBookingScreen> createState() => _RentCarBookingScreenState();
}

class _RentCarBookingScreenState extends State<RentCarBookingScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _licenseCtrl = TextEditingController();
  bool _agreeTerms = false;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _licenseCtrl.dispose();
    super.dispose();
  }

  bool get _canProceed =>
      _nameCtrl.text.trim().isNotEmpty &&
      _phoneCtrl.text.trim().length >= 10 &&
      _licenseCtrl.text.trim().length >= 8 &&
      _agreeTerms;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: _card, statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: _bg,
        body: Column(children: [
          // AppBar
          Container(
            color: _card,
            padding: EdgeInsets.fromLTRB(4, topPad + 4, 16, 14),
            child: Row(children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _pri, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              Text('예약 정보 입력', style: GoogleFonts.notoSansKr(
                  color: _pri, fontSize: 17, fontWeight: FontWeight.w800)),
            ]),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 예약 요약
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _card, borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _accent.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${widget.car.brand} ${widget.car.name}',
                            style: GoogleFonts.notoSansKr(
                                color: _pri, fontSize: 16, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 8),
                        _summaryRow('인수', '${widget.pickupRegion} · ${_dateTimeStr(widget.pickupAt)}'),
                        _summaryRow('반납', '${widget.returnRegion} · ${_dateTimeStr(widget.returnAt)}'),
                        _summaryRow('기간', '${widget.days}일'),
                        _summaryRow('보험', widget.insurance.label),
                        Divider(color: _border, height: 16),
                        Row(children: [
                          Text('총 결제 금액', style: GoogleFonts.notoSansKr(
                              color: _pri, fontSize: 14, fontWeight: FontWeight.w700)),
                          const Spacer(),
                          Text(_won(widget.totalPrice), style: GoogleFonts.notoSansKr(
                              color: _accent, fontSize: 18, fontWeight: FontWeight.w900)),
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 사용자 정보
                  _fieldLabel('이름'),
                  const SizedBox(height: 6),
                  _textField(_nameCtrl, '예약자 이름', TextInputType.name),
                  const SizedBox(height: 12),
                  _fieldLabel('연락처'),
                  const SizedBox(height: 6),
                  _textField(_phoneCtrl, '010-0000-0000', TextInputType.phone),
                  const SizedBox(height: 12),
                  _fieldLabel('운전면허 번호'),
                  const SizedBox(height: 6),
                  _textField(_licenseCtrl, '예) 서울 12-345678-00', TextInputType.text),
                  const SizedBox(height: 20),

                  // 약관 동의
                  GestureDetector(
                    onTap: () => setState(() => _agreeTerms = !_agreeTerms),
                    child: Row(children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 22, height: 22,
                        decoration: BoxDecoration(
                          color: _agreeTerms ? _accent : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: _agreeTerms ? _accent : _border, width: 1.5),
                        ),
                        child: _agreeTerms
                            ? const Icon(Icons.check_rounded, color: Colors.black, size: 15)
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(
                        '렌트카 이용 약관 및 개인정보 처리 방침에 동의합니다.',
                        style: GoogleFonts.notoSansKr(color: _sec, fontSize: 13),
                      )),
                    ]),
                  ),
                  const SizedBox(height: 28),

                  // 결제 진행 버튼
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: _canProceed ? _goToPayment : null,
                      child: Container(
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _canProceed
                                ? [_accent, const Color(0xFF0288D1)]
                                : [_border, _border],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(child: Text('결제 진행',
                          style: GoogleFonts.notoSansKr(
                            color: _canProceed ? Colors.black : _sec,
                            fontSize: 16, fontWeight: FontWeight.w900,
                          ))),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  void _goToPayment() {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => RentCarPaymentScreen(
        car: widget.car,
        days: widget.days,
        pickupAt: widget.pickupAt,
        returnAt: widget.returnAt,
        pickupRegion: widget.pickupRegion,
        returnRegion: widget.returnRegion,
        insurance: widget.insurance,
        extraOptions: widget.extraOptions,
        totalPrice: widget.totalPrice,
        userName: _nameCtrl.text.trim(),
        userPhone: _phoneCtrl.text.trim(),
        licenseNo: _licenseCtrl.text.trim(),
      ),
    ));
  }

  Widget _fieldLabel(String t) => Text(t, style: GoogleFonts.notoSansKr(
      color: _pri, fontSize: 14, fontWeight: FontWeight.w700));

  Widget _textField(TextEditingController ctrl, String hint, TextInputType type) {
    return Container(
      decoration: BoxDecoration(
        color: _card, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: type,
        style: const TextStyle(color: _pri, fontSize: 14),
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: _sec.withOpacity(0.5), fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(children: [
      SizedBox(width: 48, child: Text(label,
          style: GoogleFonts.notoSansKr(color: _sec, fontSize: 12))),
      Expanded(child: Text(value,
          style: GoogleFonts.notoSansKr(color: _pri, fontSize: 12, fontWeight: FontWeight.w600))),
    ]),
  );
}

// ══════════════════════════════════════════════════════════════
// 결제 화면
// ══════════════════════════════════════════════════════════════
class RentCarPaymentScreen extends StatefulWidget {
  final RentCar car;
  final int days;
  final DateTime pickupAt;
  final DateTime returnAt;
  final String pickupRegion;
  final String returnRegion;
  final RentInsuranceType insurance;
  final List<String> extraOptions;
  final int totalPrice;
  final String userName;
  final String userPhone;
  final String licenseNo;

  const RentCarPaymentScreen({
    super.key,
    required this.car,
    required this.days,
    required this.pickupAt,
    required this.returnAt,
    required this.pickupRegion,
    required this.returnRegion,
    required this.insurance,
    required this.extraOptions,
    required this.totalPrice,
    required this.userName,
    required this.userPhone,
    required this.licenseNo,
  });
  @override
  State<RentCarPaymentScreen> createState() => _RentCarPaymentScreenState();
}

class _RentCarPaymentScreenState extends State<RentCarPaymentScreen> {
  String _payMethod = 'card';
  bool _processing = false;

  final _methods = [
    {'key': 'card', 'label': '신용/체크카드', 'icon': Icons.credit_card_rounded},
    {'key': 'kakao', 'label': '카카오페이', 'icon': Icons.payment_rounded},
    {'key': 'naver', 'label': '네이버페이', 'icon': Icons.payment_rounded},
    {'key': 'toss', 'label': '토스페이', 'icon': Icons.payment_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: _card, statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: _bg,
        body: Column(children: [
          Container(
            color: _card,
            padding: EdgeInsets.fromLTRB(4, topPad + 4, 16, 14),
            child: Row(children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _pri, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              Text('결제', style: GoogleFonts.notoSansKr(
                  color: _pri, fontSize: 17, fontWeight: FontWeight.w800)),
            ]),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 결제 요약
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _card, borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('결제 상세', style: GoogleFonts.notoSansKr(
                            color: _sec, fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 10),
                        Row(children: [
                          Expanded(child: Text('${widget.car.brand} ${widget.car.name}',
                              style: GoogleFonts.notoSansKr(
                                  color: _pri, fontSize: 15, fontWeight: FontWeight.w700))),
                          Text('${widget.days}일', style: GoogleFonts.notoSansKr(color: _sec, fontSize: 13)),
                        ]),
                        const SizedBox(height: 4),
                        Text('${widget.pickupRegion} → ${widget.returnRegion}',
                            style: GoogleFonts.notoSansKr(color: _sec, fontSize: 12)),
                        Divider(color: _border, height: 20),
                        Row(children: [
                          Text('예약자', style: GoogleFonts.notoSansKr(color: _sec, fontSize: 12)),
                          const Spacer(),
                          Text(widget.userName, style: GoogleFonts.notoSansKr(
                              color: _pri, fontSize: 13, fontWeight: FontWeight.w600)),
                        ]),
                        const SizedBox(height: 4),
                        Row(children: [
                          Text('총 결제 금액', style: GoogleFonts.notoSansKr(
                              color: _pri, fontSize: 15, fontWeight: FontWeight.w800)),
                          const Spacer(),
                          Text(_won(widget.totalPrice), style: GoogleFonts.notoSansKr(
                              color: _accent, fontSize: 20, fontWeight: FontWeight.w900)),
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 결제 수단
                  Text('결제 수단', style: GoogleFonts.notoSansKr(
                      color: _pri, fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  ..._methods.map((m) => _paymentMethodTile(m)),
                  const SizedBox(height: 28),

                  // 결제하기 버튼
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: _processing ? null : _processPayment,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [_accent, Color(0xFF0288D1)]),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: _processing
                              ? const SizedBox(width: 22, height: 22,
                                  child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5))
                              : Text('${_won(widget.totalPrice)} 결제하기',
                                  style: GoogleFonts.notoSansKr(
                                      color: Colors.black, fontSize: 16, fontWeight: FontWeight.w900)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _paymentMethodTile(Map<String, dynamic> m) {
    final active = _payMethod == m['key'];
    return GestureDetector(
      onTap: () => setState(() => _payMethod = m['key']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: active ? _accent.withOpacity(0.08) : _card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: active ? _accent : _border, width: active ? 1.5 : 1),
        ),
        child: Row(children: [
          Container(
            width: 20, height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: active ? _accent : _border, width: 2),
              color: active ? _accent : Colors.transparent,
            ),
            child: active ? const Icon(Icons.check_rounded, color: Colors.black, size: 13) : null,
          ),
          const SizedBox(width: 12),
          Icon(m['icon'] as IconData, color: active ? _accent : _sec, size: 20),
          const SizedBox(width: 10),
          Text(m['label'] as String, style: GoogleFonts.notoSansKr(
              color: active ? _pri : _sec, fontSize: 14, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  Future<void> _processPayment() async {
    setState(() => _processing = true);
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;

    final booking = RentCarState().addBooking(
      car: widget.car,
      pickupRegion: widget.pickupRegion,
      pickupBranch: widget.car.branchName,
      returnRegion: widget.returnRegion,
      returnBranch: widget.car.branchName,
      pickupAt: widget.pickupAt,
      returnAt: widget.returnAt,
      insurance: widget.insurance,
      extraOptions: widget.extraOptions,
      totalPrice: widget.totalPrice,
      userName: widget.userName,
      userPhone: widget.userPhone,
      licenseConfirmed: widget.licenseNo,
      paymentMethod: _payMethod,
    );

    setState(() => _processing = false);

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => RentCarCompletionScreen(booking: booking)),
      (route) => route.settings.name == '/home' || route.isFirst,
    );
  }
}

// ══════════════════════════════════════════════════════════════
// 예약 완료 화면
// ══════════════════════════════════════════════════════════════
class RentCarCompletionScreen extends StatelessWidget {
  final RentCarBooking booking;
  const RentCarCompletionScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: _bg, statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: _bg,
        body: Column(children: [
          SizedBox(height: topPad + 16),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // 완료 아이콘
                  Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _green.withOpacity(0.15),
                      border: Border.all(color: _green, width: 2),
                    ),
                    child: const Icon(Icons.check_rounded, color: _green, size: 48),
                  ),
                  const SizedBox(height: 20),
                  Text('예약이 완료되었습니다!',
                      style: GoogleFonts.notoSansKr(
                          color: _pri, fontSize: 22, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  Text('예약 번호: ${booking.bookingId}',
                      style: GoogleFonts.notoSansKr(color: _sec, fontSize: 13)),
                  const SizedBox(height: 28),

                  // 예약 상세
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: _card, borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _green.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${booking.car.brand} ${booking.car.name}',
                            style: GoogleFonts.notoSansKr(
                                color: _pri, fontSize: 17, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 12),
                        _row('인수', '${booking.pickupRegion} · ${_dateTimeStr(booking.pickupAt)}'),
                        _row('반납', '${booking.returnRegion} · ${_dateTimeStr(booking.returnAt)}'),
                        _row('기간', '${booking.days}일'),
                        _row('보험', booking.insurance.label),
                        if (booking.extraOptions.isNotEmpty)
                          _row('추가옵션', booking.extraOptions.join(', ')),
                        Divider(color: _border, height: 20),
                        Row(children: [
                          Text('총 결제 금액',
                              style: GoogleFonts.notoSansKr(
                                  color: _pri, fontSize: 14, fontWeight: FontWeight.w800)),
                          const Spacer(),
                          Text(_won(booking.totalPrice), style: GoogleFonts.notoSansKr(
                              color: _accent, fontSize: 18, fontWeight: FontWeight.w900)),
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const RentMyBookingsScreen())),
                      child: Text('내 예약 확인', style: GoogleFonts.notoSansKr(
                          color: Colors.black, fontSize: 15, fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: _border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                      child: Text('홈으로', style: GoogleFonts.notoSansKr(
                          color: _sec, fontSize: 15, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      SizedBox(width: 60, child: Text(label,
          style: GoogleFonts.notoSansKr(color: _sec, fontSize: 12))),
      Expanded(child: Text(value, style: GoogleFonts.notoSansKr(
          color: _pri, fontSize: 13, fontWeight: FontWeight.w600))),
    ]),
  );
}

// ══════════════════════════════════════════════════════════════
// 마이페이지 - 내 렌트 예약 목록
// ══════════════════════════════════════════════════════════════
class RentMyBookingsScreen extends StatelessWidget {
  const RentMyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bookings = RentCarState().bookings;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: _card, statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: _bg,
        body: Column(children: [
          Container(
            color: _card,
            padding: EdgeInsets.fromLTRB(4, topPad + 4, 16, 14),
            child: Row(children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _pri, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              Text('내 렌트 예약', style: GoogleFonts.notoSansKr(
                  color: _pri, fontSize: 17, fontWeight: FontWeight.w800)),
            ]),
          ),
          Expanded(
            child: bookings.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.directions_car_outlined, color: _sec, size: 56),
                        const SizedBox(height: 14),
                        Text('예약 내역이 없습니다',
                            style: GoogleFonts.notoSansKr(color: _sec, fontSize: 15)),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text('렌트카 예약하러 가기',
                              style: GoogleFonts.notoSansKr(
                                  color: _accent, fontSize: 13, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  )
                : AnimatedBuilder(
                    animation: RentCarState(),
                    builder: (_, __) => ListView.builder(
                      padding: const EdgeInsets.all(14),
                      itemCount: RentCarState().bookings.length,
                      itemBuilder: (_, i) => _BookingCard(booking: RentCarState().bookings[i]),
                    ),
                  ),
          ),
        ]),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final RentCarBooking booking;
  const _BookingCard({required this.booking});

  Color get _statusColor {
    switch (booking.status) {
      case RentCarBookingStatus.confirmed: return _accent;
      case RentCarBookingStatus.inUse:     return _green;
      case RentCarBookingStatus.completed: return _sec;
      case RentCarBookingStatus.cancelled: return _red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _card, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: _border)),
            ),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _statusColor.withOpacity(0.4)),
                ),
                child: Text(booking.status.label, style: GoogleFonts.notoSansKr(
                    color: _statusColor, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
              const Spacer(),
              Text(booking.bookingId, style: GoogleFonts.notoSansKr(color: _sec, fontSize: 10)),
            ]),
          ),
          // 내용
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${booking.car.brand} ${booking.car.name}',
                          style: GoogleFonts.notoSansKr(
                              color: _pri, fontSize: 16, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 2),
                      Text('${booking.car.grade.label} · ${booking.car.fuel.label}',
                          style: GoogleFonts.notoSansKr(color: _sec, fontSize: 12)),
                    ],
                  )),
                  Text(_won(booking.totalPrice), style: GoogleFonts.notoSansKr(
                      color: _accent, fontSize: 16, fontWeight: FontWeight.w900)),
                ]),
                const SizedBox(height: 10),
                _bRow('인수', '${booking.pickupRegion} · ${_dateTimeStr(booking.pickupAt)}'),
                _bRow('반납', '${booking.returnRegion} · ${_dateTimeStr(booking.returnAt)}'),
                _bRow('기간', '${booking.days}일 · ${booking.insurance.label}'),
                if (booking.status == RentCarBookingStatus.confirmed) ...[
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              backgroundColor: _card,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              title: Text('예약 취소', style: GoogleFonts.notoSansKr(
                                  color: _pri, fontWeight: FontWeight.w800)),
                              content: Text('예약을 취소하시겠습니까?\n취소 후 환불은 3-5 영업일 내 처리됩니다.',
                                  style: GoogleFonts.notoSansKr(color: _sec, fontSize: 13)),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('아니오', style: GoogleFonts.notoSansKr(color: _sec)),
                                ),
                                TextButton(
                                  onPressed: () {
                                    RentCarState().cancelBooking(booking.bookingId);
                                    Navigator.pop(context);
                                  },
                                  child: Text('취소하기', style: GoogleFonts.notoSansKr(color: _red, fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(
                          height: 38,
                          decoration: BoxDecoration(
                            border: Border.all(color: _red.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(child: Text('예약 취소', style: GoogleFonts.notoSansKr(
                              color: _red, fontSize: 13, fontWeight: FontWeight.w700))),
                        ),
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

  Widget _bRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(children: [
      SizedBox(width: 40, child: Text(label,
          style: GoogleFonts.notoSansKr(color: _sec, fontSize: 12))),
      Expanded(child: Text(value, style: GoogleFonts.notoSansKr(
          color: _pri, fontSize: 12, fontWeight: FontWeight.w600))),
    ]),
  );
}
