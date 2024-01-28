import 'dart:typed_data';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:routemaster/routemaster.dart';
import 'package:untitled/core/common/photo_view.dart';
import 'package:untitled/features/community/controller/community_controller.dart';
import 'package:untitled/model/post_model.dart';
import 'package:untitled/responsive/responsive.dart';
import 'package:untitled/theme/pallete.dart';

import '../../features/auth/controller/auth_controller.dart';
import '../../features/post/controller/post_controller.dart';

class PostCard extends ConsumerWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  void deletePost(BuildContext context, WidgetRef ref) {
    ref.read(postControllerProvider.notifier).deletePost(post, context);
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

  void navigateToComments(BuildContext context) {
    Routemaster.of(context).push('/post/${post.id}/comments');
  }
  void navigateToImgPost(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ImageZoomScreen(
              imageUrls: post.linkImage,
              initialIndex: index,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTypeImage = post.type == 'image';
    final isTypeText = post.type == 'text';

    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    final currentTheme = ref.watch(themeNotifierProvider);
    return Responsive(
      child: Column(
        children: [
          Container(
              decoration: BoxDecoration(
                color: currentTheme.textTheme.bodyText2!.color!.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
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
                                    child: CircleAvatar(
                                      radius: 25,
                                      backgroundImage:
                                          NetworkImage(post.communityProfilePic),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 160,
                                          child: Text(
                                            'r/${post.communityName}',
                                            style: currentTheme
                                                .textTheme.bodyText2!
                                                .copyWith(
                                              color: currentTheme
                                                  .textTheme.bodyText2!.color!
                                                  .withOpacity(0.8),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 160,
                                          child: Text(
                                            'u/${post.username}',
                                            style: currentTheme
                                                .textTheme.bodyText2!
                                                .copyWith(
                                              color: currentTheme
                                                  .textTheme.bodyText2!.color!
                                                  .withOpacity(0.8),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  ref
                                      .watch(getCommunityByNameProvider(
                                          post.communityName))
                                      .when(
                                          data: (community) {
                                            if (community.mods
                                                .contains(user.uid)) {
                                              return PopupMenuButton(
                                                  icon: const Icon(
                                                      Icons.admin_panel_settings),
                                                  itemBuilder: (context) => [
                                                        const PopupMenuItem(
                                                          value: 'edit',
                                                          child: Text('Edit'),
                                                        ),
                                                        const PopupMenuItem(
                                                          value: 'delete',
                                                          child: Text('Delete',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red)),
                                                        ),
                                                      ],
                                                  onSelected: (value) {
                                                    if (value == 'edit') {
                                                      // Navigator.push(
                                                      //   context,
                                                      //   MaterialPageRoute(
                                                      //     builder: (context) =>
                                                      //         EditPostScreen(post: post),
                                                      //   ),
                                                      // );
                                                    } else {
                                                      deletePost(context, ref);
                                                    }
                                                  });
                                            }
                                            return const SizedBox();
                                          },
                                          loading: () =>
                                              const CircularProgressIndicator(),
                                          error: (e, s) => const Text('Error')),
                                  if (post.uid == user.uid)
                                    PopupMenuButton(
                                        itemBuilder: (context) => [
                                              const PopupMenuItem(
                                                value: 'edit',
                                                child: Text('Edit'),
                                              ),
                                              const PopupMenuItem(
                                                value: 'delete',
                                                child: Text('Delete',
                                                    style: TextStyle(
                                                        color: Colors.red)),
                                              ),
                                            ],
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            // Navigator.push(
                                            //   context,
                                            //   MaterialPageRoute(
                                            //     builder: (context) =>
                                            //         EditPostScreen(post: post),
                                            //   ),
                                            // );
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
                                  color: currentTheme.textTheme.bodyText2!.color,
                                  fontSize: 16,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (isTypeImage)
                                SizedBox(
                                  height: 300,
                                  child: GridView.builder(
                                    scrollDirection: Axis.horizontal,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 1,
                                    ),
                                    itemCount: post.linkImage.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: DottedBorder(
                                          borderType: BorderType.RRect,
                                          radius: const Radius.circular(10),
                                          dashPattern: const [12, 4],
                                          strokeCap: StrokeCap.round,
                                          color: currentTheme
                                              .textTheme.bodyText2!.color!,
                                          child: InkWell(
                                            onTap: () {
                                              navigateToImgPost(context, index);
                                            },
                                            child: Container(
                                              height: double.infinity,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              width: double.infinity,
                                              child: Image.network(
                                                post.linkImage[index],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: isGuest
                                            ? () {}
                                            : () => upvotePost(ref),
                                        icon: const Icon(Icons.arrow_upward),
                                        color: post.upvotes.contains(user.uid)
                                            ? Colors.green
                                            : null,
                                      ),
                                      Text(
                                        (post.upvotes.length -
                                                post.downvotes.length)
                                            .toString(),
                                        style: currentTheme.textTheme.bodyText2!
                                            .copyWith(
                                          color: currentTheme
                                              .textTheme.bodyText2!.color!
                                              .withOpacity(0.8),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: isGuest
                                            ? () {}
                                            : () => downVotePost(ref),
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
                                        style: currentTheme.textTheme.bodyText2!
                                            .copyWith(
                                          color: currentTheme
                                              .textTheme.bodyText2!.color!
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
