import 'dart:typed_data';

class CustomUserInfo {
  CustomUserInfo(
      {required this.id, required this.username, required this.profilePicture});

  final String id;
  final String username;
  final Uint8List? profilePicture;
}
