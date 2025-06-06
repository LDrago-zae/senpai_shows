import 'dart:async';

import 'package:flutter/material.dart';

import 'package:senpai_shows/components/anime_particle_background.dart';
import 'package:senpai_shows/components/custom_bottom_nav.dart';
import 'package:senpai_shows/services/anilist_service.dart';
import 'package:senpai_shows/services/shikimori_service.dart';

import '../components/bento_grid.dart';
import '../components/featured_banner.dart';
import '../models/anime_model.dart';

class SenpaiHome extends StatefulWidget {
  const SenpaiHome({super.key});

  @override
  State<SenpaiHome> createState() => _SenpaiHomeState();
}

class _SenpaiHomeState extends State<SenpaiHome> {
  int _selectedIndex = 0;
  final AniListApiService _aniListService = AniListApiService();

  late Future<List<Anime>> popularAnimeFuture;
  late Future<List<Anime>> recentAnimeFuture;

  List<Anime>? _cachedPopularAnime;
  List<Anime>? _cachedRecentAnime;

  @override
  void initState() {
    super.initState();
    recentAnimeFuture = _fetchAndCacheRecentAnime();
    popularAnimeFuture = _fetchAndCachePopularAnime();
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
    return fetchedAnime;
  }

  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      body: SafeArea(
        child: CosmicGlassmorphicContainer(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // FeaturedBanner replaces the carousel section
                FeaturedBanner(fetchAnime: recentAnimeFuture),

                // Trending Header
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Trending',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'See all',
                        style: TextStyle(color: Colors.tealAccent),
                      ),
                    ],
                  ),
                ),

                // Trending horizontal list
                SizedBox(
                  height: 220,
                  child: FutureBuilder<List<Anime>>(
                    future: popularAnimeFuture,
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
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
                                        gradient: LinearGradient(
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
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 4,
                                      ),
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
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'For You',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // For You Bento-Style Grid
                FutureBuilder<List<Anime>>(
                  future: recentAnimeFuture,
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
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          gradient: LinearGradient(
            colors: [
              const Color(0xff9DB2CE).withAlpha(128),
              const Color(0xff9DB2CE).withAlpha(153),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(64),
            bottom: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: CustomBottomNav(
          selectedIndex: _selectedIndex,
          onItemTapped: onItemTapped,
        ),
      ),
    );
  }
}
