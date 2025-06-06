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
}