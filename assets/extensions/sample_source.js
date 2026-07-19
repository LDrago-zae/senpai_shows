const source = {
    name: "Sample Source",
    baseUrl: "https://api.jikan.moe/v4",
    
    // Called by Dart with pre-fetched data injected as __prefetchedBody
    fetchPopular: function() {
        try {
            const data = JSON.parse(__prefetchedBody);
            if (!data || !Array.isArray(data.data)) {
                return JSON.stringify([]);
            }
            return JSON.stringify(data.data.map(item => ({
                url: item.url,
                title: item.title,
                imageUrl: (item.images && item.images.jpg && item.images.jpg.large_image_url) || ""
            })));
        } catch (e) {
            return JSON.stringify([]);
        }
    },

    getEpisodes: function(animeUrl) {
        return JSON.stringify([
            { name: "Episode 1", url: animeUrl + "/episode/1" },
            { name: "Episode 2", url: animeUrl + "/episode/2" },
            { name: "Episode 3", url: animeUrl + "/episode/3" },
            { name: "Episode 4", url: animeUrl + "/episode/4" },
            { name: "Episode 5", url: animeUrl + "/episode/5" }
        ]);
    },

    getVideoSources: function(episodeUrl) {
        return JSON.stringify([
            { quality: "Auto", url: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8" }
        ]);
    },

    // Called by Dart with pre-fetched data injected as __prefetchedBody
    fetchPopularManga: function() {
        try {
            const data = JSON.parse(__prefetchedBody);
            if (!data || !Array.isArray(data.data)) {
                return JSON.stringify([]);
            }
            return JSON.stringify(data.data.map(item => ({
                url: item.url,
                title: item.title,
                imageUrl: (item.images && item.images.jpg && item.images.jpg.large_image_url) || ""
            })));
        } catch (e) {
            return JSON.stringify([]);
        }
    },

    getMangaPages: function(mangaUrl) {
        return JSON.stringify([
            { imageUrl: "https://picsum.photos/800/1200?random=1", index: 0 },
            { imageUrl: "https://picsum.photos/800/1200?random=2", index: 1 },
            { imageUrl: "https://picsum.photos/800/1200?random=3", index: 2 },
            { imageUrl: "https://picsum.photos/800/1200?random=4", index: 3 },
            { imageUrl: "https://picsum.photos/800/1200?random=5", index: 4 }
        ]);
    }
};
