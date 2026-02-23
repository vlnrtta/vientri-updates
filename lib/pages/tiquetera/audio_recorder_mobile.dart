import 'dart:convert';
import 'dart:io';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'audio_recorder.dart';

class AudioRecorderMobile implements AudioRecorder {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  String? _path;

  AudioRecorderMobile() {
    _recorder.openRecorder();
  }

  @override
  Future<void> start() async {
    final perm = await Permission.microphone.request();
    if (!perm.isGranted) return;

    final dir = await getTemporaryDirectory();
    _path = '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';

    await _recorder.startRecorder(toFile: _path);
  }

  @override
  Future<void> pause() => _recorder.pauseRecorder();

  @override
  Future<void> resume() => _recorder.resumeRecorder();

  @override
  Future<String?> stopAndGetBase64() async {
    final path = await _recorder.stopRecorder();
    if (path == null) return null;

    final bytes = await File(path).readAsBytes();
    return base64Encode(bytes);
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
  }
}
