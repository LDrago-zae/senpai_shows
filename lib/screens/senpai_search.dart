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

  List<bool> _visibleCards = [];

  final List<Map<String, dynamic>> _genres = [
    {'name': 'Action', 'imageAsset': 'assets/senpaiAssets/solo2.png', 'color': Colors.transparent},
    {'name': 'Adventure', 'imageAsset': 'assets/senpaiAssets/op.png', 'color': Colors.transparent},
    {'name': 'Comedy', 'imageAsset': 'assets/senpaiAssets/dd.png', 'color': Colors.transparent},
    {'name': 'Drama', 'imageAsset': 'assets/senpaiAssets/cg.jpg', 'color': Colors.transparent},
    {'name': 'Fantasy', 'imageAsset': 'assets/senpaiAssets/rz.png', 'color': Colors.transparent},
    {'name': 'Horror', 'imageAsset': 'assets/senpaiAssets/tg.jpg', 'color': Colors.transparent},
    {'name': 'Mystery', 'imageAsset': 'assets/senpaiAssets/er.jpg', 'color': Colors.transparent},
    {'name': 'Romance', 'imageAsset': 'assets/senpaiAssets/dm.jpg', 'color': Colors.transparent},
    {'name': 'Sci-Fi', 'imageAsset': 'assets/senpaiAssets/sg.jpg', 'color': Colors.transparent},
    {'name': 'Slice of Life', 'imageAsset': 'assets/senpaiAssets/fr.jpg', 'color': Colors.transparent},
  ];

  @override
  void initState() {
    super.initState();
    _visibleCards = List.generate(_genres.length, (_) => false);
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    for (int i = 0; i < _genres.length; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        setState(() {
          _visibleCards[i] = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[900],
      child: Column(
        children: [
          // No SafeArea here — let MainNavigation handle insets
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 16), // top padding manually
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
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100), // 👈🏽 bottom padding so nav doesn't overlap
              itemCount: _genres.length,
              itemBuilder: (context, index) {
                final genre = _genres[index];
                return AnimatedOpacity(
                  opacity: _visibleCards[index] ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  child: AnimatedSlide(
                    offset: _visibleCards[index] ? Offset.zero : const Offset(0, 0.2),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                    child: _buildGenreCard(
                      genre['name'],
                      genre['imageAsset'],
                      genre['color'],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
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
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[800],
                child: const Center(
                  child: Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            )
                : Image.asset(
              imageAssetPath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[800],
                child: const Center(
                  child: Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
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
