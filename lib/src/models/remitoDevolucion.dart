// To parse this JSON data, do
//
//     final remitoDevolucion = remitoDevolucionFromJson(jsonString);

import 'dart:convert';

RemitoDevolucion remitoDevolucionFromJson(String str) => RemitoDevolucion.fromJson(json.decode(str));

String remitoDevolucionToJson(RemitoDevolucion data) => json.encode(data.toJson());

class RemitoDevolucion {
    int idRemito;
    String numeroRemito;
    String fechaRemito;
    String cliente;
    int idCliente;
    String vendedor;
    double total;
    String tipoComprobante;
    String estado;
    int idEstado;
    String observaciones;
    int cantidadItems;
    String? chofer;
    int? choferId;
    String? emisor;
    int? emisorId;
    String? origen;
    int? origenId;
    String? fecEmision;

    RemitoDevolucion({
        required this.idRemito,
        required this.numeroRemito,
        required this.fechaRemito,
        required this.cliente,
        required this.idCliente,
        required this.vendedor,
        required this.total,
        required this.tipoComprobante,
        required this.estado,
        required this.idEstado,
        required this.observaciones,
        required this.cantidadItems,
        this.chofer,
        this.choferId,
        this.emisor,
        this.emisorId,
        this.origen,
        this.origenId,
        this.fecEmision,
    });

    factory RemitoDevolucion.fromJson(Map<String, dynamic> json) => RemitoDevolucion(
        idRemito: json["idRemito"],
        numeroRemito: json["numeroRemito"],
        fechaRemito: json["fechaRemito"],
        cliente: json["cliente"],
        idCliente: json["idCliente"],
        vendedor: json["vendedor"],
        total: json["total"]?.toDouble(),
        tipoComprobante: json["tipoComprobante"],
        estado: json["estado"],
        idEstado: json["idEstado"],
        observaciones: json["observaciones"],
        cantidadItems: json["cantidadItems"],
        chofer: json["chofer"] ?? "",
        choferId: json["choferId"] ?? -1,
        emisor: json["emisor"] ?? "",
        emisorId: json["emisorId"] ?? -1,
        origen: json["origen"] ?? "",
        origenId: json["origenId"] ?? -1,
        fecEmision: json["fecEmision"] ?? "2026-01-01T00:00:00.000Z",
    );

    Map<String, dynamic> toJson() => {
        "idRemito": idRemito,
        "numeroRemito": numeroRemito,
        "fechaRemito": fechaRemito,
        "cliente": cliente,
        "idCliente": idCliente,
        "vendedor": vendedor,
        "total": total,
        "tipoComprobante": tipoComprobante,
        "estado": estado,
        "idEstado": idEstado,
        "observaciones": observaciones,
        "cantidadItems": cantidadItems,
        "chofer": chofer,
        "choferId": choferId,
        "emisor": emisor,
        "emisorId": emisorId,
        "origen": origen,
        "origenId": origenId,
        "fecEmision": fecEmision,
    };
}
