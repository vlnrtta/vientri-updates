// ignore_for_file: avoid_print, use_build_context_synchronously
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:vientri/constants/notificaciones.dart';
import 'package:vientri/pages/comunes/permisos/permisos_page.dart';
import 'package:vientri/src/models/acceso.dart';
import 'package:vientri/src/models/articulo.dart';
import 'package:vientri/src/models/autorizacion.dart';
import 'package:vientri/src/models/cliente.dart';
import 'package:vientri/src/models/contacto.dart';
import 'package:vientri/src/models/control.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:vientri/src/models/envio.dart';
import 'package:vientri/src/models/opcion.dart';
import 'package:vientri/src/models/entidad.dart';
import 'package:vientri/src/models/pedido.dart';
import 'package:vientri/src/models/ordenEntrega.dart';
import 'package:vientri/src/models/remitoDevolucion.dart';
import 'package:vientri/src/models/remitoEntrega.dart';
import 'package:vientri/src/models/rubro.dart';
import 'package:html/parser.dart' as parser;
import 'package:vientri/src/models/tique.dart';
import 'package:vientri/src/models/tiqueDetalle.dart';
import 'package:vientri/src/models/tiqueMensaje.dart';
import 'package:vientri/src/providers/credenciales_provider.dart';

class Controller extends GetConnect {
  Entidad entidad;
  BuildContext? context;
  late String url;
  late String url2; // para tiques
  late bool usaInternet;
  late bool usaDesarrollo;
  late String storageKey;
  final box = GetStorage();
  final version = "VientriApp V. FEB23-1047";

  Controller(this.entidad) {
    storageKey = "accesosApp${entidad.usuario}";
    usaInternet = GetStorage().read('modoConexion${entidad.usuario}') ?? true;
    usaDesarrollo = GetStorage().read('modoDesarrollo${entidad.usuario}') ?? false;
    if (usaInternet) {
      if (CredencialesProvider.isWeb) {
        if (usaDesarrollo) {
          url = entidad.urlVientri;
          print("Esta usando desarrollo https");
        } else {
          url = entidad.urlApi;
          print("Esta usando produccion https");
        }
      } else {
        if (usaDesarrollo) {
          url = entidad.cliente.trim().toLowerCase() == "feyro" ? entidad.urlVientri : entidad.urlVientriHttp;
          print("Esta usando desarrollo http");
        } else {
          url = entidad.cliente.trim().toLowerCase() == "feyro" ? entidad.urlApi : entidad.urlApiHttp;
          print("Esta usando produccion http");
          
        }
      }
    } else {
      url = entidad.urlApiLocal;
      print("Esta usando produccion local");
    }

    // para tiques
    url2 = "http://net.vientri.com:3002";
    if (kIsWeb) {
      url2 = entidad.urlVientri;
    }

  }

  void mostrarSnackbar({
    required String titulo,
    required String mensaje,
    required bool esError,
    int? seconds,
  }) {
    Get.rawSnackbar(
      title: titulo,
      message: mensaje,
      backgroundColor: esError ? Colors.red.shade400 : Colors.green.shade600,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(milliseconds: seconds ?? 1400),
      animationDuration: const Duration(milliseconds: 200),
    );
  }

  String formatearFechayDia3(String isoString) {
    final fechaOriginal = DateTime.parse(isoString).toLocal();
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final fecha = fechaOriginal.add(const Duration(hours: 3));
    final fechaDia = DateTime(fecha.year, fecha.month, fecha.day);
    final diferencia = hoy.difference(fechaDia).inDays;

    final hora = "${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}";

    if (diferencia == 0) {
      return "Hoy, $hora";
    }

    if (diferencia == 1) {
      return "Ayer, $hora";
    }

    const meses = [
      "ene", "feb", "mar", "abr", "may", "jun",
      "jul", "ago", "sep", "oct", "nov", "dic"
    ];

    final dia = fecha.day;
    final mes = meses[fecha.month - 1];

    return "$dia $mes ${fecha.year}, $hora";
  }

  String formatearFechayDia2(String fechaStr) {
    // Separar año, mes y día
    final partes = fechaStr.split('-');
    if (partes.length != 3) return fechaStr; // fallback si no es válido

    final year = int.tryParse(partes[0]);
    final month = int.tryParse(partes[1]);
    final day = int.tryParse(partes[2]);

    if (year == null || month == null || day == null) return fechaStr;

    final fecha = DateTime(year, month, day);

    final hoy = DateTime.now();
    final ayer = hoy.subtract(const Duration(days: 1));

    final fechaSolo = DateTime(fecha.year, fecha.month, fecha.day);
    final hoySolo = DateTime(hoy.year, hoy.month, hoy.day);
    final ayerSolo = DateTime(ayer.year, ayer.month, ayer.day);

    if (fechaSolo == hoySolo) {
      return 'Hoy';
    } else if (fechaSolo == ayerSolo) {
      return 'Ayer';
    } else {
      return DateFormat('d MMM', 'es_ES').format(fecha);
    }
  }

  String formatearFechayDia(String fechaStr) {
    // Separar año, mes y día
    final partes = fechaStr.split('-');
    if (partes.length != 3) return fechaStr; // fallback si no es válido

    final year = int.tryParse(partes[0]);
    final month = int.tryParse(partes[1]);
    final day = int.tryParse(partes[2]);

    if (year == null || month == null || day == null) return fechaStr;

    final fecha = DateTime(year, month, day);

    final hoy = DateTime.now();
    final ayer = hoy.subtract(const Duration(days: 1));

    final fechaSolo = DateTime(fecha.year, fecha.month, fecha.day);
    final hoySolo = DateTime(hoy.year, hoy.month, hoy.day);
    final ayerSolo = DateTime(ayer.year, ayer.month, ayer.day);

    if (fechaSolo == hoySolo) {
      return 'Hoy';
    } else if (fechaSolo == ayerSolo) {
      return 'Ayer';
    } else {
      return DateFormat('d MMM. yyyy', 'es_ES').format(fecha);
    }
  }
    
  String quitarTildes(String texto) {
    const acentos = {
      'á': 'a', 'à': 'a', 'ä': 'a', 'â': 'a',
      'Á': 'A', 'À': 'A', 'Ä': 'A', 'Â': 'A',
      'é': 'e', 'è': 'e', 'ë': 'e', 'ê': 'e',
      'É': 'E', 'È': 'E', 'Ë': 'E', 'Ê': 'E',
      'í': 'i', 'ì': 'i', 'ï': 'i', 'î': 'i',
      'Í': 'I', 'Ì': 'I', 'Ï': 'I', 'Î': 'I',
      'ó': 'o', 'ò': 'o', 'ö': 'o', 'ô': 'o',
      'Ó': 'O', 'Ò': 'O', 'Ö': 'O', 'Ô': 'O',
      'ú': 'u', 'ù': 'u', 'ü': 'u', 'û': 'u',
      'Ú': 'U', 'Ù': 'U', 'Ü': 'U', 'Û': 'U'
    };

    acentos.forEach((k, v) {
      texto = texto.replaceAll(k, v);
    });

    return texto;
  }

  // CONTROL STOCK
  String getHoraActual() {
    final now = DateTime.now();
    final formato = DateFormat('HH:mm');
    return formato.format(now);
  }

  String getFechaHoraActual() {
    final now = DateTime.now().subtract(const Duration(hours: 3));
    final formato = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formato.format(now);
  }

  String formatearFecha(String fechaStr) {
    final partes = fechaStr.split('-');
    if (partes.length != 3) return fechaStr;

    final year = int.tryParse(partes[0]);
    final month = int.tryParse(partes[1]);
    final day = int.tryParse(partes[2]);

    if (year == null || month == null || day == null) return fechaStr;

    final fecha = DateTime(year, month, day);

    return DateFormat('d MMM. yyyy', 'es_ES').format(fecha);
  }

  String capitalizarNombre(String nombre) {
    if (nombre.trim().isEmpty) return '';

    return nombre
        .trim()
        .split(RegExp(r'\s+'))
        .map((palabra) {
          if (palabra.isEmpty) return '';
          return palabra[0].toUpperCase() + palabra.substring(1).toLowerCase();
        })
        .join(' ');
  }

