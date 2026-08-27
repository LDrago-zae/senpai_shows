import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:senpai_shows/models/source_interface.dart';
import 'package:http/http.dart' as http;

class ExtensionService {
  late JavascriptRuntime flutterJs;
  static const MethodChannel _extensionChannel = MethodChannel(
    'senpai/extensions',
  );

  ExtensionService() {
    initJsEngine();
  }

  void initJsEngine() {
    flutterJs = getJavascriptRuntime();

    // Inject http client into JS for backward compatibility with repo scripts.
    // Note: async sendMessage bridge is unreliable in flutter_js, so
    // fetchPopular/fetchPopularManga use the Dart-side prefetch pattern instead.
    flutterJs.onMessage('httpGet', (dynamic args) async {
      try {
        final String url =
            args is String ? jsonDecode(args)['url'] : args['url'];
        debugPrint('[ExtensionService] httpGet: $url');
        final response = await http.get(Uri.parse(url));
        return {'body': response.body, 'statusCode': response.statusCode};
      } catch (e) {
        debugPrint('[ExtensionService] httpGet error: $e');
        return {'error': e.toString()};
      }
    });

    // JS wrapper kept for scripts that may still use it (e.g. yuzono_repo.js fetchExtensionIndex)
    flutterJs.evaluate('''
      const httpClient = {
        get: async function(url) {
          return new Promise((resolve) => {
            sendMessage('httpGet', JSON.stringify({url: url})).then((res) => {
              if (typeof res === 'string') {
                try {
                  resolve(JSON.parse(res));
                } catch(e) {
                  resolve(res);
                }
              } else {
                resolve(res);
              }
            });
          });
        }
      };
    ''');
  }

  Future<void> loadExtensionFromAssets(String assetPath) async {
    final scriptContent = await rootBundle.loadString(assetPath);
    flutterJs.evaluate(scriptContent);
  }

  /// Performs an HTTP GET in Dart, injects the response body into JS as
  /// `__prefetchedBody`, then calls the given synchronous JS function.
  /// This bypasses the broken flutter_js async sendMessage bridge.
  Future<String> _prefetchAndCallJs(String url, String jsCall) async {
    debugPrint('[ExtensionService] Prefetching: $url');
    try {
      final response = await http.get(Uri.parse(url));
      debugPrint('[ExtensionService] HTTP ${response.statusCode} for $url');

      if (response.statusCode != 200) {
        debugPrint('[ExtensionService] Non-200 response body: ${response.body.length > 200 ? response.body.substring(0, 200) : response.body}');
        flutterJs.evaluate('var __prefetchedBody = null;');
        final fallbackResult = flutterJs.evaluate(jsCall);
        return fallbackResult.isError ? '[]' : fallbackResult.stringResult;
      }

      // Inject the fetched body into JS as a global variable
      final escapedBody = jsonEncode(response.body);
      flutterJs.evaluate('var __prefetchedBody = $escapedBody;');

      // Call the synchronous JS function
      final result = flutterJs.evaluate(jsCall);
      if (result.isError) {
        debugPrint('[ExtensionService] JS eval error for $jsCall: ${result.stringResult}');
        return '[]';
      }
      return result.stringResult;
    } catch (e) {
      debugPrint('[ExtensionService] Prefetch failed for $url: $e');
      flutterJs.evaluate('var __prefetchedBody = null;');
      final fallbackResult = flutterJs.evaluate(jsCall);
      return fallbackResult.isError ? '[]' : fallbackResult.stringResult;
    }
  }

  /// Computes the genre ID hash from the source name (mirrors JS logic).
  int _hashGenreId(String? name) {
    int genreId = 1;
    if (name != null && name.isNotEmpty) {
      int hash = 0;
      for (int i = 0; i < name.length; i++) {
        hash = name.codeUnitAt(i) + ((hash << 5) - hash);
      }
      genreId = (hash.abs() % 20) + 1;
    }
    return genreId;
  }

  /// Reads the current source.name from JS to compute genre hash.
  String? _getSourceName() {
    try {
      final result = flutterJs.evaluate('source.name');
      return result.isError ? null : result.stringResult;
    } catch (_) {
      return null;
    }
  }

  /// Reads the current source.baseUrl from JS.
  String _getSourceBaseUrl() {
    try {
      final result = flutterJs.evaluate('source.baseUrl');
      return result.isError ? 'https://api.jikan.moe/v4' : result.stringResult;
    } catch (_) {
      return 'https://api.jikan.moe/v4';
    }
  }

  Future<List<AnimeItem>> fetchPopular() async {
    final baseUrl = _getSourceBaseUrl();
    final genreId = _hashGenreId(_getSourceName());
    final url = '$baseUrl/anime?genres=$genreId&order_by=popularity&sort=desc';

    debugPrint('[ExtensionService] fetchPopular() — genre=$genreId, url=$url');
    final resultStr = await _prefetchAndCallJs(url, 'source.fetchPopular()');

    try {
      final List<dynamic> jsonList = jsonDecode(resultStr);
      debugPrint('[ExtensionService] fetchPopular() loaded ${jsonList.length} items.');
      return jsonList.map((item) => AnimeItem.fromJson(item)).toList();
    } catch (e) {
      debugPrint('[ExtensionService] fetchPopular() parse error: $e');
      return [];
    }
  }

