// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:vientri/constants/notificaciones.dart';
import 'package:vientri/src/models/contacto.dart';
import 'package:vientri/src/models/entidad.dart';
import 'package:vientri/src/models/pedido.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class ContactoController extends GetxController {
  Entidad entidad;
  ContactoController(this.entidad);
  var search = ''.obs;
  var allContacts = <Contacto>[].obs;


  @override
  void onInit() {
    super.onInit();

    debounce(search, (value) {
      if (value.isNotEmpty) {
        fetchContactos(value, "", entidad);
      } else {
        allContacts.clear();
      }
    }, time: const Duration(milliseconds: 300));
  }

  List<Contacto> get filteredContacts => allContacts;

  List<Contacto> get contactosRecientes => allContacts;

  Future<void> fetchContactos(String telefono, String nombre, Entidad entidad) async {
    try {
      final response = await http.post(
        Uri.parse('${entidad.urlApi}/gestion/contacto/lista'),
        headers: {
          'x-access-token': entidad.token,
        },
        body: {
          'telefono': telefono,
          'texto': nombre
        },
      );

      if (telefono == "" && nombre == "") {
        allContacts.clear();
      } else {
        if (response.statusCode == 200 || response.statusCode == 201) {
          final responseData = jsonDecode(response.body);
          List<Contacto> contactos = Contacto.fromJsonList(responseData['contactos']);
          allContacts.assignAll(contactos);
        } else {
          allContacts.clear();
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error al buscar contactosa: $e");
      allContacts.clear();
    }
  }

  Future<void> registrarContacto(BuildContext context, String nombre, String email, String telefono, bool nuevo, Entidad entidad, Pedido pedido) async {
    Contacto contact = await registrarContacto2(nombre, email, telefono, context, nuevo, entidad);
    search.value = GetStorage().read("ultContacto${entidad.usuario}") ?? "";

    guardarContactoVisualizado(
      contact: contact,
      usuario: entidad.usuario,
      entidad: entidad
    );
    Navigator.pop(context, true);

  } 

  void enviarMensajeWhatsApp(String numeroTelefono, String mensaje) async {
    final url = Uri.parse("https://wa.me/$numeroTelefono?text=${Uri.encodeComponent(mensaje)}");

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('No se pudo abrir WhatsApp');
    }
  }

  String capitalizarNombre(String nombre) {
    return nombre
      .toLowerCase()
      .split(' ')
      .map((palabra) {
        if (palabra.isEmpty) return '';
        return palabra[0].toUpperCase() + palabra.substring(1);
      })
      .join(' ');
  }

  Future<int> detalleContacto(int id, Entidad entidad) async {
    try {
      final response = await http.post(
        Uri.parse('${entidad.urlApi}/gestion/contacto/ficha'),
        headers: {
          'x-access-token': entidad.token,
        },
        body: {
          'contactoId': id.toString()
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        int idcmpUltimo = responseData['contactos'][0]['idcmp_ultimo'];
        return idcmpUltimo;
      } else {
        return -1;
      }
    } catch (e) {
      print("Error al buscar el id: $e");
    }
      return -1;
  }

  Future<List<Map<String, dynamic>>> ultCompras(int id, Entidad entidad) async {
    try {
      final response = await http.post(
        Uri.parse('${entidad.urlApi}/comprobante/consulta'),
        headers: {
          'x-access-token': entidad.token,
        },
        body: {
          'comprobanteId': id.toString()
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final List<dynamic> detalle = responseData['detalle'];

        final List<Map<String, dynamic>> articulos = detalle.map((item) {
          return {
            "nombre": item["N_ARTICULO"]?.trim() ?? "",
            "marca": item["N_MARCA"]?.trim() ?? "",
            "id": item["ID"],
            "descripcion": item["CODIGO"]?.trim() ?? "",
            "ultimacompra": item["IMPUNI"] ?? 0.0,
            "ultimos3meses": 0,
            "ultimos6meses": 0
          };
        }).toList();

        return articulos;
      } else {
        print("Error al obtener datos: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error al buscar el comprobante: $e");
      return [];
    }
  }

  void guardarContactoVisualizado({
    required Contacto contact,
    required String usuario,
    required Entidad entidad
  }) {
    final box = GetStorage();
    DateTime ahora = DateTime.now();
    String fecha = DateFormat('dd/MM/yyyy HH:mm').format(ahora);
    String key = "visualizados$usuario";
    final rawList = box.read(key) as List?;
    List<Contacto> visualizados = rawList != null
      ? rawList.map((e) => e is Contacto ? e : Contacto.fromJson(e as Map<String, dynamic>)).toList()
      : [];

    Contacto contacto = Contacto(
      fecha: fecha,
      id: contact.id,
      idPer: contact.idPer,
      idArea: contact.idArea,
      email: contact.email,
      telefono: contact.telefono,
      horario: contact.horario,
      ccsiempre: contact.ccsiempre,
      obs: contact.obs,
      enviarDocumentos: contact.enviarDocumentos,
      des: contact.des,
      idTipoClasificacion: contact.idTipoClasificacion,
      fecsys: contact.fecsys,
      fecins: contact.fecins,
      nomCliente: contact.nomCliente
    );

    // Buscar todos los que coinciden por id
    for (int i = 0; i < visualizados.length; i++) {
      final v = visualizados[i];
      if (v.telefono == contacto.telefono) {
        visualizados[i] = contacto;
      }
    }
    fetchContactos(GetStorage().read("ultContacto$usuario"), "", entidad);
    box.write(key, visualizados.map((c) => c.toJson()).toList());
    box.write("ultContacto$usuario", contact.telefono.substring(contact.telefono.length - 4));
  }

  void eliminarContacto(int id, Entidad entidad) async {
    try {
      final response = await http.post(
        Uri.parse('${entidad.urlApi}/gestion/contacto/eliminar'),
        headers: {
          'x-access-token': entidad.token,
        },
        body: {
          'contactoId': id.toString()
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        
      } else {
        print("Error al buscar el id: $response");
      }
    } catch (e) {
      print("Error al buscar el id: $e");
    }
  }

  Future<Contacto> registrarContacto2(String nombre, String email, String telefono, BuildContext context, bool nuevo, Entidad entidad) async {
    try {
      final response = await http.post(
        Uri.parse('${entidad.urlApi}/gestion/contacto/agregar'),
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
        final decoded = jsonDecode(response.body.toLowerCase());
        final contactoJsonString = jsonEncode(decoded["contacto"]);
        final contacto = contactoFromJson(contactoJsonString);
        if (nuevo) {
          NotificationHelper.showSuccess('Contacto agregado con éxito');
        } else {
          NotificationHelper.showSuccess('Contacto actualizado con éxito');
        }
        return contacto;
      } else {
        print("Error al registrar el contacto: ${response.statusCode}");
        print("Respuesta: ${response.body}");
      }
    } catch (e) {
      print("Error en la solicitudd: $e");
    }
    return Contacto(id: 0, idPer: 0, idArea: 0, email: email, telefono: telefono, horario: "", ccsiempre: false, obs: "", enviarDocumentos: false, des: "", idTipoClasificacion: 0, fecsys: "", fecins: "", nomCliente: "");
  }


}
