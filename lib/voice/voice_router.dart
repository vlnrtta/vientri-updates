import 'package:flutter/services.dart';

typedef VoiceHandler = Future<void> Function(MethodCall call);

class VoiceRouter {
  static const MethodChannel _channel = MethodChannel('vientri/voice');

  static final List<VoiceHandler> _stack = [];

  static void init() {
    _channel.setMethodCallHandler((call) async {
      if (_stack.isNotEmpty) {
        await _stack.last(call);
      }
    });
  }

  static void pushHandler(VoiceHandler handler) {
    _stack.add(handler);
  }

  static void popHandler() {
    if (_stack.isNotEmpty) {
      _stack.removeLast();
    }
  }

  static void clear() {
    _stack.clear();
  }
}
