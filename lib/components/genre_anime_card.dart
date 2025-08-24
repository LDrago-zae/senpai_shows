import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../models/anime_model.dart';
import '../models/anime_detail_model.dart';
import '../screens/senpai_details_screen.dart';
import '../screens/senpai_home.dart';

class GenreAnimeCard extends StatefulWidget {
  final Anime anime;
  final int index;

  const GenreAnimeCard({
    super.key,
    required this.anime,
    required this.index,
  });

  @override
  State<GenreAnimeCard> createState() => _GenreAnimeCardState();
}

class _GenreAnimeCardState extends State<GenreAnimeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<double> _slideAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          widget.index * 0.05,
          (widget.index * 0.05) + 0.3,
          curve: Curves.easeOut,
        ),
      ),
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          widget.index * 0.05,
          (widget.index * 0.05) + 0.3,
          curve: Curves.easeOut,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('genre_anime_card_${widget.anime.id}'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.3 &&
            !_animationController.isAnimating &&
            !_animationController.isCompleted) {
          _animationController.forward();
        }
      },
      child: AnimatedBuilder(
        animation: _animationController,
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
      ),
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
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.tealAccent.withOpacity(0.3),
            width: 1,
          ),
          color: const Color.fromARGB(18, 20, 25, 255),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Poster
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedOrNetworkImage(
                      id: widget.anime.id.toString(),
                      imageUrl: widget.anime.imageUrl,
                      width: 120,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 120,
                        height: 180,
                        color: Colors.grey[800],
                        child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                            size: 40
                        ),
                      ),
                    ),
                  ),
                ),

                // Info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Badge
                        if (widget.anime.status != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(widget.anime.status!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              widget.anime.status!,
                              style: GoogleFonts.urbanist(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),

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
                        const SizedBox(height: 8),

                        // Rating + Episodes
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              widget.anime.rating?.toStringAsFixed(1) ?? 'N/A',
                              style: GoogleFonts.urbanist(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            if (widget.anime.episodes != null) ...[
                              const SizedBox(width: 16),
                              Text(
                                '${widget.anime.episodes} eps',
                                style: GoogleFonts.urbanist(
                                  fontSize: 13,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                            if (widget.anime.releaseDate != null) ...[
                              const SizedBox(width: 16),
                              Text(
                                widget.anime.releaseDate!,
                                style: GoogleFonts.urbanist(
                                  fontSize: 13,
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
                              .take(3)
                              .map((genre) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3
                              ),
                              decoration: BoxDecoration(
                                color: Colors.tealAccent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                genre,
                                style: GoogleFonts.urbanist(
                                  fontSize: 11,
                                  color: Colors.tealAccent,
                                  fontWeight: FontWeight.w500,
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

            // Synopsis Section
            if (widget.anime.synopsis != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(
                      color: Colors.white24,
                      thickness: 0.5,
                    ),
                    const SizedBox(height: 8),
                    AnimatedCrossFade(
                      firstChild: Text(
                        widget.anime.synopsis!,
                        style: GoogleFonts.urbanist(
                          fontSize: 13,
                          color: Colors.white70,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      secondChild: Text(
                        widget.anime.synopsis!,
                        style: GoogleFonts.urbanist(
                          fontSize: 13,
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),
                      crossFadeState: _isExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 300),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      child: Text(
                        _isExpanded ? 'See Less' : 'See More',
                        style: GoogleFonts.urbanist(
                          fontSize: 12,
                          color: Colors.tealAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
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
}