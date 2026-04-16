import 'package:flutter/material.dart';
import '../main.dart';
import '../services/api_service.dart';

class ProjectsScreen extends StatefulWidget {
  final bool hideAppBar;
  final String? initialDomainId;
  final String? initialProjectTitle;

  const ProjectsScreen({
    super.key,
    this.hideAppBar = false,
    this.initialDomainId,
    this.initialProjectTitle,
  });

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  List<Map<String, dynamic>> _allDomains = [];
  Map<String, dynamic>? _selectedDomain;
  String _selectedLevel = "All";
  bool _isLoading = true;
  String? _error;
  String? _expandedId;

  final _levels = ["All", "Basic", "Intermediate", "Advanced"];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await ApiService.getProjects();
      if (!mounted) return;
      List<Map<String, dynamic>> domains = [];
      if (data is Map && data.containsKey('domains')) {
        for (final d in (data['domains'] as List)) {
          domains.add(Map<String, dynamic>.from(d as Map));
        }
      } else if (data is List) {
        for (final d in data) {
          domains.add(Map<String, dynamic>.from(d as Map));
        }
      }
      setState(() {
        _allDomains = domains;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Failed to load projects: $e';
      });
    }
  }

  List<Map<String, dynamic>> get _filteredProjects {
    final all = (_selectedDomain?['projects'] as List<dynamic>? ?? [])
        .map((p) => Map<String, dynamic>.from(p as Map))
        .toList();
    if (_selectedLevel == 'All') return all;
    return all.where((p) => p['level']?.toString() == _selectedLevel).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40, color: Colors.red),
            const SizedBox(height: 8),
            Text(_error!, textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }

    // ── Domain Selection View ──────────────────────────────────────────
    if (_selectedDomain == null) {
      return CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Select a Domain',
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary)),
                  SizedBox(height: 6),
                  Text(
                      'Pick a domain to explore curated project ideas for your portfolio.',
                      style: TextStyle(color: AppColors.textSecondary,
                          fontSize: 14)),
                ],
              ),
            ),
          ),
          if (_allDomains.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text('No domains found.',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
              sliver: SliverGrid.builder(
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.05,
                ),
                itemCount: _allDomains.length,
                itemBuilder: (_, i) => _DomainCard(
                  domain: _allDomains[i],
                  onTap: () => setState(() {
                    _selectedDomain = _allDomains[i];
                    _selectedLevel = 'All';
                    _expandedId = null;
                  }),
                ),
              ),
            ),
        ],
      );
    }

    // ── Project List View ──────────────────────────────────────────────
    final projects = _filteredProjects;

    return CustomScrollView(
      slivers: [
        // Back header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios,
                      size: 18, color: AppColors.primary),
                  onPressed: () =>
                      setState(() => _selectedDomain = null),
                ),
                Expanded(
                  child: Text(
                    _selectedDomain!['domain_label']?.toString() ?? '',
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Level filter chips
        SliverToBoxAdapter(
          child: SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _levels.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, i) {
                final lvl = _levels[i];
                final sel = lvl == _selectedLevel;
                return ChoiceChip(
                  label: Text(lvl,
                      style: TextStyle(
                          color: sel ? Colors.white : AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight:
                              sel ? FontWeight.bold : FontWeight.normal)),
                  selected: sel,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  onSelected: (_) =>
                      setState(() => _selectedLevel = lvl),
                );
              },
            ),
          ),
        ),

        // Divider
        const SliverToBoxAdapter(
            child: Divider(height: 8, color: AppColors.border)),

        // No results
        if (projects.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Text('No $_selectedLevel projects found.',
                  style:
                      const TextStyle(color: AppColors.textSecondary)),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _ProjectCard(
                  project: projects[i],
                  expandedId: _expandedId,
                  onExpand: (id) => setState(() =>
                      _expandedId = (_expandedId == id) ? null : id),
                ),
                childCount: projects.length,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Domain Card ───────────────────────────────────────────────────────────────

class _DomainCard extends StatelessWidget {
  final Map<String, dynamic> domain;
  final VoidCallback onTap;
  const _DomainCard({required this.domain, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final label = domain['domain_label']?.toString() ?? 'Domain';
    final count = (domain['projects'] as List?)?.length ?? 0;
    final id = domain['domain_id']?.toString() ?? '';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: AppColors.shadow,
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_domainIcon(id), size: 36, color: AppColors.primary),
            const SizedBox(height: 10),
            Text(label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text('$count projects',
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }

  IconData _domainIcon(String id) {
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
}

// ── Project Card ──────────────────────────────────────────────────────────────

class _ProjectCard extends StatelessWidget {
  final Map<String, dynamic> project;
  final String? expandedId;
  final void Function(String) onExpand;

  const _ProjectCard({
    required this.project,
    required this.expandedId,
    required this.onExpand,
  });

  @override
  Widget build(BuildContext context) {
    final title = project['title']?.toString() ?? 'Untitled';
    final id = project['level_id']?.toString() ?? title;
    final level = project['level']?.toString() ?? 'Basic';
    final skills = (project['skills_gained'] as List<dynamic>? ?? []);
    final techs = (project['trending_technologies'] as List<dynamic>? ?? []);
    final learn = (project['what_you_will_learn'] as List<dynamic>? ?? []);
    final tagline = project['tagline']?.toString() ?? '';
    final overview = project['overview']?.toString() ?? '';
    final whatBuild = project['what_you_will_build']?.toString() ?? '';
    final isExpanded = expandedId == id;

    Color lc = const Color(0xFF34C759); // green
    if (level == 'Intermediate') lc = const Color(0xFFFF9500); // orange
    if (level == 'Advanced') lc = const Color(0xFFFF3B30); // red

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isExpanded ? lc.withOpacity(0.4) : AppColors.border),
        boxShadow: AppColors.shadow,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: PageStorageKey(id),
          initiallyExpanded: isExpanded,
          onExpansionChanged: (_) => onExpand(id),
          leading: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: lc.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(level[0],
                style: TextStyle(
                    color: lc,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ),
          title: Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.textPrimary)),
          subtitle: skills.isEmpty
              ? null
              : Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 2,
                    children: skills
                        .take(3)
                        .map((s) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: lc.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(s.toString(),
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: lc.withOpacity(0.9))),
                            ))
                        .toList(),
                  ),
                ),
          children: [
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (tagline.isNotEmpty) _section('Tagline', tagline),
                  if (overview.isNotEmpty) _section('Overview', overview),
                  if (whatBuild.isNotEmpty)
                    _section('What you will build', whatBuild),
                  if (learn.isNotEmpty) ...[
                    const Text('What you will learn',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.primary)),
                    const SizedBox(height: 6),
                    ...learn.map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ',
                                  style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold)),
                              Expanded(
                                child: Text(s.toString(),
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                        height: 1.4)),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 8),
                  ],
                  if (techs.isNotEmpty) ...[
                    const Text('Tech Stack',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.primary)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: techs
                          .map((t) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 9, vertical: 3),
                                decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.border)),
                                child: Text(t.toString(),
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary)),
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, String content) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.primary)),
            const SizedBox(height: 3),
            Text(content,
                style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4)),
          ],
        ),
      );
}
