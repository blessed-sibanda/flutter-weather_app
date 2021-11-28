import 'package:flutter/material.dart';

class ColorTransitionText extends AnimatedWidget {
  final String text;
  final TextStyle? style;
  final Animation<Color?> animation;

  const ColorTransitionText({
    Key? key,
    required this.text,
    this.style,
    required this.animation,
  }) : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style?.copyWith(color: animation.value),
    );
  }
}
