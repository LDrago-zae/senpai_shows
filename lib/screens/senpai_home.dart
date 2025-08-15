import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:senpai_shows/components/anime_particle_background.dart';
import 'package:senpai_shows/components/featured_banner.dart';
import 'package:senpai_shows/components/bento_grid.dart';
import 'package:senpai_shows/components/senpai_anime_card.dart';
import 'package:senpai_shows/controllers/home_controller.dart';
import 'package:senpai_shows/models/anime_model.dart';
import 'package:senpai_shows/database/image_cache_helper.dart';
import 'dart:typed_data';

import '../components/trending_cards.dart';

class SenpaiHome extends StatefulWidget {
  const SenpaiHome({super.key});

  @override
  State<SenpaiHome> createState() => _SenpaiHomeState();
}

class _SenpaiHomeState extends State<SenpaiHome> {
  final HomeController _homeController = HomeController();
  final ScrollController _scrollController = ScrollController();

  late Future<List<Anime>> popularAnimeFuture;
  late Future<List<Anime>> recentAnimeFuture;
  late Future<List<Anime>> shikimoriPopularAnimeFuture;
  late Future<List<Anime>> shikimoriRecentAnimeFuture;
  late Future<List<Anime>> featuredAnimeFuture;

  // Random anime state
  Anime? _randomAnime;
  bool _loadingRandomAnime = false;
  String? _randomAnimeError;

  @override
  void initState() {
    super.initState();
    popularAnimeFuture = _homeController.fetchPopularAnime();
    recentAnimeFuture = _homeController.fetchRecentAnime();
    shikimoriPopularAnimeFuture = _homeController.fetchShikimoriPopularAnime();
    shikimoriRecentAnimeFuture = _homeController.fetchShikimoriRecentAnime();
    featuredAnimeFuture = _homeController.fetchFeaturedAnime();

    // Scroll to the bottom after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0); // Start from top
      }
      // if (_scrollController.hasClients) {
      //   _scrollController.animateTo(
      //     _scrollController.position.maxScrollExtent,
      //     duration: const Duration(milliseconds: 300),
      //     curve: Curves.easeInOut,
      //   );
      // }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _homeController.dispose();
    super.dispose();
  }

  Future<void> _fetchRandomAnime() async {
    setState(() {
      _loadingRandomAnime = true;
      _randomAnimeError = null;
    });

    try {
      final anime = await _homeController.fetchRandomAnime();
      setState(() {
        _randomAnime = anime;
        _loadingRandomAnime = false;
      });
    } catch (e) {
      setState(() {
        _randomAnimeError = e.toString();
        _loadingRandomAnime = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(38, 10, 10, 255),
      extendBody: true,
      body: Stack(
        children: [
          // const LightBlackGlassmorphicContainer(
          //   blurStrength: 16.0,
          //   borderRadius: 16.0,
          //   padding: EdgeInsets.all(16.0),
          //   child: SizedBox.expand(),
          // ),
          SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.only(bottom: 30.0),
            child: SafeArea(
              child: Column(
                children: [
                  FeaturedBanner(
                    fetchAnime: _homeController.fetchRecentAnime(),
                  ),
                  const SizedBox(height: 16),

                  // Random Anime Button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12,
                    ),
                    child: ElevatedButton(
                      onPressed: _loadingRandomAnime ? null : _fetchRandomAnime,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(18, 20, 25, 255),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                        side: BorderSide(
                          color: Colors.tealAccent.withOpacity(0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.shuffle, color: Colors.tealAccent),
                          const SizedBox(width: 8),
                          Text(
                            'Randomize Your Show Today',
                            style: GoogleFonts.urbanist(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.tealAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Random Anime Card
                  if (_loadingRandomAnime)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(
                        color: Colors.tealAccent,
                      ),
                    )
                  else if (_randomAnimeError != null)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _randomAnimeError!,
                        style: GoogleFonts.urbanist(
                          color: Colors.redAccent,
                          fontSize: 14,
                        ),
                      ),
                    )
                  else if (_randomAnime != null)
                    RandomAnimeCard(anime: _randomAnime!),

                  // Trending Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Trending',
                          style: GoogleFonts.urbanist(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xffdbe6ff),
                          ),
                        ),
                        Text(
                          'See all',
                          style: GoogleFonts.urbanist(
                            color: Colors.tealAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Trending horizontal list
                  TrendingCards(),
                  // For You Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'For You',
                        style: GoogleFonts.urbanist(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xffdbe6ff),
                        ),
                      ),
                    ),
                  ),

                  // For You Bento-Style Grid
                  FutureBuilder<List<Anime>>(
                    future: _homeController.fetchForYouAnime(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      final animeList = snapshot.data!;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: BentoGrid(animeList: animeList),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // For You Anime Cards
                  FutureBuilder<List<Anime>>(
                    future: _homeController.fetchTrendingAnime(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          // Add some vertical padding
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.tealAccent,
                            ),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: Text(
                              'Failed to load "For You" anime: ${snapshot.error}',
                              style: GoogleFonts.urbanist(
                                color: Colors.redAccent,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: Text(
                              'No "For You" anime available.',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        );
                      }

                      final List<Anime> animeList = snapshot.data!;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ListView.builder(
                          shrinkWrap: true,
                          // Crucial for nested scrolling
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: animeList.length,
                          itemBuilder: (context, index) {
                            final Anime anime = animeList[index];
                            return SenpaiAnimeCard(
                              anime: anime,
                            ); // Use your new card widget
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper widget to use cached or network image
Widget CachedOrNetworkImage({
  required String id,
  required String imageUrl,
  double? width,
  double? height,
  BoxFit? fit,
  Color? color,
  BlendMode? colorBlendMode,
}) {
  return FutureBuilder<Uint8List?>(
    future: ImageCacheHelper().getCachedImage(id),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Container(
          width: width,
          height: height,
          color: Colors.black12,
          child: const Center(child: CircularProgressIndicator()),
        );
      } else if (snapshot.hasData && snapshot.data != null) {
        // Cached image found
        return Image.memory(
          snapshot.data!,
          width: width,
          height: height,
          fit: fit,
          color: color,
          colorBlendMode: colorBlendMode,
        );
      } else {
        // Not cached, load from network and cache it
        return Image.network(
          imageUrl,
          width: width,
          height: height,
          fit: fit,
          color: color,
          colorBlendMode: colorBlendMode,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              // Cache the image after it's loaded
              ImageCacheHelper().cacheImage(id, imageUrl);
              return child;
            }
            return Container(
              width: width,
              height: height,
              color: Colors.black12,
              child: const Center(child: CircularProgressIndicator()),
            );
          },
          errorBuilder:
              (context, error, stackTrace) => Container(
                width: width,
                height: height,
                color: Colors.grey,
                child: const Icon(Icons.broken_image),
              ),
        );
      }
    },
  );
}

// Random Anime Card Widget
class RandomAnimeCard extends StatelessWidget {
  final Anime anime;

  const RandomAnimeCard({super.key, required this.anime});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black.withOpacity(0.3),
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
            CachedOrNetworkImage(
              id: anime.id.toString(),
              imageUrl: anime.imageUrl,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.5),
              colorBlendMode: BlendMode.darken,
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    anime.title,
                    style: GoogleFonts.urbanist(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xffdbe6ff),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Description
                  Text(
                    anime.synopsis ?? 'No synopsis available.',
                    style: GoogleFonts.urbanist(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Genre and Release Date
                  Row(
                    children: [
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
                      const SizedBox(width: 8),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
