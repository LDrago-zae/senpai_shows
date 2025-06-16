import 'dart:typed_data';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class ImageCacheHelper {
  static final ImageCacheHelper _instance = ImageCacheHelper._internal();
  factory ImageCacheHelper() => _instance;
  ImageCacheHelper._internal();

  Database? _database;
  static const int _cacheDurationMs = 2 * 24 * 60 * 60 * 1000; // 2 days in milliseconds

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'image_cache.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE images (
            id TEXT PRIMARY KEY,
            imageUrl TEXT NOT NULL,
            imageData BLOB NOT NULL,
            timestamp INTEGER NOT NULL
          )
        ''');
        await db.execute('CREATE INDEX idx_image_url ON images (imageUrl)');
      },
    );
  }

  Future<Uint8List?> getCachedImage(String id) async {
    await cleanExpiredImages();
    final db = await database;
    final result = await db.query(
      'images',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      final timestamp = result.first['timestamp'] as int;
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - timestamp <= _cacheDurationMs) {
        return result.first['imageData'] as Uint8List?;
      } else {
        // Delete expired image
        await db.delete(
          'images',
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    }
    return null;
  }

  Future<void> cacheImage(String id, String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final imageData = response.bodyBytes;
        final db = await database;
        await db.insert(
          'images',
          {
            'id': id,
            'imageUrl': imageUrl,
            'imageData': imageData,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    } catch (e) {
      print('Error caching image $imageUrl: $e');
    }
  }

  Future<void> cleanExpiredImages() async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.delete(
      'images',
      where: 'timestamp < ?',
      whereArgs: [now - _cacheDurationMs],
    );
  }

  Future<void> clearCache() async {
    final db = await database;
    await db.delete('images');
  }

  // New method to get cached image by URL directly
  Future<Uint8List?> getCachedImageByUrl(String imageUrl) async {
    await cleanExpiredImages();
    final db = await database;
    final result = await db.query(
      'images',
      where: 'imageUrl = ?',
      whereArgs: [imageUrl],
    );
    if (result.isNotEmpty) {
      final timestamp = result.first['timestamp'] as int;
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - timestamp <= _cacheDurationMs) {
        return result.first['imageData'] as Uint8List?;
      } else {
        await db.delete(
          'images',
          where: 'imageUrl = ?',
          whereArgs: [imageUrl],
        );
      }
    }
    return null;
  }
}