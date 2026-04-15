import 'package:flutter/material.dart';
import '../main.dart'; // for AppColors
import 'package:url_launcher/url_launcher.dart';

class CompanyDetailScreen extends StatelessWidget {
  final Map<String, dynamic> company;

  const CompanyDetailScreen({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCompanyHeader(),
                  const SizedBox(height: 24),
                  _buildInfoGrid(),
                  const SizedBox(height: 32),
                  _buildSectionTitle("About"),
                  const SizedBox(height: 12),
                  Text(
                    company['description'] ?? "No description available.",
                    style: const TextStyle(color: AppColors.textSecondary, height: 1.6, fontSize: 15),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Tags"),
                  const SizedBox(height: 12),
                  _buildTags(),
                  const SizedBox(height: 32),
                  _buildSectionTitle("Available Internships"),
                  const SizedBox(height: 16),
                  _buildInternshipList(),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: AppColors.surface,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary.withOpacity(0.1), Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyHeader() {
    return Row(
      children: [
        Container(
          width: 80,
          height: 80,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Image.network(
            company['logo'] ?? '',
            fit: BoxFit.contain,
            errorBuilder: (c, e, s) => const Icon(Icons.business, size: 40, color: AppColors.primary),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                company['name'] ?? 'Unknown Company',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                company['industry'] ?? 'Industry',
                style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoGrid() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        mainAxisSpacing: 16,
        children: [
          _buildInfoItem(Icons.location_on_outlined, "Headquarters", company['headquarters']),
          _buildInfoItem(Icons.people_outline, "Employees", company['employeeCount']),
          _buildInfoItem(Icons.business_center_outlined, "Type", company['companyType']),
          _buildInfoItem(Icons.event_available_outlined, "Founded", company['foundedYear']?.toString()),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String? value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
              Text(
                value ?? "N/A",
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  Widget _buildTags() {
    final dynamic tagsRaw = company['tags'];
    final List<dynamic> tags = (tagsRaw is List) ? tagsRaw : [];
    
    if (tags.isEmpty) return const Text("No tags listed", style: TextStyle(color: AppColors.textMuted));
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Text(tag.toString(), style: const TextStyle(color: AppColors.primary, fontSize: 11)),
      )).toList(),
    );
  }

  Widget _buildInternshipList() {
    final dynamic internsRaw = company['internships'];
    final List<dynamic> list = (internsRaw is List) ? internsRaw : [];

    if (list.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: const Column(
          children: [
            Icon(Icons.info_outline, color: AppColors.textMuted),
            SizedBox(height: 8),
            Text("No active internship openings.", style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) => _buildInternshipCard(list[index]),
    );
  }

  Widget _buildInternshipCard(dynamic intern) {
    final dynamic skillsRaw = intern['requiredSkills'];
    final List<dynamic> skills = (skillsRaw is List) ? skillsRaw : [];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  intern['roleTitle'] ?? "No Title",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                intern['stipend'] ?? "Stipend N/A",
                style: const TextStyle(color: AppColors.success, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMinInfo(Icons.location_on_outlined, intern['location']),
              const SizedBox(width: 16),
              _buildMinInfo(Icons.work_outline, intern['workMode']),
              const SizedBox(width: 16),
              _buildMinInfo(Icons.timer_outlined, intern['duration']),
            ],
          ),
          if (skills.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text("Key Skills:", style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: skills.map((s) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(6)),
                child: Text(s.toString(), style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
              )).toList(),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary.withOpacity(0.8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () => _launchURL(intern['applicationLink']),
              child: const Text("Apply Now", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinInfo(IconData icon, String? value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(value ?? "N/A", style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
      ],
    );
  }

  Future<void> _launchURL(String? url) async {
    if (url == null || url.isEmpty) return;
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
