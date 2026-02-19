import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/stat_card.dart';

/// Admin overview dashboard
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Platform stats
        Row(
          children: const [
            Expanded(
              child: StatCard(
                title: 'Ümumi istifadəçilər',
                value: '12.4K',
                icon: Icons.people,
                color: AppColors.primary,
                trend: 8.5,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Gəlir',
                value: '₼84.2K',
                icon: Icons.payments,
                color: AppColors.success,
                trend: 12.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: const [
            Expanded(
              child: StatCard(
                title: 'Kurslar',
                value: '156',
                icon: Icons.menu_book,
                color: AppColors.secondary,
                trend: 4.2,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Hazırda aktiv',
                value: '328',
                icon: Icons.circle,
                color: AppColors.info,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Enrollment chart
        Text('Aylıq Qeydiyyatlar', style: AppTextStyles.headlineSmall),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const months = ['Yan', 'Fev', 'Mar', 'Apr', 'May', 'İyun'];
                      if (value.toInt() >= 0 && value.toInt() < months.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(months[value.toInt()],
                              style: AppTextStyles.labelSmall),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                leftTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: const [
                    FlSpot(0, 45),
                    FlSpot(1, 62),
                    FlSpot(2, 58),
                    FlSpot(3, 78),
                    FlSpot(4, 89),
                    FlSpot(5, 95),
                  ],
                  isCurved: true,
                  color: AppColors.primary,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.primary.withValues(alpha: 0.1),
                  ),
                  dotData: const FlDotData(show: false),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Recent activity
        Text('Son Fəaliyyətlər', style: AppTextStyles.headlineSmall),
        const SizedBox(height: 12),
        _ActivityItem(
          icon: Icons.person_add,
          color: AppColors.primary,
          title: 'Yeni müəllim qeydiyyatdan keçdi',
          subtitle: 'Murad Əliyev • 2 saat əvvəl',
        ),
        _ActivityItem(
          icon: Icons.menu_book,
          color: AppColors.secondary,
          title: 'Yeni kurs dərc olundu',
          subtitle: 'Flutter Masterklas • Bugün',
        ),
        _ActivityItem(
          icon: Icons.report,
          color: AppColors.warning,
          title: 'Məzmun şikayəti',
          subtitle: 'Tapşırıq #234 • 5 saat əvvəl',
        ),
        _ActivityItem(
          icon: Icons.payment,
          color: AppColors.success,
          title: 'Ödəniş qəbul edildi',
          subtitle: '₼49.99 • Premium Plan • Bugün',
        ),
      ],
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _ActivityItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title, style: AppTextStyles.titleMedium),
        subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
      ),
    );
  }
}
