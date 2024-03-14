import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:routemaster/routemaster.dart';
import 'package:video_player/video_player.dart';

import '../controller/short_video_controller.dart';

class CreateShortVideoScreen extends ConsumerStatefulWidget {
  const CreateShortVideoScreen({
    super.key,
  });

  @override
  ConsumerState<CreateShortVideoScreen> createState() => _CreateShortVideoScreenState();
}

class _CreateShortVideoScreenState extends ConsumerState<CreateShortVideoScreen> {
  late VideoPlayerController controller;

  File? videoFile;
  final TextEditingController _songController = TextEditingController();
  final TextEditingController _captionController = TextEditingController();
 void pickVideo(ImageSource src, BuildContext context) async {
    final video = await ImagePicker().pickVideo(source: src);
    if (video != null) {
      videoFile = File(video.path);
      setState(() {
        controller = VideoPlayerController.file(videoFile!);
      });
      controller.initialize();
      controller.play();
      controller.setVolume(1);
      controller.setLooping(true);
    }
  }
void uploadVideo(String songName, String caption, String videoPath) async {
    final shortVideoController = ref.read(shortVideoControllerProvider.notifier);
    shortVideoController.uploadShortVideo(
      context: context,
      caption: caption,
      songName: songName,
      file: File(videoPath),
    );
  }
  @override
  void initState() {
    super.initState();
    pickVideo(ImageSource.gallery, context);
  }
  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
   final isLoading = ref.watch(shortVideoControllerProvider);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            (videoFile == null)
                ? Column(
                children: [
                  const SizedBox(height: 150),
                  IconButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.blue),
                    ),
                    onPressed: () {
                      pickVideo(ImageSource.gallery, context);
                    },
                    icon: const Icon(
                      Icons.video_library,
                      size: 60,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text('Add a video to create a short video',
                      style: GoogleFonts.poppins(fontSize: 18)),
                ],
            )
                : SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 1.5,
                    child: VideoPlayer(controller),
                  ),
            const SizedBox(
              height: 20,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: MediaQuery.of(context).size.width - 20,
                    child: TextField(
                      controller: _songController,
                      decoration: const InputDecoration(
                        labelText: 'Song Name',
                        icon: Icon(Icons.music_note),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: MediaQuery.of(context).size.width - 20,
                    child: TextField(
                      controller: _captionController,
                      decoration: const InputDecoration(
                        labelText: 'Caption',
                        icon: Icon(Icons.closed_caption),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  ElevatedButton(

                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(70, 55),
                      backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0), // Circular shape
                  ),
                        ),
                      onPressed: () {
                        isLoading
                            ? null
                            : uploadVideo(
                            _songController.text, _captionController.text, videoFile!.path);
                      },
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : const Icon(Icons.check,size: 45,),),
                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
