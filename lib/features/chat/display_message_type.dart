import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/enums/message_enum.dart';

class DisplayMessageType extends StatelessWidget {
  final String message;
  final MessageEnum type;
  const DisplayMessageType({
    super.key,
    required this.message,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    bool isPlaying = false;
    // final AudioPlayer audioPlayer = AudioPlayer();

    return type == MessageEnum.text
        ? Text(
      message,
      style: const TextStyle(
        fontSize: 16,
      ),
    )
        : type == MessageEnum.audio
        ? StatefulBuilder(builder: (context, setState) {
      return IconButton(
        constraints: const BoxConstraints(
          minWidth: 100,
        ),
        onPressed: () async {
          // if (isPlaying) {
          //   await audioPlayer.pause();
          //   setState(() {
          //     isPlaying = false;
          //   });
          // } else {
          //   await audioPlayer.play(UrlSource(message));
          //   setState(() {
          //     isPlaying = true;
          //   });
          // }
        },
        icon: Icon(
          isPlaying ? Icons.pause_circle : Icons.play_circle,
        ),
      );
    })
        : Padding(
          padding: const EdgeInsets.all(8.0),
          child: CachedNetworkImage(
                imageUrl: message,
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),

              ),
        );
  }
}
