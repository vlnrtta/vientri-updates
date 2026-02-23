import 'audio_recorder_stub.dart'
    if (dart.library.html) 'audio_recorder_web.dart';

abstract class AudioRecorder {
  Future<void> start();
  Future<void> pause();
  Future<void> resume();
  Future<String?> stopAndGetBase64();
  void dispose();
}

AudioRecorder createAudioRecorder() => getAudioRecorder();
