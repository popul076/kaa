import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_state.dart';
import '../theme/app_theme.dart';

// ── 공통 컬러 ───────────────────────────────────────────
const _bg      = Color(0xFF020810);
const _card    = Color(0xFF0D1B2A);
const _navy    = Color(0xFF0A1628);
const _accent  = Color(0xFF4FC3F7);
const _green   = Color(0xFF10B981);
const _orange  = Color(0xFFFF6B35);
const _red     = Color(0xFFEF4444);
const _border  = Color(0xFF1E3A5F);
const _textPri = Colors.white;
const _textSec = Color(0xFFB0BEC5);

// ══════════════════════════════════════════════════════════════════════════
// 1. 견적 요청서 작성 화면
//    - 차량정보, 지역, 증상아이콘, 메모, 다중이미지(최대10장, 앱내압축)
//    - 요청 완료 시 FCM 시뮬레이션 (근처 점포 알림)
// ══════════════════════════════════════════════════════════════════════════
class QuoteRequestScreen extends StatefulWidget {
  const QuoteRequestScreen({super.key});
  @override
  State<QuoteRequestScreen> createState() => _QuoteRequestScreenState();
}

class _QuoteRequestScreenState extends State<QuoteRequestScreen> {
  final _carNameCtrl    = TextEditingController();
  final _regionCtrl     = TextEditingController(text: '대구 수성구');
  final _repairTypeCtrl = TextEditingController();
  final _memoCtrl       = TextEditingController();

  final Set<String> _selectedSymptoms = {};
  final List<XFile>  _selectedImages   = [];
  final List<XFile>  _compressedImages = [];
  bool _isSubmitting = false;
  bool _isCompressing = false;

