// To parse this JSON data, do
//
//     final contacto = contactoFromJson(jsonString);

import 'dart:convert';

Contacto contactoFromJson(String str) => Contacto.fromJson(json.decode(str));

String contactoToJson(Contacto data) => json.encode(data.toJson());

class Contacto {
    int id;
    int idPer;
    int? idArea;
    String? email;
    String telefono;
    String? horario;
    bool? ccsiempre;
    String? obs;
    bool? enviarDocumentos;
    String des;
    int? idTipoClasificacion;
    String? fecsys;
    String? fecins;
    String? nomCliente;
    String? fecha;

    Contacto({
      required this.id,
      required this.idPer,
      this.idArea,
      required this.email,
      required this.telefono,
      required this.horario,
      this.ccsiempre,
      required this.obs,
      this.enviarDocumentos,
      required this.des,
      this.idTipoClasificacion,
      required this.fecsys,
      required this.fecins,
      required this.nomCliente,
      this.fecha
    });

    factory Contacto.fromJson(Map<String, dynamic> json) => Contacto(
        id: json["id"],
        idPer: json["idper"] ?? 0,
        idArea: json["idarea"] ?? 0,
        email: json["email"],
        telefono: json["telefono"],
        horario: json["horario"],
        ccsiempre: json["ccsiempre"],
        obs: json["obs"],
        enviarDocumentos: json["enviarDocumentos"],
        des: json["des"],
        idTipoClasificacion: json["idtipoclasificacion"] ?? 0,
        fecsys: json["fecsys"],
        fecins: json["fecins"],
        nomCliente: json["nomCliente"],
        fecha: json["fecha"]
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "idper": idPer,
        "idarea": idArea,
        "email": email,
        "telefono": telefono,
        "horario": horario,
        "ccsiempre": ccsiempre,
        "obs": obs,
        "enviarDocumentos": enviarDocumentos,
        "des": des,
        "idtipoclasificacion": idTipoClasificacion,
        "fecsys": fecsys,
        "fecins": fecins,
        "nomCliente": nomCliente,
        "fecha": fecha
    };

    static List<Contacto> fromJsonList(List<dynamic> jsonList) {
      List<Contacto> toList = [];

      // ignore: avoid_function_literals_in_foreach_calls
      jsonList.forEach((item) {
        Contacto contactos = Contacto.fromJson(item);
        toList.add(contactos);
      });
      return toList;
    }

}
