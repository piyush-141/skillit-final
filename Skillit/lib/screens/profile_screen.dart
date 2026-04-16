import 'package:flutter/material.dart';
import '../main.dart'; // for AppColors
import '../services/bookmark_service.dart';
import '../services/auth_service.dart';
import 'saved_items_screen.dart';
import '../services/api_service.dart';

import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userName;
  final String userEmail;

  const ProfileScreen({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String _currentName;
  late String _currentDomain;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentName = widget.userName;
    _currentDomain = "Not Set";
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final info = await AuthService.getUserInfo();
    setState(() {
      _currentName = info['name'] ?? widget.userName;
      _currentDomain = info['domain'] ?? "Not Set";
    });

    // Also try fetching from API for fresh data
    try {
      final fresh = await ApiService.getUserProfile();
      if (fresh.containsKey('name')) {
        await AuthService.updateUserLocalData(
          name: fresh['name'],
          domain: fresh['domain'],
        );
        if (mounted) {
          setState(() {
            _currentName = fresh['name'];
            _currentDomain = fresh['domain'] ?? "Not Set";
          });
        }
      }
    } catch (e) {
      print("Error refreshing profile: $e");
    }
  }

  void _navigateToEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          currentName: _currentName,
          currentEmail: widget.userEmail,
          currentDomain: _currentDomain,
        ),
      ),
    );

    if (result == true) {
      _loadProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 22),
            onPressed: _loadProfile,
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadProfile,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildProfileHeader(context),
                  const SizedBox(height: 24),
                  _buildDomainSection(),
                  const SizedBox(height: 24),
                  _buildStatsRow(),
                  const SizedBox(height: 32),
                  _buildMenuSection(context),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : "U",
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _currentName,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 24),
        ),
        Text(
          widget.userEmail,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: _navigateToEdit,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          ),
          child: const Text("Edit Profile", style: TextStyle(fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildDomainSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          const Text(
            "CURRENTLY STUDYING",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _currentDomain,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        BookmarkService.getSavedInternshipIds(),
        BookmarkService.getSavedHackathonTitles(),
      ]),
      builder: (context, snapshot) {
        final savedInternships = snapshot.data?[0].length ?? 0;
        final savedHackathons = snapshot.data?[1].length ?? 0;
        
        return Row(
          children: [
            Expanded(
              child: _buildSimpleStatCard(
                "Saved Internships", 
                savedInternships.toString(),
                Icons.work_outline_rounded,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSimpleStatCard(
                "Saved Hackathons", 
                savedHackathons.toString(),
                Icons.code_rounded,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSimpleStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 24,
      width: 1,
      color: AppColors.border,
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Column(
      children: [
        _buildMenuItem(Icons.history, "Application History"),
        _buildMenuItem(
          Icons.bookmark_border_rounded, 
          "Saved Opportunities",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SavedItemsScreen()),
            );
          },
        ),
        _buildMenuItem(Icons.help_outline, "Help & Support"),
        _buildMenuItem(
          Icons.logout,
          "Logout",
          color: AppColors.error,
          onTap: () async {
            await AuthService.logout();
            if (context.mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            }
          },
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {Color? color, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap ?? () {},
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      leading: Icon(icon, color: color ?? AppColors.textPrimary, size: 24),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
    );
  }
}
