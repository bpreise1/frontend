import 'package:flutter/material.dart';

class UserProfileScaffoldWidget extends StatelessWidget {
  const UserProfileScaffoldWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          Scaffold.of(context).openEndDrawer();
        },
        icon: const Icon(Icons.person));
  }
}
