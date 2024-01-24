import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageZoomScreen extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const ImageZoomScreen({super.key, required this.imageUrls, required this.initialIndex});

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
          setState(() {
            isZoomed = !isZoomed;
          });
        },
        tooltip: isZoomed ? 'Zoom out' : 'Zoom in',
        child: Icon(isZoomed ? Icons.zoom_out : Icons.zoom_in),
      ),
    );
  }
}
