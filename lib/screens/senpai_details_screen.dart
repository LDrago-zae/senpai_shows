import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/anime_detail_model.dart';
import 'package:senpai_shows/services/extension_service.dart';
import 'package:senpai_shows/models/source_interface.dart';
import 'package:senpai_shows/screens/senpai_reader.dart';
import 'package:senpai_shows/screens/senpai_stream_v2.dart';

class SenpaiDetailsScreen extends StatefulWidget {
  final AnimeModel anime;
  final bool isFromExtension;
  final String? contentUrl;
  final String? sourceName;

  const SenpaiDetailsScreen({
    super.key,
    required this.anime,
    this.isFromExtension = false,
    this.contentUrl,
    this.sourceName,
  });

  @override
  State<SenpaiDetailsScreen> createState() => _SenpaiDetailsScreenState();
}

class _SenpaiDetailsScreenState extends State<SenpaiDetailsScreen> {
  final ExtensionService _extensionService = ExtensionService();
  List<Episode> _episodes = [];
  List<String> _mangaPages = [];
  bool _isLoadingContent = false;

  @override
  void initState() {
    super.initState();
    _loadExtensionContent();
  }

  @override
  void dispose() {
    _extensionService.dispose();
    super.dispose();
  }

  Future<void> _loadExtensionContent() async {
    setState(() => _isLoadingContent = true);
    try {
      if (widget.isFromExtension) {
        await _extensionService.loadExtensionFromAssets('assets/extensions/sample_source.js');
        if (widget.sourceName != null) {
          await _extensionService.flutterJs.evaluateAsync(
            "source.name = '${widget.sourceName}';"
          );
        }

        if (widget.anime.genre == 'Manga') {
          final pages = await _extensionService.getMangaPages(widget.contentUrl ?? '');
          if (!mounted) return;
          setState(() {
            _mangaPages = pages.map((p) => p.imageUrl).toList();
            _isLoadingContent = false;
          });
        } else {
          final episodes = await _extensionService.getEpisodes(widget.contentUrl ?? '');
          if (!mounted) return;
          setState(() {
            _episodes = episodes;
            _isLoadingContent = false;
          });
        }
      } else {
        // Fallback for homepage items to make them playable/readable
        if (widget.anime.genre.toLowerCase().contains('manga') || widget.anime.genre == 'Manga') {
          if (!mounted) return;
          setState(() {
            _mangaPages = [
              'https://picsum.photos/800/1200?random=11',
              'https://picsum.photos/800/1200?random=12',
              'https://picsum.photos/800/1200?random=13',
              'https://picsum.photos/800/1200?random=14',
              'https://picsum.photos/800/1200?random=15',
            ];
            _isLoadingContent = false;
          });
        } else {
          if (!mounted) return;
          setState(() {
            _episodes = [
              Episode(name: 'Episode 1', url: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8'),
              Episode(name: 'Episode 2', url: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8'),
              Episode(name: 'Episode 3', url: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8'),
              Episode(name: 'Episode 4', url: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8'),
              Episode(name: 'Episode 5', url: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8'),
            ];
            _isLoadingContent = false;
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingContent = false);
    }
  }

  Future<void> _playEpisode(Episode ep) async {
    setState(() => _isLoadingContent = true);
    try {
      String videoUrl = ep.url;
      if (widget.isFromExtension) {
        final videoSources = await _extensionService.getVideoSources(ep.url);
        if (videoSources.isNotEmpty) {
          videoUrl = videoSources.first.url;
        }
      }
      if (!mounted) return;
      setState(() => _isLoadingContent = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SenpaiStreamV2(videoUrl: videoUrl),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingContent = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load video: $e')),
      );
    }
  }

  void _readManga() {
    if (_mangaPages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pages available for this manga.')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SenpaiReader(imageUrls: _mangaPages),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isManga = widget.anime.genre == 'Manga' || widget.anime.genre.toLowerCase().contains('manga');

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
      appBar: AppBar(
        title: Text(
          "Details",
          style: GoogleFonts.urbanist(
            color: const Color(0xffdbe6ff),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.anime.title,
                      style: GoogleFonts.urbanist(
                        color: const Color(0xffdbe6ff),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.more_vert, color: Color(0xffdbe6ff)),
                ],
              ),
              const SizedBox(height: 16),

              // Hero Image (network)
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Hero(
                  tag: widget.anime.imagePath,
                  child: Image.network(
                    widget.anime.imagePath,
                    width: double.infinity,
                    height: 400,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFF1E293B),
                      height: 280,
                      child: const Icon(Icons.broken_image, color: Color(0xffdbe6ff)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title + Genre
              Text(
                widget.anime.title,
                style: GoogleFonts.urbanist(
                  fontSize: 24,
                  color: const Color(0xffdbe6ff),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.anime.genre,
                style: GoogleFonts.urbanist(
                  fontSize: 14,
                  color: const Color(0xffdbe6ff),
                ),
              ),
              const SizedBox(height: 12),

              // Action buttons (Play/Read & My List)
              Row(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      if (isManga) {
                        _readManga();
                      } else {
                        if (_episodes.isNotEmpty) {
                          _playEpisode(_episodes.first);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No episodes available to play.')),
                          );
                        }
                      }
                    },
                    icon: Icon(isManga ? Icons.book : Icons.play_arrow),
                    label: Text(isManga ? "Read" : "Play"),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xffdbe6ff),
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                    label: const Text(
                      "My List",
                      style: TextStyle(color: Color(0xffdbe6ff)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Release Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Release date",
                    style: GoogleFonts.urbanist(
                      color: const Color(0xffdbe6ff),
                      fontSize: 20,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: const Color(0xFF22D3EE),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Color(0xFF22D3EE), width: 1.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    icon: SvgPicture.asset(
                      'assets/icons/dbutton.svg',
                      width: 18,
                      height: 18,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF22D3EE),
                        BlendMode.srcIn,
                      ),
                    ),
                    label: const Text(
                      "Download",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xffdbe6ff),
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                widget.anime.releaseDate,
                style: GoogleFonts.urbanist(
                  color: const Color(0xffdbe6ff),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),

              // Synopsis
              Text(
                "Synopsis",
                style: GoogleFonts.urbanist(
                  color: const Color(0xffdbe6ff),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.anime.synopsis,
                style: GoogleFonts.urbanist(
                  color: const Color(0xffdbe6ff),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 10),

              // Starring
              Text(
                "Starring: ${widget.anime.starring}",
                style: GoogleFonts.urbanist(
                  color: const Color(0xffdbe6ff),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),

              // Dynamic episodes or reading section
              _buildExtensionContentView(isManga),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExtensionContentView(bool isManga) {
    if (_isLoadingContent) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: CircularProgressIndicator(color: Color(0xFF22D3EE)),
        ),
      );
    }

    if (isManga) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Manga Content",
            style: GoogleFonts.urbanist(
              color: const Color(0xffdbe6ff),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _readManga,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF22D3EE).withValues(alpha: 0.5)),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF22D3EE).withValues(alpha: 0.2),
                    const Color(0xFF0F172A).withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.book, color: Color(0xFF22D3EE)),
                  const SizedBox(width: 10),
                  Text(
                    "START READING (${_mangaPages.length} PAGES)",
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Anime episodes
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Episodes",
          style: GoogleFonts.urbanist(
            color: const Color(0xffdbe6ff),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _episodes.isEmpty
            ? Text(
                "No episodes listed.",
                style: GoogleFonts.urbanist(color: Colors.white54, fontSize: 14),
              )
            : SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _episodes.length,
                  itemBuilder: (context, index) {
                    final ep = _episodes[index];
                    return GestureDetector(
                      onTap: () => _playEpisode(ep),
                      child: Container(
                        width: 140,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF22D3EE).withValues(alpha: 0.4)),
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF22D3EE).withValues(alpha: 0.15),
                              const Color(0xFF0F172A),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            ep.name,
                            style: GoogleFonts.urbanist(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }
}
