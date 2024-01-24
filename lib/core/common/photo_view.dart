import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

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
    double _progress = 0;
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
              FileDownloader.downloadFile(url:  widget.imageUrls[widget.initialIndex], onDownloadError: (e) {
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
              }, onProgress: (fileName, progress) {
                _progress = progress;
              }
              );
              // downloadImage(widget.imageUrls[widget.initialIndex]);
            },
            tooltip: 'Download Image',
            child: const Icon(Icons.download),
          ),
        ],
      ),

    );
  }
}
