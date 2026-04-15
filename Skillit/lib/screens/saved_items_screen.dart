import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import '../models/internship_model.dart';
import '../services/api_service.dart';
import '../services/bookmark_service.dart';

class SavedItemsScreen extends StatefulWidget {
  const SavedItemsScreen({super.key});

  @override
  State<SavedItemsScreen> createState() => _SavedItemsScreenState();
}

class _SavedItemsScreenState extends State<SavedItemsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Internship> savedInternships = [];
  List<Map<String, dynamic>> savedHackathons = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSavedItems();
  }

  Future<void> _loadSavedItems() async {
    setState(() => isLoading = true);
    
    // Load saved IDs
    final internshipIds = await BookmarkService.getSavedInternshipIds();
    final hackathonIds = await BookmarkService.getSavedHackathonTitles();
    
    // Fetch all data (handling offline fallback as usual)
    final allInternships = await ApiService.getInternships();
    final allHackathons = await ApiService.getHackathons();
    
    // Filter
    final filteredInternships = allInternships
        .where((item) => internshipIds.contains(item['title']))
        .map((json) => Internship.fromJson(json))
        .toList();
        
    final filteredHackathons = allHackathons
        .where((item) => hackathonIds.contains(item['title']))
        .toList();

    if (mounted) {
      setState(() {
        savedInternships = filteredInternships;
        savedHackathons = filteredHackathons;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Saved Items"),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: "Internships", icon: Icon(Icons.business_center)),
            Tab(text: "Hackathons", icon: Icon(Icons.emoji_events)),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildInternshipList(),
                _buildHackathonList(),
              ],
            ),
    );
  }

  Widget _buildInternshipList() {
    if (savedInternships.isEmpty) {
      return _buildEmptyState("No saved internships yet");
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: savedInternships.length,
      itemBuilder: (context, index) {
        final item = savedInternships[index];
        return _buildInternshipCard(item);
      },
    );
  }

  Widget _buildHackathonList() {
    if (savedHackathons.isEmpty) {
      return _buildEmptyState("No saved hackathons yet");
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: savedHackathons.length,
      itemBuilder: (context, index) {
        final item = savedHackathons[index];
        return _buildHackathonCard(item);
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border, size: 64, color: AppColors.textMuted.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: AppColors.textMuted, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildInternshipCard(Internship item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${item.company} • ${item.location}"),
        trailing: IconButton(
          icon: const Icon(Icons.bookmark, color: AppColors.primary),
          onPressed: () async {
            await BookmarkService.toggleInternship(item.title);
            _loadSavedItems();
          },
        ),
        onTap: () async {
          final uri = Uri.parse(item.link);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
      ),
    );
  }

  Widget _buildHackathonCard(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        title: Text(item['title'] ?? "Untitled", style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${item['organizer'] ?? 'Unknown'} • ${item['mode'] ?? 'Online'}"),
        trailing: IconButton(
          icon: const Icon(Icons.bookmark, color: AppColors.primary),
          onPressed: () async {
            await BookmarkService.toggleHackathon(item['title']);
            _loadSavedItems();
          },
        ),
        onTap: () async {
          final uri = Uri.parse(item['link'] ?? "");
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
      ),
    );
  }
}
