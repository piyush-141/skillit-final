import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import '../models/internship_model.dart';
import '../services/api_service.dart';
import '../services/bookmark_service.dart';

class InternshipScreen extends StatefulWidget {
  final bool hideAppBar;
  const InternshipScreen({super.key, this.hideAppBar = false});

  @override
  State<InternshipScreen> createState() => _InternshipScreenState();
}

class _InternshipScreenState extends State<InternshipScreen> {
  String selectedFilter = "All";
  List<String> filters = ["All", "Remote", "Full-time", "Hybrid"];
  Set<String> bookmarkedIds = {};
  String searchQuery = "";

  List<Internship> internships = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadInternships();
  }

  Future<void> _loadInternships() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final data = await ApiService.getInternships();
      final List<Internship> loadedInternships = data.map((json) {
        return Internship.fromJson(json);
      }).toList();

      if (mounted) {
        final savedIds = await BookmarkService.getSavedInternshipIds();
        setState(() {
          internships = loadedInternships;
          bookmarkedIds = savedIds.toSet();
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load internships';
        });
      }
    }
  }

  Future<void> _openLink(String url) async {
    if (url.isEmpty) return;
    final Uri uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  List<Internship> get filteredInternships {
    var filtered = internships;
    if (selectedFilter != "All") {
      filtered = filtered.where((item) => item.type == selectedFilter).toList();
    }
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((item) {
        return item.title.toLowerCase().contains(query) ||
            item.company.toLowerCase().contains(query);
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
              title: const Text('Internships'),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  onPressed: _loadInternships,
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
                  height: 38, // Standard iOS search height
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3E3E8).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    onChanged: (value) => setState(() => searchQuery = value),
                    decoration: const InputDecoration(
                      hintText: "Search internships",
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
                    onRefresh: _loadInternships,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      itemCount: filteredInternships.length,
                      itemBuilder: (context, index) {
                        final item = filteredInternships[index];
                        final isBookmarked = bookmarkedIds.contains(item.title);
                        return _buildInternshipItem(item, isBookmarked);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInternshipItem(Internship item, bool isBookmarked) {
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
            color: const Color(0xFFF2F2F7),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.business_rounded, color: AppColors.primary, size: 24),
        ),
        title: Text(
          item.title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.company, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on_rounded, size: 12, color: Color(0xFF8E8E93)),
                const SizedBox(width: 4),
                Text(item.location, style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93))),
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
            bool isSaved = await BookmarkService.toggleInternship(item.title);
            setState(() {
              if (isSaved) {
                bookmarkedIds.add(item.title);
              } else {
                bookmarkedIds.remove(item.title);
              }
            });
          },
        ),
        onTap: () => _openLink(item.link),
      ),
    );
  }
}