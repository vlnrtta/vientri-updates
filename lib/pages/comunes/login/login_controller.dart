// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vientri/src/models/entidad.dart';
import 'package:vientri/src/providers/credenciales_provider.dart';

class LoginController extends GetxController{
  TextEditingController userController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  CredencialesProvider credencialesProvider = CredencialesProvider();

  Future<void> iniciarSesion(BuildContext context) async {
    if (isValidForm(userController.text, passwordController.text)) {
      GetStorage().write("admin", true);

      String usuario = userController.text;
      String password = passwordController.text;
      String finalUsuario = usuario;
      String finalPassword = password;

      if (usuario == "tanus" && password == "flutter") {
        finalUsuario = "uscl154";
        finalPassword = "ydppljaseRR1985";
      } else if (usuario == "feyro" && password == "flutter") {
        finalUsuario = "uscl123";
        finalPassword = "ydppljaseRR1985";
      } else if (usuario == "construluz" && password == "flutter") {
        finalUsuario = "uscl128";
        finalPassword = "ydppljaseRR1985";
      } else {
        GetStorage().write("admin", false);
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final resultado = await credencialesProvider.obtenerCredenciales(finalUsuario, finalPassword);

      Navigator.of(context).pop();
      if (resultado['error'] != null && resultado['error'] != "") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${resultado["error"]}'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        Entidad entidad = resultado['entidad'];
        entidad.logo = "";
        GetStorage().write("user", entidad.toJson());

        // Pequeña espera para asegurar que GetStorage haya actualizado su estado
        await Future.delayed(const Duration(milliseconds: 80));

        // Debug: verificar que el usuario quedó guardado
        final stored = GetStorage().read('user');
        // ignore: avoid_print
        print('[Login] user stored: ${stored != null}');

        final String? pendingRoute = GetStorage().read<String>('pending_route');
        final bool accessedViaWebLink = GetStorage().read<bool>('accessed_via_web_link') ?? false;

        if (pendingRoute != null && pendingRoute.isNotEmpty) {
          // Remover la ruta pendiente antes de navegar
          GetStorage().remove('pending_route');
          // Mantener accessed_via_web_link flag si viene por link web
          if (!accessedViaWebLink) {
            GetStorage().remove('accessed_via_web_link');
          }
          // Usar GetX para navegar preservando los parámetros de ruta
          Future.microtask(() => Get.offAllNamed(pendingRoute));
        } else {
          GetStorage().remove('accessed_via_web_link');
          Future.microtask(() => Get.offAllNamed('/inicio'));
        }
      }
    }

  }

  bool isValidForm(String usuario, String password) {
    if (usuario.isEmpty) {
      _mostrarSnackbar(
        titulo: "Usuario no válido",
        mensaje: "Ingrese el nombre de usuario",
        esError: true,
      );
      return false;
    }

    if (password.isEmpty) {
      _mostrarSnackbar(
        titulo: "Formulario no válido",
        mensaje: "Debe ingresar su contraseña para iniciar sesión",
        esError: true,
      );
      return false;
    }

    return true;
  }

  void _mostrarSnackbar({
    required String titulo,
    required String mensaje,
    required bool esError,
  }) {
    Get.snackbar(
      titulo,
      mensaje,
      icon: Icon(
        esError ? Icons.error_outline : Icons.check_circle_outline,
        color: Colors.white,
      ),
      backgroundColor: esError ? Colors.red.shade400 : Colors.green.shade600,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
      borderRadius: 10,
      duration: const Duration(seconds: 3),
    );
  }

}