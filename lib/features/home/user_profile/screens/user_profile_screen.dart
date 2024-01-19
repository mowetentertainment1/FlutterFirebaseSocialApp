import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/core/common/error_text.dart';

import '../../../../core/common/loader.dart';
import '../../../auth/controller/auth_controller.dart';


class UserProfileScreen extends ConsumerWidget {
  final String uid;
  const UserProfileScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    return Scaffold( body: ref.watch(getUserDataProvider(uid)).when(
        data: (user) => NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 100,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    // title: Text('r/${user.name}', style: const TextStyle(fontSize: 20)),
                    background: Image.network(
                      user.banner,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SliverPadding(
                    padding: const EdgeInsets.all(10),
                    sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(user.profilePic),
                                radius: 35,
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 150,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('r/${user.name}',
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 5),
                                     Text(
                                      'Karma: ${user.karma}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              OutlinedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(20))),
                                  child: const Text('Edit profile',
                                      style:
                                      TextStyle(fontSize: 12))),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            child: Text(
                              ' ${user.description}',
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                        ])))
              ];
            },
            body: const Text("Displaying posts")),
        loading: () => const Loader(),
        error: (error, stackTrace) => ErrorText( error: error.toString(),)));
  }
}
