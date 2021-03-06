import 'package:flutter/material.dart';
import 'package:maxga/utils/date-utils.dart';
import 'package:maxga/components/skeleton.dart';
import 'package:maxga/model/manga/manga.dart';
import 'package:maxga/model/manga/simple-manga-info.dart';
import 'package:maxga/model/manga/manga-source.dart';

typedef CoverBuilder = Widget Function(BuildContext context);

class MangaListTile extends StatelessWidget {
  final GestureTapCallback onTap;
  final GestureLongPressCallback onLongPress;
  final Widget cover;
  final Widget title;
  final List<Widget> labels;
  final CoverBuilder coverBuilder;
  final Widget extra;

  MangaListTile(
      {this.onTap,

      this.cover,
      this.coverBuilder,
      @required this.title,
      this.labels,
      this.extra,
      this.onLongPress});

  final Color grayFontColor = Color(0xff9e9e9e);

  @override
  Widget build(BuildContext context) {
    final EdgeInsetsGeometry itemPadding = EdgeInsets.only(
      left: 0,
      right: 10,
      top: 10,
      bottom: 10,
    );
    final double itemHeight = 120;
    final double coverWidth = 100;
    final double coverHorizonPadding = (itemHeight - coverWidth) / 2;
    var edgeInsets = EdgeInsets.only(top: 0, left: 10);
    var bodyColumn = <Widget>[
      Padding(
        padding: EdgeInsets.only(bottom: 3),
        child: title,
      )
    ];
    if (labels != null && labels.length > 0) {
      bodyColumn.addAll(labels);
    }
    Widget body = Container(
      height: itemHeight,
      padding: itemPadding,
      decoration: BoxDecoration(),
      child: Row(
        children: <Widget>[
          Center(
            child: Container(
              height: itemHeight,
              width: coverWidth,
              padding: EdgeInsets.only(
                  left: coverHorizonPadding,
                  right: coverHorizonPadding,
                  top: 0,
                  bottom: 0),
              child: cover ?? coverBuilder(context),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: edgeInsets,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: bodyColumn,
              ),
            ),
          ),
          if (extra != null) extra
        ],
      ),
    );
    if (this.onTap != null) {
      body = Material(
        child: InkWell(
          onTap: this.onTap,
          onLongPress: this.onLongPress,
          child: body,
        ),
      );
    }
    return body;
  }

  Container buildMangaTitle(String title) {
    var titleTextStyle = TextStyle(fontSize: 16);
    return Container(
      padding: EdgeInsets.only(bottom: 5),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: titleTextStyle,
        ),
      ),
    );
  }
}
//
//class MangaLabel extends StatelessWidget {
//  final Widget text;
//  final IconData icon;
//
//  const MangaLabel({Key key, this.text, this.icon}) : super(key: key);
//
//  @override
//  Widget build(BuildContext context) {
//    var containerPadding = EdgeInsets.only(top: 5);
//    return Container(
//      padding: containerPadding,
//      child: Row(
//        children: <Widget>[
//          buildMangaInfoIcon(icon),
//          Text(' '),
//          Expanded(
//            child: text,
//          ),
//        ],
//      ),
//    );
//  }
//
//  Icon buildMangaInfoIcon(IconData icon) {
//    return Icon(
//      icon,
//      size: 16,
//      color: Color(0xffffac38),
//    );
//  }
//}

class MangaExtra extends StatelessWidget {
  final Widget body;
  final Widget bottom;

  const MangaExtra({Key key, @required this.body, this.bottom})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      child: Column(
        children: <Widget>[
          Expanded(
            child: Align(
              alignment: Alignment.topRight,
              child: body,
            ),
          ),
          bottom,
        ]..removeWhere((el) => el == null),
      ),
    );
  }
}

class MangaListTileLabel extends StatelessWidget {
  final String text;
  final Color textColor;

  const MangaListTileLabel({Key key, this.text, this.textColor = Colors.grey}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final extraTextStyle = TextStyle(fontSize: 13, color: textColor);
    return Padding(
        padding: EdgeInsets.only(top: 3),
        child:
        Text(text, softWrap: false,
            overflow: TextOverflow.fade,
            style: extraTextStyle),
    );
  }
}

class MangaListTileExtra extends StatelessWidget {
  final SimpleMangaInfo manga;
  final MangaSource source;
  final Color textColor;

  const MangaListTileExtra({
    Key key,
    this.manga,
    this.textColor = Colors.grey,
    @required this.source,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(color: textColor);
    var updateTime = '';
    if (manga?.lastUpdateChapter?.updateTime != null) {
      updateTime = DateUtils.formatTime(time: manga.lastUpdateChapter.updateTime, template: 'YYYY-MM-dd');
    }
    var bottomText;
    if (manga.lastUpdateChapter != null) {
      bottomText = Align(
          alignment: Alignment.centerRight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (manga.collected) Icon(Icons.favorite, color: textColor),
              ... [manga.lastUpdateChapter.title ?? '', updateTime]
                  .map((el) => Text(el,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle))
                  .toList(growable: false)
            ],
          ));
    }
    return MangaExtra(
      body: Text(
        source.name,
        textAlign: TextAlign.right,
        style: textStyle,
      ),
      bottom: bottomText,
    );
  }

}

class SkeletonCardSliverList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate(
          [SkeletonCardList()]
      ) ,
    );
  }
}

class SkeletonCardList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final itemCount = (MediaQuery.of(context).size.height - 100) / 120;
    return SkeletonList(
      length: itemCount.floor(),
      builder: (context, index) => SkeletonCard(),
    );
  }
}

class SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final EdgeInsetsGeometry cardPadding = EdgeInsets.only(
      left: 0,
      right: 0,
      top: 10,
      bottom: 10,
    );
    var edgeInsets = EdgeInsets.only(top: 0, left: 10);
    final double cardHeight = 120;
    final double coverWidth = 100;
    final double coverHorizonPadding = (cardHeight - coverWidth) / 2;
    return Container(
      height: cardHeight,
      padding: cardPadding,
      child: Row(
        children: <Widget>[
          Center(
            child: Container(
              height: cardHeight,
              width: coverWidth - coverHorizonPadding,
              decoration: SkeletonDecoration(),
              margin: EdgeInsets.only(
                  left: coverHorizonPadding,
                  right: coverHorizonPadding,
                  top: 0,
                  bottom: 0),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: edgeInsets,
              margin: EdgeInsets.only(
                  left: 0, right: coverHorizonPadding, top: 0, bottom: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 20, decoration: SkeletonDecoration()),
                  Container(
                      height: 20,
                      width: 100,
                      margin: EdgeInsets.only(top: 10),
                      decoration: SkeletonDecoration()),
                  Container(
                      height: 20,
                      width: 100,
                      margin: EdgeInsets.only(top: 10),
                      decoration: SkeletonDecoration())
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                left: 0, right: coverHorizonPadding, top: 0, bottom: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                    height: 20, width: 80, decoration: SkeletonDecoration()),
                Column(
                  children: <Widget>[
                    Container(
                        height: 15,
                        width: 80,
                        margin: EdgeInsets.only(bottom: 5),
                        decoration: SkeletonDecoration()),
                    Container(
                        height: 15,
                        width: 80,
                        decoration: SkeletonDecoration()),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
