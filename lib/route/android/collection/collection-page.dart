import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:maxga/base/delay.dart';
import 'package:maxga/base/drawer/drawer-menu-item.dart';
import 'package:maxga/components/base/confirm-exit-scope.dart';
import 'package:maxga/components/base/manga-cover-image.dart';
import 'package:maxga/components/button/float-loading-button.dart';
import 'package:maxga/components/button/search-button.dart';
import 'package:maxga/components/dialog/circular-progress-dialog.dart';
import 'package:maxga/components/dialog/dialog.dart';
import 'package:maxga/components/manga-grid-item.dart';
import 'package:maxga/manga-repo-pool.dart';
import 'package:maxga/model/maxga/collected-manga.dart';
import 'package:maxga/model/maxga/maxga-release-info.dart';
import 'package:maxga/provider/public/collection-provider.dart';
import 'package:maxga/provider/public/user-provider.dart';
import 'package:maxga/route/android/collection/components/banner.dart';
import 'package:maxga/route/android/user/auth-page.dart';
import 'package:maxga/route/android/user/base/login-page-result.dart';
import 'package:maxga/service/update-service.dart';
import 'package:provider/provider.dart';

import '../drawer/drawer.dart';
import '../mangaInfo/manga-info-page.dart';
import 'components/collect-empty-tip-body.dart';

class CollectionPage extends StatefulWidget {
  final String name = 'index_page';

  @override
  State<StatefulWidget> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  MaxgaReleaseInfo nextVersion;

  ScrollController controller;
  bool showFab = true;

  bool isShowUpdateBanner = false;
  bool isShowLoginBanner = false;
  bool isShowSyncBanner = false;

  @override
  void initState() {
    super.initState();
    controller = ScrollController();
    double scrollUpDistance = 0;
    double scrollDownDistance = 0;
    double lastOffset = 0;
    controller.addListener(() {
      if (lastOffset > controller.offset) {
        scrollUpDistance += lastOffset - controller.offset;
        scrollDownDistance = 0;
        if (scrollUpDistance > 50) {
          setState(() {
            showFab = true;
          });
        }
      } else {
        scrollDownDistance += controller.offset - lastOffset;
        scrollUpDistance = 0;
        if (scrollDownDistance > 50) {
          setState(() {
            showFab = false;
          });
        }
      }
      lastOffset = controller.offset;
    });
    if (Platform.isAndroid) {
      UpdateService.isTodayChecked().then((v) {
        if (!v) {
          this.checkUpdate();
        }
      });
    }
    if (UserProvider.getInstance().isFirstOpen) {
      this.isShowLoginBanner = true;
    }
    UserProvider.getInstance().isShouldSync().then((v) async {
      if (v) {
        await UserProvider.getInstance().setLastRemindSyncTime();
        setState(() {
          this.isShowSyncBanner = v;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    CollectionProvider provider = Provider.of<CollectionProvider>(context);
    return Scaffold(
      drawer: MaxgaDrawer(
        active: MaxgaMenuItemType.collect,
        loginCallback: () => toLogin(),
      ),
      appBar: AppBar(
        title: Text('收藏'),
        elevation: 1,
        actions: <Widget>[MaxgaSearchButton()],
      ),
      key: scaffoldKey,
      body: ConfirmExitScope(
        child: buildBody(provider),
      ),
      floatingActionButton: provider.hasCollectedManga && showFab
          ? FloatingRefreshButton()
          : null,
    );
  }

  void hiddenSnack() {
    scaffoldKey.currentState.hideCurrentSnackBar();
  }

  checkUpdate() async {
    try {
      final result = await UpdateService.checkUpdateStatus();
      if (result.status == MaxgaUpdateStatus.mustUpdate) {
        showDialog(
            context: context,
            child: ForceUpdateDialog(url: result.releaseInfo.url));
      } else if (result.status == MaxgaUpdateStatus.hasUpdate) {
        isShowUpdateBanner = true;
      }
    } catch (e) {
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

  Widget buildBody(CollectionProvider provider) {
    if (!provider.loadOver) {
      return Column(
        children: <Widget>[
          ...buildBannerList(),
          Container(),
        ],
      );
    } else if (provider.loadOver && provider.isEmpty) {
      return Column(
        children: <Widget>[
          ...buildBannerList(),
          Expanded(
            child: CollectEmptyTipBody(),
          ),
        ],
      );
    } else {
      double screenWith = MediaQuery.of(context).size.width;
      double itemMaxWidth = 140;
      double radio = screenWith / itemMaxWidth;
      final double itemWidth =
          radio.floor() > 3 ? itemMaxWidth : screenWith / 3;
      final double height = (itemWidth + 20) / 13 * 15 + 40;
      var gridView = SliverGrid.count(
        crossAxisCount: radio.floor() > 3 ? radio.floor() : 3,
        childAspectRatio: itemWidth / height,
        children: provider.collectionMangaList
            .map(
              (el) => Material(
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

      return CustomScrollView(
        slivers: <Widget>[
          ...buildBannerList()
              .map((banner) => SliverToBoxAdapter(
                    child: banner,
                  ))
              .toList(),
          gridView,
        ],
      );
    }
  }

  List<Widget> buildBannerList() {
    return [
      if (isShowUpdateBanner)
        UpdateBanner(
          onDismiss: () {
            UpdateService.ignoreUpdate(nextVersion);
            setState(() {
              isShowUpdateBanner = false;
            });
          },
          onUpdate: () {
            openUpdateDialog(nextVersion);
            setState(() {
              isShowUpdateBanner = false;
            });
          },
        ),
      if (isShowLoginBanner)
        LoginBanner(
          onSuccess: () async {
            await AnimationDelay();
            toLogin();
          },
          onIgnore: () async {
            await AnimationDelay();
            setState(() {
              isShowLoginBanner = false;
            });
          },
        ),
      if (isShowSyncBanner)
        SyncBanner(
          onSuccess: () async {
            showDialog(
                context: context,
                child: CircularProgressDialog(
                  forbidCancel: true,
                  tip: "同步中",
                ));
            try {
              await Future.wait(
                  [UserProvider.getInstance().sync(), AnimationDelay()]);
              setState(() {
                isShowSyncBanner = false;
              });
            } catch (e) {
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text("同步出现问题"),
              ));
            } finally {
              Navigator.of(context).pop();
            }
          },
          onIgnore: () async {
            UserProvider.getInstance().delayOneDayRemindSync();
            setState(() {
              isShowSyncBanner = false;
            });
          },
        ),
    ];
  }

  startRead(CollectedManga item) async {
    if (item.hasUpdate) {
      LongAnimationDelay().then(
              (v) => Provider.of<CollectionProvider>(context).setMangaNoUpdate(item));
    }
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return MangaInfoPage(
        infoUrl: item.infoUrl,
        sourceKey: item.sourceKey,
        title: item.title,
        coverImageBuilder: (context) => MangaCoverImage(
          source:
              MangaRepoPool.getInstance().getMangaSourceByKey(item.sourceKey),
          url: item.coverImgUrl,
          tagPrefix: widget.name,
          fit: BoxFit.cover,
        ),
      );
    }));
  }

  void toLogin() async {
    AuthPageResult result = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => AuthPage()));
    if (result != null && result.success) {
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('登录成功'),
      ));
      setState(() {
        this.isShowLoginBanner = false;
        this.isShowSyncBanner = true;
      });
    }
  }
}
