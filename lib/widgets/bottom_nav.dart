import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ═══════════════════════════════════════════════════════════════
// MOINCAR Bottom Navigation Bar — 군청색 다크 테마 (v22.0.0)
// 스크롤 다운 시 숨김, 스크롤 업/정지 시 슬라이드 복귀
// ═══════════════════════════════════════════════════════════════
class BottomNav extends StatelessWidget {
  final String activeTab;
  const BottomNav({super.key, required this.activeTab});

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'icon': Icons.home_outlined,
        'activeIcon': Icons.home_rounded,
        'label': '홈',
        'tab': 'home',
        'route': '/home',
        'activeColor': const Color(0xFF4FC3F7),
      },
      {
        'icon': Icons.local_offer_outlined,
        'activeIcon': Icons.local_offer_rounded,
        'label': '쿠폰',
        'tab': 'coupon',
        'route': '/coupon',
        'activeColor': const Color(0xFFFF8C5A),
      },
      {
        'icon': Icons.verified_outlined,
        'activeIcon': Icons.verified_rounded,
        'label': '협회인증',
        'tab': 'cert',
        'route': '/cert',
        'activeColor': const Color(0xFF4CAF50),
      },
      {
        'icon': Icons.directions_car_outlined,
        'activeIcon': Icons.directions_car_rounded,
        'label': '중고차',
        'tab': 'usedcar',
        'route': '/usedcar',
        'activeColor': const Color(0xFF4FC3F7),
      },
      {
        'icon': Icons.person_outline_rounded,
        'activeIcon': Icons.person_rounded,
        'label': '마이',
        'tab': 'my',
        'route': '/my',
        'activeColor': const Color(0xFF4FC3F7),
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF030C1C),
        border: const Border(
          top: BorderSide(color: Color(0xFF1A3050), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: items.map((item) {
              final isActive = activeTab == item['tab'];
              final activeColor = item['activeColor'] as Color;
              final color = isActive ? activeColor : const Color(0xFF3A6080);
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (!isActive) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        item['route'] as String,
                        (route) => false,
                      );
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 액티브일 때 인디케이터 도트
                      if (isActive)
                        Container(
                          width: 4, height: 4,
                          margin: const EdgeInsets.only(bottom: 2),
                          decoration: BoxDecoration(
                            color: activeColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: activeColor.withOpacity(0.6),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        )
                      else
                        const SizedBox(height: 6),
                      Icon(
                        isActive
                            ? item['activeIcon'] as IconData
                            : item['icon'] as IconData,
                        color: color,
                        size: 24,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['label'] as String,
                        style: GoogleFonts.notoSansKr(
                          fontSize: 10,
                          color: color,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ── 스크롤 숨김 가능한 BottomNav 래퍼 ────────────────────────────
// HomeScreen에서 ScrollController와 연동하여
// 스크롤 다운 → 숨김 / 스크롤 업 or 정지 → 슬라이드 복귀
class HideOnScrollBottomNav extends StatefulWidget {
  final String activeTab;
  final ScrollController scrollController;
  const HideOnScrollBottomNav({
    super.key,
    required this.activeTab,
    required this.scrollController,
  });
  @override
  State<HideOnScrollBottomNav> createState() => _HideOnScrollBottomNavState();
}

class _HideOnScrollBottomNavState extends State<HideOnScrollBottomNav>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<Offset> _slide;
  bool _visible = true;
  double _lastOffset = 0;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _slide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 1),
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeInOut));
    widget.scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final offset = widget.scrollController.offset;
    final diff = offset - _lastOffset;
    if (diff > 8 && _visible) {
      // 스크롤 다운 → 숨기기
      setState(() => _visible = false);
      _anim.forward();
    } else if (diff < -8 && !_visible) {
      // 스크롤 업 → 보이기
      setState(() => _visible = true);
      _anim.reverse();
    }
    _lastOffset = offset;
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: BottomNav(activeTab: widget.activeTab),
    );
  }
}
