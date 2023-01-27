import 'package:flutter/material.dart';

class SnackBarException extends StatelessWidget {
  const SnackBarException({super.key, required this.errorMessage});

  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(16),
        height: 90,
        decoration: const BoxDecoration(
            color: Color(0xFFB00020),
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 3)),
            Flexible(
              fit: FlexFit.tight,
              child: Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 3)),
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
              icon: const Icon(Icons.close, color: Colors.white),
            ),
          ],
        ));
  }
}
