import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:untitled/features/short_video/screens/video_card.dart';
import 'package:untitled/model/comment_model.dart';

import '../../../model/short_video_model.dart';
import '../../../responsive/responsive.dart';
import '../../../theme/palette.dart';
import '../../auth/controller/auth_controller.dart';
import '../../post/controller/post_controller.dart';
import '../../post/widget/comment_card.dart';
import '../controller/short_video_controller.dart';
import 'circle_animation.dart';

class ShortVideo extends ConsumerStatefulWidget {
  final String uid;
  const ShortVideo({super.key, required this.uid});

  @override
  ConsumerState createState() => _ShortVideoState();
}

class _ShortVideoState extends ConsumerState<ShortVideo> {
  final TextEditingController _commentController = TextEditingController();
  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void addComment(ShortVideoModel video) {
    ref.read(shortVideoControllerProvider.notifier).addComment(
          context: context,
          text: _commentController.text.trim(),
          post: video,
        );
    setState(() {
      _commentController.text = '';
    });
  }

  void navigateToCreateShortVideo(BuildContext context) {
    Routemaster.of(context).push('/create-short-video');
  }

  void upvotePost(WidgetRef ref, ShortVideoModel video) {
    ref.read(shortVideoControllerProvider.notifier).upVoteShortVideo(video);
  }

