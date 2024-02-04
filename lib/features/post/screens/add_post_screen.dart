import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled/features/community/controller/community_controller.dart';
import 'package:video_player/video_player.dart';

import '../../../core/common/loader.dart';
import '../../../core/common/video_player_view.dart';
import '../../../core/utils.dart';
import '../../../model/community_model.dart';
import '../../../theme/pallete.dart';
import '../../auth/controller/auth_controller.dart';
import '../../home/delegates/search_community_delegates.dart';
import '../../home/drawers/community_list_drawer.dart';
import '../../home/drawers/profile_drawner.dart';
import '../controller/post_controller.dart';

class AddPostScreen extends ConsumerStatefulWidget {
  const AddPostScreen({super.key});

  @override
  ConsumerState createState() => _CreateAddPostScreenState();
}

class _CreateAddPostScreenState extends ConsumerState<AddPostScreen> {
  final titleController = TextEditingController();
  Community? selectedCommunity;
  List<Community> communitie = [];
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    titleController.dispose();
    super.dispose();
  }

  List<File> imageFiles = [];

  File? videoFile;

  void pickImages() async {
    final res = await pickMultipleImages();
    if (res != null) {
      setState(() {
        for (var pickedImage in res) {
          imageFiles.add(File(pickedImage.path));
          videoFile = null;
        }
      });
    }
  }

  void pickingVideo() async {
    final res = await pickVideo();
    if (res != null) {
      setState(() {
        videoFile = File(res.files.single.path!);
        imageFiles = [];
      });
    }
  }

  void pickImageFromCamera() async {
    final res = await pickImageCamera();
    if (res != null) {
      setState(() {
        imageFiles.add(File(res.path));
      });
    }
  }

  void sharePost() {
    if (imageFiles.isNotEmpty) {
      ref.read(postControllerProvider.notifier).shareImagePost(
            context: context,
            title: titleController.text.trim(),
            selectedCommunity: selectedCommunity ?? communitie[0],
            files: imageFiles,
          );
    } else if (videoFile != null) {
      ref.read(postControllerProvider.notifier).shareVideoPost(
            context: context,
            title: titleController.text.trim(),
            selectedCommunity: selectedCommunity ?? communitie[0],
            file: videoFile,
          );
    } else if (titleController.text.isNotEmpty) {
      ref.read(postControllerProvider.notifier).shareTextPost(
            context: context,
            title: titleController.text.trim(),
            selectedCommunity: selectedCommunity ?? communitie[0],
            linkVideo: '',
          );
    } else {
      showSnackBar(context, 'Please enter title');
    }
    setState(() {
      imageFiles = [];
      videoFile = null;
      titleController.clear();
    });
  }
  void displayDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void displayEndDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }
  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeNotifierProvider);
    final isLoading = ref.watch(postControllerProvider);

    final user = ref.watch(userProvider)!;
    return isLoading
        ? const Loader()
        : Scaffold(
      drawer: const CommunityListDrawer(),
      endDrawer: const ProfileDrawer(),
      appBar: AppBar(
        leading: Builder(builder: (context) {
          return IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => displayDrawer(context),
          );
        }),
        title: Text('Create Post', style: GoogleFonts.poppins()),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.search),
            onPressed: () {
              showSearch(context: context, delegate: SearchCommunityScreen(ref: ref));
            },
          ),
          Builder(builder: (context) {
            return IconButton(
              icon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(user.profilePic),
                ),
              ),
              onPressed: () => displayEndDrawer(context),
            );
          })
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
              imageFiles.isNotEmpty
                  ? SizedBox(
                      height: 200,
                      child: GridView.builder(
                        scrollDirection: Axis.horizontal,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
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
                                child: Image.file(imageFiles[index]),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : videoFile != null
                      ? VideoPlayerView(
                          url: videoFile!.path,
                          dataSourceType: DataSourceType.file,
                        )
                      : const SizedBox(),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child:
                      Text('Select Community:', style: TextStyle(fontSize: 16)),
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
                            : communities.first.name,
                        icon: const Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        style: TextStyle(
                          color: currentTheme.textTheme.bodyMedium!.color!
                              .withOpacity(0.8),
                        ),
                        underline: Container(
                          height: 2,
                          color: currentTheme.textTheme.bodyMedium!.color!
                              .withOpacity(0.8),
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCommunity = communities.firstWhere(
                                (element) => element.name == newValue);
                          });
                        },
                        items: communities
                            .map<DropdownMenuItem<String>>((Community value) {
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
              Container(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.image),
                      onPressed: () => pickImages(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.linked_camera),
                      onPressed: () => pickImageFromCamera(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.video_collection),
                      onPressed: () => pickingVideo(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.emoji_emotions),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_horiz),
                      onPressed: () {},
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () => sharePost(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                      ),
                      child: const Text(
                        'Post',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
            ]),
        );
  }
}
