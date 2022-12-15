import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: IconButton(
          onPressed: (() async {
            await FirebaseAuth.instance.signOut();
          }),
          icon: const Icon(Icons.exit_to_app)),
    );
  }
}
