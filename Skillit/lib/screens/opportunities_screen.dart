import 'package:flutter/material.dart';
import '../main.dart';
import 'internship_screen.dart';
import 'hackathon_screen.dart';

class OpportunitiesScreen extends StatefulWidget {
  const OpportunitiesScreen({super.key});

  @override
  State<OpportunitiesScreen> createState() => _OpportunitiesScreenState();
}

class _OpportunitiesScreenState extends State<OpportunitiesScreen> {
  // true = Internships, false = Hackathons
  bool _showInternships = true;

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
            // Internships Header
            GestureDetector(
              onTap: () {
                setState(() {
                  _showInternships = true;
                });
              },
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      fontWeight: _showInternships ? FontWeight.w700 : FontWeight.w500,
                      color: _showInternships ? AppColors.textPrimary : AppColors.textMuted,
                      fontSize: 24,
                    ),
                child: const Text('Internships'),
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
            // Hackathons Header
            GestureDetector(
              onTap: () {
                setState(() {
                  _showInternships = false;
                });
              },
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      fontWeight: !_showInternships ? FontWeight.w700 : FontWeight.w500,
                      color: !_showInternships ? AppColors.textPrimary : AppColors.textMuted,
                      fontSize: 24,
                    ),
                child: const Text('Hackathons'),
              ),
            ),
          ],
        ),
      ),
      // We wrap the child screens to hide their internal AppBars
      body: IndexedStack(
        index: _showInternships ? 0 : 1,
        children: const [
          InternshipScreen(hideAppBar: true),
          HackathonScreen(hideAppBar: true),
        ],
      ),
    );
  }
}
