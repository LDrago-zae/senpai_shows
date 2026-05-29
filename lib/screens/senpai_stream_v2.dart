import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class SenpaiStreamV2 extends StatefulWidget {
  final String videoUrl;

  const SenpaiStreamV2({super.key, required this.videoUrl});

  @override
  State<SenpaiStreamV2> createState() => _SenpaiStreamV2State();
}

class _SenpaiStreamV2State extends State<SenpaiStreamV2> {
  late final Player player = Player();
  late final VideoController controller = VideoController(player);

  @override
  void initState() {
    super.initState();
    player.open(Media(widget.videoUrl));
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Aniyomi-Style Player'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Video(
          controller: controller,
          // Custom controls can be built here for Aniyomi-like player overlay
        ),
      ),
    );
  }
}
