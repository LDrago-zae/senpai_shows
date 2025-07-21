import 'package:senpai_shows/models/anime_model.dart';
import 'package:senpai_shows/services/anilist_service.dart';

class RandomAnimeController {
  final AniListApiService _aniListService = AniListApiService();

  Future<Anime?> fetchRandomAnime() async {
    return await _aniListService.fetchRandomAnime();
  }
}