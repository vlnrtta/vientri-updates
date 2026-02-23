// To parse this JSON data, do
//
//     final ordenEntrega = ordenEntregaFromJson(jsonString);

import 'dart:convert';

OrdenEntrega ordenEntregaFromJson(String str) => OrdenEntrega.fromJson(json.decode(str));

String ordenEntregaToJson(OrdenEntrega data) => json.encode(data.toJson());

class OrdenEntrega {
    int idFactura;
    String desCompleta;
    String fechaFactura;
    int idCliente;
    String cliente;
    int idVendedor;
    int idCmpEstado;
    String estadoCmp;
    int idSubEstado;
    String vendedor;
    String facturaAsociada;
    int cantidadItems;

    OrdenEntrega({
        required this.idFactura,
        required this.desCompleta,
        required this.fechaFactura,
        required this.idCliente,
        required this.cliente,
        required this.idVendedor,
        required this.idCmpEstado,
        required this.estadoCmp,
        required this.idSubEstado,
        required this.vendedor,
        required this.facturaAsociada,
        required this.cantidadItems,
    });

    factory OrdenEntrega.fromJson(Map<String, dynamic> json) => OrdenEntrega(
        idFactura: json["idFactura"],
        desCompleta: json["desCompleta"],
        fechaFactura: json["fechaFactura"],
        idCliente: json["idCliente"],
        cliente: json["cliente"],
        idVendedor: json["idVendedor"],
        idCmpEstado: json["idCmpEstado"],
        estadoCmp: json["estadoCmp"],
        idSubEstado: json["idSubEstado"],
        vendedor: json["vendedor"],
        facturaAsociada: json["facturaAsociada"],
        cantidadItems: json["cantidadItems"],
    );

    Map<String, dynamic> toJson() => {
        "idFactura": idFactura,
        "desCompleta": desCompleta,
        "fechaFactura": fechaFactura,
        "idCliente": idCliente,
        "cliente": cliente,
        "idVendedor": idVendedor,
        "idCmpEstado": idCmpEstado,
        "estadoCmp": estadoCmp,
        "idSubEstado": idSubEstado,
        "vendedor": vendedor,
        "facturaAsociada": facturaAsociada,
        "cantidadItems": cantidadItems,
    };
}
