import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'package:maxga/Utils/DateUtils.dart';
import 'package:maxga/http/repo/hanhan/crypto/HanhanCrypto.dart';
import 'package:maxga/model/Chapter.dart';
import 'package:maxga/model/Manga.dart';

class HanhanHtmlParser {
  static HanhanHtmlParser _instance;

  static HanhanHtmlParser getInstance() {
    if (_instance == null) {
      _instance = HanhanHtmlParser();
    }
    return _instance;
  }

  List<SimpleMangaInfo> getMangaListFromLatestUpdate(String html) {
    var document = parse(html);
    return document
        .querySelectorAll('.section1')
        .map((el) => _parseMangaList(el))
        .toList(growable: false);
  }

  Manga getMangaFromInfoPate(body) {
    final document = parse(body);
    final mangaInfoEl = document
        .querySelector('.main')
        .querySelector('.section3')
        .querySelector('.pic');
    final int mangaId =
        int.parse(document.querySelector('#hdID').attributes['value']);
    final coverImageUrl = mangaInfoEl.querySelector('img').attributes['src'];
    final mangaTextInfoEl = mangaInfoEl.querySelector('.con');
    final title = mangaTextInfoEl.children[0].text;
    final List<String> authors = mangaTextInfoEl.children[1].innerHtml
        .replaceFirst('作者：', '')
        .split(' ');
    final List<String> type = [
      mangaTextInfoEl.children[2].querySelector('a').text
    ];
    final chapterStatusList =
        mangaTextInfoEl.children[4].text.replaceFirst('状态：', '').split(' ');
    final time = DateUtils.convertTimeStringToTimestamp(
        mangaTextInfoEl.children[5].text.replaceFirst('更新日期：', ''),
        'yyyy-MM-dd');

    final intro = document
        .querySelector('#detail_block')
        .querySelector('.ilist')
        .querySelector('p')
        .text;
    var chapterIndex = 1000;
    final chapterList = document
        .querySelector('#list_block')
        .querySelectorAll('.list_href')
        .map((el) {
      Chapter chapter = Chapter();
      final chapterUrl = _replaceDomain(el.attributes['href']);
      final chapterId = chapterUrl.substring(
        chapterUrl.indexOf('_') + 1,
        chapterUrl.length - 1,
      );
      chapter.title = el.text;
      chapter.id = int.parse(chapterId);
      chapter.order = chapterIndex--;
      chapter.url = chapterUrl;
      chapter.comicId = mangaId;
      return chapter;
    }).toList(growable: false);

    Manga manga = Manga();
    manga.id = mangaId;
    manga.title = title;
    manga.status = chapterStatusList[0];
    manga.author = authors;
    manga.typeList = type;
    manga.coverImgUrl = coverImageUrl;
    manga.chapterList = chapterList;
    manga.introduce = intro;
    return manga;
  }
  List<String> getChapterImageList(String body, List<String> imageServerList) {
    final document = parse(body);
    final imageEncryptStringEl = document.head.querySelectorAll('script')[2];
    final imageEncryptStringElText = imageEncryptStringEl.text;
    final encryptString = imageEncryptStringElText.substring(
        imageEncryptStringElText.indexOf('sFiles="') + 'sFiles="'.length,
        imageEncryptStringElText.indexOf('";var sPath')
    );
    final sPath = imageEncryptStringElText.substring(
        imageEncryptStringElText.indexOf('sPath="') + 'sPath="'.length,
        imageEncryptStringElText.lastIndexOf('";')
    );
    return  HanhanCrypto.decryptImageList(encryptString).map((url) => '${imageServerList[int.parse(sPath) - 1]}${url.substring(1)}').toList(growable: false);
  }

  static SimpleMangaInfo _parseMangaList(Element el) {
    final SimpleMangaInfo manga = SimpleMangaInfo();

    final infoEl = el.querySelector('.pic');
    String infoUrl = _replaceDomain(infoEl.attributes['href']);
    final mangaId = infoUrl.substring(infoUrl.lastIndexOf('/') + 3);
    final coverImageUrl = infoEl.querySelector('img').attributes['src'];
    final mangaInfoEl = infoEl.querySelector('.con');
    final title = mangaInfoEl.children[0].innerHtml;
    final List<String> authors = mangaInfoEl.children[1].innerHtml.split(' ');
    final List<String> type = [mangaInfoEl.children[2].innerHtml];
    final time = DateUtils.convertTimeStringToTimestamp(
        mangaInfoEl.children[4].text, 'yyyy-MM-dd hh:mm');
    final lastChapterTitle = el.querySelector('.tool').children[1].innerHtml;

    final lastChapter = Chapter();
    lastChapter.title = lastChapterTitle;
    lastChapter.updateTime = time;

    manga.status = '';
    manga.author = authors;
    manga.infoUrl = infoUrl + '/';
    manga.title = title;
    manga.coverImgUrl = coverImageUrl;
    manga.id = int.parse(mangaId);
    manga.typeList = type;
    manga.lastUpdateChapter = lastChapter;

    return manga;
  }


  static String _replaceDomain(String url ) {
    final domainReg = RegExp(
        'ddmm\.cc|hhssaa.com|hhaass\.com|hhaazz\.com|hhzzee\.com|bbssoo\.com|aaooss\.com');
    final infoUrl = url
      .replaceFirst(domainReg, 'hanhan.xiaopo.moe');
    return infoUrl;
  }

}
