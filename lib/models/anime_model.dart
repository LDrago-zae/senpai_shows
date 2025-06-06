class Anime {
  final int id;
  final String title;
  final String imageUrl;

  Anime({
    required this.id,
    required this.title,
    required this.imageUrl,
  });

  factory Anime.fromShikimoriJson(Map<String, dynamic> json) {
    return Anime(
      id: json['id'],
      title: json['name'] ?? 'Unknown',
      imageUrl: 'https://shikimori.one${json['image']['original'] ?? ''}',
    );
  }

  factory Anime.fromAniListJson(Map<String, dynamic> json) {
    return Anime(
      id: json['id'],
      title: json['title']['romaji'] ?? 'Unknown',
      imageUrl: json['coverImage']['large'] ?? '',
    );
  }

  factory Anime.fromJikanJson(Map<String, dynamic> json) {
    return Anime(
      title: json['title'] ?? '',
      imageUrl: json['images']['jpg']['image_url'] ?? '',
      id: json['id'],
    );
  }
}
