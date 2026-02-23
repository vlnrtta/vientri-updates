import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vientri/components/subtle_button/subtle_button.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/pages/controller.dart';
import 'package:vientri/pages/comunes/login/login_page.dart';
//import 'package:vientri/services/voice_service.dart';
import 'package:vientri/src/models/entidad.dart';
import 'package:vientri/src/models/opcion.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class PerfilPage extends StatefulWidget {
  Entidad entidad;
  PerfilPage({super.key, required this.entidad});

  @override
  State<PerfilPage> createState() => _PerfilPage();
}

class _PerfilPage extends State<PerfilPage> {
  late Controller con;
  List<Opcion> _opcionesSalones = [];
  final box = GetStorage();
  bool escuchando = false;

  @override
  void initState() {
    super.initState();
    con = Get.put(Controller(widget.entidad));

    _opcionesSalones = widget.entidad.salones.map((item) {
      var parts = item.split(' - ');
      return Opcion(
        id: int.parse(parts[0]),
        nombre: parts[1],
      );
    }).toList();

    escuchando = box.read('escucha_voz') ?? false;
   }

  Future<void> abrirApp() async {
    final Uri url = Uri.parse("vientri://inicio");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      con.mostrarSnackbar(titulo: "Error", mensaje: "La app no está instalada", esError: true);
    }
  }

  Future<bool> pedirPermisoMicrofono() async {
    final status = await Permission.microphone.status;

    if (status.isGranted) return true;

    final result = await Permission.microphone.request();
    return result.isGranted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context, true),
                        child: const Icon(
                          Icons.arrow_back,
                          size: 26,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 10,
                      child: Center(
                        child: Text(
                          con.capitalizarNombre(widget.entidad.usuario),
                          style: TextStyle(
                            fontSize: Fontsize.h1,
                            color: AppColors.semantics.text.body,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ),
                    const Expanded(
                      flex: 1,
                      child: Icon(
                        Icons.abc,
                        size: 26,
                        color: Colors.transparent,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              _fila("Usuario", con.capitalizarNombre(widget.entidad.usuario)),
              _fila("Nombre", con.capitalizarNombre(widget.entidad.nombre.replaceAll(".", " "))),
              _fila("Cliente", con.capitalizarNombre(widget.entidad.cliente)),
              _fila("Base de datos", "${widget.entidad.idbasededatos} | ${widget.entidad.cliente}"),
              _fila("URL", con.url),
              _fila("Servidor", widget.entidad.domicilio),
              _fila("Versión", con.version),
              const SizedBox(height: 18),
              Text(
                "Salones",
                style: TextStyle(
                  color: AppColors.semantics.text.body,
                  fontSize: Fontsize.h3,
                  fontWeight: FontWeight.bold
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _opcionesSalones.length,
                itemBuilder: (context, index) {
                  final opcion = _opcionesSalones[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Text(
                      opcion.nombre,
                      style: TextStyle(
                        color: AppColors.semantics.text.body,
                        fontSize: Fontsize.body
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),

              /*
              SwitchListTile(
                title: const Text("Escucha por voz"),
                value: escuchando,
                onChanged: (v) async {
                  if (v) {
                    final ok = await pedirPermisoMicrofono();
                    if (!ok) {
                      // permiso rechazado → no prender switch
                      setState(() => escuchando = false);
                      return;
                    }

                    await VoiceService.iniciarEscuchaVoz();
                  } else {
                    await VoiceService.detener();
                  }

                  setState(() => escuchando = v);
                  box.write('escucha_voz', v); // 💾 guardar en memoria
                },
              ),
              */

              const Spacer(),

              SubtleButton(
                text: "Cerrar sesión",
                leftIcon: Icons.logout_rounded,
                type: SubtleButtonType.error,
                onPressed: () {
                  setState(() {
                    GetStorage().remove('user');
                    Get.delete<Controller>();
                    con = Get.put(Controller(widget.entidad));
                    Get.offAll(() => const LoginPage());
                  });
                },
              ),
            ]
          )
        ),
      ),
    );
  }

  Widget _fila(String label, String content) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black12),
        ),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: Fontsize.h3,
              fontWeight: FontWeight.bold,
              color: AppColors.semantics.text.body,
            ),
          ),
          Expanded(
            child: Text(
              content,
              style: TextStyle(
                color: AppColors.semantics.text.body,
                fontSize: Fontsize.body,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

}
