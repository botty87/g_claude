import 'package:injectable/injectable.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:window_manager/window_manager.dart';

import '../../features/app_logs/data/datasources/talker_log_recorder.dart';
import '../../features/app_logs/domain/repositories/app_logs_repository.dart';

@lazySingleton
class AppLifecycleListener with WindowListener {
  AppLifecycleListener(this._recorder, this._repo, this._talker);
  final TalkerLogRecorder _recorder;
  final AppLogsRepository _repo;
  final Talker _talker;

  Future<void> attach() async {
    windowManager.addListener(this);
    // setPreventClose intercepts the close event so onWindowClose fires before
    // the window is destroyed — giving us time to flush logs and end the session.
    await windowManager.setPreventClose(true);
  }

  @override
  Future<void> onWindowClose() async {
    try {
      await _recorder.stop();
      await _repo.endSession();
    } catch (e, s) {
      _talker.handle(e, s, 'AppLifecycleListener.onWindowClose');
    }
    await windowManager.destroy();
  }
}
