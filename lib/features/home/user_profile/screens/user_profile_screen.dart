import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:untitled/core/common/error_text.dart';
import 'package:untitled/features/home/user_profile/controller/user_profile_controller.dart';
import 'package:untitled/responsive/responsive.dart';

import '../../../../core/common/loader.dart';
import '../../../../core/common/posts/post_card.dart';
import '../../../auth/controller/auth_controller.dart';

class UserProfileScreen extends ConsumerWidget {
  final String uid;
  final String name;

  const UserProfileScreen({super.key, required this.uid, required this.name});

  void navigateToEditProfile(BuildContext context) {
    Routemaster.of(context).push('/edit-profile/$uid');
  }
  void navigateToChat(BuildContext context) {
    Routemaster.of(context).push('/chat/$name/$uid');
  }
  void followUser(String uidForFollow, WidgetRef ref) {
    ref.read(userProfileControllerProvider.notifier).followUser(uidForFollow);
  }
  void unfollowUser(String uidForUnfollow, WidgetRef ref) {
    ref.read(userProfileControllerProvider.notifier).unFollowUser(uidForUnfollow);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(userProvider)!;
    final isOwner = currentUser.uid == uid;
    final isGuest = !currentUser.isAuthenticated;
    return Responsive(
      child: Scaffold(
          body: ref.watch(getUserDataProvider(uid)).when(
              data: (user) => NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverAppBar(
                        expandedHeight: 100,
                        pinned: true,
                        flexibleSpace: FlexibleSpaceBar(
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
                              children: [
                                CircleAvatar(
                                  backgroundImage: NetworkImage(user.profilePic),
                                  radius: 35,
                                ),
                                const SizedBox(width: 10),
                                SizedBox(
                                  width: 250,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('u/${user.name}',
                                          style: const TextStyle(
                                              fontSize: 16, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 5),
                                      Text(
                                        'Karma: ${user.karma}',
                                        style: const TextStyle(fontSize: 12),
                                      ),const SizedBox(height: 5),
                                      Text(
                                        'Follower: ${user.followers.length}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              child: Text(

                                ' ${user.description}',
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                isOwner
                                    ? ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blueAccent,
                                        ),
                                        onPressed: () => navigateToEditProfile(context),
                                        child: const Text(
                                          'Edit Profile',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      )
                                    : isGuest
                                        ? const SizedBox()
                                    :
                                currentUser.following.contains(uid)
                                        ? ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.grey,
                                            ),
                                            onPressed: () => unfollowUser(uid, ref),
                                            child: const Text('Unfollow',
                                                style: TextStyle(color: Colors.white)),
                                          )
                                        :
                                ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blueAccent,
                                        ),
                                        onPressed: () => followUser(uid, ref),
                                        child: const Text('Follow',
                                            style: TextStyle(color: Colors.white)),
                                      ),
                                const SizedBox(width: 10),
                                isOwner
                                    ? const SizedBox()
                                    : ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blueAccent,
                                        ),
                                        onPressed: () => navigateToChat(context),
                                        child: const Text('Message',
                                            style: TextStyle(color: Colors.white)),
                                      )
                              ],
                            ),
                            const Divider()
                          ])))
                    ];
                  },
                  body: ref.watch(getUserPostsProvider(uid)).when(
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
              error: (error, stackTrace) => ErrorText(
                    error: error.toString(),
                  ))),
    );
  }
}
