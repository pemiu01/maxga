
import 'package:flutter/material.dart';

typedef OnCollectCallBack = void Function();
typedef OnResumeCallBack = void Function();

class MangaInfoBottomBar extends StatelessWidget {
  final OnCollectCallBack onCollect;
  final OnResumeCallBack onResume;
  final bool readed;
  final bool collected;

  const MangaInfoBottomBar({Key key, this.onCollect, this.onResume, this.readed = false, this.collected = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconActiveColor = theme.brightness == Brightness.dark ? Colors.orange : Colors.orangeAccent;
    return Container(
      decoration: BoxDecoration(
          border: Border(top: BorderSide(width: 1, color: theme.dividerColor))),
      padding: EdgeInsets.only(left: 10, top: 2, bottom: 2, right: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          FlatButton.icon(
              onPressed: onCollect,
              icon: Icon(Icons.star_border, color: collected ? iconActiveColor : theme.hintColor,),
              label: const Text('收藏')),
          FlatButton(
            onPressed: onResume,
            textColor: Colors.white,
            color: theme.accentColor,
            shape:  RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(25.0)
            ),
            child: readed ? Text('  继续阅读  ') : Text('  开始阅读  '),
          )
        ],
      ),
    );
  }

}