import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:untitled/features/short_video/screens/video_card.dart';

import '../controller/short_video_controller.dart';
import 'circle_animation.dart';

class ShortVideoScreen extends ConsumerStatefulWidget {
  const ShortVideoScreen({super.key});

  @override
  ConsumerState createState() => _ShortVideoScreenState();
}

class _ShortVideoScreenState extends ConsumerState<ShortVideoScreen> {
  void navigateToCreateShortVideo(BuildContext context) {
    Routemaster.of(context).push('/create-short-video');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Short Video'),
        backgroundColor: Colors.transparent,
        actions: [
          ElevatedButton(
            onPressed: () {
              navigateToCreateShortVideo(context);
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.transparent,
              padding: EdgeInsets.zero,
              elevation: 0.0,
            ),
            child: const Icon(Icons.add),
          ),
        ],
      ),
      body:
        ref.watch(getUserShortVideosProvider).when(
          data: (shortVideos) {
            return shortVideos.isEmpty? const Center(child: Text('No Videos Found'),)
                :PageView.builder(
              itemCount: shortVideos.length,
              controller: PageController(initialPage: 0,viewportFraction: 0.8),
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                final data = shortVideos[index];
                return Stack(
                  children: [
                    VideoPlayerItem(
                      videoUrl: data.videoUrl,
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
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        data.userName,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        data.caption,
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
                                            data.songName,
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
                                    buildProfile(
                                      data.userProfilePic,
                                    ),
                                    Column(
                                      children: [
                                        InkWell(
                                          onTap: ()
                                          {
                                            // videoController.likeVideo(data.id),
                                          },
                                          child: const Icon(
                                            Icons.favorite,
                                            size: 40,
                                            // color: data.likes.contains(
                                            //     authController.user.uid)
                                            //     ? Colors.red
                                            //     : Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 7),
                                        Text(
                                          data.upVotes.length.toString(),
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
                                          onTap: () {
                                            // Navigator.of(context).push(
                                            // MaterialPageRoute(
                                            // builder: (context) => CommentScreen(
                                            // id: data.id,
                                            // ),
                                            // ),
                                            // ),
                                          },
                                          child: const Icon(
                                            Icons.comment,
                                            size: 40,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 7),
                                        Text(
                                          data.commentCount.toString(),
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
                                        const SizedBox(height: 7),
                                        Text(
                                          data.downVotes.toString(),
                                          style: const TextStyle(
                                            fontSize: 20,
                                            color: Colors.white,
                                          ),
                                        )
                                      ],
                                    ),
                                    CircleAnimation(
                                      child: buildMusicAlbum(data.userProfilePic),
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
          left: 5,
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
