const source = {
    name: "Extensions Repo",
    baseUrl: "",

    fetchExtensionIndex: async function() {
        const response = await httpClient.get(this.baseUrl + "/index.min.json");
        const data = JSON.parse(response.body);
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
    },

    fetchPopular: async function() {
        const response = await httpClient.get(this.baseUrl + "/index.min.json");
        const data = JSON.parse(response.body);
        const list = Array.isArray(data) ? data : (data.items || []);
        return JSON.stringify(list.map(item => ({
            url: item.pkg || item.name || "",
            title: item.name || "",
            imageUrl: "https://placehold.co/300x450/0f172a/ffffff?text=" +
                ((item.name || "Extension").replace(/[^a-z0-9]/gi, "+"))
        })));
    },

    getEpisodes: async function(animeId) {
        return JSON.stringify([]);
    },

    getVideoSources: async function(episodeUrl) {
        return JSON.stringify([
            { quality: "Auto", url: episodeUrl }
        ]);
    },

    fetchPopularManga: async function() {
        return await this.fetchPopular();
    },

    getMangaPages: async function(mangaId) {
        return JSON.stringify([]);
    }
};
