// To parse this JSON data, do
//
//     final entidad = entidadFromJson(jsonString);

import 'dart:convert';

Entidad entidadFromJson(String str) => Entidad.fromJson(json.decode(str));

String entidadToJson(Entidad data) => json.encode(data.toJson());

class Entidad {
    int id;
    String cliente;
    String nombre;
    String usuario;
    int usuarioId;
    String password;
    String token;
    int idbasededatos;
    List basededatos;
    String urlApi;
    String urlApiHttp;
    String urlVientri;
    String urlVientriHttp;
    String urlApiLocal;
    String domicilio;
    String logo;
    String ubicacion;
    int ubicacionId;
    bool esAdmin;
    String rol;
    int rolId;
    String color;
    List permisos;
    List salones;

    Entidad({
        required this.id,
        required this.cliente,
        required this.nombre,
        required this.usuario,
        required this.usuarioId,
        required this.password,
        required this.token,
        required this.idbasededatos,
        required this.basededatos,
        required this.urlApi,
        required this.urlApiHttp,
        required this.urlVientri,
        required this.urlVientriHttp,
        required this.urlApiLocal,
        required this.domicilio,
        required this.logo,
        required this.ubicacion,
        required this.ubicacionId,
        required this.esAdmin,
        required this.rol,
        required this.rolId,
        required this.color,
        required this.permisos,
        required this.salones,
    });

    factory Entidad.fromJson(Map<String, dynamic> json) => Entidad(
        id: json["id"],
        cliente: json["cliente"],
        nombre: json["nombre"],
        usuario: json["usuario"],
        usuarioId: json["usuarioId"],
        password: json["password"],
        token: json["token"],
        idbasededatos: json["idbasededatos"],
        basededatos: json["basededatos"],
        urlApi: json["urlApi"],
        urlApiHttp: json["urlApiHttp"],
        urlVientri: json["urlVientri"],
        urlVientriHttp: json["urlVientriHttp"],
        urlApiLocal: json["urlApiLocal"],
        domicilio: json["domicilio"],
        logo: json["logo"],
        ubicacion: json["ubicacion"],
        ubicacionId: json["ubicacionId"],
        esAdmin: json["esAdmin"],
        rol: json["rol"],
        rolId: json["rolId"],
        color: json["color"],
        permisos: json["permisos"],
        salones: json["salones"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "cliente": cliente,
        "nombre": nombre,
        "usuario": usuario,
        "usuarioId": usuarioId,
        "password": password,
        "token": token,
        "idbasededatos": idbasededatos,
        "basededatos": basededatos,
        "urlApi": urlApi,
        "urlApiHttp": urlApiHttp,
        "urlVientri": urlVientri,
        "urlVientriHttp": urlVientriHttp,
        "urlApiLocal": urlApiLocal,
        "domicilio": domicilio,
        "logo": logo,
        "ubicacion": ubicacion,
        "ubicacionId": ubicacionId,
        "esAdmin": esAdmin,
        "rol": rol,
        "rolId": rolId,
        "color": color,
        "permisos": permisos,
        "salones": salones,
    };

    static List<Entidad> fromJsonList(List<dynamic> jsonList) {
      List<Entidad> toList = [];

      // ignore: avoid_function_literals_in_foreach_calls
      jsonList.forEach((item) {
        Entidad entidades = Entidad.fromJson(item);
        toList.add(entidades);
      });
      return toList;
    }
}