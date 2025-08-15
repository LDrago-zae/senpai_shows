import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:senpai_shows/components/anime_particle_background.dart';

class SenpaiSongs extends StatefulWidget {
  const SenpaiSongs({super.key});

  @override
  State<SenpaiSongs> createState() => _SenpaiSongsState();
}

class _SenpaiSongsState extends State<SenpaiSongs> {
  List<AnimeOpening> _openings = [];
  bool _loading = true;
  String? _error;
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Popular', 'Recent', 'Classics', 'Favorites'];

  @override
  void initState() {
    super.initState();
    _loadOpenings();
  }

  Future<void> _loadOpenings() async {
    setState(() {
      _loading = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 1));
      // Sample data - replace with actual API call
      setState(() {
        _openings = [
          AnimeOpening(
            id: 1,
            title: 'Unravel',
            artist: 'TK from Ling tosite sigure',
            animeName: 'Tokyo Ghoul',
            imageUrl: 'https://example.com/tokyo_ghoul.jpg',
            duration: '3:54',
            category: 'Popular',
          ),
          AnimeOpening(
            id: 2,
            title: 'Guren no Yumiya',
            artist: 'Linked Horizon',
            animeName: 'Attack on Titan',
            imageUrl: 'https://example.com/aot.jpg',
            duration: '5:13',
            category: 'Popular',
          ),
        ];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load anime openings';
        _loading = false;
      });
    }
  }

  List<AnimeOpening> get _filteredOpenings {
    if (_selectedCategory == 'All') return _openings;
    return _openings.where((opening) => opening.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(38, 10, 10, 255),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Anime Openings',
          style: GoogleFonts.urbanist(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SizedBox.expand(),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Header Section
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple.withOpacity(0.2),
                        Colors.deepPurple.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.purpleAccent.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.music_note,
                        color: Colors.purpleAccent,
                        size: 30,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Anime Openings & Endings',
                              style: GoogleFonts.urbanist(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Discover epic anime soundtracks',
                              style: GoogleFonts.urbanist(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Category Filter
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = category == _selectedCategory;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.purpleAccent
                                : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.purpleAccent
                                  : Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            category,
                            style: GoogleFonts.urbanist(
                              color: isSelected ? Colors.black : Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Content Section
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.purpleAccent,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.redAccent,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: GoogleFonts.urbanist(
                color: Colors.redAccent,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadOpenings,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent,
                foregroundColor: Colors.black,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredOpenings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_off,
              color: Colors.white54,
              size: 80,
            ),
            const SizedBox(height: 24),
            Text(
              'No Openings Found',
              style: GoogleFonts.urbanist(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No anime openings found for this category.',
              textAlign: TextAlign.center,
              style: GoogleFonts.urbanist(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredOpenings.length,
      itemBuilder: (context, index) {
        final opening = _filteredOpenings[index];
        return _buildOpeningCard(opening);
      },
    );
  }

  Widget _buildOpeningCard(AnimeOpening opening) {
    return Card(
      color: Colors.black.withOpacity(0.7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 60,
            height: 60,
            color: Colors.grey.shade800,
            child: const Icon(
              Icons.music_note,
              color: Colors.purpleAccent,
              size: 30,
            ),
          ),
        ),
        title: Text(
          opening.title,
          style: GoogleFonts.urbanist(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'by ${opening.artist}',
              style: GoogleFonts.urbanist(
                fontSize: 14,
                color: Colors.purpleAccent,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              opening.animeName,
              style: GoogleFonts.urbanist(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              opening.duration,
              style: GoogleFonts.urbanist(
                fontSize: 12,
                color: Colors.white54,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(
                Icons.play_circle_filled,
                color: Colors.purpleAccent,
                size: 32,
              ),
              onPressed: () {
                // TODO: Implement play functionality
                _playOpening(opening);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _playOpening(AnimeOpening opening) {
    // TODO: Implement audio playback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Playing: ${opening.title}'),
        backgroundColor: Colors.purpleAccent,
      ),
    );
  }
}

class AnimeOpening {
  final int id;
  final String title;
  final String artist;
  final String animeName;
  final String imageUrl;
  final String duration;
  final String category;

  AnimeOpening({
    required this.id,
    required this.title,
    required this.artist,
    required this.animeName,
    required this.imageUrl,
    required this.duration,
    required this.category,
  });
}
