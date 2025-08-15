import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/anime_detail_model.dart';

class SenpaiDetailsScreen extends StatelessWidget {
  final AnimeModel anime;

  const SenpaiDetailsScreen({super.key, required this.anime});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(38, 10, 10, 255),
      // Extend body behind the app bar for a full-screen effect
      // This allows the content to go under the AppBar
      // Useful for a more immersive design
      extendBodyBehindAppBar: false,
      resizeToAvoidBottomInset: false,
      // AppBar with transparent background
      appBar: AppBar(
        title: Text(
          "Details",
          style: GoogleFonts.urbanist(
            color: Color(0xffdbe6ff),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
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
                        color: Color(0xffdbe6ff),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.more_vert, color: Color(0xffdbe6ff),),
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
                      child: const Icon(Icons.broken_image, color: Color(0xffdbe6ff),),
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
                  color: Color(0xffdbe6ff),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                anime.genre,
                style: GoogleFonts.urbanist(
                  fontSize: 14,
                  color: Color(0xffdbe6ff),
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
                      foregroundColor: Color(0xffdbe6ff),
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                    label: const Text("My List",
                      style: TextStyle(color: Color(0xffdbe6ff)),
                    ),
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
                      color: Color(0xffdbe6ff),
                      fontSize: 20,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.tealAccent[400],
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.tealAccent, width: 1.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    icon: SvgPicture.asset(
                      'assets/icons/dbutton.svg',
                      width: 18,
                      height: 18,
                      colorFilter: ColorFilter.mode(
                        Colors.tealAccent[400]!,
                        BlendMode.srcIn,
                      ),
                    ),
                    label: const Text("Download",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xffdbe6ff),
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                anime.releaseDate,
                style: GoogleFonts.urbanist(
                  color: Color(0xffdbe6ff),
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 20),

              // Synopsis
              Text(
                "Synopsis",
                style: GoogleFonts.urbanist(
                  color: Color(0xffdbe6ff),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                anime.synopsis,
                style: GoogleFonts.urbanist(
                  color: Color(0xffdbe6ff),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 10),

              // Starring
              Text(
                "Starring: ${anime.starring}",
                style: GoogleFonts.urbanist(
                  color: Color(0xffdbe6ff),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),

              // Episodes (network images)
              Text(
                "Episodes",
                style: GoogleFonts.urbanist(
                  color: Color(0xffdbe6ff),
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
