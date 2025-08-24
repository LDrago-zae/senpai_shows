// import 'package:jikan_api/jikan_api.dart' hide Anime;
// import '../models/anime_model.dart';
//
// class JikanApiService {
//   final Jikan _jikan = Jikan();
//
//   // Fetches top anime with only title and image
//   Future<List<Anime>> fetchTopAnime({
//     TopType type = TopType.anime,
//     TopSubtype subtype = TopSubtype.bypopularity,
//     int limit = 10,
//   }) async {
//     try {
//       final topList = await _jikan.getTop(type, subtype: subtype);
//       return topList.take(limit).map((top) => Anime(
//         title: top.title ?? 'No Title',
//         imageUrl: top.imageUrl ?? '', id: top.malId,
//       )).toList();
//     } catch (e) {
//       throw Exception('Failed to load top anime: $e');
//     }
//   }
//
//   // Fetches current season anime with only title and image
//   Future<List<Anime>> fetchCurrentSeasonAnime({
//     int limit = 10,
//   }) async {
//     try {
//       final now = DateTime.now();
//       final season = await _jikan.getSeason(now.year, _getCurrentSeason(now));
//       return season.anime.take(limit).map((anime) => Anime(
//         title: anime.title ?? 'No Title',
//         imageUrl: anime.imageUrl ?? '',
//       )).toList();
//     } catch (e) {
//       throw Exception('Failed to load seasonal anime: $e');
//     }
//   }
//
//   // Helper method to determine current season
//   SeasonType _getCurrentSeason(DateTime date) {
//     final month = date.month;
//     if (month >= 3 && month <= 5) return SeasonType.spring;
//     if (month >= 6 && month <= 8) return SeasonType.summer;
//     if (month >= 9 && month <= 11) return SeasonType.fall;
//     return SeasonType.winter;
//   }
//
//   // Fetches anime schedule with only title and image
//   Future<List<Anime>> fetchSchedule({
//     WeekDay weekday = WeekDay.monday,
//     int limit = 10,
//   }) async {
//     try {
//       final schedule = await _jikan.getSchedule(weekday: weekday);
//       return schedule.take(limit).map((anime) => Anime(
//         title: anime.title ?? 'No Title',
//         imageUrl: anime.imageUrl ?? '',
//       )).toList();
//     } catch (e) {
//       throw Exception('Failed to load schedule: $e');
//     }
//   }
//
//   // Fetches anime by genre with only title and image
//   Future<List<Anime>> fetchAnimeByGenre({
//     Genre genre = Genre.action,
//     int limit = 10,
//   }) async {
//     try {
//       final genreList = await _jikan.getGenre(GenreType.anime, genre);
//       return genreList.anime.take(limit).map((anime) => Anime(
//         title: anime.title ?? 'No Title',
//         imageUrl: anime.imageUrl ?? '',
//       )).toList();
//     } catch (e) {
//       throw Exception('Failed to load genre anime: $e');
//     }
//   }
// }