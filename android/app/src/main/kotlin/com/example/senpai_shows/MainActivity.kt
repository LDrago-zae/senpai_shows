package com.example.senpai_shows

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	private val channelName = "senpai/extensions"
	private lateinit var extensionRuntime: ExtensionRuntime

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)
		extensionRuntime = ExtensionRuntime(applicationContext)

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
			.setMethodCallHandler { call, result ->
				when (call.method) {
					"downloadExtension" -> {
						val apkUrl = call.argument<String>("apkUrl")
						val pkgName = call.argument<String>("pkgName")
						if (apkUrl.isNullOrBlank() || pkgName.isNullOrBlank()) {
							result.error("invalid_args", "apkUrl and pkgName are required", null)
							return@setMethodCallHandler
						}

						extensionRuntime.downloadExtension(apkUrl, pkgName) { outcome ->
							outcome.fold(
								onSuccess = { payload -> result.success(payload) },
								onFailure = { error ->
									result.error("download_failed", error.message, null)
								}
							)
						}
					}
					"listInstalledExtensions" -> {
						extensionRuntime.listInstalledExtensions { outcome ->
							outcome.fold(
								onSuccess = { payload -> result.success(payload) },
								onFailure = { error ->
									result.error("list_failed", error.message, null)
								}
							)
						}
					}
					"listExtensionSources" -> {
						val pkgName = call.argument<String>("pkgName")
						if (pkgName.isNullOrBlank()) {
							result.error("invalid_args", "pkgName is required", null)
							return@setMethodCallHandler
						}

						extensionRuntime.listExtensionSources(pkgName) { outcome ->
							outcome.fold(
								onSuccess = { payload -> result.success(payload) },
								onFailure = { error ->
									result.error("list_failed", error.message, null)
								}
							)
						}
					}
					"fetchPopularNative" -> {
						val sourceId = call.argument<String>("sourceId")
						val isManga = call.argument<Boolean>("isManga") ?: false
						val page = call.argument<Int>("page") ?: 1
						if (sourceId.isNullOrBlank()) {
							result.error("invalid_args", "sourceId is required", null)
							return@setMethodCallHandler
						}

						extensionRuntime.fetchPopularNative(sourceId, isManga, page) { outcome ->
							outcome.fold(
								onSuccess = { payload -> result.success(payload) },
								onFailure = { error ->
									result.error("fetch_failed", error.message, null)
								}
							)
						}
					}
					"getEpisodesNative" -> {
						val sourceId = call.argument<String>("sourceId")
						val animeUrl = call.argument<String>("animeUrl")
						if (sourceId.isNullOrBlank() || animeUrl.isNullOrBlank()) {
							result.error("invalid_args", "sourceId and animeUrl are required", null)
							return@setMethodCallHandler
						}

						extensionRuntime.getEpisodesNative(sourceId, animeUrl) { outcome ->
							outcome.fold(
								onSuccess = { payload -> result.success(payload) },
								onFailure = { error ->
									result.error("fetch_failed", error.message, null)
								}
							)
						}
					}
					"getVideoSourcesNative" -> {
						val sourceId = call.argument<String>("sourceId")
						val episodeUrl = call.argument<String>("episodeUrl")
						if (sourceId.isNullOrBlank() || episodeUrl.isNullOrBlank()) {
							result.error("invalid_args", "sourceId and episodeUrl are required", null)
							return@setMethodCallHandler
						}

						extensionRuntime.getVideoSourcesNative(sourceId, episodeUrl) { outcome ->
							outcome.fold(
								onSuccess = { payload -> result.success(payload) },
								onFailure = { error ->
									result.error("fetch_failed", error.message, null)
								}
							)
						}
					}
					"getMangaPagesNative" -> {
						val sourceId = call.argument<String>("sourceId")
						val chapterUrl = call.argument<String>("chapterUrl")
						if (sourceId.isNullOrBlank() || chapterUrl.isNullOrBlank()) {
							result.error("invalid_args", "sourceId and chapterUrl are required", null)
							return@setMethodCallHandler
						}

						extensionRuntime.getMangaPagesNative(sourceId, chapterUrl) { outcome ->
							outcome.fold(
								onSuccess = { payload -> result.success(payload) },
								onFailure = { error ->
									result.error("fetch_failed", error.message, null)
								}
							)
						}
					}
					else -> result.notImplemented()
				}
			}
	}
}
