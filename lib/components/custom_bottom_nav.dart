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
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
        decoration: BoxDecoration(
          color: Color.fromARGB(18, 20, 25, 255),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(64),
            bottom: Radius.circular(24),
          ),
          border: Border.all(
            color: Colors.tealAccent.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              // blurRadius: 10,
              // offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Container(
          height: 65,
          margin: const EdgeInsets.all(1.5),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.2),
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
                  _navIcon('assets/icons/search.png', 1, constraints.maxWidth),
                  _navIcon(
                    'assets/icons/Bookmark.png',
                    2,
                    constraints.maxWidth,
                  ),
                  _navIcon(
                    'extension',
                    3,
                    constraints.maxWidth,
                  ), // Using indicator for extensions
                  _navIcon(
                    'assets/icons/Download.png',
                    4,
                    constraints.maxWidth,
                  ),
                  _navIcon('assets/icons/user.png', 5, constraints.maxWidth),
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
          color:
              isSelected
                  ? Colors.tealAccent.withValues(alpha: 0.2)
                  : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: SizedBox(
          width: iconSize,
          height: iconSize,
          child:
              iconPath.contains('/')
                  ? Image.asset(
                    iconPath,
                    fit: BoxFit.contain,
                    color: isSelected ? Colors.tealAccent : Colors.grey[400],
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        _getFallbackIcon(index),
                        size: iconSize,
                        color:
                            isSelected ? Colors.tealAccent : Colors.grey[400],
                      );
                    },
                  )
                  : Icon(
                    _getFallbackIcon(index),
                    size: iconSize,
                    color: isSelected ? Colors.tealAccent : Colors.grey[400],
                  ),
        ),
      ),
    );
  }

  IconData _getFallbackIcon(int index) {
    switch (index) {
      case 0:
        return Icons.home_max_outlined;
      case 1:
        return Icons.search;
      case 2:
        return Icons.bookmark_border;
      case 3:
        return Icons.extension_outlined;
      case 4:
        return Icons.save_alt_outlined;
      case 5:
        return Icons.person_outline;
      default:
        return Icons.error;
    }
  }
}
