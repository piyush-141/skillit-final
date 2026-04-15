import 'package:flutter/material.dart';
import '../main.dart';
import 'internship_screen.dart';
import 'hackathon_screen.dart';
import 'companies_screen.dart';
import 'saved_items_screen.dart';
import 'login_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  final String userName;
  final String userEmail;

  const HomeScreen({super.key, this.userName = 'User', this.userEmail = ''});

  final List<Map<String, dynamic>> features = const [
    {
      "title": "Internships",
      "icon": Icons.work_outline,
      "route": "/internships",
      "count": "35+",
      "subtitle": "Live Opportunities"
    },
    {
      "title": "Hackathons",
      "icon": Icons.emoji_events_outlined,
      "route": "/hackathons",
      "count": "50+",
      "subtitle": "Active Contests"
    },
    {
      "title": "Companies",
      "icon": Icons.business_outlined,
      "route": "/companies",
      "count": "100+",
      "subtitle": "Top Employers"
    },
    {
      "title": "Roadmaps",
      "icon": Icons.map_outlined,
      "route": "/roadmaps",
      "count": "20+",
      "subtitle": "Career Paths"
    },
    {
      "title": "Saved Items",
      "icon": Icons.bookmark_outline,
      "route": "/saved",
      "count": "Sync",
      "subtitle": "Your Wishlist"
    },
    {
      "title": "Projects",
      "icon": Icons.code_outlined,
      "route": "/projects",
      "count": "300+",
      "subtitle": "Ideas"
    },
  ];

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.primary.withOpacity(0.2),
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          if (userEmail.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              userEmail,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Divider(color: AppColors.border),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  label: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleNavigation(BuildContext context, Map<String, dynamic> item) {
    if (item["title"] == "Internships") {
      Navigator.push(context, MaterialPageRoute(builder: (_) => InternshipScreen()));
    } else if (item["title"] == "Hackathons") {
      Navigator.push(context, MaterialPageRoute(builder: (_) => HackathonScreen()));
    } else if (item["title"] == "Companies") {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const CompaniesScreen()));
    } else if (item["title"] == "Saved Items") {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const SavedItemsScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${item["title"]} - Coming Soon!"),
          backgroundColor: AppColors.textPrimary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome Back",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userName,
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _showProfileMenu(context),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.grayBg,
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: 'Where are you going?',
                  hintStyle: GoogleFonts.outfit(color: AppColors.textSecondary),
                  prefixIcon: const Icon(Icons.search, color: AppColors.primary, size: 22),
                  fillColor: Colors.transparent,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Section Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              "Explore Features",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: 16),

          // Features Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 8.0, bottom: 120.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1, // Flexible enough for padding
              ),
              itemCount: features.length,
              itemBuilder: (context, index) {
                final item = features[index];
                return InkWell(
                  onTap: () => _handleNavigation(context, item),
                  borderRadius: BorderRadius.circular(8),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(item["icon"], color: AppColors.primary, size: 28),
                          const Spacer(),
                          Text(
                            item["title"],
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item["subtitle"],
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}