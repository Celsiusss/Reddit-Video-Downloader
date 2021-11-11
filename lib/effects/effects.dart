import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:image_gallery/image_gallery.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:reddit_video_downloader/actions/actions.dart';
import 'package:reddit_video_downloader/models/app_state.dart';
import 'package:redux_epics/redux_epics.dart';
import 'package:http/http.dart' as http;

Future<String> _getDash(String redditUrl) async {

  Future<String> fetch(String url) async {
    if (!redditUrl.endsWith('/')) {
      redditUrl += '/';
    }
    redditUrl += '.json';

    try {
      final response = await http.get(redditUrl);
      debugPrint(response.statusCode.toString());
      if (response.statusCode == 302) {
        debugPrint('Location: ' + response.headers['Location']);
        return await fetch(response.headers['Location']);
      }

      return response.body;
    } catch (e) {
      return '{}';
    }
  }

  dynamic data = jsonDecode(await fetch(redditUrl));

  try {
    String dashUrl = data[0]['data']['children'][0]['data']['secure_media']
        ['reddit_video']['dash_url'];
    return dashUrl;
  } catch (e) {
    return null;
  }
}

Stream<dynamic> _startDownload(
    Stream<dynamic> actions, EpicStore<AppState> store) {
  return actions
      .where((action) => action is StartDownloadAction)
      .asyncMap((action) async {
    void updateStatus(String status) {
      StoreProvider.of<AppState>(action.context)
          .dispatch(new UpdateStatusAction(status));
    }

    void openDialog(String title, String body) {
      StoreProvider.of<AppState>(action.context).dispatch(new OpenDialogAction(
          title: title, body: body, context: action.context));
    }

    debugPrint('download');
    updateStatus('Starting download');
    String url = action.url;

    var images = await FlutterGallaryPlugin.getAllImages;
    debugPrint(images.toString());

    if (url.isEmpty) {
      openDialog('Failure', 'Empty URL.');
      return new StopDownloadAction();
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
        openDialog('Insufficient permissions',
            'We need the storage permission to be able to save your video.');
        debugPrint('access denied');
        return new StopDownloadAction();
      }
    }

    updateStatus('Getting DASH information');
    String dashUrl = await _getDash(url);
    if (dashUrl == null) {
      openDialog(
          'Failure', 'Something happened when getting the video information.');
      return new StopDownloadAction();
    }

    debugPrint(dashUrl);

    updateStatus('Initializiging ffmpeg');
    final FlutterFFmpeg ffmpeg = new FlutterFFmpeg();
    final Directory directory = await getTemporaryDirectory();

    String path = directory.path;

    String fileName = 'temp.mp4';

    debugPrint('Path: ' + path);
    updateStatus('Running ffmpeg');

    ffmpeg.disableLogs();
    ffmpeg.enableStatisticsCallback((int time,
        int size,
        double bitrate,
        double speed,
        int videoFrameNumber,
        double videoQuality,
        double videoFps) {
      updateStatus(
          'time: $time, size: $size, bitrate: $bitrate, speed: $speed, videoFrameNumber: $videoFrameNumber, videoQuality: $videoQuality, videoFps: $videoFps');
    });

    int code =
        await ffmpeg.execute('-y -i $dashUrl -codec copy $path/$fileName');
    if (code == 0) {
      debugPrint('success');
      debugPrint('saving to $path/$fileName');

      final result = await ImageGallerySaver.saveFile('$path/$fileName');
      debugPrint(result);
      updateStatus('Success');
      openDialog('Success', 'Your video was downloaded.');
      return new StopDownloadAction();
    } else {
      debugPrint('failure');
      updateStatus('Error');
      debugPrint(code.toString());
      openDialog('Failure', 'Something happened when downloading the video.');
      return new StopDownloadAction();
    }
  });
}

Stream<dynamic> _openDialog(
    Stream<dynamic> actions, EpicStore<AppState> store) {
  return actions
      .where((action) => action is OpenDialogAction)
      .asyncMap((action) async {
    showDialog(
        context: action.context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(action.title),
            content: SingleChildScrollView(
              child: Text(action.body),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Close'),
                onPressed: Navigator.of(context).pop,
              )
            ],
          );
        });
  });
}

final epic = combineEpics<AppState>([_startDownload, _openDialog]);
