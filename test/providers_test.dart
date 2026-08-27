import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:senpai_shows/models/anime_model.dart';
import 'package:senpai_shows/services/anilist_service.dart';
import 'package:senpai_shows/services/kitsu_service.dart';
import 'package:senpai_shows/services/shikimori_service.dart';
import 'package:senpai_shows/controllers/home_controller.dart';

class _AllowAllHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    HttpOverrides.global = _AllowAllHttpOverrides();
  });

  group('AniListApiService Tests', () {
    final service = AniListApiService();

    test('fetchPopularAnime returns a valid list of anime', () async {
      final list = await service.fetchPopularAnime(page: 1, perPage: 5);
      expect(list, isA<List<Anime>>());
      expect(list.isNotEmpty, true);
      expect(list.first.title.isNotEmpty, true);
    });

    test('fetchRecentAnime returns recent anime', () async {
      final list = await service.fetchRecentAnime(page: 1, perPage: 5);
      expect(list, isA<List<Anime>>());
      expect(list.isNotEmpty, true);
    });

    test('fetchRecommendedAnime returns recommended anime', () async {
      final list = await service.fetchRecommendedAnime(page: 1, perPage: 5);
      expect(list, isA<List<Anime>>());
      expect(list.isNotEmpty, true);
    });

    test('fetchAnimeByGenre returns anime matching genre', () async {
      final list = await service.fetchAnimeByGenre('Action', page: 1, perPage: 5);
      expect(list, isA<List<Anime>>());
      expect(list.isNotEmpty, true);
      expect(list.first.title.isNotEmpty, true);
    });

    test('searchAnime returns search results', () async {
      final list = await service.searchAnime('Naruto', page: 1, perPage: 3);
      expect(list, isA<List<Anime>>());
      expect(list.isNotEmpty, true);
      expect(list.any((a) => a.title.toLowerCase().contains('naruto')), true);
    });
  });

  group('KitsuApiService Tests', () {
    final service = KitsuApiService();

    test('fetchFeaturedAnime / fetchTopAiringAnime returns anime list', () async {
      final list = await service.fetchTopAiringAnime(limit: 5);
      expect(list, isA<List<Anime>>());
      expect(list.isNotEmpty, true);
      expect(list.first.title.isNotEmpty, true);
    });

    test('fetchRecommendedAnime returns anime list', () async {
      final list = await service.fetchRecommendedAnime(limit: 5);
      expect(list, isA<List<Anime>>());
      expect(list.isNotEmpty, true);
    });

    test('fetchAnimeList returns anime list', () async {
      final list = await service.fetchAnimeList(limit: 5);
      expect(list, isA<List<Anime>>());
      expect(list.isNotEmpty, true);
    });

    test('fetchAnimeByGenre returns anime matching genre', () async {
      final list = await service.fetchAnimeByGenre('Action', limit: 5);
      expect(list, isA<List<Anime>>());
      expect(list.isNotEmpty, true);
    });

    test('searchAnime returns search results', () async {
      final list = await service.searchAnime('One Piece', limit: 3);
      expect(list, isA<List<Anime>>());
      expect(list.isNotEmpty, true);
      expect(list.any((a) => a.title.toLowerCase().contains('one piece')), true);
    });
  });

  group('ShikimoriApiService Tests', () {
    final service = ShikimoriApiService();

    test('fetchPopularAnime returns popular anime list', () async {
      final list = await service.fetchPopularAnime(limit: 5);
      expect(list, isA<List<Anime>>());
      expect(list.isNotEmpty, true);
      expect(list.first.title.isNotEmpty, true);
    });

    test('fetchRecentAnime returns recent anime list', () async {
      final list = await service.fetchRecentAnime(limit: 5);
      expect(list, isA<List<Anime>>());
      expect(list.isNotEmpty, true);
    });

    test('fetchAnimeByGenre returns anime by genre', () async {
      final list = await service.fetchAnimeByGenre('Action', page: 1, limit: 5);
      expect(list, isA<List<Anime>>());
      expect(list.isNotEmpty, true);
    });

    test('searchAnime returns search results', () async {
      final list = await service.searchAnime('Bleach', page: 1, limit: 3);
      expect(list, isA<List<Anime>>());
      expect(list.isNotEmpty, true);
    });
  });

  group('HomeController Multi-Source Tests', () {
    final controller = HomeController();

    test('fetchPopularAnime caches result', () async {
      final list1 = await controller.fetchPopularAnime(perPage: 5);
      final list2 = await controller.fetchPopularAnime(perPage: 5);
      expect(identical(list1, list2), true);
    });

    test('fetchAnimeByGenreMultiSource combines multiple sources', () async {
      final list = await controller.fetchAnimeByGenreMultiSource('Action', perPage: 6);
      expect(list, isA<List<Anime>>());
      expect(list.isNotEmpty, true);
    });

    test('searchAnime with source switching works', () async {
      final anilistResults = await controller.searchAnime('Naruto', source: 'anilist');
      final kitsuResults = await controller.searchAnime('Naruto', source: 'kitsu');
      final shikimoriResults = await controller.searchAnime('Naruto', source: 'shikimori');

      expect(anilistResults.isNotEmpty, true);
      expect(kitsuResults.isNotEmpty, true);
      expect(shikimoriResults.isNotEmpty, true);
    });
  });
}
