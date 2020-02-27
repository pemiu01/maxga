import 'package:maxga/http/repo/manhuadui/parser/manhuadui-html-parser.dart';

import 'package:maxga/http/repo/utils/manga-http-utils.dart';
import 'package:maxga/model/manga/manga.dart';
import 'package:maxga/model/manga/manga-source.dart';

import '../maxga-data-http-repo.dart';
import 'constants/manhuadui-manga-source.dart';




class ManhuaduiDataRepo extends MaxgaDataHttpRepo {
  MangaSource _source = ManhuaduiMangaSource;
  ManhuaduiHtmlParser parser = ManhuaduiHtmlParser.getInstance();
  MangaHttpUtils _httpUtils = MangaHttpUtils(ManhuaduiMangaSource);

  @override
  Future<List<String>> getSuggestion(String words) {
    // TODO: implement getSuggestion
    return null;
  }

  @override
  Future<List<String>> getChapterImageList(String url) async {
    return _httpUtils.requestMangaSourceApi<List<String>>('${_source.apiDomain}$url',
        parser: (res) => parser.getMangaImageListFromMangaPage(res.data));
  }

  @override
  Future<List<SimpleMangaInfo>> getLatestUpdate(int page) async {
    return _httpUtils.requestMangaSourceApi<List<SimpleMangaInfo>>(
        '${_source.apiDomain}/update/?page=${page + 1}',
        parser: (res) => parser.getMangaListFromLatestUpdate(res.data)
          ..forEach((manga) => manga.sourceKey = _source.key));
  }

  @override
  Future<Manga> getMangaInfo(String url) async {
    return _httpUtils.requestMangaSourceApi<Manga>(url,
        parser: (res) => parser.getMangaFromMangaInfoPage(res.data)
          ..infoUrl = url);
  }

  @override
  Future<List<SimpleMangaInfo>> getSearchManga(String keywords) async {
    return _httpUtils.requestMangaSourceApi<List<SimpleMangaInfo>>(
        '${_source.apiDomain}/search/?keywords=$keywords',
        parser: (res) => parser.getMangaListFromSearch(res.data)
          ..forEach((item) => item.sourceKey = _source.key));
  }

  @override
  MangaSource get mangaSource => _source;

  @override
  Future<List<SimpleMangaInfo>> getRankedManga(int page) async {
    if (page >= 1) {
      return [];
    }

    return _httpUtils.requestMangaSourceApi<List<SimpleMangaInfo>>(
        'https://m.manhuadui.com/rank/click/',
        parser: (res) => parser.getMangaListFromRank(res.data)
          ..forEach((el) => el.sourceKey = _source.key));
  }
  @override
  Future<String> generateShareLink(Manga manga) {
    return Future.value(manga.infoUrl);
  }
}