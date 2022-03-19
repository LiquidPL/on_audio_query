import 'dart:async';
import 'dart:io';

import 'package:on_audio_query_platform_interface/on_audio_query_platform_interface.dart';

import '../helpers/query_helper_io.dart';
import '/src/interfaces/observer_interface.dart';
import '/src/methods/queries/audios_query.dart';

class AudiosObserver implements ObserverInterface {
  // Helper
  final QueryHelper _helper = QueryHelper();

  // Query
  final AudiosQuery _query = AudiosQuery();

  //
  final StreamController<List<AudioModel>> _controller = StreamController();

  //
  StreamSubscription<FileSystemEvent>? _toWatchStream;

  // [Internal] variable to detect when the observer is running or not.
  bool _isRunning = false;

  @override
  bool get isRunning => _isRunning;

  @override
  Stream<List<AudioModel>> get stream => _controller.stream;

  @override
  Future<void> startObserver(Map args) async {
    //
    if (!_isRunning) {
      print(_helper.defaultMusicDirectory);
      //
      Stream<FileSystemEvent> toWatch = _helper.defaultMusicDirectory.watch(
        recursive: true,
      );

      //
      _toWatchStream = toWatch.listen(
        (_) => onChange(),
        onError: (error) => onError(error),
        cancelOnError: true,
      );

      //
      _isRunning = true;
    }

    //
    _controller.add(await _query.queryAudios());
  }

  @override
  void onChange() async {
    //
    if (_controller.isClosed) {
      stopObserver();
      return;
    }

    //
    if (_controller.isPaused) return;

    //
    _controller.add(await _query.queryAudios());
  }

  @override
  void onError(dynamic error) async => _controller.addError(error);

  @override
  void stopObserver() {
    //
    _isRunning = false;
    _controller.close();
    _toWatchStream?.cancel();
    _toWatchStream = null;
  }
}