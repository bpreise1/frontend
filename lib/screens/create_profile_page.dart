import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/home.dart';
import 'package:frontend/models/user_exception.dart';
import 'package:frontend/providers/current_user_provider.dart';
import 'package:frontend/repository/user_repository.dart';

import 'package:frontend/widgets/profile_avatar.dart';

class CreateProfilePage extends StatefulWidget {
  const CreateProfilePage({super.key});

  @override
  State<CreateProfilePage> createState() => _CreateProfilePageState();
}

class _CreateProfilePageState extends State<CreateProfilePage> {
  late final TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Flexible(
                child: Text(
                  'Thank you for using Fitkick!\n\nPlease create a username and optionally upload a profile picture to get started!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(
                  top: 20,
                ),
                child: Consumer(
                  builder: (context, ref, child) {
                    final currentUser = ref.watch(currentUserProvider);

                    return currentUser.when(
                      data: (data) {
                        final profilePicture = data.profilePicture;

                        return ProfileAvatar(
                          radius: 100,
                          profilePicture: profilePicture,
                          editingEnabled: true,
                        );
                      },
                      error: (error, stackTrace) {
                        return Text(
                          error.toString(),
                        );
                      },
                      loading: () {
                        return const ProfileAvatar(radius: 100);
                      },
                    );
                  },
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                child: TextField(
                  controller: _textEditingController,
                  decoration: InputDecoration(
                    hintText: 'Enter username...',
                    suffixIcon: const Icon(Icons.edit),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              Consumer(
                builder: (context, ref, child) {
                  return OutlinedButton(
                    onPressed: () async {
                      UserException? userException;

                      try {
                        await ref
                            .read(currentUserProvider.notifier)
                            .setUsernameById(userRepository.getCurrentUserId(),
                                _textEditingController.text);
                      } on UserException catch (exception) {
                        userException = exception;
                      }

                      if (context.mounted) {
                        if (userException != null) {
                          userException.displayException(context);
                        } else {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) {
                                return const Home();
                              },
                            ),
                          );
                        }
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Text('Get Started'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
