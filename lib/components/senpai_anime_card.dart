import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:senpai_shows/models/anime_detail_model.dart';
import 'package:senpai_shows/screens/senpai_details_screen.dart';
import '../models/anime_model.dart';
import '../screens/senpai_home.dart';

class SenpaiAnimeCard extends StatelessWidget {
  final Anime anime;

  const SenpaiAnimeCard({super.key, required this.anime});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => SenpaiDetailsScreen(
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
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.tealAccent.withOpacity(0.5),
            width: 1,
          ),
          color: Color.fromARGB(18,20,25,255),
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
                  id: anime.id.toString(),
                  imageUrl: anime.imageUrl,
                  width: 150,
                  height: 200,
                  fit: BoxFit.cover,
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
                    if (anime.status != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: anime.status == 'Airing'
                                ? Colors.green
                                : anime.status == 'Finished'
                                    ? Colors.blue
                                    : Colors.red,
                          ),
                        ),
                        child: Text(
                          anime.status!,
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
                      anime.title,
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
                        if (anime.releaseDate != null)
                          Text(
                            anime.releaseDate!,
                            style: GoogleFonts.urbanist(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                        if (anime.episodes != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '${anime.episodes} eps',
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
                          anime.rating?.toString() ?? 'N/A',
                          style: GoogleFonts.urbanist(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        if (anime.rank != null) ...[
                          const SizedBox(width: 12),
                          Text(
                            '#${anime.rank}',
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
                      children: (anime.genre != null
                          ? anime.genre!.split(',').map((g) => g.trim()).toList()
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
                    )
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
