import 'package:dio/dio.dart';

import 'http/repo/MaxgaDataHttpRepo.dart';
import 'http/repo/dmzj/DmzjDataRepo.dart';
import 'http/repo/hanhan/HanhanDataRepo.dart';
import 'http/repo/manhuadui/ManhuaduiDataRepo.dart';
import 'http/repo/manhuagui/ManhuaguiDataRepo.dart';
import 'model/manga/MangaSource.dart';

class MangaRepoPool {
  Map<String, MaxgaDataHttpRepo> _map = {};
  Map<String, MangaSource> _mangaSourceMap = {};
  Dio _dio = Dio(
    BaseOptions(
      connectTimeout: 15000,
    )
  );


  void changeTimeoutLimit(int value) {
    this._dio = Dio(
        BaseOptions(
          connectTimeout: value,
        )
    );
  }

  List<MaxgaDataHttpRepo> get allDataRepo => _getAllRepo();
  List<MangaSource> get allDataSource => _getAllSource();

  Dio get dio => _dio;
  
  

  static MangaRepoPool _application = MangaRepoPool();
  static MangaRepoPool getInstance() => MangaRepoPool._application;

  
  

  MangaRepoPool() {
    print('pool init');
    final manhuaduiDataRepo = ManhuaduiDataRepo();
    final dmzjDataRepo = DmzjDataRepo();
    final hanhanDateRepo = HanhanDateRepo();
    final manhuaguiDateRepo = ManhuaguiDataRepo();
    registryRepo(dmzjDataRepo);
    registryRepo(hanhanDateRepo);
    registryRepo(manhuaduiDataRepo);
    registryRepo(manhuaguiDateRepo);
  }

  registryRepo(MaxgaDataHttpRepo repo) {
    _mangaSourceMap[repo.mangaSource.key] = repo.mangaSource;
    _map[repo.mangaSource.key] = repo;
  }

  MaxgaDataHttpRepo getRepo({MangaSource source, String key}) {
    if (key != null) {
      return _map[key];
    }

    if (source != null) {
      return _map[source.key];
    }

    throw Error();
  }


  List<MaxgaDataHttpRepo> _getAllRepo() {
    return _map.values.toList(growable: false);
  }

  List<MangaSource> _getAllSource() {
    return _mangaSourceMap.values.toList(growable: false);
  }

  MaxgaDataHttpRepo getDataRepo(String key) {
    return _map[key];
  }

  MangaSource getMangaSourceByKey(String key) {
    return _mangaSourceMap[key];
  }



  
  
}
