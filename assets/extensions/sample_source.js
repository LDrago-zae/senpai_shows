const source = {
    name: "Sample Source",
    baseUrl: "https://api.jikan.moe/v4",
    
    getFallbackAnime: function() {
        return [
            {
                url: "https://myanimelist.net/anime/52991/Sousou_no_Frieren",
                title: "Sousou no Frieren",
                imageUrl: "https://cdn.myanimelist.net/images/anime/1015/138006l.jpg"
            },
            {
                url: "https://myanimelist.net/anime/52299/Ore_dake_Level_Up_na_Ken",
                title: "Solo Leveling",
                imageUrl: "https://cdn.myanimelist.net/images/anime/1844/141018l.jpg"
            },
            {
                url: "https://myanimelist.net/anime/21/One_Piece",
                title: "One Piece",
                imageUrl: "https://cdn.myanimelist.net/images/anime/1244/138851l.jpg"
            },
            {
                url: "https://myanimelist.net/anime/51009/Jujutsu_Kaisen_2nd_Season",
                title: "Jujutsu Kaisen Season 2",
                imageUrl: "https://cdn.myanimelist.net/images/anime/1792/138042l.jpg"
            },
            {
                url: "https://myanimelist.net/anime/44511/Chainsaw_Man",
                title: "Chainsaw Man",
                imageUrl: "https://cdn.myanimelist.net/images/anime/1806/126216l.jpg"
            }
        ];
    },

    getFallbackManga: function() {
        return [
            {
                url: "https://myanimelist.net/manga/121496/Solo_Leveling",
                title: "Solo Leveling",
                imageUrl: "https://cdn.myanimelist.net/images/manga/3/222295l.jpg"
            },
            {
                url: "https://myanimelist.net/manga/13/One_Piece",
                title: "One Piece",
                imageUrl: "https://cdn.myanimelist.net/images/manga/2/253146l.jpg"
            },
            {
                url: "https://myanimelist.net/manga/113138/Jujutsu_Kaisen",
                title: "Jujutsu Kaisen",
                imageUrl: "https://cdn.myanimelist.net/images/manga/1/209370l.jpg"
            },
            {
                url: "https://myanimelist.net/manga/116778/Chainsaw_Man",
                title: "Chainsaw Man",
                imageUrl: "https://cdn.myanimelist.net/images/manga/3/216464l.jpg"
            },
            {
                url: "https://myanimelist.net/manga/126287/Sousou_no_Frieren",
                title: "Sousou no Frieren",
                imageUrl: "https://cdn.myanimelist.net/images/manga/3/234551l.jpg"
            }
        ];
    },

    // Called by Dart with pre-fetched data injected as __prefetchedBody
    fetchPopular: function() {
        try {
            if (typeof __prefetchedBody === 'undefined' || !__prefetchedBody) {
                return JSON.stringify(source.getFallbackAnime());
            }
            const data = JSON.parse(__prefetchedBody);
            if (!data || !Array.isArray(data.data) || data.data.length === 0) {
                return JSON.stringify(source.getFallbackAnime());
            }
            return JSON.stringify(data.data.map(item => ({
                url: item.url || "",
                title: item.title || "Untitled",
                imageUrl: (item.images && item.images.jpg && (item.images.jpg.large_image_url || item.images.jpg.image_url)) || ""
            })));
        } catch (e) {
            return JSON.stringify(source.getFallbackAnime());
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
            if (typeof __prefetchedBody === 'undefined' || !__prefetchedBody) {
                return JSON.stringify(source.getFallbackManga());
            }
            const data = JSON.parse(__prefetchedBody);
            if (!data || !Array.isArray(data.data) || data.data.length === 0) {
                return JSON.stringify(source.getFallbackManga());
            }
            return JSON.stringify(data.data.map(item => ({
                url: item.url || "",
                title: item.title || "Untitled",
                imageUrl: (item.images && item.images.jpg && (item.images.jpg.large_image_url || item.images.jpg.image_url)) || ""
            })));
        } catch (e) {
            return JSON.stringify(source.getFallbackManga());
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
