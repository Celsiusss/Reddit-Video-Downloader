import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:reddit_video_downloader/screens/home/download.dart';

class Home extends StatelessWidget {
  TextEditingController urlController = new TextEditingController();

  BuildContext context;

  Future<String> getDash(String redditUrl) async {
    if (!redditUrl.endsWith('/')) {
      redditUrl += '/';
    }
    redditUrl += '.json';

    Future<String> fetch() async {
      try {
        final response = await http.get(redditUrl);
        return response.body;
      } catch (e) {
        return '{}';
      }
    }

    dynamic data = jsonDecode(await fetch());

    try {
      String dashUrl = data[0]['data']['children'][0]['data']['secure_media']
          ['reddit_video']['dash_url'];
      return dashUrl;
    } catch (e) {
      return null;
    }
  }

  void downloadVideo() async {
    debugPrint('download');
    String url = urlController.text;
    urlController.clear();

    if (url.isEmpty) {
      openDialog('Failure', 'Empty URL.');
      return;
    }

    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);

    if (permission != PermissionStatus.granted) {
      Map<PermissionGroup, PermissionStatus> permissions =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.storage]);
      debugPrint(permissions.toString());
      var status = permissions[PermissionGroup.storage];

      if (status != PermissionStatus.granted) {
        openDialog('Insufficient permissions', 'We need the storage permission to be able to save your video.');
        debugPrint('access denied');
        return;
      }
    }

    String dashUrl = await this.getDash(url);
    if (dashUrl == null) {
      openDialog('Failure', 'Something happened when getting the video information.');
      return;
    }

    debugPrint(dashUrl);

    final FlutterFFmpeg ffmpeg = new FlutterFFmpeg();
    final Directory directory = await getTemporaryDirectory();

    String path = directory.path;

    String fileName = 'temp.mp4';

    debugPrint('Path: ' + path);

    int code = await ffmpeg.execute('-y -i $dashUrl -codec copy $path/$fileName');
    if (code == 0) {
      debugPrint('success');
      debugPrint('saving to $path/$fileName');

      final result = await ImageGallerySaver.saveFile('$path/$fileName');
      debugPrint(result);
      openDialog('Success', 'Your video was downloaded.');
    } else {
      debugPrint('failure');
      debugPrint(code.toString());
      openDialog('Failure', 'Something happened when downloading the video.');
    }
  }

  Future<void> openDialog(String title, String body) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: Text(body),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Close'),
                onPressed: Navigator.of(context).pop,
              )
            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return Container(
      height: 270,
      child: Download(
        urlController: urlController,
        downloadVideo: downloadVideo,
      )
    );
  }
}

class RedditResponse {
  final String videoUrl;

  RedditResponse({this.videoUrl});
}