  static const _kCarName    = 'qr_car_name';
  static const _kRegion     = 'qr_region';
  static const _kRepairType = 'qr_repair_type';
  static const _kSymptoms   = 'qr_symptoms';

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  // ── 저장된 데이터 복원 (사용자 입력 유지) ──────────────
  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final carName    = prefs.getString(_kCarName);
    final region     = prefs.getString(_kRegion);
    final repairType = prefs.getString(_kRepairType);
    final symptoms   = prefs.getStringList(_kSymptoms) ?? [];
    setState(() {
      if (carName != null && carName.isNotEmpty) _carNameCtrl.text = carName;
      if (region  != null && region.isNotEmpty)  _regionCtrl.text  = region;
      if (repairType != null && repairType.isNotEmpty) _repairTypeCtrl.text = repairType;
      _selectedSymptoms.addAll(symptoms);
    });
  }

  // ── 입력 데이터 저장 ──────────────────────────────────
  Future<void> _saveInputData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCarName,    _carNameCtrl.text.trim());
    await prefs.setString(_kRegion,     _regionCtrl.text.trim());
    await prefs.setString(_kRepairType, _repairTypeCtrl.text.trim());
    await prefs.setStringList(_kSymptoms, _selectedSymptoms.toList());
  }

  // ── 입력 데이터 초기화 (새 요청 시작 시) ──────────────
  Future<void> _clearSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kCarName);
    await prefs.remove(_kRegion);
    await prefs.remove(_kRepairType);
    await prefs.remove(_kSymptoms);
    setState(() {
      _carNameCtrl.clear();
      _regionCtrl.text = '대구 수성구';
      _repairTypeCtrl.clear();
      _memoCtrl.clear();
      _selectedSymptoms.clear();
      _selectedImages.clear();
      _compressedImages.clear();
    });
  }

  @override
  void dispose() {
    _saveInputData(); // 화면 이탈 시 자동 저장
    _carNameCtrl.dispose();
    _regionCtrl.dispose();
    _repairTypeCtrl.dispose();
    _memoCtrl.dispose();
    super.dispose();
  }

  // _carNumCtrl 제거됨 — 차량번호는 확정 후 수집

  // ── 이미지 선택 + 즉시 압축 ──────────────────────────
  Future<void> _pickImages(ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        final images = await _picker.pickMultiImage(imageQuality: 100);
        if (images.isEmpty) return;
        final remaining = 10 - _selectedImages.length;
        final toAdd = images.take(remaining).toList();
        if (toAdd.isEmpty) {
          _showSnack('최대 10장까지 선택 가능합니다');
          return;
        }
        setState(() => _isCompressing = true);
        for (final img in toAdd) {
          final compressed = await _compressImage(img);
          setState(() {
            _selectedImages.add(img);
            _compressedImages.add(compressed ?? img);
          });
        }
        setState(() => _isCompressing = false);
      } else {
        final img = await _picker.pickImage(source: source, imageQuality: 100);
        if (img == null) return;
        if (_selectedImages.length >= 10) {
          _showSnack('최대 10장까지 선택 가능합니다'); return;
        }
        setState(() => _isCompressing = true);
        final compressed = await _compressImage(img);
        setState(() {
          _selectedImages.add(img);
          _compressedImages.add(compressed ?? img);
          _isCompressing = false;
        });
      }
    } catch (e) {
      setState(() => _isCompressing = false);
      _showSnack('이미지 선택 중 오류가 발생했습니다');
    }
  }

  // ── 이미지 압축 (5MB → 300KB 미만 목표) ─────────────
  Future<XFile?> _compressImage(XFile file) async {
    try {
      final outPath = '${file.path}_compressed.jpg';
      final result = await FlutterImageCompress.compressAndGetFile(
        file.path, outPath,
        quality: 40,        // 품질 40% → 90%+ 압축률
        minWidth: 1280,
        minHeight: 720,
        format: CompressFormat.jpeg,
      );
      return result;
    } catch (_) {
      return null;
    }
  }

  void _removeImage(int idx) {
    setState(() {
      _selectedImages.removeAt(idx);
      _compressedImages.removeAt(idx);
    });
  }

  // ── 견적 요청 제출 ────────────────────────────────────
  Future<void> _submit() async {
    if (_carNameCtrl.text.trim().isEmpty) {
      _showSnack('차량명을 입력해 주세요'); return;
    }
    if (_selectedSymptoms.isEmpty) {
      _showSnack('증상을 하나 이상 선택해 주세요'); return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 800)); // 전송 시뮬레이션

    final req = EstimateRequest(
      requestId: 'REQ-${DateTime.now().millisecondsSinceEpoch}',
      carName:   _carNameCtrl.text.trim(),
      carNumber: '',  // 차량번호는 확정 후 입력
      region:    _regionCtrl.text.trim(),
      repairType: _repairTypeCtrl.text.trim().isEmpty ? '일반 정비' : _repairTypeCtrl.text.trim(),
      symptoms:  _selectedSymptoms.toList(),
      memo:      _memoCtrl.text.trim(),
      compressedImageUrls: _compressedImages.map((f) => f.path).toList(),
      createdAt: DateTime.now(),
    );

    AppState().addEstimateRequest(req);
    await _clearSavedData(); // 전송 성공 시 캐시 초기화

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    // FCM 시뮬레이션 배너
    _showFcmBanner();
  }

  void _showFcmBanner() {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
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
            boxShadow: [BoxShadow(color: _green.withOpacity(0.2), blurRadius: 20)],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: _green.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: _green.withOpacity(0.5)),
              ),
              child: const Icon(Icons.check_circle_rounded, color: _green, size: 36),
            ),
            const SizedBox(height: 16),
            const Text('견적 요청 완료!',
              style: TextStyle(color: _textPri, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('주변 정비점포에 실시간 알림을 발송했습니다.\n견적서가 도착하면 알림으로 알려드립니다.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _textSec, fontSize: 13, height: 1.6)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _accent.withOpacity(0.3)),
              ),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.notifications_active, color: _accent, size: 14),
                SizedBox(width: 6),
                Text('근처 정비점포에 FCM 알림 발송 중...',
                  style: TextStyle(color: _accent, fontSize: 11, fontWeight: FontWeight.w600)),
              ]),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // dialog 닫기
                  Navigator.pop(context); // 요청서 화면 닫기
                  Navigator.pushNamed(context, '/quote-received');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('도착한 견적서 확인하기',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
              ),
            ),
            const SizedBox(height: 10),
            // ── 내 요청 현황으로 가기 버튼 ──
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context); // dialog 닫기
                  Navigator.pop(context); // 요청서 화면 닫기
                  Navigator.pushNamed(context, '/my-quotes');
                },
                icon: const Icon(Icons.list_alt_rounded, color: _accent, size: 16),
                label: const Text('내 요청 현황으로 가기',
                  style: TextStyle(color: _accent, fontWeight: FontWeight.w600, fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: _accent.withOpacity(0.5)),
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

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF1E3A5F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4,
              decoration: BoxDecoration(color: _border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text('사진 추가', style: TextStyle(color: _textPri, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Row(children: [
              _sourceBtn(Icons.camera_alt_outlined, '사진 찍기',   () { Navigator.pop(context); _pickImages(ImageSource.camera); }),
              const SizedBox(width: 12),
              _sourceBtn(Icons.photo_library_outlined, '앨범에서 선택', () { Navigator.pop(context); _pickImages(ImageSource.gallery); }),
            ]),
            const SizedBox(height: 8),
          ]),
        ),
      ),
    );
  }

  Widget _sourceBtn(IconData icon, String label, VoidCallback onTap) {
    return Expanded(child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: _navy,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: _accent, size: 28),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: _textSec, fontSize: 12, fontWeight: FontWeight.w600)),
        ]),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: _bg,
        statusBarIconBrightness: Brightness.light,
      ),
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
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: _textPri, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('정비 견적 요청', style: TextStyle(color: _textPri, fontSize: 17, fontWeight: FontWeight.w800)),
                  Text('사진으로 근처 정비점에 견적을 요청하세요', style: TextStyle(color: _textSec, fontSize: 11)),
                ]),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: _accent.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.photo_camera, color: _accent, size: 12),
                  SizedBox(width: 4),
                  Text('최대 10장', style: TextStyle(color: _accent, fontSize: 10, fontWeight: FontWeight.w600)),
                ]),
              ),
            ]),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // ── ① 차량 정보 ────────────────────────────
                _sectionTitle('🚗  차량 정보'),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _accent.withOpacity(0.2)),
                  ),
                  child: const Row(children: [
                    Icon(Icons.info_outline, color: _accent, size: 13),
                    SizedBox(width: 6),
                    Text('차량번호는 정비 확정 후 별도로 수집합니다',
                      style: TextStyle(color: _accent, fontSize: 11)),
                  ]),
                ),
                const SizedBox(height: 10),
                _inputField(_carNameCtrl, '차량명 (예: 그랜저, 쏘나타)', Icons.directions_car_outlined),
                const SizedBox(height: 10),
                _inputField(_regionCtrl, '방문 지역', Icons.location_on_outlined),
                const SizedBox(height: 10),
                _inputField(_repairTypeCtrl, '정비 유형 (예: 사고수리, 엔진오일 교환)', Icons.build_outlined),

                const SizedBox(height: 24),

                // ── ② 증상 아이콘 선택 ─────────────────────
                Row(children: [
                  _sectionTitle('🔍  증상 선택'),
                  const SizedBox(width: 6),
                  const Text('(복수 선택 가능)', style: TextStyle(color: _textSec, fontSize: 11)),
                ]),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: kSymptomIcons.map((s) {
                    final selected = _selectedSymptoms.contains(s.id);
                    return GestureDetector(
                      onTap: () => setState(() {
                        if (selected) _selectedSymptoms.remove(s.id);
                        else          _selectedSymptoms.add(s.id);
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          color: selected ? _accent.withOpacity(0.18) : _card,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: selected ? _accent : _border,
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(s.emoji, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 5),
                          Text(s.label, style: TextStyle(
                            color: selected ? _accent : _textSec,
                            fontSize: 12,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                          )),
                        ]),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // ── ③ 상세 메모 ────────────────────────────
                _sectionTitle('📝  상세 메모'),
                const SizedBox(height: 10),
                TextField(
                  controller: _memoCtrl,
                  maxLines: 4,
                  style: const TextStyle(color: _textPri, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: '증상이나 요청사항을 자세히 작성해 주세요.\n예) 급감속 시 소음, 정지선 앞 진동 등',
                    hintStyle: TextStyle(color: _textSec.withOpacity(0.6), fontSize: 12),
                    filled: true, fillColor: _card,
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _accent)),
                  ),
                ),

                const SizedBox(height: 24),

                // ── ④ 사고/증상 사진 ───────────────────────
                Row(children: [
                  _sectionTitle('📸  사고/증상 사진'),
                  const Spacer(),
                  Text('${_selectedImages.length}/10',
                    style: TextStyle(color: _selectedImages.length >= 10 ? _orange : _textSec, fontSize: 12, fontWeight: FontWeight.w600)),
                ]),
                const SizedBox(height: 10),

                if (_isCompressing)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: _accent)),
                      SizedBox(width: 10),
                      Text('이미지 압축 중... (용량 90% 절감)', style: TextStyle(color: _textSec, fontSize: 12)),
                    ]),
                  ),

                // 이미지 그리드
                if (_selectedImages.isNotEmpty) ...[
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, mainAxisSpacing: 6, crossAxisSpacing: 6, childAspectRatio: 1),
                    itemCount: _selectedImages.length,
                    itemBuilder: (_, i) => Stack(children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(_selectedImages[i].path),
                          fit: BoxFit.cover, width: double.infinity, height: double.infinity,
                          errorBuilder: (_, __, ___) => Container(
                            color: _card,
                            child: const Icon(Icons.broken_image, color: _textSec),
                          ),
                        ),
                      ),
                      Positioned(top: 4, right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(i),
                          child: Container(
                            width: 22, height: 22,
                            decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                            child: const Icon(Icons.close, color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                      // 압축 크기 표시 (시뮬레이션)
                      Positioned(bottom: 4, left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                          child: const Text('압축완료', style: TextStyle(color: Colors.white, fontSize: 8)),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 10),
                ],

                // 사진 추가 버튼 2개
                if (_selectedImages.length < 10)
                  Row(children: [
                    Expanded(
                      child: _photoBtn(Icons.camera_alt_outlined, '사진 찍기',
                        () => _pickImages(ImageSource.camera)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _photoBtn(Icons.photo_library_outlined, '앨범사진 찾기',
                        () => _pickImages(ImageSource.gallery)),
                    ),
                  ]),

                const SizedBox(height: 24),

                // ── ⑤ 요청 받는 근처 점포 미리보기 ─────────
                _sectionTitle('📍  요청 받는 근처 점포'),
                const SizedBox(height: 10),
                ...AppData.stores.take(3).map((s) => _nearbyStoreRow(s)),

                const SizedBox(height: 8),
                Center(child: Text('GPS 기반 반경 내 점포에 자동 발송됩니다',
                  style: TextStyle(color: _textSec.withOpacity(0.6), fontSize: 11))),
              ]),
            ),
          ),

          // ── 하단 제출 버튼 ────────────────────────────
          Container(
            color: _card,
            padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  disabledBackgroundColor: _border,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSubmitting
                    ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.send_rounded, size: 18, color: Colors.white),
                        SizedBox(width: 8),
                        Text('견적 요청하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                      ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(title,
    style: const TextStyle(color: _textPri, fontSize: 14, fontWeight: FontWeight.w800));

  Widget _inputField(TextEditingController ctrl, String hint, IconData icon) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: _textPri, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: _textSec.withOpacity(0.6), fontSize: 12),
        prefixIcon: Icon(icon, color: _textSec, size: 18),
        filled: true, fillColor: _card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _accent)),
      ),
    );
  }

  Widget _photoBtn(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: _navy,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: _accent, size: 18),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: _textSec, fontSize: 12, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  Widget _nearbyStoreRow(Store store) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: _accent.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(color: _accent.withOpacity(0.3)),
          ),
          child: const Center(child: Text('🔧', style: TextStyle(fontSize: 17))),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(store.name, style: const TextStyle(color: _textPri, fontSize: 12, fontWeight: FontWeight.w700)),
          Text('${store.distance} · ⭐ ${store.rating}', style: const TextStyle(color: _textSec, fontSize: 10)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: _green.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _green.withOpacity(0.3)),
          ),
          child: const Text('알림대기', style: TextStyle(color: _green, fontSize: 9, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// 2. 도착한 견적서 목록 화면
//    - 내 요청서 목록 + 각 요청별 도착 견적서 카드
//    - 홈 상단 배너에서 진입
// ══════════════════════════════════════════════════════════════════════════
class QuoteReceivedScreen extends StatefulWidget {
  const QuoteReceivedScreen({super.key});
  @override
  State<QuoteReceivedScreen> createState() => _QuoteReceivedScreenState();
}

class _QuoteReceivedScreenState extends State<QuoteReceivedScreen> {
  @override
  void initState() {
    super.initState();
    AppState().initDummyEstimates();
  }

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
          // ── 헤더 ──────────────────────────────────
          Container(
            color: _card,
            padding: EdgeInsets.fromLTRB(16, topPad + 12, 16, 14),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: _textPri, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('도착한 견적서', style: TextStyle(color: _textPri, fontSize: 17, fontWeight: FontWeight.w800)),
                  Text('점포에서 보낸 견적을 확인하세요', style: TextStyle(color: _textSec, fontSize: 11)),
                ]),
              ),
              if (AppState().totalBidCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: _red, borderRadius: BorderRadius.circular(12)),
                  child: Text('${AppState().totalBidCount}건',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
                ),
            ]),
          ),

          Expanded(
            child: requests.isEmpty
                ? _emptyView()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: requests.length,
                    itemBuilder: (_, i) => _RequestCard(request: requests[i]),
                  ),
          ),
        ]),
      ),
    );
  }

  Widget _emptyView() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Text('📭', style: TextStyle(fontSize: 52)),
      const SizedBox(height: 16),
      const Text('아직 도착한 견적서가 없습니다', style: TextStyle(color: _textPri, fontSize: 16, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      const Text('견적을 요청하면 근처 정비점포에서\n빠르게 답변을 보내드립니다',
        textAlign: TextAlign.center, style: TextStyle(color: _textSec, fontSize: 13, height: 1.6)),
      const SizedBox(height: 24),
      ElevatedButton.icon(
        onPressed: () => Navigator.pushNamed(context, '/quote-request'),
        icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
        label: const Text('지금 견적 요청하기'),
        style: ElevatedButton.styleFrom(
          backgroundColor: _accent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    ]),
  );
}

