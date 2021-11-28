import 'package:flutter/material.dart';

class TransitionAppBar extends AnimatedWidget {
  final Widget title;
  final Widget actionIcon;
  final Widget? leadingAction;
  final Animation<Color?> animation;

  const TransitionAppBar({
    Key? key,
    required this.title,
    required this.actionIcon,
    this.leadingAction,
    required this.animation,
  }) : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: animation.value,
      leading: leadingAction,
      elevation: 0.0,
      bottomOpacity: 0.0,
      title: title,
      actions: [actionIcon],
    );
  }
}
