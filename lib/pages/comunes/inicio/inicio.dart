// ignore_for_file: prefer_const_constructors, avoid_print, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/constants/notificaciones.dart';
import 'package:vientri/pages/ordenes_preparacion/lista_ordenes_entrega.dart';
import 'package:vientri/pages/autorizaciones/lista_autorizaciones.dart';
import 'package:vientri/pages/comunes/login/login_page.dart';
import 'package:vientri/pages/comunes/permisos/permisos_page.dart';
import 'package:vientri/pages/comunes/usuario/perfil_page.dart';
import 'package:vientri/pages/copilot/copilot_page.dart';
import 'package:vientri/pages/leer_codigos/lista_recientes.dart';
import 'package:vientri/pages/asignar_codigos_imagenes/lista_articulos.dart';
import 'package:vientri/pages/catalogo/lista_pedidos(master).dart';
import 'package:vientri/pages/contactos/lista_contactos.dart';
import 'package:vientri/pages/controller.dart';
import 'package:vientri/pages/stock/lista_controles.dart';
import 'package:vientri/pages/tiquetera/lista_tiques.dart';
import 'package:vientri/pages/traslados/lista_traslados.dart';
import 'package:vientri/src/models/entidad.dart';
import 'package:vientri/voice/voice_commands.dart';
import 'package:vientri/voice/voice_router.dart';

