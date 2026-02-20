import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/premium_drawer.dart';

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

  static const _destinations = [
    '/student/courses',
    '/student/live',
    '/student/assignments',
    '/student/schedule',
    '/student/exams',
  ];

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
    for (int i = 0; i < _destinations.length; i++) {
      if (location.startsWith(_destinations[i])) {
        if (_currentIndex != i) {
          setState(() => _currentIndex = i);
        }
        break;
      }
    }
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
              items: const [
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
              ],
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
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.mail_outline_rounded,
                      color: AppColors.primary),
                  tooltip: 'Mesajlar',
                ),
                IconButton(
                  onPressed: () => context.push('/student/profile'),
                  icon: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: AppColors.primary, width: 1.5),
                    ),
                    child: const Icon(Icons.person_rounded,
                        color: AppColors.primary, size: 20),
                  ),
                  tooltip: 'Profil',
                ),
                const SizedBox(width: 8),
              ],
            ),
      extendBody: true,
      body: widget.child,
      bottomNavigationBar: isSubPage
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
                    destinations: const [
                      NavigationDestination(
                        icon: Icon(Icons.home_outlined),
                        selectedIcon: Icon(Icons.home_rounded),
                        label: AppStrings.navHome,
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.videocam_outlined),
                        selectedIcon: Icon(Icons.videocam_rounded),
                        label: AppStrings.liveClasses,
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.assignment_outlined),
                        selectedIcon: Icon(Icons.assignment_rounded),
                        label: AppStrings.assignments,
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.event_note_outlined),
                        selectedIcon: Icon(Icons.event_note_rounded),
                        label: AppStrings.navSchedule,
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.quiz_outlined),
                        selectedIcon: Icon(Icons.quiz_rounded),
                        label: AppStrings.exams,
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
