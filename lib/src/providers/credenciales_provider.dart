// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:vientri/pages/controller.dart';
import 'package:vientri/src/models/entidad.dart';
import 'package:vientri/src/models/opcion.dart';
import 'package:flutter/foundation.dart';

class CredencialesProvider extends GetConnect {
  late Controller con;
  late String url;
  static bool isWeb = kIsWeb;

  CredencialesProvider() {
    if (kIsWeb) {
      url = "https://net.vientri.com:3003";
      print("Estoy en la web");
    } else {
      url = "http://net.vientri.com:3002"; 
      print("Estoy en App");
    }
  }

  // OBTIENE CREDENCIALES
  Future<Map<String, dynamic>> obtenerCredenciales(String usuario, String password) async {
    try {
      print("OBTENIENDO CREDENCIALES PARA USUARIO: $url/gestion/autoriza");
      final response = await http.post(
        Uri.parse('$url/gestion/autoriza'),
        body: {
          'name': usuario,
          'password': password,
        },
      );

      if (response.statusCode != 200) {
        return {
          'entidad': null,
          'error': '${json.decode(response.body)["message"]}',
        };
      }

      final jsonData = json.decode(response.body);

      Entidad entidad = Entidad(
        id: jsonData['usuario']['id'] ?? -1,
        cliente: jsonData['cliente'] ?? "",
        nombre: jsonData['usuario']['name']?.trim() ?? "",
        usuario: jsonData['usuario']['apeNom']?.trim() ?? "",
        usuarioId: jsonData['usuario']['idVientri'] ?? -1,
        password: password,
        token: jsonData['token'] ?? "",
        idbasededatos: jsonData['idbasededatos'],
        basededatos: jsonData['bases'],
        urlApi: jsonData['urlApi'] ?? "",
        urlApiHttp: jsonData['urlApiHttp'] ?? "",
        urlVientri: jsonData['urlVientri'] ?? "",
        urlVientriHttp: jsonData['urlVientriHttp'] ?? "",
        urlApiLocal: jsonData['urlApiLocal'] ?? "",
        domicilio: jsonData['urlDomicilio'] ?? "",
        logo: jsonData['logo'] ?? "",
        ubicacion: "",
        ubicacionId: 0,
        esAdmin: jsonData['usuario']['administrador'],
        rol: "",
        rolId: 0,
        color: jsonData['color'] ?? "",
        permisos: [],
        salones: [],
      );
      final permisosResult = await obtenerPermisos(entidad);
      if (permisosResult['error'] != null) {
        return {
          'entidad': entidad,
          'error': permisosResult['error'],
        };
      }

      entidad = permisosResult['entidad'];
      Get.delete<Controller>();
      con = Get.put(Controller(entidad));

      return {
        'entidad': entidad,
        'error': null,
      };
    } catch (e) {
      return {
        'entidad': null,
        'error': 'Error de conexión: $e',
      };
    }
  }

  // OBTIENE NUMEROS DE ACCESOS (PERMISOS)
  Future<Map<String, dynamic>> obtenerPermisos(Entidad ent) async {
    try {
      kIsWeb
        ?  print(Uri.parse('${ent.urlApi}/usuarios/consulta'))
        : ent.cliente.trim().toLowerCase() == "feyro"
          ?  print("urlApi ${Uri.parse('${ent.urlApi}/usuarios/consulta')}")
          :  print("urlApiHttp ${Uri.parse('${ent.urlApiHttp}/usuarios/consulta')}");
      final response = await http.post(
        kIsWeb
        ? Uri.parse('${ent.urlApi}/usuarios/consulta')
        : ent.cliente.trim().toLowerCase() == "feyro"
          ? Uri.parse('${ent.urlApi}/usuarios/consulta')
          : Uri.parse('${ent.urlApiHttp}/usuarios/consulta'),
        headers: {
          'x-access-token': ent.token,
        },
        body: {
          'usuarioId': ent.usuarioId.toString(),
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        return {
          'entidad': ent,
          'error': kIsWeb
            ?  'Fallo busqueda de usuario con ${ent.urlApi}/usuarios/consulta", ${response.body}'
            : ent.cliente.trim().toLowerCase() == "feyro"
              ?  'Fallo busqueda de usuario con urlApi ${ent.urlApi}/usuarios/consulta'
              :  'Fallo busqueda de usuario con urlApiHttp ${ent.urlApiHttp}/usuarios/consulta'
        };
      }
      GetStorage().remove("accesosApp${ent.usuario}");
      
      final jsonData = json.decode(response.body);
      Entidad entidad = Entidad(
        id: ent.id,
        cliente: ent.cliente,
        nombre: ent.nombre,
        usuario: ent.usuario,
        usuarioId: ent.usuarioId,
        password: ent.password,
        token: ent.token,
        idbasededatos: ent.idbasededatos,
        basededatos: ent.basededatos,
        urlApi: ent.urlApi,
        urlApiHttp: ent.urlApiHttp,
        urlVientri: ent.urlVientri,
        urlVientriHttp: ent.urlVientriHttp,
        urlApiLocal: ent.urlApiLocal,
        domicilio: ent.domicilio,
        logo: ent.logo,
        ubicacion: ent.ubicacion,
        ubicacionId: ent.ubicacionId,
        esAdmin: ent.esAdmin,
        rol: ent.rol,
        rolId: ent.rolId,
        color: ent.color,
        permisos: jsonData["accesos"], // [216, 218], //
        salones: jsonData["salones"] ?? [] // ["2 - NAVE 2", "3 - NAVE 6"] 
      );

      List<Opcion> salones = entidad.salones.map((item) {
        var parts = item.split(' - ');
        return Opcion(
          id: int.parse(parts[0]),
          nombre: parts[1],
        );
      }).toList();
      
      entidad.ubicacion = salones.isNotEmpty ? salones.first.nombre : "";
      entidad.ubicacionId = salones.isNotEmpty ? salones.first.id : 0;
      return {
        'entidad': entidad,
        'error': null,
      };
    } catch (e) {
      return {
        'entidad': ent,
        'error': kIsWeb
          ? 'Fallo busqueda de permisos con ${ent.urlApi}, $e'
          : 'Fallo busqueda de permisos con ${ent.urlApiHttp}, $e'
      };
    }
  }

}