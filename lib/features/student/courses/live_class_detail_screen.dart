import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../providers/course_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/haptic_service.dart';
import '../../../models/course_model.dart';

class LiveClassDetailScreen extends StatefulWidget {
  final String courseId;
  const LiveClassDetailScreen({super.key, required this.courseId});

  @override
  State<LiveClassDetailScreen> createState() => _LiveClassDetailScreenState();
}

class _LiveClassDetailScreenState extends State<LiveClassDetailScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Timer? _timer;
  Duration _timeRemaining = const Duration();
  late DateTime _targetTime;

  @override
  void initState() {
    super.initState();
    // Setup Blinking Animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    _fadeAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Setup Mock Target Time (2 hours from now)
    _targetTime = DateTime.now().add(const Duration(hours: 2, minutes: 15, seconds: 30));
    _updateTime();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    if (_targetTime.isAfter(now)) {
      setState(() {
        _timeRemaining = _targetTime.difference(now);
      });
    } else {
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();
    final course = provider.courses.firstWhere(
      (c) => c.id == widget.courseId,
      orElse: () => CourseModel.demoCourses.first,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.black.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.8),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: isDark ? Colors.white : Colors.black),
              onPressed: () => context.pop(),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            SizedBox(
              height: 380,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    course.thumbnailUrl,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          isDark ? Colors.black.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.9),
                          isDark ? Colors.black : Colors.white,
                        ],
                        stops: const [0.4, 0.8, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 24,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: AppColors.error,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'CANLI ƏLAQƏ',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.error,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.people_rounded, size: 14),
                                  const SizedBox(width: 4),
                                  Text('${course.studentsCount} tələbə', style: AppTextStyles.labelSmall),
                                ],
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          course.title,
                          style: AppTextStyles.headlineLarge.copyWith(height: 1.1),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.person_rounded, size: 16, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text(course.instructor, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Next Session Action Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.timer_rounded, color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Dərsin başlamasına qaldı:',
                                    style: AppTextStyles.labelSmall.copyWith(color: Colors.white70),
                                  ),
                                  Text(
                                    _formatDuration(_timeRemaining),
                                    style: AppTextStyles.headlineMedium.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: ElevatedButton(
                            onPressed: () {
                              HapticService.heavy();
                              // Logic to join Zoom / Live Stream
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primary,
                              elevation: 0,
                              minimumSize: const Size(double.infinity, 54),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.live_tv_rounded, size: 20),
                                const SizedBox(width: 8),
                                Text('İndi Qoşul', style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Calendar
                  Text('Dərs Təqvimi', style: AppTextStyles.titleLarge),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 90,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 7,
                      itemBuilder: (context, index) {
                        final now = DateTime.now();
                        final date = now.add(Duration(days: index - 2));
                        final isToday = index == 2;
                        final hasClass = index == 2 || index == 5;
                        
                        return Container(
                          width: 64,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: isToday ? AppColors.primary : (isDark ? AppColors.darkSurface : Colors.white),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isToday ? AppColors.primary : (isDark ? Colors.white12 : Colors.black12),
                            ),
                            boxShadow: isToday ? [
                              BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))
                            ] : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _getWeekday(date.weekday),
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: isToday ? Colors.white70 : (isDark ? Colors.white60 : Colors.black54),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${date.day}',
                                style: AppTextStyles.titleLarge.copyWith(
                                  color: isToday ? Colors.white : (isDark ? Colors.white : Colors.black),
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (hasClass)
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: isToday ? Colors.white : AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Notes and Materials
                  Text('Materiallar və Qeydlərim', style: AppTextStyles.titleLarge),
                  const SizedBox(height: 16),
                  _buildMaterialCard(
                    context,
                    title: 'Dərs 1: Mövzu Müzakirəsi Slaydı',
                    type: 'PDF',
                    size: '2.4 MB',
                    icon: Icons.picture_as_pdf_rounded,
                    color: Colors.redAccent,
                  ),
                  _buildMaterialCard(
                    context,
                    title: 'Ev tapşırığı N1',
                    type: 'DOCX',
                    size: '1.1 MB',
                    icon: Icons.description_rounded,
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialCard(BuildContext context, {required String title, required String type, required String size, required IconData icon, required Color color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('$type • $size', style: AppTextStyles.labelSmall),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded),
            color: AppColors.primary,
            onPressed: () {
              HapticService.light();
            },
          ),
        ],
      ),
    );
  }

  String _getWeekday(int weekday) {
    switch (weekday) {
      case 1: return 'BE';
      case 2: return 'ÇA';
      case 3: return 'Çər';
      case 4: return 'CA';
      case 5: return 'Cüm';
      case 6: return 'Şən';
      case 7: return 'Baz';
      default: return '';
    }
  }
}
