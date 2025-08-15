import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/anime_model.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/anime_detail_model.dart';
import '../screens/senpai_details_screen.dart';

class FeaturedBanner extends StatefulWidget {
  final Future<List<Anime>> fetchAnime;

  const FeaturedBanner({super.key, required this.fetchAnime});

  @override
  _FeaturedBannerState createState() => _FeaturedBannerState();
}

class _FeaturedBannerState extends State<FeaturedBanner> with TickerProviderStateMixin {
  late PageController pageController;
  late List<AnimationController> _pageControllers;
  late List<Animation<double>> _opacities;
  late List<Animation<double>> _scales;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    _pageControllers = [];
    _opacities = [];
    _scales = [];
  }

  @override
  void dispose() {
    pageController.dispose();
    for (var controller in _pageControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initAnimations(int count) {
    _pageControllers
        .addAll(List.generate(count, (index) => AnimationController(vsync: this, duration: Duration(milliseconds: 500))));
    _opacities = _pageControllers.map((controller) => Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeIn),
    )).toList();
    _scales = _pageControllers.map((controller) => Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOutBack),
    )).toList();

    // Trigger first animation
    if (_pageControllers.isNotEmpty) {
      _pageControllers[0].forward();
    }
  }

  void _onPageChanged(int index) {
    // Reset and play animation for new page
    for (var controller in _pageControllers) {
      controller.reset();
    }
    if (index < _pageControllers.length) {
      _pageControllers[index].forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 15.0),
      child: SizedBox(
        height: 400,
        width: double.infinity,
        child: FutureBuilder<List<Anime>>(
          future: widget.fetchAnime,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Icon(Icons.error, color: Colors.red, size: 48),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Container(
                color: Colors.grey[900],
                child: const Center(
                  child: Text(
                    'No anime found',
                    style: TextStyle(color: Color(0xffdbe6ff)),
                  ),
                ),
              );
            }

            final animeList = snapshot.data!;
            if (_pageControllers.isEmpty) {
              _initAnimations(animeList.length);
            }

            return Stack(
              children: [
                Positioned.fill(
                  child: PageView.builder(
                    controller: pageController,
                    padEnds: false,
                    physics: const PageScrollPhysics().applyTo(
                      const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                    ),
                    itemCount: animeList.length,
                    onPageChanged: _onPageChanged,
                    itemBuilder: (context, index) {
                      final anime = animeList[index];
                      return AnimatedBuilder(
                        animation: _pageControllers[index],
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scales[index].value,
                            child: Opacity(
                              opacity: _opacities[index].value,
                              child: child,
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SenpaiDetailsScreen(
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
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.tealAccent.withOpacity(0.5),
                                  width: .5,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Stack(
                                  children: [
                                    Hero(
                                      tag: anime.imageUrl,
                                      child: Image.network(
                                        anime.imageUrl,
                                        height: 400,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Container(
                                            color: Colors.grey[900],
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress.expectedTotalBytes != null
                                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                    : null,
                                              ),
                                            ),
                                          );
                                        },
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          color: Colors.grey[900],
                                          child: const Center(
                                            child: Icon(Icons.broken_image, color: Colors.grey),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.7),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 32,
                                      left: 16,
                                      child: Text(
                                        anime.title.toUpperCase(),
                                        style: GoogleFonts.urbanist(
                                          color: Color(0xffdbe6ff),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          shadows: [
                                            Shadow(
                                              blurRadius: 10,
                                              color: Colors.black,
                                              offset: Offset(2, 2),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // ... (rest of the overlay icons and PageIndicator)
                Positioned(
                  top: 0,
                  left: 16,
                  child: IconButton(
                    onPressed: () {},
                    icon: Image.asset(
                      'assets/senpaiAssets/logo.png',
                      width: 120,
                      height: 120,
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 16,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const FaIcon(Icons.search_rounded),
                        color: Colors.white,
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const FaIcon(Icons.notifications_none, size: 24),
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 3,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: PageIndicator(
                        controller: pageController,
                        itemCount: animeList.length,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class PageIndicator extends StatelessWidget {
  final PageController controller;
  final int itemCount;

  const PageIndicator({
    Key? key,
    required this.controller,
    required this.itemCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        double page = 0;
        if (controller.hasClients && controller.position.haveDimensions) {
          page = controller.page ?? 0;
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(itemCount, (index) {
            double opacity = (1 - (page - index).abs()).clamp(0.0, 1.0);
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(opacity > 0.5 ? 1.0 : 0.4),
              ),
            );
          }),
        );
      },
    );
  }
}