  Future<List<Episode>> getEpisodes(String animeUrl) async {
    // Episodes don't need HTTP — they're static in the sample source
    final result = flutterJs.evaluate("source.getEpisodes('$animeUrl')");
    if (result.isError) {
      debugPrint('[ExtensionService] getEpisodes() error: ${result.stringResult}');
      return [];
    }
    try {
      final List<dynamic> jsonList = jsonDecode(result.stringResult);
      debugPrint('[ExtensionService] getEpisodes() loaded ${jsonList.length} episodes.');
      return jsonList.map((item) => Episode.fromJson(item)).toList();
    } catch (e) {
      debugPrint('[ExtensionService] getEpisodes() parse error: $e');
      return [];
    }
  }

  Future<List<VideoSource>> getVideoSources(String episodeUrl) async {
    // Video sources don't need HTTP — they're static in the sample source
    final result = flutterJs.evaluate("source.getVideoSources('$episodeUrl')");
    if (result.isError) {
      debugPrint('[ExtensionService] getVideoSources() error: ${result.stringResult}');
      return [];
    }
    try {
      final List<dynamic> jsonList = jsonDecode(result.stringResult);
      debugPrint('[ExtensionService] getVideoSources() loaded ${jsonList.length} sources.');
      return jsonList.map((item) => VideoSource.fromJson(item)).toList();
    } catch (e) {
      debugPrint('[ExtensionService] getVideoSources() parse error: $e');
      return [];
    }
  }

  Future<List<MangaPage>> getMangaPages(String chapterUrl) async {
    // Manga pages don't need HTTP — they're static in the sample source
    final result = flutterJs.evaluate("source.getMangaPages('$chapterUrl')");
    if (result.isError) {
      debugPrint('[ExtensionService] getMangaPages() error: ${result.stringResult}');
      return [];
    }
    try {
      final List<dynamic> jsonList = jsonDecode(result.stringResult);
      debugPrint('[ExtensionService] getMangaPages() loaded ${jsonList.length} pages.');
      return jsonList.map((item) => MangaPage.fromJson(item)).toList();
    } catch (e) {
      debugPrint('[ExtensionService] getMangaPages() parse error: $e');
      return [];
    }
  }

  Future<List<AnimeItem>> fetchPopularManga() async {
    final baseUrl = _getSourceBaseUrl();
    final genreId = _hashGenreId(_getSourceName());
    final url = '$baseUrl/manga?genres=$genreId&order_by=popularity&sort=desc';

    debugPrint('[ExtensionService] fetchPopularManga() — genre=$genreId, url=$url');
    final resultStr = await _prefetchAndCallJs(url, 'source.fetchPopularManga()');

    try {
      final List<dynamic> jsonList = jsonDecode(resultStr);
      debugPrint('[ExtensionService] fetchPopularManga() loaded ${jsonList.length} items.');
      return jsonList.map((item) => AnimeItem.fromJson(item)).toList();
    } catch (e) {
      debugPrint('[ExtensionService] fetchPopularManga() parse error: $e');
      return [];
    }
  }

