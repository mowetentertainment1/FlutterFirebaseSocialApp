import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:untitled/core/common/error_text.dart';

import '../../../../core/common/loader.dart';
import '../../../auth/controller/auth_controller.dart';

class UserProfileScreen extends ConsumerWidget {
  final String uid;

  const UserProfileScreen({super.key, required this.uid});

  void navigateToEditProfile(BuildContext context) {
    Routemaster.of(context).push('/edit-profile/$uid');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    return Scaffold(
        body: ref.watch(getUserDataProvider(uid)).when(
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
                              SizedBox(
                                width: 180,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('u/${user.name}',
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
                                  onPressed: () =>
                                      navigateToEditProfile(context),
                                  style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                          color: Colors.blue, width: 1),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20))),
                                  child: const Icon(Icons.edit, size: 20)),
                            ],
                          ),
                          const SizedBox(height: 20),
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
            error: (error, stackTrace) => ErrorText(
                  error: error.toString(),
                )));
  }
}
