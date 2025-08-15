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
import 'package:senpai_shows/screens/senpai_details_screen.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'dart:typed_data';
import '../components/trending_cards.dart';
import '../models/anime_detail_model.dart';

class SenpaiHome extends StatefulWidget {
  const SenpaiHome({super.key});

  @override
  State<SenpaiHome> createState() => _SenpaiHomeState();
}

class _SenpaiHomeState extends State<SenpaiHome> with SingleTickerProviderStateMixin {
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
    // Initialize futures
    popularAnimeFuture = _homeController.fetchPopularAnime();
    recentAnimeFuture = _homeController.fetchRecentAnime();
    shikimoriPopularAnimeFuture = _homeController.fetchShikimoriPopularAnime();
    shikimoriRecentAnimeFuture = _homeController.fetchShikimoriRecentAnime();
    featuredAnimeFuture = _homeController.fetchFeaturedAnime();

    // Scroll to the top after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
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
      backgroundColor: const Color.fromARGB(38, 10, 10, 255),
      extendBody: true,
      body: Stack(
        children: [
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
                        backgroundColor: const Color.fromARGB(18, 20, 25, 255),
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
                      RandomAnimeCard(
                        anime: _randomAnime!,
                        index: 0, // Single card
                      ),

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
                            color: const Color(0xffdbe6ff),
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
                          color: const Color(0xffdbe6ff),
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
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: animeList.length,
                          itemBuilder: (context, index) {
                            final Anime anime = animeList[index];
                            return SenpaiAnimeCard(
                              index: index,
                              anime: anime,
                            );
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

// Updated SenpaiAnimeCard with visibility-based animation
class SenpaiAnimeCard extends StatefulWidget {
  final Anime anime;
  final int index;

  const SenpaiAnimeCard({
    super.key,
    required this.anime,
    required this.index,
  });

  @override
  State<SenpaiAnimeCard> createState() => _SenpaiAnimeCardState();
}

class _SenpaiAnimeCardState extends State<SenpaiAnimeCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          widget.index * 0.08,
          (widget.index * 0.08) + 0.28,
          curve: Curves.easeOut,
        ),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          widget.index * 0.08,
          (widget.index * 0.08) + 0.28,
          curve: Curves.easeOut,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('anime_card_${widget.anime.id}'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.5 && !_animationController.isAnimating && !_animationController.isCompleted) {
          _animationController.forward();
        }
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: child,
            ),
          );
        },
        child: _buildAnimeCard(context),
      ),
    );
  }

  Widget _buildAnimeCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SenpaiDetailsScreen(
              anime: AnimeModel(
                title: widget.anime.title,
                genre: widget.anime.genre ?? 'Unknown',
                imagePath: widget.anime.imageUrl,
                synopsis: widget.anime.synopsis ?? 'No synopsis available.',
                releaseDate: widget.anime.releaseDate ?? 'Unknown',
                starring: widget.anime.starring ?? 'N/A',
              ),
            ),
          ),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.tealAccent.withOpacity(0.5),
            width: 1,
          ),
          color: const Color.fromARGB(18, 20, 25, 255),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 5, bottom: 5),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedOrNetworkImage(
                  id: widget.anime.id.toString(),
                  imageUrl: widget.anime.imageUrl,
                  width: 150,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 150,
                    height: 200,
                    color: Colors.grey[800],
                    child: const Icon(Icons.broken_image, color: Colors.grey, size: 50),
                  ),
                ),
              ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Badge
                    if (widget.anime.status != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: widget.anime.status == 'Airing'
                                ? Colors.green
                                : widget.anime.status == 'Finished'
                                ? Colors.blue
                                : Colors.red,
                          ),
                        ),
                        child: Text(
                          widget.anime.status!,
                          style: GoogleFonts.urbanist(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    const SizedBox(height: 6),
                    // Title
                    Text(
                      widget.anime.title,
                      style: GoogleFonts.urbanist(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Episodes + Release Date
                    Row(
                      children: [
                        if (widget.anime.releaseDate != null)
                          Text(
                            widget.anime.releaseDate!,
                            style: GoogleFonts.urbanist(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                        if (widget.anime.episodes != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '${widget.anime.episodes} eps',
                            style: GoogleFonts.urbanist(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Rating + Rank
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          widget.anime.rating?.toString() ?? 'N/A',
                          style: GoogleFonts.urbanist(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        if (widget.anime.rank != null) ...[
                          const SizedBox(width: 12),
                          Text(
                            '#${widget.anime.rank}',
                            style: GoogleFonts.urbanist(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Genre Tags
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: (widget.anime.genre != null
                          ? widget.anime.genre!.split(',').map((g) => g.trim()).toList()
                          : [])
                          .map((genre) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.tealAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            genre,
                            style: GoogleFonts.urbanist(
                              fontSize: 12,
                              color: Colors.tealAccent,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Updated RandomAnimeCard with visibility-based animation
class RandomAnimeCard extends StatefulWidget {
  final Anime anime;
  final int index;

  const RandomAnimeCard({
    super.key,
    required this.anime,
    required this.index,
  });

  @override
  State<RandomAnimeCard> createState() => _RandomAnimeCardState();
}

class _RandomAnimeCardState extends State<RandomAnimeCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          widget.index * 0.08,
          (widget.index * 0.08) + 0.28,
          curve: Curves.easeOut,
        ),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          widget.index * 0.08,
          (widget.index * 0.08) + 0.28,
          curve: Curves.easeOut,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('random_anime_card_${widget.anime.id}'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.5 && !_animationController.isAnimating && !_animationController.isCompleted) {
          _animationController.forward();
        }
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: child,
            ),
          );
        },
        child: _buildRandomAnimeCard(context),
      ),
    );
  }

  Widget _buildRandomAnimeCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SenpaiDetailsScreen(
              anime: AnimeModel(
                title: widget.anime.title,
                genre: widget.anime.genre ?? 'Unknown',
                imagePath: widget.anime.imageUrl,
                synopsis: widget.anime.synopsis ?? 'No synopsis available.',
                releaseDate: widget.anime.releaseDate ?? 'Unknown',
                starring: widget.anime.starring ?? 'N/A',
              ),
            ),
          ),
        );
      },
      child: Container(
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
                id: widget.anime.id.toString(),
                imageUrl: widget.anime.imageUrl,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.5),
                colorBlendMode: BlendMode.darken,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: double.infinity,
                  height: 250,
                  color: Colors.grey[800],
                  child: const Icon(Icons.broken_image, color: Colors.grey, size: 50),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      widget.anime.title,
                      style: GoogleFonts.urbanist(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xffdbe6ff),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Description
                    Text(
                      widget.anime.synopsis ?? 'No synopsis available.',
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
                        if (widget.anime.genre != null)
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
                              widget.anime.genre!,
                              style: GoogleFonts.urbanist(
                                fontSize: 12,
                                color: Colors.tealAccent,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        if (widget.anime.releaseDate != null)
                          Text(
                            widget.anime.releaseDate!,
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
      ),
    );
  }
}

// CachedOrNetworkImage (unchanged from your original)
Widget CachedOrNetworkImage({
  required String id,
  required String imageUrl,
  double? width,
  double? height,
  BoxFit? fit,
  Color? color,
  BlendMode? colorBlendMode,
  Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
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
        return Image.memory(
          snapshot.data!,
          width: width,
          height: height,
          fit: fit,
          color: color,
          colorBlendMode: colorBlendMode,
        );
      } else {
        return Image.network(
          imageUrl,
          width: width,
          height: height,
          fit: fit,
          color: color,
          colorBlendMode: colorBlendMode,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
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
          errorBuilder: errorBuilder ??
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