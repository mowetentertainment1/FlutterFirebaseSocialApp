import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:routemaster/routemaster.dart';
import 'package:untitled/core/common/loader.dart';
import 'package:untitled/core/common/video_player_view.dart';
import 'package:untitled/features/community/controller/community_controller.dart';
import 'package:untitled/model/post_model.dart';
import 'package:untitled/responsive/responsive.dart';
import 'package:untitled/theme/palette.dart';
import 'package:video_player/video_player.dart';

import '../../../features/auth/controller/auth_controller.dart';
import '../../../features/post/controller/post_controller.dart';

class PostCard extends ConsumerWidget {
  const PostCard({super.key, required this.post});
  final PostModel post;

  void deletePost(BuildContext context, WidgetRef ref) {
    ref.read(postControllerProvider.notifier).deletePost(post.linkImage, post, context);
  }

  void navigateToEditPost(BuildContext context) {
    Routemaster.of(context).push('/post/edit/${post.id}');
  }

  void upvotePost(WidgetRef ref) {
    ref.read(postControllerProvider.notifier).upVotePost(post);
  }

  void downVotePost(WidgetRef ref) {
    ref.read(postControllerProvider.notifier).downVotePost(post);
  }

  void navigateToCommunity(BuildContext context) {
    Routemaster.of(context).push('/r/${post.communityName}');
  }
  void navigateToUserProf(BuildContext context) {

  }

  void navigateToComments(BuildContext context) {
    Routemaster.of(context).push('/post/${post.id}/comments');
  }

  void navigateToImgPost(BuildContext context, int index, List<String> imageUrls) {
    Routemaster.of(context).push(
        '/post/img?imageUrls=${Uri.encodeComponent(imageUrls.join(','))}&initialIndex=$index');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTypeImage = post.type == 'image';
    final isTypeVideo = post.type == 'video';

    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    final currentTheme = ref.watch(themeNotifierProvider);
    return Responsive(
      child: Column(
        children: [
          Container(
              decoration: BoxDecoration(
                color: currentTheme.textTheme.bodyMedium!.color!.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      navigateToCommunity(context);
                                    },
                                    child: Stack(children: [
                                      CircleAvatar(
                                        radius: 25,
                                        backgroundImage:
                                            NetworkImage(post.communityProfilePic),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: GestureDetector(
                                          onTap: () {
                                            ref.read(getUserDataProvider(post.userUid)).whenData((value) {
                                              Routemaster.of(context).push('/u/${value.name}/${value.uid}/${value.token}');
                                            });
                                          },
                                          child: CircleAvatar(
                                            radius: 13,
                                            backgroundImage:
                                                NetworkImage(post.userProfilePic),
                                          ),
                                        ),
                                      ),
                                    ]),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 160,
                                          child: Text(
                                            'r/${post.communityName}',
                                            style: currentTheme.textTheme.bodyMedium!
                                                .copyWith(
                                              color: currentTheme
                                                  .textTheme.bodyMedium!.color!
                                                  .withOpacity(0.8),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 160,
                                          child: GestureDetector(
                                            onTap: () {
                                              ref.read(getUserDataProvider(post.userUid)).whenData((value) {
                                                Routemaster.of(context).push('/u/${value.name}/${value.uid}/${value.token}');
                                              });
                                            },
                                            child: Text(
                                              'u/${post.username}',
                                              style: currentTheme.textTheme.bodyMedium!
                                                  .copyWith(
                                                color: currentTheme
                                                    .textTheme.bodyMedium!.color!
                                                    .withOpacity(0.8),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  ref
                                      .watch(
                                          getCommunityByNameProvider(post.communityName))
                                      .when(
                                          data: (community) {
                                            if (community.mods.contains(user.uid)) {
                                              return PopupMenuButton(
                                                  icon: const Icon(
                                                      Icons.admin_panel_settings),
                                                  itemBuilder: (context) => [
                                                        const PopupMenuItem(
                                                          value: 'delete',
                                                          child: Text('Delete',
                                                              style: TextStyle(
                                                                  color: Colors.red)),
                                                        ),
                                                      ],
                                                  onSelected: (value) {
                                                    deletePost(context, ref);
                                                  });
                                            }
                                            return const SizedBox();
                                          },
                                          loading: () =>
                                              const CircularProgressIndicator(),
                                          error: (e, s) => const Text('Error')),
                                  if (post.userUid == user.uid)
                                    PopupMenuButton(
                                        itemBuilder: (context) => [
                                              const PopupMenuItem(
                                                value: 'edit',
                                                child: Text('Edit'),
                                              ),
                                              const PopupMenuItem(
                                                value: 'delete',
                                                child: Text('Delete',
                                                    style: TextStyle(color: Colors.red)),
                                              ),
                                            ],
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            navigateToEditPost(context);
                                          } else {
                                            deletePost(context, ref);
                                          }
                                        }),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                post.title,
                                style: GoogleFonts.poppins().copyWith(
                                  color: currentTheme.textTheme.bodyMedium!.color,
                                  fontSize: 16,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (isTypeImage)
                                SizedBox(
                                  height: 350,
                                  child: GridView.builder(
                                    scrollDirection: Axis.horizontal,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 1,
                                    ),
                                    itemCount: post.linkImage.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: InkWell(
                                          onTap: () {
                                            navigateToImgPost(
                                                context, index, post.linkImage);
                                          },
                                          child: SizedBox(
                                            height: double.infinity,
                                            width: double.infinity,
                                            child: CachedNetworkImage(
                                              imageUrl: post.linkImage[index],
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  const Loader(),
                                              useOldImageOnUrlChange: true,
                                              errorWidget: (context, url, error) =>
                                                  const Icon(Icons.error),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              if (isTypeVideo)
                                VideoPlayerView(
                                  url: post.linkVideo,
                                  dataSourceType: DataSourceType.network,
                                ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed:
                                            isGuest ? () {} : () => upvotePost(ref),
                                        icon: const Icon(Icons.arrow_upward),
                                        color: post.upvotes.contains(user.uid)
                                            ? Colors.green
                                            : null,
                                      ),
                                      Text(
                                        (post.upvotes.length - post.downvotes.length)
                                            .toString(),
                                        style:
                                            currentTheme.textTheme.bodyMedium!.copyWith(
                                          color: currentTheme.textTheme.bodyMedium!.color!
                                              .withOpacity(0.8),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed:
                                            isGuest ? () {} : () => downVotePost(ref),
                                        icon: const Icon(Icons.arrow_downward),
                                        color: post.downvotes.contains(user.uid)
                                            ? Colors.red
                                            : null,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          navigateToComments(context);
                                        },
                                        icon: const Icon(Icons.comment),
                                      ),
                                      Text(
                                        post.commentCount.toString(),
                                        style:
                                            currentTheme.textTheme.bodyMedium!.copyWith(
                                          color: currentTheme.textTheme.bodyMedium!.color!
                                              .withOpacity(0.8),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {},
                                        icon: const Icon(Icons.share),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              )),
        ],
      ),
    );
  }
}
