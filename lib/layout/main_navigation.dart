import 'package:flutter/material.dart';
import 'package:senpai_shows/screens/senpai_bookmarks.dart';
import 'package:senpai_shows/screens/senpai_downloads.dart';
import 'package:senpai_shows/screens/senpai_home.dart';
import 'package:senpai_shows/screens/senpai_search.dart';
import 'package:senpai_shows/screens/senpai_songs.dart';
// import other screens as needed
import '../components/custom_bottom_nav.dart';
import '../screens/senpai_profile.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final ValueNotifier<int> _tabNotifier = ValueNotifier(0);
  late final SenpaiSearch _senpaiSearchScreen;

  @override
  void initState() {
    super.initState();
    _senpaiSearchScreen = SenpaiSearch(tabNotifier: _tabNotifier);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _tabNotifier.value = index; // 👈 notify which screen is selected
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.black,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const SenpaiHome(),
          _senpaiSearchScreen,
          SenpaiBookmarks(),
          SenpaiSongs(),
          SenpaiDownloads(),
          SenpaiProfile(),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: CustomBottomNav(
            selectedIndex: _selectedIndex,
            onItemTapped: _onItemTapped,
          ),
        ),
      ),
    );
  }
}

