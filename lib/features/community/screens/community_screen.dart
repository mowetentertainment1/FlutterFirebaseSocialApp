import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:untitled/core/common/loader.dart';
import 'package:untitled/model/community_model.dart';

import '../../../core/common/error_text.dart';
import '../../../core/common/post_card.dart';
import '../../../responsive/responsive.dart';
import '../../auth/controller/auth_controller.dart';
import '../controller/community_controller.dart';

class CommunityScreen extends ConsumerWidget {
  final String communityName;

  void navigateToModTools(BuildContext context) {
    Routemaster.of(context).push('/mod-tools/$communityName');
  }

  void joinCommunity(WidgetRef ref, Community community, BuildContext context) {
    ref
        .read(communityControllerProvider.notifier)
        .joinCommunity(community, context);
  }

  const CommunityScreen({super.key, required this.communityName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    return Responsive(
      child: Scaffold(
          body: ref.watch(communityNameProvider(communityName)).when(
              data: (community) => NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverAppBar(
                        expandedHeight: 100,
                        pinned: true,
                        flexibleSpace: FlexibleSpaceBar(
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
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundImage: NetworkImage(community.avatar),
                                  radius: 35,
                                ),
                                const SizedBox(width: 10),
                                SizedBox(
                                  width: 250,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 10),
                                      Text('r/${community.name}',
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 5),
                                      Text(
                                        'Members: ${community.members.length}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          isGuest
                                              ? const SizedBox()
                                              :
                                          community.mods.contains(user.uid)
                                              ? ElevatedButton(
                                                  onPressed: () {
                                                    navigateToModTools(context);
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.blueAccent,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    'Mod Tools',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.white),
                                                  ),
                                                )
                                              : OutlinedButton(
                                                  onPressed: () => joinCommunity(
                                                      ref, community, context),
                                                  style: ElevatedButton.styleFrom(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    community.members
                                                            .contains(user.uid)
                                                        ? 'Leave'
                                                        : 'Join',
                                                    style: const TextStyle(
                                                        fontSize: 12),
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  ' ${community.description}',
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                            ),
                            const Divider(),
                          ])))
                    ];
                  },
                  body: ref.watch(getCommunityPostsProvider(communityName)).when(
                      data: (posts) {
                        return ListView.builder(
                          itemCount: posts.length,
                          itemBuilder: (context, index) {
                            final post = posts[index];
                            return PostCard(post: post);
                          },
                        );
                      },
                      error: (Object error, StackTrace stackTrace) =>
                          ErrorText(error: error.toString()),
                      loading: () => const Loader())),
              loading: () => const Loader(),
              error: (error, stackTrace) => Text(error.toString()))),
    );
  }
}
