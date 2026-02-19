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
          Text('Yeni İmtahan', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 24),

          Text('Başlıq', style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          const TextField(
            decoration: InputDecoration(hintText: 'İmtahan başlığı'),
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

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Müddət (dəq)', style: AppTextStyles.labelLarge),
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
                    Text('Suallar', style: AppTextStyles.labelLarge),
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

          Text('Təlimatlar', style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          const TextField(
            maxLines: 3,
            decoration: InputDecoration(hintText: 'İmtahan təlimatları...'),
          ),
          const SizedBox(height: 32),

          PremiumButton(
            label: 'İmtahan yarat',
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
