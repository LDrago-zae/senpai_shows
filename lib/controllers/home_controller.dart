import 'package:senpai_shows/controllers/randome_anime_controller.dart';
import 'package:senpai_shows/models/anime_model.dart';
import 'package:senpai_shows/services/anilist_service.dart';
import 'package:senpai_shows/services/shikimori_service.dart';
import 'package:senpai_shows/services/kitsu_service.dart';


class HomeController {
  final AniListApiService _aniListService = AniListApiService();
  final ShikimoriApiService _shikimoriService = ShikimoriApiService();
  final KitsuApiService _kitsuService = KitsuApiService();
  final RandomAnimeController _randomAnimeController = RandomAnimeController();

  List<Anime>? _cachedPopularAnime;
  List<Anime>? _cachedRecentAnime;
  List<Anime>? _cachedShikimoriPopularAnime;
  List<Anime>? _cachedShikimoriRecentAnime;

  Future<List<Anime>> fetchPopularAnime({int perPage = 15}) async {
    if (_cachedPopularAnime != null) {
      return _cachedPopularAnime!;
    }
    final fetchedAnime = await _aniListService.fetchPopularAnime(perPage: perPage);
    _cachedPopularAnime = fetchedAnime;
    return fetchedAnime;
  }

  Future<List<Anime>> fetchRecentAnime({int perPage = 15}) async {
    if (_cachedRecentAnime != null) {
      return _cachedRecentAnime!;
    }
    final fetchedAnime = await _aniListService.fetchRecentAnime(perPage: perPage);
    _cachedRecentAnime = fetchedAnime;
    return fetchedAnime;
  }

  Future<List<Anime>> fetchShikimoriPopularAnime({int limit = 15}) async {
    if (_cachedShikimoriPopularAnime != null) {
      return _cachedShikimoriPopularAnime!;
    }
    final fetchedAnime = await _shikimoriService.fetchPopularAnime(limit: limit);
    _cachedShikimoriPopularAnime = fetchedAnime;
    return fetchedAnime;
  }

  Future<List<Anime>> fetchShikimoriRecentAnime({int limit = 15}) async {
    if (_cachedShikimoriRecentAnime != null) {
      return _cachedShikimoriRecentAnime!;
    }
    final fetchedAnime = await _shikimoriService.fetchRecentAnime(limit: limit);
    _cachedShikimoriRecentAnime = fetchedAnime;
    return fetchedAnime;
  }

  Future<List<Anime>> fetchFeaturedAnime({int limit = 5}) async {
    return await _kitsuService.fetchTopAiringAnime(limit: limit);
  }

  Future<List<Anime>> fetchTrendingAnime({int limit = 10}) async {
    return await _kitsuService.fetchTopAiringAnime(limit: limit);
  }

  Future<List<Anime>> fetchForYouAnime({int limit = 12}) async {
    return await _kitsuService.fetchAnimeList(limit: limit);
  }

  Future<Anime?> fetchRandomAnime() async {
    return await _randomAnimeController.fetchRandomAnime();
  }

  void dispose() {
    // No resources to dispose since no state management or listeners
  }
}