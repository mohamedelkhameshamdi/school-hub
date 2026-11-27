import 'package:flutter/material.dart';

import '../../data/models/app_user.dart';
import '../../data/repositories/school_repository.dart';
import '../../data/services/auth_service.dart';
import 'admin_dashboard_screen.dart';
import 'event_form_screen.dart';
import 'events_list_screen.dart';
import 'news_form_screen.dart';
import 'news_list_screen.dart';
import 'plan_form_screen.dart';
import 'plans_screen.dart';

class _TabSpec {
  const _TabSpec({
    required this.title,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.body,
    this.onAdd,
    this.addLabel = 'Add',
  });

  final String title;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget body;
  final VoidCallback? onAdd;
  final String addLabel;
}

/// Students get News / Events / Plans. Admins also get a Dashboard tab and
/// a "+" button on each tab to create content.
class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.user,
    required this.authService,
    required this.repository,
  });

  final AppUser user;
  final AuthService authService;
  final SchoolRepository repository;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  void _openNewsForm() => Navigator.of(context).push(
        MaterialPageRoute<bool>(
          builder: (_) => NewsFormScreen(repository: widget.repository),
        ),
      );

  void _openEventForm() => Navigator.of(context).push(
        MaterialPageRoute<bool>(
          builder: (_) => EventFormScreen(repository: widget.repository),
        ),
      );

  void _openPlanForm() => Navigator.of(context).push(
        MaterialPageRoute<bool>(
          builder: (_) => PlanFormScreen(repository: widget.repository),
        ),
      );

  List<_TabSpec> _buildTabs() {
    final user = widget.user;
    final repo = widget.repository;
    final admin = user.isAdmin;

    return [
      if (admin)
        _TabSpec(
          title: 'Dashboard',
          label: 'Dashboard',
          icon: Icons.dashboard_outlined,
          selectedIcon: Icons.dashboard,
          body: AdminDashboardScreen(
            repository: repo,
            user: user,
            onNewEvent: _openEventForm,
            onNewNews: _openNewsForm,
            onNewPlan: _openPlanForm,
          ),
        ),
      _TabSpec(
        title: 'School News',
        label: 'News',
        icon: Icons.article_outlined,
        selectedIcon: Icons.article,
        body: NewsListScreen(repository: repo, user: user),
        onAdd: admin ? _openNewsForm : null,
        addLabel: 'Post news',
      ),
      _TabSpec(
        title: admin ? 'Manage Events' : 'Upcoming Events',
        label: 'Events',
        icon: Icons.event_outlined,
        selectedIcon: Icons.event,
        body: EventsListScreen(repository: repo, user: user),
        onAdd: admin ? _openEventForm : null,
        addLabel: 'New event',
      ),
      _TabSpec(
        title: 'School Plans',
        label: 'Plans',
        icon: Icons.flag_outlined,
        selectedIcon: Icons.flag,
        body: PlansScreen(repository: repo, user: user),
        onAdd: admin ? _openPlanForm : null,
        addLabel: 'Add plan',
      ),
    ];
  }

  Future<void> _confirmSignOut() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will need to sign in again to continue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (ok == true) await widget.authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _buildTabs();
    final index = _index >= tabs.length ? 0 : _index;
    final current = tabs[index];

    return Scaffold(
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(current.title, key: ValueKey(current.title)),
        ),
        actions: [
          if (widget.user.isAdmin)
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Chip(
                avatar: Icon(Icons.shield_outlined, size: 18),
                label: Text('Admin'),
                visualDensity: VisualDensity.compact,
              ),
            ),
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: _confirmSignOut,
          ),
        ],
      ),
      // IndexedStack keeps each tab alive: scroll position is preserved.
      body: IndexedStack(
        index: index,
        children: [for (final tab in tabs) tab.body],
      ),
      floatingActionButton: current.onAdd == null
          ? null
          : FloatingActionButton.extended(
              onPressed: current.onAdd,
              icon: const Icon(Icons.add),
              label: Text(current.addLabel),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          for (final tab in tabs)
            NavigationDestination(
              icon: Icon(tab.icon),
              selectedIcon: Icon(tab.selectedIcon),
              label: tab.label,
            ),
        ],
      ),
    );
  }
}
