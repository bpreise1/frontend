import 'package:flutter/services.dart';

class RepsInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;

    final pattern = RegExp(r"^(\d+(?:-\d*)?)?$");
    if (!pattern.hasMatch(newText)) {
      return oldValue;
    }

    return newValue;
  }
}
