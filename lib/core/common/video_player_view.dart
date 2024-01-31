import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerView extends StatefulWidget {
  final String url;
  final DataSourceType dataSourceType;
  const VideoPlayerView({super.key, required this.url, required this.dataSourceType});

  @override
  _VideoPlayerViewState createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
@override
  void initState() {
    super.initState();
    switch (widget.dataSourceType) {
      case DataSourceType.network:
        _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.url));
        break;
      case DataSourceType.asset:
        _videoPlayerController = VideoPlayerController.asset(widget.url);
        break;
      case DataSourceType.file:
        _videoPlayerController = VideoPlayerController.file(File(widget.url));
        break;
      case DataSourceType.contentUri:
        _videoPlayerController = VideoPlayerController.contentUri(Uri.parse(widget.url));
        break;
    }
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: false,
      looping: true,
      autoInitialize: true,
      allowFullScreen: true,
      deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
      deviceOrientationsOnEnterFullScreen: [DeviceOrientation.landscapeLeft],
      placeholder: Container(
        color: Colors.black,
      ),
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            errorMessage,
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }
@override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Chewie(
        controller: _chewieController,
      ),);
  }
}
