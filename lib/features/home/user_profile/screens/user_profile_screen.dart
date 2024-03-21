import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:untitled/core/common/error_text.dart';
import 'package:untitled/features/home/user_profile/controller/user_profile_controller.dart';
import 'package:untitled/responsive/responsive.dart';

import '../../../../core/colors.dart';
import '../../../../core/common/loader.dart';
import '../../../../core/common/posts/post_card.dart';
import '../../../auth/controller/auth_controller.dart';
import '../../../short_video/controller/short_video_controller.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  final String uid;
  final String name;
  final String token;

  const UserProfileScreen({
    super.key,
    required this.uid,
    required this.name,
    required this.token,
  });

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  void navigateToEditProfile(BuildContext context) {
    Routemaster.of(context).push('/edit-profile/${widget.uid}');
  }
  void navigateToChat(BuildContext context) {
    Routemaster.of(context).push('/chat/${widget.name}/${widget.uid}/${widget.token}');
  }

  void followUser(String uidForFollow, WidgetRef ref) {
    ref.read(userProfileControllerProvider.notifier).followUser(uidForFollow);
  }

  void unfollowUser(String uidForUnfollow, WidgetRef ref) {
    ref.read(userProfileControllerProvider.notifier).unFollowUser(uidForUnfollow);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(userProvider)!;
    final isOwner = currentUser.uid == widget.uid;
    final isGuest = !currentUser.isAuthenticated;
    return Responsive(
      child: Scaffold(
        body: ref.watch(getUserDataProvider(widget.uid)).when(
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
                                    Text(
                                      'u/${user.name}',
                                      style: const TextStyle(
                                          fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Karma: ${user.karma}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Text(
                                          'Follower: ${user.followers.length}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          'Following: ${user.following.length}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
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
                                      : currentUser.following.contains(widget.uid)
                                          ? ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.grey,
                                              ),
                                              onPressed: () =>
                                                  unfollowUser(widget.uid, ref),
                                              child: const Text('Unfollow',
                                                  style: TextStyle(color: Colors.white)),
                                            )
                                          : ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blueAccent,
                                              ),
                                              onPressed: () =>
                                                  followUser(widget.uid, ref),
                                              child: const Text('Follow',
                                                  style: TextStyle(color: Colors.white)),
                                            ),
                              const SizedBox(width: 10),
                              isOwner
                                  ? const SizedBox()
                                  : isGuest
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
                        ]),
                      ),
                    ),
                  ];
                },
                body: Column(
                  children: [
                    SizedBox(
                      child: TabBar(
                        controller: _tabController,
                        indicatorColor: tabColor,
                        indicatorWeight: 4,
                        labelColor: tabColor,
                        unselectedLabelColor: Colors.grey,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        tabs: const [
                          Tab(text: 'Posts'),
                          Tab(text: 'Short Videos'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          ref.watch(getUserPostsProvider(widget.uid)).when(
                                data: (posts) {
                                  return posts.isEmpty
                                      ? const Center(
                                          child: Text('No posts yet'),
                                        )
                                      : ListView.builder(
                                          itemCount: posts.length,
                                          itemBuilder: (BuildContext context, int index) {
                                            final post = posts[index];
                                            return PostCard(post: post);
                                          },
                                        );
                                },
                                error: (Object error, StackTrace stackTrace) =>
                                    ErrorText(error: error.toString()),
                                loading: () => const Loader(),
                              ),
                          ref.watch(getUserShortVideosUidProvider(widget.uid)).when(
                                data: (videos) {
                                  return videos.isEmpty
                                      ? const Center(
                                          child: Text('No videos yet'),
                                        )
                                      : GridView.builder(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemCount: videos.length,
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            childAspectRatio: 1,
                                            crossAxisSpacing: 5,
                                          ),
                                          itemBuilder: (context, index) {
                                            String thumbnail = videos[index].thumbnail;
                                            return InkWell(
                                              onLongPress: () {
                                                if (videos[index].userUid == user.uid) {
                                                  showDialog<void>(
                                                    context: context,
                                                    barrierDismissible: true,
                                                    builder:
                                                        (BuildContext dialogContext) {
                                                      return AlertDialog(
                                                        title:
                                                            const Text('Delete Comment'),
                                                        content: const Text(
                                                            'Are you sure you want to delete this comment?'),
                                                        actions: <Widget>[
                                                          TextButton(
                                                            child: const Text('Cancel'),
                                                            onPressed: () {
                                                              Navigator.of(dialogContext)
                                                                  .pop();
                                                            },
                                                          ),
                                                          TextButton(
                                                            child: const Text('Delete',
                                                                style: TextStyle(
                                                                    color: Colors.red)),
                                                            onPressed: () {
                                                              Navigator.of(dialogContext)
                                                                  .pop();
                                                              ref
                                                                  .read(
                                                                      shortVideoControllerProvider
                                                                          .notifier)
                                                                  .deleteShortVideo(
                                                                      videos[index],
                                                                      context);
                                                            },
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                }
                                              },
                                              onTap: () {
                                                Routemaster.of(context).push(
                                                    '/short-video/${videos[index].userUid}/$index');
                                              },
                                              child: CachedNetworkImage(
                                                imageUrl: thumbnail,
                                                fit: BoxFit.cover,
                                              ),
                                            );
                                          },
                                        );
                                },
                                error: (Object error, StackTrace stackTrace) =>
                                    ErrorText(error: error.toString()),
                                loading: () => const Loader(),
                              ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              loading: () => const Loader(),
              error: (error, stackTrace) => ErrorText(error: error.toString()),
            ),
      ),
    );
  }
}
