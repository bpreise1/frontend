import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/bottom_navigation_bar_provider.dart';
import 'package:frontend/screens/create_plan_page.dart';
import 'package:frontend/screens/encyclopedia_page.dart';
import 'package:frontend/screens/home_page.dart';
import 'package:frontend/screens/saved_plans_page.dart';
import 'package:frontend/screens/search_page.dart';

class Home extends ConsumerWidget {
  const Home({super.key});

  final List<Widget> _screens = const [
    HomePage(),
    SearchPage(),
    CreatePlanPage(),
    SavedPlansPage(),
    EncyclopediaPage(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int selectedIndex = ref.watch(bottomNavigationBarProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitkick'),
      ),
      body: _screens[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'search'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'create-plan'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bookmark), label: 'saved-plans'),
          BottomNavigationBarItem(
              icon: Icon(Icons.import_contacts), label: 'encyclopedia'),
        ],
        onTap: ((index) {
          ref
              .read(bottomNavigationBarProvider.notifier)
              .setNavigationBarIndex(index);
        }),
      ),
    );
  }
}
