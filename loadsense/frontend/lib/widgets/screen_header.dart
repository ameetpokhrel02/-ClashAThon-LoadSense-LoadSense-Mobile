import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../providers/reminder_provider.dart';
import '../providers/navigation_provider.dart';

class ScreenHeader extends StatelessWidget {
  final Widget? child;
  final String? title;
  final String? subtitle;
  final dynamic user;
  final bool showUserInfo;
  final bool showNotification;
  final Widget? action;
  final List<Widget>? stats;
  final bool? showBackButton;

  const ScreenHeader({
    super.key,
    this.child,
    this.title,
    this.subtitle,
    this.user,
    this.showUserInfo = false,
    this.showNotification = true,
    this.action,
    this.stats,
    this.showBackButton,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopRow(context),
          if (stats != null && stats!.isNotEmpty) ...[
            const SizedBox(height: 24),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.8,
              children: stats!,
            ),
          ],
          if (child != null) ...[
            const SizedBox(height: 20),
            child!,
          ],
        ],
      ),
    );
  }

  Widget _buildTopRow(BuildContext context) {
    final bool canPop = showBackButton ?? Navigator.canPop(context);

    if (showUserInfo) {
      return Row(
        children: [
          if (canPop) ...[
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 8),
          ],
          GestureDetector(
            onTap: () => context.read<NavigationProvider>().setIndex(4),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              backgroundImage: (user?.avatar != null && user!.avatar!.isNotEmpty) ? NetworkImage(user!.avatar!) : null,
              child: (user?.avatar == null || user!.avatar!.isEmpty)
                ? Text(user?.firstName.isNotEmpty == true ? user!.firstName[0] : 'U', style: const TextStyle(color: Colors.white))
                : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtitle ?? 'Welcome back,',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                Text(
                  title ?? '${user?.firstName ?? "User"} ${user?.lastName ?? ""}',
                  style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 18, 
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
          ),
          if (action != null) action!,
          if (showNotification) ...[
            if (action != null) const SizedBox(width: 8),
            _buildNotificationIcon(context),
          ],
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              if (canPop) ...[
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    Text(
                      title ?? '',
                      style: const TextStyle(
                        color: Colors.white, 
                        fontSize: 24, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (action != null) action!,
            if (showNotification) ...[
              if (action != null) const SizedBox(width: 8),
              _buildNotificationIcon(context),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildNotificationIcon(BuildContext context) {
    return Consumer<ReminderProvider>(
      builder: (context, provider, _) {
        final unreadCount = provider.reminders.where((r) => !r.isRead).length;

        return IconButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.reminders),
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 24),
              ),
              if (unreadCount > 0)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      unreadCount > 9 ? '9+' : '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class HeaderStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const HeaderStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
