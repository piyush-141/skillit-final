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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            // Roadmaps Header
            GestureDetector(
              onTap: () {
                setState(() {
                  _showRoadmaps = true;
                });
              },
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      fontWeight: _showRoadmaps ? FontWeight.w700 : FontWeight.w500,
                      color: _showRoadmaps ? AppColors.textPrimary : AppColors.textMuted,
                      fontSize: 24,
                    ),
                child: const Text('Roadmaps'),
              ),
            ),
            const SizedBox(width: 16),
            // Divider / separator
            Text(
              '/',
              style: TextStyle(
                color: AppColors.border,
                fontSize: 24,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(width: 16),
            // Projects Header
            GestureDetector(
              onTap: () {
                setState(() {
                  _showRoadmaps = false;
                });
              },
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      fontWeight: !_showRoadmaps ? FontWeight.w700 : FontWeight.w500,
                      color: !_showRoadmaps ? AppColors.textPrimary : AppColors.textMuted,
                      fontSize: 24,
                    ),
                child: const Text('Projects'),
              ),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _showRoadmaps ? 0 : 1,
        children: [
          RoadmapScreen(hideAppBar: true),
          ProjectsScreen(hideAppBar: true),
        ],
      ),
    );
  }
}
