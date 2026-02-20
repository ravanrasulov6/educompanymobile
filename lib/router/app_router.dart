import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';

// Feature screens
import '../features/landing/landing_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/student/student_shell.dart';
import '../features/student/courses/courses_screen.dart';
import '../features/student/courses/categories_screen.dart';
import '../features/student/courses/course_detail_screen.dart';
import '../features/student/courses/all_courses_screen.dart';
import '../features/student/courses/my_courses_screen.dart';
import '../features/student/courses/live_class_detail_screen.dart';
import '../features/student/live_classes/live_classes_screen.dart';
import '../features/student/assignments/assignments_screen.dart';
import '../features/student/schedule/schedule_screen.dart';
import '../features/student/exams/exams_screen.dart';
import '../features/student/exams/exam_taking_screen.dart';
import '../features/student/exams/exam_result_screen.dart';
import '../features/student/profile/profile_screen.dart';
import '../features/student/profile/payment_methods_screen.dart';
import '../features/student/profile/settings_placeholder_screen.dart';
import '../features/student/profile/streak_details_screen.dart';
import '../features/teacher/teacher_shell.dart';
import '../features/teacher/teacher_courses_screen.dart';
import '../features/teacher/teacher_analytics_screen.dart';
import '../features/teacher/create_assignment_screen.dart';
import '../features/teacher/create_exam_screen.dart';
import '../features/admin/admin_shell.dart';
import '../features/admin/admin_dashboard_screen.dart';
import '../features/admin/admin_users_screen.dart';
import '../features/admin/admin_courses_screen.dart';
import '../features/admin/admin_settings_screen.dart';

/// App router configuration with role-based navigation
class AppRouter {
  final AuthProvider authProvider;

  AppRouter(this.authProvider);

  late final GoRouter router = GoRouter(
    refreshListenable: authProvider,
    initialLocation: '/',
    redirect: _guardRedirect,
    routes: [
      // ── Landing ─────────────────────────────────────────────
      GoRoute(
        path: '/',
        name: 'landing',
        builder: (context, state) => const LandingScreen(),
      ),

      // ── Auth ────────────────────────────────────────────────
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const LoginScreen(),
          transitionsBuilder: (context, animation, _, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
        ),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const SignupScreen(),
          transitionsBuilder: (context, animation, _, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
        ),
      ),

      // ── Student Shell ───────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => StudentShell(child: child),
        routes: [
          GoRoute(
            path: '/student/courses',
            name: 'studentCourses',
            builder: (context, state) => const CoursesScreen(),
          ),
          GoRoute(
            path: '/student/categories',
            name: 'categories',
            builder: (context, state) => const CategoriesScreen(),
          ),
          GoRoute(
            path: '/student/courses/:id',
            name: 'courseDetail',
            builder: (context, state) => CourseDetailScreen(
              courseId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/student/live-classes/:id',
            name: 'liveClassDetail',
            builder: (context, state) => LiveClassDetailScreen(
              courseId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/student/live',
            name: 'liveClasses',
            builder: (context, state) => const LiveClassesScreen(),
          ),
          GoRoute(
            path: '/student/assignments',
            name: 'assignments',
            builder: (context, state) => const AssignmentsScreen(),
          ),
          GoRoute(
            path: '/student/schedule',
            name: 'schedule',
            builder: (context, state) => const ScheduleScreen(),
          ),
          GoRoute(
            path: '/student/exams',
            name: 'exams',
            builder: (context, state) => const ExamsScreen(),
          ),
          GoRoute(
            path: '/student/my-courses',
            name: 'myCourses',
            builder: (context, state) => const MyCoursesScreen(),
          ),
          GoRoute(
            path: '/student/streak-details',
            name: 'streakDetails',
            builder: (context, state) => const StreakDetailsScreen(),
          ),
          GoRoute(
            path: '/student/all-courses',
            name: 'allCourses',
            builder: (context, state) => const AllCoursesScreen(),
          ),
          GoRoute(
            path: '/student/exams/:id/take',
            name: 'takeExam',
            builder: (context, state) => const ExamTakingScreen(),
          ),
          GoRoute(
            path: '/student/exams/result',
            name: 'examResult',
            builder: (context, state) => const ExamResultScreen(),
          ),
          GoRoute(
            path: '/student/profile',
            name: 'studentProfile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/student/profile/certificates',
            name: 'studentCertificates',
            builder: (context, state) => const SettingsPlaceholderScreen(
              title: 'Sertifikatlar',
              icon: Icons.workspace_premium_rounded,
            ),
          ),
          GoRoute(
            path: '/student/profile/payment',
            name: 'studentPayment',
            builder: (context, state) => const PaymentMethodScreen(),
          ),
          GoRoute(
            path: '/student/profile/notifications',
            name: 'studentNotifications',
            builder: (context, state) => const SettingsPlaceholderScreen(
              title: 'Bildiriş Tənzimləmələri',
              icon: Icons.notifications_active_rounded,
            ),
          ),
        ],
      ),

      // ── Teacher Shell ───────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => TeacherShell(child: child),
        routes: [
          GoRoute(
            path: '/teacher/courses',
            name: 'teacherCourses',
            builder: (context, state) => const TeacherCoursesScreen(),
          ),
          GoRoute(
            path: '/teacher/analytics',
            name: 'teacherAnalytics',
            builder: (context, state) => const TeacherAnalyticsScreen(),
          ),
          GoRoute(
            path: '/teacher/create-assignment',
            name: 'createAssignment',
            builder: (context, state) => const CreateAssignmentScreen(),
          ),
          GoRoute(
            path: '/teacher/create-exam',
            name: 'createExam',
            builder: (context, state) => const CreateExamScreen(),
          ),
        ],
      ),

      // ── Admin Shell ─────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: '/admin/dashboard',
            name: 'adminDashboard',
            builder: (context, state) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: '/admin/users',
            name: 'adminUsers',
            builder: (context, state) => const AdminUsersScreen(),
          ),
          GoRoute(
            path: '/admin/courses',
            name: 'adminCourses',
            builder: (context, state) => const AdminCoursesScreen(),
          ),
          GoRoute(
            path: '/admin/settings',
            name: 'adminSettings',
            builder: (context, state) => const AdminSettingsScreen(),
          ),
        ],
      ),
    ],
  );

  /// Route guard: redirect based on auth status and role
  String? _guardRedirect(BuildContext context, GoRouterState state) {
    final isAuthenticated = authProvider.isAuthenticated;
    final role = authProvider.currentRole;
    final location = state.matchedLocation;

    // Public routes
    final publicRoutes = ['/', '/login', '/signup'];
    final isPublic = publicRoutes.contains(location);

    // Not authenticated → allow only public routes
    if (!isAuthenticated) {
      return isPublic ? null : '/';
    }

    // Authenticated user on public route → redirect to their dashboard
    if (isAuthenticated && isPublic) {
      switch (role) {
        case UserRole.student:
        case UserRole.guest:
          return '/student/courses';
        case UserRole.teacher:
          return '/teacher/courses';
        case UserRole.admin:
          return '/admin/dashboard';
      }
    }

    // Role-based access control
    if (location.startsWith('/admin') && role != UserRole.admin) {
      return '/student/courses';
    }
    if (location.startsWith('/teacher') &&
        role != UserRole.teacher &&
        role != UserRole.admin) {
      return '/student/courses';
    }

    return null; // No redirect needed
  }
}
