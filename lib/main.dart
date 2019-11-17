import 'package:flutter/material.dart';
import 'package:reddit_video_downloader/screens/home/home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.indigoAccent,
        textTheme: TextTheme(
          headline: TextStyle(fontSize: 21),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.indigoAccent,
          textTheme: ButtonTextTheme.primary
        )
      ),
      home: Scaffold(
        appBar: AppBar(
            title: Text('Reddit Video Downloader!'),
        ),
        body: Home()
      ),
    );
  }
}
