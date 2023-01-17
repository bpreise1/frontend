import 'package:flutter/material.dart';

class SnackBarException extends StatelessWidget {
  const SnackBarException({super.key, required this.errorMessage});

  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 70,
      decoration: const BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Stack(children: [
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
              icon: const Icon(Icons.close, color: Colors.white))
        ]),
        Center(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.white),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 3)),
            Text(errorMessage,
                style: const TextStyle(
                    fontSize: 12, overflow: TextOverflow.ellipsis)),
          ],
        ))
      ]),
    );
  }
}
