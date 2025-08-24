import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:senpai_shows/screens/genre_anime_screen.dart';
import 'package:senpai_shows/screens/senpai_details_screen.dart';
import 'package:senpai_shows/models/anime_model.dart';
import 'package:senpai_shows/models/anime_detail_model.dart';
import 'package:senpai_shows/controllers/home_controller.dart';
import 'package:senpai_shows/screens/senpai_home.dart';
import 'dart:async';

class SenpaiSearch extends StatefulWidget {
  final ValueNotifier<int> tabNotifier;

  const SenpaiSearch({super.key, required this.tabNotifier});

  @override
  State<SenpaiSearch> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SenpaiSearch>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final HomeController _homeController = HomeController();

  late AnimationController _animationController;
  late List<Animation<double>> _opacityAnimations;
  late List<Animation<double>> _slideAnimations;
  late VoidCallback _tabListener;

  List<Anime> _searchResults = [];
  bool _isSearching = false;
  bool _showSearchResults = false;
  Timer? _debounceTimer;

  final List<Map<String, dynamic>> _genres = [
    {
      'name': 'Action',
      'imageAsset': 'assets/senpaiAssets/solo2.png',
      'color': Colors.transparent,
    },
    {
      'name': 'Adventure',
      'imageAsset': 'assets/senpaiAssets/op.png',
      'color': Colors.transparent,
    },
    {
      'name': 'Comedy',
      'imageAsset': 'assets/senpaiAssets/dd.png',
      'color': Colors.transparent,
    },
    {
      'name': 'Drama',
      'imageAsset': 'assets/senpaiAssets/cg.jpg',
      'color': Colors.transparent,
    },
    {
      'name': 'Fantasy',
      'imageAsset': 'assets/senpaiAssets/rz.png',
      'color': Colors.transparent,
    },
    {
      'name': 'Horror',
      'imageAsset': 'assets/senpaiAssets/tg.jpg',
      'color': Colors.transparent,
    },
    {
      'name': 'Mystery',
      'imageAsset': 'assets/senpaiAssets/er.jpg',
      'color': Colors.transparent,
    },
    {
      'name': 'Romance',
      'imageAsset': 'assets/senpaiAssets/dm.jpg',
      'color': Colors.transparent,
    },
    {
      'name': 'Sci-Fi',
      'imageAsset': 'assets/senpaiAssets/sg.jpg',
      'color': Colors.transparent,
    },
    {
      'name': 'Slice of Life',
      'imageAsset': 'assets/senpaiAssets/fr.jpg',
      'color': Colors.transparent,
    },
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _opacityAnimations = List.generate(
      _genres.length,
          (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.08,
            (index * 0.08) + 0.28,
            curve: Curves.easeOut,
          ),
        ),
      ),
    );

    _slideAnimations = List.generate(
      _genres.length,
          (index) => Tween<double>(begin: 50.0, end: 0.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.08,
            (index * 0.08) + 0.28,
            curve: Curves.easeOut,
          ),
        ),
      ),
    );

    _tabListener = () {
      if (widget.tabNotifier.value == 1) {
        _triggerAnimation();
      }
    };

    widget.tabNotifier.addListener(_tabListener);

    // Start animation initially if this screen is first
    if (widget.tabNotifier.value == 1) {
      _triggerAnimation();
    }

    // Add search listener
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onFocusChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();

    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (query.isEmpty) {
        setState(() {
          _showSearchResults = false;
          _searchResults = [];
          _isSearching = false;
        });
      } else if (query.length >= 2) {
        _performSearch(query);
      }
    });
  }

  void _onFocusChanged() {
    if (!_searchFocusNode.hasFocus && _searchController.text.isEmpty) {
      setState(() {
        _showSearchResults = false;
      });
    }
  }

  Future<void> _performSearch(String query) async {
    if (!mounted) return;

    setState(() {
      _isSearching = true;
      _showSearchResults = true;
    });

    try {
      final results = await _homeController.searchAnime(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
      print('Search error: $e');
    }
  }

  void _triggerAnimation() {
    _animationController.reset();
    _animationController.forward();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _animationController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _homeController.dispose();
    widget.tabNotifier.removeListener(_tabListener);
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      color: const Color.fromARGB(38, 10, 10, 255),
      child: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  style: GoogleFonts.urbanist(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search anime...',
                    hintStyle: GoogleFonts.urbanist(color: Colors.grey[400]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _showSearchResults = false;
                          _searchResults = [];
                        });
                      },
                    )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                  ),
                ),
              ),
            ),

            // Content Area
            Expanded(
              child: _showSearchResults ? _buildSearchResults() : _buildGenreGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.tealAccent),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              'No anime found',
              style: GoogleFonts.urbanist(
                color: Colors.grey[400],
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term',
              style: GoogleFonts.urbanist(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 70),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final anime = _searchResults[index];
        return _buildSearchResultCard(anime);
      },
    );
  }

  Widget _buildSearchResultCard(Anime anime) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(18, 20, 25, 255),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.tealAccent.withOpacity(0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SenpaiDetailsScreen(
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
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Anime Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedOrNetworkImage(
                    id: anime.id.toString(),
                    imageUrl: anime.imageUrl,
                    width: 60,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 60,
                      height: 80,
                      color: Colors.grey[800],
                      child: const Icon(
                        Icons.broken_image,
                        color: Colors.grey,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Anime Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        anime.title,
                        style: GoogleFonts.urbanist(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (anime.genre != null)
                        Text(
                          anime.genre!,
                          style: GoogleFonts.urbanist(
                            color: Colors.tealAccent,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (anime.rating != null && anime.rating! > 0) ...[
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              anime.rating!.toStringAsFixed(1),
                              style: GoogleFonts.urbanist(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                          if (anime.episodes != null) ...[
                            const SizedBox(width: 12),
                            Text(
                              '${anime.episodes} eps',
                              style: GoogleFonts.urbanist(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                          if (anime.status != null) ...[
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(anime.status!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                anime.status!,
                                style: GoogleFonts.urbanist(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
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

  Widget _buildGenreGrid() {
    return ListView.builder(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 70),
      itemCount: _genres.length,
      itemBuilder: (context, index) {
        final genre = _genres[index];
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimations[index].value,
              child: Transform.translate(
                offset: Offset(0, _slideAnimations[index].value),
                child: child,
              ),
            );
          },
          child: _buildGenreCard(
            genre['name'],
            genre['imageAsset'],
            genre['color'],
          ),
        );
      },
    );
  }

  Widget _buildGenreCard(String genreName, String imageAssetPath, Color color) {
    final isNetworkImage = imageAssetPath.startsWith('http');

    return Container(
      height: 200,
      margin: const EdgeInsets.only(bottom: 16, right: 8, left: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            isNetworkImage
                ? Image.network(
              imageAssetPath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _imageErrorPlaceholder(),
            )
                : Image.asset(
              imageAssetPath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _imageErrorPlaceholder(),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, color.withOpacity(0.7)],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              child: Text(
                genreName.toUpperCase(),
                style: GoogleFonts.urbanist(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  shadows: [
                    Shadow(
                      blurRadius: 8,
                      color: Colors.black.withOpacity(0.8),
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  print('Selected genre: $genreName');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GenreAnimeScreen(genreName: genreName),
                    ),
                  );
                },
                splashColor: color.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'airing':
      case 'ongoing':
        return Colors.green;
      case 'finished':
      case 'completed':
        return Colors.blue;
      case 'not yet aired':
      case 'upcoming':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _imageErrorPlaceholder() {
    return Container(
      color: Colors.grey[800],
      child: const Center(
        child: Icon(Icons.broken_image, color: Colors.grey, size: 50),
      ),
    );
  }
}