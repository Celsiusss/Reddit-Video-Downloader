import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:reddit_video_downloader/actions/actions.dart';
import 'package:reddit_video_downloader/screens/home/download.dart';
import 'package:reddit_video_downloader/screens/videos/videos.dart';

import 'models/app_state.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController urlController = new TextEditingController();
  List<Widget> _widgets = <Widget>[];

  _HomeState() {
    _widgets = [
      Download(
        urlController: urlController,
      ),
      Videos()
    ];
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, int>(
      converter: (store) => store.state.tabNumber,
      builder: (context, tabNumber) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Video Downloader for Reddit'),
          backgroundColor: Colors.white,
          textTheme: TextTheme(
            title: TextStyle(color: Colors.black),
          ),
          elevation: 0,
        ),
        body: _widgets.elementAt(tabNumber),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: tabNumber,
          onTap: (number) => StoreProvider.of<AppState>(context)
              .dispatch(new SwitchTabAction(tabNumber: number)),
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.file_download),
              title: Text('Download'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.video_library),
              title: Text('Videos'),
            )
          ],
        ),
      ),
    );
  }
}

class RedditResponse {
  final String videoUrl;

  RedditResponse({this.videoUrl});
}
