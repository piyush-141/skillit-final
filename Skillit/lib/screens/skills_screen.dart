import 'package:flutter/material.dart';
import '../main.dart';
import 'roadmap_screen.dart';
import 'projects_screen.dart';

class SkillsScreen extends StatefulWidget {
  const SkillsScreen({super.key});

  @override
  State<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> {
  // true = Roadmaps, false = Projects
  bool _showRoadmaps = true;

  @override
  Widget build(BuildContext context) {
    // ✅ NO nested Scaffold — we are already inside MainLayout's Scaffold.
    // Using Column so the header + body stack correctly.
    return Column(
      children: [
        // ── Tab Header ─────────────────────────────────────────────────
        Container(
          color: AppColors.background,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Row(
            children: [
              _HeaderTab(
                label: 'Roadmaps',
                isActive: _showRoadmaps,
                onTap: () => setState(() => _showRoadmaps = true),
              ),
              const SizedBox(width: 8),
              Text(
                '/',
                style: TextStyle(
                  color: AppColors.border,
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(width: 8),
              _HeaderTab(
                label: 'Projects',
                isActive: !_showRoadmaps,
                onTap: () => setState(() => _showRoadmaps = false),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // ── Screen Body ────────────────────────────────────────────────
        // Expanded fills remaining space from the outer Scaffold body.
        Expanded(
          child: IndexedStack(
            index: _showRoadmaps ? 0 : 1,
            children: const [
              RoadmapScreen(hideAppBar: true),
              ProjectsScreen(hideAppBar: true),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _HeaderTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 200),
        style: TextStyle(
          fontFamily: 'Inter',
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          color: isActive ? AppColors.textPrimary : AppColors.textMuted,
          fontSize: 24,
        ),
        child: Text(label),
      ),
    );
  }
}
