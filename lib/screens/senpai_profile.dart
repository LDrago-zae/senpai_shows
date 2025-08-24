import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SenpaiProfile extends StatefulWidget {
  const SenpaiProfile({super.key});

  @override
  State<SenpaiProfile> createState() => _SenpaiProfileState();
}

class _SenpaiProfileState extends State<SenpaiProfile> {
  final UserService _userService = UserService();
  User? _currentUser;
  bool _loading = false;

  // Sample user data for additional stats (replace with actual data from your backend)
  final Map<String, dynamic> _userProfile = {
    'favoriteGenres': ['Action', 'Romance', 'Slice of Life'],
    'watchedAnime': 127,
    'favoriteAnime': 23,
    'watchTime': 2847, // in hours
  };

  @override
  void initState() {
    super.initState();
    _loadUserData();

    // Listen to auth state changes
    _userService.authStateChanges.listen((User? user) {
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    });
  }

  void _loadUserData() {
    setState(() {
      _currentUser = _userService.currentUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(38, 10, 10, 255),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Profile',
          style: GoogleFonts.urbanist(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: _showEditProfile,
          ),
        ],
      ),
      body: Stack(
        children: [
          SizedBox.expand(),
          _currentUser != null
              ? _buildProfileContent()
              : _buildLoginPrompt(),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 16.0,
        bottom: 100.0,
      ),
      child: Column(
        children: [
          const SizedBox(height: 100),
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _buildStatsCards(),
          const SizedBox(height: 24),
          _buildSettingsSection(),
          const SizedBox(height: 24),
          _buildActionButtons(),
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
        border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.tealAccent,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: _currentUser!.photoURL != null
                      ? Image.network(
                    _currentUser!.photoURL!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _defaultAvatar(),
                  )
                      : _defaultAvatar(),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.tealAccent,
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
            _currentUser!.displayName ?? 'Anonymous User',
            style: GoogleFonts.urbanist(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _currentUser!.email ?? 'No email',
            style: GoogleFonts.urbanist(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Member since ${_formatJoinDate(_currentUser!.metadata.creationTime)}',
            style: GoogleFonts.urbanist(
              fontSize: 14,
              color: Colors.tealAccent,
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
            '${_userProfile['watchedAnime']}',
            'Anime',
            Icons.play_circle_filled,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Favorites',
            '${_userProfile['favoriteAnime']}',
            'Shows',
            Icons.favorite,
            Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Watch Time',
            '${_userProfile['watchTime']}',
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
            Colors.tealAccent,
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
            Colors.blueAccent,
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
              backgroundColor: Colors.tealAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.palette),
            label: Text(
              'Customize Theme',
              style: GoogleFonts.urbanist(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _showSignOutConfirmation,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.logout),
            label: Text(
              'Sign Out',
              style: GoogleFonts.urbanist(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 100,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 20),
          Text(
            'Please Sign In',
            style: GoogleFonts.urbanist(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Sign in to view your profile',
            style: GoogleFonts.urbanist(
              color: Colors.grey[400],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: _signInWithGoogle,
            icon: const Icon(Icons.login, color: Colors.white),
            label: Text(
              'Sign in with Google',
              style: GoogleFonts.urbanist(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.tealAccent,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _defaultAvatar() {
    return Container(
      color: Colors.grey[800],
      child: Icon(
        Icons.person,
        size: 60,
        color: Colors.grey[400],
      ),
    );
  }

  String _formatJoinDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatLastSignIn(DateTime? date) {
    if (date == null) return 'Unknown';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inMinutes} minutes ago';
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    try {
      final result = await _userService.signInWithGoogle();
      if (result != null) {
        setState(() {
          _currentUser = result.user;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Signed in successfully'),
            backgroundColor: const Color(0xFF4ECDC4),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign in failed: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
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
              child: Text(
                'Close',
                style: GoogleFonts.urbanist(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
        backgroundColor: Colors.tealAccent,
        duration: const Duration(seconds: 2),
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
            child: Text(
              'Cancel',
              style: GoogleFonts.urbanist(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () async {
              setState(() => _loading = true);
              try {
                await _userService.signOut();
                setState(() {
                  _currentUser = null;
                });
                Navigator.pop(context); // Close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Signed out successfully'),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    backgroundColor: const Color(0xFF4ECDC4),
                    duration: const Duration(seconds: 1),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Sign-out failed: $e'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              } finally {
                setState(() => _loading = false);
              }
            },
            child: Text(
              'Sign Out',
              style: GoogleFonts.urbanist(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}