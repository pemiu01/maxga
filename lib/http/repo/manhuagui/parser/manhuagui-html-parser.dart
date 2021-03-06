import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:maxga/utils/date-utils.dart';
import 'package:maxga/http/repo/manhuagui/constants/manhuagui-manga-source.dart';
import 'package:maxga/model/manga/chapter.dart';
import 'package:maxga/model/manga/simple-manga-info.dart';
import 'package:maxga/model/manga/manga.dart';

class ManhuaguiHtmlParser {
  static ManhuaguiHtmlParser _instance;

  static ManhuaguiHtmlParser getInstance() {
    if (_instance == null) {
      _instance = ManhuaguiHtmlParser();
    }
    return _instance;
  }

  List<SimpleMangaInfo> getSimpleMangaInfoFromSearch(String body) {
    final document = parseFragment(body);
    final mangaListEl =
        document.querySelector('#detail').querySelectorAll('li');
    return getSimpleMangaInfoFromLiList(mangaListEl);
  }

  List<SimpleMangaInfo> getSimpleMangaInfoListFromUpdatePage(String body) {
    var document = parseFragment(body, container: 'ul');

    return getSimpleMangaInfoFromLiList(document.querySelectorAll('li'));
  }

  List<SimpleMangaInfo> getSimpleMangaInfoFromLiList(
      List<Element> mangaElList) {
    return mangaElList.map((el) {
      final infoEl = el.querySelector('a');
      final url = infoEl.attributes['href'];
      final id = url.substring(
        url.indexOf('ic/') + 3,
        url.lastIndexOf('/'),
      );
      final coverImageUrl = infoEl.querySelector('img').attributes['data-src'];
      final title = infoEl.children[1].innerHtml;
      final authors =
          infoEl.children[2].querySelector('dd').innerHtml.split(',');

      final typeList =
          infoEl.children[3].querySelector('dd').innerHtml.split(',');
      final lastUpdateChapterTitle =
          infoEl.children[4].querySelector('dd').innerHtml;

      final lastUpdateTime = DateUtils.convertTimeStringToDateTime(
          infoEl.children[5].querySelector('dd').innerHtml, 'YYYY-MM-dd');

      Chapter lastUpdateChapter = Chapter();
      lastUpdateChapter.updateTime = lastUpdateTime;
      lastUpdateChapter.title = lastUpdateChapterTitle;

      return SimpleMangaInfo.fromMangaRepo(
        sourceKey: ManhuaguiMangaSourceKey,
        id: id,
        infoUrl: url,
        coverImgUrl: coverImageUrl,
        title: title,
        authors: authors,
        typeList: typeList,
        lastUpdateChapter: lastUpdateChapter,
      );
    }).toList(growable: false);
  }

  Manga getMangaInfo(String body) {
    final document = parse(body);
    final title = document.querySelector('.main-bar').children[0].innerHtml;
    final bookDetail = document.querySelector('.book-detail');
    final contList = bookDetail.querySelector('.cont-list');
    final coverImageUrl =
        contList.querySelector('.thumb').querySelector('img').attributes['src'];
    final mangaStatus =
        contList.querySelector('.thumb').querySelector('i').innerHtml;

    final lastUpdateChapterTitle =
        contList.children[1].querySelector('dd').innerHtml;

    final lastUpdateTime = DateUtils.convertTimeStringToDateTime(
        contList.children[2].querySelector('dd').innerHtml, 'YYYY-MM-dd');

    final authors = contList.children[3].querySelector('dd').text.split(',');
    final typeList = contList.children[4].querySelector('dd').text.split(',');
    final bookIntro = document.querySelector('.book-intro').children[0].text;

    var index = 10000;
    final List<Chapter> chapterList = document
        .querySelector('.chapter-list')
        .querySelectorAll('li')
        .map((el) => _getChapter(el, index--))
        .toList(growable: false);

    var lastUpdateChapter = chapterList.first.copyWith(updateTime: lastUpdateTime);
    return Manga.fromMangaInfoRequest(
        authors: authors,
        types: typeList,
        introduce: bookIntro,
        title: title,
        id: null,
        infoUrl: null,
        status: mangaStatus,
        coverImgUrl: coverImageUrl,
        sourceKey: ManhuaguiMangaSource.key,
        chapterList: chapterList,
        latestChapter: lastUpdateChapter);
  }

  Chapter _getChapter(Element el, int index) {
    Chapter chapter = Chapter();
    final chapterEl = el.querySelector('a');
    final url = chapterEl.attributes['href'];
    final int chapterId = int.parse(
        (url.substring(url.lastIndexOf('/') + 1, url.lastIndexOf('.'))));
    final text = chapterEl.children[0].innerHtml;
    chapter.title = text;
    chapter.url = url;
    chapter.order = index;
    chapter.id = chapterId;
    return chapter;
  }

  String getEncryptImageString(String body) {
    final document = parse(body);
    return document.body.children[10].innerHtml;
  }
}
