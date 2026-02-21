import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/entrance_animation.dart';
import '../../../core/services/haptic_service.dart';

class StreakDetailsScreen extends StatelessWidget {
  const StreakDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStreakSummary(context),
                  const SizedBox(height: 32),
                  _buildRewardCard(context),
                  const SizedBox(height: 32),
                  _buildTaskSection(context),
                  const SizedBox(height: 32),
                  _buildInfoSection(context),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      backgroundColor: Colors.white.withOpacity(0.8),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A)),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: FlexibleSpaceBar(
            title: Text(
              'Seriya Yolçuluğu',
              style: AppTextStyles.headlineSmall.copyWith(
                color: const Color(0xFF0F172A),
                fontWeight: FontWeight.w900,
                fontSize: 24,
              ),
            ),
            centerTitle: false,
            titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
            background: Container(color: Colors.transparent),
          ),
        ),
      ),
    );
  }

  Widget _buildStreakSummary(BuildContext context) {
    return EntranceAnimation(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '7 günlük seriya!',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: const Color(0xFF0F172A),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Siz hal-hazırda alovlanırsınız! 🔥',
                    style: AppTextStyles.bodySmall.copyWith(color: const Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardCard(BuildContext context) {
    return EntranceAnimation(
      delay: const Duration(milliseconds: 100),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2563EB).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.stars_rounded, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              'Böyük Mükafat!',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '2 AZN Balans',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 32),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '7 günlük seriyanı tamamla və qazan',
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskSection(BuildContext context) {
    final tasks = [
      {'title': '7 gün ardıcıl daxil olmaq', 'subtitle': 'Hər gün tətbiqi aç və öyrən', 'icon': Icons.login_rounded, 'done': true},
      {'title': 'Bütün tapşırıqları bitirmək', 'subtitle': 'Həmin həftənin tapşırıqları', 'icon': Icons.assignment_turned_in_rounded, 'done': false},
      {'title': 'Canlı dərslərdə iştirak', 'subtitle': 'Ən azı 2 canlı dərsə qatıl', 'icon': Icons.videocam_rounded, 'done': false},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Həftəlik Tapşırıqlar',
          style: AppTextStyles.headlineSmall.copyWith(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.w900, 
            letterSpacing: -0.5
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(tasks.length, (index) {
          final task = tasks[index];
          return EntranceAnimation(
            delay: Duration(milliseconds: 200 + (index * 100)),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (task['done'] as bool) ? Colors.green.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      task['icon'] as IconData,
                      color: (task['done'] as bool) ? Colors.green : AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task['title'] as String,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.w800, 
                            fontSize: 16
                          ),
                        ),
                        Text(
                          task['subtitle'] as String,
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  if (task['done'] as bool)
                    const Icon(Icons.check_circle_rounded, color: Colors.green)
                  else
                    const Icon(Icons.radio_button_unchecked_rounded, color: Colors.grey),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9), // Slate-100
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Cashback balansınıza 7-ci günün sonunda avtomatik əlavə olunacaq.',
              style: const TextStyle(
                color: Color(0xFF475569), // Slate-600
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: const Color(0xFFE2E8F0))),
      ),
      child: ElevatedButton(
        onPressed: null, // Disabled until complete
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: Colors.grey.withOpacity(0.2),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        child: const Text(
          'Mükafatı Tələb Et',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
      ),
    );
  }
}