class _RequestCard extends StatelessWidget {
  final EstimateRequest request;
  const _RequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final symptomLabels = request.symptoms
        .map((id) => kSymptomIcons.firstWhere((s) => s.id == id, orElse: () => const SymptomIcon(id: '', emoji: '', label: '')).label)
        .where((l) => l.isNotEmpty).join(' · ');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── 요청서 헤더 ──────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: _accent.withOpacity(0.3)),
              ),
              child: const Text('내 요청서', style: TextStyle(color: _accent, fontSize: 10, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 8),
            Text(request.status.emoji + '  ' + request.status.label,
              style: TextStyle(color: _statusColor(request.status), fontSize: 11, fontWeight: FontWeight.w600)),
            const Spacer(),
            Text(_timeAgo(request.createdAt), style: const TextStyle(color: _textSec, fontSize: 10)),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${request.carName}  ·  ${request.carNumber}',
              style: const TextStyle(color: _textPri, fontSize: 14, fontWeight: FontWeight.w800)),
            const SizedBox(height: 3),
            Text('${request.region}  ·  ${request.repairType}  ·  $symptomLabels',
              style: const TextStyle(color: _textSec, fontSize: 11)),
            if (request.memo.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(request.memo, style: const TextStyle(color: _textSec, fontSize: 11, height: 1.4),
                maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ]),
        ),

        if (request.bids.isNotEmpty) ...[
          Divider(color: _border, height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
            child: Row(children: [
              const Icon(Icons.mail_outline_rounded, color: _accent, size: 14),
              const SizedBox(width: 5),
              Text('점포 예상견적서  ${request.bidCount}건',
                style: const TextStyle(color: _accent, fontSize: 12, fontWeight: FontWeight.w700)),
            ]),
          ),
          ...request.bids.map((bid) => _BidPreviewTile(
            request: request, bid: bid,
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => QuoteDetailScreen(request: request, bid: bid))),
          )),
          const SizedBox(height: 8),
        ] else
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
            child: Row(children: [
              SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: _textSec.withOpacity(0.4))),
              const SizedBox(width: 8),
              const Text('견적서 도착 대기중...', style: TextStyle(color: _textSec, fontSize: 11)),
            ]),
          ),
      ]),
    );
  }

  Color _statusColor(RepairStatus s) {
    switch (s) {
      case RepairStatus.bidding:   return _accent;
      case RepairStatus.matched:   return _green;
      case RepairStatus.repairing: return _orange;
      case RepairStatus.completed: return _green;
      default: return _textSec;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1)  return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24)   return '${diff.inHours}시간 전';
    return '${diff.inDays}일 전';
  }
}

