import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/custom_snackbar.dart';

import '../../widgets/logo_widget.dart';
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _reset() async {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    final email = args['email']!;
    final otp = args['otp']!;

    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        CustomSnackBar.show(context, 'Passwords do not match', isError: true);
        return;
      }

      final success = await context.read<AuthProvider>().resetPassword(
            email,
            otp,
            _passwordController.text.trim(),
          );

      if (success && mounted) {
        CustomSnackBar.show(context, 'Password reset successful. Please login.');
        Navigator.popUntil(context, ModalRoute.withName(AppRoutes.login));
      } else if (mounted) {
        CustomSnackBar.show(context, context.read<AuthProvider>().error ?? 'Reset failed', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Background Organic Shapes
          Positioned(
            top: -40,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.04),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.03),
                shape: BoxShape.circle,
              ),
            ),
          ),


          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  // Logo
                  const AppLogo(size: 70)
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .scale(begin: const Offset(0.8, 0.8)),

                  const SizedBox(height: 40),


                  // Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reset Password',
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Establish a new secure password for your portal.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 32),
                          AppTextField(
                            controller: _passwordController,
                            label: 'New Credentials',
                            hint: 'Min 6 characters',
                            prefixIcon: Icons.lock_outline_rounded,
                            isPassword: true,
                            validator: (v) => v != null && v.length >= 6 ? null : 'Security requires 6+ chars',
                          ),
                          const SizedBox(height: 20),
                          AppTextField(
                            controller: _confirmPasswordController,
                            label: 'Confirm Credentials',
                            hint: 'Repeat password',
                            prefixIcon: Icons.verified_user_outlined,
                            isPassword: true,
                            textInputAction: TextInputAction.done,
                            onEditingComplete: _reset,
                            validator: (v) => v != null && v.isNotEmpty ? null : 'Confirmation required',
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: AppButton(
                              label: 'Reset Password',
                              onPressed: _reset,
                              isLoading: auth.isLoading,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.1),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 16, top: 8),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
