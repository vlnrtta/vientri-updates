import 'dart:convert';
import 'dart:typed_data';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'audio_recorder.dart';

AudioRecorder getAudioRecorder() => AudioRecorderWeb();

class AudioRecorderWeb implements AudioRecorder {
  html.MediaRecorder? _recorder;
  final List<html.Blob> _chunks = [];

  @override
  Future<void> start() async {
    final stream = await html.window.navigator.mediaDevices!
        .getUserMedia({'audio': true});

    _recorder = html.MediaRecorder(stream);
    _chunks.clear();

    _recorder!.addEventListener('dataavailable', (event) {
      final e = event as html.BlobEvent;
      if (e.data != null) {
        _chunks.add(e.data!);
      }
    });

    _recorder!.start();
  }

  @override
  Future<void> pause() async => _recorder?.pause();

  @override
  Future<void> resume() async => _recorder?.resume();

  @override
  Future<String?> stopAndGetBase64() async {
    _recorder?.stop();
    await Future.delayed(const Duration(milliseconds: 300));

    final blob = html.Blob(_chunks);
    final reader = html.FileReader();

    reader.readAsArrayBuffer(blob);
    await reader.onLoadEnd.first;

    final bytes = Uint8List.view(reader.result as ByteBuffer);
    return base64Encode(bytes);
  }

  @override
  void dispose() {
    _recorder?.stream?.getTracks().forEach((t) => t.stop());
  }
}
