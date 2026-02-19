import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/stat_card.dart';

/// Teacher analytics screen
class TeacherAnalyticsScreen extends StatelessWidget {
  const TeacherAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Stats
        Row(
          children: const [
            Expanded(
              child: StatCard(
                title: 'Avg. Rating',
                value: '4.7',
                icon: Icons.star,
                color: AppColors.accent,
                trend: 2.1,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Completion Rate',
                value: '78%',
                icon: Icons.check_circle,
                color: AppColors.success,
                trend: 5.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: const [
            Expanded(
              child: StatCard(
                title: 'Active Students',
                value: '312',
                icon: Icons.people,
                color: AppColors.secondary,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'This Week Views',
                value: '1.8K',
                icon: Icons.visibility,
                color: AppColors.info,
                trend: 15.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Chart
        Text('Student Engagement', style: AppTextStyles.headlineSmall),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 100,
              barTouchData: BarTouchData(enabled: true),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          days[value.toInt() % 7],
                          style: AppTextStyles.labelSmall,
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
              barGroups: [
                _makeGroup(0, 65),
                _makeGroup(1, 78),
                _makeGroup(2, 52),
                _makeGroup(3, 89),
                _makeGroup(4, 71),
                _makeGroup(5, 40),
                _makeGroup(6, 35),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Recent submissions
        Text('Recent Submissions', style: AppTextStyles.headlineSmall),
        const SizedBox(height: 12),
        ..._buildRecentSubmissions(),
      ],
    );
  }

  BarChartGroupData _makeGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: AppColors.primary,
          width: 18,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ],
    );
  }

  List<Widget> _buildRecentSubmissions() {
    final submissions = [
      {'student': 'Alice', 'assignment': 'Todo App', 'time': '2 hours ago'},
      {'student': 'Bob', 'assignment': 'Design System', 'time': '5 hours ago'},
      {'student': 'Carol', 'assignment': 'Todo App', 'time': 'Yesterday'},
    ];

    return submissions
        .map((s) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    s['student']![0],
                    style: const TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                ),
                title: Text(s['student']!, style: AppTextStyles.titleMedium),
                subtitle: Text(s['assignment']!),
                trailing: Text(s['time']!, style: AppTextStyles.labelSmall),
              ),
            ))
        .toList();
  }
}
