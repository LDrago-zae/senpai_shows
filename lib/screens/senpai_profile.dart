import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:senpai_shows/components/anime_particle_background.dart';
import 'package:senpai_shows/firebase/senpai_auth.dart';
import 'package:senpai_shows/screens/senpai_login.dart';
import 'package:senpai_shows/screens/senpai_splash.dart';
import 'package:senpai_shows/components/slide_animation.dart';

class SenpaiProfile extends StatefulWidget {
  const SenpaiProfile({super.key});

  @override
  State<SenpaiProfile> createState() => _SenpaiProfileState();
}

class _SenpaiProfileState extends State<SenpaiProfile> {
  bool _loading = false;

  // Sample user data - replace with actual user data
  final UserProfile _userProfile = UserProfile(
    name: 'Otaku Senpai',
    email: 'otaku@senpai.com',
    avatarUrl: '',
    joinDate: DateTime(2023, 1, 15),
    favoriteGenres: ['Action', 'Romance', 'Slice of Life'],
    watchedAnime: 127,
    favoriteAnime: 23,
    watchTime: 2847, // in hours
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Profile',
          style: GoogleFonts.urbanist(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              _showEditProfile();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          const LightBlackGlassmorphicContainer(
            blurStrength: 8.0,
            borderRadius: 16.0,
            padding: EdgeInsets.all(16.0),
            child: SizedBox.expand(),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildProfileHeader(),
                  const SizedBox(height: 24),
                  _buildStatsCards(),
                  const SizedBox(height: 24),
                  _buildSettingsSection(),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withOpacity(0.2),
            Colors.indigo.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blueAccent.withOpacity(0.3),
                child: const Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.blueAccent,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _userProfile.name,
            style: GoogleFonts.urbanist(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _userProfile.email,
            style: GoogleFonts.urbanist(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Member since ${_userProfile.joinDate.year}',
            style: GoogleFonts.urbanist(
              fontSize: 14,
              color: Colors.blueAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Watched',
            '${_userProfile.watchedAnime}',
            'Anime',
            Icons.play_circle_filled,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Favorites',
            '${_userProfile.favoriteAnime}',
            'Shows',
            Icons.favorite,
            Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Watch Time',
            '${_userProfile.watchTime}',
            'Hours',
            Icons.access_time,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.urbanist(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.urbanist(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.urbanist(
              fontSize: 10,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            'Account Settings',
            Icons.settings,
            Colors.blueAccent,
                () => _showComingSoon('Account Settings'),
          ),
          const Divider(color: Colors.white12),
          _buildSettingsTile(
            'Notification Preferences',
            Icons.notifications,
            Colors.orangeAccent,
                () => _showComingSoon('Notification Settings'),
          ),
          const Divider(color: Colors.white12),
          _buildSettingsTile(
            'Download Settings',
            Icons.download,
            Colors.greenAccent,
                () => _showComingSoon('Download Settings'),
          ),
          const Divider(color: Colors.white12),
          _buildSettingsTile(
            'Privacy & Security',
            Icons.security,
            Colors.purpleAccent,
                () => _showComingSoon('Privacy Settings'),
          ),
          const Divider(color: Colors.white12),
          _buildSettingsTile(
            'Help & Support',
            Icons.help,
            Colors.tealAccent,
                () => _showComingSoon('Help Center'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(String title, IconData icon, Color iconColor, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: GoogleFonts.urbanist(
          fontSize: 16,
          color: Colors.white,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showComingSoon('Theme Settings'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.palette),
            label: const Text('Customize Theme'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showSignOutConfirmation(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out'),
          ),
        ),
      ],
    );
  }

  void _showEditProfile() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Edit Profile',
              style: GoogleFonts.urbanist(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Profile editing feature coming soon!',
              style: GoogleFonts.urbanist(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  void _showSignOutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: Text(
          'Sign Out',
          style: GoogleFonts.urbanist(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: GoogleFonts.urbanist(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              setState(() => _loading = true);
              try {
                await SenpaiAuth().signOut();
                if (mounted) {
                  Navigator.pop(context); // Close dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Signed out successfully'),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      backgroundColor: const Color(0xFF4ECDC4),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                  Navigator.pushReplacement(
                    context,
                    SlideAnimation(
                      page: const SenpaiLogin(),
                      direction: AxisDirection.left,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Sign-out failed: $e'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              } finally {
                if (mounted) {
                  setState(() => _loading = false);
                }
              }
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

class UserProfile {
  final String name;
  final String email;
  final String avatarUrl;
  final DateTime joinDate;
  final List<String> favoriteGenres;
  final int watchedAnime;
  final int favoriteAnime;
  final int watchTime;

  UserProfile({
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.joinDate,
    required this.favoriteGenres,
    required this.watchedAnime,
    required this.favoriteAnime,
    required this.watchTime,
  });
}