import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:senpai_shows/components/anime_particle_background.dart';

class SenpaiDownloads extends StatefulWidget {
  const SenpaiDownloads({super.key});

  @override
  State<SenpaiDownloads> createState() => _SenpaiDownloadsState();
}

class _SenpaiDownloadsState extends State<SenpaiDownloads> {
  List<DownloadedAnime> _downloads = [];
  bool _loading = true;
  String? _error;
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Completed', 'Downloading', 'Paused'];

  @override
  void initState() {
    super.initState();
    _loadDownloads();
  }

  Future<void> _loadDownloads() async {
    setState(() {
      _loading = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 1));
      // Sample data - replace with actual downloaded content
      setState(() {
        _downloads = [
          DownloadedAnime(
            id: 1,
            title: 'Attack on Titan S4',
            episode: 'Episode 15',
            progress: 1.0,
            status: DownloadStatus.completed,
            fileSize: '450 MB',
            downloadDate: DateTime.now().subtract(const Duration(days: 2)),
            thumbnailUrl: 'https://example.com/aot.jpg',
          ),
          DownloadedAnime(
            id: 2,
            title: 'Demon Slayer',
            episode: 'Episode 8',
            progress: 0.65,
            status: DownloadStatus.downloading,
            fileSize: '380 MB',
            downloadDate: DateTime.now(),
            thumbnailUrl: 'https://example.com/demon_slayer.jpg',
          ),
        ];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load downloads';
        _loading = false;
      });
    }
  }

  List<DownloadedAnime> get _filteredDownloads {
    if (_selectedFilter == 'All') return _downloads;
    return _downloads.where((download) =>
      download.status.toString().split('.').last.toLowerCase() ==
      _selectedFilter.toLowerCase()).toList();
  }

  double get _totalSize {
    return _downloads.fold(0.0, (sum, download) =>
      sum + double.parse(download.fileSize.split(' ')[0]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Downloads',
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
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // TODO: Open download settings
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          const LightBlackGlassmorphicContainer(
            blurStrength: 6.0,
            borderRadius: 16.0,
            padding: EdgeInsets.all(16.0),
            child: SizedBox.expand(),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Header Section
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.withOpacity(0.2),
                        Colors.deepOrange.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orangeAccent.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.download,
                        color: Colors.orangeAccent,
                        size: 30,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Downloaded Content',
                              style: GoogleFonts.urbanist(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '${_downloads.length} items • ${_totalSize.toStringAsFixed(1)} GB total',
                              style: GoogleFonts.urbanist(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Filter Tabs
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filters.length,
                    itemBuilder: (context, index) {
                      final filter = _filters[index];
                      final isSelected = filter == _selectedFilter;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.orangeAccent
                                : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.orangeAccent
                                  : Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            filter,
                            style: GoogleFonts.urbanist(
                              color: isSelected ? Colors.black : Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Content Section
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.orangeAccent,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.redAccent,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: GoogleFonts.urbanist(
                color: Colors.redAccent,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDownloads,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.black,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredDownloads.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.download_outlined,
              color: Colors.white54,
              size: 80,
            ),
            const SizedBox(height: 24),
            Text(
              'No Downloads',
              style: GoogleFonts.urbanist(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Download anime episodes to watch offline.',
              textAlign: TextAlign.center,
              style: GoogleFonts.urbanist(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              icon: const Icon(Icons.explore),
              label: const Text('Browse Anime'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredDownloads.length,
      itemBuilder: (context, index) {
        final download = _filteredDownloads[index];
        return _buildDownloadCard(download);
      },
    );
  }

  Widget _buildDownloadCard(DownloadedAnime download) {
    return Card(
      color: Colors.black.withOpacity(0.7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 80,
                height: 80,
                color: Colors.grey.shade800,
                child: const Icon(
                  Icons.movie,
                  color: Colors.orangeAccent,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    download.title,
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    download.episode,
                    style: GoogleFonts.urbanist(
                      fontSize: 14,
                      color: Colors.orangeAccent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (download.status == DownloadStatus.downloading) ...[
                    LinearProgressIndicator(
                      value: download.progress,
                      backgroundColor: Colors.grey.shade700,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(download.progress * 100).toInt()}% • ${download.fileSize}',
                      style: GoogleFonts.urbanist(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Icon(
                          _getStatusIcon(download.status),
                          color: _getStatusColor(download.status),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${download.fileSize} • ${_getStatusText(download.status)}',
                          style: GoogleFonts.urbanist(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) => _handleMenuAction(value, download),
              itemBuilder: (context) => [
                if (download.status == DownloadStatus.completed)
                  const PopupMenuItem(
                    value: 'play',
                    child: Row(
                      children: [
                        Icon(Icons.play_arrow, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Play'),
                      ],
                    ),
                  ),
                if (download.status == DownloadStatus.downloading)
                  const PopupMenuItem(
                    value: 'pause',
                    child: Row(
                      children: [
                        Icon(Icons.pause, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Pause'),
                      ],
                    ),
                  ),
                if (download.status == DownloadStatus.paused)
                  const PopupMenuItem(
                    value: 'resume',
                    child: Row(
                      children: [
                        Icon(Icons.play_arrow, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Resume'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.redAccent),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(DownloadStatus status) {
    switch (status) {
      case DownloadStatus.completed:
        return Icons.check_circle;
      case DownloadStatus.downloading:
        return Icons.download;
      case DownloadStatus.paused:
        return Icons.pause_circle;
      case DownloadStatus.failed:
        return Icons.error;
    }
  }

  Color _getStatusColor(DownloadStatus status) {
    switch (status) {
      case DownloadStatus.completed:
        return Colors.green;
      case DownloadStatus.downloading:
        return Colors.orangeAccent;
      case DownloadStatus.paused:
        return Colors.amber;
      case DownloadStatus.failed:
        return Colors.redAccent;
    }
  }

  String _getStatusText(DownloadStatus status) {
    switch (status) {
      case DownloadStatus.completed:
        return 'Completed';
      case DownloadStatus.downloading:
        return 'Downloading';
      case DownloadStatus.paused:
        return 'Paused';
      case DownloadStatus.failed:
        return 'Failed';
    }
  }

  void _handleMenuAction(String action, DownloadedAnime download) {
    switch (action) {
      case 'play':
        // TODO: Implement play functionality
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Playing ${download.title}')),
        );
        break;
      case 'pause':
        setState(() {
          download.status = DownloadStatus.paused;
        });
        break;
      case 'resume':
        setState(() {
          download.status = DownloadStatus.downloading;
        });
        break;
      case 'delete':
        _showDeleteConfirmation(download);
        break;
    }
  }

  void _showDeleteConfirmation(DownloadedAnime download) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: Text(
          'Delete Download',
          style: GoogleFonts.urbanist(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${download.title}"?',
          style: GoogleFonts.urbanist(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _downloads.remove(download);
              });
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

enum DownloadStatus { completed, downloading, paused, failed }

class DownloadedAnime {
  final int id;
  final String title;
  final String episode;
  final double progress;
  DownloadStatus status;
  final String fileSize;
  final DateTime downloadDate;
  final String thumbnailUrl;

  DownloadedAnime({
    required this.id,
    required this.title,
    required this.episode,
    required this.progress,
    required this.status,
    required this.fileSize,
    required this.downloadDate,
    required this.thumbnailUrl,
  });
}
