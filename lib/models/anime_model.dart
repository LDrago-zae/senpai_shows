class Anime {
  final int id;
  final String title;
  final String imageUrl;
  final double score;

  Anime({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.score,
  });

  factory Anime.fromShikimoriJson(Map<String, dynamic> json) {
    return Anime(
      id: json['id'],
      title: json['name'] ?? 'Unknown',
      imageUrl: 'https://shikimori.one${json['image']['original'] ?? ''}',
      score: (json['score'] is num) ? (json['score'] as num).toDouble() : 0.0,
    );
  }

  factory Anime.fromAniListJson(Map<String, dynamic> json) {
    return Anime(
      id: json['id'],
      title: json['title']['romaji'] ?? 'Unknown',
      imageUrl: json['coverImage']['large'] ?? '',
      score: (json['averageScore'] is int) ? (json['averageScore'] as int).toDouble() : 0.0,
    );
  }
}