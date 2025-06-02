// lib/widgets/slide_animation.dart
import 'package:flutter/material.dart';

class SlideAnimation extends PageRouteBuilder {
  final Widget page;
  final AxisDirection direction;

  SlideAnimation({
    required this.page,
    this.direction = AxisDirection.right,
  }) : super(
    transitionDuration: const Duration(milliseconds: 800),
    reverseTransitionDuration: const Duration(milliseconds: 500),
    pageBuilder: (context, animation, secondaryAnimation) => page,
  );

  @override
  Widget buildTransitions(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: _getBeginOffset(),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutQuart,
      )),
      child: child,
    );
  }

  Offset _getBeginOffset() {
    switch (direction) {
      case AxisDirection.up:
        return const Offset(0, 1);
      case AxisDirection.down:
        return const Offset(0, -1);
      case AxisDirection.left:
        return const Offset(1, 0);
      case AxisDirection.right:
        return const Offset(-1, 0);
    }
  }
}