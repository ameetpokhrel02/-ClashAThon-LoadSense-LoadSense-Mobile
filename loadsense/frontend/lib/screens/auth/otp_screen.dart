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
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final email = ModalRoute.of(context)!.settings.arguments as String;
    if (_formKey.currentState!.validate()) {
      final success = await context.read<AuthProvider>().verifyOtp(email, _otpController.text.trim());
      if (success && mounted) {
        CustomSnackBar.show(context, 'OTP Verified');
        Navigator.pushNamed(context, AppRoutes.resetPassword, arguments: {
          'email': email,
          'otp': _otpController.text.trim(),
        });
      } else if (mounted) {
        CustomSnackBar.show(context, context.read<AuthProvider>().error ?? 'Verification failed', isError: true);
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
            top: -20,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.04),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            right: -60,
            child: Container(
              width: 150,
              height: 150,
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
                            'Verify OTP',
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'We sent a 6-digit code to your email.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 32),
                          AppTextField(
                            controller: _otpController,
                            label: 'Access Code',
                            hint: '••••••',
                            prefixIcon: Icons.fingerprint_rounded,
                            keyboardType: TextInputType.number,
                            validator: (v) => v != null && v.length == 6 ? null : '6-digit code matches',
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: AppButton(
                              label: 'Verify Code',
                              onPressed: _verify,
                              isLoading: auth.isLoading,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.1),

                  const SizedBox(height: 32),

                  Center(
                    child: TextButton(
                      onPressed: () {
                        final email = ModalRoute.of(context)!.settings.arguments as String;
                        context.read<AuthProvider>().forgotPassword(email);
                      },
                      child: const Text(
                        'Resend Secure Code',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ).animate().fadeIn(delay: 600.ms),
                  
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
