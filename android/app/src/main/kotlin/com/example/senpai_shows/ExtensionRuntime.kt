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
            makeFileReadOnly(file)
            val info = parsePackageInfo(file)
            if (info == null) {
              mapOf(
                "apkPath" to file.absolutePath,
                "error" to "Invalid APK"
              )
            } else {
              val appName = info.applicationInfo?.let {
                context.packageManager.getApplicationLabel(it).toString()
              } ?: info.packageName
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
      info.applicationInfo?.sourceDir = apkFile.path
      info.applicationInfo?.publicSourceDir = apkFile.path
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
      makeFileReadOnly(apkFile)
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

  private fun makeFileReadOnly(file: File) {
    file.setReadable(true, false)
    file.setWritable(false, false)
  }

  private fun makeFileWritable(file: File) {
    file.setWritable(true, false)
    file.setReadable(true, false)
  }

  private fun downloadToFile(url: String, target: File): Long {
    if (target.exists()) {
      makeFileWritable(target)
    }
    val connection = URL(url).openConnection()
    connection.connectTimeout = 15000
    connection.readTimeout = 30000

    val total = BufferedInputStream(connection.getInputStream()).use { input ->
      FileOutputStream(target).use { output ->
        val buffer = ByteArray(8192)
        var totalBytes = 0L
        var count = input.read(buffer)
        while (count != -1) {
          output.write(buffer, 0, count)
          totalBytes += count
          count = input.read(buffer)
        }
        output.flush()
        totalBytes
      }
    }
    makeFileReadOnly(target)
    return total
  }

  // --- NATIVE EXTENSION CONTENT LOADING CODE ---

  private fun getSourceId(source: Any): Long? {
    return try {
      val method = source.javaClass.methods.firstOrNull { it.name == "getId" || it.name == "id" }
      (method?.invoke(source) as? Number)?.toLong()
    } catch (e: Throwable) {
      null
    }
  }

  private fun createInterfaceInstance(className: String, classLoader: ClassLoader): Any {
    val clazz = Class.forName(className, true, classLoader)
    return try {
      val companionField = clazz.getField("Companion")
      val companionObj = companionField.get(null)
      companionObj.javaClass.getMethod("create").invoke(companionObj)
    } catch (e: Throwable) {
      clazz.getMethod("create").invoke(null)
    }
  }

  private fun findSourceAndClassLoader(sourceId: String): Pair<Any, DexClassLoader>? {
    val dir = extensionsDir()
    if (!dir.exists()) return null

    val apkFiles = dir.listFiles { file -> file.extension.lowercase() == "apk" } ?: return null
    val optimizedDir = File(context.codeCacheDir, "ext_dex")
    if (!optimizedDir.exists()) {
      optimizedDir.mkdirs()
    }

    for (file in apkFiles) {
      makeFileReadOnly(file)
      val info = parsePackageInfo(file) ?: continue
      val classNames = readExtensionClassNames(info)
      val classLoader = DexClassLoader(file.path, optimizedDir.path, null, context.classLoader)

      for (className in classNames) {
        try {
          val clazz = Class.forName(className, false, classLoader)
          val instance = clazz.getDeclaredConstructor().newInstance()
          val createSourcesMethod = clazz.methods.firstOrNull { it.name == "createSources" }
          val sources = if (createSourcesMethod != null) {
            createSourcesMethod.invoke(instance) as? List<*> ?: emptyList<Any>()
          } else {
            listOf(instance)
          }

          for (source in sources) {
            if (source != null && getSourceId(source).toString() == sourceId) {
              return Pair(source, classLoader)
            }
          }
        } catch (e: Throwable) {
          e.printStackTrace()
          // Skip classes that cannot be loaded/instantiated
        }
      }
    }
    return null
  }

  fun fetchPopularNative(
    sourceId: String,
    isManga: Boolean,
    page: Int,
    callback: (Result<List<Map<String, Any>>>) -> Unit
  ) {
    executor.execute {
      runCatching {
        val (source, classLoader) = findSourceAndClassLoader(sourceId)
          ?: throw Exception("Extension source with ID $sourceId is not installed.")

        val methodName = if (isManga) "fetchPopularManga" else "fetchPopularAnime"
        val popularMethod = source.javaClass.methods.firstOrNull {
          (it.name == methodName || it.name == "fetchPopular") &&
          it.parameterTypes.size == 1 &&
          (it.parameterTypes[0] == Int::class.java || it.parameterTypes[0] == Integer::class.java)
        } ?: throw Exception("Method $methodName not found on source.")

        val observable = popularMethod.invoke(source, page) as? rx.Observable<*>
          ?: throw Exception("Method $methodName did not return an RxJava Observable.")

        val resultPage = observable.toBlocking().first()
          ?: throw Exception("Observable returned no result page.")

        val getListMethod = resultPage.javaClass.methods.firstOrNull {
          it.name == "getMangas" || it.name == "getAnimes" || it.name == "mangas" || it.name == "animes"
        } ?: throw Exception("Could not find list getter on result page.")

        val itemsList = getListMethod.invoke(resultPage) as? List<*> ?: emptyList<Any>()

        itemsList.mapNotNull { item ->
          if (item == null) return@mapNotNull null
          val url = tryInvokeString(item, "getUrl") ?: tryInvokeString(item, "url") ?: ""
          val title = tryInvokeString(item, "getTitle") ?: tryInvokeString(item, "title") ?: ""
          val thumbnailUrl = tryInvokeString(item, "getThumbnail_url")
            ?: tryInvokeString(item, "thumbnail_url")
            ?: tryInvokeString(item, "thumbnailUrl")
            ?: ""

          mapOf(
            "url" to url,
            "title" to title,
            "imageUrl" to thumbnailUrl
          )
        }
      }.also { result ->
        mainHandler.post { callback(result) }
      }
    }
  }

  fun getEpisodesNative(
    sourceId: String,
    animeUrl: String,
    callback: (Result<List<Map<String, Any>>>) -> Unit
  ) {
    executor.execute {
      runCatching {
        val (source, classLoader) = findSourceAndClassLoader(sourceId)
          ?: throw Exception("Extension source with ID $sourceId is not installed.")

        val sAnimeInstance = createInterfaceInstance("eu.kanade.tachiyomi.animesource.model.SAnime", classLoader)
        sAnimeInstance.javaClass.getMethod("setUrl", String::class.java).invoke(sAnimeInstance, animeUrl)

        val fetchEpisodeListMethod = source.javaClass.methods.firstOrNull {
          it.name == "fetchEpisodeList" &&
          it.parameterTypes.size == 1 &&
          it.parameterTypes[0].name.contains("SAnime")
        } ?: throw Exception("fetchEpisodeList method not found on source.")

        val observable = fetchEpisodeListMethod.invoke(source, sAnimeInstance) as? rx.Observable<*>
          ?: throw Exception("fetchEpisodeList did not return an RxJava Observable.")

        val episodesList = observable.toBlocking().first() as? List<*> ?: emptyList<Any>()

        episodesList.mapNotNull { episode ->
          if (episode == null) return@mapNotNull null
          val name = tryInvokeString(episode, "getName") ?: tryInvokeString(episode, "name") ?: ""
          val url = tryInvokeString(episode, "getUrl") ?: tryInvokeString(episode, "url") ?: ""
          mapOf(
            "name" to name,
            "url" to url
          )
        }
      }.also { result ->
        mainHandler.post { callback(result) }
      }
    }
  }

  fun getVideoSourcesNative(
    sourceId: String,
    episodeUrl: String,
    callback: (Result<List<Map<String, Any>>>) -> Unit
  ) {
    executor.execute {
      runCatching {
        val (source, classLoader) = findSourceAndClassLoader(sourceId)
          ?: throw Exception("Extension source with ID $sourceId is not installed.")

        val sEpisodeInstance = createInterfaceInstance("eu.kanade.tachiyomi.animesource.model.SEpisode", classLoader)
        sEpisodeInstance.javaClass.getMethod("setUrl", String::class.java).invoke(sEpisodeInstance, episodeUrl)

        val fetchVideoListMethod = source.javaClass.methods.firstOrNull {
          it.name == "fetchVideoList" &&
          it.parameterTypes.size == 1 &&
          it.parameterTypes[0].name.contains("SEpisode")
        } ?: throw Exception("fetchVideoList method not found on source.")

        val observable = fetchVideoListMethod.invoke(source, sEpisodeInstance) as? rx.Observable<*>
          ?: throw Exception("fetchVideoList did not return an RxJava Observable.")

        val videosList = observable.toBlocking().first() as? List<*> ?: emptyList<Any>()

        videosList.mapNotNull { video ->
          if (video == null) return@mapNotNull null
          val url = tryInvokeString(video, "getUrl") ?: tryInvokeString(video, "videoUrl") ?: tryInvokeString(video, "url") ?: ""
          val quality = tryInvokeString(video, "getQuality") ?: tryInvokeString(video, "quality") ?: ""
          mapOf(
            "url" to url,
            "quality" to quality
          )
        }
      }.also { result ->
        mainHandler.post { callback(result) }
      }
    }
  }

  fun getMangaPagesNative(
    sourceId: String,
    chapterUrl: String,
    callback: (Result<List<Map<String, Any>>>) -> Unit
  ) {
    executor.execute {
      runCatching {
        val (source, classLoader) = findSourceAndClassLoader(sourceId)
          ?: throw Exception("Extension source with ID $sourceId is not installed.")

        val sChapterInstance = createInterfaceInstance("eu.kanade.tachiyomi.source.model.SChapter", classLoader)
        sChapterInstance.javaClass.getMethod("setUrl", String::class.java).invoke(sChapterInstance, chapterUrl)

        val fetchPageListMethod = source.javaClass.methods.firstOrNull {
          it.name == "fetchPageList" &&
          it.parameterTypes.size == 1 &&
          it.parameterTypes[0].name.contains("SChapter")
        } ?: throw Exception("fetchPageList method not found on source.")

        val observable = fetchPageListMethod.invoke(source, sChapterInstance) as? rx.Observable<*>
          ?: throw Exception("fetchPageList did not return an RxJava Observable.")

        val pagesList = observable.toBlocking().first() as? List<*> ?: emptyList<Any>()

        pagesList.mapNotNull { page ->
          if (page == null) return@mapNotNull null
          val imageUrl = tryInvokeString(page, "getImageUrl") ?: tryInvokeString(page, "imageUrl") ?: ""
          val index = try {
            page.javaClass.getMethod("getIndex").invoke(page) as? Int ?: 0
          } catch (e: Throwable) {
            0
          }
          mapOf(
            "imageUrl" to imageUrl,
            "index" to index
          )
        }
      }.also { result ->
        mainHandler.post { callback(result) }
      }
    }
  }
}
