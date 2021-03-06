

import 'package:flutter/material.dart';
import 'package:maxga/base/drawer/drawer-menu-item.dart';
import 'package:maxga/constant/icons/antd-icon.dart';

const List<DrawerMenuItem> DrawerMenuList = [
  const DrawerMenuItem('收藏', Icons.collections_bookmark, MaxgaMenuItemType.collect),
  const DrawerMenuItem('图源', Icons.view_list, MaxgaMenuItemType.mangaSourceViewer),
  const DrawerMenuItem('隐藏漫画', AntdIcons.book_fill, MaxgaMenuItemType.hiddenMangaViewer),
  const DrawerMenuItem('历史记录', Icons.history, MaxgaMenuItemType.history),
  const DrawerMenuItem('设置', Icons.settings, MaxgaMenuItemType.setting),
  const DrawerMenuItem('关于', Icons.info_outline, MaxgaMenuItemType.about),
];