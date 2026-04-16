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
  List<dynamic> _allDomains = [];
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
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await ApiService.getProjects();
      if (!mounted) return;
      List<dynamic> domains = [];
      if (data is Map && data.containsKey('domains')) {
        domains = List<dynamic>.from(data['domains'] as List);
      } else if (data is List) {
        domains = List<dynamic>.from(data);
      }
      setState(() { _allDomains = domains; _isLoading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _isLoading = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (_isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40, color: Colors.red),
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    } else if (_selectedDomain == null) {
      body = _DomainGrid(
        domains: _allDomains,
        onSelect: (d) => setState(() {
          _selectedDomain = d;
          _selectedLevel = "All";
          _expandedId = null;
        }),
      );
    } else {
      body = _ProjectList(
        domain: _selectedDomain!,
        levels: _levels,
        selectedLevel: _selectedLevel,
        expandedId: _expandedId,
        onLevelChanged: (l) => setState(() => _selectedLevel = l),
        onBack: () => setState(() => _selectedDomain = null),
        onExpand: (id) => setState(() => _expandedId = _expandedId == id ? null : id),
      );
    }

    if (widget.hideAppBar) {
      return body;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Project Ideas'),
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
}

// ── Domain Grid ───────────────────────────────────────────────────────────────

class _DomainGrid extends StatelessWidget {
  final List<dynamic> domains;
  final void Function(Map<String, dynamic>) onSelect;

  const _DomainGrid({required this.domains, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    if (domains.isEmpty) {
      return const Center(
        child: Text('No domains found', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Select a Domain',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('Pick a domain to explore project ideas.',
                    style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: domains.length,
            itemBuilder: (_, i) {
              final d = domains[i] as Map<String, dynamic>;
              final count = (d['projects'] as List?)?.length ?? 0;
              return InkWell(
                onTap: () => onSelect(d),
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
                      Icon(_icon(d['domain_id']?.toString() ?? ''),
                          size: 36, color: AppColors.primary),
                      const SizedBox(height: 10),
                      Text(
                        d['domain_label']?.toString() ?? 'Domain',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text('$count projects',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textMuted)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _icon(String id) {
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

// ── Project List ──────────────────────────────────────────────────────────────

class _ProjectList extends StatelessWidget {
  final Map<String, dynamic> domain;
  final List<String> levels;
  final String selectedLevel;
  final String? expandedId;
  final void Function(String) onLevelChanged;
  final VoidCallback onBack;
  final void Function(String) onExpand;

  const _ProjectList({
    required this.domain,
    required this.levels,
    required this.selectedLevel,
    required this.expandedId,
    required this.onLevelChanged,
    required this.onBack,
    required this.onExpand,
  });

  @override
  Widget build(BuildContext context) {
    final all = (domain['projects'] as List<dynamic>? ?? []);
    final filtered = selectedLevel == 'All'
        ? all
        : all.where((p) => p['level']?.toString() == selectedLevel).toList();

    return Column(
      children: [
        // Back + title
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 18,
                    color: AppColors.primary),
                onPressed: onBack,
              ),
              Expanded(
                child: Text(
                  domain['domain_label']?.toString() ?? '',
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        // Level chips
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: levels.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (_, i) {
              final lvl = levels[i];
              final sel = lvl == selectedLevel;
              return ChoiceChip(
                label: Text(lvl,
                    style: TextStyle(
                        color: sel ? Colors.white : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: sel ? FontWeight.bold : FontWeight.normal)),
                selected: sel,
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surface,
                onSelected: (_) => onLevelChanged(lvl),
              );
            },
          ),
        ),
        const Divider(height: 1),
        // Project items
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text('No $selectedLevel projects found.',
                      style:
                          const TextStyle(color: AppColors.textSecondary)))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _ProjectCard(
                    project: filtered[i] as Map<String, dynamic>,
                    expandedId: expandedId,
                    onExpand: onExpand,
                  ),
                ),
        ),
      ],
    );
  }
}

// ── Project Card ──────────────────────────────────────────────────────────────

class _ProjectCard extends StatelessWidget {
  final Map<String, dynamic> project;
  final String? expandedId;
  final void Function(String) onExpand;

  const _ProjectCard(
      {required this.project,
      required this.expandedId,
      required this.onExpand});

  @override
  Widget build(BuildContext context) {
    final title = project['title']?.toString() ?? 'Untitled';
    final id = project['level_id']?.toString() ?? title;
    final level = project['level']?.toString() ?? 'Basic';
    final skills = project['skills_gained'] as List<dynamic>? ?? [];
    final techs = project['trending_technologies'] as List<dynamic>? ?? [];
    final learn = project['what_you_will_learn'] as List<dynamic>? ?? [];
    final isExpanded = expandedId == id;

    Color lc = Colors.green;
    if (level == 'Intermediate') lc = Colors.orange;
    if (level == 'Advanced') lc = Colors.red;

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
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
                color: lc.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6)),
            child: Text(level[0],
                style: TextStyle(
                    color: lc, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          title: Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14)),
          subtitle: skills.isEmpty
              ? null
              : Wrap(
                  spacing: 4,
                  runSpacing: 2,
                  children: skills.take(3).map((s) => Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: lc.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(4)),
                        child: Text(s.toString(),
                            style: TextStyle(
                                fontSize: 10,
                                color: lc.withOpacity(0.9))),
                      )).toList(),
                ),
          children: [
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((project['tagline'] ?? '').toString().isNotEmpty)
                    _sec('Tagline', project['tagline'].toString()),
                  if ((project['overview'] ?? '').toString().isNotEmpty)
                    _sec('Overview', project['overview'].toString()),
                  if ((project['what_you_will_build'] ?? '').toString().isNotEmpty)
                    _sec('What you will build',
                        project['what_you_will_build'].toString()),
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
                                          height: 1.4))),
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
                                    border:
                                        Border.all(color: AppColors.border)),
                                child: Text(t.toString(),
                                    style: const TextStyle(fontSize: 11)),
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

  Widget _sec(String title, String content) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
        ]),
      );
}
