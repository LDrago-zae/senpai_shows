// lib/components/bento_grid.dart
import 'package:flutter/material.dart';
import '../models/anime_model.dart';

class BentoGrid extends StatelessWidget {
  final List<Anime> animeList;

  const BentoGrid({super.key, required this.animeList});

  @override
  Widget build(BuildContext context) {
    if (animeList.length < 6) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.65,
        ),
        itemCount: animeList.length,
        itemBuilder: (context, index) {
          return _buildAnimeCard(animeList[index]);
        },
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 200,
                child: _buildAnimeCard(animeList[0]),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 200,
                child: _buildAnimeCard(animeList[1]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: SizedBox(
                height: 280,
                child: _buildAnimeCard(animeList[2]),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  SizedBox(
                    height: 134,
                    child: _buildAnimeCard(animeList[3]),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 134,
                    child: _buildAnimeCard(animeList[4]),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 160,
                child: _buildAnimeCard(animeList[5 % animeList.length]),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 160,
                child: _buildAnimeCard(animeList[6 % animeList.length]),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 160,
                child: _buildAnimeCard(animeList[7 % animeList.length]),
              ),
            ),
          ],
        ),
        if (animeList.length > 8) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    SizedBox(
                      height: 140,
                      child: _buildAnimeCard(animeList[8]),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 140,
                      child: _buildAnimeCard(animeList[9 % animeList.length]),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 292,
                  child: _buildAnimeCard(animeList[8 % animeList.length]),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildAnimeCard(Anime anime) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              anime.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey[900],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                      color: Colors.tealAccent,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[900],
                child: const Center(
                  child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
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
              bottom: 8,
              left: 8,
              right: 8,
              child: Text(
                anime.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}