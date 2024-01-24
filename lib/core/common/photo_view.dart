import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class ImageZoomScreen extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;


  const ImageZoomScreen({
    Key? key,
    required this.imageUrls,
    required this.initialIndex,
  }) : super(key: key);

  @override
  _ImageZoomScreenState createState() => _ImageZoomScreenState();
}

class _ImageZoomScreenState extends State<ImageZoomScreen> {
  bool isZoomed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: GestureDetector(
        onDoubleTap: () {
          setState(() {
            isZoomed = !isZoomed;
          });
        },
        child: PhotoViewGallery.builder(
          itemCount: widget.imageUrls.length,
          builder: (context, index) {
            return PhotoViewGalleryPageOptions(
              imageProvider: NetworkImage(widget.imageUrls[index]),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
            );
          },
          scrollPhysics: const BouncingScrollPhysics(),
          backgroundDecoration: const BoxDecoration(
            color: Colors.black,
          ),
          pageController: PageController(initialPage: widget.initialIndex),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          downloadImage(widget.imageUrls[widget.initialIndex]);
        },
        tooltip: 'Download Image',
        child: const Icon(Icons.download),
      ),
    );
  }

  Future<void> downloadImage(String imageUrl) async {
    // Capture the context before entering the asynchronous code
    final context = this.context;

    Dio dio = Dio();
    try {
      final response = await dio.get(imageUrl, options: Options(responseType: ResponseType.bytes));

      final externalDir = await getDownloadsDirectory();
      final filePath = '${externalDir!.path}/downloaded_image.jpg';

      File file = File(filePath);
      await file.writeAsBytes(response.data);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File saved at: $filePath'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download image: $e'),
        ),
      );
    }
  }
}
