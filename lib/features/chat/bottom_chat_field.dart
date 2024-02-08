
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/colors.dart';
import '../../core/utils.dart';

class BottomChatField extends ConsumerStatefulWidget {
  final String recieverUserId;
  final bool isGroupChat;
  const BottomChatField({
    super.key,
    required this.recieverUserId,
    required this.isGroupChat,
  });

  @override
  ConsumerState<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends ConsumerState<BottomChatField> {
  bool isShowSendButton = false;
  final TextEditingController _messageController = TextEditingController();
  // FlutterSoundRecorder? _soundRecorder;
  bool isRecorderInit = false;
  bool isShowEmojiContainer = false;
  bool isRecording = false;
  FocusNode focusNode = FocusNode();

  // @override
  // void initState() {
  //   super.initState();
  //   _soundRecorder = FlutterSoundRecorder();
  //   openAudio();
  // }

  // void openAudio() async {
  //   final status = await Permission.microphone.request();
  //   if (status != PermissionStatus.granted) {
  //     throw RecordingPermissionException('Mic permission not allowed!');
  //   }
  //   await _soundRecorder!.openRecorder();
  //   isRecorderInit = true;
  // }

  // void sendTextMessage() async {
  //   if (isShowSendButton) {
  //     ref.read(chatControllerProvider).sendTextMessage(
  //       context,
  //       _messageController.text.trim(),
  //       widget.recieverUserId,
  //       widget.isGroupChat,
  //     );
  //     setState(() {
  //       _messageController.text = '';
  //     });
  //   } else {
  //     var tempDir = await getTemporaryDirectory();
  //     var path = '${tempDir.path}/flutter_sound.aac';
  //     if (!isRecorderInit) {
  //       return;
  //     }
  //     if (isRecording) {
  //       await _soundRecorder!.stopRecorder();
  //       sendFileMessage(File(path), MessageEnum.audio);
  //     } else {
  //       await _soundRecorder!.startRecorder(
  //         toFile: path,
  //       );
  //     }
  //
  //     setState(() {
  //       isRecording = !isRecording;
  //     });
  //   }
  // }
  //
  // void sendFileMessage(
  //     File file,
  //     MessageEnum messageEnum,
  //     ) {
  //   ref.read(chatControllerProvider).sendFileMessage(
  //     context,
  //     file,
  //     widget.recieverUserId,
  //     messageEnum,
  //     widget.isGroupChat,
  //   );
  // }
  //

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

  void hideEmojiContainer() {
    setState(() {
      isShowEmojiContainer = false;
    });
  }

  void showEmojiContainer() {
    setState(() {
      isShowEmojiContainer = true;
    });
  }

  void showKeyboard() => focusNode.requestFocus();
  void hideKeyboard() => focusNode.unfocus();

  void toggleEmojiKeyboardContainer() {
    if (isShowEmojiContainer) {
      showKeyboard();
      hideEmojiContainer();
    } else {
      hideKeyboard();
      showEmojiContainer();
    }
  }

  // @override
  // void dispose() {
  //   super.dispose();
  //   _messageController.dispose();
  //   _soundRecorder!.closeRecorder();
  //   isRecorderInit = false;
  // }

  @override
  Widget build(BuildContext context) {
    // final messageReply = ref.watch(messageReplyProvider);
    // final isShowMessageReply = messageReply != null;
    return Column(
      children: [
        // isShowMessageReply ? const MessageReplyPreview() : const SizedBox(),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                focusNode: focusNode,
                controller: _messageController,
                onChanged: (val) {
                  if (val.isNotEmpty) {
                    setState(() {
                      isShowSendButton = true;
                    });
                  } else {
                    setState(() {
                      isShowSendButton = false;
                    });
                  }
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: mobileChatBoxColor,

                  suffixIcon: SizedBox(
                    width: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: pickImages,
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Colors.grey,
                          ),
                        ),
                        const IconButton(
                          onPressed: pickVideo,
                          icon: Icon(
                            Icons.video_collection,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  hintText: 'Type a message!',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: const BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(10),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                bottom: 8,
                right: 2,
                left: 2,
              ),
              child: CircleAvatar(
                backgroundColor: const Color(0xFF128C7E),
                radius: 25,
                child: GestureDetector(
                  onTap: () {
                    // sendTextMessage();
                  },
                  child: Icon(
                    isShowSendButton
                        ? Icons.send
                        : isRecording
                        ? Icons.close
                        : Icons.mic,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
