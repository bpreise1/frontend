import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/widgets/profile_avatar.dart';

class FollowRequestsPage extends ConsumerWidget {
  const FollowRequestsPage({required this.uid, super.key});

  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(
      userNotifierProvider(uid),
    );

    return user.when(
      data: (data) {
        final requests = data.followRequests;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Follow Requests'),
          ),
          body: ListView.separated(
              itemBuilder: (context, index) {
                return ListTile(
                  title: Row(
                    children: [
                      ProfileAvatar(
                        radius: 50,
                        profilePicture: requests[index].profilePicture,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                      Text(requests[index].username),
                      const Spacer(),
                      ElevatedButton(
                        style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (_) => Colors.white,
                          ),
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (_) => const Color(0xFFB00020),
                          ),
                        ),
                        onPressed: () {
                          ref
                              .read(userNotifierProvider(uid).notifier)
                              .rejectFollowRequest(
                                requests[index],
                              );
                        },
                        child: const Icon(Icons.close),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (_) => Colors.white,
                          ),
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (_) => const Color(0xFF146E0E),
                          ),
                        ),
                        onPressed: () {
                          ref
                              .read(userNotifierProvider(uid).notifier)
                              .acceptFollowRequest(
                                requests[index],
                              );
                        },
                        child: const Icon(Icons.check),
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return const Divider();
              },
              itemCount: requests.length),
        );
      },
      error: (error, stackTrace) {
        return Text(
          error.toString(),
        );
      },
      loading: () {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Follow Requests'),
          ),
          body: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.secondary,
          ),
        );
      },
    );
  }
}
