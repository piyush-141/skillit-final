import 'package:flutter/material.dart';
import 'dart:async';
import '../main.dart';
import '../services/api_service.dart';
import 'internship_screen.dart';
import 'hackathon_screen.dart';
import 'companies_screen.dart';
import 'roadmap_screen.dart';
import 'projects_screen.dart';
import 'login_screen.dart';
import 'saved_items_screen.dart';
import 'cold_outreach_screen.dart';
import 'resume_builder_screen.dart';
import 'profile_screen.dart';
import 'skills_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  final String userEmail;

  const HomeScreen({super.key, this.userName = 'User', this.userEmail = ''});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  Map<String, List<dynamic>> _searchResults = {};
  bool _isSearching = false;
  bool _showResults = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  final List<Map<String, dynamic>> _features = const [
    {
      "title": "Internships",
      "icon": Icons.work_rounded,
      "subtitle": "Live roles"
    },
    {
      "title": "Hackathons",
      "icon": Icons.emoji_events_rounded,
      "subtitle": "Build & Win"
    },
    {
      "title": "Companies",
      "icon": Icons.business_rounded,
      "subtitle": "Top teams"
    },
    {"title": "Roadmaps", "icon": Icons.map_rounded, "subtitle": "Level up"},
    {
      "title": "Saved Items",
      "icon": Icons.bookmark_rounded,
      "subtitle": "Wishlist"
    },
    {"title": "Projects", "icon": Icons.code_rounded, "subtitle": "Code ideas"},
  ];

  final List<Map<String, dynamic>> _appTools = const [
    {
      "title": "Resume Builder",
      "keywords": "resume cv fix builder",
      "icon": Icons.description_rounded,
      "screen": "resume"
    },
    {
      "title": "Cold Outreach",
      "keywords": "email outreach networking cold",
      "icon": Icons.auto_awesome_rounded,
      "screen": "outreach"
    },
    {
      "title": "Tracked Progress",
      "keywords": "progress roadmaps learning tracked",
      "icon": Icons.map_rounded,
      "screen": "roadmaps"
    },
    {
      "title": "Saved Highlights",
      "keywords": "saved wishlist bookmark favorites",
      "icon": Icons.bookmark_rounded,
      "screen": "saved"
    },
    {
      "title": "Edit Profile",
      "keywords": "settings profile account edit name password",
      "icon": Icons.person_outline,
      "screen": "profile"
    },
    {
      "title": "Skill Assessment",
      "keywords": "skills test assessment evaluation",
      "icon": Icons.psychology_outlined,
      "screen": "skills"
    },
    {
      "title": "Company Directory",
      "keywords": "companies teams startups",
      "icon": Icons.business_rounded,
      "screen": "companies"
    },
    {
      "title": "Live Internships",
      "keywords": "internships jobs roles work",
      "icon": Icons.work_rounded,
      "screen": "internships"
    },
    {
      "title": "Active Hackathons",
      "keywords": "hackathons build events win",
      "icon": Icons.emoji_events_rounded,
      "screen": "hackathons"
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _removeOverlay();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.length < 2) {
        setState(() {
          _searchResults = {};
          _isSearching = false;
          _showResults = false;
        });
        _removeOverlay();
        return;
      }

      setState(() {
        _isSearching = true;
        _showResults = true;
      });

      _showOverlay(); // Create overlay if not present

      final results = await ApiService.search(query);

      // Filter local tools
      final matchedTools = _appTools.where((tool) {
        final searchStr = "${tool['title']} ${tool['keywords']}".toLowerCase();
        return searchStr.contains(query.toLowerCase());
      }).toList();

      if (mounted) {
        setState(() {
          _searchResults = {
            'Apps & Tools': matchedTools,
            'Internships': results['internships'] ?? [],
            'Hackathons': results['hackathons'] ?? [],
            'Companies': results['companies'] ?? [],
            'Roadmaps': results['roadmaps'] ?? [],
            'Projects': results['projects'] ?? [],
          };
          _isSearching = false;
        });
        _overlayEntry?.markNeedsBuild();
      }
    });
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width - 48,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 50),
          child: Material(
            elevation: 8,
            color: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 400),
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.98),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10))
                ],
              ),
              child: _isSearching
                  ? const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                          child: CircularProgressIndicator(strokeWidth: 3)),
                    )
                  : _searchResults.values.every((list) => list.isEmpty)
                      ? const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text("No results found",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textMuted)),
                        )
                      : ListView(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          children: _searchResults.entries
                              .where((e) => e.value.isNotEmpty)
                              .map((entry) {
                            return _buildSearchSection(entry.key, entry.value);
                          }).toList(),
                        ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSection(String title, List<dynamic> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(title.toUpperCase(),
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  letterSpacing: 1.2)),
        ),
        ...items.map((item) => _buildSearchResultItem(title, item)),
        const Divider(height: 1, color: AppColors.border),
      ],
    );
  }

  Widget _buildSearchResultItem(String type, dynamic item) {
    String title = "";
    String subtitle = "";
    IconData icon = Icons.search;

    switch (type) {
      case 'Internships':
        title = item['title'];
        subtitle = item['company'];
        icon = Icons.work_outline;
        break;
      case 'Hackathons':
        title = item['title'];
        subtitle = item['organizer'];
        icon = Icons.emoji_events_outlined;
        break;
      case 'Companies':
        title = item['name'];
        subtitle = item['industry'] ?? "Technology";
        icon = Icons.business_outlined;
        break;
      case 'Roadmaps':
        title = item['label'];
        subtitle = item['tagline'] ?? "Career Path";
        icon = Icons.map_outlined;
        break;
      case 'Projects':
        title = item['title'];
        subtitle = item['domainLabel'] ?? "Project Idea";
        icon = Icons.code_outlined;
        break;
      case 'Apps & Tools':
        title = item['title'];
        subtitle = "App Feature";
        icon = item['icon'] ?? Icons.apps_rounded;
        break;
    }

    return ListTile(
      dense: true,
      leading: Icon(icon, size: 18, color: AppColors.textSecondary),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      subtitle: Text(subtitle,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
      onTap: () {
        _removeOverlay();
        _searchController.clear();
        _navigateToResult(type, item);
      },
    );
  }

  void _navigateToResult(String type, dynamic item) {
    Widget target;
    switch (type) {
      case 'Internships':
        target = const InternshipScreen();
        break;
      case 'Hackathons':
        target = const HackathonScreen();
        break;
      case 'Companies':
        target = const CompaniesScreen();
        break;
      case 'Roadmaps':
        target = RoadmapScreen(initialRoadmapId: item['roadmapId']);
        break;
      case 'Projects':
        target = ProjectsScreen(
            initialDomainId: item['domainId'],
            initialProjectTitle: item['title']);
        break;
      case 'Apps & Tools':
        switch (item['screen']) {
          case 'resume':
            target = const ResumeBuilderScreen();
            break;
          case 'outreach':
            target = const ColdOutreachScreen();
            break;
          case 'roadmaps':
            target = const RoadmapScreen();
            break;
          case 'saved':
            target = SavedItemsScreen();
            break;
          case 'profile':
            target = ProfileScreen(
              userName: widget.userName,
              userEmail: widget.userEmail,
            );
            break;
          case 'skills':
            target = const SkillsScreen();
            break;
          case 'companies':
            target = const CompaniesScreen();
            break;
          case 'internships':
            target = const InternshipScreen();
            break;
          case 'hackathons':
            target = const HackathonScreen();
            break;
          default:
            return;
        }
        break;
      default:
        return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => target));
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.primary,
                    child: Text(
                        widget.userName.isNotEmpty
                            ? widget.userName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.userName,
                            style: Theme.of(context).textTheme.titleLarge),
                        Text(widget.userEmail,
                            style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Divider(color: AppColors.border),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                    (route) => false),
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: GestureDetector(
        onTap: () {
          _removeOverlay();
          FocusScope.of(context).unfocus();
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Hello,",
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: AppColors.textSecondary)),
                        Text(widget.userName,
                            style: Theme.of(context).textTheme.displayMedium),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => _showProfileMenu(context),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.grayBg,
                        child: Text(
                            widget.userName.isNotEmpty
                                ? widget.userName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Search Bar with LayerLink
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: CompositedTransformTarget(
                  link: _layerLink,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3E3E8).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: _showResults
                              ? AppColors.primary.withOpacity(0.3)
                              : Colors.transparent),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Search internships, projects, roadmaps...',
                        hintStyle: const TextStyle(
                            fontSize: 14, color: AppColors.textMuted),
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: AppColors.textMuted, size: 20),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged("");
                                })
                            : null,
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text("Quick Tools",
                        style: Theme.of(context).textTheme.titleLarge),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        _buildQuickToolCard(context,
                            title: "Cold Outreach",
                            icon: Icons.auto_awesome_rounded,
                            color: AppColors.primary,
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const ColdOutreachScreen()))),
                        const SizedBox(width: 12),
                        _buildQuickToolCard(context,
                            title: "Resume Builder",
                            icon: Icons.description_rounded,
                            color: AppColors.success,
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const ResumeBuilderScreen()))),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: Text("Recommended for you",
                    style: Theme.of(context).textTheme.titleLarge),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.4),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = _features[index];
                    return GestureDetector(
                      onTap: () {
                        if (item["title"] == "Internships")
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const InternshipScreen()));
                        else if (item["title"] == "Hackathons")
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const HackathonScreen()));
                        else if (item["title"] == "Companies")
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const CompaniesScreen()));
                        else if (item["title"] == "Saved Items")
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => SavedItemsScreen()));
                        else if (item["title"] == "Roadmaps")
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const RoadmapScreen()));
                        else if (item["title"] == "Projects")
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ProjectsScreen()));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4))
                            ]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(item["icon"],
                                color: AppColors.primary, size: 24),
                            const Spacer(),
                            Text(item["title"],
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 15)),
                            Text(item["subtitle"],
                                style: const TextStyle(
                                    color: AppColors.textMuted, fontSize: 12)),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: _features.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickToolCard(BuildContext context,
      {required String title,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
            border: Border.all(color: color.withOpacity(0.1), width: 1)),
        child: Row(
          children: [
            Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 20)),
            const SizedBox(width: 10),
            Expanded(
                child: Text(title,
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.textPrimary))),
          ],
        ),
      ),
    );
  }
}
