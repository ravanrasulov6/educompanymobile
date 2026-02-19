import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/premium_button.dart';

/// Create exam screen
class CreateExamScreen extends StatelessWidget {
  const CreateExamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('New Exam', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 24),

          Text('Title', style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          const TextField(
            decoration: InputDecoration(hintText: 'Exam title'),
          ),
          const SizedBox(height: 20),

          Text('Course', style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(hintText: 'Select course'),
            items: const [
              DropdownMenuItem(value: 'flutter', child: Text('Flutter Development')),
              DropdownMenuItem(value: 'design', child: Text('UI/UX Design')),
              DropdownMenuItem(value: 'algo', child: Text('Data Structures')),
            ],
            onChanged: (_) {},
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Duration (min)', style: AppTextStyles.labelLarge),
                    const SizedBox(height: 8),
                    const TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(hintText: '30'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Questions', style: AppTextStyles.labelLarge),
                    const SizedBox(height: 8),
                    const TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(hintText: '20'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Text('Instructions', style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          const TextField(
            maxLines: 3,
            decoration: InputDecoration(hintText: 'Exam instructions...'),
          ),
          const SizedBox(height: 32),

          PremiumButton(
            label: 'Create Exam',
            onPressed: () {},
            isGradient: true,
            icon: Icons.check_circle,
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}
