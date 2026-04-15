import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../main.dart'; // for AppColors

class RoadmapScreen extends StatefulWidget {
  final bool hideAppBar;
  const RoadmapScreen({super.key, this.hideAppBar = false});

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> {
  bool _isLoading = true;
  String _errorMessage = '';

  List<dynamic> _domains = [];
  Map<String, dynamic>? _selectedDomain;
  Set<String> _completedNodes = {};
  
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _initAndLoad();
  }

  Future<void> _initAndLoad() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _loadCompletedNodes();
    } catch (e) {
      print("⚠️ SharedPreferences failed: $e");
    }

    try {
      final data = await ApiService.getRoadmaps();
      if (data.isNotEmpty && data.containsKey('fields')) {
        setState(() {
          _domains = data['fields'] as List<dynamic>;
          if (_domains.isNotEmpty) {
            _selectedDomain = _domains[0];
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Invalid data received from roadmap API';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load roadmaps: $e';
      });
    }
  }

  void _loadCompletedNodes() {
    final saved = _prefs?.getStringList('completed_roadmap_nodes');
    if (saved != null) {
      setState(() {
        _completedNodes = saved.toSet();
      });
    }
  }

  Future<void> _toggleNodeCompletion(String nodeId) async {
    setState(() {
      if (_completedNodes.contains(nodeId)) {
        _completedNodes.remove(nodeId);
      } else {
        _completedNodes.add(nodeId);
      }
    });
    await _prefs?.setStringList('completed_roadmap_nodes', _completedNodes.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: widget.hideAppBar 
          ? const PreferredSize(preferredSize: Size.zero, child: SizedBox.shrink())
          : AppBar(
              title: const Text('Skills & Roadmaps'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: _initAndLoad,
                ),
              ],
            ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? _buildErrorState()
              : Column(
                  children: [
                    _buildDomainSelector(),
                    Expanded(
                      child: _selectedDomain == null
                          ? const Center(child: Text("Select a domain"))
                          : _buildRoadmapContent(_selectedDomain!),
                    ),
                  ],
                ),
    );
  }

  Widget _buildErrorState() {
     return Center(child: Text(_errorMessage, style: const TextStyle(color: AppColors.error)));
  }

  Widget _buildDomainSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _domains.map((domain) {
            final isSelected = _selectedDomain?['id'] == domain['id'];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(domain['label'] ?? 'Unknown'),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) setState(() => _selectedDomain = domain);
                },
                backgroundColor: AppColors.surface,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRoadmapContent(Map<String, dynamic> domain) {
    final content = domain['content'] ?? {};
    final roadmap = domain['roadmap'] as List<dynamic>? ?? [];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      children: [
        Text(domain['label'] ?? '', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(domain['tagline'] ?? '', style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
        const SizedBox(height: 16),
        _buildInfoCard("Overview", content['overview']),
        const SizedBox(height: 12),
        _buildInfoCard("Details", content['details']),
        const SizedBox(height: 24),
        const Text("Roadmap Nodes", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...roadmap.asMap().entries.map((entry) {
          return _buildNodeItem(domain['id'], entry.key, entry.value, entry.key == roadmap.length - 1);
        }).toList(),
      ],
    );
  }

  Widget _buildInfoCard(String title, String? text) {
    if (text == null || text.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(color: AppColors.textSecondary, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildNodeItem(String domainId, int index, dynamic node, bool isLast) {
    final String nodeId = "roadmap_${domainId}_${node['phase']}";
    final bool isCompleted = _completedNodes.contains(nodeId);
    final title = node['title'] ?? 'Phase ${node['phase']}';
    final skills = node['skills'] as List<dynamic>? ?? [];

    return IntrinsicHeight(
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                InkWell(
                  onTap: () => _toggleNodeCompletion(nodeId),
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted ? AppColors.success : AppColors.surface,
                      border: Border.all(color: isCompleted ? AppColors.success : AppColors.border, width: 2),
                    ),
                    child: Icon(isCompleted ? Icons.check : Icons.lock_open, size: 16, color: isCompleted ? Colors.white : AppColors.textMuted),
                  ),
                ),
                if (!isLast) Expanded(child: Container(width: 2, color: isCompleted ? AppColors.success : AppColors.border)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: InkWell(
                onTap: () => _toggleNodeCompletion(nodeId),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isCompleted ? AppColors.success.withOpacity(0.5) : AppColors.border),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Phase ${node['phase']}: $title", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, decoration: isCompleted ? TextDecoration.lineThrough : null)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8, runSpacing: 8,
                        children: skills.map((s) => Chip(label: Text(s.toString(), style: const TextStyle(fontSize: 10)))).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
