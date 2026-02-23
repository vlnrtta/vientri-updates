// To parse this JSON data, do
//
//     final autorizacion = autorizacionFromJson(jsonString);

import 'dart:convert';

Autorizacion autorizacionFromJson(String str) =>
    Autorizacion.fromJson(json.decode(str));

String autorizacionToJson(Autorizacion data) => json.encode(data.toJson());

class Autorizacion {
  int idAutorizacion;
  int idTipoAutorizacion;
  String tipoAutorizacion;
  int idCliente;
  String apeNomCliente;
  int idUsuario;
  String apeNomUsuario;
  String fecha;
  String detalleFecha;
  String hora;
  double importe;
  String observacion;
  int idSalon;
  double porcentaje;

  Autorizacion({
    required this.idAutorizacion,
    required this.idTipoAutorizacion,
    required this.tipoAutorizacion,
    required this.idCliente,
    required this.apeNomCliente,
    required this.idUsuario,
    required this.apeNomUsuario,
    required this.fecha,
    required this.detalleFecha,
    required this.hora,
    required this.importe,
    required this.observacion,
    required this.idSalon,
    required this.porcentaje,
  });

  factory Autorizacion.fromJson(Map<String, dynamic> json) => Autorizacion(
        idAutorizacion: json["idAutorizacion"],
        idTipoAutorizacion: json["idTipoAutorizacion"],
        tipoAutorizacion: json["tipoAutorizacion"],
        idCliente: json["idCliente"],
        apeNomCliente: json["apeNomCliente"],
        idUsuario: json["idUsuario"],
        apeNomUsuario: json["apeNomUsuario"],
        fecha: json["fecha"],
        detalleFecha: json["detalleFecha"],
        hora: json["hora"],
        importe: json["importe"]?.toDouble(),
        observacion: json["observacion"],
        idSalon: json["idSalon"],
        porcentaje: (json["porcentaje"] ?? 0).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "idAutorizacion": idAutorizacion,
        "idTipoAutorizacion": idTipoAutorizacion,
        "tipoAutorizacion": tipoAutorizacion,
        "idCliente": idCliente,
        "apeNomCliente": apeNomCliente,
        "idUsuario": idUsuario,
        "apeNomUsuario": apeNomUsuario,
        "fecha": fecha,
        "detalleFecha": detalleFecha,
        "hora": hora,
        "importe": importe,
        "observacion": observacion,
        "idSalon": idSalon,
        "porcentaje": porcentaje,
      };
}
