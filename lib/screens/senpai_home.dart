import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:senpai_shows/components/anime_particle_background.dart';
import 'package:senpai_shows/components/custom_bottom_nav.dart';
import 'package:senpai_shows/components/featured_banner.dart';
import 'package:senpai_shows/components/bento_grid.dart';
import 'package:senpai_shows/models/anime_model.dart';
import 'package:senpai_shows/screens/senpai_search.dart';
import 'package:senpai_shows/services/anilist_service.dart';
import 'package:senpai_shows/services/shikimori_service.dart';
import 'package:senpai_shows/services/kitsu_service.dart';

import '../controllers/randome_anime_controller.dart';

class SenpaiHome extends StatefulWidget {
  const SenpaiHome({super.key});

  @override
  State<SenpaiHome> createState() => _SenpaiHomeState();
}

class _SenpaiHomeState extends State<SenpaiHome> {
  int _selectedIndex = 0;
  final AniListApiService _aniListService = AniListApiService();
  final ShikimoriApiService _shikimoriService = ShikimoriApiService();
  final KitsuApiService _kitsuService = KitsuApiService();
  final ScrollController _scrollController = ScrollController();
  final RandomAnimeController _randomAnimeController = RandomAnimeController();

  late Future<List<Anime>> popularAnimeFuture;
  late Future<List<Anime>> recentAnimeFuture;
  late Future<List<Anime>> shikimoriPopularAnimeFuture;
  late Future<List<Anime>> shikimoriRecentAnimeFuture;

  List<Anime>? _cachedPopularAnime;
  List<Anime>? _cachedRecentAnime;
  List<Anime>? _cachedShikimoriPopularAnime;
  List<Anime>? _cachedShikimoriRecentAnime;

  // Random anime state
  Anime? _randomAnime;
  bool _loadingRandomAnime = false;
  String? _randomAnimeError;

  @override
  void initState() {
    super.initState();
    recentAnimeFuture = _fetchAndCacheRecentAnime();
    popularAnimeFuture = _fetchAndCachePopularAnime();
    shikimoriPopularAnimeFuture = _fetchAndCacheShikimoriPopularAnime();
    shikimoriRecentAnimeFuture = _fetchAndCacheShikimoriRecentAnime();

    // Scroll to the bottom after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<List<Anime>> _fetchAndCachePopularAnime() async {
    if (_cachedPopularAnime != null) {
      return _cachedPopularAnime!;
    }
    final fetchedAnime = await _aniListService.fetchPopularAnime(perPage: 15);
    _cachedPopularAnime = fetchedAnime;
    return fetchedAnime;
  }

  Future<List<Anime>> _fetchAndCacheRecentAnime() async {
    if (_cachedRecentAnime != null) {
      return _cachedRecentAnime!;
    }
    final fetchedAnime = await _aniListService.fetchRecentAnime(perPage: 15);
    _cachedRecentAnime = fetchedAnime;
    return fetchedAnime;
  }

  Future<List<Anime>> _fetchAndCacheShikimoriPopularAnime() async {
    if (_cachedShikimoriPopularAnime != null) {
      return _cachedShikimoriPopularAnime!;
    }
    final fetchedAnime = await _shikimoriService.fetchPopularAnime(limit: 15);
    _cachedShikimoriPopularAnime = fetchedAnime;
    return fetchedAnime;
  }

  Future<List<Anime>> _fetchAndCacheShikimoriRecentAnime() async {
    if (_cachedShikimoriRecentAnime != null) {
      return _cachedShikimoriRecentAnime!;
    }
    final fetchedAnime = await _shikimoriService.fetchRecentAnime(limit: 15);
    _cachedShikimoriRecentAnime = fetchedAnime;
    return fetchedAnime;
  }

  Future<void> _fetchRandomAnime() async {
    setState(() {
      _loadingRandomAnime = true;
      _randomAnimeError = null;
    });

    try {
      final anime = await _randomAnimeController.fetchRandomAnime();
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
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Stack(
        children: [
          const LightBlackGlassmorphicContainer(
            blurStrength: 6.0,
            borderRadius: 16.0,
            padding: EdgeInsets.all(16.0),
            child: SizedBox.expand(),
          ),
          SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.only(bottom: 80.0),
            child: Column(
              children: [
                FeaturedBanner(
                  fetchAnime: _kitsuService.fetchTopAiringAnime(
                    limit: 5,
                  ),
                ),
                const SizedBox(height: 16),

                // Random Anime Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                  child: ElevatedButton(
                    onPressed: _loadingRandomAnime ? null : _fetchRandomAnime,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent.withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                      side: BorderSide(color: Colors.tealAccent.withOpacity(0.5)),
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
                    child: CircularProgressIndicator(color: Colors.tealAccent),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Trending',
                        style: GoogleFonts.urbanist(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
                SizedBox(
                  height: 220,
                  child: FutureBuilder<List<Anime>>(
                    future: _kitsuService.fetchTopAiringAnime(limit: 10),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      final animeList = snapshot.data!;
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: animeList.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemBuilder: (context, index) {
                          final anime = animeList[index];
                          return Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 130,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Stack(
                                children: [
                                  Image.network(
                                    anime.imageUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        gradient:LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.8),
                                          ],
                                        ),
                                      ),
                                      child: Text(
                                        anime.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    left: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.tealAccent,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                // For You Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'For You',
                      style: GoogleFonts.urbanist(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // For You Bento-Style Grid
                FutureBuilder<List<Anime>>(
                  future: _kitsuService.fetchAnimeList(limit: 12),
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

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
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
            Image.network(
              anime.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 250,
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
                      color: Colors.white,
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
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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