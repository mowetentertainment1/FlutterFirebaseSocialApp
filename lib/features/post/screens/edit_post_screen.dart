import 'package:chewie/chewie.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:routemaster/routemaster.dart';
import 'package:untitled/features/community/controller/community_controller.dart';
import 'package:video_player/video_player.dart';

import '../../../core/common/loader.dart';
import '../../../core/common/video_player_view.dart';
import '../../../core/utils.dart';
import '../../../model/community_model.dart';
import '../../../theme/palette.dart';
import '../controller/post_controller.dart';

class EditPostScreen extends ConsumerStatefulWidget {
  final String postId;
  const EditPostScreen({super.key, required this.postId});

  @override
  ConsumerState createState() => _CreateEditPostScreenState();
}

class _CreateEditPostScreenState extends ConsumerState<EditPostScreen> {
  final titleController = TextEditingController();
  CommunityModel? selectedCommunity;
  List<CommunityModel> communitie = [];
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    titleController.dispose();
    super.dispose();
  }

  List<String> imageFiles = [];

  String? videoFile;

  void updatePost() {
    if (titleController.text.isEmpty) {
      showSnackBar(context, 'Title cannot be empty');
      return;
    }
    if (selectedCommunity == null) {
      showSnackBar(context, 'Select a community');
      return;
    }
    ref.read(getPostByIdProvider(widget.postId)).whenData(
      (post) {
        ref.read(postControllerProvider.notifier).updatePost(
              title: titleController.text,
              context: context,
              postModel: post,
              selectedCommunity: selectedCommunity ?? communitie[0],
            );
      },
    );
    Routemaster.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeNotifierProvider);
    final isLoading = ref.watch(postControllerProvider);
    ref.read(getPostByIdProvider(widget.postId)).whenData((post) {
      if (titleController.text.isEmpty) {
        titleController.text = post.title;
      }
      if (selectedCommunity == null) {
        ref.read(communityNameProvider(post.communityName)).whenData((value) {
          selectedCommunity = value;
        });
      }
      if (post.linkVideo.isNotEmpty) {
        videoFile = post.linkVideo;
      } else if (post.linkImage.isNotEmpty) {
        imageFiles = post.linkImage;
      }
    });
    return isLoading
        ? const Loader()
        : Scaffold(
            appBar: AppBar(
              title: Text('Edit Post', style: GoogleFonts.poppins()),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ElevatedButton(
                    onPressed: () {
                      updatePost();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
            body: Wrap(children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    hintText: 'What\'s on your mind?',
                  ),
                  maxLines: 5,
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Select Community:', style: TextStyle(fontSize: 16)),
                ),
              ),
              ref.watch(userCommunitiesProvider).when(
                  data: (communities) {
                    communitie = communities;
                    if (communities.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('You have not joined any community yet'),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: DropdownButton<String>(
                        value: selectedCommunity != null
                            ? selectedCommunity!.name
                            : 'Select Community',
                        icon: const Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        style: TextStyle(
                          color:
                          currentTheme.textTheme.bodyMedium!.color!.withOpacity(0.8),
                        ),
                        underline: Container(
                          height: 2,
                          color: Colors.blueAccent,
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCommunity = communities
                                .firstWhere((element) => element.name == newValue);
                          });
                        },
                        items: communities
                            .map<DropdownMenuItem<String>>((CommunityModel value) {
                          return DropdownMenuItem<String>(
                            value: value.name,
                            child: Text(value.name),
                          );
                        }).toList(),
                      ),
                    );
                  },
                  loading: () => const Loader(),
                  error: (error, stackTrace) => Text(error.toString())),
              const SizedBox(height: 20),
              imageFiles.isNotEmpty
                  ? SizedBox(
                      height: 200,
                      child: GridView.builder(
                        scrollDirection: Axis.horizontal,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                        ),
                        itemCount: imageFiles.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DottedBorder(
                              borderType: BorderType.RRect,
                              radius: const Radius.circular(10),
                              dashPattern: const [12, 4],
                              strokeCap: StrokeCap.round,
                              color: currentTheme.textTheme.bodyMedium!.color!,
                              child: Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                width: double.infinity,
                                child: Image.network(
                                  imageFiles[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : videoFile != null
                      ? VideoPlayerView(
                          url: videoFile!,
                          dataSourceType: DataSourceType.network,
                        )
                      : const SizedBox(),

            ]),
          );
  }
}
