import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Hero illustration
              Container(
                width: double.infinity,
                height: 320,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: AppColors.border),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/hero_illustration.png',
                    height: 240,
                  ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.8, 0.8)),
                ),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),
              const SizedBox(height: 40),
              Text(
                'Manage Your\nAcademic Load',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      height: 1.1,
                      letterSpacing: -0.5,
                    ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
              const SizedBox(height: 16),
              Text(
                'Track your courses, deadlines, and workload. Get AI-powered insights to study smarter, not harder.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
              const SizedBox(height: 40),
              // Feature rows
              ..._features.map((f) => _FeatureRow(icon: f.$1, label: f.$2, color: f.$3))
                  .map((w) => Padding(padding: const EdgeInsets.only(bottom: 16), child: w)),
              const SizedBox(height: 40),
              // CTA Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
                  child: const Text('Get Started Free'),
                ),
              ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                  child: const Text('Sign In'),
                ),
              ).animate().fadeIn(delay: 700.ms, duration: 400.ms),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  static const _features = [
    (Icons.auto_graph_rounded, 'Track weekly workload automatically', AppColors.primary),
    (Icons.alarm_rounded, 'Never miss a deadline', AppColors.secondary),
    (Icons.psychology_rounded, 'Get AI-powered study plans', AppColors.success),
  ];
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _FeatureRow({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

