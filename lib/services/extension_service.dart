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

    // Inject http client into JS so scripts can fetch data bypassing CORS constraints.
    flutterJs.onMessage('httpGet', (dynamic args) async {
      try {
        // args is already a Map if sent correctly from flutter_js helper
        final String url =
            args is String ? jsonDecode(args)['url'] : args['url'];
        final response = await http.get(Uri.parse(url));
        return {'body': response.body, 'statusCode': response.statusCode};
      } catch (e) {
        return {'error': e.toString()};
      }
    });

    // Provide a simple JS wrapper for the injected Dart method
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

  Future<List<AnimeItem>> fetchPopular() async {
    JsEvalResult result = await flutterJs.evaluateAsync(
      "source.fetchPopular()",
    );
    result = await flutterJs.handlePromise(result);
    if (result.isError) {
      print('Error executing JS: ${result.stringResult}');
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(result.stringResult);
      return jsonList.map((item) => AnimeItem.fromJson(item)).toList();
    } catch (e) {
      print('Error parsing JS output: $e');
      return [];
    }
  }

  Future<List<Episode>> getEpisodes(String animeUrl) async {
    JsEvalResult result = await flutterJs.evaluateAsync(
      "source.getEpisodes('$animeUrl')",
    );
    result = await flutterJs.handlePromise(result);
    if (result.isError) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(result.stringResult);
      return jsonList.map((item) => Episode.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<VideoSource>> getVideoSources(String episodeUrl) async {
    JsEvalResult result = await flutterJs.evaluateAsync(
      "source.getVideoSources('$episodeUrl')",
    );
    result = await flutterJs.handlePromise(result);
    if (result.isError) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(result.stringResult);
      return jsonList.map((item) => VideoSource.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<MangaPage>> getMangaPages(String chapterUrl) async {
    JsEvalResult result = await flutterJs.evaluateAsync(
      "source.getMangaPages('$chapterUrl')",
    );
    result = await flutterJs.handlePromise(result);
    if (result.isError) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(result.stringResult);
      return jsonList.map((item) => MangaPage.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<AnimeItem>> fetchPopularManga() async {
    JsEvalResult result = await flutterJs.evaluateAsync(
      "source.fetchPopularManga()",
    );
    result = await flutterJs.handlePromise(result);
    if (result.isError) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(result.stringResult);
      return jsonList.map((item) => AnimeItem.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<ExtensionRepoItem>> fetchExtensionIndex() async {
    JsEvalResult result = await flutterJs.evaluateAsync(
      "source.fetchExtensionIndex()",
    );
    result = await flutterJs.handlePromise(result);
    if (result.isError) {
      print('Error executing JS: ${result.stringResult}');
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(result.stringResult);
      return jsonList
          .whereType<Map>()
          .map(
            (item) =>
                ExtensionRepoItem.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    } catch (e) {
      print('Error parsing JS output: $e');
      return [];
    }
  }

  Future<List<ExtensionRepoItem>> fetchExtensionIndexForRepo(
    ExtensionRepoConfig repo,
  ) async {
    await flutterJs.evaluateAsync(
      'source.baseUrl = ${jsonEncode(repo.baseUrl)}; '
      'source.name = ${jsonEncode(repo.name)};'
    );

    final items = await fetchExtensionIndex();
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
  }

  Future<List<ExtensionRepoItem>> fetchExtensionIndexes(
    List<ExtensionRepoConfig> repos,
  ) async {
    final results = <ExtensionRepoItem>[];
    for (final repo in repos) {
      results.addAll(await fetchExtensionIndexForRepo(repo));
    }
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
}
