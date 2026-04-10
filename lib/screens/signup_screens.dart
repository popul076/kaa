import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';
import '../widgets/common_widgets.dart';

// ═══════════════════════════════════════════════════════════════
// 가입 화면 전체 — 군청색 다크 테마 통일 (홈/로그인과 동일)
// bg:#020810  s1:#071428  s2:#0D1E3C  br:#1A3050
// accent:#4FC3F7  t1:#E8F4FF  t2:#7AB0D4  t3:#3A6080
// ═══════════════════════════════════════════════════════════════

// ── 색상 상수 ────────────────────────────────────────────────
const Color _bg      = Color(0xFF020810);
const Color _s1      = Color(0xFF071428);
const Color _s2      = Color(0xFF0D1E3C);
const Color _br      = Color(0xFF1A3050);
const Color _accent  = Color(0xFF4FC3F7);
const Color _t1      = Color(0xFFE8F4FF);
const Color _t2      = Color(0xFF7AB0D4);
const Color _t3      = Color(0xFF3A6080);

// ── 공통 다크 진행 표시 ──────────────────────────────────────
class SignupProgress extends StatelessWidget {
  final int step;
  const SignupProgress({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    final steps = ['약관동의', '프로필', '관심분야'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
      color: _bg,
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            return Expanded(
              child: Container(
                height: 2,
                color: (i ~/ 2) < step - 1 ? _accent : _br,
              ),
            );
          }
          final si = i ~/ 2;
          final isActive = si + 1 == step;
          final isDone   = si + 1 < step;
          return Column(
            children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isDone || isActive) ? _accent : _s2,
                  border: Border.all(
                    color: (isDone || isActive) ? _accent : _br,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: isDone
                    ? const Icon(Icons.check, size: 14, color: Color(0xFF020810))
                    : Text('${si + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isActive ? _bg : _t3,
                        ),
                      ),
                ),
              ),
              const SizedBox(height: 4),
              Text(steps[si],
                style: TextStyle(
                  fontSize: 10,
                  color: isActive ? _accent : _t3,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ==================== STEP 1: 약관동의 ====================
class SignupTermsScreen extends StatefulWidget {
  const SignupTermsScreen({super.key});
  @override
  State<SignupTermsScreen> createState() => _SignupTermsScreenState();
}

class _SignupTermsScreenState extends State<SignupTermsScreen> {
  final state = AppState();
  final List<String> allIds = ['service', 'privacy', 'location', 'marketing', 'age'];
  final List<String> reqIds = ['service', 'privacy', 'location', 'age'];

  final Map<String, String> termLabels = {
    'service':   '[필수] 서비스 이용약관',
    'privacy':   '[필수] 개인정보 수집 및 이용',
    'location':  '[필수] 위치기반 서비스 이용약관',
    'marketing': '[선택] 마케팅 정보 수신 동의',
    'age':       '[필수] 만 14세 이상입니다',
  };

  bool get allAgreed => allIds.every((id) => state.signup.agreed.contains(id));
  bool get reqDone   => reqIds.every((id) => state.signup.agreed.contains(id));

  void toggleAll() => setState(() {
    state.signup.agreed = allAgreed ? [] : [...allIds];
  });

  void toggleTerm(String id) => setState(() {
    state.signup.agreed.contains(id)
      ? state.signup.agreed.remove(id)
      : state.signup.agreed.add(id);
  });

  @override
  Widget build(BuildContext context) {
    final provider = state.signup.provider ?? 'kakao';
    final pvData = {
      'kakao':  {'bg': const Color(0xFFFEE500), 'fg': const Color(0xFF191919), 'name': '카카오'},
      'naver':  {'bg': const Color(0xFF03C75A), 'fg': Colors.white,            'name': '네이버'},
      'google': {'bg': const Color(0xFF4285F4), 'fg': Colors.white,            'name': '구글'},
    }[provider] ?? {'bg': _s2, 'fg': _t1, 'name': '소셜'};

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _DarkNav(title: '회원가입', onBack: () => Navigator.pushNamed(context, '/login')),
            SignupProgress(step: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    // 제공자 배지
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: (pvData['bg'] as Color).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: (pvData['bg'] as Color).withOpacity(0.4)),
                      ),
                      child: Text('${pvData['name']} 계정으로 가입 중',
                        style: TextStyle(
                          color: pvData['bg'] as Color,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('서비스 이용약관에\n동의해 주세요',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _t1),
                    ),
                    const SizedBox(height: 8),
                    Text('MOINCAR 모빌리티 플랫폼 서비스를 시작합니다.',
                      style: TextStyle(fontSize: 13, color: _t2),
                    ),
                    const SizedBox(height: 24),

                    // 전체 동의
                    GestureDetector(
                      onTap: toggleAll,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: allAgreed ? _accent.withOpacity(0.12) : _s1,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: allAgreed ? _accent : _br,
                          ),
                        ),
                        child: Row(
                          children: [
                            _DarkCheckBox(checked: allAgreed),
                            const SizedBox(width: 12),
                            Text('전체 동의',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _t1),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(height: 24, color: _br),

                    // 개별 약관
                    ...['service', 'privacy', 'location', 'marketing', 'age'].map((id) {
                      return _DarkTermItem(
                        id: id,
                        label: termLabels[id]!,
                        checked: state.signup.agreed.contains(id),
                        showDetail: id != 'age',
                        onTap: () => toggleTerm(id),
                        onDetail: id != 'age' ? () => _showTermModal(context, id) : null,
                      );
                    }),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _DarkNextBtn(label: '다음으로', enabled: reqDone,
              onTap: () => Navigator.pushNamed(context, '/signup-profile')),
          ],
        ),
      ),
    );
  }

