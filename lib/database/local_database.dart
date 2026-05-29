import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:senpai_shows/database/isar_models.dart';

class LocalDatabase {
  static late Isar isar;

  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([
      AniMangaItemSchema,
      HistoryItemSchema,
      DownloadItemSchema,
    ], directory: dir.path);
  }

  // --- AniMangaItem Methods ---

  static Future<void> saveItem(AniMangaItem item) async {
    await isar.writeTxn(() async {
      await isar.aniMangaItems.put(item);
    });
  }

  static Future<List<AniMangaItem>> getFavorites() async {
    return await isar.aniMangaItems.filter().isFavoriteEqualTo(true).findAll();
  }

  // --- HistoryItem Methods ---

  static Future<void> updateHistory(HistoryItem history) async {
    await isar.writeTxn(() async {
      await isar.historyItems.put(history);
    });
  }

  static Future<HistoryItem?> getHistory(String itemUrl) async {
    return await isar.historyItems.filter().itemUrlEqualTo(itemUrl).findFirst();
  }

  // --- DownloadItem Methods ---
  static Future<void> saveDownload(DownloadItem download) async {
    await isar.writeTxn(() async {
      await isar.downloadItems.put(download);
    });
  }

  static Future<List<DownloadItem>> getCompletedDownloads() async {
    return await isar.downloadItems.filter().isCompletedEqualTo(true).findAll();
  }
}
