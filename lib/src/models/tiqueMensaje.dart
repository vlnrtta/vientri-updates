// To parse this JSON data, do
//
//     final tiqueMensaje = tiqueMensajeFromJson(jsonString);

import 'dart:convert';

TiqueMensaje tiqueMensajeFromJson(String str) => TiqueMensaje.fromJson(json.decode(str));

String tiqueMensajeToJson(TiqueMensaje data) => json.encode(data.toJson());

class TiqueMensaje {
    int id;
    int idPedido;
    String usuario;
    String mensaje;
    String fecSys;
    String adjunto;
    String? audio;

    TiqueMensaje({
        required this.id,
        required this.idPedido,
        required this.usuario,
        required this.mensaje,
        required this.fecSys,
        required this.adjunto,
        this.audio,
    });

    factory TiqueMensaje.fromJson(Map<String, dynamic> json) => TiqueMensaje(
        id: json["id"],
        idPedido: json["idPedido"],
        usuario: json["usuario"],
        mensaje: json["mensaje"],
        fecSys: json["fecSys"],
        adjunto: json["adjunto"],
        audio: json["audio"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "idPedido": idPedido,
        "usuario": usuario,
        "mensaje": mensaje,
        "fecSys": fecSys,
        "adjunto": adjunto,
        "audio": audio,
    };
}
