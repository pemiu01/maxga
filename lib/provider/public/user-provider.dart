import 'dart:convert';

import 'package:maxga/components/button/manga-outline-button.dart';
import 'package:maxga/http/server/base/maxga-request-error.dart';
import 'package:maxga/http/server/base/maxga-server-response-status.dart';
import 'package:maxga/http/server/user-http.repo.dart';
import 'package:maxga/model/user/user.dart';
import 'package:maxga/service/local-storage.service.dart';
import 'package:maxga/service/maxga-server.service.dart';
import 'package:maxga/service/user.service.dart';

import '../base/base-provider.dart';
import 'collection-provider.dart';

class UserProvider  extends BaseProvider {
  User user;
  DateTime lastSyncTime;
  DateTime lastRemindSyncTime;
  int syncInterval;

  bool isFirstOpen = false;
  bool get isLogin => user != null;

  String get token => user?.token ?? null;

  static const String _userStorageKey = "\$userStorage";
  static const String _syncTimeKey = "\$syncTimeKey";
  static const String _firstOpenKey = "\$firstOpenKey";
  static const String _syncIntervalKey = "\$syncIntervalKey";
  static const String _lastRemindSyncKey = '\$lastRemindSyncKey';
  static UserProvider _instance;

  static UserProvider getInstance() {
    if (_instance == null) {
      _instance = UserProvider();
    }
    return _instance;
  }

  init() async {
    await this._loadLoginStatus();
    await this._loadSyncTime();
    await this._loadFirstOpenStatus();
    await this._loadSyncInterval();

    final lastRemindSyncTimeString = await LocalStorage.getString(_lastRemindSyncKey);
    if (lastRemindSyncTimeString != null) {
      this.lastRemindSyncTime = DateTime.parse(lastRemindSyncTimeString);
    } else {
      this.lastRemindSyncTime = null;
    }
    if (this.isFirstOpen) {
      await this._setFirstOpenTime();
    }
  }

  Future<void> setLastRemindSyncTime() {
    return LocalStorage.setString(_lastRemindSyncKey, DateTime.now().toIso8601String());
  }

  Future<void> delayOneDayRemindSync() async {
    var lastRemindSyncTime = this.lastRemindSyncTime ?? DateTime.now();
    await LocalStorage.setString(_lastRemindSyncKey, lastRemindSyncTime.add(Duration(days: 1)).toIso8601String());

    this.lastRemindSyncTime = lastRemindSyncTime;
  }

  Future<bool> isShouldSync() async {
    if (this.syncInterval == 0) {
      return false;
    }
    if(this.lastRemindSyncTime == null) {
      return true;
    }
    var diffDays = DateTime.now().difference(this.lastRemindSyncTime);
    if (diffDays.inDays - this.syncInterval > 1) {
      return true;
    } else  {
      return ( DateTime.now().day - this.lastRemindSyncTime.day -  this.syncInterval) >= 1;
    }
  }

  Future<void> _loadSyncTime() async {
    final syncTimeString = await LocalStorage.getString(_syncTimeKey);
    if (syncTimeString != null) {
      this.lastSyncTime = DateTime.parse(
          syncTimeString
      );
    }
  }

  Future<void> sync() async {
    final syncTime = DateTime.now();
    await MaxgaServerService.sync();
    await CollectionProvider.getInstance().init();
    await LocalStorage.setString(_syncTimeKey, syncTime.toIso8601String());
    this.lastSyncTime = syncTime;
    this.lastRemindSyncTime = syncTime;
    notifyListeners();
  }

  Future<void> setLoginStatus(User user) async {
    await LocalStorage.setString(_userStorageKey, json.encode(user));
    await setSyncInterval(7);
    isFirstOpen = false;
    this.user = user;
    notifyListeners();
  }
  Future<void> setSyncInterval(int interval) async {
    await LocalStorage.setNumber(_syncIntervalKey,  interval);
    this.syncInterval = interval;
    notifyListeners();
  }

  Future<void> logout([bool tokenInvalid = false]) async {
    await LocalStorage.clearItem(_userStorageKey);
    await LocalStorage.clearItem(_syncIntervalKey);
    await LocalStorage.clearItem(_syncTimeKey);
    await LocalStorage.clearItem(_lastRemindSyncKey);
    if (!tokenInvalid) {
      try {
        await UserService.logout(user.refreshToken);
      } catch(e) {
        print('清除 refresh token 失败');
      }
    }
    this.syncInterval = 0;
    this.lastRemindSyncTime = null;
    this.lastSyncTime = null;
    this.user = null;
    notifyListeners();
  }

  refreshToken() async {

    try {
      final token = await UserHttpRepo.refreshToken(this.user.refreshToken);
      var json = this.user.toJson();
      json['token'] = token;
      User user = User.fromJson(json);
      this.setLoginStatus(user);
    } on MaxgaRequestError catch(e) {
      switch(e. status) {
        case MaxgaServerResponseStatus.TOKEN_INVALID:
        case MaxgaServerResponseStatus.ACTIVE_TOKEN_OUT_OF_DATE:
          await this.logout(true);
          break;
        default:
      }
      rethrow;
    } catch(e) {
      rethrow;
    }
  }

  Future<void> _loadLoginStatus() async {
    var userStorageString = await LocalStorage.getString(_userStorageKey);
    if (userStorageString == null) {
      return null;
    }
    var user = User.fromJson(
        json.decode(userStorageString)
    );

    this.user = user;
    notifyListeners();
  }


  Future<void> _loadSyncInterval() async {
    this.syncInterval = (await LocalStorage.getNumber(_syncIntervalKey)) ?? 0;
  }

  Future<void> _loadFirstOpenStatus() async {
    String firstOpenTimeString = await LocalStorage.getString(_firstOpenKey);
    this.isFirstOpen = firstOpenTimeString == null;
  }

  Future<void> _setFirstOpenTime() async {
    await LocalStorage.setString(_firstOpenKey, DateTime.now().toIso8601String());
  }

  clearData() async {
    await this.logout();


    notifyListeners();
  }


}