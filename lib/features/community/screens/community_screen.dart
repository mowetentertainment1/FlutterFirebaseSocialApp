import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/core/common/loader.dart';

import '../controller/community_controller.dart';

class CommunityScreen extends ConsumerWidget {
  final String communityName;

  const CommunityScreen({super.key, required this.communityName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        body: ref.watch(communityNameProvider(communityName)).when(
            data: (community) => NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      expandedHeight: 100,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                        // title: Text('r/${community.name}', style: const TextStyle(fontSize: 20)),
                        background: Image.network(
                          community.banner,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SliverPadding(
                        padding: const EdgeInsets.all(10),
                        sliver: SliverList(
                            delegate: SliverChildListDelegate([
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(community.avatar),
                                radius: 35,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            'r/${community.name.substring(0, 10)}',
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 5),
                                        Text(
                                          'Members: ${community.members.length}',
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                      ],
                                    ),
                                    OutlinedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20))),
                                        child: const Text('Join')),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Members: ${community.members.length}',
                            style: const TextStyle(fontSize: 15),
                          ),
                        ])))
                  ];
                },
                body: const Text("Displaying posts")),
            loading: () => const Loader(),
            error: (error, stackTrace) => Text(error.toString())));
  }
}
