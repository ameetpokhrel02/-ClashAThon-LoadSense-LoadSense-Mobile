import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/screen_header.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const ScreenHeader(
              title: 'About LoadSense',
              showBackButton: true,
              showNotification: false,
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 120, // Increased size from 80
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'LoadSense is an Academic Overload Detection System that helps students manage multiple deadlines efficiently. It provides a simple dashboard to visualize upcoming assignments, quizzes, and projects, highlights high workload periods, and sends overload alerts.',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'By planning ahead, students can reduce stress, avoid last-minute submissions, and improve the quality of their work. LoadSense also supports course management and gives insights into weekly workload patterns, helping students stay organized and in control of their academic schedule.',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.justify,
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
