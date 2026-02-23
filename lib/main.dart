import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/pages/ordenes_preparacion/lista_ordenes_entrega.dart';
import 'package:vientri/pages/catalogo/carrito_page.dart';
import 'package:vientri/pages/catalogo/estado_traslado.dart';
import 'package:vientri/pages/catalogo/lista_pedidos.dart';
import 'package:vientri/pages/catalogo/rubros_page.dart';
import 'package:vientri/pages/stock/asignar_control.dart';
import 'package:vientri/pages/stock/lista_controles.dart';
import 'package:vientri/pages/stock/nuevo_control.dart';
import 'package:vientri/pages/comunes/inicio/inicio.dart';
import 'package:vientri/pages/comunes/login/login_page.dart';
import 'package:vientri/pages/tiquetera/audio_detalle_tique.dart';
import 'package:vientri/pages/tiquetera/detalle_tique.dart';
import 'package:vientri/pages/tiquetera/detalle_tique_web.dart';
import 'package:vientri/pages/traslados/detalle_traslado.dart';
import 'package:vientri/pages/traslados/lista_traslados.dart';
import 'package:vientri/pages/traslados/nuevo_traslado.dart';
import 'package:vientri/services/boot_page.dart';
import 'package:vientri/src/models/control.dart';
import 'package:vientri/src/models/entidad.dart';
import 'package:vientri/src/models/envio.dart';
import 'package:vientri/src/models/pedido.dart';
import 'package:vientri/voice/voice_router.dart';
import 'dart:async';
import 'package:intl/date_symbol_data_local.dart';
import 'package:app_links/app_links.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  await initializeDateFormatting(null, null);
  Intl.defaultLocale = 'es_AR';

  VoiceRouter.init();

  final uri = Uri.base;
  // Capturar la ruta completa incluyendo hash y query parameters
  // Ejemplo: /#/web/tiquet/750007 → /web/tiquet/750007
  final fullPath = uri.fragment;
  if (fullPath.isNotEmpty && fullPath != '/') {
    // Si hay una ruta web, guardarla para procesarla después del login
    GetStorage().write('pending_route', fullPath);
  }

  runApp(const MyApp());
}



