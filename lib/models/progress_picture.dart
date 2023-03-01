import 'dart:typed_data';

class ProgressPicture {
  const ProgressPicture({required this.image, this.timeCreated});

  final Uint8List image;
  final DateTime? timeCreated;
}
