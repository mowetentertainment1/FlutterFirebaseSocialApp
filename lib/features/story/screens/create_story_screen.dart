import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/core/common/loader.dart';

import '../../../core/utils.dart';
import '../controller/story_controller.dart';

class CreateStoryScreen extends ConsumerStatefulWidget {
  const CreateStoryScreen({
    Key? key,
  }) : super(key: key);

  @override
  _CreateStoryScreenState createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends ConsumerState<CreateStoryScreen> {
  List<File> imageFiles = [];
  int initialIndex = 0;
  bool isZoomed = false;
  int currentIndex = 0;
  late PageController pageController;
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

  void saveStory() {
    final storyController = ref.read(storyControllerProvider.notifier);
    storyController.saveStory(
      context: context,
      title: 'Story Title',
      files: imageFiles,
    );
  }

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: initialIndex);
    currentIndex = initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(storyControllerProvider);
    return Scaffold(
      appBar: AppBar(),
      body: (imageFiles.isEmpty)
          ? Center(
              heightFactor: 10,
              child: Column(
                children: [
                  const SizedBox(height: 300),
                  IconButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.blue),
                    ),
                    onPressed: pickImages,
                    icon: const Icon(
                      Icons.add_a_photo,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text('Add some images to create a story',
                      style: GoogleFonts.poppins(fontSize: 18)),
                ],
              ),
            )
          : GestureDetector(
              onDoubleTap: () {
                setState(() {
                  isZoomed = !isZoomed;
                });
              },
              child: PhotoViewGallery.builder(
                itemCount: imageFiles.length,
                builder: (context, index) {
                  return PhotoViewGalleryPageOptions(
                    imageProvider: FileImage(imageFiles[index]),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 2,
                  );
                },
                scrollPhysics: const BouncingScrollPhysics(),
                backgroundDecoration: const BoxDecoration(
                  color: Colors.black,
                ),
                pageController: pageController,
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
              ),
            ),
      floatingActionButton: (imageFiles.isEmpty)
          ? null
          : Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      isZoomed = !isZoomed;
                    });
                  },
                  child: Icon(isZoomed ? Icons.zoom_out : Icons.zoom_in),
                ),
                const SizedBox(width: 10),
                isLoading
                    ? ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent.withOpacity(0.5),
                        ),
                        child: const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: () => saveStory(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                        ),
                        child: const Text(
                          'Post',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                const SizedBox(width: 10),
              ],
            ),
    );
  }

  void navigateToNextImage() {
    final nextIndex = currentIndex + 1;
    if (nextIndex < imageFiles.length) {
      setState(() {
        currentIndex = nextIndex;
      });
      pageController.jumpToPage(nextIndex);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No more images'),
        ),
      );
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
