import 'package:flutter/services.dart';

typedef VoiceCallback = Future<void> Function(MethodCall call);

class VoiceCommands {
  static final Map<String, VoiceCallback> _handlers = {};

  static Future<void> handle(MethodCall call) async {
    final method = call.method;

    final callback = _handlers[method];
    if (callback != null) {
      await callback(call);
    } else {
      // Si no hay handler, ignorar
      // print("🔇 No hay handler para '$method'");
    }
  }

  static void register(String command, VoiceCallback handler) {
    _handlers[command] = handler;
  }

  static void unregister(String command) {
    _handlers.remove(command);
  }

  static void clear() {
    _handlers.clear();
  }
}