class _BidPreviewTile extends StatelessWidget {
  final EstimateRequest request;
  final QuoteBid bid;
  final VoidCallback onTap;
  const _BidPreviewTile({required this.request, required this.bid, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isUnread = !bid.isRead;
    return GestureDetector(
      onTap: () {
        // 읽음 처리
        if (isUnread) {
          AppState().markBidRead(request.requestId, bid.bidId);
        }
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUnread ? _accent.withOpacity(0.05) : _navy,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnread ? _accent.withOpacity(0.4) : _border.withOpacity(0.7),
            width: isUnread ? 1.5 : 1,
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Stack(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(bid.storeImage, width: 40, height: 40, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(width: 40, height: 40, color: _card,
                    child: const Icon(Icons.store, color: _textSec, size: 20))),
              ),
              if (isUnread)
                Positioned(top: 0, right: 0,
                  child: Container(width: 10, height: 10,
                    decoration: const BoxDecoration(color: _orange, shape: BoxShape.circle))),
            ]),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(bid.storeName,
                  style: TextStyle(
                    color: _textPri, fontSize: 12, fontWeight: FontWeight.w700,
                  ))),
                if (isUnread)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: _orange, borderRadius: BorderRadius.circular(6)),
                    child: const Text('NEW', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w800)),
                  ),
                if (!isUnread)
                  const Icon(Icons.check_circle_rounded, color: _green, size: 14),
              ]),
              Row(children: [
                Text('${bid.storeDistance}  ', style: const TextStyle(color: _textSec, fontSize: 10)),
                const Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 11),
                Text('  ${bid.storeRating}', style: const TextStyle(color: _textSec, fontSize: 10)),
              ]),
            ])),
            const Icon(Icons.chevron_right_rounded, color: _textSec, size: 18),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            _costChip('부품비', '${_formatKRW(bid.partsCost)}원'),
            const SizedBox(width: 6),
            _costChip('공임비', '${_formatKRW(bid.laborCost)}원'),
            const SizedBox(width: 6),
            _costChip('예상총액', '${_formatKRW(bid.totalCost)}원', highlight: true),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.schedule_outlined, color: _textSec, size: 11),
            const SizedBox(width: 4),
            Text('예상 소요 ${bid.estimatedTime}', style: const TextStyle(color: _textSec, fontSize: 10)),
          ]),
        ]),
      ),
    );
  }

  Widget _costChip(String label, String val, {bool highlight = false}) {
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: highlight ? _accent.withOpacity(0.12) : _card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: highlight ? _accent.withOpacity(0.3) : _border),
      ),
      child: Column(children: [
        Text(label, style: const TextStyle(color: _textSec, fontSize: 8)),
        const SizedBox(height: 2),
        Text(val, style: TextStyle(color: highlight ? _accent : _textPri, fontSize: 11, fontWeight: FontWeight.w800)),
      ]),
    ));
  }

  String _formatKRW(int v) {
    return v.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }
}

// ══════════════════════════════════════════════════════════════════════════
// 3. 견적서 상세 화면
//    - 점포 정보 + 비용 3분할
//    - [전화문의] → phoneRevealed 후 전화번호 공개 (플랫폼 이탈 방지)
//    - [1:1 문의] → 채팅 페이지로
//    - 수리 현황 단계 표시
// ══════════════════════════════════════════════════════════════════════════
class QuoteDetailScreen extends StatefulWidget {
  final EstimateRequest request;
  final QuoteBid bid;
  const QuoteDetailScreen({super.key, required this.request, required this.bid});
  @override
  State<QuoteDetailScreen> createState() => _QuoteDetailScreenState();
}

class _QuoteDetailScreenState extends State<QuoteDetailScreen> {
  late QuoteBid _bid;

  @override
  void initState() {
    super.initState();
    _bid = widget.bid;
  }

