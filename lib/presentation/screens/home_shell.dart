import 'package:flutter/material.dart';

import '../../data/repositories/mock_school_repository.dart';
import '../../data/repositories/school_repository.dart';
import 'events_list_screen.dart';
import 'news_list_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static const _titles = ['School News', 'Upcoming Events'];

  // Swap for MockSchoolRepository(simulateError: true) to preview the error state.
  final SchoolRepository _repository = MockSchoolRepository();
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(_titles[_index], key: ValueKey(_index)),
        ),
      ),
      // IndexedStack keeps each tab alive: scroll position and loaded data
      // are preserved when switching tabs.
      body: IndexedStack(
        index: _index,
        children: [
          NewsListScreen(repository: _repository),
          EventsListScreen(repository: _repository),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.article_outlined),
            selectedIcon: Icon(Icons.article),
            label: 'News',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: 'Events',
          ),
        ],
      ),
    );
  }
}
