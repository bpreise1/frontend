import 'package:flutter/material.dart';
import 'package:frontend/widgets/snack_bar_exception.dart';

class UserException implements Exception {
  const UserException({required this.message});

  final String message;

  void displayException(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: SnackBarException(errorMessage: message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        dismissDirection: DismissDirection.none,
        elevation: 100));
  }
}