  void _revealAndCall() {
    if (!_bid.phoneRevealed) {
      AppState().revealPhone(widget.request.requestId, _bid.bidId);
      setState(() { _bid.phoneRevealed = true; });
    }
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: _card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.phone_in_talk_rounded, color: _green, size: 40),
            const SizedBox(height: 12),
            Text(_bid.storeName, style: const TextStyle(color: _textPri, fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(_bid.storePhone, style: const TextStyle(color: _accent, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            const SizedBox(height: 8),
            const Text('전화번호가 공개되었습니다.\n통화 후 앱으로 돌아와 예약을 완료해 주세요.',
              textAlign: TextAlign.center, style: TextStyle(color: _textSec, fontSize: 11, height: 1.5)),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(foregroundColor: _textSec),
                child: const Text('닫기'),
              )),
              const SizedBox(width: 10),
              Expanded(child: ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  final uri = Uri.parse('tel:${_bid.storePhone}');
                  if (await canLaunchUrl(uri)) launchUrl(uri);
                },
                icon: const Icon(Icons.call, size: 16),
                label: const Text('전화걸기'),
                style: ElevatedButton.styleFrom(backgroundColor: _green),
              )),
            ]),
          ]),
        ),
      ),
    );
  }

  String _formatKRW(int v) =>
    v.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  // ── 매칭 동의 → 전화번호 팝업 → 매칭 확정 ────────────
  void _showMatchConfirmDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
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
            const SizedBox(height: 16),
            const Text('이 점포로 매칭할까요?',
              style: TextStyle(color: _textPri, fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('${_bid.storeName}과 매칭되면\n다른 점포의 견적은 자동으로 마감됩니다.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: _textSec, fontSize: 13, height: 1.6)),
            const SizedBox(height: 20),
            // 견적 요약
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _navy,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _border),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _matchInfoItem('예상총액', '${_formatKRW(_bid.totalCost)}원', _accent),
                _matchInfoItem('소요시간', _bid.estimatedTime, _textSec),
                _matchInfoItem('평점', '⭐ ${_bid.storeRating}', _textSec),
              ]),
            ),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _textSec,
                  side: const BorderSide(color: Color(0xFF1E3A5F)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('취소'),
              )),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showPhoneInputDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('동의하기', style: TextStyle(fontWeight: FontWeight.w800)),
              )),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _matchInfoItem(String label, String val, Color color) {
    return Column(children: [
      Text(label, style: const TextStyle(color: _textSec, fontSize: 10)),
      const SizedBox(height: 4),
      Text(val, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800)),
    ]);
  }

  // ── 전화번호 입력 팝업 → 매칭 성공 처리 ────────────────
  void _showPhoneInputDialog() {
    final phoneCtrl = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _accent.withOpacity(0.3), width: 1.5),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.phone_iphone_rounded, color: _accent, size: 40),
            const SizedBox(height: 12),
            const Text('연락처 확인',
              style: TextStyle(color: _textPri, fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('점포에서 연락할 수 있도록\n전화번호를 입력해 주세요.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _textSec, fontSize: 13, height: 1.6)),
            const SizedBox(height: 20),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: _textPri, fontSize: 15, letterSpacing: 1.2),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '010-0000-0000',
                hintStyle: TextStyle(color: _textSec.withOpacity(0.5)),
                filled: true, fillColor: _navy,
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _accent),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: OutlinedButton(
                onPressed: () => Navigator.pop(dialogCtx),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _textSec,
                  side: const BorderSide(color: Color(0xFF1E3A5F)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('뒤로'),
              )),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton(
                onPressed: () {
                  if (phoneCtrl.text.trim().length < 9) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('올바른 전화번호를 입력해 주세요')));
                    return;
                  }
                  Navigator.pop(dialogCtx);
                  _completeMatch();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('매칭 완료', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800)),
              )),
            ]),
          ]),
        ),
      ),
    );
  }

  // ── 매칭 완료 처리 + 알림 전송 시뮬레이션 ──────────────
  void _completeMatch() {
    AppState().matchRequest(widget.request.requestId, _bid.bidId);
    setState(() {
      _bid.phoneRevealed = true;
      _bid.status = RepairStatus.matched;
    });

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0D2040), Color(0xFF0A1628)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _green.withOpacity(0.5), width: 1.5),
            boxShadow: [BoxShadow(color: _green.withOpacity(0.2), blurRadius: 20)],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: _green.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: _green.withOpacity(0.5)),
              ),
              child: const Icon(Icons.celebration_rounded, color: _green, size: 36),
            ),
            const SizedBox(height: 16),
            const Text('🎉 매칭 성공!',
              style: TextStyle(color: _textPri, fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text('${_bid.storeName}과 매칭되었습니다!\n점포에서 곧 연락드릴 예정입니다.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: _textSec, fontSize: 13, height: 1.6)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _green.withOpacity(0.3)),
              ),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.notifications_active, color: _green, size: 14),
                SizedBox(width: 6),
                Text('다른 점포에 마감 알림 발송 완료',
                  style: TextStyle(color: _green, fontSize: 11, fontWeight: FontWeight.w600)),
              ]),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context); // 팝업 닫기
                  final uri = Uri.parse('tel:${_bid.storePhone}');
                  if (await canLaunchUrl(uri)) launchUrl(uri);
                },
                icon: const Icon(Icons.phone_rounded, size: 16),
                label: Text('📞  ${_bid.storePhone}  전화걸기',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context); // 팝업 닫기
                  Navigator.pop(context); // 상세 화면 닫기
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: _textSec,
                  side: BorderSide(color: _border.withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('견적서 목록으로 돌아가기'),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: _bg, statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: _bg,
        body: Column(children: [
          // ── 헤더 ──────────────────────────────────
          Container(
            color: _card,
            padding: EdgeInsets.fromLTRB(16, topPad + 12, 16, 14),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: _textPri, size: 20)),
              const SizedBox(width: 12),
              const Text('견적서 상세', style: TextStyle(color: _textPri, fontSize: 17, fontWeight: FontWeight.w800)),
            ]),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // ── 점포 카드 ──────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _border),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: _accent.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                        child: Text(_bid.storeBadge, style: const TextStyle(color: _accent, fontSize: 10, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 6),
                      Text('${_bid.storeDistance}  ·  ⭐ ${_bid.storeRating}',
                        style: const TextStyle(color: _textSec, fontSize: 11)),
                      const Spacer(),
                      Text(_bid.status.emoji + '  ' + _bid.status.label,
                        style: const TextStyle(color: _green, fontSize: 11, fontWeight: FontWeight.w600)),
                    ]),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(_bid.storeImage,
                        width: double.infinity, height: 140, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(height: 140, color: _navy,
                          child: const Center(child: Icon(Icons.store, color: _textSec, size: 48)))),
                    ),
                    const SizedBox(height: 12),
                    Text(_bid.storeName, style: const TextStyle(color: _textPri, fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    // 전화번호: 공개된 경우만 표시
                    if (_bid.phoneRevealed)
                      Row(children: [
                        const Icon(Icons.phone, color: _green, size: 14),
                        const SizedBox(width: 6),
                        Text(_bid.storePhone, style: const TextStyle(color: _green, fontSize: 13, fontWeight: FontWeight.w700)),
                      ])
                    else
                      const Row(children: [
                        Icon(Icons.lock_outline, color: _textSec, size: 14),
                        SizedBox(width: 6),
                        Text('전화번호는 전화문의 클릭 시 공개됩니다',
                          style: TextStyle(color: _textSec, fontSize: 11)),
                      ]),
                  ]),
                ),

                const SizedBox(height: 14),

                // ── 비용 3분할 ─────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _card, borderRadius: BorderRadius.circular(16), border: Border.all(color: _border)),
                  child: Column(children: [
                    const Row(children: [
                      Icon(Icons.receipt_long_outlined, color: _accent, size: 16),
                      SizedBox(width: 6),
                      Text('예상 견적', style: TextStyle(color: _textPri, fontSize: 14, fontWeight: FontWeight.w800)),
                    ]),
                    const SizedBox(height: 14),
                    Row(children: [
                      _bigCostBox('부품비', _bid.partsCost, _textSec),
                      const SizedBox(width: 8),
                      _bigCostBox('공임비', _bid.laborCost, _textSec),
                      const SizedBox(width: 8),
                      _bigCostBox('예상총액', _bid.totalCost, _accent, highlight: true),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      const Icon(Icons.schedule_outlined, color: _textSec, size: 13),
                      const SizedBox(width: 5),
                      Text('예상 소요 시간: ${_bid.estimatedTime}',
                        style: const TextStyle(color: _textSec, fontSize: 12)),
                    ]),
                  ]),
                ),

                const SizedBox(height: 14),

                // ── 수리 현황 타임라인 ─────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _card, borderRadius: BorderRadius.circular(16), border: Border.all(color: _border)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Row(children: [
                      Icon(Icons.timeline_rounded, color: _accent, size: 16),
                      SizedBox(width: 6),
                      Text('수리 현황', style: TextStyle(color: _textPri, fontSize: 14, fontWeight: FontWeight.w800)),
                    ]),
                    const SizedBox(height: 16),
                    _statusTimeline(),
                  ]),
                ),

                const SizedBox(height: 14),

                // ── 점포 메모 ──────────────────────────
                if (_bid.memo.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _navy, borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _orange.withOpacity(0.3)),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Row(children: [
                        Icon(Icons.info_outline_rounded, color: _orange, size: 14),
                        SizedBox(width: 6),
                        Text('점포 메모', style: TextStyle(color: _orange, fontSize: 12, fontWeight: FontWeight.w700)),
                      ]),
                      const SizedBox(height: 6),
                      Text(_bid.memo, style: const TextStyle(color: _textSec, fontSize: 12, height: 1.5)),
                    ]),
                  ),

                const SizedBox(height: 14),

                // ── 원터치 액션 버튼 ──────────────────────
                Column(children: [
                  // 매칭 상태에 따라 다른 버튼 표시
                  if (_bid.status == RepairStatus.matched || _bid.status == RepairStatus.bidding) ...[
                    // ── 매칭 동의 버튼 (아직 매칭 전) ──
                    if (widget.request.status != RepairStatus.matched)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _showMatchConfirmDialog(),
                          icon: const Icon(Icons.handshake_rounded, size: 18),
                          label: const Text('이 견적으로 매칭하기',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _green,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    if (widget.request.status == RepairStatus.matched)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: _green.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _green.withOpacity(0.4)),
                        ),
                        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.check_circle_rounded, color: _green, size: 18),
                          SizedBox(width: 8),
                          Text('매칭 완료된 점포입니다', style: TextStyle(color: _green, fontWeight: FontWeight.w700, fontSize: 14)),
                        ]),
                      ),
                    const SizedBox(height: 8),
                  ],
                  // 전화걸기 (즉시 전화 앱 실행)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (!_bid.phoneRevealed) {
                          AppState().revealPhone(widget.request.requestId, _bid.bidId);
                          setState(() { _bid.phoneRevealed = true; });
                        }
                        final uri = Uri.parse('tel:${_bid.storePhone}');
                        if (await canLaunchUrl(uri)) launchUrl(uri);
                      },
                      icon: const Icon(Icons.phone_rounded, size: 18),
                      label: Text(
                        _bid.phoneRevealed
                          ? '📞  ${_bid.storePhone}  바로 전화걸기'
                          : '📞  전화걸기 (탭하면 번호 공개 + 연결)',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A3A5C),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 1:1 문의 + 뒤로가기 나란히
                  Row(children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pushNamed(context, '/chat', arguments: {
                          'storeName': _bid.storeName,
                          'storeId':   _bid.storeId,
                        }),
                        icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                        label: const Text('1:1 문의', style: TextStyle(fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accent,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_rounded, size: 16, color: _accent),
                        label: const Text('뒤로가기',
                          style: TextStyle(color: _accent, fontWeight: FontWeight.w700)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: _accent.withOpacity(0.5)),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ]),
                ]),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _bigCostBox(String label, int amount, Color color, {bool highlight = false}) {
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: highlight ? _accent.withOpacity(0.1) : _navy,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: highlight ? _accent.withOpacity(0.4) : _border),
      ),
      child: Column(children: [
        Text(label, style: const TextStyle(color: _textSec, fontSize: 10)),
        const SizedBox(height: 4),
        Text('${_formatKRW(amount)}원',
          style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w900),
          textAlign: TextAlign.center),
      ]),
    ));
  }

  Widget _statusTimeline() {
    final steps = [
      RepairStatus.pending, RepairStatus.bidding,
      RepairStatus.matched, RepairStatus.repairing, RepairStatus.completed,
    ];
    final curIdx = steps.indexOf(_bid.status);
    return Row(
      children: steps.asMap().entries.map((e) {
        final idx = e.key;
        final s   = e.value;
        final done = idx <= curIdx;
        return Expanded(child: Row(children: [
          Expanded(child: Column(children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: done ? _green : _card,
                shape: BoxShape.circle,
                border: Border.all(color: done ? _green : _border, width: 1.5),
              ),
              child: Center(child: done
                ? const Icon(Icons.check, color: Colors.white, size: 14)
                : Text('${idx+1}', style: const TextStyle(color: _textSec, fontSize: 10))),
            ),
            const SizedBox(height: 4),
            Text(s.label, textAlign: TextAlign.center,
              style: TextStyle(color: done ? _green : _textSec, fontSize: 8, fontWeight: FontWeight.w600)),
          ])),
          if (idx < steps.length - 1)
            Container(height: 1.5, width: 12,
              color: idx < curIdx ? _green : _border),
        ]));
      }).toList(),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// 4. 점포측 투찰 화면 (StoreMgrScreen에서 진입)
