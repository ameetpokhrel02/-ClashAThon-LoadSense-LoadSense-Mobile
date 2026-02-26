class ApiConstants {

  static const String baseUrl = 'https://clashathon-loadsense-loadsense.onrender.com/api';

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resetPassword = '/auth/reset-password';
  static const String me = '/auth/me';

  // Users
  static const String profile = '/users/profile';

  // Modules
  static const String modules = '/modules';

  // Deadlines
  static const String deadlines = '/deadlines';

  // Workload
  static const String workloadCalculate = '/workload/calculate';
  static const String workload = '/workload';
  static const String workloadAlert = '/workload/alert';
  static const String workloadSummary = '/workload/summary';
  static const String workloadCalendarStats = '/workload/calendar-stats';

  // Dashboard
  static const String dashboardCalculate = '/dashboard/calculate';
  static const String dashboardAlert = '/dashboard/alert';
  static const String dashboardSummary = '/dashboard/summary';

  // Feedback
  static const String feedbackRatings = '/feedback-ratings';

  // AI
  static const String aiSuggestion = '/ai/suggestion';

  // Reminders
  static const String reminders = '/reminders';

  // Insights
  static const String insights = '/insights';
}

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String otp = '/otp';
  static const String resetPassword = '/reset-password';
  static const String main = '/main';
  static const String dashboard = '/dashboard';
  static const String calendar = '/calendar';
  static const String deadlines = '/deadlines';
  static const String addDeadline = '/deadlines/add';
  static const String modules = '/modules';
  static const String addModule = '/modules/add';
  static const String editModule = '/modules/edit';
  static const String moduleDetail = '/modules/detail';
  static const String workload = '/workload';
  static const String workloadAlert = '/workload/alert';
  static const String insights = '/insights';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String about = '/about';
  static const String feedback = '/feedback';
  static const String reminders = '/reminders';
  static const String deadlineDetail = '/deadlines/detail';
  static const String editDeadline = '/deadlines/edit';
}

class AppStrings {
  static const String appName = 'LoadSense';
  static const String tagline = 'Manage your academic workload smartly';
  static const String tokenKey = 'auth_token';
  static const String defaultError = 'Something went wrong. Please try again.';
}