  Future<List<ExtensionRepoItem>> fetchExtensionIndex() async {
    // Read the current baseUrl from JS (set by fetchExtensionIndexForRepo)
    final baseUrl = _getSourceBaseUrl();
    final indexUrl = '$baseUrl/index.min.json';

    try {
      final resultStr = await _prefetchAndCallJs(
        indexUrl,
        'source.fetchExtensionIndex()',
      );

      final List<dynamic> jsonList = jsonDecode(resultStr);
      return jsonList
          .whereType<Map>()
          .map(
            (item) =>
                ExtensionRepoItem.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    } catch (e) {
      debugPrint('[ExtensionService] fetchExtensionIndex() error: $e');
      return [];
    }
  }

  Future<List<ExtensionRepoItem>> fetchExtensionIndexForRepo(
    ExtensionRepoConfig repo,
  ) async {
    try {
      // Set source.baseUrl and source.name in JS synchronously
      flutterJs.evaluate(
        'source.baseUrl = ${jsonEncode(repo.baseUrl)}; '
        'source.name = ${jsonEncode(repo.name)};'
      );

      final items = await fetchExtensionIndex();
      if (items.isEmpty) {
        debugPrint('[ExtensionService] Repo "${repo.name}" returned no items.');
      } else {
        debugPrint('[ExtensionService] Repo "${repo.name}" loaded ${items.length} items.');
      }
      return items
          .map(
            (item) => item.copyWith(
              repoId: repo.id,
              repoName: repo.name,
              repoUrl: repo.baseUrl,
              repoType: repo.type,
            ),
          )
          .toList();
    } catch (e) {
      debugPrint('[ExtensionService] Repo "${repo.name}" failed: $e');
      return [];
    }
  }

  Future<List<ExtensionRepoItem>> fetchExtensionIndexes(
    List<ExtensionRepoConfig> repos,
  ) async {
    final results = <ExtensionRepoItem>[];
    debugPrint('[ExtensionService] Loading extension indexes from ${repos.length} repos...');
    for (final repo in repos) {
      try {
        final repoItems = await fetchExtensionIndexForRepo(repo);
        results.addAll(repoItems);
      } catch (e) {
        debugPrint('[ExtensionService] Repo "${repo.name}" failed: $e');
      }
    }
    debugPrint('[ExtensionService] Total extensions loaded: ${results.length}');
    return results;
  }

  void dispose() {
    flutterJs.dispose();
  }

  bool get isAndroidRuntimeAvailable {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  }

  Future<Map<String, dynamic>?> downloadExtensionApk({
    required String apkUrl,
    required String pkgName,
  }) async {
    if (!isAndroidRuntimeAvailable) return null;
    final result = await _extensionChannel.invokeMethod<Map>(
      'downloadExtension',
      {'apkUrl': apkUrl, 'pkgName': pkgName},
    );
    return result?.cast<String, dynamic>();
  }

  Future<List<Map<String, dynamic>>> listInstalledExtensions() async {
    if (!isAndroidRuntimeAvailable) return [];
    final result = await _extensionChannel.invokeMethod<List>(
      'listInstalledExtensions',
    );
    return result
            ?.whereType<Map>()
            .map((item) => item.cast<String, dynamic>())
            .toList() ??
        [];
  }

  Future<List<Map<String, dynamic>>> listExtensionSources({
    required String pkgName,
  }) async {
    if (!isAndroidRuntimeAvailable) return [];
    final result = await _extensionChannel.invokeMethod<List>(
      'listExtensionSources',
      {'pkgName': pkgName},
    );
    return result
            ?.whereType<Map>()
            .map((item) => item.cast<String, dynamic>())
            .toList() ??
        [];
  }

  // --- NATIVE CONTENT LOADING BRIDGE METHODS ---

  Future<List<AnimeItem>> fetchPopularNative({
    required String sourceId,
    required bool isManga,
    int page = 1,
  }) async {
    if (!isAndroidRuntimeAvailable) return [];
    try {
      final result = await _extensionChannel.invokeMethod<List>(
        'fetchPopularNative',
        {
          'sourceId': sourceId,
          'isManga': isManga,
          'page': page,
        },
      );
      if (result == null) return [];
      return result
          .whereType<Map>()
          .map((item) => AnimeItem.fromJson(item.cast<String, dynamic>()))
          .toList();
    } catch (e) {
      debugPrint('[ExtensionService] fetchPopularNative error: $e');
      return [];
    }
  }

  Future<List<Episode>> getEpisodesNative({
    required String sourceId,
    required String animeUrl,
  }) async {
    if (!isAndroidRuntimeAvailable) return [];
    try {
      final result = await _extensionChannel.invokeMethod<List>(
        'getEpisodesNative',
        {
          'sourceId': sourceId,
          'animeUrl': animeUrl,
        },
      );
      if (result == null) return [];
      return result
          .whereType<Map>()
          .map((item) => Episode.fromJson(item.cast<String, dynamic>()))
          .toList();
    } catch (e) {
      debugPrint('[ExtensionService] getEpisodesNative error: $e');
      return [];
    }
  }

  Future<List<VideoSource>> getVideoSourcesNative({
    required String sourceId,
    required String episodeUrl,
  }) async {
    if (!isAndroidRuntimeAvailable) return [];
    try {
      final result = await _extensionChannel.invokeMethod<List>(
        'getVideoSourcesNative',
        {
          'sourceId': sourceId,
          'episodeUrl': episodeUrl,
        },
      );
      if (result == null) return [];
      return result
          .whereType<Map>()
          .map((item) => VideoSource.fromJson(item.cast<String, dynamic>()))
          .toList();
    } catch (e) {
      debugPrint('[ExtensionService] getVideoSourcesNative error: $e');
      return [];
    }
  }

  Future<List<MangaPage>> getMangaPagesNative({
    required String sourceId,
    required String chapterUrl,
  }) async {
    if (!isAndroidRuntimeAvailable) return [];
    try {
      final result = await _extensionChannel.invokeMethod<List>(
        'getMangaPagesNative',
        {
          'sourceId': sourceId,
          'chapterUrl': chapterUrl,
        },
      );
      if (result == null) return [];
      return result
          .whereType<Map>()
          .map((item) => MangaPage.fromJson(item.cast<String, dynamic>()))
          .toList();
    } catch (e) {
      debugPrint('[ExtensionService] getMangaPagesNative error: $e');
      return [];
    }
  }
}