//    - 요청 목록 + 빠른 답변 폼 (부품비·공임비·예상시간)
//    - 음성/텍스트 알림 ON/OFF 설정
//    - PC 점포관리자 연동 대비: 동일 데이터 모델 사용
// ══════════════════════════════════════════════════════════════════════════
class ShopQuoteScreen extends StatefulWidget {
  const ShopQuoteScreen({super.key});
  @override
  State<ShopQuoteScreen> createState() => _ShopQuoteScreenState();
}

class _ShopQuoteScreenState extends State<ShopQuoteScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  // 알림 설정
  bool _soundOn   = true;
  bool _textOn    = true;
  bool _vibration = true;

  // 투찰 입력
  final _partsCtrl  = TextEditingController();
  final _laborCtrl  = TextEditingController();
  final _etimeCtrl  = TextEditingController();
  final _bidMemoCtrl = TextEditingController();

  // 신규 요청 시뮬레이션
  final List<Map<String, dynamic>> _incomingRequests = [
    {
      'id': 'REQ-001',
      'car': '그랜저',
      'carNum': '123가4567',
      'region': '대구 수성구',
      'symptoms': ['소음', '사고수리'],
      'memo': '급감속 시 소음이 있습니다. 빠른 견적 부탁드립니다.',
      'time': '2분 전',
      'distance': '1.1km',
      'responded': false,
    },
    {
      'id': 'REQ-002',
      'car': '아반떼',
      'carNum': '456나7890',
      'region': '대구 수성구',
      'symptoms': ['브레이크', '누유'],
      'memo': '브레이크 밟을 때 소리가 납니다.',
      'time': '15분 전',
      'distance': '2.3km',
      'responded': true,
    },
  ];

  int? _respondingIdx;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    final s = AppState().shopNotifSettings;
    _soundOn   = s.soundEnabled;
    _textOn    = s.textEnabled;
    _vibration = s.vibration;
    // 신규 요청 알림 시뮬레이션
    WidgetsBinding.instance.addPostFrameCallback((_) => _simulateNewRequest());
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _partsCtrl.dispose();
    _laborCtrl.dispose();
    _etimeCtrl.dispose();
    _bidMemoCtrl.dispose();
    super.dispose();
  }

  void _simulateNewRequest() {
    if (!mounted) return;
    if (_textOn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.notifications_active, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Expanded(child: Text('새로운 정비 견적 요청이 도착했습니다!',
              style: TextStyle(fontWeight: FontWeight.w700))),
          ]),
          backgroundColor: const Color(0xFF1565C0),
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          action: SnackBarAction(label: '확인', textColor: _accent, onPressed: () {}),
        ),
      );
    }
    // 음성 알림은 실제 기기에서만 동작 (audioplayers 필요 시 연동)
    if (_soundOn) {
      HapticFeedback.heavyImpact(); // 진동으로 대체 (음성은 audioplayers 연동)
    }
  }

  void _submitBid(int idx) {
    final parts = int.tryParse(_partsCtrl.text.replaceAll(',', '')) ?? 0;
    final labor = int.tryParse(_laborCtrl.text.replaceAll(',', '')) ?? 0;
    if (parts == 0 || labor == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('부품비와 공임비를 입력해 주세요'),
          backgroundColor: Color(0xFF1E3A5F)));
      return;
    }
    setState(() {
      _incomingRequests[idx]['responded'] = true;
      _respondingIdx = null;
      _partsCtrl.clear(); _laborCtrl.clear();
      _etimeCtrl.clear(); _bidMemoCtrl.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ 견적서를 발송했습니다!'),
        backgroundColor: Color(0xFF10B981)));
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: _bg, statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: _bg,
        body: Column(children: [
          // ── 헤더 ──────────────────────────────────
          Container(
            color: _card,
            padding: EdgeInsets.fromLTRB(16, topPad + 12, 16, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: _textPri, size: 20)),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('점포 견적 관리', style: TextStyle(color: _textPri, fontSize: 17, fontWeight: FontWeight.w800)),
                    Text('PC 점포관리자와 동일 데이터 연동', style: TextStyle(color: _textSec, fontSize: 10)),
                  ]),
                ),
                // 알림 설정 버튼
                GestureDetector(
                  onTap: _showNotifSettings,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _soundOn ? _accent.withOpacity(0.15) : _card,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _soundOn ? _accent.withOpacity(0.4) : _border),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(_soundOn ? Icons.volume_up : Icons.volume_off,
                        color: _soundOn ? _accent : _textSec, size: 14),
                      const SizedBox(width: 4),
                      Text(_soundOn ? '음성 ON' : '음성 OFF',
                        style: TextStyle(color: _soundOn ? _accent : _textSec, fontSize: 10, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              TabBar(
                controller: _tabCtrl,
                indicatorColor: _accent,
                labelColor: _accent,
                unselectedLabelColor: _textSec,
                labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                tabs: [
                  Tab(text: '신규 요청  ${_incomingRequests.where((r) => !r['responded']).length}건'),
                  const Tab(text: '답변 완료'),
                ],
              ),
            ]),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                // ── 탭1: 신규 요청 ──────────────────
                _buildRequestList(false),
                // ── 탭2: 답변 완료 ──────────────────
                _buildRequestList(true),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildRequestList(bool showResponded) {
    final list = _incomingRequests
        .asMap().entries
        .where((e) => e.value['responded'] == showResponded)
        .toList();

    if (list.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(showResponded ? '📭' : '🎉', style: const TextStyle(fontSize: 48)),
        const SizedBox(height: 12),
        Text(showResponded ? '답변 완료된 요청이 없습니다' : '모든 요청에 답변했습니다!',
          style: const TextStyle(color: _textSec, fontSize: 14)),
      ]));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (_, i) {
        final idx = list[i].key;
        final req = list[i].value;
        return _RequestTile(
          req: req, idx: idx,
          isResponding: _respondingIdx == idx,
          showResponded: showResponded,
          partsCtrl: _partsCtrl, laborCtrl: _laborCtrl,
          etimeCtrl: _etimeCtrl, memoCtrl: _bidMemoCtrl,
          onRespond: () => setState(() => _respondingIdx = _respondingIdx == idx ? null : idx),
          onSubmit: () => _submitBid(idx),
        );
      },
    );
  }

  void _showNotifSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(builder: (ctx, setBS) {
        return SafeArea(child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: _border, borderRadius: BorderRadius.circular(2))),
            ]),
            const SizedBox(height: 16),
            const Text('알림 설정', style: TextStyle(color: _textPri, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text('PC 점포관리자와 동일하게 적용됩니다', style: TextStyle(color: _textSec, fontSize: 11)),
            const SizedBox(height: 20),
            _notifRow(ctx, setBS, Icons.volume_up_rounded, '음성 알림',
              '새 요청 시 "주변에 새로운 정비 요청이 도착했습니다" 음성 재생', _soundOn,
              (v) { setBS(() => _soundOn = v); setState(() => _soundOn = v); AppState().updateShopNotifSettings(sound: v); }),
            const SizedBox(height: 14),
            _notifRow(ctx, setBS, Icons.notifications_rounded, '텍스트 알림',
              '새 요청 시 앱 상단 배너로 알림 표시', _textOn,
              (v) { setBS(() => _textOn = v); setState(() => _textOn = v); AppState().updateShopNotifSettings(text: v); }),
            const SizedBox(height: 14),
            _notifRow(ctx, setBS, Icons.vibration_rounded, '진동 알림',
              '새 요청 시 기기 진동', _vibration,
              (v) { setBS(() => _vibration = v); setState(() => _vibration = v); AppState().updateShopNotifSettings(vibration: v); }),
            const SizedBox(height: 20),
            // PC 연동 안내
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _navy,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _accent.withOpacity(0.2)),
              ),
              child: const Row(children: [
                Icon(Icons.computer_rounded, color: _accent, size: 16),
                SizedBox(width: 8),
                Expanded(child: Text(
                  'PC 점포관리자 연동 시 알림 설정이 자동으로 동기화됩니다. (추후 지원 예정)',
                  style: TextStyle(color: _textSec, fontSize: 11, height: 1.4),
                )),
              ]),
            ),
            const SizedBox(height: 16),
          ]),
        ));
      }),
    );
  }

  Widget _notifRow(BuildContext ctx, StateSetter setBS, IconData icon, String title, String sub, bool val, Function(bool) onChange) {
    return Row(children: [
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: val ? _accent.withOpacity(0.12) : _card,
          shape: BoxShape.circle,
          border: Border.all(color: val ? _accent.withOpacity(0.4) : _border),
        ),
        child: Icon(icon, color: val ? _accent : _textSec, size: 20),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: _textPri, fontSize: 13, fontWeight: FontWeight.w700)),
        Text(sub, style: const TextStyle(color: _textSec, fontSize: 10, height: 1.3)),
      ])),
      Switch(
        value: val, onChanged: onChange,
        activeColor: _accent,
        inactiveThumbColor: _textSec,
        inactiveTrackColor: _border,
      ),
    ]);
  }
}

