import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils.dart';
import '../../../theme/pallete.dart';

class AddPostScreen extends ConsumerStatefulWidget {
  const AddPostScreen({super.key});
  @override
  ConsumerState createState() => _CreateAddPostScreenState();
  }

  class _CreateAddPostScreenState extends ConsumerState<AddPostScreen> {
  final titleController = TextEditingController();
  final bodyController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    bodyController.dispose();
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
  // void pickImageFromCamera() async {
  //   final res = await pickImageCamera();
  //   if (res != null) {
  //     setState(() {
  //         imageFiles.add(File(res.path));
  //     });
  //   }
  // }
  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeNotifierProvider);

    return Wrap(
      children: [
    Container(
      padding: const EdgeInsets.all(8.0),
      child: const TextField(
      decoration: InputDecoration(
      hintText: 'What\'s on your mind?',
      ),
      maxLines: 5,
      ),
    ),
        const SizedBox(height: 20),
        // imageFiles.isNotEmpty
        //     ? SizedBox(
        //   height: 200,
        //   child: GridView.builder(
        //     scrollDirection: Axis.horizontal,
        //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        //       crossAxisCount: 1,
        //     ),
        //     itemCount: imageFiles.length,
        //     itemBuilder: (BuildContext context, int index) {
        //       return Padding(
        //         padding: const EdgeInsets.all(8.0),
        //         child: DottedBorder(
        //           borderType: BorderType.RRect,
        //           radius: const Radius.circular(10),
        //           dashPattern: const [12, 4],
        //           strokeCap: StrokeCap.round,
        //           color: currentTheme.textTheme.bodyText2!.color!,
        //           child: Container(
        //             height: 200,
        //             decoration: BoxDecoration(
        //               borderRadius: BorderRadius.circular(10),
        //             ),
        //             width: double.infinity,
        //             child: Image.file(imageFiles[index]),
        //           ),
        //         ),
        //       );
        //     },
        //   ),
        // )
        //     : const SizedBox(height: 0),
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
                onPressed: () {},
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
                onPressed: () {},
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
