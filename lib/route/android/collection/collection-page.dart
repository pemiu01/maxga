import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:maxga/base/drawer/menu-item.dart';
import 'package:maxga/components/MangaCoverImage.dart';
import 'package:maxga/components/MangaGridItem.dart';
import 'package:maxga/components/MaxgaButton.dart';
import 'package:maxga/components/base/WillExitScope.dart';
import 'package:maxga/components/dialog.dart';
import 'package:maxga/model/manga/Manga.dart';
import 'package:maxga/model/maxga/MaxgaReleaseInfo.dart';
import 'package:maxga/provider/public/CollectionProvider.dart';
import 'package:maxga/route/error-page/ErrorPage.dart';
import 'package:maxga/service/UpdateService.dart';
import 'package:provider/provider.dart';
import 'package:maxga/MangaRepoPool.dart';

import '../mangaInfo/MangaInfoPage.dart';
import '../drawer/drawer.dart';
import '../search/search-page.dart';

class CollectionPage extends StatefulWidget {
  final String name = 'index_page';

  @override
  State<StatefulWidget> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      UpdateService.isTodayChecked().then((v) {
        if (!v) {
          this.checkUpdate();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MaxgaDrawer(
        active: MaxgaMenuItemType.collect,
      ),
      appBar: AppBar(
        title: const Text('收藏'),
        actions: <Widget>[
          MaxgaSearchButton(),
//            MaxgaTestButton(),
        ],
      ),
      key: scaffoldKey,
      body: WillExitScope(
        child: buildBody(),
      ),
    );
  }



  toSearch() {
    Navigator.push(context, MaterialPageRoute<void>(builder: (context) {
      return SearchPage();
    }));
  }


  void hiddenSnack() {
    scaffoldKey.currentState.hideCurrentSnackBar();
  }

  checkUpdate() async {
    try {
      final nextVersion = await UpdateService.checkUpdateStatus();
      if (nextVersion != null) {
        final buttonPadding = const EdgeInsets.fromLTRB(15, 5, 15, 5);
        scaffoldKey.currentState.showSnackBar(SnackBar(
            duration: Duration(seconds: 3),
            content: GestureDetector(
              child: Padding(
                padding: buttonPadding,
                child: Text('有新版本更新, 点击查看'),
              ),
              onTap: () {
                hiddenSnack();
                openUpdateDialog(nextVersion);
              },
            ),
            action: SnackBarAction(
              label: '忽略',
              textColor: Colors.greenAccent,
              onPressed: () {
                openUpdateDialog(nextVersion);
              },
            )));
      }
    } catch(e) {
      debugPrint('检查更新失败');
    }
  }

  openUpdateDialog(MaxgaReleaseInfo nextVersion) {
    showDialog(
        context: context,
        builder: (context) => UpdateDialog(
          text: nextVersion.description,
          url: nextVersion.url,
          onIgnore: () => UpdateService.ignoreUpdate(nextVersion),
        ));
  }


  Widget buildBody() {
    CollectionProvider provider = Provider.of<CollectionProvider>(context);
    if (!provider.loadOver) {
      return Container();
    } else if (provider.loadOver && provider.isEmpty) {
      return ErrorPage('您没有收藏的漫画');
    } else {
      double screenWith = MediaQuery
          .of(context)
          .size
          .width;
      double itemMaxWidth = 140;
      double radio = screenWith / itemMaxWidth;
      final double itemWidth = radio.floor() > 3 ? itemMaxWidth : screenWith /
          3;
      final double height = (itemWidth + 20) / 13 * 15 + 40;
      var gridView = GridView.count(
        crossAxisCount: radio.floor() > 3 ? radio.floor() : 3,
        childAspectRatio: itemWidth / height,
        children: provider.collectionMangaList
            .map(
              (el) =>
              Material(
                  color: Colors.transparent,
                  child: InkWell(
                      onTap: () => this.startRead(el),
                      child: MangaGridItem(
                        manga: el,
                        tagPrefix: widget.name,
                        source: MangaRepoPool.getInstance()
                            .getMangaSourceByKey(el.sourceKey),
                      ))),
        )
            .toList(growable: false),
      );
      return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: RefreshIndicator(
            onRefresh: () => this.updateCollectedManga(),
            child: gridView,
          ));
    }
  }



  startRead(Manga item) async {
    Provider.of<CollectionProvider>(context).setMangaNoUpdate(item);
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return MangaInfoPage(
          infoUrl: item.infoUrl,
          sourceKey: item.sourceKey,
          coverImageBuilder: (context) =>
              MangaCoverImage(
                source: MangaRepoPool.getInstance()
                    .getMangaSourceByKey(item.sourceKey),
                url: item.coverImgUrl,
                tagPrefix: widget.name,
                fit: BoxFit.cover,
              ));
    }));
  }


  updateCollectedManga() {
    final c = new Completer<bool>();
    updateCollectionAction().then((v) {
      if (!c.isCompleted) {
        c.complete(true);
      }
    });
    Future.delayed(Duration(seconds: 3)).then((v) {
      if (!c.isCompleted) {
        c.complete(true);
      }
    });
    return c.future;
  }

  Future updateCollectionAction() async {
    final CollectionProvider collectionState = Provider.of<CollectionProvider>(
        context);
    final result = await collectionState.checkAndUpdateCollectManga();
    if (result != null) {
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('收藏漫画已经更新结束'),
      ));
    }
  }

}