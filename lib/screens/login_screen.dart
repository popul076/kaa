import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_state.dart';

// ═══════════════════════════════════════════════════════════════
// MOINCAR Login Screen — 군청색 다크 테마 (v22.0.0)
// 배경: #020810  포인트: #4FC3F7 (아이스블루)
// ═══════════════════════════════════════════════════════════════
// 자동 로그인 유틸리티
class AuthPrefs {
  static const _keyLoginTime = 'last_login_time';
  static const _keyLoggedIn  = 'is_logged_in';
  static const _autoLoginDays = 30;

  static Future<void> saveLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, true);
    await prefs.setInt(_keyLoginTime, DateTime.now().millisecondsSinceEpoch);
  }

  static Future<bool> isAutoLoginValid() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool(_keyLoggedIn) ?? false;
    if (!loggedIn) return false;
    final loginTime = prefs.getInt(_keyLoginTime) ?? 0;
    final diff = DateTime.now().millisecondsSinceEpoch - loginTime;
    final days = diff / (1000 * 60 * 60 * 24);
    return days < _autoLoginDays;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLoggedIn);
    await prefs.remove(_keyLoginTime);
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const Color _bg     = Color(0xFF020810);
  static const Color _s1     = Color(0xFF071428);
  static const Color _s2     = Color(0xFF0D1E3C);
  static const Color _br     = Color(0xFF1A3050);
  static const Color _accent = Color(0xFF4FC3F7);
  static const Color _t1     = Color(0xFFE8F4FF);
  static const Color _t2     = Color(0xFF7AB0D4);
  static const Color _t3     = Color(0xFF3A6080);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20, color: Color(0xFF7AB0D4)),
          onPressed: () => Navigator.pop(context),
        ),
        title: null,  // M 로고 + MOINCAR 텍스트 삭제
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 배경 글로우
          Positioned(
            top: -60, right: -60,
            child: Container(
              width: 240, height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _accent.withOpacity(0.04),
              ),
            ),
          ),
          Positioned(
            bottom: -40, left: -40,
            child: Container(
              width: 180, height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _accent.withOpacity(0.03),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // 안내 텍스트
                  Text(
                    '간편하게 시작하세요',
                    style: GoogleFonts.notoSansKr(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: _t1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'SNS 계정으로 MOINCAR를 바로 이용할 수 있습니다',
                    style: GoogleFonts.notoSansKr(
                      fontSize: 13,
                      color: _t3,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // 구분선
                  Container(
                    width: 36, height: 2,
                    decoration: BoxDecoration(
                      color: _accent.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),

                  const SizedBox(height: 44),

                  // 카카오 로그인 버튼
                  _SocialLoginButton(
                    bgColor: const Color(0xFFFEE500),
                    textColor: const Color(0xFF191919),
                    iconWidget: const _KakaoIcon(),
                    label: '카카오로 시작하기',
                    onTap: () async {
                      await AuthPrefs.saveLogin();
                      if (context.mounted) Navigator.pushNamed(context, '/signup-terms');
                    },
                  ),

                  const SizedBox(height: 12),

                  // 네이버 로그인 버튼
                  _SocialLoginButton(
                    bgColor: const Color(0xFF03C75A),
                    textColor: Colors.white,
                    iconWidget: const _NaverIcon(),
                    label: '네이버로 시작하기',
                    onTap: () async {
                      await AuthPrefs.saveLogin();
                      if (context.mounted) Navigator.pushNamed(context, '/signup-terms');
                    },
                  ),

                  const SizedBox(height: 12),

                  // 구글 로그인 버튼 — 다크 테마에 맞게 어두운 테두리
                  _SocialLoginButton(
                    bgColor: const Color(0xFF0D1E3C),
                    textColor: _t1,
                    borderColor: _br,
                    iconWidget: const _GoogleIcon(),
                    label: 'Google로 시작하기',
                    onTap: () async {
                      await AuthPrefs.saveLogin();
                      if (context.mounted) Navigator.pushNamed(context, '/signup-terms');
                    },
                  ),

                  const Spacer(),

                  // ── 구분선 + 일반 가입하기 ──
                  Row(
                    children: [
                      Expanded(child: Divider(color: _br, thickness: 0.8)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('또는',
                          style: GoogleFonts.notoSansKr(fontSize: 12, color: _t3)),
                      ),
                      Expanded(child: Divider(color: _br, thickness: 0.8)),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // 일반 가입하기 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const SignupNormalScreen())),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: _accent.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        backgroundColor: _accent.withOpacity(0.05),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_add_outlined, color: _accent, size: 18),
                          const SizedBox(width: 8),
                          Text('일반 가입하기 (ID·비밀번호·이메일)',
                            style: GoogleFonts.notoSansKr(
                              fontSize: 14, fontWeight: FontWeight.w700, color: _accent)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 이용약관 (다크 테마)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: _s1.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _br.withOpacity(0.4)),
                    ),
                    child: Text(
                      '로그인 시 이용약관 및 개인정보 처리방침에 동의하게 됩니다',
                      style: GoogleFonts.notoSansKr(fontSize: 11, color: _t3),
                      textAlign: TextAlign.center,
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

// ══════════════════════════════════════════════════════════
// 일반 가입 화면 (전화번호=아이디, 비밀번호, 이메일)
// ══════════════════════════════════════════════════════════
class SignupNormalScreen extends StatefulWidget {
  const SignupNormalScreen({super.key});
  @override
  State<SignupNormalScreen> createState() => _SignupNormalScreenState();
}

class _SignupNormalScreenState extends State<SignupNormalScreen> {
  static const Color _bg     = Color(0xFF020810);
  static const Color _card   = Color(0xFF0D1B2A);
  static const Color _br     = Color(0xFF1E3A5F);
  static const Color _accent = Color(0xFF4FC3F7);
  static const Color _orange = Color(0xFFFF6B35);
  static const Color _green  = Color(0xFF10B981);
  static const Color _t1     = Color(0xFFE8F4FF);
  static const Color _t3     = Color(0xFF3A6080);

  final _idCtrl     = TextEditingController(); // ID (영문/숫자)
  final _pwCtrl     = TextEditingController();
  final _pw2Ctrl    = TextEditingController();
  final _nameCtrl   = TextEditingController();
  final _emailCtrl  = TextEditingController();
  final _phoneCtrl  = TextEditingController(); // 전화번호 (선택)

  bool _pwVisible   = false;
  bool _pw2Visible  = false;
  bool _loading     = false;
  bool _idChecked   = false;
  bool _agreeTerms  = false;
  bool _agreePrivacy= false;
  int  _step        = 1; // 1=기본정보, 2=약관동의, 3=완료

  bool get _canNext1 =>
    _idCtrl.text.length >= 4 &&
    _pwCtrl.text.length >= 6 &&
    _pwCtrl.text == _pw2Ctrl.text &&
    _nameCtrl.text.isNotEmpty &&
    _emailCtrl.text.contains('@') &&
    _idChecked;

  void _checkId() {
    if (_idCtrl.text.length < 4) {
      _snack('아이디는 4자 이상이어야 합니다');
      return;
    }
    setState(() => _idChecked = true);
    _snack('✅ 사용 가능한 아이디입니다');
  }

  Future<void> _signup() async {
    if (!_agreeTerms || !_agreePrivacy) {
      _snack('필수 약관에 동의해주세요');
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));

    final user = UserModel(
      name: _nameCtrl.text,
      phone: _phoneCtrl.text,
      email: _emailCtrl.text,
      loginType: 'normal',
    );
    AppState().setLoggedIn(user);
    await AuthPrefs.saveLogin();
    setState(() { _loading = false; _step = 3; });
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: _bg, statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: _bg,
        body: Column(
          children: [
            // 상단바
            Container(
              color: _card,
              padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 10, 16, 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_step > 1) setState(() => _step--);
                      else Navigator.pop(context);
                    },
                    child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(_step == 3 ? '가입 완료' : '일반 회원 가입',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                  const Spacer(),
                  if (_step < 3)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _accent.withOpacity(0.4)),
                      ),
                      child: Text('$_step / 2',
                        style: TextStyle(fontSize: 12, color: _accent, fontWeight: FontWeight.w700)),
                    ),
                ],
              ),
            ),

            if (_step == 3)
              _buildComplete()
            else
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 진행바
                      LinearProgressIndicator(
                        value: _step == 1 ? 0.5 : 1.0,
                        backgroundColor: _br,
                        color: _accent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      const SizedBox(height: 8),
                      Text(_step == 1 ? '기본 정보 입력' : '약관 동의',
                        style: TextStyle(fontSize: 12, color: _accent, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 20),

                      if (_step == 1) ...[
                        // ── 이름
                        _label('이름 *'),
                        _darkField(_nameCtrl, '홍길동'),
                        const SizedBox(height: 16),

                        // ── 아이디 (ID)
                        _label('아이디 (ID) *'),
                        Row(
                          children: [
                            Expanded(
                              child: _darkField(_idCtrl, '영문/숫자 4자 이상',
                                onChanged: (_) => setState(() => _idChecked = false)),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _idChecked ? null : _checkId,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _idChecked ? _green : _accent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: Text(_idChecked ? '✓ 확인됨' : '중복확인',
                                  style: TextStyle(color: _bg, fontSize: 13, fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ],
                        ),
                        if (_idChecked)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Row(children: [
                              Icon(Icons.check_circle, color: _green, size: 14),
                              const SizedBox(width: 4),
                              Text('사용 가능한 아이디입니다',
                                style: TextStyle(color: _green, fontSize: 11, fontWeight: FontWeight.w600)),
                            ]),
                          ),
                        const SizedBox(height: 16),

                        // ── 비밀번호
                        _label('비밀번호 * (6자리 이상)'),
                        _darkFieldPw(_pwCtrl, '영문+숫자+특수문자 조합 권장', _pwVisible,
                          () => setState(() => _pwVisible = !_pwVisible)),
                        const SizedBox(height: 10),
                        _darkFieldPw(_pw2Ctrl, '비밀번호 확인', _pw2Visible,
                          () => setState(() => _pw2Visible = !_pw2Visible)),
                        if (_pw2Ctrl.text.isNotEmpty && _pwCtrl.text != _pw2Ctrl.text)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text('비밀번호가 일치하지 않습니다',
                              style: TextStyle(color: Colors.red.shade400, fontSize: 11)),
                          ),
                        const SizedBox(height: 16),

                        // ── 이메일 (필수)
                        _label('이메일 *'),
                        _darkField(_emailCtrl, 'example@email.com',
                          keyboardType: TextInputType.emailAddress),
                        const SizedBox(height: 16),

                        // ── 전화번호 (선택)
                        _label('전화번호 (선택)'),
                        _darkField(_phoneCtrl, '01012345678',
                          keyboardType: TextInputType.phone),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: _accent.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _accent.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: _accent, size: 14),
                              const SizedBox(width: 8),
                              Expanded(child: Text(
                                '간편 로그인(카카오/네이버/구글)과 달리 아이디·비밀번호·이메일로 가입합니다.',
                                style: TextStyle(fontSize: 11, color: _t3))),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _canNext1 ? () => setState(() => _step = 2) : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _canNext1 ? _accent : _br,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: Text('다음 단계',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                                color: _canNext1 ? _bg : _t3)),
                          ),
                        ),
                      ],

                      // ── STEP 2: 약관 동의
                      if (_step == 2) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _card,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: _br),
                          ),
                          child: Column(
                            children: [
                              _agreeRow('[필수] 서비스 이용약관 동의', _agreeTerms,
                                (v) => setState(() => _agreeTerms = v!)),
                              const Divider(color: Color(0xFF1E3A5F), height: 20),
                              _agreeRow('[필수] 개인정보 처리방침 동의', _agreePrivacy,
                                (v) => setState(() => _agreePrivacy = v!)),
                              const Divider(color: Color(0xFF1E3A5F), height: 20),
                              _agreeRow('[선택] 마케팅 정보 수신 동의', false,
                                (v) {}),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 가입 정보 요약
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _accent.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _accent.withOpacity(0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('📋 가입 정보 확인',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _t1)),
                              const SizedBox(height: 10),
                              _infoRow('아이디', _idCtrl.text),
                              _infoRow('이름', _nameCtrl.text),
                              _infoRow('이메일', _emailCtrl.text),
                              if (_phoneCtrl.text.isNotEmpty)
                                _infoRow('전화번호', _phoneCtrl.text),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: (_agreeTerms && _agreePrivacy && !_loading) ? _signup : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: (_agreeTerms && _agreePrivacy) ? _orange : _br,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: _loading
                              ? const SizedBox(width: 22, height: 22,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                              : Text('가입 완료하기',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                                    color: (_agreeTerms && _agreePrivacy) ? Colors.white : _t3)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _agreeRow(String label, bool value, void Function(bool?) onChanged) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: _accent,
          checkColor: _bg,
          side: BorderSide(color: _br),
        ),
        Expanded(child: Text(label,
          style: TextStyle(fontSize: 13, color: _t1))),
        Icon(Icons.chevron_right, color: _t3, size: 16),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(width: 70,
            child: Text('$label:', style: TextStyle(fontSize: 12, color: _t3))),
          Expanded(child: Text(value,
            style: TextStyle(fontSize: 12, color: _t1, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _buildComplete() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: _green.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: _green.withOpacity(0.4), width: 2),
              ),
              child: Icon(Icons.check_rounded, color: _green, size: 40),
            ),
            const SizedBox(height: 20),
            Text('가입이 완료되었습니다!',
              style: GoogleFonts.notoSansKr(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 8),
            Text('${_nameCtrl.text}님 (${_idCtrl.text}),\nMOINCAR 모인카에 오신 것을 환영합니다!',
              style: TextStyle(fontSize: 13, color: _t3), textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _accent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _accent.withOpacity(0.3)),
              ),
              child: Text('아이디: ${_idCtrl.text}\n이메일: ${_emailCtrl.text}',
                style: TextStyle(fontSize: 12, color: _accent), textAlign: TextAlign.center),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context, '/home', (_) => false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('MOINCAR 시작하기',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _bg)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(t, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)));

  Widget _darkField(TextEditingController ctrl, String hint,
    {TextInputType? keyboardType, void Function(String)? onChanged}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      onChanged: onChanged ?? (_) => setState(() {}),
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: _t3.withOpacity(0.6), fontSize: 13),
        filled: true, fillColor: _card,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _br)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _br)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _accent)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }

  Widget _darkFieldPw(TextEditingController ctrl, String hint, bool visible, VoidCallback toggle) {
    return TextField(
      controller: ctrl,
      obscureText: !visible,
      onChanged: (_) => setState(() {}),
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: _t3.withOpacity(0.6), fontSize: 13),
        filled: true, fillColor: _card,
        suffixIcon: IconButton(
          icon: Icon(visible ? Icons.visibility_off : Icons.visibility, color: _t3, size: 20),
          onPressed: toggle,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _br)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _br)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _accent)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }

  @override
  void dispose() {
    _idCtrl.dispose(); _pwCtrl.dispose(); _pw2Ctrl.dispose();
    _nameCtrl.dispose(); _emailCtrl.dispose(); _phoneCtrl.dispose();
    super.dispose();
  }
}

