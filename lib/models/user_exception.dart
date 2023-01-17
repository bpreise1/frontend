import 'package:flutter/material.dart';
import 'package:frontend/widgets/snack_bar_error.dart';

class UserException implements Exception {
  const UserException({required this.message});

  final String message;

  void displayException(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: SnackBarError(errorMessage: message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0));
  }
}
