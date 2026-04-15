import 'package:flutter/material.dart';
import '../main.dart';
import '../widgets/glassmorphic_bottom_nav.dart';
import 'home_screen.dart';
import 'opportunities_screen.dart';
import 'skills_screen.dart';
import 'companies_screen.dart';
import 'profile_screen.dart';

class MainLayout extends StatefulWidget {
  final String userName;
  final String userEmail;

  const MainLayout({Key? key, this.userName = 'User', this.userEmail = ''}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(userName: widget.userName, userEmail: widget.userEmail),
      const OpportunitiesScreen(),
      const CompaniesScreen(), // Reordered to match new bottom nav logic
      const SkillsScreen(), 
      ProfileScreen(userName: widget.userName, userEmail: widget.userEmail),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: GlassmorphicBottomNavBar(
        selectedIndex: _currentIndex,
        onItemTapped: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
