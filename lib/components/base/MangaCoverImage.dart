import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:maxga/model/manga/MangaSource.dart';

class MangaCoverImage extends StatelessWidget {
  final String url;
  final String tagPrefix;
  final BoxFit fit;
  final MangaSource source;

  const MangaCoverImage(
      {Key key,
      @required this.url,
      @required this.tagPrefix,
      this.fit = BoxFit.contain,
      @required this.source})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
        tag: '$tagPrefix$url',
        child: CachedNetworkImage(
            imageUrl: url,
            fit: fit,
            alignment: Alignment.topCenter,
            httpHeaders: {
              'referer': source?.headers != null ? source?.headers['referer'] : "",
            },
            placeholder: (context, url) => Align(
                  child: Container(
                    color: Color(0xffe9ecef),
                  ),
                )));
  }
}