class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Entidad entidad;
  late StreamSubscription deepLinkSubscription;

  @override
  void initState() {
    super.initState();

    final data = GetStorage().read("user");
    entidad = data != null
        ? Entidad.fromJson(data)
        : Entidad(id: 0, cliente: '', nombre: '', usuario: '', usuarioId: 0, password: '', token: '', idbasededatos: 0, basededatos: [], urlApi: '', urlApiHttp: '', urlVientri: '', urlVientriHttp: '', urlApiLocal: '', domicilio: '', logo: '', ubicacion: '', ubicacionId: 0, esAdmin: false, rol: '', rolId: 0, color: '', permisos: [], salones: []);
    
    // Configurar listeners para deep links
    _setupDeepLinkListener();
  }

  void _setupDeepLinkListener() {
    final appLinks = AppLinks();
    
    // Escuchar deep links mientras la app está abierta
    deepLinkSubscription = appLinks.uriLinkStream.listen(
      (Uri uri) {
        // Convertir vientri://tiquet/750007 a /tiquet/750007
        final path = '/${uri.host}${uri.path}';
        GetStorage().write('pending_route', path);
        
        // Si ya hay usuario, ir directamente a esa ruta
        final user = GetStorage().read('user');
        if (user != null) {
          Get.offAllNamed(path);
        } else {
          // Si no hay usuario, ir a login y luego a la ruta
          Get.offAllNamed('/');
        }
      },
      onError: (err) {
        print('Error al procesar deep link: $err');
      },
    );
  }

  @override
  void dispose() {
    deepLinkSubscription.cancel();
    super.dispose();
  }
  
  Future<bool> pedirPermisoMicrofono() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  String rutaInicial() {
    final user = GetStorage().read('user');
    if (user == null) return '/';
    return '/inicio';
  }

  /// Middleware para proteger rutas de web
  GetPage _protectedWebPage({
    required String name,
    required GetPageBuilder pageBuilder,
  }) {
    return GetPage(
      name: name,
      page: () {
        final user = GetStorage().read('user');
        // Debug: estado al entrar en protected page
        // ignore: avoid_print
        print('[ProtectedRoute] checking $name, user present: ${user != null}, pending_route: ${GetStorage().read('pending_route')}');
        if (user == null) {
          // Solo guardar la ruta pendiente si no existe ya
          final existingRoute = GetStorage().read('pending_route');
          if (existingRoute == null) {
            // Intentar capturar la ruta completa desde el fragment (ej: /web/tiquet/750007)
            final fullPath = Uri.base.fragment;
            if (fullPath.isNotEmpty && fullPath != '/') {
              GetStorage().write('pending_route', fullPath);
            } else {
              // Fallback al nombre de la ruta (sin parámetros)
              GetStorage().write('pending_route', name);
            }
          }
          // Usar Future para evitar problemas durante la construcción
          Future.microtask(() {
            // Debug
            // ignore: avoid_print
            print('[ProtectedRoute] redirecting to / (login) for $name');
            Get.offAllNamed('/');
          });
          return const LoginPage();
        }
        return pageBuilder();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/boot',
      getPages: [
        GetPage(name: '/boot', page: () => const BootPage()),
        GetPage(
          name: '/tiquet/:id',
          page: () {
            final id = int.parse(Get.parameters['id']!);
            return DetalleTique(
              entidad: entidad,
              idTique: id,
            );
          },
        ),
        _protectedWebPage(
          name: '/web/tiquet/:id',
          pageBuilder: () {
            final id = int.parse(Get.parameters['id']!);
            return DetalleTiqueWeb(
              entidad: entidad,
              idTique: id,
            );
          },
        ),
        GetPage(
          name: '/audio-tiquet/:id',
          page: () {
            final id = int.parse(Get.parameters['id']!);
            return AudioDetalleTique(
              entidad: entidad,
              idTique: id,
            );
          },
        ),
        GetPage(name: '/', page: () => const LoginPage()),
        GetPage(name: '/inicio', page: () => InicioPage(entidad: entidad)),
        GetPage(name: '/listaControles', page: () => ListaControles(entidad: entidad)),
        GetPage(name: '/nuevoControl', page: () => NuevoControl(entidad: entidad, control: Control(id: 0, diferencias: "", ubicacion: "", ubicacionId: 0, empleado: "", empleadoId: 0, fecha: "", hora: "", usrSolicita: "", idUsrSolicita: 0, estadoId: 0, duracion: "", horaIni: "", horaFin: "", items: 0, articulos: []))),
        GetPage(name: '/asignarControl', page: () => AsignarControl(entidad: entidad)),
        GetPage(name: '/listaTraslados', page: () => ListaTraslados(entidad: entidad)),
        GetPage(name: '/nuevoTraslado', page: () => NuevoTraslado(entidad: entidad)),
        GetPage(name: '/estadoTraslado', page: () => EstadoTraslado(entidad: entidad, label: '', icon: Icons.abc, color: Colors.white, observacion: '')),
        GetPage(name: '/detalleTraslado', page: () => DetalleTraslado(
          entidad: entidad,
          envio: Envio(id: 0, estadoId: 0, estadoName: "", emisor: "", receptor: "", emisorId: -1, receptorId: -1, origen: "", origenId: 0, destino: "", destinoId: 0, chofer: "", choferId: 0, cantidad: 0, hora: "", observacionEmisor: "", observacionReceptor: "", fecha: "", articulos: []),
        )),
        GetPage(name: '/listaPedidos', page: () => ListaPedidos(entidad: entidad)),
        GetPage(name: '/rubros', page: () => RubroPage(entidad: entidad, pedido: Pedido(id: 0, idUsr: 0, detalle: [], namePer: '', idPer: 0, idContactoPer: 0, nameContacto: '', nameUsr: '', estado: '', estadoId: 0, fecha: '', total: 0, pdto: 0, telefono: '', items: 0),)),
        GetPage(name: '/carrito', page: () => CarritoPage(entidad: entidad, pedido: Pedido(id: 0, idUsr: 0, detalle: [], namePer: '', idPer: 0, idContactoPer: 0, nameContacto: '', nameUsr: '', estado: '', estadoId: 0, fecha: '', total: 0, pdto: 0, telefono: '', items: 0),)),
        GetPage(name: '/listaPedidosPendientes', page: () => ListaOrdenesEntrega(entidad: entidad)),
      ],
      theme: ThemeData(
        fontFamily: 'Inter',
        primaryColor: const Color.fromARGB(255, 255, 255, 255),
        colorScheme: ColorScheme(
          primary: AppColors.semantics.text.action,
          secondary: const Color.fromARGB(255, 255, 255, 255),
          brightness: Brightness.light,
          onPrimary: const Color.fromARGB(255, 255, 255, 255),
          surface: const Color.fromARGB(255, 255, 255, 255),
          onSurface: const Color.fromARGB(255, 92, 92, 92),
          error: const Color.fromARGB(255, 255, 255, 255),
          onError: const Color.fromARGB(255, 255, 255, 255),
          onSecondary: const Color.fromARGB(255, 255, 255, 255),
        ),
      ),
    );
  }
}
