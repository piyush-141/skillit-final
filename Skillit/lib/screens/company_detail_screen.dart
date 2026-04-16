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
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCompanyHeader(context),
              const SizedBox(height: 32),
              _buildInfoGrid(),
              const SizedBox(height: 32),
              _buildSectionTitle("About"),
              const SizedBox(height: 12),
              Text(
                company['description'] ?? "No description available.",
                style: const TextStyle(color: AppColors.textSecondary, height: 1.6, fontSize: 16),
              ),
              const SizedBox(height: 32),
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
    );
  }

  Widget _buildCompanyHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 72,
          height: 72,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Image.network(
            company['logo'] ?? '',
            fit: BoxFit.contain,
            errorBuilder: (c, e, s) => const Icon(Icons.business, size: 36, color: AppColors.primary),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                company['name'] ?? 'Unknown Company',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 24),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildInfoItem(Icons.location_on_rounded, "Headquarters", company['headquarters'])),
              Expanded(child: _buildInfoItem(Icons.people_rounded, "Employees", company['employeeCount'])),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildInfoItem(Icons.business_center_rounded, "Type", company['companyType'])),
              Expanded(child: _buildInfoItem(Icons.calendar_today_rounded, "Founded", company['foundedYear']?.toString())),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String? value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
              Text(
                value ?? "N/A",
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
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
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: -0.5),
    );
  }

  Widget _buildTags() {
    final dynamic tagsRaw = company['tags'];
    final List<dynamic> tags = (tagsRaw is List) ? tagsRaw : [];
    
    if (tags.isEmpty) return const Text("No tags listed", style: TextStyle(color: AppColors.textMuted));
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: tags.map((tag) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE3E3E8).withOpacity(0.4),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(tag.toString(), style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
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
        ),
        child: const Column(
          children: [
            Icon(Icons.info_outline, color: AppColors.textMuted),
            SizedBox(height: 8),
            Text("No active roles.", style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
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
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  intern['stipend'] ?? "Stipend N/A",
                  style: const TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMinInfo(Icons.location_on_rounded, intern['location']),
              const SizedBox(width: 20),
              _buildMinInfo(Icons.timer_rounded, intern['duration']),
            ],
          ),
          if (skills.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text("Skills Required", style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills.map((s) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
                child: Text(s.toString(), style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w500)),
              )).toList(),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _launchURL(intern['applicationLink']),
              child: const Text("Apply Now", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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
        const SizedBox(width: 6),
        Text(value ?? "N/A", style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
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
