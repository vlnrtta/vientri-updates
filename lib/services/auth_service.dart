import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vientri/src/models/entidad.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  final storage = GetStorage();

  /// Obtiene el usuario almacenado
  Entidad? getUser() {
    final data = storage.read('user');
    if (data == null) return null;
    return Entidad.fromJson(data);
  }

  /// Verifica si hay sesión iniciada
  bool isAuthenticated() {
    return getUser() != null;
  }

  /// Almacena una ruta pendiente (para después del login)
  void setPendingRoute(String route) {
    storage.write('pending_route', route);
  }

  /// Obtiene la ruta pendiente
  String? getPendingRoute() {
    return storage.read('pending_route');
  }

  /// Limpia la ruta pendiente
  void clearPendingRoute() {
    storage.remove('pending_route');
  }

  /// Maneja el login y navega a la ruta pendiente si existe
  void handleLoginSuccess() {
    final pendingRoute = getPendingRoute();
    clearPendingRoute();

    if (pendingRoute != null) {
      Get.offAllNamed(pendingRoute);
    } else {
      Get.offAllNamed('/inicio');
    }
  }

  /// Logout
  void logout() {
    storage.remove('user');
    storage.remove('pending_route');
    Get.offAllNamed('/');
  }
}
