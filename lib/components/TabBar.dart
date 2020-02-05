import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ColoredTabBar extends Container implements PreferredSizeWidget {
  ColoredTabBar({this.color,@required this.tabBar});

  final Color color;
  final TabBar tabBar;

  @override
  Size get preferredSize => tabBar.preferredSize;

  @override
  Widget build(BuildContext context) => Container(
    color: Theme.of(context).scaffoldBackgroundColor,
    child: tabBar,
  );
}