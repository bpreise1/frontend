import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/search_page_provider.dart';
import 'package:frontend/screens/profile_page.dart';
import 'package:frontend/utils/debouncer.dart';
import 'package:frontend/widgets/profile_avatar.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Debouncer debouncer = Debouncer(
      duration: const Duration(milliseconds: 500),
    );

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
        ),
        Consumer(
          builder: (context, ref, child) {
            return TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Enter username...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onChanged: (value) async {
                debouncer.run(
                  () async {
                    await ref
                        .read(
                          searchPageNotifierProvider.notifier,
                        )
                        .queryUsersByUsername(value);
                  },
                );
              },
            );
          },
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
        ),
        Consumer(
          builder: (context, ref, child) {
            final users = ref.watch(searchPageNotifierProvider);

            return users.when(
              data: (data) {
                return Expanded(
                  child: ListView.separated(
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Row(
                          children: [
                            ProfileAvatar(
                              radius: 50,
                              profilePicture: data[index].profilePicture,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                            ),
                            Text(data[index].username),
                          ],
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return ProfilePage(
                                    id: data[index].id,
                                    username: data[index].username,
                                    profilePicture: data[index].profilePicture);
                              },
                            ),
                          );
                        },
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const Divider();
                    },
                    itemCount: data.length,
                  ),
                );
              },
              error: (error, stackTrace) {
                return Text(
                  error.toString(),
                );
              },
              loading: () {
                return CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.secondary,
                );
              },
            );
          },
        )
      ],
    );
  }
}
