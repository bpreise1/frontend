import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
      secondary: Color(0xff898ae1), onSecondary: Colors.black),
);

ThemeData darkTheme = ThemeData(
  colorScheme: const ColorScheme.dark(
      secondary: Color(0xff585daf), onSecondary: Colors.white),
);
