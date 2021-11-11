import 'package:reddit_video_downloader/actions/actions.dart';
import 'package:reddit_video_downloader/models/app_state.dart';
import 'package:reddit_video_downloader/reduers/download_reducer.dart';
import 'package:redux/redux.dart';

AppState appReducer(AppState state, action) {
  return AppState(
      download: downloadReducer(state.download, action),
      tabNumber: combineReducers<int>(
              [TypedReducer<int, SwitchTabAction>(_tabNumber)])(
          state.tabNumber, action));
}

int _tabNumber(int number, action) {
  return action.tabNumber;
}
