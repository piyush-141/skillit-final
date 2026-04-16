import 'package:flutter/material.dart';
import '../main.dart';
import '../services/api_service.dart';

class ProjectsScreen extends StatefulWidget {
  final bool hideAppBar;
  final String? initialDomainId;
  final String? initialProjectTitle;
  const ProjectsScreen({super.key, this.hideAppBar = false, this.initialDomainId, this.initialProjectTitle});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  List<dynamic> _allDomains = [];
  Map<String, dynamic>? _selectedDomain;
  String _selectedLevel = "All";
  bool _isLoading = true;
  String _errorMessage = "";

  // Track the unique ID of the currently expanded project
  String? _expandedProjectId;

  final List<String> _levels = ["All", "Basic", "Intermediate", "Advanced"];

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      final dynamic data = await ApiService.getProjects();
      print("🔍 RECEIVED PROJECTS DATA: ${data != null}");
      if (mounted) {
        setState(() {
          if (data is Map && data.containsKey('domains')) {
            _allDomains = data['domains'] as List<dynamic>;
            print("✅ Loaded ${_allDomains.length} domains from Map");
          } else if (data is List) {
            _allDomains = data;
            print("✅ Loaded ${_allDomains.length} domains from List");
          } else {
            print("⚠️ Data structure invalid: $data");
            _errorMessage = "Invalid data structure in projects.json";
            _allDomains = [];
          }
          _isLoading = false;
        });

        if (widget.initialDomainId != null) {
          final domain = _allDomains.firstWhere(
            (d) => d['domain_id'] == widget.initialDomainId,
            orElse: () => null,
          );
          if (domain != null) {
            setState(() {
              _selectedDomain = domain;
              if (widget.initialProjectTitle != null) {
                _expandedProjectId = widget.initialProjectTitle; // Or a specific ID if available
              }
            });
          }
        }
      }
    } catch (e) {
      print("❌ Error loading projects: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Failed to load projects: $e";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage.isNotEmpty
            ? _buildErrorState()
            : AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _selectedDomain == null
                    ? _buildDomainSelectionGrid()
                    : _buildProjectExplorer(),
              );

    if (widget.hideAppBar) {
      return SizedBox.expand(
        child: Material(
          color: AppColors.background,
          child: SafeArea(child: body),
        ),
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
      body: body,
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text(_errorMessage, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _loadProjects, child: const Text("Retry")),
        ],
      ),
    );
  }

  // Requirement 2: First ask user to select a domain
  Widget _buildDomainSelectionGrid() {
    return Column(
      key: const ValueKey("domain_selection"),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Text(
            "Select a Domain",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Pick a path to see curated project ideas designed for your portfolio.",
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: _allDomains.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open, size: 48, color: AppColors.textMuted),
                      SizedBox(height: 16),
                      Text("No domains found in projects.json", style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                )
              : GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.0, // Increased height to prevent overflow
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemCount: _allDomains.length,
            itemBuilder: (context, index) {
              final domain = _allDomains[index];
              return _buildDomainCard(domain);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDomainCard(Map<String, dynamic> domain) {
    return InkWell(
      onTap: () => setState(() => _selectedDomain = domain),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.surface,
              AppColors.surface.withOpacity(0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
              _getDomainIcon(domain['domain_id']),
              size: 40,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            Text(
              domain['domain_label'] ?? "Unknown",
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              "${(domain['projects'] as List).length} Projects",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getDomainIcon(dynamic id) {
    final String sId = id.toString().toLowerCase();
    if (sId.contains('frontend')) return Icons.web;
    if (sId.contains('backend')) return Icons.storage;
    if (sId.contains('fullstack')) return Icons.layers;
    if (sId.contains('machine')) return Icons.psychology;
    if (sId.contains('data')) return Icons.analytics;
    if (sId.contains('android') || sId.contains('mobile')) return Icons.phone_android;
    if (sId.contains('cloud')) return Icons.cloud;
    if (sId.contains('cyber')) return Icons.security;
    return Icons.code;
  }

  // Requirement 3: Filtering & Requirement 5: Layout
  Widget _buildProjectExplorer() {
    final projects = (_selectedDomain!['projects'] as List<dynamic>? ?? []).where((p) {
      if (_selectedLevel == "All") return true;
      return p['level'] == _selectedLevel;
    }).toList();

    return Column(
      key: const ValueKey("project_explorer"),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildExplorerHeader(),
        _buildDifficultyTabs(),
        Expanded(
          child: projects.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                  itemCount: projects.length,
                  itemBuilder: (context, index) {
                    return _buildProjectCard(projects[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildExplorerHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 20, color: AppColors.primary),
                onPressed: () => setState(() => _selectedDomain = null),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              Text(
                _selectedDomain!['domain_label'] ?? "",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            "Choose a project difficulty level to get started.",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyTabs() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _levels.length,
        itemBuilder: (context, index) {
          final level = _levels[index];
          final isSelected = _selectedLevel == level;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(level),
              selected: isSelected,
              onSelected: (val) {
                if (val) setState(() => _selectedLevel = level);
              },
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: AppColors.textMuted.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            "No $_selectedLevel projects found.",
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // Requirement 4: Expandable Card Design & Requirement 6: Interaction
  Widget _buildProjectCard(Map<String, dynamic> project) {
    final String title = project['title']?.toString() ?? "Untitled Project";
    final String pId = project['level_id']?.toString() ?? 
                       project['_id']?.toString() ?? 
                       title;
    final bool isExpanded = _expandedProjectId == pId;
    final level = project['level']?.toString() ?? "Basic";
    
    Color levelColor = Colors.green;
    if (level == "Intermediate") levelColor = Colors.orange;
    if (level == "Advanced") levelColor = Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded ? levelColor.withOpacity(0.5) : AppColors.border,
          width: isExpanded ? 2 : 1,
        ),
        boxShadow: isExpanded ? [
          BoxShadow(
            color: levelColor.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
          )
        ] : [],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: PageStorageKey(pId),
          initiallyExpanded: isExpanded,
          // Requirement 6: Only one can be expanded
          onExpansionChanged: (expanded) {
            setState(() {
              _expandedProjectId = expanded ? pId : null;
            });
          },
          leading: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: levelColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              level.substring(0, 1),
              style: TextStyle(color: levelColor, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: _buildSkillsWrap(project['skills_gained'] as List<dynamic>? ?? [], levelColor),
          trailing: AnimatedRotation(
            turns: isExpanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.keyboard_arrow_down),
          ),
          children: [
            const Divider(color: AppColors.border, height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection("Tagline", project['tagline']),
                  _buildSection("Overview", project['overview']),
                  _buildSection("What you will build", project['what_you_will_build']),
                  
                  const SizedBox(height: 12),
                  const Text(
                    "Trending Technologies",
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  const SizedBox(height: 8),
                  ... (project['trending_technologies'] as List<dynamic>? ?? []).map((step) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("• ", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                        Expanded(child: Text(step.toString(), style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
                      ],
                    ),
                  )),

                  const SizedBox(height: 12),
                  const Text(
                    "Trending Tech Stack",
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (project['trending_technologies'] as List<dynamic>? ?? []).map((tech) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(tech.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsWrap(List<dynamic> skills, Color levelColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: skills.take(3).map((skill) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: levelColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            skill.toString(),
            style: TextStyle(fontSize: 10, color: levelColor.withOpacity(0.8)),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildSection(String title, dynamic content) {
    if (content == null || content.toString().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            content.toString(),
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }
}
