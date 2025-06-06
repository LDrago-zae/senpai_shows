import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/anime_model.dart';
import 'package:google_fonts/google_fonts.dart';

class FeaturedBanner extends StatelessWidget {
  final Future<List<Anime>> fetchAnime;

  const FeaturedBanner({super.key, required this.fetchAnime});

  @override
  Widget build(BuildContext context) {
    final pageController = PageController();

    return SizedBox(
      height: 240,
      child: FutureBuilder<List<Anime>>(
        future: fetchAnime,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Container(
              color: Colors.grey[900],
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
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
          }

          final animeList = snapshot.data!;
          return Stack(
            children: [
              // Scrollable banners with snapping
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
                  itemBuilder: (context, index) {
                    final anime = animeList[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          children: [
                            Image.network(
                              anime.imageUrl,
                              height: 240,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: Colors.grey[900],
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder:
                                  (context, error, stackTrace) => Container(
                                    color: Colors.grey[900],
                                    child: const Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        color: Colors.grey,
                                      ),
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
                                    Colors.black.withOpacity(0.7),
                                  ],
                                ),
                              ),
                            ),
                            // Title
                            Positioned(
                              bottom: 16,
                              left: 16,
                              child: Text(
                                anime.title.toUpperCase(),
                                style: GoogleFonts.urbanist(
                                  color: Colors.white,
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
                    );
                  },
                ),
              ),

              // Static icons overlay
              Positioned(
                top: 16,
                left: 16,
                child: IconButton(
                  onPressed: () {},
                  icon: Image.asset(
                    'assets/senpaiAssets/logo.png',
                    width: 100,
                    height: 100,
                  ),
                ),
              ),
              Positioned(
                top: 48,
                right: 16,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: FaIcon(Icons.search_rounded),
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

              // Page indicator
              Positioned(
                bottom: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
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
            ],
          );
        },
      ),
    );
  }
}

class PageIndicator extends StatelessWidget {
  final PageController controller;
  final int itemCount;

  const PageIndicator({
    super.key,
    required this.controller,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final currentPage = controller.page?.round() ?? 0;
        return Text(
          '${currentPage + 1}/$itemCount',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        );
      },
    );
  }
}
