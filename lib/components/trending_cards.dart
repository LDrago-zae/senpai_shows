import 'package:flutter/material.dart';
import 'package:senpai_shows/screens/senpai_details_screen.dart';

import '../controllers/home_controller.dart';
import '../models/anime_detail_model.dart';
import '../models/anime_model.dart';
import '../screens/senpai_home.dart';

class TrendingCards extends StatelessWidget {
  TrendingCards({super.key});

  final HomeController _homeController = HomeController();

  @override
  Widget build(BuildContext context) {
    return Container(
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
      height: 220,
      child: FutureBuilder<List<Anime>>(
        future: _homeController.fetchTrendingAnime(),
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
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => SenpaiDetailsScreen(
                            anime: AnimeModel(
                              title: anime.title,
                              genre: '',
                              imagePath: anime.imageUrl,
                              synopsis:
                              anime.synopsis ??
                                  'No synopsis available.',
                              releaseDate:
                              anime.releaseDate ?? 'Unknown',
                              starring: anime.starring ?? 'N/A',
                            ),
                          ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  width: 130,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.tealAccent.withOpacity(0.5),
                      width: 1,
                    ),
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
                        CachedOrNetworkImage(
                          id: anime.id.toString(),
                          imageUrl: anime.imageUrl,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
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
                                color: Color(0xffdbe6ff),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        // Positioned(
                        //   top: 8,
                        //   left: 8,
                        //   child: Container(
                        //     padding: const EdgeInsets.symmetric(
                        //       horizontal: 6,
                        //       vertical: 4,
                        //     ),
                        //     decoration: BoxDecoration(
                        //       color: Colors.tealAccent,
                        //       borderRadius: BorderRadius.circular(8),
                        //     ),
                        //     child: Text(
                        //       '${index + 1}',
                        //       style: const TextStyle(
                        //         fontWeight: FontWeight.bold,
                        //         color: Colors.black,
                        //         fontSize: 12,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
