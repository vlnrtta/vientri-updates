// To parse this JSON data, do
//
//     final notificacion = notificacionFromJson(jsonString);

import 'dart:convert';

Notificacion notificacionFromJson(String str) => Notificacion.fromJson(json.decode(str));

String notificacionToJson(Notificacion data) => json.encode(data.toJson());

class Notificacion {
    int id;
    int tipoId;
    String tipoDes;
    String fecha;
    String hora;
    int estadoId;
    String estadoDes;
    int monto;
    int ubicacionId;
    String ubicacionDes;
    int vendedorId;
    String vendedorDes;
    int cajeroId;
    String cajeroDes;
    int clienteId;
    String clienteDes;
    String telefono;

    Notificacion({
        required this.id,
        required this.tipoId,
        required this.tipoDes,
        required this.fecha,
        required this.hora,
        required this.estadoId,
        required this.estadoDes,
        required this.monto,
        required this.ubicacionId,
        required this.ubicacionDes,
        required this.vendedorId,
        required this.vendedorDes,
        required this.cajeroId,
        required this.cajeroDes,
        required this.clienteId,
        required this.clienteDes,
        required this.telefono,
    });

    factory Notificacion.fromJson(Map<String, dynamic> json) => Notificacion(
        id: json["id"],
        tipoId: json["tipoId"],
        tipoDes: json["tipoDes"],
        fecha: json["fecha"],
        hora: json["hora"],
        estadoId: json["estadoId"],
        estadoDes: json["estadoDes"],
        monto: json["monto"],
        ubicacionId: json["ubicacionId"],
        ubicacionDes: json["ubicacionDes"],
        vendedorId: json["vendedorId"],
        vendedorDes: json["vendedorDes"],
        cajeroId: json["cajeroId"],
        cajeroDes: json["cajeroDes"],
        clienteId: json["clienteId"],
        clienteDes: json["clienteDes"],
        telefono: json["telefono"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "tipoId": tipoId,
        "tipoDes": tipoDes,
        "fecha": fecha,
        "hora": hora,
        "estadoId": estadoId,
        "estadoDes": estadoDes,
        "monto": monto,
        "ubicacionId": ubicacionId,
        "ubicacionDes": ubicacionDes,
        "vendedorId": vendedorId,
        "vendedorDes": vendedorDes,
        "cajeroId": cajeroId,
        "cajeroDes": cajeroDes,
        "clienteId": clienteId,
        "clienteDes": clienteDes,
        "telefono": telefono,
    };
}
