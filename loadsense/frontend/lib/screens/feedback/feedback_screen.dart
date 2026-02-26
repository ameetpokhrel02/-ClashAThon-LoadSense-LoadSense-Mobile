import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/feedback_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/custom_snackbar.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _commentController = TextEditingController();
  int _rating = 0;

  Future<void> _submit() async {
    if (_rating == 0) {
      CustomSnackBar.show(context, 'Please select a rating', isError: true);
      return;
    }

    final success = await context.read<FeedbackProvider>().submitFeedback(
          _rating,
          _commentController.text.trim(),
        );

    if (success && mounted) {
      CustomSnackBar.show(context, 'Thank you for your feedback!');
      Navigator.pop(context);
    } else if (mounted) {
      CustomSnackBar.show(
        context,
        context.read<FeedbackProvider>().error ?? 'Submission failed',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feedback')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            const Icon(Icons.rate_review_outlined, size: 80.0, color: AppColors.primary),
            const SizedBox(height: 24),
            Text('Rate your experience', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            const Text(
              'How is LoadSense helping you manage your academic workload?',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  iconSize: 48.0,
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: index < _rating ? Colors.amber : AppColors.textDisabled,
                  ),
                  onPressed: () => setState(() => _rating = index + 1),
                );
              }),
            ),
            const SizedBox(height: 32),
            AppTextField(
              controller: _commentController,
              label: 'Your Comments (Optional)',
              hint: 'What can we improve?',
              maxLines: 4,
            ),
            const SizedBox(height: 40),
            AppButton(
              label: 'Submit Feedback',
              onPressed: _submit,
              isLoading: context.watch<FeedbackProvider>().isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
