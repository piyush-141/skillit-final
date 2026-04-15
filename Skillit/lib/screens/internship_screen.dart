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
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: _loadInternships,
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
                  Text("Internships", style: Theme.of(context).textTheme.displayLarge),
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
                      hintText: "Search company or role",
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
                    onRefresh: _loadInternships,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                      itemCount: filteredInternships.length,
                      itemBuilder: (context, index) {
                        final item = filteredInternships[index];
                        final isBookmarked = bookmarkedIds.contains(item.title);
                        return _buildInternshipCard(item, isBookmarked);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInternshipCard(Internship item, bool isBookmarked) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: InkWell(
        onTap: () => _openLink(item.link),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Placeholder (Airbnb uses large images)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.grayBg,
                      image: DecorationImage(
                        image: NetworkImage("https://source.unsplash.com/featured/?office,${item.company.replaceAll(' ', '')}"),
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
                        bool isSaved = await BookmarkService.toggleInternship(item.title);
                        setState(() {
                          if (isSaved) {
                            bookmarkedIds.add(item.title);
                          } else {
                            bookmarkedIds.remove(item.title);
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
                    item.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.black),
                    const SizedBox(width: 4),
                    Text("New", style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            Text(item.company, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(
              "${item.duration} • ${item.type}",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              item.location,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}