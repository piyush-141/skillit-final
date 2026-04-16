import 'dart:ui';
import 'package:flutter/material.dart';
import '../main.dart';

class NavItem {
  final IconData icon;
  final String label;

  NavItem({required this.icon, required this.label});
}

class GlassmorphicBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const GlassmorphicBottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color selectedColor = AppColors.primary;
    final Color unselectedColor = const Color(0xFF8E8E93);

    final List<NavItem> items = [
      NavItem(icon: Icons.explore_outlined, label: 'Explore'),
      NavItem(icon: Icons.auto_awesome_outlined, label: 'Opportunities'),
      NavItem(icon: Icons.business_outlined, label: 'Companies'),
      NavItem(icon: Icons.bolt_outlined, label: 'Skills'),
      NavItem(icon: Icons.account_circle_outlined, label: 'Me'),
    ];

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 85,
          padding: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            border: const Border(
              top: BorderSide(color: Color(0xFFC6C6C8), width: 0.5),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(items.length, (index) {
              final isSelected = selectedIndex == index;
              
              return Expanded(
                child: GestureDetector(
                  onTap: () => onItemTapped(index),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        items[index].icon,
                        color: isSelected ? selectedColor : unselectedColor,
                        size: 26,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        items[index].label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? selectedColor : unselectedColor,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
