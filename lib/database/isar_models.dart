import 'package:isar/isar.dart';

part 'isar_models.g.dart';

@collection
class AniMangaItem {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String url;

  late String title;
  late String imageUrl;
  late String sourceId;
  late bool isManga;

  bool isFavorite = false;
}

@collection
class HistoryItem {
  Id id = Isar.autoIncrement;

  @Index()
  late String itemUrl;

  late String episodeOrChapterName;
  late String episodeOrChapterUrl;

  late int progress; // time in ms or page number
  late int total; // total time or total pages

  late DateTime lastReadAt;
}

@collection
class DownloadItem {
  Id id = Isar.autoIncrement;

  late String itemUrl;
  late String episodeOrChapterName;
  late String episodeOrChapterUrl;

  late String localPath;
  late bool isCompleted;
}
