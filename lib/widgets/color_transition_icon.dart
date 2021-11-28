import 'package:flutter/material.dart';

class ColorTransitionIcon extends AnimatedWidget {
  final IconData icon;
  final double size;
  final Animation<Color> animation;

  const ColorTransitionIcon({
    Key? key,
    required this.icon,
    required this.size,
    required this.animation,
  }) : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      color: animation.value,
      size: size,
    );
  }
}
