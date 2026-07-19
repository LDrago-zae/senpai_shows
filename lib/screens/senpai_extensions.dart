import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:senpai_shows/models/source_interface.dart';
import 'package:senpai_shows/services/extension_service.dart';
import 'package:senpai_shows/screens/senpai_list.dart';

class SenpaiExtensions extends StatefulWidget {
  const SenpaiExtensions({super.key});

  @override
  State<SenpaiExtensions> createState() => _SenpaiExtensionsState();
}

class _SenpaiExtensionsState extends State<SenpaiExtensions> {
  final ExtensionService _extensionService = ExtensionService();
  final TextEditingController _searchController = TextEditingController();
  List<ExtensionRepoItem> _extensions = [];
  bool _isLoading = false;
  String _query = '';
  String _selectedRepoType = 'all'; // 'all', 'anime', 'manga'
  String _selectedRepoId = 'all';
  Set<String> _installedPkgs = {};
  Set<String> _installingPkgs = {};

  final List<ExtensionRepoConfig> _repoConfigs = const [
    ExtensionRepoConfig(
      id: 'yuzono-anime',
      name: 'Yuzono Anime Repo',
      baseUrl: 'https://raw.githubusercontent.com/yuzono/anime-repo/repo',
      type: 'anime',
    ),
    ExtensionRepoConfig(
      id: 'aniyomi',
      name: 'Aniyomi Extensions',
      baseUrl:
          'https://raw.githubusercontent.com/aniyomiorg/aniyomi-extensions/repo',
      type: 'mixed',
    ),
    ExtensionRepoConfig(
      id: 'keiyoushi',
      name: 'Keiyoushi Extensions',
      baseUrl: 'https://raw.githubusercontent.com/keiyoushi/extensions/repo',
      type: 'manga',
    ),
  ];

  final List<Color> _accentColors = const [
    Color(0xFF22D3EE),
    Color(0xFF38BDF8),
    Color(0xFFF59E0B),
    Color(0xFF84CC16),
  ];

  @override
  void initState() {
    super.initState();
    _loadInstalledExtensions();
    _loadExtensionIndex();
  }

  Future<void> _loadInstalledExtensions() async {
    try {
      final installed = await _extensionService.listInstalledExtensions();
      final pkgs = installed.map((ext) => ext['pkgName'] as String).toSet();
      if (mounted) {
        setState(() {
          _installedPkgs = pkgs;
        });
      }
    } catch (e) {
      debugPrint('Error loading installed extensions: $e');
    }
  }

