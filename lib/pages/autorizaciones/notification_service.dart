import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final _messaging = FirebaseMessaging.instance;

  static Future<void> initNotifications() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print("Permisos: ${settings.authorizationStatus}");

    // Obtener FCM Token del dispositivo:
    String? token = await _messaging.getToken();
    print("TOKEN FCM: $token");

    // Notificaciones mientras la app está en foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Mensaje en foreground: ${message.notification?.title}");

      // Opcional: mostrar snackbar
    });

    // Notificaciones tocadas cuando app está en background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("Abrieron la app desde la notificación");
    });
  }
}
