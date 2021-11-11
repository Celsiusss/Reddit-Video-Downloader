import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reddit_video_downloader/actions/actions.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:reddit_video_downloader/models/app_state.dart';

class Download extends StatelessWidget {
  static const platform = const MethodChannel('app.channel.shared.data');
  TextEditingController urlController;

  Download({@required this.urlController}) {
    getSharedText();
  }

  getSharedText() async {
    var sharedData = await platform.invokeMethod("getSharedText");
    if (sharedData != null) {
      urlController.text = sharedData;
    }
  }

  @override
  Widget build(BuildContext context) {
    void startDownload() {
      StoreProvider.of<AppState>(context)
          .dispatch(new StartDownloadAction(urlController.text, context));
      urlController.clear();
    }

    return Column(
      children: <Widget>[
        Card(
          elevation: 5,
          margin: const EdgeInsets.all(24),
          child: Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: StoreConnector<AppState, bool>(
                  converter: (store) => store.state.download.isDownloading,
                  builder: (context, isDownloading) {
                    if (!isDownloading) {
                      return Column(children: <Widget>[
                        Text(
                          'Download Video',
                          style: Theme.of(context).textTheme.headline,
                        ),
                        TextField(
                          controller: urlController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(), labelText: 'URL'),
                          onSubmitted: (s) => startDownload(),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: FlatButton(
                            padding: EdgeInsets.all(15),
                            child: Container(
                              width: 120,
                              height: 20,
                              child: Row(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(right: 20),
                                    child: Icon(Icons.file_download),
                                  ),
                                  Text('Download'),
                                ],
                              ),
                            ),
                            onPressed: () => startDownload(),
                          ),
                        ),
                      ]);
                    } else {
                      return Downloading();
                    }
                  })),
        ),
      ],
    );
  }
}

class Downloading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, String>(
      converter: (Store<AppState> store) => store.state.download.status,
      builder: (context, String status) => Column(
        children: <Widget>[Text(status)],
      ),
    );
  }
}