  Future<void> _installExtension(ExtensionRepoItem item) async {
    if (_installingPkgs.contains(item.pkg)) return;
    setState(() {
      _installingPkgs.add(item.pkg);
    });
    try {
      final apkUrl = "${item.repoUrl}/apk/${item.apk}";
      debugPrint(
        '[SenpaiExtensions] Installing extension ${item.name} from $apkUrl...',
      );
      final result = await _extensionService.downloadExtensionApk(
        apkUrl: apkUrl,
        pkgName: item.pkg,
      );
      if (result != null && result['apkPath'] != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully installed ${item.name}!'),
              backgroundColor: const Color(0xFF84CC16),
            ),
          );
        }
        await _loadInstalledExtensions();
      } else {
        throw Exception('Failed to save downloaded file.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to install ${item.name}: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _installingPkgs.remove(item.pkg);
        });
      }
    }
  }

  Future<void> _loadExtensionIndex() async {
    setState(() => _isLoading = true);
    await _extensionService.loadExtensionFromAssets(
      'assets/extensions/yuzono_repo.js',
    );

    final extensions = await _extensionService.fetchExtensionIndexes(
      _repoConfigs,
    );
    await _loadInstalledExtensions();
    if (!mounted) return;
    setState(() {
      _extensions = extensions;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _extensionService.dispose();
    super.dispose();
  }

  List<ExtensionRepoItem> get _filteredExtensions {
    Iterable<ExtensionRepoItem> results = _extensions;

    if (_selectedRepoId != 'all') {
      results = results.where((item) => item.repoId == _selectedRepoId);
    }

    if (_selectedRepoType != 'all') {
      results = results.where(
        (item) =>
            item.repoType == _selectedRepoType || item.repoType == 'mixed',
      );
    }

    if (_query.isEmpty) return results.toList();
    final normalized = _query.toLowerCase();

    return results.where((item) {
      final nameMatch = item.name.toLowerCase().contains(normalized);
      final pkgMatch = item.pkg.toLowerCase().contains(normalized);
      final sourceMatch = item.sources.any(
        (source) =>
            source.name.toLowerCase().contains(normalized) ||
            source.lang.toLowerCase().contains(normalized),
      );
      return nameMatch || pkgMatch || sourceMatch;
    }).toList();
  }

  String get _selectedRepoName {
    if (_selectedRepoId == 'all') return 'All repos';
    final repo = _repoConfigs.firstWhere(
      (config) => config.id == _selectedRepoId,
      orElse: () => _repoConfigs.first,
    );
    return repo.name;
  }

  bool get _hasActiveFilters {
    return _query.isNotEmpty ||
        _selectedRepoId != 'all' ||
        _selectedRepoType != 'all';
  }

  bool _resolveIsManga(ExtensionRepoItem item) {
    if (item.repoType == 'manga') return true;
    if (item.repoType == 'anime') return false;
    return _selectedRepoType == 'manga';
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredExtensions;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF0B0F1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Extensions',
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadExtensionIndex,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B0F1A), Color(0xFF0F172A), Color(0xFF0B0F1A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            _buildBackgroundGlow(),
            SafeArea(
              top: false,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader()),
                  SliverToBoxAdapter(child: _buildRepoToggle()),
                  SliverToBoxAdapter(child: _buildRepoFilters()),
                  SliverToBoxAdapter(child: _buildSearchBar()),
                  SliverToBoxAdapter(child: _buildStatsRow(filtered)),
                  ..._buildContentSlivers(filtered),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundGlow() {
    return Stack(
      children: [
        Positioned(
          top: -80,
          left: -40,
          child: _glowCircle(color: const Color(0xFF22D3EE), size: 220),
        ),
        Positioned(
          bottom: -120,
          right: -60,
          child: _glowCircle(color: const Color(0xFFF59E0B), size: 260),
        ),
      ],
    );
  }

  Widget _glowCircle({required Color color, required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: 0.35), Colors.transparent],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, kToolbarHeight + 24, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aniyomi Extensions',
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Browse curated extension repos from Yuzono, Aniyomi, and Keiyoushi.',
            style: GoogleFonts.urbanist(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildPill(
                icon: Icons.cloud_done_outlined,
                label: _selectedRepoName,
              ),
              _buildPill(
                icon: Icons.category_outlined,
                label:
                    _selectedRepoType == 'all'
                        ? 'All types'
                        : _selectedRepoType.toUpperCase(),
              ),
              _buildPill(
                icon: Icons.extension_outlined,
                label: '${_extensions.length} extensions',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRepoToggle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFF0B0F1A).withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildToggleButton(
                label: 'All',
                icon: Icons.dashboard_outlined,
                isActive: _selectedRepoType == 'all',
                activeColor: const Color(0xFF38BDF8),
                onTap: () {
                  if (_selectedRepoType != 'all') {
                    setState(() {
                      _selectedRepoType = 'all';
                    });
                  }
                },
              ),
            ),
            Expanded(
              child: _buildToggleButton(
                label: 'Anime',
                icon: Icons.movie_outlined,
                isActive: _selectedRepoType == 'anime',
                activeColor: const Color(0xFF22D3EE),
                onTap: () {
                  if (_selectedRepoType != 'anime') {
                    setState(() {
                      _selectedRepoType = 'anime';
                    });
                  }
                },
              ),
            ),
            Expanded(
              child: _buildToggleButton(
                label: 'Manga',
                icon: Icons.menu_book_outlined,
                isActive: _selectedRepoType == 'manga',
                activeColor: const Color(0xFFF59E0B),
                onTap: () {
                  if (_selectedRepoType != 'manga') {
                    setState(() {
                      _selectedRepoType = 'manga';
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepoFilters() {
    final chips = <Widget>[
      _buildRepoChip(
        label: 'All repos',
        isActive: _selectedRepoId == 'all',
        onTap: () => setState(() => _selectedRepoId = 'all'),
      ),
      ..._repoConfigs.map(
        (repo) => _buildRepoChip(
          label: repo.name,
          isActive: _selectedRepoId == repo.id,
          onTap: () => setState(() => _selectedRepoId = repo.id),
        ),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Wrap(spacing: 10, runSpacing: 10, children: chips),
    );
  }

  Widget _buildRepoChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final color = isActive ? const Color(0xFF22D3EE) : Colors.white54;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color:
              isActive
                  ? const Color(0xFF22D3EE).withValues(alpha: 0.18)
                  : const Color(0xFF0B0F1A).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isActive ? color : Colors.white.withValues(alpha: 0.12),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.urbanist(
            color: isActive ? Colors.white : Colors.white70,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient:
              isActive
                  ? LinearGradient(
                    colors: [
                      activeColor.withValues(alpha: 0.25),
                      activeColor.withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                  : null,
          borderRadius: BorderRadius.circular(12),
          border:
              isActive
                  ? Border.all(
                    color: activeColor.withValues(alpha: 0.5),
                    width: 1.5,
                  )
                  : Border.all(color: Colors.transparent, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? activeColor : Colors.white54,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                color: isActive ? Colors.white : Colors.white54,
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPill({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0F1A).withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white70),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.urbanist(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _query = value.trim()),
        style: GoogleFonts.urbanist(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search extensions or sources',
          hintStyle: GoogleFonts.urbanist(color: Colors.white54),
          prefixIcon: const Icon(Icons.search, color: Colors.white54),
          suffixIcon:
              _query.isEmpty
                  ? null
                  : IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                    icon: const Icon(Icons.close, color: Colors.white54),
                  ),
          filled: true,
          fillColor: const Color(0xFF0B0F1A).withValues(alpha: 0.7),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF22D3EE)),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(List<ExtensionRepoItem> items) {
    final totalExtensions = _extensions.length;
    final summaryItems = _hasActiveFilters ? items : _extensions;
    final totalSources = summaryItems.fold<int>(
      0,
      (sum, item) => sum + item.sources.length,
    );
    final nsfwCount = summaryItems.where((item) => item.nsfw == 1).length;
    final showLabel = _hasActiveFilters && totalExtensions > 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showLabel)
            Text(
              'Showing ${items.length} of $totalExtensions',
              style: GoogleFonts.urbanist(color: Colors.white54, fontSize: 12),
            ),
          if (showLabel) const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  label: 'Extensions',
                  value: totalExtensions.toString(),
                  color: const Color(0xFF22D3EE),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  label: 'Sources',
                  value: totalSources.toString(),
                  color: const Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  label: 'NSFW',
                  value: nsfwCount.toString(),
                  color: const Color(0xFFF97316),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0F1A).withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.urbanist(
              color: Colors.white60,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildContentSlivers(List<ExtensionRepoItem> items) {
    if (_isLoading) {
      return [
        const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: CircularProgressIndicator(color: Color(0xFF22D3EE)),
          ),
        ),
      ];
    }

    if (items.isEmpty) {
      return [
        SliverFillRemaining(hasScrollBody: false, child: _buildEmptyState()),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final item = items[index];
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 250 + (index * 30)),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, (1 - value) * 12),
                    child: child,
                  ),
                );
              },
              child: _buildExtensionCard(item, index),
            );
          }, childCount: items.length),
        ),
      ),
    ];
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, size: 48, color: Colors.white54),
            const SizedBox(height: 12),
            Text(
              'No extensions found',
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try a different search or refresh the repo index.',
              textAlign: TextAlign.center,
              style: GoogleFonts.urbanist(color: Colors.white60, fontSize: 14),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _loadExtensionIndex,
              icon: const Icon(Icons.refresh, color: Color(0xFF22D3EE)),
              label: Text(
                'Refresh',
                style: GoogleFonts.urbanist(
                  color: const Color(0xFF22D3EE),
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF22D3EE)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExtensionCard(ExtensionRepoItem item, int index) {
    final accent = _accentColors[index % _accentColors.length];
    final visibleSources = item.sources.take(3).toList();
    final remaining = item.sources.length - visibleSources.length;

    final tags = <Widget>[
      if (item.repoName.isNotEmpty) _buildTag(item.repoName, accent),
      if (item.repoType.isNotEmpty)
        _buildTag(item.repoType.toUpperCase(), accent),
      _buildTag((item.lang.isEmpty ? 'ALL' : item.lang.toUpperCase()), accent),
      if (item.version.isNotEmpty) _buildTag('v${item.version}', accent),
      _buildTag('${item.sources.length} sources', accent),
      if (item.nsfw == 1) _buildTag('NSFW', const Color(0xFFF97316)),
    ];

    return GestureDetector(
      onTap: () => _showSourcesSheet(item, accent),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              accent.withValues(alpha: 0.18),
              const Color(0xFF0B0F1A).withValues(alpha: 0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accent.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatar(item, accent),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name.isEmpty ? 'Untitled extension' : item.name,
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.pkg.isEmpty ? 'Package not listed' : item.pkg,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.urbanist(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                () {
                  final isInstalled = _installedPkgs.contains(item.pkg);
                  final isInstalling = _installingPkgs.contains(item.pkg);

                  Widget actionWidget;
                  if (isInstalling) {
                    actionWidget = const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF22D3EE),
                      ),
                    );
                  } else if (isInstalled) {
                    actionWidget = Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF84CC16).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF84CC16).withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check,
                            size: 10,
                            color: Color(0xFF84CC16),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Installed',
                            style: GoogleFonts.urbanist(
                              color: const Color(0xFF84CC16),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    actionWidget = ElevatedButton(
                      onPressed: () => _installExtension(item),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent.withValues(alpha: 0.15),
                        foregroundColor: accent,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        side: BorderSide(color: accent.withValues(alpha: 0.4)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Install',
                        style: GoogleFonts.urbanist(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }

                  return actionWidget;
                }(),
              ],
            ),
            const SizedBox(height: 12),
            if (item.apk.isNotEmpty)
              Row(
                children: [
                  const Icon(
                    Icons.file_download_outlined,
                    size: 14,
                    color: Colors.white54,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.apk,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.urbanist(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            if (item.apk.isNotEmpty) const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: tags),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...visibleSources.map(
                  (source) => _buildSourceChip(
                    '${source.name} (${source.lang})',
                    accent,
                  ),
                ),
                if (remaining > 0) _buildSourceChip('+$remaining more', accent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(ExtensionRepoItem item, Color accent) {
    final initial =
        item.name.isNotEmpty
            ? item.name.trim().substring(0, 1).toUpperCase()
            : '?';

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [accent, accent.withValues(alpha: 0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: accent.withValues(alpha: 0.7)),
      ),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.spaceGrotesk(
            color: const Color(0xFF0B0F1A),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: GoogleFonts.urbanist(
          color: Colors.white70,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSourceChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0F1A).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: GoogleFonts.urbanist(color: Colors.white60, fontSize: 11),
      ),
    );
  }

  void _showSourcesSheet(ExtensionRepoItem item, Color accent) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final maxHeight = MediaQuery.of(context).size.height * 0.7;

        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildAvatar(item, accent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.name.isEmpty ? 'Untitled extension' : item.name,
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.pkg.isEmpty ? 'Package not listed' : item.pkg,
                  style: GoogleFonts.urbanist(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Sources',
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                if (item.sources.isEmpty)
                  Text(
                    'No sources listed for this extension.',
                    style: GoogleFonts.urbanist(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      itemCount: item.sources.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final source = item.sources[index];

                        return InkWell(
                          onTap: () {
                            final isInstalled = _installedPkgs.contains(
                              item.pkg,
                            );
                            if (!isInstalled) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Please install ${item.name} first.',
                                  ),
                                  backgroundColor: const Color(0xFFEF4444),
                                ),
                              );
                              return;
                            }
                            Navigator.pop(context); // Close bottom sheet
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => SourceDetailsScreen(
                                      source: source,
                                      isManga: _resolveIsManga(item),
                                    ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF0B0F1A,
                              ).withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: accent.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  source.name,
                                  style: GoogleFonts.urbanist(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${source.lang} | ${source.id}',
                                  style: GoogleFonts.urbanist(
                                    color: Colors.white54,
                                    fontSize: 11,
                                  ),
                                ),
                                if (source.baseUrl.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      source.baseUrl,
                                      style: GoogleFonts.urbanist(
                                        color: Colors.white38,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