// ── 공통 소셜 로그인 버튼 ──────────────────────────────────
class _SocialLoginButton extends StatelessWidget {
  final Color bgColor;
  final Color textColor;
  final Color? borderColor;
  final Widget iconWidget;
  final String label;
  final VoidCallback onTap;

  const _SocialLoginButton({
    required this.bgColor,
    required this.textColor,
    this.borderColor,
    required this.iconWidget,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: borderColor != null
                ? BorderSide(color: borderColor!)
                : BorderSide.none,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: iconWidget,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.notoSansKr(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 카카오 아이콘 ─────────────────────────────────────────
class _KakaoIcon extends StatelessWidget {
  const _KakaoIcon();
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 24, height: 24,
      child: CustomPaint(painter: _KakaoPainter()),
    );
  }
}

class _KakaoPainter extends CustomPainter {
  const _KakaoPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF191919);
    canvas.drawOval(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.82), paint);
    final path = Path()
      ..moveTo(size.width * 0.35, size.height * 0.75)
      ..lineTo(size.width * 0.25, size.height)
      ..lineTo(size.width * 0.55, size.height * 0.80)
      ..close();
    canvas.drawPath(path, paint);
  }
  @override bool shouldRepaint(_) => false;
}

// ── 네이버 아이콘 ─────────────────────────────────────────
class _NaverIcon extends StatelessWidget {
  const _NaverIcon();
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 24, height: 24,
      child: Center(
        child: Text('N',
          style: TextStyle(
            color: Colors.white, fontSize: 16,
            fontWeight: FontWeight.w900, fontFamily: 'Arial')),
      ),
    );
  }
}

