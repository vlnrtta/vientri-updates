// To parse this JSON data, do
//
//     final control = controlFromJson(jsonString);

import 'dart:convert';

import 'package:vientri/src/models/articulo.dart';

Control controlFromJson(String str) => Control.fromJson(json.decode(str));

String controlToJson(Control data) => json.encode(data.toJson());

class Control {
    int id;
    String ubicacion;
    int ubicacionId;
    String usrSolicita;
    int idUsrSolicita;
    String empleado;
    int empleadoId;
    String fecha;
    String hora;
    int estadoId;
    String duracion;
    String horaIni;
    String horaFin;
    int items;
    String diferencias;
    List<Articulo> articulos;

    Control({
        required this.id,
        required this.ubicacion,
        required this.ubicacionId,
        required this.usrSolicita,
        required this.idUsrSolicita,
        required this.empleado,
        required this.empleadoId,
        required this.fecha,
        required this.hora,
        required this.estadoId,
        required this.duracion,
        required this.horaIni,
        required this.horaFin,
        required this.items,
        required this.diferencias,
        required this.articulos,
    });

    factory Control.fromJson(Map<String, dynamic> json) => Control(
        id: json["id"],
        ubicacion: json["ubicacion"],
        ubicacionId: json["ubicacionId"],
        usrSolicita: json["usrSolicita"],
        idUsrSolicita: json["idUsrSolicita"],
        empleado: json["empleado"],
        empleadoId: json["empleadoId"],
        fecha: json["fecha"],
        hora: json["hora"],
        estadoId: json["estadoId"],
        duracion: json["duracion"],
        horaIni: json["horaIni"],
        horaFin: json["horaFin"],
        items: json["items"],
        diferencias: json["diferencias"],
        articulos: List<Articulo>.from(
            json["articulos"].map((x) => Articulo.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "ubicacion": ubicacion,
        "ubicacionId": ubicacionId,
        "usrSolicita": usrSolicita,
        "idUsrSolicita": idUsrSolicita,
        "empleado": empleado,
        "empleadoId": empleadoId,
        "fecha": fecha,
        "hora": hora,
        "estadoId": estadoId,
        "duracion": duracion,
        "horaIni": horaIni,
        "horaFin": horaFin,
        "items": items,
        "diferencias": diferencias,
        "articulos": List<dynamic>.from(articulos.map((x) => x.toJson())),
    };
}