  void _showTermModal(BuildContext context, String id) {
    final content = {
      'service':   {'title': '서비스 이용약관',         'body': '제1조 (목적)\n이 약관은 MOINCAR 모빌리티 플랫폼 서비스 이용에 관한 권리·의무를 규정합니다.\n\n제2조 (서비스 내용)\n자동차 관련 점포 검색, 중고차 정보 조회, 정비 견적 요청, 쿠폰 발급 등의 기능을 제공합니다.'},
      'privacy':   {'title': '개인정보 수집 및 이용',   'body': '수집 항목: 이름, 차량번호(선택), 위치 정보\n\n수집 목적: 회원 식별, 서비스 제공\n\n보유 기간: 회원 탈퇴 시까지'},
      'location':  {'title': '위치기반 서비스 이용약관', 'body': '위치기반서비스는 이용자의 현재 위치를 기반으로 주변 자동차 관련 점포를 검색하고 거리 정보를 제공합니다.'},
      'marketing': {'title': '마케팅 정보 수신 동의',   'body': '수신 내용: 신규 서비스 안내, 이벤트·프로모션, 쿠폰 발급 알림, 점포 추천 정보\n\n수신 채널: 앱 푸시 알림'},
    };
    final item = content[id];
    if (item == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: _s1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: _br, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text(item['title']!, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _t1)),
            const SizedBox(height: 16),
            Text(item['body']!, style: TextStyle(fontSize: 13, color: _t2, height: 1.6)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('확인', style: TextStyle(color: _bg, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DarkTermItem extends StatelessWidget {
  final String id, label;
  final bool checked, showDetail;
  final VoidCallback onTap;
  final VoidCallback? onDetail;

  const _DarkTermItem({
    required this.id, required this.label, required this.checked,
    required this.showDetail, required this.onTap, this.onDetail,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            _DarkCheckBox(checked: checked),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: TextStyle(fontSize: 14, color: _t1)),
            ),
            if (showDetail)
              GestureDetector(
                onTap: onDetail,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: _br),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('보기', style: TextStyle(fontSize: 11, color: _t3)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DarkCheckBox extends StatelessWidget {
  final bool checked;
  const _DarkCheckBox({required this.checked});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22, height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: checked ? _accent : _s2,
        border: Border.all(
          color: checked ? _accent : _br,
          width: 1.5,
        ),
      ),
      child: checked
        ? Icon(Icons.check, size: 13, color: _bg)
        : null,
    );
  }
}

// ==================== STEP 2: 프로필 ====================
class SignupProfileScreen extends StatefulWidget {
  const SignupProfileScreen({super.key});
  @override
  State<SignupProfileScreen> createState() => _SignupProfileScreenState();
}

class _SignupProfileScreenState extends State<SignupProfileScreen> {
  final state = AppState();
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: state.signup.name);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _DarkNav(title: '프로필 설정', onBack: () => Navigator.pop(context)),
            SignupProgress(step: 2),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('닉네임을\n입력해 주세요',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _t1),
                    ),
                    const SizedBox(height: 8),
                    Text('MOINCAR에서 사용할 이름을 알려주세요. 나중에 변경 가능합니다.',
                      style: TextStyle(fontSize: 13, color: _t2),
                    ),
                    const SizedBox(height: 28),

                    Text('닉네임 *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _t1)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _ctrl,
                      onChanged: (v) => state.signup.name = v,
                      maxLength: 10,
                      style: TextStyle(color: _t1),
                      decoration: InputDecoration(
                        hintText: '닉네임을 입력해 주세요',
                        hintStyle: TextStyle(color: _t3, fontSize: 14),
                        counterText: '',
                        filled: true,
                        fillColor: _s1,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: _br),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: _br),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: _accent, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('한글/영문 2~10자 이내', style: TextStyle(fontSize: 11, color: _t3)),
                    const SizedBox(height: 24),

                    // 안내 박스
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _s1,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _br),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('💡', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                style: TextStyle(fontSize: 12, color: _t2, height: 1.6),
                                children: [
                                  TextSpan(text: '모든 가입자는 일반 이용자로 시작합니다.\n',
                                    style: TextStyle(fontWeight: FontWeight.w600, color: _t1)),
                                  const TextSpan(text: '점포가 있다면 가입 후 홈 화면에서 '),
                                  TextSpan(text: '점포 등록',
                                    style: TextStyle(fontWeight: FontWeight.w600, color: _accent)),
                                  const TextSpan(text: '을 진행하세요.\n차량 번호는 '),
                                  TextSpan(text: '마이페이지',
                                    style: TextStyle(fontWeight: FontWeight.w600, color: _accent)),
                                  const TextSpan(text: '에서 언제든 등록 가능합니다.'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _DarkNextBtn(label: '다음으로', enabled: true, onTap: () {
              final name = _ctrl.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: const Text('닉네임을 입력해 주세요.'),
                    backgroundColor: _s2));
                return;
              }
              state.signup.name = name;
              Navigator.pushNamed(context, '/signup-interest');
            }),
          ],
        ),
      ),
    );
  }
}

