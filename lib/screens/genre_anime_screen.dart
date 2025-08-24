import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/anime_model.dart';
import '../controllers/home_controller.dart';
import '../components/genre_anime_card.dart';
import '../screens/senpai_home.dart';

class GenreAnimeScreen extends StatefulWidget {
  final String genreName;

  const GenreAnimeScreen({
    super.key,
    required this.genreName,
  });

  @override
  State<GenreAnimeScreen> createState() => _GenreAnimeScreenState();
}

class _GenreAnimeScreenState extends State<GenreAnimeScreen> {
  final HomeController _homeController = HomeController();
  final ScrollController _scrollController = ScrollController();

  late Future<List<Anime>> genreAnimeFuture;

  @override
  void initState() {
    super.initState();
    genreAnimeFuture = _homeController.fetchAnimeByGenre(widget.genreName);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _homeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(38, 10, 10, 255),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${widget.genreName} Anime',
          style: GoogleFonts.urbanist(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FutureBuilder<List<Anime>>(
          future: genreAnimeFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.tealAccent,
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.redAccent,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load ${widget.genreName} anime',
                      style: GoogleFonts.urbanist(
                        color: Colors.redAccent,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      style: GoogleFonts.urbanist(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          genreAnimeFuture = _homeController.fetchAnimeByGenre(widget.genreName);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.tealAccent,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'No ${widget.genreName} anime found.',
                  style: GoogleFonts.urbanist(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              );
            }

            final animeList = snapshot.data!;

            return Column(
              children: [
                // Stats Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.tealAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.tealAccent.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Found ${animeList.length} anime',
                          style: GoogleFonts.urbanist(
                            color: Colors.tealAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.tealAccent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.genreName,
                            style: GoogleFonts.urbanist(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Anime List
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      bottom: 100.0, // Add bottom padding for navigation
                    ),
                    itemCount: animeList.length,
                    itemBuilder: (context, index) {
                      final anime = animeList[index];
                      return GenreAnimeCard(
                        anime: anime,
                        index: index,
                      );
                    },
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