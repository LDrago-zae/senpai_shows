import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SenpaiSearch extends StatefulWidget {
  const SenpaiSearch({super.key});

  @override
  State<SenpaiSearch> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SenpaiSearch> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _showSearchResults = false;

  // Sample genre data - replace with your actual data
  final List<Map<String, dynamic>> _genres = [
    {
      'name': 'Action',
      'imageAsset': 'assets/senpaiAssets/actionanime.jpeg',
      // Replace with your image
      'color': Colors.redAccent,
    },
    {
      'name': 'Adventure',
      'imageAsset': 'https://example.com/adventure.jpg',
      'color': Colors.blueAccent,
    },
    {
      'name': 'Comedy',
      'imageAsset': 'https://example.com/comedy.jpg',
      'color': Colors.yellowAccent,
    },
    {
      'name': 'Drama',
      'imageAsset': 'https://example.com/drama.jpg',
      'color': Colors.purpleAccent,
    },
    {
      'name': 'Fantasy',
      'imageAsset': 'https://example.com/fantasy.jpg',
      'color': Colors.greenAccent,
    },
    {
      'name': 'Horror',
      'imageAsset': 'https://example.com/horror.jpg',
      'color': Colors.deepOrangeAccent,
    },
    {
      'name': 'Mystery',
      'imageAsset': 'https://example.com/mystery.jpg',
      'color': Colors.indigoAccent,
    },
    {
      'name': 'Romance',
      'imageAsset': 'https://example.com/romance.jpg',
      'color': Colors.pinkAccent,
    },
    {
      'name': 'Sci-Fi',
      'imageAsset': 'https://example.com/scifi.jpg',
      'color': Colors.tealAccent,
    },
    {
      'name': 'Slice of Life',
      'imageAsset': 'https://example.com/sliceoflife.jpg',
      'color': Colors.lightBlueAccent,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
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
                  onTap: () {
                    setState(() {
                      _showSearchResults = true;
                    });
                  },
                  onSubmitted: (value) {
                    // Handle search submission
                  },
                  style: GoogleFonts.urbanist(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search anime...',
                    hintStyle: GoogleFonts.urbanist(
                      color: Colors.grey[400],
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey[400],
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                  ),
                ),
              ),
            ),

            // Genre List with fade effect
            Expanded(
              child: AnimatedOpacity(
                opacity: _showSearchResults ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _genres.length,
                  itemBuilder: (context, index) {
                    final genre = _genres[index];
                    return _buildGenreCard(
                      genre['name'],
                      genre['imageAsset'],
                      genre['color'],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenreCard(String genreName, String imageAssetPath, Color color) {
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
            // Background image using local asset
            Image.asset(
              imageAssetPath, // Use the asset path directly
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(
                    color: Colors.grey[800],
                    child: const Center(
                      child: Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
            ),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    color.withOpacity(0.7),
                  ],
                ),
              ),
            ),

            // Genre name
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

            // Tap effect
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // Handle genre selection
                  print('Selected genre: $genreName');
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
}