  // ESTADOS
  // 10822 -> PENDIENTE O ENVIADO
  // 10823 -> EN CURSO
  // 10824 -> FINALIZADO
  // N -> S/D
  Future<List<Control>> listaControles([String? filtro]) async {
    try {
      final response = await http.post(
        Uri.parse('$url/controlStk/lista'),
        headers: {
          'x-access-token': entidad.token,
        },
        body: {
          "usuarioId": entidad.usuarioId.toString(),
          "listaTodo": entidad.permisos.contains(218) ? "1" : "0" 
        }
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final controles = data["controles"];
        
        if (controles == null) return [];

        final lista = controles is List ? controles : [controles];
        return lista.map<Control>((r) {
          print("RTA: $r");
          final fechaHora = DateTime.parse(r["FECHAHORA"]);
          return Control(
            id: r["ID"] ?? 0,
            estadoId: r["IDCRC_ESTADOCONTROL"] ?? 0,
            hora: "${fechaHora.hour.toString().padLeft(2, '0')}:${fechaHora.minute.toString().padLeft(2, '0')}",
            fecha: "${fechaHora.year}-${fechaHora.month.toString().padLeft(2, '0')}-${fechaHora.day.toString().padLeft(2, '0')}",
            articulos: [],
            items: r["ITEMS"] ?? 0,
            ubicacion: r["ALMACENDES"].toString().trim(),
            ubicacionId: r["IDALMACEN"] ?? 0,
            empleado: r["USR_EJECUTA"].toString().trim(),
            empleadoId: r["IDUSR_EJECUTA"] ?? 0,
            idUsrSolicita: r["IDUSR_SOLICITA"] ?? 0,
            usrSolicita: r["USR_SOLICITA"].toString().trim(),
            duracion: r["duracion"].toString(),
            horaIni: r["FECHAHORAINI"].toString(),
            horaFin: r["FECHAHORAFIN"].toString(),
            diferencias: r["DIFERENCIAS"].toString(),
          );
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception("Error al obtener Control: $e");
    }
  }

  Future<Control> detalleControl(int id) async {
    try {
      final response = await http.post(
        Uri.parse('$url/controlStk/consulta'),
        headers: {
          'x-access-token': entidad.token,
        },
        body: {
          'controlId': id.toString(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final controlJson = data["control"];
        final fechaHora = DateTime.parse(controlJson["FECHAHORA"]);
        final List<dynamic> detalleJson = data["items"] ?? [];
        final List<Articulo> articulos = detalleJson.map((item) {
          final fecha = DateTime.parse(item["FECHAHORA"]);
          final horaFormateada = DateFormat('HH:mm').format(fecha);
          return Articulo(
            id: item["ID"] ?? 0,
            articuloId: item["IDART"],
            articuloDes: item["articuloDes"].toString().trim(),
            rubroDes: item["rubroDes"] ?? "",
            rubroId: item["rubroId"] ?? 0,
            articuloCod: item["articuloCod"].toString().trim(),
            impoconiva: 0,
            hora: horaFormateada,
            stk: item["STOCK"] ?? 0,
            cantidad: item["CANTIDAD"] ?? 0,
            foto: "",
            cBarra: ""
          );
        }).toList();

        return Control(
          id: controlJson["ID"] ?? 0,
          estadoId: controlJson["IDCRC_ESTADOCONTROL"] ?? 0,
          hora: "${fechaHora.hour.toString().padLeft(2, '0')}:${fechaHora.minute.toString().padLeft(2, '0')}",
          fecha: "${fechaHora.year}-${fechaHora.month.toString().padLeft(2, '0')}-${fechaHora.day.toString().padLeft(2, '0')}",
          articulos: articulos,
          ubicacion: controlJson["ALMACENDES"] ?? "",
          ubicacionId: controlJson["IDALMACEN"] ?? 0,
          idUsrSolicita: controlJson["IDUSR_SOLICITA"] ?? 0,
          usrSolicita: controlJson["USR_SOLICITA"]?.trim() ?? "",
          empleado: controlJson["USR_EJECUTA"]?.trim() ?? "",
          empleadoId: controlJson["IDUSR_EJECUTA"] ?? 0,
          duracion: controlJson["duracion"] ?? "",
          horaIni: controlJson["FECHAHORAINI"] ?? "",
          horaFin: controlJson["FECHAHORAFIN"] ?? "",
          items: controlJson["ITEMS"] ?? 0,
          diferencias: "",
        );
      } else {
        throw Exception("Error en la API: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error al obtener Control: $e");
    }
  }

  //  SI EL ID ES 0 LO CREA Y SINO LO EDITA
  Future<int> actualizaControl(BuildContext context, Control control) async {
    try {
      final body = {
        "jControl": {
          "id": control.id,
          "idUsrSolicita": control.idUsrSolicita,
          "idUsrEjecuta": control.empleadoId,
          "fechaHora": getFechaHoraActual(),
          "fechaHoraIni": control.horaIni == "" ? null : control.horaIni,
          "fechaHoraFin": control.horaFin == "" ? null : control.horaFin,
          "idCrcEstadoControl": control.estadoId,
          "idAlmacen": control.ubicacionId,
          "articulos": control.articulos.map((art) => 
            {
              "id": control.id == 0 ? 0 : art.id,
              "idArt": art.articuloId,
              "cantidad": art.cantidad,
              "stock": art.stk,
              "fechaHora": getFechaHoraActual()
            }
          ).toList(),
        }
      };

      print("ACUTALIZACION: ${jsonEncode(body)}");

      final response = await http.post(
        Uri.parse('$url/controlStk/actualiza'),
        headers: {
          'x-access-token': entidad.token,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      int id = 0;
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (control.id == 0) {
          print("SE CREO UN CONTROL");
          print("NUEVO CONTROL ID: ${jsonDecode(response.body)}");
        } else {
          print("SE ACTUALIZO EL CONTENIDO DEL CONTROL: ${control.id}");
          print("CONTROL ID: ${jsonDecode(response.body)}");
        }

        final decoded = jsonDecode(response.body);

        if (decoded.containsKey("controlId") && decoded["controlId"] != null) {
          id = int.tryParse(decoded["controlId"].toString()) ?? 0;
        } else {
          print("No vino controlId en la respuesta: $decoded");
        }
        return id;

      } else {
        print("Error al enviar el control: ${response.statusCode}");
        print("Respuesta: ${response.body}");

        if (response.statusCode == 404) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("No se pudo cargar el control, vuelva a intentarlo"),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }

        return id;
      }
    } catch (e) {
      print("Error en la solicitud: $e");
      return 0;
    }
  }

  Future<void> actualizaEstado(BuildContext context, int id, int estadoId) async {
    try {
      final response = await http.post(
        Uri.parse('$url/controlStk/actualizaEstado'),
        headers: {
          'x-access-token': entidad.token,
        },
        body: {
          "controlId": id.toString(),
          "estadoId": estadoId.toString()
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {

      } else {
        print("Error al cambiar de estado el control: ${response.statusCode}");
        print("Respuesta: ${response.body}");

        if (response.statusCode == 404) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("No se pudo actualizar el estado, vuelva a intentarlo"),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }

      }
    } catch (e) {
      print("Error en la solicitud: $e");
    }
  }

  //  SI EL ID ES 0 LO CREA Y SINO LO EDITA
  Future<int> actualizaControlItem(BuildContext context, Control control) async {
    try {
      final body = {
        "jControl": {
          "id": control.id,
          "idUsrSolicita": control.idUsrSolicita,
          "idUsrEjecuta": control.empleadoId,
          "fechaHora": control.fecha,
          "fechaHoraIni": null,
          "fechaHoraFin": null,
          "idCrc_estadoControl": control.estadoId,
          "idAlmacen": control.ubicacionId
        }
      };

      print(jsonEncode(body));

      final response = await http.post(
        Uri.parse('$url/controlStk/actualiza'),
        headers: {
          'x-access-token': entidad.token,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      int id = 0;
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (control.id == 0) {
          print("SE CREO UN CONTROL");
          print("NUEVO CONTROL ID: ${jsonDecode(response.body)}");
        } else {
          print("SE ACTUALIZO EL CONTENIDO DEL CONTROL: ${control.id}");
          print("CONTROL ID: ${jsonDecode(response.body)}");
        }

        final decoded = jsonDecode(response.body);
        print("RTA: $decoded");

        if (decoded.containsKey("carritoId") && decoded["carritoId"] != null) {
          id = int.tryParse(decoded["carritoId"].toString()) ?? 0;
        } else {
          print("No vino carritoId en la respuesta: $decoded");
        }
        return id;

      } else {
        print("Error al enviar el control: ${response.statusCode}");
        print("Respuesta: ${response.body}");

        if (response.statusCode == 404) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("No se pudo cargar el control, vuelva a intentarlo"),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }

        return id;
      }
    } catch (e) {
      print("Error en la solicitud: $e");
      return 0;
    }
  }
  
  Future<bool> cancelarEnvio(BuildContext context, String id) async {
    try {
      final response = await http.post(
        Uri.parse('$url/controlStk/elimina'),
        headers: {
          'x-access-token': entidad.token,
        },
        body: {
          "controlId": id.toString()
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
        
      }
    } catch (e) {
      print("Error en la solicitud: $e");
      return false;
    }
  }
  // FIN CONTROL STOCK




  // COMUNES
  Future<List<Rubro>> listaRubros(Entidad entidad) async {
    try {
      final response = await http.post(
        Uri.parse('$url/gestion/articulo/rubros'),
        headers: {
          'x-access-token': entidad.token
        },
        body: {},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        List<Rubro> rubros = Rubro.fromJsonList(responseData['rubros']);
        return rubros;
      } else {
        return [];
      }
    } catch (e) {
        return [];
    }
  }

  Future<List<Articulo>> listaArticulos(String filtro, Entidad entidad) async {
    try {
      final response = await http.post(
        Uri.parse('$url/gestion/articulo/lista'),
        headers: {
          'x-access-token': entidad.token,
        },
        body: {
          "texto": quitarTildes(filtro.toString()),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.body;

        final responseData = jsonDecode(body);
        if (responseData['articulos'] is List) {
          return Articulo.fromJsonList(responseData['articulos']);
        } else {
          print("La API no devolvió una lista en 'articulos': ${responseData['articulos']}");
          return [];
        }
      } else {
        print("Error HTTP: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error en listaArticulos: $e");
      return [];
    }
  }

  Future<List<Opcion>> listaDepositos() async {
    try {
      final response = await http.post(
        Uri.parse('$url/gestion/depositos/lista'),
        headers: {
          'x-access-token': entidad.token,
        },
        body: {
          'texto': ""
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);

        List<Opcion> opciones = (data['depositos'] as List)
            .map((item) => Opcion(
                  id: item['depositoId'],
                  nombre: item['depositoDes'],
                ))
            .toList();

        return opciones;
      } else {
        return [];
      }
    } catch (e) {
      print("Error listaDepositos: $e");
      return [];
    }
  }

  Future<List<Opcion>> listaEmpleados([List? permisos]) async {
    permisos ??= [];
    try {
      final response = await http.post(
        Uri.parse('$url/usuarios/lista'),
        headers: {
          'x-access-token': entidad.token,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);

        final usuarios = (data["usuarios"] as List)
        .map((item) => Opcion.fromJson(item))
        .toList();

        if (permisos.isEmpty) return usuarios;

        final usuariosFiltrados = usuarios.where((user) {
          final permsUser = user.permisos ?? [];
          return permsUser.any((p) => permisos?.contains(p) ?? false);
        }).toList();

        return usuariosFiltrados;
      } else {
        return [];
      }
    } catch (e) {
      print("Error lista empleados: $e");
      return [];
    }
  }

  bool contienePermiso(dynamic value) {
    if (entidad.esAdmin) { return true; }
    if (value is int) {
      return entidad.permisos.contains(value);
    } else if (value is List<int>) {
      // caso lista de números: todos deben estar en permisos
      // ignore: avoid_types_as_parameter_names
      return value.any((num) => entidad.permisos.contains(num));
    }
    return false;
  }
  
  /*Future<bool> enviarWppPdf(BuildContext context, String telefono, String msj) async {
    try {
      final response = await http.post(
        Uri.parse('http://net.vientri.com:3004/whatsapp/sendmessage'),
        headers: {
          'x-access-token': entidad.token,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "phoneNumber": "5493571526683",
          "message": msj,
          "filesUrl": ["C:/usr/presupuesto.pdf"],
          "contextId": "ubGbpLHy59KLPEhr"
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Msj enviado: ${response.statusCode}");
        print("Respuesta: ${response.body}");
        return true;
      } else {
        print("Error al enviar msj: ${response.statusCode}");
        print("Respuesta: ${response.body}");

        if (response.statusCode == 404) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("No se pudo cargar el control, vuelva a intentarlo"),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return false;
      }

    } catch (e) {
      return false;
    }
  }*/

  Future<String?> capturarBase64(GlobalKey key) async {
    try {
      await Future.delayed(Duration(milliseconds: 50));
      await WidgetsBinding.instance.endOfFrame;

      RenderRepaintBoundary boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;

      if (boundary.debugNeedsPaint) {
        await Future.delayed(Duration(milliseconds: 20));
        await WidgetsBinding.instance.endOfFrame;
      }

      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      final bytes = byteData?.buffer.asUint8List();

      if (bytes == null) return null;

      return base64Encode(bytes);

    } catch (e) {
      print("Error al capturar: $e");
      return null;
    }
  }

  Future<bool> enviarWpp2(String contextId, String telefono, String msj) async {
    try {
      final response = await http.post(
        Uri.parse('$url2/whatsapp/sendmessage'),
        headers: {
          'x-access-token': entidad.token,
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          "contextId": contextId,
          "phoneNumber": telefono,
          "message": msj,
          "filesUrl": []
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;

    } catch (e) {
      print("Error al enviar: $e");
      return false;
    }
  }




  // TIQUETERA
  Future<List<Tique>> listaTiques(int page) async {
    try {
      final response = await http.get(
        Uri.parse("$url2/api/v1/tiques?page=$page"),
        headers: {
          "x-access-token": entidad.token,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List tiquesJson = data["resultados"];
        return tiquesJson.map((e) => Tique.fromJson(e)).toList();
      } else {
        throw Exception("Error al obtener tiques");
      }
    } catch (e) {
      throw Exception("Error al obtener tiques: $e");
    }
  }

  Future<TiqueDetalle> detalleTique(int idTique) async {
    print("$url2/api/v1/tiques/$idTique");
    try {
      final response = await http.get(
        Uri.parse("$url2/api/v1/tiques/$idTique"),
        headers: {
          "x-access-token": entidad.token,
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final dynamic tiqueJson = data["data"];
        return TiqueDetalle.fromJson(tiqueJson);
      } else {
        throw Exception("Error al obtener el detalle del tique");
      }
    } catch (e) {
      throw Exception("Error al obtener el detalle del tique: $e");
    }
  }

  Future<bool> cambiarUsuarioEncargadoTique(int idTique, int idUsrVientri) async {
    /// 3 VIENTRI
    /// 7 LEO
    /// 10 HERNAN
    try {
      final response = await http.put(
        Uri.parse('$url2/api/v1/$idTique/tiques'),
        headers: {
          'x-access-token': entidad.token,
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          "idUsrVientri": idUsrVientri,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;

    } catch (e) {
      print("Error al enviar: $e");
      return false;
    }
  }

  Future<List<TiqueMensaje>> listaMensajesTique(int idTique) async {
    try {
      final response = await http.post(
        Uri.parse("$url2/viapicom/tique/obtenerChat"),
        headers: {
          "x-access-token": entidad.token,
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          "idTique": idTique
        })
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List tiquesJson = data["resultados"];
        return tiquesJson.map((e) => TiqueMensaje.fromJson(e)).toList();
      } else {
        throw Exception("Error al obtener mensajes");
      }
    } catch (e) {
      throw Exception("Error al obtener mensajes: $e");
    }
  }

  Future<List<Opcion>> listaRtasRapidas() async {
    try {
      final response = await http.get(
        Uri.parse('$url2/api/v1/respuestas'),
        headers: {
          'x-access-token': entidad.token,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        List<Opcion> opciones = (data['resultados'] as List)
        .map((item) => Opcion(
          id: item['id'],
          nombre: item['descripcion'],
        )).toList();
        return opciones;
      } else {
        return [];
      }
    } catch (e) {
      print("Error al listar respuestas rapidas: $e");
      return [];
    }
  }
  
  // cierra tique
  Future<bool> responderTique(int idTique, int idRespuesta, String contextId, String telefono, String msj, String tiempoResolucion, int idUsuarioVientriAsignado, int idUsuarioVientriElegido, int idUsuarioVientriActual) async {
    try {
      final response = await http.post(
        Uri.parse('$url2/viapicom/tique/responder'),
        headers: {
          'x-access-token': entidad.token,
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          "idTique": idTique,
          "idRespuesta": idRespuesta,
          "tiempoResolucion": tiempoResolucion,
          "idUsuarioVientriAsignado": idUsuarioVientriAsignado,
          "idUsuarioVientriElegido": idUsuarioVientriElegido,
          "idUsuarioVientriActual": idUsuarioVientriActual
        }),
      );

      if(response.statusCode == 200 || response.statusCode == 201) {
        return await enviarWpp2(contextId, telefono, msj);
      }
      return false;

    } catch (e) {
      print("Error al enviar: $e");
      return false;
    }
  }
  
  // manda msj simple
  Future<bool> enviarMensajeTique(int idTique, String msj) async {
    try {
      final response = await http.post(
        Uri.parse('$url2/viapicom/tique/chat'),
        headers: {
          'x-access-token': entidad.token,
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          "idTique": idTique,
          "texto": msj
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;

    } catch (e) {
      print("Error al enviar: $e");
      return false;
    }
  }
  
  // manda resumen con audio
  Future<Map<String, dynamic>> enviarResumenAudioTique(
    int idTique,
    String resumen,
    String usuario,
    String adjunto,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$url2/api/v1/tiques/$idTique/crearMensaje'),
        headers: {
          'x-access-token': entidad.token,
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          "mensaje": resumen,
          "usuario": usuario.trim(),
          "adjunto": adjunto
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }

      return {
        "success": false,
        "message": "Error HTTP ${response.statusCode}"
      };
    } catch (e) {
      return {
        "success": false,
        "message": e.toString()
      };
    }
  }
  
  // adjunta archivo audio a un msj
  Future<Map<String, dynamic>> adjuntarArchivoMsj(
    int idMsj,
    String base64,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$url2/api/v1/tiques/$idMsj/adjuntarArchivo'),
        headers: {
          'x-access-token': entidad.token,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "adjunto": base64,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {

        return jsonDecode(response.body);
      }

      return {
        "success": false,
        "message": "Error HTTP ${response.statusCode}",
      };
    } catch (e) {
      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }
  
  Future<String> obtenerAudioMensaje(int idMsj) async {
    try {
      final response = await http.get(
        Uri.parse('$url2/api/v1/tiques/chat/$idMsj'),
        headers: {
          'x-access-token': entidad.token,
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (jsonDecode(response.body)["data"] != null) {
          final data = jsonDecode(response.body)["data"]["ADJUNTO"];
          return data;
        }
        print("Error al consultar el audio $idMsj");
        return "";
      }
      print("Error al consultar el audioo $idMsj");
      return "";
    } catch (e) {
      print("Error al enviar: $e");
      return "";
    }
  }
  
  Future<bool> editarAgregarTelefono(String telefono, int idUsr, int idBaseDatos) async {
    try {
      final response = await http.post(
        Uri.parse('$url2/api/v1/tiques/actualizar-telefono'),
        headers: {
          'x-access-token': entidad.token,
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          "nroTelefono": telefono,
          "idUsr": idUsr,
          "idBaseDatos": idBaseDatos,
          "debug": false
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;

    } catch (e) {
      print("Error al enviar: $e");
      return false;
    }
  }
  
  Future<String> base64ToText(String base64Audio) async {
    try {
      final response = await http.post(
        Uri.parse('http://net.vientri.com:3004/whatsapp/transcribe'),
        headers: {
          'x-access-token': entidad.token,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "audio": base64Audio,
          "mimeType": "audio/aac",
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data["data"]["transcription"] ?? "";
      } else {
        print("Error transcribiendo: ${response.body}");
        return "";
      }
    } catch (e) {
      print("Error transcribirAudio(): $e");
      return "";
    }
  }
  
  // validar si existe nro wpp
  Future<bool> validarNroWpp(String numero) async {
    try {
      final response = await http.post(
        kIsWeb ? Uri.parse("https://net.vientri.com:3004/whatsapp/checknumber") : Uri.parse('$url2/whatsapp/checknumber'),
        headers: {
          'x-access-token': entidad.token,
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          "phoneNumber": numero,
          "contextId": "WeCvYG4AaBKrYUnP"
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (jsonDecode(response.body)["data"]["exists"] == true) {
          return true;
        } else {
          return false;
        }
      }
      return false;
    } catch (e) {
      print("Error al enviar: $e");
      return false;
    }
  }
  
  Future<String> asignarContextId(String usuario) async {
    if (usuario.trim().toUpperCase() == "LEO") {
      return "AVFg37bNhyymWwN2";
    } else if (usuario.toUpperCase().contains("HERNAN")) {
      return "zdzBHN6uOn1lpWzn";
    } else {
      return "Z3okwRGFLmFXsS3b";
    }
  }
  // FIN TIQUETERA





  // REMITOS DEVOLUCION
  Future<List<RemitoDevolucion>> listaRemitosDevolucion(int page) async {
    try {
      final response = await http.get(
        Uri.parse("$url/api/v1/comprobantes/remitos-devolucion?page=$page"),
        headers: {
          "x-access-token": entidad.token,
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List remitosJson = data["data"];
        return remitosJson.map((e) => RemitoDevolucion.fromJson(e)).toList();
      } else {
        throw Exception("Error al obtener remitos de devolucion");
      }
    } catch (e) {
      throw Exception("Error al obtener remitos de devolucion: $e");
    }
  }

  Future<List<Articulo>> articulosRemitoDevolucion(int idRemito) async {
    try {
      final response = await http.get(
        Uri.parse("$url/api/v1/comprobantes/$idRemito"),
        headers: {
          "x-access-token": entidad.token,
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List articulos = data["data"]["items"];
        return articulos.map(
          (e) => Articulo(
            id: e["ID"],
            articuloId: e["IDART"],
            articuloDes: e["DES"].trim(),
            articuloCod: e["COD"].trim(),
            impoconiva: e["TOTAL"],
            stk: 0,
            rubroId: 0,
            rubroDes: "",
            cantidad: e["CANTIDAD"],
            foto: "",
            cBarra: e["CBARRA"].trim()
          )
        ).toList();
      } else {
        throw Exception("Error al obtener items de devolucion");
      }
    } catch (e) {
      throw Exception("Error al obtener items de devolucion: $e");
    }
  }
  
  Future<bool> registrarCmpRemito(RemitoDevolucion remito, List<Articulo> articulos) async {
    List<Map<String, dynamic>> articulosJson = articulos.map((a) {
      return {
        "articuloId": a.id,
        "cantidad": a.cantidad,
      };
    }).toList();

    final remitoJson = {
      "fechaHora": remito.fecEmision,
      "personaId": entidad.id,
      "userId": entidad.usuarioId,
      "origen_depositoId": remito.origenId,
      "destino_depositoId": 1, // SIEMPRE VAN AL MISMO DESTINO
      "observacion": remito.observaciones,
      "idCmpOrigen": remito.idRemito,
      "idChofer": remito.choferId,
      "articulos": articulosJson,
    };

    try {
      final response = await http.post(
        kIsWeb ? Uri.parse("$url/comprobantes/remitos/nuevo") : Uri.parse('$url/comprobantes/remitos/nuevo'),
        headers: {
          'x-access-token': entidad.token,
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          "jRemito": remitoJson,
        })
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        mostrarSnackbar(esError: true, titulo: "Error", mensaje: "No se pudo registrar el remito", seconds: 3000);
        return false;
      }
    } catch (e) {
      print("Error al enviar: $e");
      mostrarSnackbar(esError: true, titulo: "Error", mensaje: "No se pudo registrar el remito", seconds: 3000);
      return false;
    }
  }

  Future<bool> enviarWppPdfCmpRemito(String contextId, String phoneNumber, String message, String pdfBase64, String id) async {
    try {
      final response = await http.post(
        kIsWeb ? Uri.parse("https://net.vientri.com:3004/whatsapp/sendmessage") : Uri.parse('$url/whatsapp/sendmessage'),
        headers: {
          'x-access-token': entidad.token,
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          "contextId": "Se02XXi4ukdxW0wk",
          "phoneNumber": "5493571526683",
          "message": message,
          "filesUrl": [ 
            {
              "base64": pdfBase64,
              "mimetype": "application/pdf",
              "filename": "Remito de devolucion-$id.pdf"
            }
          ]
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        mostrarSnackbar(esError: true, titulo: "El servicio de Envío por WhatsApp falló", mensaje: "Avise a Sistemas", seconds: 3000);
        return false;
      }
    } catch (e) {
      print("Error al enviar: $e");
      return false;
    }
  }
  // FIN REMITOS DEVOLUCION






  // ORDENES DE ENTREGA
  Future<List<OrdenEntrega>> listaOrdenesEntrega(int page, int idSalon) async {
    try {
      print("$url/api/v1/comprobantes/ordenes-de-entrega?page=$page&idSalon=$idSalon");
      final response = await http.get(
        kIsWeb 
        ? Uri.parse("$url/api/v1/comprobantes/ordenes-de-entrega?page=$page&idSalon=$idSalon") 
        : Uri.parse("$url/api/v1/comprobantes/ordenes-de-entrega?page=$page&idSalon=$idSalon"),
        headers: {
          "x-access-token": entidad.token,
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List ordenes = data["data"];
        return ordenes.map((e) => OrdenEntrega.fromJson(e)).toList();
      } else {
        throw Exception("Error al obtener ordenes pendientes");
      }
    } catch (e) {
      throw Exception("Error al obtener ordenes pendientes: $e");
    }
  }

  Future<List<RemitoEntrega>> listaRemitosEntregados(int page, int idSalon) async {
    try {
      print("${entidad.urlVientriHttp}/api/v1/comprobantes/remitos-entregados?page=$page&idSalon=$idSalon");
      final response = await http.get(
        kIsWeb 
        ? Uri.parse("${entidad.urlVientriHttp}/api/v1/comprobantes/remitos-entregados?page=$page&idSalon=$idSalon") 
        : Uri.parse("${entidad.urlVientriHttp}/api/v1/comprobantes/remitos-entregados?page=$page&idSalon=$idSalon"),
        headers: {
          "x-access-token": entidad.token,
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List ordenes = data["data"];
        return ordenes.map((e) => RemitoEntrega.fromJson(e)).toList();
      } else {
        throw Exception("Error al obtener ordenes pendientes");
      }
    } catch (e) {
      throw Exception("Error al obtener ordenes pendientes: $e");
    }
  }

  Future<List<Articulo>> articulosOrdenEntrega(int id) async {
    try {
      final response = await http.post(
        Uri.parse("${entidad.urlVientri}/viapiGestion/comprobantes/consulta"),
        headers: {
          "x-access-token": entidad.token,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "idComprobante": id,
          "web": 1
        })
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List articulos = data["items"];
        return articulos.map(
          (e) => Articulo(
            id: e["ID"],
            articuloId: e["IDART"],
            articuloDes: e["DES"].trim(),
            articuloCod: e["COD"].trim(),
            impoconiva: e["TOTAL"],
            stk: 0,
            rubroId: 0,
            rubroDes: "",
            cantidad: e["CANTIDAD"],
            foto: "",
            cBarra: e["CBARRA"].trim()
          )
        ).toList();
      } else {
        throw Exception("Error al obtener articulos");
      }
    } catch (e) {
      throw Exception("Error al obtener articulos: $e");
    }
  }
 
  Future<bool> cambioEstadoOrdenEntrega(int idCmp, int idEstado, int idPer) async {
    final fecha = DateFormat("yyyy-MM-ddTHH:mm:ss").format(DateTime.now());

    dynamic body = jsonEncode({
      "idCmpestado": idEstado,
      "IDPER_PROVEEDOR": idPer,
      "FEC_ESTADO": fecha
    });

    if (idEstado == 5) {
      body = jsonEncode({
        "IDSUBESTADO": idEstado,
      }); 
    }

    try {
      final response = await http.put(
        Uri.parse("${entidad.urlVientriHttp}/api/v1/comprobantes/$idCmp"),
        headers: {
          'x-access-token': entidad.token,
          'Content-Type': 'application/json',
        },
        body: body
      );
      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        mostrarSnackbar(esError: true, titulo: "Error", mensaje: "No se pudo cambiar el estado de la orden", seconds: 3000);
        return false;
      }
    } catch (e) {
      print("Error al enviar: $e");
      mostrarSnackbar(esError: true, titulo: "Error", mensaje: "No se pudo cambiar el estado de la orden", seconds: 3000);
      return false;
    }
  }


  Future<bool> registrarOrdenPreparacion(OrdenEntrega orden, List<Articulo> articulos) async {
    List<Map<String, dynamic>> articulosJson = articulos.map((a) {
      return {
        "articuloId": a.id,
        "cantidad": a.cantidad,
      };
    }).toList();

    final remitoMap = {
      "fechaHora": orden.fechaFactura,
      "personaId": entidad.id,
      "userId": entidad.usuarioId,
      "idCmpOrigen": orden.idFactura,
      "observacion": "",
      "origen_depositoId": "",
      "destino_depositoId": 22,
      "articulos": articulosJson,
    };

    final String remitoJsonString = jsonEncode(remitoMap);
    try {
      final response = await http.post(
        Uri.parse("$url/comprobantes/generar-orden-de-preparacion"),
        headers: {
          'x-access-token': entidad.token,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "jRemito": remitoJsonString,
        })
      );
      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        mostrarSnackbar(esError: true, titulo: "Error", mensaje: "No se pudo registrar la orden de preparacion", seconds: 3000);
        return false;
      }
    } catch (e) {
      print("Error al enviar: $e");
      mostrarSnackbar(esError: true, titulo: "Error", mensaje: "No se pudo registrar el remito", seconds: 3000);
      return false;
    }
  }
  // FIN ORDENES DE ENTREGA




  // CHAT IA
  Future<bool> enviarWpp(BuildContext context, String telefono, String msj, String img, String pathArchivo) async {
    try {
      final response = await http.post(
        kIsWeb ? Uri.parse("https://net.vientri.com:3004/whatsapp/sendmessage") : Uri.parse('$url2/whatsapp/sendmessage'),
        headers: {
          'x-access-token': entidad.token,
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          "contextId": "nvv1uqRNvqGHaGQ0",
          "phoneNumber": "5493571526683",//telefono,
          "message": msj,
          "filesUrl": []
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;

    } catch (e) {
      print("Error al enviar: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>> enviarMsjBackend() async {
    try {
      final response = await http.post(
        Uri.parse('$url/wa/v1/procesar'),
        headers: {
          'x-access-token': entidad.token,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "data": "99999 ARTICULOS",
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("HOLAAA");
        return jsonDecode(response.body);
      }

      return {};
    } catch (e) {
      print("Error al enviar: $e");
      return {};
    }
  }

  Future<String> transcribirAudio(String pathAudio) async {
    try {
      final bytes = await File(pathAudio).readAsBytes();
      final base64Audio = base64Encode(bytes);

      final response = await http.post(
        Uri.parse('https://net.vientri.com:3004/whatsapp/transcribe'),
        headers: {
          'x-access-token': entidad.token,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "audio": base64Audio,
          "mimeType": "audio/aac",
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data["data"]["transcription"] ?? "";
      } else {
        print("Error transcribiendo: ${response.body}");
        return "";
      }
    } catch (e) {
      print("Error transcribirAudio(): $e");
      return "";
    }
  }
  
  Future<String> generarResumenIaAudio(String transcripcion) async {
    try {
      final response = await http.post(
        Uri.parse('https://net.vientri.com:3007/generar-prompts'),
        headers: {
          'x-access-token': entidad.token,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
            "query": transcripcion,
            "promptId": 7,
            "provider": "perplexity"
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data["resultado"] ?? "";
      } else {
        return "Error en generar resumen";
      }
    } catch (e) {
      return "Error en generar resumen: $e";
    }
  }
  // FIN CHAT IA





  // TRASLADOS
  String getFechaActual() {
    final now = DateTime.now();
    final formato = DateFormat('yyyy-MM-dd HH:mm');
    return formato.format(now);
  }

  // ARREGLAR QUE OBSERVACION ENVIAMOS ACA SI DE EMISOR O RECEPTOR
  Future<bool> registrarTraslado(Envio envio) async {
    String fechaActual = getFechaActual();
    try {
      final jRemito = {
        "fechaHora": fechaActual,
        "userId": entidad.usuarioId,
        "origen_depositoId": envio.origenId,
        "destino_depositoId": envio.destinoId,
        "personaId": envio.choferId,
        "observacion": envio.observacionEmisor,
        "articulos": envio.articulos
          .map((a) => {
                "e[]": a.articuloId,
                "cantidad": a.cantidad,
              })
          .toList()
      };

      final response = await http.post(
        Uri.parse('$url/comprobantes/remitos/nuevo'),
        headers: {
          'x-access-token': entidad.token,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          "jRemito": jsonEncode(jRemito),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data["remitoId"] > 0 ) {
          return true;
        } else {
          return false;
        }
      } else {
        print("ERROR: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print("ERROR: $e");
      return false;
    }
  }

  Future<bool> editarTraslado(Envio envio) async {
    String fechaActual = getFechaActual();
    try {
      final jRemito = {
        "remitoId": envio.id,
        "fechaHora": fechaActual,
        "userId": entidad.usuarioId,
        "origen_depositoId": envio.origenId,
        "destino_depositoId": envio.destinoId,
        "personaId": envio.choferId,
        "observacion": envio.observacionEmisor,
        "articulos": envio.articulos
          .map((a) => {
            "id": a.id,
            "articuloId": a.articuloId,
            "cantidad": a.cantidad,
          })
          .toList()
      };

      final response = await http.post(
        Uri.parse('$url/comprobantes/remitos/actualiza'),
        headers: {
          'x-access-token': entidad.token,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          "jRemito": jsonEncode(jRemito),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data["remitoId"] > 0 ) {
          return true;
        } else {
          return false;
        }
      } else {
        print("ERROR: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print("ERROR: $e");
      return false;
    }
  }

  Future<List<Envio>> listaTraslados() async {
    try {
      final response = await http.post(
        Uri.parse("$url/comprobantes/remitos/lista"),
        headers: {
          "x-access-token": entidad.token,
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final remitos = data["remitos"] as List<dynamic>;
        return remitos.map((r) {
          final fechaHora = DateTime.parse(r["fecha"]);

          return Envio(
            id: r["id"],
            estadoId: r["estadoId"],
            estadoName: r["estadoName"],
            emisor: data["emisor"] ?? "",
            emisorId: data["emisorId"] ?? -1,
            receptor: data["receptor"] ?? "",
            receptorId: data["receptorId"] ?? -1,
            origen: r["origenName"],
            origenId: r["origenId"],
            destino: r["destinoName"],
            destinoId: r["destinoId"],
            chofer: "",
            choferId: -1,
            cantidad: r["cantidad"],
            hora: "${fechaHora.hour.toString().padLeft(2, '0')}:${fechaHora.minute.toString().padLeft(2, '0')}",
            observacionEmisor: r["observacion"] ?? "", // cambiar a observacion emisor
            observacionReceptor: r["observacion"] ?? "", // cambiar a observacion receptor
            fecha: "${fechaHora.year}-${fechaHora.month.toString().padLeft(2, '0')}-${fechaHora.day.toString().padLeft(2, '0')}",
            articulos: [],
          );
        }).toList();
      } else {
        throw Exception("Error al obtener remitos");
      }
    } catch (e) {
      throw Exception("Error al obtener remitos: $e");
    }
  }

  Future<Envio> detalleTraslado(BuildContext context, int id) async {
    try {
      final response = await http.post(
        Uri.parse('$url/comprobantes/remitos/consulta'),
        headers: {
          'x-access-token': entidad.token,
        },
        body: {
          'remitoId': id.toString(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        final fechaHora = DateTime.parse(data["fecha"]);

        final List<dynamic> detalleJson = data["detalle"] ?? [];
        final List<Articulo> articulos = detalleJson.map((item) {
          return Articulo(
            id: item["id"] ?? 0,
            articuloId: item["articuloId"] ?? 0,
            articuloDes: item["articuloName"] ?? "",
            rubroDes: item["rubroDes"] ?? "",
            rubroId: item["rubroId"] ?? 0,
            articuloCod: item["articuloCod"].toString().trim(),
            impoconiva: 0,
            stk: 0,
            cantidad: item["cantidad"] ?? 0,
            foto: "",
            cBarra: ""
          );
        }).toList();

        return Envio(
          id: data["remitoId"] ?? 0,
          estadoId: data["estadoId"] ?? 0,
          estadoName: data["estadoName"] ?? "",
          emisor: data["emisor"] ?? "",
          emisorId: data["emisorId"] ?? -1,
          receptor: data["receptor"] ?? "",
          receptorId: data["receptorId"] ?? -1,
          origen: data["origenName"] ?? "",
          origenId: data["origenId"] ?? 0,
          destino: data["destinoName"] ?? "",
          destinoId: data["destinoId"] ?? 0,
          chofer: data["responsableName"] ?? "",
          choferId: data["responsableId"] ?? 0,
          cantidad: detalleJson.fold<int>(0, (sum, item) => sum + (item["cantidad"] as int)),
          hora: "${fechaHora.hour.toString().padLeft(2, '0')}:${fechaHora.minute.toString().padLeft(2, '0')}",
          observacionEmisor: data["observacion"] ?? "",
          observacionReceptor: data["observacionEstado"] ?? "",
          fecha: "${fechaHora.year}-${fechaHora.month.toString().padLeft(2, '0')}-${fechaHora.day.toString().padLeft(2, '0')}",
          articulos: articulos,
        );
      } else {
        if (response.statusCode == 404) {
          if (!context.mounted) {
            throw Exception("Widget no montado, no se puede mostrar SnackBar");
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Error, no se pudo obtener los items del traslado"),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 6),
            ),
          );

        }
        throw Exception("Error al obtener Envio: ");
      }
    } catch (e) {
      if (!context.mounted) {
        throw Exception("Widget no montado, no se puede mostrar SnackBar");
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error, no se pudo obtener los items del traslado"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 6),
        ),
      );
      throw Exception("Error al obtener Envio: $e");
    }
  }

  Future<bool> cambioEstadoTraslado(int id, int estadoId, String observacion) async {
    try {
      final response = await http.post(
        Uri.parse('$url/comprobantes/remitos/estado'),
        headers: {
          'x-access-token': entidad.token,
        },
        body: {
          'remitoId': id.toString(),
          'estadoId': estadoId.toString(),
          'observacion': observacion
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (int.parse(data["remitoId"]) > 0 ) {
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> eliminarTraslado(String id) async {
    try {
      final response = await http.post(
        Uri.parse('$url/comprobantes/remitos/elimina'),
        headers: {
          'x-access-token': entidad.token,
        },
        body: {
          "remitoId": id,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data != null ) {
          return true;
        } else {
          return false;
        }
      } else {
        print("ERROR: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print("ERROR: $e");
      return false;
    }
  }
  // FIN TRASLADOS




  //  CATALOGO
  String capitalizar(String texto) {
    if (texto.isEmpty) return '';
    return texto[0].toUpperCase() + texto.substring(1).toLowerCase();
  }

  Future<List<Pedido>> listaPedidos() async {
    final response = await http.post(
      Uri.parse("$url/gestionEcm/pedidos/lista"),
      headers: {
        "x-access-token": entidad.token,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      print("PEDIDOS $data");

      // Si la respuesta indica que no hay pedidos, devolvemos lista vacía
      if (data is Map && data["message"] == "No se encontraron Pedidos") {
        return [];
      }

      final pedidos = data["pedidos"] as List<dynamic>?;

      if (pedidos == null || pedidos.isEmpty) {
        return [];
      }

      return pedidos.map((p) {
        final fechaHora = DateTime.parse(p["FECHA"]);

        return Pedido(
          id: p["ID"] ?? 0,
          idUsr: p["IDUSR"] ?? 0,
          namePer: p['NAMEPER']?.trim() ?? "",
          idPer: p['IDPER'] ?? 0,
          idContactoPer: p['IDCONTACTOPER'] ?? 0,
          nameContacto: p['NAMECONTACTO']?.trim() ?? "",
          nameUsr: p['NAMEUSR']?.trim() ?? "",
          fecha:
              "${fechaHora.year}-${fechaHora.month.toString().padLeft(2, '0')}-${fechaHora.day.toString().padLeft(2, '0')}",
          estado: p['ESTADO']?.trim() ?? "",
          estadoId: p['IDESTADO'] ?? 0,
          total: p['TOTAL'] == null ? 0 : (p['TOTAL'] as num).toDouble(),
          pdto: p['PDTO'] == null ? 0 : (p['PDTO'] as num).toDouble(),
          telefono: (p['TELEFONO'] == null || p['TELEFONO'].toString().trim().isEmpty)
              ? "Sin teléfono"
              : p['TELEFONO'].toString().trim(),
          items: p['ITEMS'] ?? 0,
          detalle: [],
        );
      }).toList();
    } else {
      throw Exception("Error al obtener pedidos");
    }
  }

  Future<List<Detalle>> listaDetalles(int id) async {
    final response = await http.post(
      Uri.parse("$url/gestionEcm/pedidos/consulta"),
      headers: {
        "x-access-token": entidad.token,
      },
      body: {
        "carritoId": id.toString(),
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      List<Detalle> articulos = Detalle.fromJsonList(responseData['detalle']);
      return articulos;
    } else {
      return [];
    }
  }

  //  SI EL PEDIDO.ID = 0 CREA UN NUEVO PEDIDO Y DEVUELVE EL NUEVO ID, SINO ACTUALIZA EL PEDIDO CON ESE ID
  Future<int> actualizarPedido(BuildContext context, Entidad entidad, Pedido pedido) async {
    final ahora = DateTime.now();
    final formato = DateFormat('yyyyMMdd');
    final fechaFormateada = formato.format(ahora);

    try {
      final body = {
        "jPedido": {
          "carritoId": pedido.id,
          "fecha": pedido.fecha == "" ? fechaFormateada : pedido.fecha,
          "consumidorFinal": 0,
          "cliente": {
            "id": pedido.idPer,
            "contactoId": pedido.idContactoPer,
            "name": pedido.nameContacto != "" ? pedido.nameContacto : pedido.telefono,
            "cuit": "",
            "condicionIvaId": 1,
            "email": "",
            "localidad": "",
            "direccion": ""
          },
          "neto": pedido.total,
          "iva": 0.00,
          "noGrabado": 0.00,
          "pdto": pedido.pdto,
          "total": pedido.total
        }
      };

      print(jsonEncode(body));
      final response = await http.post(
        Uri.parse('$url/gestionEcm/carrito/actualiza'),
        headers: {
          'x-access-token': entidad.token,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      int id = 0;
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (pedido.id == 0) {
          print("SE CREO UN PEDIDO");
          print("NUEVO PEDIDO ID: ${jsonDecode(response.body)}");
        } else {
          print("SE ACTUALIZO EL CONTENIDO DEL PEDIDO: ${pedido.id}");
          print("PEDIDO ID: ${jsonDecode(response.body)}");
        }

        final decoded = jsonDecode(response.body);

        if (decoded.containsKey("carritoId") && decoded["carritoId"] != null) {
          id = int.tryParse(decoded["carritoId"].toString()) ?? 0;
        } else {
          print("No vino carritoId en la respuesta: $decoded");
        }
        return id;

      } else {
        print("Error al enviar el pedido: ${response.statusCode}");
        print("Respuesta: ${response.body}");

        if (response.statusCode == 404) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("No se pudo cargar el pedido, vuelva a intentarlo"),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }

        return id;
      }
    } catch (e) {
      print("Error en la solicitud: $e");
      return 0;
    }
  }

  Future<int> actualizarPedidoItem(BuildContext context, Entidad entidad, Pedido pedido, Detalle detalle) async {
    try {
      final body = {
        "articulo": {
          "carritoId": pedido.id,
          "articuloId": detalle.articuloId,
          "itemId": detalle.itemId,
          "cantidad": detalle.cantidad,
          "netoUnitario": detalle.unifinal,
          "alicuotaIva": 21,
          "ivaUnitario": 0.0,
          "pDescuento": detalle.pdto,
          "finalUnitario": detalle.unifinalcdto,
        }
      };

      print(jsonEncode(body));
      final response = await http.post(
        Uri.parse('$url/gestionEcm/carrito/actualizaItem'),
        headers: {
          'x-access-token': entidad.token,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      int id = 0;
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (pedido.id == 0) {
          print("SE CREO UN ARTICULO");
          print("NUEVO ARTICULO ID: ${jsonDecode(response.body)}");
        } else {
          print("SE ACTUALIZO EL CONTENIDO DEL PEDIDO: ${pedido.id}");
          print("ARTICULO ID: ${jsonDecode(response.body)}");
        }

        final decoded = jsonDecode(response.body);

        if (decoded.containsKey("itemId") && decoded["itemId"] != null) {
          id = int.tryParse(decoded["itemId"].toString()) ?? 0;
        } else {
          print("No vino itemId en la respuesta: $decoded");
        }
        return id;

      } else {
        print("Error al enviar el articulo: ${response.statusCode}");
        print("Respuesta: ${response.body}");

        if (response.statusCode == 404) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("No se pudo cargar el articulo, vuelva a intentarlo"),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }

        return id;
      }
    } catch (e) {
      print("Error en la solicitud: $e");
      return 0;
    }
  }

  Future<bool> cambiarEstadoPedido(int pedidoId, String nuevoEstado, Entidad entidad) async {
    try {
      final response = await http.post(
        Uri.parse('$url/gestionEcm/pedidos/actualizaEstado'),
        headers: {
          'x-access-token': entidad.token,
        },
        body: {
          "carritoId": "$pedidoId",
          "estado": nuevoEstado
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print("Error al cambiar el estado: ${response.statusCode}");
        print("Respuesta: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error en la solicitud cambio de estado: $e");
      return false;
    }
  }

  Future<void> eliminaPedido(Entidad entidad, int id) async {
    try {
      await http.post(
        Uri.parse('$url/gestionEcm/pedidos/elimina'),
        headers: {
          'x-access-token': entidad.token
        },
        body: {
          'carritoId': id.toString()
        }
      );
    } catch (e) {
      print("Error en eliminaPedido(): $e");
    }
  }

  void enviarMensajeWhatsApp(String numeroTelefono, String mensaje) async {
    final mensajeCodificado = Uri.encodeComponent(mensaje);

    final uri = Uri.parse(
      "https://wa.me/$numeroTelefono?text=$mensajeCodificado",
    );

    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'No se pudo abrir WhatsApp';
    }
  }

  String generarResumenPedido(List<dynamic> itemsCarrito) {
    StringBuffer buffer = StringBuffer();
    
    buffer.writeln('*RESUMEN DE TU PEDIDO*');
    buffer.writeln('*━━━━━━━━━━━━━━━━━━━━━*');
    buffer.writeln();
    
    double total = 0;
    
    for (var item in itemsCarrito) {
      String nombre = item['nombre']?.toString().trim() ?? 'Producto sin nombre';
      String descripcion = item['descripcion']?.toString().trim() ?? '';
      double precio = double.tryParse(item['precio']?.toString().replaceAll(',', '') ?? '0') ?? 0;
      int cantidad = item['cantidad'] ?? 1;
      
      double subtotal = precio * cantidad;
      total += subtotal;
      
      buffer.writeln('$cantidad $nombre x \$${formatPrice(precio)} = *\$${formatPrice(precio * cantidad)}*');
      buffer.writeln('  _${descripcion}_');
      buffer.writeln();
    }
    buffer.writeln('*━━━━━━━━━━━━━━━━━━━━━*');
    buffer.writeln('*TOTAL A PAGAR:* \$${formatPrice(total)}');
    buffer.writeln();
    
    buffer.writeln('🙏 ¡Gracias por tu compra!');
    buffer.writeln('🚚 Tu pedido será preparado pronto.');
    buffer.writeln('📞 Te contactaremos para confirmar.');
    buffer.writeln('👉 Seguí tu pedido acá:');

    return buffer.toString();
  }

  String formatPrice(double precio) {
    String parteEntera = precio.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    String parteDecimal = (precio - precio.toInt()).toStringAsFixed(2).substring(1);
    return parteEntera + parteDecimal;
  }
  //  FIN CATALOGO





  // ASIGNAR CODIGO
  Future<void> asignarCodigo(BuildContext context, int articuloId, String codigo) async {
    try {
      final response = await http.post(
        Uri.parse('$url/gestion/articulo/cBarra'),
        headers: {
          'x-access-token': entidad.token,
        },
        body: {
          "articuloId": articuloId.toString(),
          "cBarra": codigo
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {

      } else {
        print("Error al asignar el código del artículo: ${response.statusCode}");
        print("Respuesta: ${response.body}");

        if (response.statusCode == 404) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("No se pudo asignar el código al artículo, vuelva a intentarlo"),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }

      }
    } catch (e) {
      print("Error en la solicitud: $e");
    }
  }

  Future<void> asignarFoto(BuildContext context, int articuloId, String foto, int numFoto) async {
    try {
      final response = await http.post(
        Uri.parse('$url/gestion/articulo/registrarFoto'),
        headers: {
          'x-access-token': entidad.token,
        },
        body: {
          "articuloId": articuloId.toString(),
          "foto": foto,
          "orden": numFoto.toString()
        },
      );

      print("FOTO: ${response.statusCode}");
      if (response.statusCode == 200 || response.statusCode == 201) {

      } else {
        print("Error al asignar foto del artículo: ${response.statusCode}");
        print("Respuesta: ${response.body}");

        if (response.statusCode == 404) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("No se pudo asignar foto al artículo, vuelva a intentarlo"),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }

      }
    } catch (e) {
      print("Error en la solicitud: $e");
    }
  }

  Future<String?> buscarPrimeraImagenBase64(String codigoBarra) async {
    try {
      final query = Uri.encodeComponent(codigoBarra);
      final url = "https://www.google.com/search?tbm=isch&q=$query";

      final response = await http.get(Uri.parse(url), headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0 Safari/537.36',
      });

      final document = parser.parse(response.body);
      final images = document.querySelectorAll('img');
      final urls = images
          .map((img) => img.attributes['src'])
          .where((src) => src != null && src.startsWith('http'))
          .toSet()
          .take(20)
          .cast<String>()
          .toList();

      if (urls.isEmpty) return null;

      // Tomamos la primera imagen válida
      final firstImageUrl = urls.first;
      final imgResponse = await http.get(Uri.parse(firstImageUrl));

      if (imgResponse.statusCode == 200) {
        return base64Encode(imgResponse.bodyBytes);
      } else {
        return null;
      }
    } catch (e) {
      print("Error al buscar imagen automática: $e");
      return null;
    }
  }
  //  FIN ASIGNAR CODIGO




  //  AUTORIZACIONES
  Future<List<Autorizacion>> listaAutorizaciones() async {
    try {
      final response = await http.post(
        Uri.parse('$url/viapicom/autorizacion/listarPendientes'),
        headers: {
          'x-access-token': entidad.token,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final autorizaciones = data["autorizaciones"];
        
        if (autorizaciones == []) return [];
        final lista = autorizaciones is List ? autorizaciones : [autorizaciones];
        return lista.map<Autorizacion>((r) {
          return Autorizacion(
            idAutorizacion: r["idAutorizacion"],
            idTipoAutorizacion: r["idTipoAutorizacion"],
            tipoAutorizacion: r["tipoAutorizacion"],
            idCliente: r["idCliente"],
            apeNomCliente: r["apeNomCliente"],
            idUsuario: r["idUsuario"],
            apeNomUsuario: r["apeNomUsuario"],
            fecha: r["fecha"],
            detalleFecha: r["detalleFecha"],
            hora: r["hora"],
            importe: r["importe"],
            observacion: r["observacion"],
            idSalon: r["idSalon"],
            porcentaje: 0.0,
          );
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception("Error al obtener Control: $e");
    }
  }

  Future<Autorizacion> detalleAutorizacion(int id) async {
    try {
      final response = await http.post(
        Uri.parse('$url/viapicom/autorizacion/consultar'),
        headers: {
          'x-access-token': entidad.token,
        },
        body: {
          'idAutorizacion': id.toString(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Autorizacion(
          idAutorizacion: data["idAutorizacion"],
          idTipoAutorizacion: data["idTipoAutorizacion"],
          tipoAutorizacion: data["tipoAutorizacion"],
          fecha: data["fecha"],
          idCliente: data["idCliente"],
          apeNomCliente: data['apeNomCliente'],
          idUsuario: data["idUsuario"],
          apeNomUsuario: data['apeNomUsuario'],
          detalleFecha: data['detalleFecha'],
          hora: data['hora'],
          importe: double.parse(data["importe"].toString()),
          observacion: data['observacion'],
          idSalon: 0,
          porcentaje: double.parse(data["porcentaje"].toString()),
        );
      } else {
        throw Exception("Error en la API: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error al obtener autorización: $e");
    }
  }
  
  // ACCION 0 RECHAZA
  // ACCION 1 AUTORIZA
  Future<bool> autorizar(int id, int accion, double? pDto, double? impDto) async {
    try {
      final response = await http.post(
        Uri.parse('$url/viapicom/autorizacion/autorizar'),
        headers: {
          'x-access-token': entidad.token,
        },
        body: {
          "idAutorizacion": id.toString(),
          "accion": accion.toString(),
          "pDto": pDto != null ? pDto.toString() : "",
          "impDto": impDto != null ? impDto.toString() : ""
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print("Error al cambiar el estado: ${response.statusCode}");
        print("Respuesta: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error en la solicitud cambio de estado: $e");
      return false;
    }
  }
  //  FIN AUTORIZACIONES




  // PERMISOS
  void screenPermisos(
    BuildContext context,
    Entidad entidad,
    String titulo,
    int idApp, {
    VoidCallback? onReturn,
  }) {
    Navigator.of(context)
        .push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            PermisosPage(entidad: entidad, titulo: titulo, idApp: idApp),
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
    ).then((value) {
      // reinstanciás el controller si querés
      Get.delete<Controller>();
      Get.put(Controller(entidad));

      // ejecutás el callback de la pantalla
      if (onReturn != null) {
        onReturn();
      }
    });
  }

  Future<List<Acceso>> obtenerAccesos() async {
    final response = await http.get(
      Uri.parse("$url2/usuarios/accesosApp"),
      headers: {
        "x-access-token": entidad.token,
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Error al obtener accesos: ${response.statusCode}");
    }

    final jsonResponse = jsonDecode(response.body);
    final List<dynamic> accesosJson = jsonResponse["accesos"] ?? [];

    final accesos = accesosJson.map((e) => Acceso.fromJson(e)).toList();

    box.write(storageKey, jsonEncode(accesos.map((e) => e.toJson()).toList()));

    return accesos;
  }

  Future<Map<int, String>> obtenerAccesosPorApp(int appId) async {
    final accesos = await obtenerAccesos();

    final filtrados = accesos
        .where((a) => a.appId == appId)
        .map((a) => MapEntry(a.accesoId, a.accesoDes))
        .toList();
    print("permisos para app $appId: $filtrados");
    return Map.fromEntries(filtrados);
  }

  Future<void> limpiarCache() async {
    await box.remove(storageKey);
  }
  // FIN PERMISOS




  //  CONTACTOS
  String telefonoFormateado(String telefono) {
    String limpio = telefono.trim().replaceAll(" ", "").replaceFirst(RegExp(r'^\+54\s*9?\s*'), '');

    if (limpio.length < 7) return limpio;

    if (limpio.startsWith('357')) {
      if (limpio.length > 7) {
        String parte1 = limpio.substring(0, 4);
        String parte2 = limpio.length > 7 ? limpio.substring(4, 7) : limpio.substring(4);
        String parte3 = limpio.length > 7 ? limpio.substring(7) : '';
        return [parte1, parte2, parte3].where((s) => s.isNotEmpty).join(' ');
      }
    }

    String parte1 = limpio.substring(0, 3);
    String parte2 = limpio.length > 6 ? limpio.substring(3, 6) : limpio.substring(3);
    String parte3 = limpio.length > 6 ? limpio.substring(6) : '';
    return [parte1, parte2, parte3].where((s) => s.isNotEmpty).join(' ');
  }

  Future<List<Contacto>> listaContactos() async {
    try {
      final response = await http.post(
        Uri.parse('$url/gestion/contacto/lista'),
        headers: {
          'x-access-token': entidad.token,
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        List<Contacto> contactos = Contacto.fromJsonList(responseData['contactos']);

        return contactos;
      } else {
        return [];
      }
    } catch (e) {
      print("Error al buscar contactos: $e");
      return [];
    }
  }
  
  Future<bool> registrarContacto(BuildContext context, String nombre, String email, String telefono, bool nuevo) async {
    try {
      final response = await http.post(
        Uri.parse('$url/gestion/contacto/agregar'),
        headers: {
          'x-access-token': entidad.token,
        },
        body: {
          "nombre": nombre,
          "email": email,
          "telefono": telefono,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        /*final decoded = jsonDecode(response.body.toLowerCase());
        final contactoJsonString = jsonEncode(decoded["contacto"]);
        final contacto = contactoFromJson(contactoJsonString);*/
        if (nuevo) {
          NotificationHelper.showSuccess('Contacto agregado con éxito');
        } else {
          NotificationHelper.showSuccess('Contacto actualizado con éxito');
        }
        return true;
      } else {
        print("Error al registrar el contacto: ${response.statusCode}");
        print("Respuesta: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error en la solicitud: $e");
      return false;
    }
  }

  Future<Cliente?> buscarPorCuilArca(String cuil) async {
    try {
      final uri = Uri.parse(
          'http://net.vientri.com:3002/api/v1/padronafip/buscar?q=$cuil');

      final response = await http.get(
        uri,
        headers: {
          "x-access-token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTE1MSwiaWRkYiI6MTU0LCJkYiI6IlNHQV9UQU5VUyIsInJvbGVzIjoiIiwiaWF0IjoxNzY0MjUzNTYwLCJleHAiOjE3NjY4NDU1NjB9.GGpWqoh9LGO56mXAZyDZv7aEu425Ytjn7lu0FHA689I"
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body is List && body.isNotEmpty) {
          return Cliente.fromJson(body[0]);
        }
        return null;
      } else {
        print("Error AFIP: ${response.statusCode}");
      }
    } catch (e) {
      print("Error consultando AFIP: $e");
    }
    return null;
  } //20 00 56 56 42 8
  //  FIN CONTACTOS

}
