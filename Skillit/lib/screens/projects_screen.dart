import 'package:flutter/material.dart';
import '../main.dart';
import '../services/api_service.dart';

class ProjectsScreen extends StatefulWidget {
  final bool hideAppBar;
  final String? initialDomainId;
  final String? initialProjectTitle;
  const ProjectsScreen(
      {super.key,
      this.hideAppBar = false,
      this.initialDomainId,
      this.initialProjectTitle});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  List<dynamic> _allDomains = [];
  Map<String, dynamic>? _selectedDomain;
  String _selectedLevel = "All";
  bool _isLoading = true;
  String _errorMessage = "";
  String? _expandedProjectId;

  final List<String> _levels = ["All", "Basic", "Intermediate", "Advanced"];

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      final dynamic data = await ApiService.getProjects();
      if (!mounted) return;
      setState(() {
        if (data is Map && data.containsKey('domains')) {
          _allDomains = List<dynamic>.from(data['domains']);
        } else if (data is List) {
          _allDomains = List<dynamic>.from(data);
        } else {
          _errorMessage = "Could not load project data.";
          _allDomains = [];
        }
        _isLoading = false;
      });

      // Auto-select domain if provided
      if (widget.initialDomainId != null && _allDomains.isNotEmpty) {
        try {
          final domain = _allDomains.firstWhere(
              (d) => d['domain_id'] == widget.initialDomainId);
          if (mounted) {
            setState(() {
              _selectedDomain = domain as Map<String, dynamic>;
            });
          }
        } catch (_) {}
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to load projects. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder to always have proper constraints
    final content = LayoutBuilder(
      builder: (context, constraints) {
        if (_isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_errorMessage.isNotEmpty) {
          return _buildErrorState();
        }
        if (_selectedDomain == null) {
          return _buildDomainSelectionGrid(constraints);
        }
        return _buildProjectExplorer(constraints);
      },
    );

    if (widget.hideAppBar) {
      return Material(
        color: AppColors.background,
        child: content,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Project Ideas"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _selectedDomain != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _selectedDomain = null),
              )
            : null,
      ),
      body: content,
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(_errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary)),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
              onPressed: _loadProjects, child: const Text("Retry")),
        ],
      ),
    );
  }

  Widget _buildDomainSelectionGrid(BoxConstraints constraints) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Select a Domain",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                ),
                SizedBox(height: 8),
                Text(
                  "Pick a path to see curated project ideas for your portfolio.",
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
        if (_allDomains.isEmpty)
          const SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 56, color: AppColors.textMuted),
                  SizedBox(height: 12),
                  Text(
                    "No project domains found.",
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.0,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    _buildDomainCard(_allDomains[index] as Map<String, dynamic>),
                childCount: _allDomains.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDomainCard(Map<String, dynamic> domain) {
    final projectCount = (domain['projects'] as List?)?.length ?? 0;
    return InkWell(
      onTap: () => setState(() {
        _selectedDomain = domain;
        _selectedLevel = "All";
        _expandedProjectId = null;
      }),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getDomainIcon(domain['domain_id']?.toString() ?? ''),
              size: 40,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            Text(
              domain['domain_label']?.toString() ?? "Unknown",
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              "$projectCount Projects",
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getDomainIcon(String id) {
    final s = id.toLowerCase();
    if (s.contains('frontend')) return Icons.web;
    if (s.contains('backend')) return Icons.storage;
    if (s.contains('fullstack')) return Icons.layers;
    if (s.contains('machine')) return Icons.psychology;
    if (s.contains('data')) return Icons.analytics;
    if (s.contains('android') || s.contains('mobile')) return Icons.phone_android;
    if (s.contains('cloud')) return Icons.cloud;
    if (s.contains('cyber')) return Icons.security;
    return Icons.code;
  }

  Widget _buildProjectExplorer(BoxConstraints constraints) {
    final allProjects =
        (_selectedDomain!['projects'] as List<dynamic>? ?? []);
    final filtered = _selectedLevel == "All"
        ? allProjects
        : allProjects
            .where((p) => p['level']?.toString() == _selectedLevel)
            .toList();

    return Column(
      children: [
        // Header row with back button
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios,
                    size: 20, color: AppColors.primary),
                onPressed: () =>
                    setState(() => _selectedDomain = null),
              ),
              Expanded(
                child: Text(
                  _selectedDomain!['domain_label']?.toString() ?? "",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        // Difficulty tabs
        SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _levels.length,
            itemBuilder: (context, index) {
              final level = _levels[index];
              final isSelected = _selectedLevel == level;
              return Padding(
                padding: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
                child: ChoiceChip(
                  label: Text(level),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) setState(() => _selectedLevel = level);
                  },
                  backgroundColor: AppColors.surface,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color:
                        isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              );
            },
          ),
        ),
        const Divider(height: 1, color: AppColors.border),
        // Project list
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    "No $_selectedLevel projects found.",
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return _buildProjectCard(
                        filtered[index] as Map<String, dynamic>);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> project) {
    final String title =
        project['title']?.toString() ?? "Untitled Project";
    final String pId = project['level_id']?.toString() ??
        project['_id']?.toString() ??
        title;
    final bool isExpanded = _expandedProjectId == pId;
    final String level = project['level']?.toString() ?? "Basic";

    Color levelColor = Colors.green;
    if (level == "Intermediate") levelColor = Colors.orange;
    if (level == "Advanced") levelColor = Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isExpanded
              ? levelColor.withOpacity(0.5)
              : AppColors.border,
          width: isExpanded ? 1.5 : 1,
        ),
        boxShadow: isExpanded
            ? [
                BoxShadow(
                  color: levelColor.withOpacity(0.08),
                  blurRadius: 12,
                  spreadRadius: 1,
                )
              ]
            : [],
      ),
      child: Theme(
        data:
            Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: PageStorageKey(pId),
          initiallyExpanded: isExpanded,
          onExpansionChanged: (expanded) {
            setState(() {
              _expandedProjectId = expanded ? pId : null;
            });
          },
          leading: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: levelColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              level[0],
              style: TextStyle(
                  color: levelColor, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15),
          ),
          subtitle: _buildSkillChips(
              project['skills_gained'] as List<dynamic>? ?? [],
              levelColor),
          trailing: AnimatedRotation(
            turns: isExpanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.keyboard_arrow_down),
          ),
          children: [
            const Divider(color: AppColors.border, height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection("Tagline", project['tagline']),
                  _buildSection("Overview", project['overview']),
                  _buildSection(
                      "What you will build", project['what_you_will_build']),
                  _buildLearnList(
                      project['what_you_will_learn'] as List<dynamic>?),
                  _buildTechChips(
                      project['trending_technologies'] as List<dynamic>?),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillChips(List<dynamic> skills, Color color) {
    if (skills.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: skills.take(3).map((s) => Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(s.toString(),
                  style: TextStyle(
                      fontSize: 10, color: color.withOpacity(0.9))),
            )).toList(),
      ),
    );
  }

  Widget _buildLearnList(List<dynamic>? items) {
    if (items == null || items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("What you will learn",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontSize: 13)),
          const SizedBox(height: 6),
          ...items.map((step) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("• ",
                        style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(step.toString(),
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              height: 1.4)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildTechChips(List<dynamic>? techs) {
    if (techs == null || techs.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Trending Tech Stack",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                fontSize: 13)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: techs
              .map((t) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(t.toString(),
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500)),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildSection(String title, dynamic content) {
    if (content == null || content.toString().trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontSize: 13)),
          const SizedBox(height: 4),
          Text(content.toString(),
              style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4)),
        ],
      ),
    );
  }
}
