import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/user_preferences.dart';
import 'package:frontend/providers/bottom_navigation_bar_provider.dart';
import 'package:frontend/providers/user_preferences_provider.dart';
import 'package:frontend/screens/create_plan_page.dart';
import 'package:frontend/screens/encyclopedia_page.dart';
import 'package:frontend/screens/home_page.dart';
import 'package:frontend/screens/new_create_plan_page.dart';
import 'package:frontend/screens/saved_plans_page.dart';
import 'package:frontend/screens/search_page.dart';
import 'package:frontend/widgets/user_profile_scaffold_button.dart';
import 'package:frontend/widgets/weight_mode_toggle.dart';

class Home extends ConsumerWidget {
  const Home({super.key});

  final List<Widget> _screens = const [
    HomePage(),
    SearchPage(),
    NewCreatePlanPage(),
    SavedPlansPage(),
    EncyclopediaPage(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int selectedIndex = ref.watch(bottomNavigationBarProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitkick'),
        actions: const [UserProfileScaffoldWidget()],
      ),
      endDrawer: Drawer(
        child: ListView(children: [
          TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
              child: const Text('Sign Out')),
          const Center(child: WeightModeToggle())
        ]),
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
