import 'package:flutter/material.dart';

class Sun extends AnimatedWidget {
  final Animation<Color> animation;

  Sun({Key? key, required this.animation})
      : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    var maxWidth = MediaQuery.of(context).size.width;
    var margin = (maxWidth * .3) / 2;

    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: margin),
        constraints: BoxConstraints(
          maxWidth: maxWidth,
        ),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: animation.value,
        ),
      ),
    );
  }
}
