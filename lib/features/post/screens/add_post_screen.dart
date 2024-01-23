import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/features/community/controller/community_controller.dart';

import '../../../core/common/loader.dart';
import '../../../core/utils.dart';
import '../../../model/community_model.dart';
import '../../../theme/pallete.dart';
import '../controller/post_controller.dart';

class AddPostScreen extends ConsumerStatefulWidget {
  const AddPostScreen({super.key});
  @override
  ConsumerState createState() => _CreateAddPostScreenState();
  }

  class _CreateAddPostScreenState extends ConsumerState<AddPostScreen> {
  final titleController = TextEditingController();
  Community? selectedCommunity;
  List<Community> communities = [];
  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
  }
  List<File> imageFiles = [];
  File? avatarFile;
  void pickImages() async {
    final res = await pickMultipleImages();
    if (res != null) {
      setState(() {
        for (var pickedImage in res) {
          imageFiles.add(File(pickedImage.path));
        }
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
      ref.read(postControllerProvider.notifier).shareImagePost(
        context: context,
        title: titleController.text.trim(),
        selectedCommunity: selectedCommunity ?? communities[0],
        file: imageFiles,
        // webFile: bannerWebFile,
      );
    }
  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeNotifierProvider);
    final isLoading = ref.watch(postControllerProvider);

    return isLoading
        ? const Loader()
        : Wrap(
      children: [
    Container(
      padding: const EdgeInsets.all(8.0),
      child:  TextField(
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
                  color: currentTheme.textTheme.bodyText2!.color!,
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
            : const SizedBox(height: 0),
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
              communities = communities;
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
                  style:  TextStyle(color:currentTheme.textTheme.bodyText2!.color!),
                  underline: Container(
                    height: 2,
                    color: currentTheme.textTheme.bodyText2!.color!,
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
                      value:  value.name,
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
                onPressed: () =>pickImages(),
              ),
              IconButton(
                icon: const Icon(Icons.linked_camera),
                onPressed: () =>pickImageFromCamera(),
              ),
              IconButton(
                icon: const Icon(Icons.video_collection),
                onPressed: () {},
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
      ],);
  }
}
