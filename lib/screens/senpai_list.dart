import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:senpai_shows/models/source_interface.dart';
import 'package:senpai_shows/services/extension_service.dart';
import 'package:senpai_shows/screens/senpai_details_screen.dart';
import 'package:senpai_shows/models/anime_detail_model.dart';

class SourceDetailsScreen extends StatefulWidget {
  final ExtensionRepoSource source;
  final bool isManga;

  const SourceDetailsScreen({
    super.key,
    required this.source,
    required this.isManga,
  });

  @override
  State<SourceDetailsScreen> createState() => _SourceDetailsScreenState();
}

class _SourceDetailsScreenState extends State<SourceDetailsScreen> {
  final ExtensionService _extensionService = ExtensionService();
  final TextEditingController _searchController = TextEditingController();

  List<AnimeItem> _items = [];
  bool _isLoading = true;
  bool _isSearching = false;
  String _searchQuery = '';
  bool _isGridView = true;
  String _activeFilter = 'popular'; // 'popular', 'latest', 'filter'

  @override
  void initState() {
    super.initState();
    _fetchSourceData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _extensionService.dispose();
    super.dispose();
  }

  Future<void> _fetchSourceData() async {
    setState(() => _isLoading = true);
    try {
      List<AnimeItem> fetchedItems;

      if (widget.source.id.isEmpty || widget.source.id == 'sample') {
        // JS Sample fallback loading
        await _extensionService.loadExtensionFromAssets('assets/extensions/sample_source.js');
        if (widget.isManga) {
          fetchedItems = await _extensionService.fetchPopularManga();
        } else {
          fetchedItems = await _extensionService.fetchPopular();
        }
      } else {
        // Native source loading from APK
        fetchedItems = await _extensionService.fetchPopularNative(
          sourceId: widget.source.id,
          isManga: widget.isManga,
          page: 1,
        );
      }

      if (!mounted) return;
      setState(() {
        _items = fetchedItems;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load items: $e')),
      );
    }
  }

  List<AnimeItem> get _filteredItems {
    if (_searchQuery.isEmpty) return _items;
    final normalized = _searchQuery.toLowerCase();
    return _items.where((item) => item.title.toLowerCase().contains(normalized)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredItems;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (value) => setState(() => _searchQuery = value.trim()),
                style: GoogleFonts.urbanist(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search in source...',
                  hintStyle: GoogleFonts.urbanist(color: Colors.white54),
                  border: InputBorder.none,
                ),
              )
            : Text(
                widget.source.name,
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                }
                _isSearching = !_isSearching;
              });
            },
          ),
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view, color: Colors.white),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF22D3EE),
                    ),
                  )
                : filtered.isEmpty
                    ? _buildEmptyState()
                    : _isGridView
                        ? _buildGridView(filtered)
                        : _buildListView(filtered),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xFF0F172A),
      child: Row(
        children: [
          _buildFilterButton(
            label: 'Popular',
            icon: Icons.favorite_outline,
            isActive: _activeFilter == 'popular',
            activeColor: const Color(0xFF22D3EE),
            onTap: () => setState(() => _activeFilter = 'popular'),
          ),
          const SizedBox(width: 8),
          _buildFilterButton(
            label: 'Latest',
            icon: Icons.new_releases_outlined,
            isActive: _activeFilter == 'latest',
            activeColor: const Color(0xFF38BDF8),
            onTap: () => setState(() => _activeFilter = 'latest'),
          ),
          const SizedBox(width: 8),
          _buildFilterButton(
            label: 'Filter',
            icon: Icons.filter_list_outlined,
            isActive: _activeFilter == 'filter',
            activeColor: const Color(0xFFF59E0B),
            onTap: () => setState(() => _activeFilter = 'filter'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton({
    required String label,
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? activeColor.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive ? activeColor : Colors.white60,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.urbanist(
                color: isActive ? activeColor : Colors.white60,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView(List<AnimeItem> items) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.7,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildGridCard(item);
      },
    );
  }

  Widget _buildGridCard(AnimeItem item) {
    return GestureDetector(
      onTap: () => _navigateToDetail(item),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          color: const Color(0xFF0F172A),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                item.imageUrl.isNotEmpty ? item.imageUrl : 'https://placehold.co/300x450/0f172a/ffffff?text=No+Cover',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF1E293B),
                  child: const Icon(Icons.broken_image, color: Colors.white30, size: 30),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(8, 24, 8, 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.85),
                        Colors.black,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.urbanist(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListView(List<AnimeItem> items) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildListCard(item);
      },
    );
  }

  Widget _buildListCard(AnimeItem item) {
    return GestureDetector(
      onTap: () => _navigateToDetail(item),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          color: const Color(0xFF0F172A),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 60,
                height: 80,
                child: Image.network(
                  item.imageUrl.isNotEmpty ? item.imageUrl : 'https://placehold.co/150x200/0f172a/ffffff?text=No+Cover',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFF1E293B),
                    child: const Icon(Icons.broken_image, color: Colors.white30, size: 20),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.urbanist(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.isManga ? 'Manga Source' : 'Anime Source',
                    style: GoogleFonts.urbanist(
                      color: const Color(0xFF22D3EE),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white30),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_outlined, size: 48, color: Colors.white30),
            const SizedBox(height: 12),
            Text(
              'No items found',
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try adjusting your search query or refreshing.',
              textAlign: TextAlign.center,
              style: GoogleFonts.urbanist(color: Colors.white60, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(AnimeItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SenpaiDetailsScreen(
          anime: AnimeModel(
            title: item.title,
            genre: widget.isManga ? 'Manga' : 'Anime',
            imagePath: item.imageUrl,
            synopsis: 'Details fetched from ${widget.source.name} via extension.',
            releaseDate: 'N/A',
            starring: 'N/A',
          ),
          isFromExtension: true,
          contentUrl: item.url,
          sourceName: widget.source.name,
          sourceId: widget.source.id,
        ),
      ),
    );
  }
}
