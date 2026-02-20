import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/premium_drawer.dart';

/// Admin dashboard shell with navigation
class AdminShell extends StatefulWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const _destinations = [
    '/admin/dashboard',
    '/admin/users',
    '/admin/courses',
    '/admin/settings',
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
    final location = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < _destinations.length; i++) {
      if (location.startsWith(_destinations[i])) {
        if (_currentIndex != i) setState(() => _currentIndex = i);
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: PremiumDrawer(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onDestinationSelected,
        items: const [
          {'icon': Icons.dashboard_rounded, 'label': AppStrings.navHome},
          {'icon': Icons.people_alt_rounded, 'label': AppStrings.navUsers},
          {'icon': Icons.auto_stories_rounded, 'label': AppStrings.courseManagement},
          {'icon': Icons.settings_rounded, 'label': AppStrings.navSettings},
        ],
      ),
      appBar: AppBar(
        leading: context.canPop()
            ? IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              )
            : GestureDetector(
                onTap: () => _scaffoldKey.currentState?.openDrawer(),
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Center(
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: const Icon(Icons.menu_rounded,
                          size: 20, color: AppColors.primary),
                    ),
                  ),
                ),
              ),
        title: Text(_getTitle()),
        leadingWidth: 52,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_active_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: widget.child,
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(height: 1, thickness: 0.5),
          NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: _onDestinationSelected,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_rounded),
                selectedIcon: Icon(Icons.dashboard_rounded),
                label: AppStrings.navHome,
              ),
              NavigationDestination(
                icon: Icon(Icons.people_alt_rounded),
                selectedIcon: Icon(Icons.people_alt_rounded),
                label: AppStrings.navUsers,
              ),
              NavigationDestination(
                icon: Icon(Icons.auto_stories_rounded),
                selectedIcon: Icon(Icons.auto_stories_rounded),
                label: AppStrings.courseManagement,
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_rounded),
                selectedIcon: Icon(Icons.settings_rounded),
                label: AppStrings.navSettings,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0: return AppStrings.adminPanel;
      case 1: return AppStrings.userManagement;
      case 2: return AppStrings.courseManagement;
      case 3: return AppStrings.settingsTitle;
      default: return AppStrings.appName;
    }
  }
}
