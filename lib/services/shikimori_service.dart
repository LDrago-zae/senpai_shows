import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/anime_model.dart';


class ShikimoriApiService {
  static const String _baseUrl = 'https://shikimori.one/api';
  static const Map<String, String> _headers = {
    'User-Agent': 'SenpaiShowsApp/1.0',
  };

  Future<List<Anime>> fetchPopularAnime({int limit = 10}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/animes?order=popularity&limit=$limit'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Anime.fromShikimoriJson(json)).toList();
    } else {
      throw Exception('Failed to load popular anime from Shikimori');
    }
  }

  Future<List<Anime>> fetchRecentAnime({int limit = 10}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/animes?order=aired_on&limit=$limit'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Anime.fromShikimoriJson(json)).toList();
    } else {
      throw Exception('Failed to load recent anime from Shikimori');
    }
  }

  Future<List<Anime>> fetchAnimeByGenre(String genre, {int page = 1, int limit = 20}) async {
    // Map common genre names to Shikimori genre IDs
    final genreMap = {
      'action': 1,
      'adventure': 2,
      'cars': 3,
      'comedy': 4,
      'dementia': 5,
      'demons': 6,
      'mystery': 7,
      'drama': 8,
      'ecchi': 9,
      'fantasy': 10,
      'game': 11,
      'hentai': 12,
      'historical': 13,
      'horror': 14,
      'kids': 15,
      'magic': 16,
      'martial arts': 17,
      'mecha': 18,
      'music': 19,
      'parody': 20,
      'samurai': 21,
      'romance': 22,
      'school': 23,
      'sci-fi': 24,
      'shoujo': 25,
      'shoujo ai': 26,
      'shounen': 27,
      'shounen ai': 28,
      'space': 29,
      'sports': 30,
      'super power': 31,
      'vampire': 32,
      'yaoi': 33,
      'yuri': 34,
      'harem': 35,
      'slice of life': 36,
      'supernatural': 37,
      'military': 38,
      'police': 39,
      'psychological': 40,
      'thriller': 41,
      'seinen': 42,
      'josei': 43,
    };

    final genreId = genreMap[genre.toLowerCase()];

    try {
      final uri = Uri.parse('$_baseUrl/animes').replace(queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
        'order': 'popularity',
        if (genreId != null) 'genre': genreId.toString(),
        if (genreId == null) 'search': genre, // Fallback to search if genre ID not found
      });

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'SenpaiShows/1.0',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        return data.map((item) {
          return Anime(
            id: item['id'],
            title: item['russian'] ?? item['name'] ?? 'Unknown Title',
            imageUrl: item['image']?['original'] != null
                ? 'https://shikimori.one${item['image']['original']}'
                : 'https://via.placeholder.com/300x400',
            rating: (item['score'] ?? 0.0).toDouble(),
            episodes: item['episodes'],
            status: _mapShikimoriStatus(item['status']),
            synopsis: item['description'] ?? 'No synopsis available.',
            releaseDate: item['aired_on']?.substring(0, 4),
            genre: (item['genres'] as List?)?.map((g) => g['name']).join(', '),
            rank: 0,
            starring: (item['studios'] as List?)?.isNotEmpty == true
                ? item['studios'][0]['name']
                : 'Unknown Studio',
          );
        }).toList();
      } else {
        throw Exception('Failed to fetch $genre anime from Shikimori: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching $genre anime from Shikimori: $e');
      throw Exception('Failed to load $genre anime from Shikimori');
    }
  }

  String _mapShikimoriStatus(String? status) {
    switch (status) {
      case 'anons':
        return 'Not Yet Aired';
      case 'ongoing':
        return 'Airing';
      case 'released':
        return 'Finished';
      default:
        return 'Unknown';
    }
  }

  Future<List<Anime>> searchAnime(String query, {int page = 1, int limit = 10}) async {
    try {
      final uri = Uri.parse('$_baseUrl/animes').replace(queryParameters: {
        'search': query,
        'page': page.toString(),
        'limit': limit.toString(),
        'order': 'popularity',
      });

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'SenpaiShows/1.0',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        return data.map((item) {
          return Anime(
            id: item['id'],
            title: item['russian'] ?? item['name'] ?? 'Unknown Title',
            imageUrl: item['image']?['original'] != null
                ? 'https://shikimori.one${item['image']['original']}'
                : 'https://via.placeholder.com/300x400',
            rating: (item['score'] ?? 0.0).toDouble(),
            episodes: item['episodes'],
            status: _mapShikimoriStatus(item['status']),
            synopsis: item['description'] ?? 'No synopsis available.',
            releaseDate: item['aired_on']?.substring(0, 4),
            genre: (item['genres'] as List?)?.map((g) => g['name']).join(', '),
            rank: 0,
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