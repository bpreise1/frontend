import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/current_user_provider.dart';
import 'package:frontend/providers/profile_page_provider.dart';
import 'package:frontend/widgets/add_image_button.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar(
      {required this.radius,
      this.profilePicture,
      this.editingEnabled = false,
      this.isProfilePage = false,
      super.key});

  final double radius;
  final Uint8List? profilePicture;
  final bool editingEnabled;
  final bool isProfilePage;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          children: [
            CircleAvatar(
              backgroundImage:
                  profilePicture != null ? MemoryImage(profilePicture!) : null,
              radius: radius,
            ),
            if (editingEnabled)
              Positioned(
                right: 0,
                bottom: 0,
                child: Consumer(
                  builder: (context, ref, child) {
                    return AddImageButton(
                      onImagePicked: (image) {
                        ref
                            .read(currentUserProvider.notifier)
                            .setProfilePictureForCurrentUser(image);

                        if (isProfilePage) {
                          ref
                              .read(profilePageProvider.notifier)
                              .setProfilePicture(image);
                        }
                      },
                      opacity: .7,
                    );
                  },
                ),
              ),
          ],
        ),
      ],
    );
  }
}
