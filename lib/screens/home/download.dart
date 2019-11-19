import 'dart:async';

import 'package:flutter/material.dart';

class Download extends StatelessWidget {
  TextEditingController urlController;
  Function downloadVideo;

  StreamController<bool> isDownloadingController;
  Stream<bool> isDownloading = new Stream.value(false);

  Download({@required this.urlController, @required this.downloadVideo}) {
    isDownloadingController = new StreamController();
    isDownloadingController.add(false);
    isDownloading = isDownloadingController.stream;
  }

  startDownload() async {
    isDownloadingController.add(true);
    await downloadVideo();
    isDownloadingController.add(false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Card(
          elevation: 5,
          margin: const EdgeInsets.all(24),
          child: Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: StreamBuilder<bool>(
                  stream: isDownloading,
                  builder: (context, snapshot) {
                    if (!snapshot.data) {
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
                          child: RaisedButton(
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
                            onPressed: startDownload,
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
    return Column(
      children: <Widget>[Text('Downloading...')],
    );
  }
}
