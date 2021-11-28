import 'package:flutter/material.dart';

class ColorTransitionBox extends AnimatedWidget {
  final Animation<Color?> animation;
  final Widget child;

  const ColorTransitionBox({
    Key? key,
    required this.child,
    required this.animation,
  }) : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: animation.value,
      ),
      child: child,
    );
  }
}
