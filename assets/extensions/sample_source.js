const source = {
    name: "Sample Source",
    baseUrl: "https://api.jikan.moe/v4",
    
    fetchPopular: async function() {
        // Hash the name to choose a unique genre (between 1 and 20)
        let genreId = 1;
        if (this.name) {
            let hash = 0;
            for (let i = 0; i < this.name.length; i++) {
                hash = this.name.charCodeAt(i) + ((hash << 5) - hash);
            }
            genreId = Math.abs(hash % 20) + 1;
        }

        // Fetch anime matching the selected genre ordered by popularity
        const response = await httpClient.get(this.baseUrl + "/anime?genres=" + genreId + "&order_by=popularity&sort=desc");
        const data = JSON.parse(response.body);
        return JSON.stringify(data.data.map(item => ({
            url: item.url,
            title: item.title,
            imageUrl: item.images.jpg.large_image_url
        })));
    },

    getEpisodes: async function(animeUrl) {
        return JSON.stringify([
            { name: "Episode 1", url: animeUrl + "/episode/1" },
            { name: "Episode 2", url: animeUrl + "/episode/2" },
            { name: "Episode 3", url: animeUrl + "/episode/3" },
            { name: "Episode 4", url: animeUrl + "/episode/4" },
            { name: "Episode 5", url: animeUrl + "/episode/5" }
        ]);
    },

    getVideoSources: async function(episodeUrl) {
        return JSON.stringify([
            { quality: "Auto", url: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8" }
        ]);
    },

    fetchPopularManga: async function() {
        // Hash the name to choose a unique genre (between 1 and 20)
        let genreId = 1;
        if (this.name) {
            let hash = 0;
            for (let i = 0; i < this.name.length; i++) {
                hash = this.name.charCodeAt(i) + ((hash << 5) - hash);
            }
            genreId = Math.abs(hash % 20) + 1;
        }

        // Fetch manga matching the selected genre ordered by popularity
        const response = await httpClient.get(this.baseUrl + "/manga?genres=" + genreId + "&order_by=popularity&sort=desc");
        const data = JSON.parse(response.body);
        return JSON.stringify(data.data.map(item => ({
            url: item.url,
            title: item.title,
            imageUrl: item.images.jpg.large_image_url
        })));
    },

    getMangaPages: async function(mangaUrl) {
        return JSON.stringify([
            { imageUrl: "https://picsum.photos/800/1200?random=1", index: 0 },
            { imageUrl: "https://picsum.photos/800/1200?random=2", index: 1 },
            { imageUrl: "https://picsum.photos/800/1200?random=3", index: 2 },
            { imageUrl: "https://picsum.photos/800/1200?random=4", index: 3 },
            { imageUrl: "https://picsum.photos/800/1200?random=5", index: 4 }
        ]);
    }
};
