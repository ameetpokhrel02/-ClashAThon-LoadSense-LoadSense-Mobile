import 'package:flutter/material.dart';
import 'constants.dart';
import '../models/module_model.dart';
import '../models/deadline_model.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/main_nav_screen.dart';
import '../screens/deadlines/add_deadline_screen.dart';
import '../screens/deadlines/edit_deadline_screen.dart';
import '../screens/deadlines/deadline_detail_screen.dart';
import '../screens/modules/add_module_screen.dart';
import '../screens/modules/edit_module_screen.dart';
import '../screens/modules/module_detail_screen.dart';
import '../screens/deadlines/deadlines_screen.dart';
import '../screens/modules/modules_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/about_screen.dart';
import '../screens/workload/workload_screen.dart';
import '../screens/insights/insights_screen.dart';
import '../screens/feedback/feedback_screen.dart';
import '../screens/reminders/reminders_screen.dart';

class AppRouter {
  static Map<String, WidgetBuilder> get routes => {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.onboarding: (context) => const OnboardingScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.register: (context) => const RegisterScreen(),
        AppRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),
        AppRoutes.otp: (context) => const OtpScreen(),
        AppRoutes.resetPassword: (context) => const ResetPasswordScreen(),
        AppRoutes.main: (context) => const MainNavScreen(),
        AppRoutes.addDeadline: (context) => const AddDeadlineScreen(),
        AppRoutes.editDeadline: (context) {
          final deadline = ModalRoute.of(context)!.settings.arguments as Deadline;
          return EditDeadlineScreen(deadline: deadline);
        },
        AppRoutes.deadlineDetail: (context) => const DeadlineDetailScreen(),
        AppRoutes.addModule: (context) => const AddModuleScreen(),
        AppRoutes.editModule: (context) {
          final module = ModalRoute.of(context)!.settings.arguments as Module;
          return EditModuleScreen(module: module);
        },
        AppRoutes.moduleDetail: (context) => const ModuleDetailScreen(),
        AppRoutes.editProfile: (context) => const EditProfileScreen(),
        AppRoutes.about: (context) => const AboutScreen(),
        AppRoutes.deadlines: (context) => const DeadlinesScreen(showBackButton: true),
        AppRoutes.modules: (context) => const ModulesScreen(),
        AppRoutes.workload: (context) => const WorkloadScreen(),
        AppRoutes.insights: (context) => const InsightsScreen(),
        AppRoutes.feedback: (context) => const FeedbackScreen(),
        AppRoutes.reminders: (context) => const RemindersScreen(),
      };
}
