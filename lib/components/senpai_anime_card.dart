import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:senpai_shows/models/anime_detail_model.dart';
import 'package:senpai_shows/screens/senpai_details_screen.dart';
import '../models/anime_model.dart';
import '../screens/senpai_home.dart';

class SenpaiAnimeCard extends StatefulWidget {
  final Anime anime;
  final int index;
  final AnimationController animationController;

  const SenpaiAnimeCard({
    super.key,
    required this.anime,
    required this.index,
    required this.animationController,
  });

  @override
  State<SenpaiAnimeCard> createState() => _SenpaiAnimeCardState();
}

class _SenpaiAnimeCardState extends State<SenpaiAnimeCard> {
  late Animation<double> _opacityAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // Define opacity animation
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: widget.animationController,
        curve: Interval(
          widget.index * 0.08,
          (widget.index * 0.08) + 0.28,
          curve: Curves.easeOut,
        ),
      ),
    );

    // Define slide animation
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: widget.animationController,
        curve: Interval(
          widget.index * 0.08,
          (widget.index * 0.08) + 0.28,
          curve: Curves.easeOut,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animationController,
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