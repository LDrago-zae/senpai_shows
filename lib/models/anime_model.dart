// class Anime {
//   final int id;
//   final String title;
//   final String imageUrl;
//
//   // Additional optional fields
//   final String? genre;
//   final String? releaseDate;
//   final String? synopsis;
//   final String? starring;
//
//   Anime({
//     required this.id,
//     required this.title,
//     required this.imageUrl,
//     this.genre,
//     this.releaseDate,
//     this.synopsis,
//     this.starring,
//   });
//
//   factory Anime.fromShikimoriJson(Map<String, dynamic> json) {
//     return Anime(
//       id: json['id'],
//       title: json['name'] ?? 'Unknown',
//       imageUrl: 'https://shikimori.one${json['image']['original'] ?? ''}',
//       genre: json['genre'] ?? 'Unknown',
//       releaseDate: json['aired_on'] ?? 'Unknown',
//       synopsis: json['description'] ?? 'No synopsis available.',
//       starring: null, // You can add logic here if available
//     );
//   }
//
//   factory Anime.fromAniListJson(Map<String, dynamic> json) {
//     return Anime(
//       id: json['id'],
//       title: json['title']['romaji'] ?? 'Unknown',
//       imageUrl: json['coverImage']['extraLarge'] ?? '',
//       genre: (json['genres'] as List?)?.join(', ') ?? 'Unknown',
//       releaseDate: json['startDate']?['year']?.toString() ?? 'Unknown',
//       synopsis: json['description'] ?? 'No synopsis available.',
//       starring: null,
//     );
//   }
//
//   factory Anime.fromKitsuJson(Map<String, dynamic> json) {
//     final attributes = json['attributes'];
//     return Anime(
//       id: int.tryParse(json['id']) ?? 0,
//       title: attributes['canonicalTitle'] ?? 'Unknown',
//       imageUrl: attributes['posterImage']?['original'] ?? '',
//       genre: (attributes['genres'] as List?)?.join(', ') ?? 'Unknown',
//       releaseDate: attributes['startDate'] ?? 'Unknown',
//       synopsis: attributes['synopsis'] ?? 'No synopsis available.',
//       starring: null,
//     );
//   }
// }
class Anime {
  final int id;
  final String title;
  final String imageUrl;

  // Additional optional fields from previous version
  final String? genre;
  final String? releaseDate;
  final String? synopsis;
  final String? starring;

  // NEW: Additional optional fields needed for AnimeCard
  final String? status; // e.g., "Finished Airing", "Currently Airing"
  final int? episodes;  // Number of episodes
  final double? rating; // Average rating (e.g., from AniList, Kitsu)
  final int? rank;      // Ranking (e.g., from Shikimori, AniList)

  Anime({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.genre,
    this.releaseDate,
    this.synopsis,
    this.starring,
    this.status,     // Add to constructor
    this.episodes,   // Add to constructor
    this.rating,     // Add to constructor
    this.rank,       // Add to constructor
  });

  factory Anime.fromShikimoriJson(Map<String, dynamic> json) {
    // Example: Parsing relevant fields from Shikimori API response
    // You'll need to adjust keys based on the actual Shikimori API docs/response
    final ratesScoresStats = json['rates_scores_stats'] as List?;
    double? averageScore;
    if (ratesScoresStats != null && ratesScoresStats.isNotEmpty) {
      // Simplified: Often the score is weighted. A full implementation would calculate the weighted average.
      // This just takes the score from the first entry as an example.
      averageScore = (ratesScoresStats.first['name'] as num?)?.toDouble();
    }

    return Anime(
      id: json['id'],
      title: json['name'] ?? json['russian'] ?? 'Unknown', // Use Russian title if name is missing?
      imageUrl: 'https://shikimori.one${json['image']?['original'] ?? ''}',
      genre: (json['genres'] as List?)?.map((g) => g['russian'] as String?).join(', '), // Example for Russian genre names
      releaseDate: json['aired_on'] ?? json['released_on'] ?? 'Unknown',
      synopsis: json['description_html'] ?? json['description'] ?? 'No synopsis available.',
      starring: null, // Populate if data available
      status: json['status'] == 'released' ? 'Finished Airing' :
      json['status'] == 'ongoing' ? 'Currently Airing' :
      json['status'] == 'anons' ? 'Not yet aired' : json['status'], // Map Shikimori status
      episodes: json['episodes'] is int ? json['episodes'] as int :
      json['episodes_aired'] is int ? json['episodes_aired'] as int : null,
      rating: averageScore, // Or parse from 'score' if it's a simple average
      rank: json['ranked'] is int ? json['ranked'] as int : null, // Check actual key for rank
    );
  }

  factory Anime.fromAniListJson(Map<String, dynamic> json) {
    return Anime(
      id: json['id'],
      title: json['title']?['romaji'] ?? json['title']?['english'] ?? json['title']?['native'] ?? 'Unknown',
      imageUrl: json['coverImage']?['extraLarge'] ?? json['coverImage']?['large'] ?? '',
      genre: (json['genres'] as List?)?.join(', '),
      releaseDate: json['startDate'] != null ?
      "${json['startDate']['year'] ?? '?'}-${json['startDate']['month'] ?? '?'}-${json['startDate']['day'] ?? '?'}" : 'Unknown',
      synopsis: json['description'],
      starring: null, // Populate if data available
      status: json['status'], // AniList often uses "FINISHED", "RELEASING", "NOT_YET_RELEASED", "CANCELLED", "HIATUS"
      episodes: json['episodes'] is int ? json['episodes'] as int : null,
      rating: (json['averageScore'] is num) ? json['averageScore'].toDouble() / 10.0 : null, // AniList score is out of 100
      rank: json['rankings'] is List && json['rankings'].isNotEmpty ?
      (json['rankings'][0]['rank'] is int ? json['rankings'][0]['rank'] as int : null) : null, // Get primary rank
    );
  }

  factory Anime.fromKitsuJson(Map<String, dynamic> json) {
    final attributes = json['attributes'];
    return Anime(
      id: int.tryParse(json['id']) ?? 0,
      title: attributes?['canonicalTitle'] ?? 'Unknown',
      imageUrl: attributes?['posterImage']?['original'] ?? attributes?['posterImage']?['large'] ?? '',
      genre: null, // Kitsu genres usually require a separate lookup via relationships
      releaseDate: attributes?['startDate'] ?? 'Unknown',
      synopsis: attributes?['synopsis'],
      starring: null, // Populate if data available
      status: attributes?['status'] != null ?
      (attributes!['status'] == 'finished' ? 'Finished Airing' :
      attributes['status'] == 'current' ? 'Currently Airing' :
      attributes['status'] == 'upcoming' ? 'Not yet aired' :
      attributes['status']) : null, // Map Kitsu status
      episodes: attributes?['episodeCount'] is int ? attributes!['episodeCount'] as int : null,
      rating: attributes?['averageRating'] != null ? double.tryParse(attributes!['averageRating'].toString()) : null, // Kitsu rating is string?
      rank: null, // Check if Kitsu provides a direct rank, often needs calculation
    );
  }

// Optional: A generic constructor or helper if data comes from a different source
// that matches the Anime class fields directly.
// factory Anime.fromMap(Map<String, dynamic> map) { ... }
}