// ── 점포측 요청 타일 (빠른 투찰 폼 포함) ──────────────────────
class _RequestTile extends StatelessWidget {
  final Map<String, dynamic> req;
  final int idx;
  final bool isResponding;
  final bool showResponded;
  final TextEditingController partsCtrl, laborCtrl, etimeCtrl, memoCtrl;
  final VoidCallback onRespond, onSubmit;

  const _RequestTile({
    required this.req, required this.idx,
    required this.isResponding, required this.showResponded,
    required this.partsCtrl, required this.laborCtrl,
    required this.etimeCtrl, required this.memoCtrl,
    required this.onRespond, required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isResponding ? _accent.withOpacity(0.5) : _border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // 요청 헤더
            Row(children: [
              if (!showResponded)
                Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(color: _red, shape: BoxShape.circle),
                ),
              if (!showResponded) const SizedBox(width: 6),
              Text('${req['car']}  ·  ${req['carNum']}',
                style: const TextStyle(color: _textPri, fontSize: 14, fontWeight: FontWeight.w800)),
              const Spacer(),
              Text(req['time'], style: const TextStyle(color: _textSec, fontSize: 10)),
            ]),
            const SizedBox(height: 4),
            Text('${req['region']}  ·  ${req['distance']}',
              style: const TextStyle(color: _textSec, fontSize: 11)),
            const SizedBox(height: 6),
            // 증상 태그
            Wrap(spacing: 6, children: (req['symptoms'] as List<String>).map((s) =>
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(s, style: const TextStyle(color: _accent, fontSize: 10, fontWeight: FontWeight.w600)),
              ),
            ).toList()),
            const SizedBox(height: 6),
            Text(req['memo'], style: const TextStyle(color: _textSec, fontSize: 11, height: 1.4),
              maxLines: 2, overflow: TextOverflow.ellipsis),
          ]),
        ),

        if (!showResponded) ...[
          Divider(color: _border, height: 1),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(children: [
              if (isResponding) ...[
                // 빠른 투찰 폼 (10초 내 답변 목표)
                const Row(children: [
                  Icon(Icons.flash_on_rounded, color: _orange, size: 14),
                  SizedBox(width: 4),
                  Text('빠른 견적 입력  (10초 안에 보내세요!)',
                    style: TextStyle(color: _orange, fontSize: 11, fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: _bidInput(partsCtrl, '부품비 (원)', Icons.widgets_outlined)),
                  const SizedBox(width: 8),
                  Expanded(child: _bidInput(laborCtrl, '공임비 (원)', Icons.handyman_outlined)),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: _bidInput(etimeCtrl, '예상 시간 (예: 당일 1시간)', Icons.schedule_outlined)),
                  const SizedBox(width: 8),
                  Expanded(child: _bidInput(memoCtrl, '메모 (선택)', Icons.notes_outlined)),
                ]),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onSubmit,
                    icon: const Icon(Icons.send_rounded, size: 16),
                    label: const Text('견적서 발송', style: TextStyle(fontWeight: FontWeight.w800)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ] else
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onRespond,
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('견적서 작성하기', style: TextStyle(fontWeight: FontWeight.w700)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _accent,
                      side: const BorderSide(color: _border),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
            ]),
          ),
        ] else
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
            child: Row(children: [
              const Icon(Icons.check_circle_outline_rounded, color: _green, size: 16),
              const SizedBox(width: 6),
              const Text('견적서 발송 완료', style: TextStyle(color: _green, fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
          ),
      ]),
    );
  }

  Widget _bidInput(TextEditingController ctrl, String hint, IconData icon) {
    return TextField(
      controller: ctrl,
      keyboardType: hint.contains('원') ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: _textPri, fontSize: 12),
      decoration: InputDecoration(
        hintText: hint, hintStyle: const TextStyle(color: _textSec, fontSize: 10),
        prefixIcon: Icon(icon, size: 14, color: _textSec),
        filled: true, fillColor: _navy,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _accent)),
      ),
    );
  }
}
