import 'package:flutter/material.dart';
import 'package:loadsense/providers/navigation_provider.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'core/constants.dart';
import 'core/app_routes.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/module_provider.dart';
import 'providers/deadline_provider.dart';
import 'providers/workload_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/insight_provider.dart';
import 'providers/reminder_provider.dart';
import 'providers/feedback_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ModuleProvider()),
        ChangeNotifierProvider(create: (_) => DeadlineProvider()),
        ChangeNotifierProvider(create: (_) => WorkloadProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => InsightProvider()),
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
        ChangeNotifierProvider(create: (_) => FeedbackProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: const LoadSenseApp(),
    ),
  );
}

class LoadSenseApp extends StatelessWidget {
  const LoadSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      routes: AppRouter.routes,
      // home: MainNavScreen(),
    );
  }
}
