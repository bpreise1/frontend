import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class AddPictureModal extends StatelessWidget {
  const AddPictureModal({required this.onImagePicked, super.key});

  final void Function(Uint8List image) onImagePicked;

  Future<Uint8List?> _pickImage(ImageSource source) async {
    Uint8List? imageData;

    try {
      final image = await ImagePicker()
          .pickImage(source: source, maxHeight: 640, maxWidth: 960);
      if (image != null) {
        imageData = await image.readAsBytes();
      }
    } on PlatformException catch (exception) {
      print(exception.toString());
    }

    return imageData;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 50),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
          ),
          Container(
            alignment: Alignment.topCenter,
            height: 4,
            width: 36,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onBackground,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 30),
          ),
          InkWell(
            onTap: () async {
              Uint8List? image = await _pickImage(ImageSource.gallery);
              if (image != null) {
                onImagePicked(image);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Row(
                children: const [
                  Icon(Icons.image),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                  ),
                  Flexible(
                    child: Text(
                      'Choose from libary',
                    ),
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () async {
              Uint8List? image = await _pickImage(ImageSource.camera);
              if (image != null) {
                onImagePicked(image);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Row(
                children: const [
                  Icon(Icons.photo_camera),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                  ),
                  Flexible(
                    child: Text(
                      'Take photo',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
