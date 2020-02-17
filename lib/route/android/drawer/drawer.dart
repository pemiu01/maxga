import 'package:flutter/material.dart';
import 'package:maxga/base/delay.dart';
import 'package:maxga/base/drawer/menu-item.dart';
import 'package:maxga/constant/DrawerValue.dart';
import 'package:maxga/provider/public/ThemeProvider.dart';
import 'package:maxga/provider/public/UserProvider.dart';
import 'package:provider/provider.dart';

import '../collection/collection-page.dart';
import '../source-viewer/source-viewer.dart';
import 'about/about-page.dart';
import 'history/history-page.dart';
import 'setting/setting-page.dart';

class MaxgaDrawer extends StatefulWidget {
  final MaxgaMenuItemType active;
  final VoidCallback loginCallback;

  const MaxgaDrawer({Key key, this.active, @required this.loginCallback})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => MaxgaDrawerState();
}

class MaxgaDrawerState extends State<MaxgaDrawer> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final list = DrawerMenuList.map((menuItem) => ListTile(
            title: Text(menuItem.title),
            leading: Icon(menuItem.icon),
            selected: menuItem.type == widget.active,
            onTap: () => _handleMenuItemChoose(menuItem.type)))
        .toList(growable: false);
    return Drawer(
      child: Column(
        children: <Widget>[
          Consumer<UserProvider>(
            builder:
                (BuildContext context, UserProvider value, Widget child) {
                  if (value.isLogin) {
                    return UserAccountsDrawerHeader(
                        accountName: Text(value.user.username)
                    );
                  } else {
                    return UserAccountsDrawerHeader(
                        accountName: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            AnimationDelay()
                                .then((v) => widget.loginCallback());
                          },
                          child: const Text('未登录'),
                        ));
                  }
                },
          ),
          MediaQuery.removePadding(
              context: context,
              child: Expanded(
                child: ListView(
                  children: list,
                ),
              )),
          ListTile(
            title: const Text('夜间模式'),
            trailing: Switch(
              value: theme.brightness == Brightness.dark,
              onChanged: (v) =>
                  Provider.of<ThemeProvider>(context).changeBrightness(),
            ),
          )
        ],
      ),
    );
  }

  _handleMenuItemChoose(MaxgaMenuItemType type) async {
    switch (type) {
      case MaxgaMenuItemType.collect:
        Navigator.pop(context);
        await AnimationDelay();
        Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  CollectionPage(),
            ));
        break;
      case MaxgaMenuItemType.mangaSourceViewer:
        Navigator.pop(context);
        await AnimationDelay();
        Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  SourceViewerPage(),
            ));
        break;
      case MaxgaMenuItemType.history:
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HistoryPage(),
            ));
        break;
      case MaxgaMenuItemType.setting:
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SettingPage(),
            ));
        break;
      case MaxgaMenuItemType.about:
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AboutPage(),
            ));
        break;
    }
  }
}
