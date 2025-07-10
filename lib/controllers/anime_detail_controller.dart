// controllers/anime_controller.dart

import '../models/anime_detail_model.dart';

class AnimeController {
  AnimeModel getAnimeDetail() {
    // In real app, this could come from an API or database
    return AnimeModel(
      title: "Jujutsu Kaisen",
      genre: "Shonen, Dark Fantasy",
      imagePath: "assets/senpaiAssets/solo2.png",
      releaseDate: "December 9, 2017",
      synopsis:
      "With his days numbered, high schooler Yuji decides to hunt down and consume the remaining 19 fingers of a deadly curse so it can die with him.",
      starring: "Junya Enoki, Yuma Uchida, Asami Seto",
    );
  }
}