  void downVotePost(WidgetRef ref, ShortVideoModel video) {
    ref.read(shortVideoControllerProvider.notifier).downVoteShortVideo(video);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    final currentTheme = ref.watch(themeNotifierProvider);
    return Scaffold(
      body: ref.watch(getUserShortVideoByIdProvider(widget.uid)).when(
            data: (shortVideos) {
              return Stack(
                children: [
                  VideoPlayerItem(
                    videoUrl: shortVideos.videoUrl,
                  ),
                  Column(
                    children: [
                      const SizedBox(
                        height: 100,
                      ),
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.only(
                                  left: 20,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      shortVideos.userName,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      shortVideos.caption,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.music_note,
                                          size: 15,
                                          color: Colors.white,
                                        ),
                                        Text(
                                          shortVideos.songName,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: 100,
                              margin: const EdgeInsets.only(top: 20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  ref.read(getUserDataProvider(shortVideos.userUid)).when(
                                        data: (user) {
                                          return buildProfile(
                                            user.profilePic,
                                          );
                                        },
                                        loading: () => const CircularProgressIndicator(),
                                        error: (error, stack) => const SizedBox(),
                                      ),
                                  Column(
                                    children: [
                                      IconButton(
                                        onPressed: isGuest
                                            ? () {}
                                            : () => upvotePost(ref, shortVideos),
                                        icon: Icon(
                                          Icons.arrow_upward,
                                          size: 40,
                                          color: shortVideos.upVotes.contains(user.uid)
                                              ? Colors.green
                                              : Colors.white,
                                        ),
                                      ),
                                      Text(
                                        (shortVideos.upVotes.length -
                                                shortVideos.downVotes.length)
                                            .toString(),
                                        style: const TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: isGuest
                                            ? () {}
                                            : () => downVotePost(ref, shortVideos),
                                        icon: Icon(
                                          Icons.arrow_downward,
                                          size: 40,
                                          color: shortVideos.downVotes.contains(user.uid)
                                              ? Colors.red
                                              : Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          showBottomSheet(
                                              backgroundColor:
                                                  currentTheme.backgroundColor,
                                              shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(20),
                                                  topRight: Radius.circular(20),
                                                ),
                                              ),
                                              context: context,
                                              builder: (context) {
                                                return PopScope(
                                                  canPop: false,
                                                  onPopInvoked: (bool isPop) {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets.all(20),
                                                    height: 600,
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          'Comments',
                                                          style: TextStyle(
                                                              color: currentTheme
                                                                  .textTheme
                                                                  .bodyMedium!
                                                                  .color!,
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight.bold),
                                                        ),
                                                        Expanded(
                                                          child: StreamBuilder<
                                                              List<CommentModel>>(
                                                            stream: ref
                                                                .watch(
                                                                    shortVideoControllerProvider
                                                                        .notifier)
                                                                .fetchShortVideoComments(
                                                                    shortVideos.id),
                                                            builder: (BuildContext
                                                                    context,
                                                                AsyncSnapshot<
                                                                        List<
                                                                            CommentModel>>
                                                                    snapshot) {
                                                              if (snapshot
                                                                      .connectionState ==
                                                                  ConnectionState
                                                                      .waiting) {
                                                                return const Center(
                                                                    child:
                                                                        CircularProgressIndicator());
                                                              }
                                                              if (snapshot
                                                                  .data!.isEmpty) {
                                                                return const Center(
                                                                    child: Text(
                                                                        'No comments'));
                                                              }
                                                              return ListView.builder(
                                                                itemCount:
                                                                    snapshot.data!.length,
                                                                itemBuilder:
                                                                    (BuildContext context,
                                                                        int index) {
                                                                  final comment = snapshot
                                                                      .data![index];
                                                                  return InkWell(
                                                                    onLongPress: () {
                                                                      if (comment
                                                                              .username ==
                                                                          user.name) {
                                                                        showDialog<void>(
                                                                          context:
                                                                              context,
                                                                          barrierDismissible:
                                                                              true,
                                                                          builder:
                                                                              (BuildContext
                                                                                  dialogContext) {
                                                                            return AlertDialog(
                                                                              title: const Text(
                                                                                  'Delete Comment'),
                                                                              content:
                                                                                  const Text(
                                                                                      'Are you sure you want to delete this comment?'),
                                                                              actions: <Widget>[
                                                                                TextButton(
                                                                                  child: const Text(
                                                                                      'Cancel'),
                                                                                  onPressed:
                                                                                      () {
                                                                                    Navigator.of(dialogContext)
                                                                                        .pop();
                                                                                  },
                                                                                ),
                                                                                TextButton(
                                                                                  child: const Text(
                                                                                      'Delete',
                                                                                      style:
                                                                                          TextStyle(color: Colors.red)),
                                                                                  onPressed:
                                                                                      () {
                                                                                    Navigator.of(dialogContext)
                                                                                        .pop();
                                                                                    ref.read(postControllerProvider.notifier).deleteComment(
                                                                                        comment,
                                                                                        context);
                                                                                  },
                                                                                ),
                                                                              ],
                                                                            );
                                                                          },
                                                                        );
                                                                      }
                                                                    },
                                                                    child: CommentCard(
                                                                        comment: comment),
                                                                  );
                                                                },
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                        if (!isGuest)
                                                          Responsive(
                                                            child: SizedBox(
                                                              height: 50,
                                                              child: TextField(
                                                                controller:
                                                                    _commentController,
                                                                decoration:
                                                                    InputDecoration(
                                                                  border:
                                                                      const OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                      Radius.circular(10),
                                                                    ),
                                                                  ),
                                                                  contentPadding:
                                                                      const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal: 16),
                                                                  hintText:
                                                                      'Add a comment',
                                                                  suffixIcon:
                                                                      GestureDetector(
                                                                    onTap: () {
                                                                      addComment(
                                                                          shortVideos);
                                                                    },
                                                                    child:
                                                                        _commentController
                                                                                .text
                                                                                .trim()
                                                                                .isEmpty
                                                                            ? IconButton(
                                                                                onPressed:
                                                                                    () {},
                                                                                icon: const Icon(
                                                                                    Icons
                                                                                        .send,
                                                                                    color:
                                                                                        Colors.grey),
                                                                              )
                                                                            : IconButton(
                                                                                onPressed:
                                                                                    () {
                                                                                  addComment(
                                                                                      shortVideos);
                                                                                },
                                                                                icon: const Icon(
                                                                                    Icons
                                                                                        .send,
                                                                                    color:
                                                                                        Colors.blue),
                                                                              ),
                                                                  ),
                                                                ),
                                                                onSubmitted: (value) {
                                                                  addComment(shortVideos);
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              });
                                        },
                                        child: const Icon(
                                          Icons.comment,
                                          size: 40,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 7),
                                      Text(
                                        shortVideos.commentCount.toString(),
                                        style: const TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                        ),
                                      )
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      InkWell(
                                        onTap: () {},
                                        child: const Icon(
                                          Icons.reply,
                                          size: 40,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  CircleAnimation(
                                    child: buildMusicAlbum(shortVideos.userProfilePic),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text(
                'Error: $error',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
    );
  }

  buildProfile(String profilePhoto) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(children: [
        Positioned(
          right: 5,
          child: Container(
            width: 50,
            height: 50,
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image(
                image: NetworkImage(profilePhoto),
                fit: BoxFit.cover,
              ),
            ),
          ),
        )
      ]),
    );
  }

  buildMusicAlbum(String profilePhoto) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Column(
        children: [
          Container(
              padding: EdgeInsets.all(11),
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Colors.grey,
                      Colors.white,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image(
                  image: NetworkImage(profilePhoto),
                  fit: BoxFit.cover,
                ),
              ))
        ],
      ),
    );
  }
}
