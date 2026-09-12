import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/today_provider.dart';
import '../repositories/local_progress_repository.dart';
import 'bible_screen.dart';
import 'home_screen.dart';
import 'more_screen.dart';
import 'prayers_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({this.progressRepository, super.key});
  final LocalProgressRepository? progressRepository;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late final TodayProvider _todayProvider;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _todayProvider = TodayProvider(repository: widget.progressRepository);
  }

  @override
  void dispose() {
    _todayProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const destinations = [
      NavigationDestination(icon: Icon(Icons.today_outlined), label: 'Hoje'),
      NavigationDestination(
          icon: Icon(Icons.menu_book_outlined), label: 'Bíblia'),
      NavigationDestination(
          icon: Icon(Icons.volunteer_activism_outlined), label: 'Orações'),
      NavigationDestination(icon: Icon(Icons.more_horiz), label: 'Mais'),
    ];
    final screens = [
      const HomeScreen(),
      const BibleScreen(),
      const PrayersScreen(),
      const MoreScreen(),
    ];

    return ChangeNotifierProvider.value(
      value: _todayProvider,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 720;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Vida com Cristo'),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Icon(Icons.spa_outlined,
                      color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
            body: Row(
              children: [
                if (wide)
                  NavigationRail(
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: _select,
                    labelType: NavigationRailLabelType.all,
                    destinations: destinations
                        .map((destination) => NavigationRailDestination(
                              icon: destination.icon,
                              label: Text(destination.label),
                            ))
                        .toList(),
                  ),
                Expanded(
                  child: IndexedStack(index: _selectedIndex, children: screens),
                ),
              ],
            ),
            bottomNavigationBar: wide
                ? null
                : NavigationBar(
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: _select,
                    destinations: destinations,
                  ),
          );
        },
      ),
    );
  }

  void _select(int index) => setState(() => _selectedIndex = index);
}