// ==================== STEP 3: 관심분야 ====================
class SignupInterestScreen extends StatefulWidget {
  const SignupInterestScreen({super.key});
  @override
  State<SignupInterestScreen> createState() => _SignupInterestScreenState();
}

class _SignupInterestScreenState extends State<SignupInterestScreen> {
  final state = AppState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _DarkNav(title: '관심 분야 선택', onBack: () => Navigator.pop(context)),
            SignupProgress(step: 3),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('관심 있는 분야를\n선택하세요',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _t1),
                    ),
                    const SizedBox(height: 8),
                    Text('맞춤 뉴스 큐레이션에 활용됩니다. 최소 1개 이상 선택해 주세요.',
                      style: TextStyle(fontSize: 13, color: _t2),
                    ),
                    const SizedBox(height: 20),

                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.1,
                      children: AppData.interests.map((item) {
                        final isSelected = state.signup.interests.contains(item['id']);
                        return GestureDetector(
                          onTap: () => setState(() {
                            isSelected
                              ? state.signup.interests.remove(item['id'])
                              : state.signup.interests.add(item['id']!);
                          }),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? _accent.withOpacity(0.15) : _s1,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? _accent : _br,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(item['icon']!, style: const TextStyle(fontSize: 22)),
                                const SizedBox(height: 6),
                                Text(item['label']!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    color: isSelected ? _accent : _t2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        state.signup.interests.isEmpty
                          ? '최소 1개를 선택해 주세요'
                          : '${state.signup.interests.length}개 선택됨',
                        style: TextStyle(
                          fontSize: 13,
                          color: state.signup.interests.isEmpty ? _t3 : _accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _DarkNextBtn(label: '가입 완료', enabled: state.signup.interests.isNotEmpty,
              onTap: () {
                state.setLoggedIn(UserModel(
                  name: state.signup.name.isEmpty ? '이용자' : state.signup.name,
                  interests: state.signup.interests,
                ));
                Navigator.pushNamedAndRemoveUntil(context, '/signup-done', (_) => false);
              }),
          ],
        ),
      ),
    );
  }
}

