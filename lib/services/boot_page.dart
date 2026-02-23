import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb; 

class BootPage extends StatefulWidget {
  const BootPage({super.key});

  @override
  State<BootPage> createState() => _BootPageState();
}

class _BootPageState extends State<BootPage> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleRouting();
    });
  }

  void _handleRouting() {
    final user = GetStorage().read('user');
    final pendingRoute = GetStorage().read('pending_route');

    // Debug
    // ignore: avoid_print
    print('[BootPage] user present: ${user != null}, pending_route: $pendingRoute');

    // Si no hay usuario
    if (user == null) {
      // Si hay una ruta pendiente, guardarla para después del login
      if (pendingRoute != null && pendingRoute.startsWith('/web/')) {
        GetStorage().write('pending_route', pendingRoute);
        // Marcar que se accedió via link web (para bloquear back)
        GetStorage().write('accessed_via_web_link', true);
        Get.offAllNamed('/');
      } else {
        GetStorage().remove('pending_route');
        GetStorage().remove('accessed_via_web_link');
        Get.offAllNamed('/');
      }
      return;
    }

    // Si hay usuario
    if (pendingRoute != null) {
      GetStorage().remove('pending_route');
      
      // Si es una ruta web, usar el prefijo correcto
      if (pendingRoute.startsWith('/web/')) {
        // Marcar que se accedió via link web (para bloquear back)
        GetStorage().write('accessed_via_web_link', true);
        Get.offAllNamed(pendingRoute);
      } else if (kIsWeb) {
        // Para web, agregar prefijo /web si no lo tiene
        GetStorage().remove('accessed_via_web_link');
        Get.offAllNamed('/web$pendingRoute');
      } else {
        GetStorage().remove('accessed_via_web_link');
        Get.offAllNamed(pendingRoute);
      }
    } else {
      GetStorage().remove('accessed_via_web_link');
      Get.offAllNamed('/inicio');
    }
  }

  


  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
