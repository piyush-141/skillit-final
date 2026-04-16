import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import '../services/api_service.dart';
import '../services/bookmark_service.dart';

class HackathonScreen extends StatefulWidget {
  final bool hideAppBar;
  const HackathonScreen({super.key, this.hideAppBar = false});

  @override
  State<HackathonScreen> createState() => _HackathonScreenState();
}

class _HackathonScreenState extends State<HackathonScreen> {
  String selectedFilter = "All";
  List<String> filters = ["All", "Online", "Offline", "Hybrid"];
  Set<String> bookmarkedTitles = {};
  String searchQuery = "";

  List<Map<String, dynamic>> hackathons = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadHackathons();
  }

  Future<void> _loadHackathons() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final data = await ApiService.getHackathons();
      if (mounted) {
        final savedTitles = await BookmarkService.getSavedHackathonTitles();
        setState(() {
          hackathons = data;
          bookmarkedTitles = savedTitles.toSet();
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load hackathons';
        });
      }
    }
  }

  void _openLink(String url) async {
    if (url.isEmpty) return;
    final Uri uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  List<Map<String, dynamic>> get filteredHackathons {
    var filtered = hackathons;
    if (selectedFilter != "All") {
      filtered = filtered.where((item) {
        final mode = item["mode"]?.toString().toLowerCase() ?? "";
        return mode.contains(selectedFilter.toLowerCase());
      }).toList();
    }
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((item) {
        final title = item["title"]?.toString().toLowerCase() ?? "";
        return title.contains(query);
      }).toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: widget.hideAppBar 
          ? null 
          : AppBar(
              title: const Text('Hackathons'),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  onPressed: _loadHackathons,
                ),
              ],
            ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Apple Style Search & Filter
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3E3E8).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    onChanged: (value) => setState(() => searchQuery = value),
                    decoration: const InputDecoration(
                      hintText: "Search hackathons",
                      prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF8E8E93), size: 18),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                      fillColor: Colors.transparent,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: filters.map((filter) {
                      final isSelected = selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => selectedFilter = filter),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : Colors.white,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : const Color(0xFFC6C6C8),
                              ),
                            ),
                            child: Text(
                              filter,
                              style: TextStyle(
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // iOS Style List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : RefreshIndicator(
                    onRefresh: _loadHackathons,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      itemCount: filteredHackathons.length,
                      itemBuilder: (context, index) {
                        final item = filteredHackathons[index];
                        final title = item["title"] ?? "Untitled";
                        final isBookmarked = bookmarkedTitles.contains(title);
                        return _buildHackathonItem(item, title, isBookmarked);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHackathonItem(Map<String, dynamic> item, String title, bool isBookmarked) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7E6), // Subtle warm tint for contests
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.emoji_events_rounded, color: Color(0xFFFAAD14), size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item["organizer"] ?? "Global Host", style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 12, color: Color(0xFF8E8E93)),
                const SizedBox(width: 4),
                Text(item["date"] ?? "TBA", style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93))),
                const SizedBox(width: 12),
                const Icon(Icons.location_on_rounded, size: 12, color: Color(0xFF8E8E93)),
                const SizedBox(width: 4),
                Text(item["mode"] ?? "Online", style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93))),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            color: isBookmarked ? AppColors.primary : const Color(0xFFC6C6C8),
          ),
          onPressed: () async {
            bool isSaved = await BookmarkService.toggleHackathon(title);
            setState(() {
              if (isSaved) {
                bookmarkedTitles.add(title);
              } else {
                bookmarkedTitles.remove(title);
              }
            });
          },
        ),
        onTap: () => _openLink(item["link"] ?? ""),
      ),
    );
  }
}