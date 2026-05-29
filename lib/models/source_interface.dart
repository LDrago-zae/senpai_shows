export 'package:flutter_js/flutter_js.dart';

abstract class ExtensionSource {
  final String id;
  final String name;
  final String version;
  final String baseUrl;

  ExtensionSource({
    required this.id,
    required this.name,
    required this.version,
    required this.baseUrl,
  });
}

class AnimeItem {
  final String url;
  final String title;
  final String imageUrl;

  AnimeItem({required this.url, required this.title, required this.imageUrl});

  factory AnimeItem.fromJson(Map<String, dynamic> json) {
    return AnimeItem(
      url: json['url'] ?? '',
      title: json['title'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}

class ExtensionRepoSource {
  final String name;
  final String lang;
  final String id;
  final String baseUrl;

  ExtensionRepoSource({
    required this.name,
    required this.lang,
    required this.id,
    required this.baseUrl,
  });

  factory ExtensionRepoSource.fromJson(Map<String, dynamic> json) {
    return ExtensionRepoSource(
      name: json['name'] ?? '',
      lang: json['lang'] ?? '',
      id: json['id'] ?? '',
      baseUrl: json['baseUrl'] ?? '',
    );
  }
}

class ExtensionRepoItem {
  final String name;
  final String pkg;
  final String apk;
  final String lang;
  final int code;
  final String version;
  final int nsfw;
  final List<ExtensionRepoSource> sources;

  ExtensionRepoItem({
    required this.name,
    required this.pkg,
    required this.apk,
    required this.lang,
    required this.code,
    required this.version,
    required this.nsfw,
    required this.sources,
  });

  factory ExtensionRepoItem.fromJson(Map<String, dynamic> json) {
    final rawSources = json['sources'];
    final sources =
        rawSources is List
            ? rawSources
                .whereType<Map>()
                .map(
                  (item) => ExtensionRepoSource.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
            : <ExtensionRepoSource>[];

    return ExtensionRepoItem(
      name: json['name'] ?? '',
      pkg: json['pkg'] ?? '',
      apk: json['apk'] ?? '',
      lang: json['lang'] ?? '',
      code: json['code'] ?? 0,
      version: json['version'] ?? '',
      nsfw: json['nsfw'] ?? 0,
      sources: sources,
    );
  }
}

class Episode {
  final String name;
  final String url;

  Episode({required this.name, required this.url});

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(name: json['name'] ?? '', url: json['url'] ?? '');
  }
}

class VideoSource {
  final String url;
  final String quality;

  VideoSource({required this.url, required this.quality});

  factory VideoSource.fromJson(Map<String, dynamic> json) {
    return VideoSource(url: json['url'] ?? '', quality: json['quality'] ?? '');
  }
}

class MangaPage {
  final String imageUrl;
  final int index;

  MangaPage({required this.imageUrl, required this.index});

  factory MangaPage.fromJson(Map<String, dynamic> json) {
    return MangaPage(
      imageUrl: json['imageUrl'] ?? '',
      index: json['index'] ?? 0,
    );
  }
}
