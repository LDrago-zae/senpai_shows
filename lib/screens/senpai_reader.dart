import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:preload_page_view/preload_page_view.dart';

class SenpaiReader extends StatefulWidget {
  final List<String> imageUrls;

  // Future: Mode could be Webtoon, LTR, RTL
  final String mode;

  const SenpaiReader({
    super.key,
    required this.imageUrls,
    this.mode = 'webtoon',
  });

  @override
  State<SenpaiReader> createState() => _SenpaiReaderState();
}

class _SenpaiReaderState extends State<SenpaiReader> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Manga Reader'),
        backgroundColor: Colors.black87,
      ),
      body:
          widget.mode == 'webtoon'
              ? _buildWebtoonReader()
              : _buildPaginatedReader(),
    );
  }

  Widget _buildWebtoonReader() {
    return ListView.builder(
      itemCount: widget.imageUrls.length,
      itemBuilder: (context, index) {
        return ExtendedImage.network(
          widget.imageUrls[index],
          fit: BoxFit.contain,
          mode: ExtendedImageMode.gesture,
          initGestureConfigHandler: (state) {
            return GestureConfig(
              minScale: 0.9,
              animationMinScale: 0.7,
              maxScale: 3.0,
              animationMaxScale: 3.5,
              speed: 1.0,
              inertialSpeed: 100.0,
              initialScale: 1.0,
              inPageView: false,
            );
          },
        );
      },
    );
  }

  Widget _buildPaginatedReader() {
    return PreloadPageView.builder(
      itemCount: widget.imageUrls.length,
      reverse: widget.mode == 'rtl',
      itemBuilder: (context, index) {
        return InteractiveViewer(
          child: ExtendedImage.network(
            widget.imageUrls[index],
            fit: BoxFit.contain,
          ),
        );
      },
    );
  }
}
