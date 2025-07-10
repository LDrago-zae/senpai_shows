import 'package:flutter/material.dart';
import 'package:senpai_shows/screens/senpai_home.dart';
import 'package:senpai_shows/screens/senpai_search.dart';
// import other screens as needed
import '../components/custom_bottom_nav.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _screens = const [
    SenpaiHome(),
    SenpaiSearch(),
    // Future Screens:
    // BookmarksScreen(),
    // MusicScreen(),
    // DownloadsScreen(),
    // ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Allows content behind the bottom nav
      backgroundColor: Colors.black,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 12, right: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              // color: Colors.black, // Keep background same as screen
              // 🔥 No shadow, clean floating nav
            ),
            child: CustomBottomNav(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
            ),
          ),
        ),
      ),
    );
  }
}
