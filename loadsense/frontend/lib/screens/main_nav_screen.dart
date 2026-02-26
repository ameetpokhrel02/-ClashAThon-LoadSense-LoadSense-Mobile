import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import 'dashboard/dashboard_screen.dart';
import 'calendar/calendar_screen.dart';
import 'deadlines/deadlines_screen.dart';
import 'modules/modules_screen.dart';
import 'profile/profile_screen.dart';
import '../providers/navigation_provider.dart';

class MainNavScreen extends StatelessWidget {
  const MainNavScreen({super.key});

  final List<Widget> _screens = const [
    DashboardScreen(showBackButton: false),
    CalendarScreen(showBackButton: false),
    DeadlinesScreen(showBackButton: false),
    ModulesScreen(showBackButton: false),
    ProfileScreen(showBackButton: false),
  ];

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<NavigationProvider>();

    return Scaffold(
      body: IndexedStack(
        index: navProvider.selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navProvider.selectedIndex,
        onTap: (index) => navProvider.setIndex(index),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            activeIcon: Icon(Icons.grid_view_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month_rounded),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer_outlined),
            activeIcon: Icon(Icons.timer_rounded),
            label: 'Deadlines',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book_rounded),
            label: 'Modules',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
