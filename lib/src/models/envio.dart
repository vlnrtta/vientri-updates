import 'dart:convert';
import 'package:vientri/src/models/articulo.dart';


Envio envioFromJson(String str) => Envio.fromJson(json.decode(str));

String envioToJson(Envio data) => json.encode(data.toJson());

class Envio {
  int id;
  int estadoId;
  String estadoName;
  String emisor;
  int emisorId;
  String receptor;
  int receptorId;
  String origen;
  int origenId;
  String destino;
  int destinoId;
  String chofer;
  int choferId;
  int cantidad;
  String hora;
  String observacionEmisor;
  String observacionReceptor;
  String fecha;
  List<Articulo> articulos;

  Envio({
    required this.id,
    required this.estadoId,
    required this.estadoName,
    required this.emisor,
    required this.emisorId,
    required this.receptor,
    required this.receptorId,
    required this.origen,
    required this.origenId,
    required this.destino,
    required this.destinoId,
    required this.chofer,
    required this.choferId,
    required this.cantidad,
    required this.hora,
    required this.observacionEmisor,
    required this.observacionReceptor,
    required this.fecha,
    required this.articulos,
  });

  factory Envio.fromJson(Map<String, dynamic> json) => Envio(
        id: json["id"],
        estadoId: json["estadoId"],
        estadoName: json["estadoName"],
        emisor: json["emisor"],
        emisorId: json["emisorId"],
        receptor: json["receptor"],
        receptorId: json["receptorId"],
        origen: json["origen"],
        origenId: json["origenId"],
        destino: json["destino"],
        destinoId: json["destinoId"],
        chofer: json["chofer"],
        choferId: json["choferId"],
        cantidad: json["cantidad"],
        hora: json["hora"],
        observacionEmisor: json["observacionEmisor"],
        observacionReceptor: json["observacionReceptor"],
        fecha: json["fecha"],
        articulos: List<Articulo>.from(
            json["articulos"].map((x) => Articulo.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "estadoId": estadoId,
        "estadoName": estadoName,
        "emisor": emisor,
        "emisorId": emisorId,
        "receptor": receptor,
        "receptorId": receptorId,
        "origen": origen,
        "origenId": origenId,
        "destino": destino,
        "destinoId": destinoId,
        "chofer": chofer,
        "choferId": choferId,
        "cantidad": cantidad,
        "hora": hora,
        "observacionEmisor": observacionEmisor,
        "observacionReceptor": observacionReceptor,
        "fecha": fecha,
        "articulos": List<dynamic>.from(articulos.map((x) => x.toJson())),
      };
}
