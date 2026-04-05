import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ==================== KAA 로고 ====================
class KaaLogo extends StatelessWidget {
  final double size;
  final bool dark;
  const KaaLogo({super.key, this.size = 22, this.dark = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('K',
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w900,
            color: dark ? Colors.white : AppColors.primary,
            letterSpacing: -0.5,
          ),
        ),
        Text('AA',
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w700,
            color: dark ? Colors.white.withOpacity(0.85) : AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

// ==================== 앱 헤더 ====================
class AppHeader extends StatelessWidget {
  final bool showBack;
  final bool showSearch;
  final String? title;
  final VoidCallback? onBack;
  final VoidCallback? onNotification;
  final int notifCount;

  const AppHeader({
    super.key,
    this.showBack = false,
    this.showSearch = false,
    this.title,
    this.onBack,
    this.onNotification,
    this.notifCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          // Left
          SizedBox(
            width: 40,
            child: showBack
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textPrimary),
                  onPressed: onBack ?? () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                )
              : GestureDetector(
                  onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false),
                  child: const KaaLogo(),
                ),
          ),

          // Center
          Expanded(
            child: showSearch
              ? GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: 36,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.bgGray,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search, size: 16, color: AppColors.textMuted),
                        SizedBox(width: 6),
                        Text('점포, 서비스 검색',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : title != null
                ? Text(title!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // Right
          SizedBox(
            width: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, size: 22, color: AppColors.textPrimary),
                  onPressed: onNotification ?? () => Navigator.pushNamed(context, '/notification'),
                  padding: EdgeInsets.zero,
                ),
                if (notifCount > 0)
                  Positioned(
                    top: 6,
                    right: 4,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: AppColors.danger,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text('$notifCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 하단 네비게이션 ====================
class AppBottomNav extends StatelessWidget {
  final String currentTab;
  final Function(String) onTab;

  const AppBottomNav({super.key, required this.currentTab, required this.onTab});

  @override
  Widget build(BuildContext context) {
    final tabs = [
      {'id': 'home', 'label': '홈', 'icon': Icons.home_outlined, 'activeIcon': Icons.home},
      {'id': 'coupon', 'label': '쿠폰', 'icon': Icons.confirmation_number_outlined, 'activeIcon': Icons.confirmation_number},
      {'id': 'cert', 'label': '협회인증', 'icon': Icons.verified_outlined, 'activeIcon': Icons.verified},
      {'id': 'used-car', 'label': '중고차', 'icon': Icons.directions_car_outlined, 'activeIcon': Icons.directions_car},
      {'id': 'my', 'label': '마이', 'icon': Icons.person_outline, 'activeIcon': Icons.person},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: tabs.map((tab) {
              final isActive = currentTab == tab['id'];
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTab(tab['id'] as String),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isActive ? tab['activeIcon'] as IconData : tab['icon'] as IconData,
                        size: 22,
                        color: isActive ? AppColors.primary : AppColors.textMuted,
                      ),
                      const SizedBox(height: 2),
                      Text(tab['label'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          color: isActive ? AppColors.primary : AppColors.textMuted,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
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

// ==================== 점포 카드 (소) ====================
class StoreCardSmall extends StatelessWidget {
  final dynamic store;
  final VoidCallback? onTap;

  const StoreCardSmall({super.key, required this.store, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 이미지
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
              child: Image.network(
                store.image,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 90,
                  height: 90,
                  color: AppColors.bgGray,
                  child: const Icon(Icons.store, color: AppColors.textMuted),
                ),
              ),
            ),
            // 내용
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: store.type == 'certified' ? AppColors.badgeCert : AppColors.badgeNormal,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(store.badge,
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const Spacer(),
                        Text(store.distance,
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(store.name,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Text('⭐ ', style: TextStyle(fontSize: 11)),
                        Text('${store.rating}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      children: store.tags.take(2).map<Widget>((tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.bgGray,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(tag,
                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                        ),
                      )).toList(),
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
}

// ==================== 섹션 헤더 ====================
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (subtitle != null)
                Text(subtitle!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
            ],
          ),
          const Spacer(),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Text(actionLabel!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
