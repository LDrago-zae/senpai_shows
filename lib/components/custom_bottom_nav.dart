import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xff01968B),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(64),
            bottom: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.7),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Container(
          height: 65,
          margin: const EdgeInsets.all(1.5),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(64),
              bottom: Radius.circular(24),
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _navIcon('assets/icons/home.png', 0, constraints.maxWidth),
                  _navIcon('assets/icons/Bookmark.png', 1, constraints.maxWidth),
                  _navIcon('assets/icons/Download.png', 2, constraints.maxWidth),
                  _navIcon('assets/icons/user.png', 3, constraints.maxWidth),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _navIcon(String iconPath, int index, double maxWidth) {
    final isSelected = index == selectedIndex;
    final iconSize = maxWidth * 0.06; // Responsive icon size

    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(isSelected ? 12 : 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.tealAccent.withOpacity(0.2) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: SizedBox(
          width: iconSize,
          height: iconSize,
          child: Image.asset(
            iconPath,
            fit: BoxFit.contain,
            color: isSelected ? Colors.tealAccent : Colors.grey[400],
            errorBuilder: (context, error, stackTrace) {
              // Fallback to Material icons if assets not found
              final fallbackIcons = [
                Icons.home_max_outlined,
                Icons.bookmark_border,
                Icons.save_alt_outlined,
                Icons.person_outline,
              ];
              return Icon(
                fallbackIcons[index],
                size: iconSize,
                color: isSelected ? Colors.tealAccent : Colors.grey[400],
              );
            },
          ),
        ),
      ),
    );
  }
}