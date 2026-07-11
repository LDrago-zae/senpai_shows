package com.example.senpai_shows

import android.content.Context
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import dalvik.system.DexClassLoader
import java.io.BufferedInputStream
import java.io.File
import java.io.FileOutputStream
import java.net.URL
import java.util.concurrent.Executors

class ExtensionRuntime(private val context: Context) {
  private val executor = Executors.newSingleThreadExecutor()
  private val mainHandler = Handler(Looper.getMainLooper())

  private fun extensionsDir(): File {
    val dir = File(context.filesDir, "extensions")
    if (!dir.exists()) {
      dir.mkdirs()
    }
    return dir
  }

  fun downloadExtension(
    apkUrl: String,
    pkgName: String,
    callback: (Result<Map<String, Any>>) -> Unit
  ) {
    executor.execute {
      runCatching {
        val target = File(extensionsDir(), "$pkgName.apk")
        val bytes = downloadToFile(apkUrl, target)
        mapOf(
          "pkgName" to pkgName,
          "apkPath" to target.absolutePath,
          "bytes" to bytes
        )
      }.also { result ->
        mainHandler.post { callback(result) }
      }
    }
  }

  fun listInstalledExtensions(callback: (Result<List<Map<String, Any>>>) -> Unit) {
    executor.execute {
      runCatching {
        val dir = extensionsDir()
        if (!dir.exists()) return@runCatching emptyList<Map<String, Any>>()

        dir.listFiles { file -> file.extension.lowercase() == "apk" }
          ?.map { file ->
            val info = parsePackageInfo(file)
            if (info == null) {
              mapOf(
                "apkPath" to file.absolutePath,
                "error" to "Invalid APK"
              )
            } else {
              val appName =
                context.packageManager.getApplicationLabel(info.applicationInfo).toString()
              val classes = readExtensionClassNames(info)
              mapOf(
                "pkgName" to info.packageName,
                "versionName" to (info.versionName ?: ""),
                "versionCode" to getVersionCode(info),
                "apkPath" to file.absolutePath,
                "appName" to appName,
                "classes" to classes
              )
            }
          }
          ?: emptyList()
      }.also { result ->
        mainHandler.post { callback(result) }
      }
    }
  }

  fun listExtensionSources(
    pkgName: String,
    callback: (Result<List<Map<String, Any>>>) -> Unit
  ) {
    executor.execute {
      runCatching {
        val apkFile = findExtensionApk(pkgName)
          ?: return@runCatching emptyList<Map<String, Any>>()

        val info = parsePackageInfo(apkFile)
        val classNames = readExtensionClassNames(info)
        classNames.map { className ->
          loadSourceMetadata(apkFile, className)
        }
      }.also { result ->
        mainHandler.post { callback(result) }
      }
    }
  }

  private fun findExtensionApk(pkgName: String): File? {
    val file = File(extensionsDir(), "$pkgName.apk")
    return if (file.exists()) file else null
  }

  private fun parsePackageInfo(apkFile: File): PackageInfo? {
    val pm = context.packageManager
    val info = pm.getPackageArchiveInfo(apkFile.path, PackageManager.GET_META_DATA)
    if (info != null) {
      info.applicationInfo.sourceDir = apkFile.path
      info.applicationInfo.publicSourceDir = apkFile.path
    }
    return info
  }

  private fun readExtensionClassNames(info: PackageInfo?): List<String> {
    val meta = info?.applicationInfo?.metaData ?: return emptyList()
    val raw =
      meta.getString("tachiyomi.extension.class")
        ?: meta.getString("aniyomi.extension.class")
        ?: meta.getString("extension.class")
        ?: return emptyList()

    return raw.split(';').map { it.trim() }.filter { it.isNotEmpty() }
  }

  private fun loadSourceMetadata(apkFile: File, className: String): Map<String, Any> {
    val optimizedDir = File(context.codeCacheDir, "ext_dex")
    if (!optimizedDir.exists()) {
      optimizedDir.mkdirs()
    }

    return try {
      val classLoader = DexClassLoader(
        apkFile.path,
        optimizedDir.path,
        null,
        context.classLoader
      )
      val clazz = Class.forName(className, false, classLoader)
      val instance = clazz.getDeclaredConstructor().newInstance()
      val name = tryInvokeString(instance, "getName") ?: className
      val lang = tryInvokeString(instance, "getLang") ?: ""

      mapOf(
        "className" to className,
        "name" to name,
        "lang" to lang,
        "loaded" to true
      )
    } catch (e: Throwable) {
      mapOf(
        "className" to className,
        "name" to className,
        "lang" to "",
        "loaded" to false,
        "error" to "${e.javaClass.simpleName}: ${e.message ?: "Unknown error"}"
      )
    }
  }

  private fun tryInvokeString(instance: Any, methodName: String): String? {
    return try {
      val method = instance.javaClass.methods.firstOrNull {
        it.name == methodName && it.parameterTypes.isEmpty()
      }
      method?.invoke(instance)?.toString()
    } catch (e: Throwable) {
      null
    }
  }

  private fun getVersionCode(info: PackageInfo): Long {
    return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
      info.longVersionCode
    } else {
      @Suppress("DEPRECATION")
      info.versionCode.toLong()
    }
  }

  private fun downloadToFile(url: String, target: File): Long {
    val connection = URL(url).openConnection()
    connection.connectTimeout = 15000
    connection.readTimeout = 30000

    BufferedInputStream(connection.getInputStream()).use { input ->
      FileOutputStream(target).use { output ->
        val buffer = ByteArray(8192)
        var total = 0L
        var count = input.read(buffer)
        while (count != -1) {
          output.write(buffer, 0, count)
          total += count
          count = input.read(buffer)
        }
        output.flush()
        return total
      }
    }
  }
}
