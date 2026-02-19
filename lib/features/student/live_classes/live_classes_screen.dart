import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/premium_button.dart';

/// Live classes screen with upcoming sessions
class LiveClassesScreen extends StatelessWidget {
  const LiveClassesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Active session banner
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEF4444), Color(0xFFF97316)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text('LIVE NOW',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('Flutter State Management',
                  style: AppTextStyles.headlineMedium
                      .copyWith(color: Colors.white)),
              const SizedBox(height: 4),
              Text('Sarah Teacher • Started 15 min ago',
                  style:
                      AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
              const SizedBox(height: 16),
              PremiumButton(
                label: 'Join Session',
                onPressed: () {},
                icon: Icons.videocam,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Upcoming
        Text('Upcoming Sessions', style: AppTextStyles.headlineSmall),
        const SizedBox(height: 12),

        _LiveClassCard(
          title: 'Color Theory Workshop',
          instructor: 'Sarah Teacher',
          time: 'Tomorrow, 2:00 PM',
          duration: '1 hour',
        ),
        _LiveClassCard(
          title: 'Advanced Widget Patterns',
          instructor: 'Sarah Teacher',
          time: 'Wed, 10:00 AM',
          duration: '1.5 hours',
        ),
        _LiveClassCard(
          title: 'Responsive Design Lab',
          instructor: 'Sarah Teacher',
          time: 'Fri, 3:00 PM',
          duration: '1 hour',
        ),
      ],
    );
  }
}

class _LiveClassCard extends StatelessWidget {
  final String title;
  final String instructor;
  final String time;
  final String duration;

  const _LiveClassCard({
    required this.title,
    required this.instructor,
    required this.time,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.videocam_outlined,
                  color: AppColors.secondary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.titleLarge),
                  const SizedBox(height: 4),
                  Text('$instructor • $duration',
                      style: AppTextStyles.bodySmall.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5))),
                  const SizedBox(height: 2),
                  Text(time,
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.primary)),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_active_outlined, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
