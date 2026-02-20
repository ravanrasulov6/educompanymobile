import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/premium_drawer.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import 'package:provider/provider.dart';

/// Student bottom navigation shell
class StudentShell extends StatefulWidget {
  final Widget child;
  const StudentShell({super.key, required this.child});

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<String> get _destinations {
    final role = context.read<AuthProvider>().currentRole;
    if (role == UserRole.guest) {
      return ['/student/courses', '/student/categories'];
    }
    return [
      '/student/courses',
      '/student/live',
      '/student/assignments',
      '/student/schedule',
      '/student/my-courses',
    ];
  }

  void _onDestinationSelected(int index) {
    if (index != _currentIndex) {
      setState(() => _currentIndex = index);
      context.go(_destinations[index]);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sync nav index with current route
    final location = GoRouterState.of(context).matchedLocation;
    final dests = _destinations;
    for (int i = 0; i < dests.length; i++) {
      if (location.startsWith(dests[i])) {
        if (_currentIndex != i) {
          setState(() => _currentIndex = i);
        }
        break;
      }
    }
  }

  List<Map<String, dynamic>> get _drawerItems {
    final role = context.read<AuthProvider>().currentRole;
    if (role == UserRole.guest) {
      return [
        {
          'icon': Icons.dashboard_rounded,
          'label': AppStrings.navHome
        },
        {
          'icon': Icons.grid_view_rounded,
          'label': 'Kateqoriyalar'
        },
        {
          'icon': Icons.settings_rounded,
          'label': 'Tənzimləmələr'
        },
      ];
    }
    return const [
      {
        'icon': Icons.dashboard_rounded,
        'label': AppStrings.navHome
      },
      {
        'icon': Icons.emoji_events_rounded,
        'label': 'Liderlər Lövhəsi'
      },
      {
        'icon': Icons.insights_rounded,
        'label': 'Sınaq Nəticələrim'
      },
      {
        'icon': Icons.download_done_rounded,
        'label': 'Yükləmələrim'
      },
      {
        'icon': Icons.forum_rounded,
        'label': 'Müəllimə Sual Ver'
      },
      {
        'icon': Icons.settings_rounded,
        'label': 'Tənzimləmələr'
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isSubPage = _isSubPage(context);

    return Scaffold(
      key: _scaffoldKey,
      drawer: isSubPage
          ? null
          : PremiumDrawer(
              selectedIndex: _currentIndex,
              onDestinationSelected: _onDestinationSelected,
              items: _drawerItems,
            ),
      appBar: isSubPage
          ? null
          : AppBar(
              leading: GestureDetector(
                onTap: () => _scaffoldKey.currentState?.openDrawer(),
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Center(
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.1),
                      child: const Icon(Icons.menu_rounded,
                          size: 20, color: AppColors.primary),
                    ),
                  ),
                ),
              ),
              title: Row(
                children: [
                  Image.asset(
                    'assets/images/logo_m.png',
                    height: 28,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              leadingWidth: 52,
              actions: [
                if (!context.read<AuthProvider>().isGuest)
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.mail_outline_rounded,
                        color: AppColors.primary),
                    tooltip: 'Mesajlar',
                  ),
                const _ProfileActionButton(),
                const SizedBox(width: 8),
              ],
            ),
      extendBody: true,
      body: widget.child,
      bottomNavigationBar: isSubPage || context.read<AuthProvider>().isGuest
          ? null
          : ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.75),
                    border: Border(
                      top: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: NavigationBar(
                    backgroundColor: Colors.transparent, // override theme default 
                    elevation: 0,
                    selectedIndex: _currentIndex,
                    onDestinationSelected: _onDestinationSelected,
                    destinations: context.read<AuthProvider>().isGuest 
                      ? const [
                          NavigationDestination(
                            icon: Icon(Icons.home_outlined),
                            selectedIcon: Icon(Icons.home_rounded),
                            label: AppStrings.navHome,
                          ),
                          NavigationDestination(
                            icon: Icon(Icons.grid_view_outlined),
                            selectedIcon: Icon(Icons.grid_view_rounded),
                            label: 'Kateqoriyalar',
                          ),
                        ]
                      : const [
                          NavigationDestination(
                            icon: Icon(Icons.home),
                            selectedIcon: Icon(Icons.home),
                            label: AppStrings.navHome,
                          ),
                          NavigationDestination(
                            icon: Icon(Icons.videocam),
                            selectedIcon: Icon(Icons.videocam),
                            label: AppStrings.liveClasses,
                          ),
                          NavigationDestination(
                            icon: Icon(Icons.assignment),
                            selectedIcon: Icon(Icons.assignment),
                            label: AppStrings.assignments,
                          ),
                          NavigationDestination(
                            icon: Icon(Icons.event_note),
                            selectedIcon: Icon(Icons.event_note),
                            label: AppStrings.navSchedule,
                          ),
                          NavigationDestination(
                            icon: Icon(Icons.class_outlined),
                            selectedIcon: Icon(Icons.class_rounded),
                            label: AppStrings.myCourses,
                          ),
                        ],
                  ),
                ),
              ),
            ),
    );
  }

  /// Returns true only if the current route is a sub-page (not a root tab).
  bool _isSubPage(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    // If the current location exactly matches any root tab, it's NOT a sub-page
    for (final dest in _destinations) {
      if (location == dest) return false;
    }
    // Otherwise it's a sub-page (e.g. /student/courses/123, /student/profile)
    return true;
  }
}

class _ProfileActionButton extends StatelessWidget {
  const _ProfileActionButton();

  @override
  Widget build(BuildContext context) {
    final isGuest = context.watch<AuthProvider>().isGuest;

    if (isGuest) {
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.go('/login'),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.login_rounded, color: AppColors.primary, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Giriş edin',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return IconButton(
      onPressed: () => context.push('/student/profile'),
      icon: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 20),
      ),
      tooltip: 'Profil',
    );
  }
}
