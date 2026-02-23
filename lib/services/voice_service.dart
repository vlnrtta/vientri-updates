import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceService {
  static bool _escuchando = false;

  static const MethodChannel _channel = MethodChannel("vientri/voice");

  static Future<void> iniciarEscuchaVoz() async {
    final mic = await Permission.microphone.request();

    if (!mic.isGranted) {
      throw Exception("Permiso de micrófono denegado"); 
    }

    await _channel.invokeMethod("startVoiceService");
  }
  
  static Future<void> detener() async {
    if (!_escuchando) return;
    _escuchando = false;

    await _channel.invokeMethod("startVoiceService");
  }
}

