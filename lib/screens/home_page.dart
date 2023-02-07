import 'package:flutter/material.dart';

Map mockDate = {
  'username': 'Test User',
};

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    //TODO: Make separate widgets for each part of page
    return Column(
      children: [
        Expanded(
          child: Row(),
        ),
        Expanded(
          child: ListView(),
        ),
        Expanded(
          child: ListView(),
        )
      ],
    );
  }
}
