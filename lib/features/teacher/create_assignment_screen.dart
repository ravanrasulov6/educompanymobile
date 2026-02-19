import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/premium_button.dart';

/// Create assignment screen
class CreateAssignmentScreen extends StatelessWidget {
  const CreateAssignmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('New Assignment', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 24),

          Text('Title', style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          const TextField(
            decoration: InputDecoration(hintText: 'Assignment title'),
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

          Text('Description', style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          const TextField(
            maxLines: 4,
            decoration: InputDecoration(hintText: 'Describe the assignment...'),
          ),
          const SizedBox(height: 20),

          Text('Deadline', style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          TextField(
            readOnly: true,
            decoration: InputDecoration(
              hintText: 'Select deadline',
              suffixIcon: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () {},
              ),
            ),
          ),
          const SizedBox(height: 32),

          PremiumButton(
            label: 'Create Assignment',
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
