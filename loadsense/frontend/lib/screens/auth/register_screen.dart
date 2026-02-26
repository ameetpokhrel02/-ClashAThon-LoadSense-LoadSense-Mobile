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
import '../../providers/navigation_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        CustomSnackBar.show(context, 'Passwords do not match', isError: true);
        return;
      }

      final success = await context.read<AuthProvider>().register(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      if (success && mounted) {
        context.read<NavigationProvider>().setIndex(0);
        Navigator.pushReplacementNamed(context, AppRoutes.main);
      } else if (mounted) {
        CustomSnackBar.show(context,
            context.read<AuthProvider>().error ?? 'Registration failed',
            isError: true);
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
            top: -50,
            left: -100,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.04),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -80,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.03),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Background 3D Illustration - Large & Subtle
          Positioned(
            top: 60,
            left: -100,
            right: -100,
            child: Opacity(
              opacity: 0.08,
              child: Transform.rotate(
                angle: -0.1,
                child: Image.asset(
                  'assets/images/auth_hero.png',
                  height: 400,
                  fit: BoxFit.contain,
                ),
              ),
            ).animate().fadeIn(duration: 1200.ms).slideY(begin: 0.1),
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

                  // Illustration Container
                  Container(
                    height: 160,
                    width: 160,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/auth_hero.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 200.ms)
                      .scale(begin: const Offset(0.9, 0.9)),

                  const SizedBox(height: 40),

                  // Registration Card
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
                            'Create Account',
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium
                                ?.copyWith(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  controller: _firstNameController,
                                  label: 'First Name',
                                  prefixIcon: Icons.person_outline_rounded,
                                  validator: (v) => v != null && v.isNotEmpty
                                      ? null
                                      : 'Required',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: AppTextField(
                                  controller: _lastNameController,
                                  label: 'Last Name',
                                  validator: (v) => v != null && v.isNotEmpty
                                      ? null
                                      : 'Required',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            controller: _emailController,
                            label: 'Institutional Email',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => v != null && v.contains('@')
                                ? null
                                : 'Valid email required',
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            controller: _passwordController,
                            label: 'Secure Password',
                            prefixIcon: Icons.lock_outline_rounded,
                            isPassword: true,
                            validator: (v) => v != null && v.length >= 6
                                ? null
                                : '6+ characters',
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            controller: _confirmPasswordController,
                            label: 'Confirm Access',
                            prefixIcon: Icons.verified_user_outlined,
                            isPassword: true,
                            textInputAction: TextInputAction.done,
                            onEditingComplete: _register,
                            validator: (v) =>
                                v != null && v.isNotEmpty ? null : 'Confirm it',
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: AppButton(
                              label: 'Create Account',
                              onPressed: _register,
                              isLoading: auth.isLoading,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 600.ms)
                      .slideY(begin: 0.1),

                  const SizedBox(height: 32),

                  // Bottom Links
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Been here already?',
                          style: TextStyle(color: AppColors.textSecondary)),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.login),
                        child: const Text('Back to Login',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ).animate().fadeIn(delay: 600.ms),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
