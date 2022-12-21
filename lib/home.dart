import 'package:flutter/material.dart';
import 'package:frontend/screens/create_plan_page.dart';
import 'package:frontend/screens/encyclopedia_page.dart';
import 'package:frontend/screens/home_page.dart';
import 'package:frontend/screens/saved_plans_page.dart';
import 'package:frontend/screens/search_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  final List<Widget> _screens = const [
    HomePage(),
    SearchPage(),
    CreatePlanPage(),
    SavedPlansPage(),
    EncyclopediaPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitkick'),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
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
        onTap: ((index) => {
              setState(() {
                _selectedIndex = index;
              })
            }),
      ),
    );
  }
}
