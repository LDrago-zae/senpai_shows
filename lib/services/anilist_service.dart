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

  Future<List<Anime>> fetchAnimeByGenre(String genre, {int page = 1, int perPage = 20}) async {
    const String query = '''
    query (\$page: Int, \$perPage: Int, \$genre: String) {
      Page(page: \$page, perPage: \$perPage) {
        media(genre: \$genre, type: ANIME, sort: POPULARITY_DESC) {
          id
          title {
            romaji
            english
            native
          }
          coverImage {
            large
            medium
          }
          averageScore
          episodes
          status
          description
          startDate {
            year
          }
          genres
          studios {
            nodes {
              name
            }
          }
          format
        }
      }
    }
  ''';

    final variables = {
      'page': page,
      'perPage': perPage,
      'genre': genre,
    };

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'query': query,
          'variables': variables,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['errors'] != null) {
          throw Exception('GraphQL Error: ${data['errors']}');
        }

        final List<dynamic> mediaList = data['data']['Page']['media'];
        return mediaList.map((item) {
          return Anime(
            id: item['id'],
            title: item['title']['english'] ??
                item['title']['romaji'] ??
                item['title']['native'] ??
                'Unknown Title',
            imageUrl: item['coverImage']['large'] ??
                item['coverImage']['medium'] ??
                'https://via.placeholder.com/300x400',
            rating: (item['averageScore'] ?? 0).toDouble() / 10.0,
            episodes: item['episodes'],
            status: _mapAniListStatus(item['status']),
            synopsis: item['description']?.replaceAll(RegExp(r'<[^>]*>'), '') ?? 'No synopsis available.',
            releaseDate: item['startDate']?['year']?.toString(),
            genre: item['genres']?.join(', '),
            rank: 0,
            starring: item['studios']?['nodes']?.isNotEmpty == true
                ? item['studios']['nodes'][0]['name']
                : 'Unknown Studio',
          );
        }).toList();
      } else {
        throw Exception('Failed to fetch $genre anime from AniList: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching $genre anime from AniList: $e');
      throw Exception('Failed to load $genre anime from AniList');
    }
  }

  String _mapAniListStatus(String? status) {
    switch (status) {
      case 'RELEASING':
        return 'Airing';
      case 'FINISHED':
        return 'Finished';
      case 'NOT_YET_RELEASED':
        return 'Not Yet Aired';
      case 'CANCELLED':
        return 'Cancelled';
      case 'HIATUS':
        return 'Hiatus';
      default:
        return 'Unknown';
    }
  }

  Future<List<Anime>> searchAnime(String query, {int page = 1, int perPage = 10}) async {
    const String searchQuery = '''
    query (\$page: Int, \$perPage: Int, \$search: String) {
      Page(page: \$page, perPage: \$perPage) {
        media(search: \$search, type: ANIME, sort: POPULARITY_DESC) {
          id
          title {
            romaji
            english
            native
          }
          coverImage {
            large
            medium
          }
          averageScore
          episodes
          status
          description
          startDate {
            year
          }
          genres
        }
      }
    }
  ''';

    final variables = {
      'page': page,
      'perPage': perPage,
      'search': query,
    };

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'query': searchQuery,
          'variables': variables,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['errors'] != null) {
          throw Exception('GraphQL Error: ${data['errors']}');
        }

        final List<dynamic> mediaList = data['data']['Page']['media'];
        return mediaList.map((item) {
          return Anime(
            id: item['id'],
            title: item['title']['english'] ??
                item['title']['romaji'] ??
                item['title']['native'] ??
                'Unknown Title',
            imageUrl: item['coverImage']['large'] ??
                item['coverImage']['medium'] ??
                'https://via.placeholder.com/300x400',
            rating: (item['averageScore'] ?? 0).toDouble() / 10.0,
            episodes: item['episodes'],
            status: _mapAniListStatus(item['status']),
            synopsis: item['description']?.replaceAll(RegExp(r'<[^>]*>'), '') ?? 'No synopsis available.',
            releaseDate: item['startDate']?['year']?.toString(),
            genre: item['genres']?.join(', '),
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