// ==================== 가입 완료 ====================
class SignupDoneScreen extends StatefulWidget {
  const SignupDoneScreen({super.key});
  @override
  State<SignupDoneScreen> createState() => _SignupDoneScreenState();
}

class _SignupDoneScreenState extends State<SignupDoneScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _showOwnerPopup(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState();
    final user  = state.user;
    final interestLabels = (user?.interests ?? [])
      .map((id) => AppData.interests
        .firstWhere((i) => i['id'] == id, orElse: () => {'label': id})['label']!)
      .toList();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_bg, _s1, Color(0xFF0A1A2A)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 성공 아이콘
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _accent, width: 2),
                    color: _accent.withOpacity(0.15),
                  ),
                  child: Icon(Icons.check, size: 36, color: _accent),
                ),
                const SizedBox(height: 24),
                Text('가입 완료!',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: _t1),
                ),
                const SizedBox(height: 8),
                Text('${user?.name ?? ''}님, 환영합니다 🎉',
                  style: TextStyle(fontSize: 16, color: _t2),
                ),
                const SizedBox(height: 8),
                Text('MOINCAR 모빌리티 플랫폼 회원이 되셨습니다.\n내 주변 자동차 서비스를 바로 이용해 보세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: _t3, height: 1.6),
                ),
                const SizedBox(height: 32),

                // 요약 카드
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _s1,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _br),
                  ),
                  child: Column(
                    children: [
                      _DoneRow(icon: '📍', label: '위치', value: 'GPS 자동 감지'),
                      const SizedBox(height: 12),
                      _DoneRow(
                        icon: '⭐',
                        label: '관심 분야',
                        value: interestLabels.length <= 2
                          ? interestLabels.join(', ')
                          : '${interestLabels.take(2).join(', ')} 외 ${interestLabels.length - 2}개',
                      ),
                      const SizedBox(height: 12),
                      _DoneRow(icon: '👤', label: '회원 유형', value: '일반 이용자'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () =>
                      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: Text('MOINCAR 시작하기 →',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _bg),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DoneRow extends StatelessWidget {
  final String icon, label, value;
  const _DoneRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(fontSize: 13, color: _t3)),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 13, color: _t1, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ==================== 점주여부 팝업 ====================
void _showOwnerPopup(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.65),
    builder: (ctx) => Dialog(
      backgroundColor: _s1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _accent.withOpacity(0.15),
                border: Border.all(color: _accent.withOpacity(0.4), width: 1.5),
              ),
              child: const Center(child: Text('🏪', style: TextStyle(fontSize: 28))),
            ),
            const SizedBox(height: 16),
            Text('점포를 운영 중이신가요?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _t1),
            ),
            const SizedBox(height: 8),
            Text('자동차 관련 사업자라면\n무료 AI 점포 페이지를 만들어 드려요!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: _t2, height: 1.5),
            ),
            const SizedBox(height: 28),
            // 점포 등록 (위, 강조)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, '/store-register');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('네, 점포 등록하기',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _bg)),
                    const SizedBox(width: 6),
                    Icon(Icons.arrow_forward, size: 16, color: _bg),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            // 나중에 (아래, 약하게)
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: _br),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('아니요, 나중에', style: TextStyle(fontSize: 14, color: _t3)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ==================== 공통 다크 위젯 ====================
class _DarkNav extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  const _DarkNav({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bg,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: _s1,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _br),
              ),
              child: Icon(Icons.arrow_back_ios_new, size: 15, color: _t2),
            ),
          ),
          Expanded(
            child: Text(title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _t1),
            ),
          ),
          const SizedBox(width: 36),
        ],
      ),
    );
  }
}

class _DarkNextBtn extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  const _DarkNextBtn({required this.label, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bg,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: enabled ? onTap : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: enabled ? _accent : _s2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: enabled ? _bg : _t3,
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.arrow_forward, size: 16, color: enabled ? _bg : _t3),
            ],
          ),
        ),
      ),
    );
  }
}
