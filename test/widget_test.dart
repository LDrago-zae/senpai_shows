import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:senpai_shows/components/anime_particle_background.dart';
import 'package:senpai_shows/components/slide_animation.dart';

void main() {
  testWidgets('LightBlackGlassmorphicContainer renders child content', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LightBlackGlassmorphicContainer(
            child: Text('SenpaiShows Ready'),
          ),
        ),
      ),
    );

    expect(find.text('SenpaiShows Ready'), findsOneWidget);
  });

  testWidgets('SlideAnimation builds route for page correctly', (WidgetTester tester) async {
    final route = SlideAnimation(
      page: const Scaffold(body: Text('Animated Anime Title')),
    );

    expect(route.page, isNotNull);
    expect(route.transitionDuration, const Duration(milliseconds: 300));
  });
}
