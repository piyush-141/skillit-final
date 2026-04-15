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
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: _loadHackathons,
                ),
              ],
            ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Elegant Header Section
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.hideAppBar) ...[
                  Text("Hackathons", style: Theme.of(context).textTheme.displayLarge),
                  const SizedBox(height: 16),
                ],
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    onChanged: (value) => setState(() => searchQuery = value),
                    decoration: InputDecoration(
                      hintText: "Search coding contests",
                      prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      fillColor: Colors.transparent,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: filters.map((filter) {
                      final isSelected = selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() => selectedFilter = filter);
                          },
                          showCheckmark: false,
                          backgroundColor: Colors.white,
                          selectedColor: Colors.black,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? Colors.black : AppColors.border,
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

          // Main Listing
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : RefreshIndicator(
                    onRefresh: _loadHackathons,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                      itemCount: filteredHackathons.length,
                      itemBuilder: (context, index) {
                        final item = filteredHackathons[index];
                        final title = item["title"] ?? "Untitled";
                        final isBookmarked = bookmarkedTitles.contains(title);
                        return _buildHackathonCard(item, title, isBookmarked);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHackathonCard(Map<String, dynamic> item, String title, bool isBookmarked) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: InkWell(
        onTap: () => _openLink(item["link"] ?? ""),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.grayBg,
                      image: DecorationImage(
                        image: NetworkImage("https://source.unsplash.com/featured/?coding,hackathon,${title.split(' ').first}"),
                        fit: BoxFit.cover,
                        onError: (e, s) => {},
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () async {
                        bool isSaved = await BookmarkService.toggleHackathon(title);
                        setState(() {
                          if (isSaved) {
                            bookmarkedTitles.add(title);
                          } else {
                            bookmarkedTitles.remove(title);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Icon(
                          isBookmarked ? Icons.favorite : Icons.favorite_border,
                          color: isBookmarked ? AppColors.primary : AppColors.textPrimary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.black),
                    const SizedBox(width: 4),
                    Text(item["prize"]?.contains('\$') == true ? "Grand" : "Top", 
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            Text(item["organizer"] ?? "Global Organizer", style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(
              "${item["date"]} • ${item["mode"]}",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              item["location"] ?? "Online",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}