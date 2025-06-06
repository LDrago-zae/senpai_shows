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
}