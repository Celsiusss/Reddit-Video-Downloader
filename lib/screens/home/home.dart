import 'package:flutter/material.dart';
import 'package:reddit_video_downloader/screens/home/download.dart';

class Home extends StatelessWidget {
  final TextEditingController urlController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 270,
      child: Download(
        urlController: urlController,
      )
    );
  }
}

class RedditResponse {
  final String videoUrl;

  RedditResponse({this.videoUrl});
}
