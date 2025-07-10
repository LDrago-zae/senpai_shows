class Anime {
  final int id;
  final String title;
  final String imageUrl;

  // Additional optional fields
  final String? genre;
  final String? releaseDate;
  final String? synopsis;
  final String? starring;

  Anime({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.genre,
    this.releaseDate,
    this.synopsis,
    this.starring,
  });

  factory Anime.fromShikimoriJson(Map<String, dynamic> json) {
    return Anime(
      id: json['id'],
      title: json['name'] ?? 'Unknown',
      imageUrl: 'https://shikimori.one${json['image']['original'] ?? ''}',
      genre: json['genre'] ?? 'Unknown',
      releaseDate: json['aired_on'] ?? 'Unknown',
      synopsis: json['description'] ?? 'No synopsis available.',
      starring: null, // You can add logic here if available
    );
  }

  factory Anime.fromAniListJson(Map<String, dynamic> json) {
    return Anime(
      id: json['id'],
      title: json['title']['romaji'] ?? 'Unknown',
      imageUrl: json['coverImage']['extraLarge'] ?? '',
      genre: (json['genres'] as List?)?.join(', ') ?? 'Unknown',
      releaseDate: json['startDate']?['year']?.toString() ?? 'Unknown',
      synopsis: json['description'] ?? 'No synopsis available.',
      starring: null,
    );
  }

  factory Anime.fromKitsuJson(Map<String, dynamic> json) {
    final attributes = json['attributes'];
    return Anime(
      id: int.tryParse(json['id']) ?? 0,
      title: attributes['canonicalTitle'] ?? 'Unknown',
      imageUrl: attributes['posterImage']?['original'] ?? '',
      genre: (attributes['genres'] as List?)?.join(', ') ?? 'Unknown',
      releaseDate: attributes['startDate'] ?? 'Unknown',
      synopsis: attributes['synopsis'] ?? 'No synopsis available.',
      starring: null,
    );
  }
}