// ── 구글 아이콘 ────────────────────────────────────────────
class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 24, height: 24,
      child: CustomPaint(painter: _GooglePainter()),
    );
  }
}

class _GooglePainter extends CustomPainter {
  const _GooglePainter();
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    // 반투명 배경 원
    canvas.drawCircle(Offset(cx, cy), r,
      Paint()..color = const Color(0xFF1A3050));

    // 4분면 색상
    final colors = [
      const Color(0xFF4285F4),
      const Color(0xFFEA4335),
      const Color(0xFFFBBC05),
      const Color(0xFF34A853),
    ];
    for (int i = 0; i < 4; i++) {
      final paint = Paint()..color = colors[i];
      final startAngle = (i * 90 - 45) * 3.14159 / 180;
      final sweepAngle = 90 * 3.14159 / 180;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.85),
        startAngle, sweepAngle, true, paint);
    }

    // 가운데 원 (도넛)
    canvas.drawCircle(Offset(cx, cy), r * 0.5,
      Paint()..color = const Color(0xFF0D1E3C));

    // G 가로 막대
    canvas.drawRect(
      Rect.fromLTWH(cx, cy - r * 0.12, r * 0.85, r * 0.24),
      Paint()..color = const Color(0xFF4285F4));
  }
  @override bool shouldRepaint(_) => false;
}
