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
					else -> result.notImplemented()
				}
			}
	}
}
