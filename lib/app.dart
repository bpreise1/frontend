import 'package:flutter/material.dart';
import 'package:frontend/authentication/auth_gate.dart';
import 'package:frontend/theme/theme_constants.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: darkTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: const AuthGate(),
    );
  }
}
