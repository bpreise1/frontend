import 'package:flutter/material.dart';

class PrivacyToggleButton extends StatelessWidget {
  const PrivacyToggleButton(
      {required this.isOn,
      required this.isPublicProfile,
      required this.onToggleOn,
      required this.onToggleOff,
      super.key});

  final bool isOn;
  final bool isPublicProfile;
  final void Function() onToggleOn;
  final void Function() onToggleOff;

  @override
  Widget build(BuildContext context) {
    final String text = isOn
        ? isPublicProfile
            ? 'Visible to everyone'
            : 'Visible to followers'
        : 'Visible to me only';

    return Row(
      children: [
        isOn
            ? IconButton(
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                onPressed: () {
                  onToggleOff();
                },
                icon: const Icon(Icons.visibility),
              )
            : IconButton(
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                onPressed: () {
                  onToggleOn();
                },
                icon: const Icon(Icons.visibility_off),
              ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 2),
        ),
        Flexible(
          child: Text(text),
        ),
      ],
    );
  }
}
