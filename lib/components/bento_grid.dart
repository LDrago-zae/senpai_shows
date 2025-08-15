import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/anime_detail_model.dart';
import '../models/anime_model.dart';
import '../screens/senpai_details_screen.dart';

class BentoGrid extends StatefulWidget {
  final List<Anime> animeList;

  const BentoGrid({super.key, required this.animeList});

  @override
  _BentoGridState createState() => _BentoGridState();
}

class _BentoGridState extends State<BentoGrid> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _opacityAnimations;

  @override
  void initState() {
    super.initState();
    // Initialize animation controllers for each card
    _controllers = List.generate(
      widget.animeList.length,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 500 + index * 100),
      ),
    );
    _scaleAnimations =
        _controllers
            .map(
              (controller) => Tween<double>(begin: 0.8, end: 1.0).animate(
                CurvedAnimation(parent: controller, curve: Curves.easeOutBack),
              ),
            )
            .toList();
    _opacityAnimations =
        _controllers
            .map(
              (controller) => Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(parent: controller, curve: Curves.easeIn),
              ),
            )
            .toList();

    // Start animations
    for (var controller in _controllers) {
      controller.forward();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.animeList.length < 6) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.65,
        ),
        itemCount: widget.animeList.length,
        itemBuilder: (context, index) {
          return _buildAnimeCard(context, widget.animeList[index], index);
        },
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 200,
                child: _buildAnimeCard(context, widget.animeList[0], 0),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 200,
                child: _buildAnimeCard(context, widget.animeList[1], 1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: SizedBox(
                height: 280,
                child: _buildAnimeCard(context, widget.animeList[2], 2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  SizedBox(
                    height: 134,
                    child: _buildAnimeCard(context, widget.animeList[3], 3),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 134,
                    child: _buildAnimeCard(context, widget.animeList[4], 4),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 160,
                child: _buildAnimeCard(
                  context,
                  widget.animeList[5 % widget.animeList.length],
                  5,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 160,
                child: _buildAnimeCard(
                  context,
                  widget.animeList[6 % widget.animeList.length],
                  6,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 160,
                child: _buildAnimeCard(
                  context,
                  widget.animeList[7 % widget.animeList.length],
                  7,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnimeCard(BuildContext context, Anime anime, int index) {
    return AnimatedBuilder(
      animation: _controllers[index % _controllers.length],
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimations[index % _controllers.length].value,
          child: Opacity(
            opacity: _opacityAnimations[index % _controllers.length].value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => SenpaiDetailsScreen(
                    anime: AnimeModel(
                      title: anime.title,
                      genre: anime.genre ?? 'Unknown',
                      imagePath: anime.imageUrl,
                      synopsis: anime.synopsis ?? 'No synopsis available.',
                      releaseDate: anime.releaseDate ?? 'Unknown',
                      starring: anime.starring ?? 'N/A',
                    ),
                  ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.tealAccent.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // Background Image with Blur
                CachedNetworkImage(
                  imageUrl: anime.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  placeholder:
                      (context, url) => Container(
                        color: Colors.black12,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.tealAccent,
                          ),
                        ),
                      ),
                  errorWidget:
                      (context, url, error) => Container(
                        color: Colors.black12,
                        child: const Icon(Icons.error, color: Colors.redAccent),
                      ),
                ),
                // Glassmorphic Overlay
                Container(color: Colors.black.withOpacity(0.3)),
                // Content
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Title
                      Text(
                        anime.title,
                        style: GoogleFonts.urbanist(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Genre
                      if (anime.genre != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.tealAccent.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            anime.genre!,
                            style: GoogleFonts.urbanist(
                              fontSize: 12,
                              color: Colors.tealAccent,
                            ),
                          ),
                        ),
                      const SizedBox(height: 4),
                      // Release Date
                      if (anime.releaseDate != null)
                        Text(
                          anime.releaseDate!,
                          style: GoogleFonts.urbanist(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
