import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:reddit_video_downloader/effects/effects.dart';
import 'package:reddit_video_downloader/models/app_state.dart';
import 'package:reddit_video_downloader/reduers/app_state_reducer.dart';
import 'package:reddit_video_downloader/home.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:redux_epics/redux_epics.dart';

enum TabItem { download, videos }

var _epicMiddleware = new EpicMiddleware(epic);

void main() {
  final store = new Store<AppState>(
    appReducer,
    initialState: AppState.initial(),
    middleware: [_epicMiddleware],
  );
  runApp(MyApp(store: store));
}

class MyApp extends StatelessWidget {
  final Store store;

  MyApp({this.store});

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        title: 'Video Downloader for Reddit',
        theme: ThemeData(
            brightness: Brightness.light,
            backgroundColor: Colors.white,
            primaryColor: Colors.indigoAccent,
            textTheme: TextTheme(
              headline: TextStyle(fontSize: 21),
            ),
            buttonTheme: ButtonThemeData(
              buttonColor: Colors.white,
              textTheme: ButtonTextTheme.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                  side: BorderSide(color: Colors.blue)),
            ),
            appBarTheme: AppBarTheme(
              color: Colors.white,
            )),
        home: Home()
      ),
    );
  }
}
