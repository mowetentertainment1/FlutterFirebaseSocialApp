import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageZoomScreen extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const ImageZoomScreen({
    super.key,
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  _ImageZoomScreenState createState() => _ImageZoomScreenState();
}

class _ImageZoomScreenState extends State<ImageZoomScreen> {
  bool isZoomed = false;
  int currentIndex = 0;
  late PageController pageController;
  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: widget.initialIndex);
    currentIndex = widget.initialIndex;
  }
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
          pageController: pageController,
          onPageChanged: (index) {
            setState(() {
              currentIndex = index;
            });
          },
        ),

      ),

  
      floatingActionButton: Row(
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

          FloatingActionButton(
            onPressed: () {
              FileDownloader.downloadFile(url:  widget.imageUrls[currentIndex], onDownloadError: (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to download image: $e'),
                  ),
                );
              }, onDownloadCompleted: (String path) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('File saved at: $path'),
                    ));
              }
              );
              // downloadImage(widget.imageUrls[widget.initialIndex]);
            },
            tooltip: 'Download Image',
            child: const Icon(Icons.download),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () {
              navigateToNextImage();
            },
            tooltip: 'Next Image',
            child: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }

  void navigateToNextImage() {
    final nextIndex = currentIndex + 1;
    if (nextIndex < widget.imageUrls.length) {
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
