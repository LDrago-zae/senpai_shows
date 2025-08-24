import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/anime_model.dart';

class KitsuApiService {
  static const String _baseUrl = 'https://kitsu.io/api/edge';

  Future<List<Anime>> fetchFeaturedAnime({int limit = 10}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/anime?page[limit]=$limit&page[offset]=0&sort=popularityRank'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((anime) => Anime.fromKitsuJson(anime)).toList();
    } else {
      throw Exception('Failed to fetch featured anime from Kitsu');
    }
  }

  Future<List<Anime>> fetchRecommendedAnime({int limit = 10}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/anime?page[limit]=$limit&page[offset]=0&sort=-averageRating'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((anime) => Anime.fromKitsuJson(anime)).toList();
    } else {
      throw Exception('Failed to fetch recommended anime from Kitsu');
    }
  }

  Future<List<Anime>> fetchTopAiringAnime({int limit = 10}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/anime?page[limit]=$limit&page[offset]=0&filter[status]=current&sort=popularityRank'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((anime) => Anime.fromKitsuJson(anime)).toList();
    } else {
      throw Exception('Failed to fetch top airing anime from Kitsu');
    }
  }

  Future<List<Anime>> fetchAnimeList({int limit = 10}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/anime?page[limit]=$limit&page[offset]=0'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((anime) => Anime.fromKitsuJson(anime)).toList();
    } else {
      throw Exception('Failed to fetch anime from Kitsu');
    }
  }

  Future<Anime?> fetchRandomAnime() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/anime?page[limit]=1&page[offset]=${(DateTime.now().millisecondsSinceEpoch / 1000).floor() % 1000}'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      if (data.isNotEmpty) {
        return Anime.fromKitsuJson(data.first);
      }
      return null; // No anime found
    } else {
      throw Exception('Failed to fetch random anime from Kitsu');
    }
  }

  Future<List<Anime>> fetchAnimeByGenre(String genre, {int pageOffset = 0, int limit = 20}) async {
    try {
      final uri = Uri.parse('$_baseUrl/anime').replace(queryParameters: {
        'filter[categories]': genre.toLowerCase(),
        'sort': '-popularityRank',
        'page[limit]': limit.toString(),
        'page[offset]': pageOffset.toString(),
        'include': 'categories',
      });

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/vnd.api+json',
          'Content-Type': 'application/vnd.api+json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> animeList = data['data'] ?? [];

        return animeList.map((item) {
          final attributes = item['attributes'];
          return Anime(
            id: int.tryParse(item['id']) ?? 0,
            title: attributes['titles']?['en'] ??
                attributes['titles']?['en_jp'] ??
                attributes['canonicalTitle'] ??
                'Unknown Title',
            imageUrl: attributes['posterImage']?['large'] ??
                attributes['posterImage']?['medium'] ??
                'https://via.placeholder.com/300x400',
            rating: (attributes['averageRating'] != null)
                ? double.tryParse(attributes['averageRating']) ?? 0.0
                : 0.0,
            episodes: attributes['episodeCount'],
            status: _mapKitsuStatus(attributes['status']),
            synopsis: attributes['synopsis'] ?? 'No synopsis available.',
            releaseDate: attributes['startDate']?.substring(0, 4),
            genre: genre, // Since we're filtering by this genre
            rank: attributes['popularityRank'] ?? 0,
            starring: 'Unknown Studio', // Kitsu doesn't always provide studio info in this endpoint
          );
        }).toList();
      } else {
        throw Exception('Failed to fetch $genre anime from Kitsu: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching $genre anime from Kitsu: $e');
      throw Exception('Failed to load $genre anime from Kitsu');
    }
  }

  String _mapKitsuStatus(String? status) {
    switch (status) {
      case 'current':
        return 'Airing';
      case 'finished':
        return 'Finished';
      case 'tba':
      case 'unreleased':
        return 'Not Yet Aired';
      default:
        return 'Unknown';
    }
  }

  Future<List<Anime>> searchAnime(String query, {int pageOffset = 0, int limit = 10}) async {
    try {
      final uri = Uri.parse('$_baseUrl/anime').replace(queryParameters: {
        'filter[text]': query,
        'sort': '-popularityRank',
        'page[limit]': limit.toString(),
        'page[offset]': pageOffset.toString(),
      });

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/vnd.api+json',
          'Content-Type': 'application/vnd.api+json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> animeList = data['data'] ?? [];

        return animeList.map((item) {
          final attributes = item['attributes'];
          return Anime(
            id: int.tryParse(item['id']) ?? 0,
            title: attributes['titles']?['en'] ??
                attributes['titles']?['en_jp'] ??
                attributes['canonicalTitle'] ??
                'Unknown Title',
            imageUrl: attributes['posterImage']?['large'] ??
                attributes['posterImage']?['medium'] ??
                'https://via.placeholder.com/300x400',
            rating: (attributes['averageRating'] != null)
                ? double.tryParse(attributes['averageRating']) ?? 0.0
                : 0.0,
            episodes: attributes['episodeCount'],
            status: _mapKitsuStatus(attributes['status']),
            synopsis: attributes['synopsis'] ?? 'No synopsis available.',
            releaseDate: attributes['startDate']?.substring(0, 4),
            genre: attributes['genres']?.join(', ') ?? 'Unknown',
            rank: attributes['popularityRank'] ?? 0,
          );
        }).toList();
      } else {
        throw Exception('Failed to search anime: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching anime: $e');
      return [];
    }
  }
}