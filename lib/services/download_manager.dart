import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:senpai_shows/database/isar_models.dart';
import 'package:senpai_shows/database/local_database.dart';

class DownloadManager {
  static Future<void> downloadVideo(
    String videoUrl,
    String itemUrl,
    String title,
    String episodeName,
  ) async {
    try {
      // 1. Get destination
      final targetDir = Directory(
        "\${(await getApplicationDocumentsDirectory()).path}/downloads/\${title.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}",
      );
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      final file = File(
        "\${targetDir.path}/\${episodeName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}.mp4",
      );

      // 2. Add pending entry to ISAR
      final record =
          DownloadItem()
            ..itemUrl = itemUrl
            ..episodeOrChapterName = episodeName
            ..episodeOrChapterUrl = videoUrl
            ..localPath = file.path
            ..isCompleted = false;

      await LocalDatabase.saveDownload(record);

      // 3. Download the file streams (Example: basic download)
      // Note: For large files, use flutter_downloader or chunked streaming logic
      var response = await http.get(Uri.parse(videoUrl));
      await file.writeAsBytes(response.bodyBytes);

      // 4. Mark as completed
      record.isCompleted = true;
      await LocalDatabase.saveDownload(record);
    } catch (e) {
      print('Download error: \$e');
    }
  }
}
