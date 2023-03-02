import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProgressPicturePage extends StatelessWidget {
  const ProgressPicturePage(
      {required this.username,
      required this.image,
      required this.dateCreated,
      super.key});

  final String username;
  final MemoryImage image;
  final DateTime dateCreated;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(username),
        ),
        body: ListView(
          children: [
            Hero(
              tag: image,
              child: Image(image: image),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Center(
                child: Text(
                  DateFormat('yMMMMd').format(dateCreated),
                ),
              ),
            ),
          ],
        ));
  }
}
