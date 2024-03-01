import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/colors.dart';
import '../../../core/enums/message_enums.dart';
import '../../../core/utils.dart';
import '../../auth/controller/auth_controller.dart';
import '../controller/community_chat_controller.dart';
class CommunityBottomChatField extends ConsumerStatefulWidget {
  final String receiverUserId;
  const CommunityBottomChatField({
    super.key,
    required this.receiverUserId,
  });

  @override
  ConsumerState<CommunityBottomChatField> createState() => _CommunityBottomChatFieldState();
}

class _CommunityBottomChatFieldState extends ConsumerState<CommunityBottomChatField> {
  bool isShowSendButton = false;
  final TextEditingController _messageController = TextEditingController();
  FlutterSoundRecorder? _soundRecorder;
  bool isRecorderInit = false;
  bool isShowEmojiContainer = false;
  bool isRecording = false;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _soundRecorder = FlutterSoundRecorder();
    openAudio();
    ref.read(getCurrentUserDataProvider);
  }

  void openAudio() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Mic permission not allowed!');
    }
    await _soundRecorder!.openRecorder();
    isRecorderInit = true;
  }

  void sendTextMessage() async {
    if (isShowSendButton && _messageController.text.trim().isNotEmpty) {
      ref.read(communityChatControllerProvider.notifier).sendTextMessage(
        context,
        _messageController.text.trim(),
        widget.receiverUserId,
      );
      setState(() {
        _messageController.text = '';
        isShowSendButton = false;
      });
    } else {
      var tempDir = await getTemporaryDirectory();
      var path = '${tempDir.path}/flutter_sound.aac';
      if (!isRecorderInit) {
        return;
      }
      if (isRecording) {
        await _soundRecorder!.stopRecorder();
        sendFileMessage(File(path), MessageEnum.audio);
      } else {
        await _soundRecorder!.startRecorder(
          toFile: path,
        );
      }
        setState(() {
          isRecording = !isRecording;
        });
    }
  }

  void sendFileMessage(
      File file,
      MessageEnum messageEnum,
      ) {
    ref.read(communityChatControllerProvider.notifier).sendFileMessage(
        context,
        file,
        widget.receiverUserId,
        messageEnum
    );
  }

  void openPickImage() async {
    final res = await pickImage();
    if (res != null) {
      sendFileMessage(
        File(res.files.single.path!),
        MessageEnum.image,
      );
    }
  }

  void pickingVideo() async {
    final res = await pickVideo();
    if (res != null) {
      sendFileMessage(
        File(res.files.single.path!),
        MessageEnum.video,
      );
    }
  }

  void showKeyboard() => focusNode.requestFocus();
  void hideKeyboard() => focusNode.unfocus();
  @override
  void dispose() {
    super.dispose();
    _messageController.dispose();
    _soundRecorder!.closeRecorder();
    isRecorderInit = false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: 8.0,
        right: 8.0,
        bottom: 6.0,
      ),
      color: mobileChatBoxColor,
      child: Column(
        children: [
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
                            onPressed: openPickImage,
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
                  right: 2,
                  left: 2,
                ),
                child: CircleAvatar(
                  backgroundColor: tabColor,
                  child: GestureDetector(
                    onTap: sendTextMessage,
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
      ),
    );
  }
}
