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
          Text('Yeni Tapşırıq', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 24),

          Text('Başlıq', style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          const TextField(
            decoration: InputDecoration(hintText: 'Tapşırıq başlığı'),
          ),
          const SizedBox(height: 20),

          Text('Kurs', style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(hintText: 'Kurs seçin'),
            items: const [
              DropdownMenuItem(value: 'flutter', child: Text('Flutter Proqramlaşdırma')),
              DropdownMenuItem(value: 'design', child: Text('UI/UX Dizayn')),
              DropdownMenuItem(value: 'algo', child: Text('Məlumat Strukturları')),
            ],
            onChanged: (_) {},
          ),
          const SizedBox(height: 20),

          Text('Təsvir', style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          const TextField(
            maxLines: 4,
            decoration: InputDecoration(hintText: 'Tapşırığı təsvir edin...'),
          ),
          const SizedBox(height: 20),

          Text('Son tarix', style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          TextField(
            readOnly: true,
            decoration: InputDecoration(
              hintText: 'Tarix seçin',
              suffixIcon: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () {},
              ),
            ),
          ),
          const SizedBox(height: 32),

          PremiumButton(
            label: 'Tapşırıq yarat',
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
