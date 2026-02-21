import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/stat_card.dart';

/// Dynamic teacher analytics screen — real Supabase data
class TeacherAnalyticsScreen extends StatefulWidget {
  const TeacherAnalyticsScreen({super.key});

  @override
  State<TeacherAnalyticsScreen> createState() => _TeacherAnalyticsScreenState();
}

class _TeacherAnalyticsScreenState extends State<TeacherAnalyticsScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;

  // Analytics data
  int _totalStudents = 0;
  int _totalCourses = 0;
  int _totalLessons = 0;
  int _totalQuestions = 0;
  int _pendingQuestions = 0;
  int _totalResources = 0;
  double _avgRating = 0.0;
  List<Map<String, dynamic>> _recentActivity = [];
  List<double> _weeklyData = [0, 0, 0, 0, 0, 0, 0];

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Get teacher's courses
      final courses = await _supabase
          .from('courses')
          .select('id, title, rating, students_count, status')
          .eq('instructor_id', userId);
      final courseList = courses as List;
      _totalCourses = courseList.length;

      // Calculate total students and average rating
      double ratingSum = 0;
      int ratingCount = 0;
      for (final c in courseList) {
        _totalStudents += (c['students_count'] as int? ?? 0);
        final r = (c['rating'] as num?)?.toDouble() ?? 0;
        if (r > 0) {
          ratingSum += r;
          ratingCount++;
        }
      }
      _avgRating = ratingCount > 0 ? ratingSum / ratingCount : 0;

      final courseIds = courseList.map((c) => c['id'] as String).toList();

      if (courseIds.isNotEmpty) {
        // Get total lessons
        final sections = await _supabase
            .from('course_sections')
            .select('id')
            .inFilter('course_id', courseIds);
        final sectionIds =
            (sections as List).map((s) => s['id'] as String).toList();

        if (sectionIds.isNotEmpty) {
          final lessons = await _supabase
              .from('lessons')
              .select('id')
              .inFilter('section_id', sectionIds);
          _totalLessons = (lessons as List).length;

          final lessonIds =
              (lessons).map((l) => l['id'] as String).toList();

          if (lessonIds.isNotEmpty) {
            // Get questions
            final questions = await _supabase
                .from('student_questions')
                .select('id, is_answered, created_at')
                .inFilter('lesson_id', lessonIds);
            final qList = questions as List;
            _totalQuestions = qList.length;
            _pendingQuestions =
                qList.where((q) => q['is_answered'] != true).length;

            // Weekly activity data (questions per day this week)
            final now = DateTime.now();
            for (final q in qList) {
              final created = DateTime.tryParse(q['created_at'] ?? '');
              if (created != null) {
                final dayDiff = now.difference(created).inDays;
                if (dayDiff < 7) {
                  _weeklyData[6 - dayDiff] += 1;
                }
              }
            }
          }

          // Get resources
          final resources = await _supabase
              .from('course_resources')
              .select('id')
              .inFilter('course_id', courseIds);
          _totalResources = (resources as List).length;
        }
      }

      // Recent activity — latest student questions
      _recentActivity = await _fetchRecentActivity(userId);
    } catch (e) {
      debugPrint('Analytics error: $e');
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<List<Map<String, dynamic>>> _fetchRecentActivity(
      String teacherId) async {
    try {
      final response = await _supabase.rpc('get_teacher_recent_activity',
          params: {'teacher_id': teacherId}).limit(5);
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      // Fallback if RPC doesn't exist
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadAnalytics,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Row 1: Courses + Students
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Kurslar',
                  value: '$_totalCourses',
                  icon: Icons.school_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: 'Tələbələr',
                  value: _formatNum(_totalStudents),
                  icon: Icons.people_rounded,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 2: Rating + Lessons
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Ortalama Reytinq',
                  value: _avgRating > 0
                      ? _avgRating.toStringAsFixed(1)
                      : '—',
                  icon: Icons.star_rounded,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: 'Dərslər',
                  value: '$_totalLessons',
                  icon: Icons.play_lesson_rounded,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 3: Questions + Resources
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Suallar',
                  value: '$_totalQuestions',
                  icon: Icons.help_rounded,
                  color: AppColors.info,
                  trend: _pendingQuestions > 0
                      ? _pendingQuestions.toDouble()
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: 'Resurslar',
                  value: '$_totalResources',
                  icon: Icons.folder_rounded,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Pending questions indicator
          if (_pendingQuestions > 0)
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notification_important_rounded,
                      color: AppColors.warning, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '$_pendingQuestions gözləyən sual var',
                      style: AppTextStyles.titleMedium
                          .copyWith(color: AppColors.warning),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: AppColors.warning),
                ],
              ),
            ),

          // Weekly Activity Chart
          Text('Həftəlik Aktivlik', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _weeklyData.reduce((a, b) => a > b ? a : b) + 5,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toInt()} sual',
                        const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = [
                          'B.e', 'Ç.ə', 'Ç', 'C.ə', 'C', 'Ş', 'B'
                        ];
                        final now = DateTime.now();
                        final dayIndex =
                            (now.weekday - 7 + value.toInt()) % 7;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(days[dayIndex.abs() % 7],
                              style: AppTextStyles.labelSmall),
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
                barGroups: _weeklyData.asMap().entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value,
                        gradient: AppColors.primaryGradient,
                        width: 20,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Platform overview
          Text('Platforma Statistikası', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 12),
          _buildOverviewRow(
              Icons.book_rounded, 'Dərc olunmuş kurslar',
              '$_totalCourses kurs', AppColors.success),
          _buildOverviewRow(
              Icons.video_library_rounded, 'Yüklənmiş dərslər',
              '$_totalLessons dərs', AppColors.info),
          _buildOverviewRow(
              Icons.chat_rounded, 'Ümumi suallar',
              '$_totalQuestions sual', AppColors.primary),
          _buildOverviewRow(
              Icons.attach_file_rounded, 'Resurs faylları',
              '$_totalResources resurs', AppColors.accent),
        ],
      ),
    );
  }

  Widget _buildOverviewRow(
      IconData icon, String label, String value, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(label, style: AppTextStyles.bodyMedium),
        trailing: Text(value,
            style: AppTextStyles.titleMedium.copyWith(color: color)),
      ),
    );
  }

  String _formatNum(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}
