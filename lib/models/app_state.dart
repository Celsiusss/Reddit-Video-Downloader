import 'package:meta/meta.dart';
import 'package:reddit_video_downloader/models/download.dart';

@immutable
class AppState {
  final Download download;
  final int tabNumber;

  AppState({
    this.download = const Download(),
    this.tabNumber,
  });

  factory AppState.initial() => AppState(
        download: new Download(isDownloading: false, status: 'Not downloading'),
        tabNumber: 0,
      );

  AppState copyWith({
    Download download,
    int tabNumber,
  }) {
    return AppState(
      download: download ?? this.download,
      tabNumber: tabNumber ?? this.tabNumber,
    );
  }
}
