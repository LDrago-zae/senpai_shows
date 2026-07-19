const source = {
    name: "Extensions Repo",
    baseUrl: "",

    // Synchronous version: parses __prefetchedBody injected by Dart
    fetchExtensionIndex: function() {
        try {
            const data = JSON.parse(__prefetchedBody);
            const list = Array.isArray(data) ? data : (data.items || []);
            return JSON.stringify(list.map(item => ({
                name: item.name || "",
                pkg: item.pkg || "",
                apk: item.apk || "",
                lang: item.lang || "",
                code: item.code || 0,
                version: item.version || "",
                nsfw: item.nsfw || 0,
                sources: (item.sources || []).map(src => ({
                    name: src.name || "",
                    lang: src.lang || "",
                    id: src.id || "",
                    baseUrl: src.baseUrl || ""
                }))
            })));
        } catch (e) {
            return JSON.stringify([]);
        }
    },

    fetchPopular: function() {
        try {
            const data = JSON.parse(__prefetchedBody);
            const list = Array.isArray(data) ? data : (data.items || []);
            return JSON.stringify(list.map(item => ({
                url: item.pkg || item.name || "",
                title: item.name || "",
                imageUrl: "https://placehold.co/300x450/0f172a/ffffff?text=" +
                    ((item.name || "Extension").replace(/[^a-z0-9]/gi, "+"))
            })));
        } catch (e) {
            return JSON.stringify([]);
        }
    },

    getEpisodes: function(animeId) {
        return JSON.stringify([]);
    },

    getVideoSources: function(episodeUrl) {
        return JSON.stringify([
            { quality: "Auto", url: episodeUrl }
        ]);
    },

    fetchPopularManga: function() {
        return source.fetchPopular();
    },

    getMangaPages: function(mangaId) {
        return JSON.stringify([]);
    }
};