// ignore: must_be_immutable
class InicioPage extends StatefulWidget {
  Entidad entidad;
  InicioPage({super.key, required this.entidad});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  late Controller con;
  bool _ejecutandoEnviarAudio = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.entidad.usuario.isEmpty) {
        Get.offAll(() => LoginPage());
      }
    });

    Get.delete<Controller>();    
    con = Get.put(Controller(widget.entidad));
    consultarPermiso();

    VoiceRouter.pushHandler(_onVoiceCommand);
    /*
    VoiceCommands.register('enviar_audio', (call) async {
      if (_ejecutandoEnviarAudio) {
        debugPrint('🔁 enviar_audio ignorado (ya en ejecución)');
        return;
      }

      _ejecutandoEnviarAudio = true;

      final String? nombreContacto = call.arguments as String?;
      debugPrint('🎙 Enviar audio a: $nombreContacto');

      await Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
            CopilotPage(
              entidad: widget.entidad,
              nombreContacto: con.quitarTildes(nombreContacto ?? ""),
            ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end)
                .chain(CurveTween(curve: Curves.ease));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );

      if (mounted) {
        setState(() {
          _ejecutandoEnviarAudio = false;
          Get.delete<Controller>();
          con = Get.put(Controller(widget.entidad));
        });
      }
    });
    */
  }

  void consultarPermiso() async {
    await Permission.microphone.request();
  }

  List<Widget> _buildBotones() {
    return [
      if (con.contienePermiso(216))
        _boton(
          "Control de stock",
          "assets/stock.svg",
          ListaControles(entidad: widget.entidad),
        ),

      if (con.contienePermiso(235))
        _boton(
          "Asignar cód. e imagen",
          "assets/scanner_imagen.svg",
          ListaArticulos(entidad: widget.entidad),
        ),

      if (con.contienePermiso(226))
        _boton(
          "Leer código de barras",
          "assets/scanner.svg",
          ListaRecientes(entidad: widget.entidad),
        ),

      if (con.contienePermiso(200))
        _boton(
          "Catálogo",
          "assets/catalogo.svg",
          ListaPedidos(entidad: widget.entidad),
        ),

      if (con.contienePermiso(205))
        _boton(
          "Traslados",
          "assets/traslados.svg",
          ListaTraslados(entidad: widget.entidad),
        ),

      if (con.contienePermiso(234))
        _boton(
          "Autorizaciones",
          "assets/notificaciones.svg",
          ListaAutorizaciones(entidad: widget.entidad),
        ),

      if (widget.entidad.usuario.toLowerCase() == "shaka")
      _boton(
        "Contactos",
        "assets/contactos.svg",
        ListaContactos(entidad: widget.entidad),
      ),

      /*_boton(
        "Chat",
        "assets/chat.svg",
        Chat(entidad: widget.entidad),
      ),*/

      if (widget.entidad.usuario.toLowerCase() == "shaka")
      _boton(
        "Tiquetera",
        "assets/tiques.svg",
        ListaTiques(entidad: widget.entidad),
      ),

      /*_boton(
        "Imprimir",
        "assets/print.svg",
        Imprimir(entidad: widget.entidad),
      ),*/

      /*_boton(
        "Remito devolución",
        "assets/remito_devolucion.svg",
        ListaRemitos(entidad: widget.entidad),
      ),*/

      if (con.contienePermiso(258))
      _boton(
        "Órdenes de entrega",
        "assets/ordenes_entrega.svg",
        ListaOrdenesEntrega(entidad: widget.entidad),
      ),
      
    ];
  }

  Future<void> _onVoiceCommand(MethodCall call) async {
    switch (call.method) {
      case 'enviar_audio':

          if (_ejecutandoEnviarAudio) {
            debugPrint('🔁 enviar_audio ignorado (ya en ejecución)');
            return;
          }

          _ejecutandoEnviarAudio = true;

          final String? nombreContacto = call.arguments as String?;

          debugPrint('🎙 Enviar audio a: $nombreContacto');

          await Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                CopilotPage(
                  entidad: widget.entidad,
                  nombreContacto: con.quitarTildes(nombreContacto ?? ""),
                ),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                final tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: Curves.ease));
                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );

          if (mounted) {
            setState(() {
              _ejecutandoEnviarAudio = false;
              Get.delete<Controller>();
              con = Get.put(Controller(widget.entidad));
            });
          }

          break;

        case 'cancelar':
        break;

        case 'cambiar_modo':
          final String? modo = call.arguments as String?;
          if (modo == "desarrollo") {
            setState(() => con.usaDesarrollo = true);
            GetStorage().remove('modoDesarrollo${widget.entidad.usuario}');
            GetStorage().write('modoDesarrollo${widget.entidad.usuario}', con.usaDesarrollo);
            Get.delete<Controller>();
            con = Get.put(Controller(widget.entidad));
          } else if (modo == "producción") {
            setState(() => con.usaDesarrollo = false);
            GetStorage().remove('modoDesarrollo${widget.entidad.usuario}');
            GetStorage().write('modoDesarrollo${widget.entidad.usuario}', con.usaDesarrollo);
            Get.delete<Controller>();
            con = Get.put(Controller(widget.entidad));
          }
        break;
    }
  }

  void _navigate(Widget pantallaDestino) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => pantallaDestino,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    ).then((_) {
      setState(() {
        Get.delete<Controller>();
        con = Get.put(Controller(widget.entidad));
      });
    });
  }

  @override
  void dispose() {
    VoiceCommands.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: NotificationWrapper(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: LayoutBuilder(
            builder: (context, constraints) {

              return Stack(
                children: [
                  _buildBackground(),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: double.infinity,
                    ),
                    child: _buildContent(constraints),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF9C74D1),
            Color(0xFFFFFFFF),
          ],
          begin: Alignment.topCenter,
          end: Alignment.center,
        ),
      ),
    );
  }

  Widget _buildContent(BoxConstraints constraints) {
    final isDesktop = constraints.maxWidth >= 1100;
    final isTablet  = constraints.maxWidth >= 700;

    final crossAxisCount = isDesktop
        ? 6
        : isTablet
            ? 4
            : 2;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(isDesktop),
            GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: isDesktop ? 1.1 : 1,
              children: _buildBotones(),
            ),
            if (!con.contienePermiso([216, 235, 226, 200, 205, 234, 233]))
              Center(child: _cartelNoHayApps()),
          ],
        ),
      ),
    );
  }

  Widget _boton(String titulo, String ruta, Widget pantallaDestino) {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.semantics.border.primary,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigate(pantallaDestino),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              ruta,
              width: 42,
              height: 42,
              colorFilter: ColorFilter.mode(
                AppColors.semantics.text.action,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                titulo,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.semantics.text.action,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDesktop) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.entidad.cliente.trim().toUpperCase() == "TANUS"
                    ? "Tanus Jalil"
                    : con.capitalizarNombre(widget.entidad.cliente.trim()),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isDesktop ? 28 : Fontsize.h2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildHeaderActions(),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            "Hola, ${con.capitalizarNombre(widget.entidad.nombre.trim().replaceAll(".", " "))}",
            style: TextStyle(
              color: Colors.white,
              fontSize: isDesktop ? 48 : 40,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (con.usaDesarrollo) _buildWarning(),
        ],
      ),
    );
  }

  Widget _buildHeaderActions() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context)
                .push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        PermisosPage(
                      entidad: widget.entidad,
                      titulo: "Accesos",
                      idApp: 7,
                    ),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      final tween = Tween(begin: begin, end: end)
                          .chain(CurveTween(curve: Curves.ease));
                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                    transitionDuration:
                        const Duration(milliseconds: 400),
                  ),
                )
                .then((_) {
              setState(() {
                Get.delete<Controller>();
                con = Get.put(Controller(widget.entidad));
              });
            });
          },
          child: const Icon(
            Icons.vpn_key_outlined,
            color: Colors.white,
            size: 26,
          ),
        ),
        const SizedBox(width: 16),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    PerfilPage(entidad: widget.entidad),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  final tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: Curves.ease));
                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
                transitionDuration:
                    const Duration(milliseconds: 400),
              ),
            );
          },
          child: ClipOval(
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.brand.c900,
              child: Text(
                widget.entidad.nombre.isNotEmpty
                    ? widget.entidad.nombre[0].toUpperCase()
                    : "",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: Fontsize.h3,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWarning() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 24,
            color: AppColors.semantics.text.warning,
          ),
          const SizedBox(width: 8),
          Text(
            "BASE DE DATOS DE DESARROLLO",
            style: TextStyle(
              color: AppColors.semantics.text.warning,
              fontSize: Fontsize.body,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cartelNoHayApps() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(143, 255, 255, 255),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.semantics.border.primary, width: 1.3)
      ),
      child: Text(
        "No cuenta con acceso a ninguna app",
        style: TextStyle(
          color: AppColors.semantics.text.secondary,
          fontSize: Fontsize.body
        ),
        textAlign: TextAlign.center,
      ),
    );
  }


}