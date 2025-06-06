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
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.black12.withValues(alpha: .1),
            width: 0.5,
          ),
        ),
        gradient: LinearGradient(
          colors: [
            Colors.black12.withValues(alpha: .3),
            Colors.black12.withValues(alpha: .1),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(64), bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navIcon(Icons.home, 0),
          _navIcon(Icons.bookmark_border, 1),
          _navIcon(Icons.share, 2),
          _navIcon(Icons.person_outline, 3),
        ],
      ),
    );
  }

  Widget _navIcon(IconData icon, int index) {
    final isSelected = index == selectedIndex;
    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: Icon(
        icon,
        size: 26,
        color: isSelected ? Colors.tealAccent : Colors.grey,
      ),
    );
  }
}
