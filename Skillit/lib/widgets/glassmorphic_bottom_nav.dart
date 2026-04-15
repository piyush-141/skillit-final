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
    final Color unselectedColor = AppColors.textSecondary;

    final List<NavItem> items = [
      NavItem(icon: Icons.search, label: 'Explore'),
      NavItem(icon: Icons.favorite_border, label: 'Wishlist'),
      NavItem(icon: Icons.business_outlined, label: 'Companies'),
      NavItem(icon: Icons.mail_outline, label: 'Inbox'),
      NavItem(icon: Icons.person_outline, label: 'Profile'),
    ];

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.border.withOpacity(0.5), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(items.length, (index) {
          final isSelected = selectedIndex == index;
          
          return Expanded(
            child: InkWell(
              onTap: () => onItemTapped(index),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    items[index].icon,
                    color: isSelected ? selectedColor : unselectedColor,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    items[index].label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? selectedColor : unselectedColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
