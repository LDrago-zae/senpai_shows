import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:senpai_shows/models/source_interface.dart';
import 'package:senpai_shows/services/extension_service.dart';

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

  const repoConfigs = [
    ExtensionRepoConfig(
      id: 'yuzono-anime',
      name: 'Yuzono Anime Repo',
      baseUrl: 'https://raw.githubusercontent.com/yuzono/anime-repo/repo',
      type: 'anime',
    ),
    ExtensionRepoConfig(
      id: 'aniyomi',
      name: 'Aniyomi Extensions',
      baseUrl:
          'https://raw.githubusercontent.com/aniyomiorg/aniyomi-extensions/repo',
      type: 'mixed',
    ),
    ExtensionRepoConfig(
      id: 'keiyoushi',
      name: 'Keiyoushi Extensions',
      baseUrl: 'https://raw.githubusercontent.com/keiyoushi/extensions/repo',
      type: 'manga',
    ),
  ];

  group('Extension Models & Direct JSON Parsing Tests', () {
    test('ExtensionRepoItem parses valid JSON correctly', () {
      final json = {
        'name': 'GogoAnime',
        'pkg': 'eu.kanade.tachiyomi.animeextension.en.gogoanime',
        'apk': 'animeextension-en.gogoanime-v14.apk',
        'lang': 'en',
        'code': 14,
        'version': '1.4.14',
        'nsfw': 0,
        'sources': [
          {
            'name': 'Gogoanime',
            'lang': 'en',
            'id': '123456789',
            'baseUrl': 'https://anitaku.to',
          }
        ]
      };

      final item = ExtensionRepoItem.fromJson(json);
      expect(item.name, 'GogoAnime');
      expect(item.pkg, 'eu.kanade.tachiyomi.animeextension.en.gogoanime');
      expect(item.apk, 'animeextension-en.gogoanime-v14.apk');
      expect(item.lang, 'en');
      expect(item.code, 14);
      expect(item.version, '1.4.14');
      expect(item.nsfw, 0);
      expect(item.sources.length, 1);
      expect(item.sources.first.name, 'Gogoanime');
      expect(item.sources.first.id, '123456789');
    });

    test('ExtensionRepoItem handles missing or null fields gracefully', () {
      final json = <String, dynamic>{};
      final item = ExtensionRepoItem.fromJson(json);
      expect(item.name, '');
      expect(item.pkg, '');
      expect(item.apk, '');
      expect(item.lang, '');
      expect(item.code, 0);
      expect(item.sources, isEmpty);
    });

    test('AnimeItem parses correctly', () {
      final json = {
        'url': 'https://example.com/anime/1',
        'title': 'Test Anime',
        'imageUrl': 'https://example.com/cover.jpg',
      };
      final item = AnimeItem.fromJson(json);
      expect(item.url, 'https://example.com/anime/1');
      expect(item.title, 'Test Anime');
      expect(item.imageUrl, 'https://example.com/cover.jpg');
    });

    test('Episode, VideoSource, and MangaPage parse correctly', () {
      final ep = Episode.fromJson({'name': 'Episode 1', 'url': 'https://example.com/ep1'});
      expect(ep.name, 'Episode 1');
      expect(ep.url, 'https://example.com/ep1');

      final vs = VideoSource.fromJson({'quality': '1080p', 'url': 'https://example.com/stream.m3u8'});
      expect(vs.quality, '1080p');
      expect(vs.url, 'https://example.com/stream.m3u8');

      final mp = MangaPage.fromJson({'imageUrl': 'https://example.com/page1.jpg', 'index': 0});
      expect(mp.imageUrl, 'https://example.com/page1.jpg');
      expect(mp.index, 0);
    });
  });

  group('Live Extension Repository Index Network Fetching', () {
    for (final repo in repoConfigs) {
      test('Fetch index for repo: ${repo.name}', () async {
        final indexUrl = '${repo.baseUrl}/index.min.json';
        final response = await http.get(Uri.parse(indexUrl));
        expect(response.statusCode, 200, reason: 'Failed to fetch index from $indexUrl');

        final dynamic decoded = jsonDecode(response.body);
        final List<dynamic> items = decoded is List ? decoded : (decoded['items'] ?? []);
        expect(items.isNotEmpty, true, reason: 'Index for ${repo.name} should not be empty');

        final parsedItems = items
            .whereType<Map>()
            .map((item) => ExtensionRepoItem.fromJson(Map<String, dynamic>.from(item)))
            .toList();

        expect(parsedItems.isNotEmpty, true);
        expect(parsedItems.first.name.isNotEmpty, true);
        expect(parsedItems.first.pkg.isNotEmpty, true);
        expect(parsedItems.first.apk.isNotEmpty, true);
      });
    }
  });

  group('ExtensionService JS Runtime Tests', () {
    late ExtensionService extensionService;

    setUp(() {
      extensionService = ExtensionService();
    });

    tearDown(() {
      extensionService.dispose();
    });

    test('sample_source.js evaluates and fetches popular anime and manga', () async {
      final script = File('assets/extensions/sample_source.js').readAsStringSync();
      extensionService.flutterJs.evaluate(script);

      final animeList = await extensionService.fetchPopular();
      expect(animeList, isA<List<AnimeItem>>());
      expect(animeList.isNotEmpty, true, reason: 'Sample source fetchPopular should return items');
      expect(animeList.first.title.isNotEmpty, true);

      final mangaList = await extensionService.fetchPopularManga();
      expect(mangaList, isA<List<AnimeItem>>());
      expect(mangaList.isNotEmpty, true, reason: 'Sample source fetchPopularManga should return items');
      expect(mangaList.first.title.isNotEmpty, true);

      final episodes = await extensionService.getEpisodes('https://sample.moe/anime/1');
      expect(episodes.length, 5);
      expect(episodes.first.name, 'Episode 1');

      final videoSources = await extensionService.getVideoSources('https://sample.moe/episode/1');
      expect(videoSources.isNotEmpty, true);
      expect(videoSources.first.quality, 'Auto');

      final mangaPages = await extensionService.getMangaPages('https://sample.moe/manga/1');
      expect(mangaPages.length, 5);
      expect(mangaPages.first.imageUrl.isNotEmpty, true);
    });

    test('yuzono_repo.js evaluates and parses repo index from all configured repos', () async {
      final script = File('assets/extensions/yuzono_repo.js').readAsStringSync();
      extensionService.flutterJs.evaluate(script);

      final allExtensions = await extensionService.fetchExtensionIndexes(repoConfigs);
      expect(allExtensions.isNotEmpty, true, reason: 'Should load extensions from all repos');

      final yuzonoExts = allExtensions.where((e) => e.repoId == 'yuzono-anime').toList();
      final aniyomiExts = allExtensions.where((e) => e.repoId == 'aniyomi').toList();
      final keiyoushiExts = allExtensions.where((e) => e.repoId == 'keiyoushi').toList();

      expect(yuzonoExts.isNotEmpty, true, reason: 'Yuzono extensions loaded');
      expect(aniyomiExts.isNotEmpty, true, reason: 'Aniyomi extensions loaded');
      expect(keiyoushiExts.isNotEmpty, true, reason: 'Keiyoushi extensions loaded');

      for (final ext in allExtensions.take(10)) {
        expect(ext.name.isNotEmpty, true);
        expect(ext.pkg.isNotEmpty, true);
        expect(ext.apk.isNotEmpty, true);
      }
    });
  });
}
