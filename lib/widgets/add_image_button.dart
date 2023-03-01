import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:frontend/widgets/add_picture_modal.dart';

class AddImageButton extends StatelessWidget {
  const AddImageButton(
      {required this.onImagePicked,
      this.size = 1,
      this.opacity = 1,
      super.key});

  final void Function(Uint8List image) onImagePicked;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        showModalBottomSheet(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          context: context,
          builder: (context) {
            return AddPictureModal(onImagePicked: onImagePicked);
          },
        );
      },
      style: ButtonStyle(
        padding: MaterialStateProperty.all<EdgeInsets>(
          EdgeInsets.all(16 * size),
        ),
        shape: MaterialStateProperty.all<CircleBorder>(
          const CircleBorder(),
        ),
        backgroundColor: MaterialStateProperty.all<Color>(
          Theme.of(context).colorScheme.secondary.withOpacity(opacity),
        ),
      ),
      child: Icon(
        Icons.photo_camera,
        size: 25 * size,
        color: Theme.of(context).colorScheme.onSecondary,
      ),
    );
  }
}
