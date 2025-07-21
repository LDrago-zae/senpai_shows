import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/anime_detail_model.dart';

class SenpaiDetailsScreen extends StatelessWidget {
  final AnimeModel anime;

  const SenpaiDetailsScreen({super.key, required this.anime});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      anime.title,
                      style: GoogleFonts.urbanist(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.more_vert, color: Colors.white),
                ],
              ),
              const SizedBox(height: 16),

              // Hero Image (network)
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Hero(
                  tag: anime.imagePath,
                  child: Image.network(
                    anime.imagePath,
                    width: double.infinity,
                    height: 400,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[900],
                      height: 280,
                      child: const Icon(Icons.broken_image, color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title + Genre
              Text(
                anime.title,
                style: GoogleFonts.urbanist(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                anime.genre,
                style: GoogleFonts.urbanist(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 12),

              // Buttons
              Row(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent[700],
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.play_arrow),
                    label: const Text("Play"),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                    label: const Text("My List"),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Release Date + Download
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Release date",
                    style: GoogleFonts.urbanist(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent[400],
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text("Download"),
                  ),
                ],
              ),
              Text(
                anime.releaseDate,
                style: GoogleFonts.urbanist(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 20),

              // Synopsis
              Text(
                "Synopsis",
                style: GoogleFonts.urbanist(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                anime.synopsis,
                style: GoogleFonts.urbanist(
                  color: Colors.grey[300],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 10),

              // Starring
              Text(
                "Starring: ${anime.starring}",
                style: GoogleFonts.urbanist(
                  color: Colors.tealAccent[100],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),

              // Episodes (network images)
              Text(
                "Episodes",
                style: GoogleFonts.urbanist(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 140,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(anime.imagePath),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
