import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  late AnimationController _animationController;
  late List<Animation<double>> _opacityAnimations;
  late List<Animation<double>> _slideAnimations;
  late VoidCallback _tabListener;

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

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _opacityAnimations = List.generate(
      _genres.length,
          (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(index * 0.08, (index * 0.08) + 0.28, curve: Curves.easeOut),
        ),
      ),
    );

    _slideAnimations = List.generate(
      _genres.length,
          (index) => Tween<double>(begin: 50.0, end: 0.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(index * 0.08, (index * 0.08) + 0.28, curve: Curves.easeOut),
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
  }

  void _triggerAnimation() {
    _animationController.reset();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    widget.tabNotifier.removeListener(_tabListener);
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      color: Colors.grey[900],
      child: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
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
                  style: GoogleFonts.urbanist(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Search anime...',
                    hintStyle: GoogleFonts.urbanist(color: Colors.grey[400]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
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
              ),
            ),
          ],
        ),
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

  Widget _imageErrorPlaceholder() {
    return Container(
      color: Colors.grey[800],
      child: const Center(
        child: Icon(Icons.broken_image, color: Colors.grey, size: 50),
      ),
    );
  }
}
