import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/anime_model.dart';

class AniListApiService {
  static const String _apiUrl = 'https://graphql.anilist.co';

  Future<List<Anime>> fetchPopularAnime({int page = 1, int perPage = 10}) async {
    const String query = r'''
      query ($page: Int, $perPage: Int) {
        Page(page: $page, perPage: $perPage) {
          media(type: ANIME, sort: POPULARITY_DESC) {
            id
            title {
              romaji
            }
            coverImage {
              extraLarge
            }
            averageScore
          }
        }
      }
    ''';

    final Map<String, dynamic> variables = {
      'page': page,
      'perPage': perPage,
    };

    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'query': query,
        'variables': variables,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> mediaList = jsonResponse['data']['Page']['media'];
      return mediaList.map((media) => Anime.fromAniListJson(media)).toList();
    } else {
      throw Exception('Failed to load popular anime from AniList');
    }
  }

  Future<List<Anime>> fetchRecentAnime({int page = 1, int perPage = 10}) async {
    const String query = r'''
      query ($page: Int, $perPage: Int) {
        Page(page: $page, perPage: $perPage) {
          media(type: ANIME, sort: START_DATE_DESC) {
            id
            title {
              romaji
            }
            coverImage {
              extraLarge
            }
            averageScore
          }
        }
      }
    ''';

    final Map<String, dynamic> variables = {
      'page': page,
      'perPage': perPage,
    };

    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'query': query,
        'variables': variables,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> mediaList = jsonResponse['data']['Page']['media'];
      return mediaList.map((media) => Anime.fromAniListJson(media)).toList();
    } else {
      throw Exception('Failed to load recent anime from AniList');
    }
  }

  Future<List<Anime>> fetchRecommendedAnime({int page = 1, int perPage = 10}) async {
    const String query = r'''
      query ($page: Int, $perPage: Int) {
        Page(page: $page, perPage: $perPage) {
          media(type: ANIME, sort: RECOMMENDED_DESC) {
            id
            title {
              romaji
            }
            coverImage {
              extraLarge
            }
            averageScore
          }
        }
      }
    ''';

    final Map<String, dynamic> variables = {
      'page': page,
      'perPage': perPage,
    };

    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'query': query,
        'variables': variables,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> mediaList = jsonResponse['data']['Page']['media'];
      return mediaList.map((media) => Anime.fromAniListJson(media)).toList();
    } else {
      throw Exception('Failed to load recommended anime from AniList');
    }
  }
  Future<Anime?> fetchRandomAnime() async {
    // Pick a random ID (common range: 1 to ~18000 for anime)
    final int randomId = 10000 + (DateTime.now().millisecondsSinceEpoch % 8000);

    const String query = r'''
    query ($id: Int) {
      Media(id: $id, type: ANIME) {
        id
        title {
          romaji
        }
        coverImage {
          extraLarge
        }
        averageScore
        episodes
        description
      }
    }
  ''';

    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'query': query,
        'variables': {'id': randomId},
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final media = jsonResponse['data']['Media'];
      if (media != null) {
        return Anime.fromAniListJson(media);
      }
      return fetchRandomAnime(); // Retry if no anime found with that ID
    } else {
      throw Exception('Failed to fetch random anime');
    }
  }
}


