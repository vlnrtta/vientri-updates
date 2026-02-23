// To parse this JSON data, do
//
//     final cliente = clienteFromJson(jsonString);

import 'dart:convert';

Cliente clienteFromJson(String str) => Cliente.fromJson(json.decode(str));

String clienteToJson(Cliente data) => json.encode(data.toJson());

class Cliente {
    int id;
    int cuit;
    String des;
    String inscripcion;
    int idsexo;
    int idciva;
    int idtipper;
    int idiigg;
    bool empleador;
    bool intsoc;
    String catmonotributo;
    String actmonotributo;

    Cliente({
        required this.id,
        required this.cuit,
        required this.des,
        required this.inscripcion,
        required this.idsexo,
        required this.idciva,
        required this.idtipper,
        required this.idiigg,
        required this.empleador,
        required this.intsoc,
        required this.catmonotributo,
        required this.actmonotributo,
    });

    factory Cliente.fromJson(Map<String, dynamic> json) => Cliente(
        id: json["ID"],
        cuit: json["CUIT"],
        des: json["DES"],
        inscripcion: json["INSCRIPCION"],
        idsexo: json["IDSEXO"],
        idciva: json["IDCIVA"],
        idtipper: json["IDTIPPER"],
        idiigg: json["IDIIGG"],
        empleador: json["EMPLEADOR"],
        intsoc: json["INTSOC"],
        catmonotributo: json["CATMONOTRIBUTO"],
        actmonotributo: json["ACTMONOTRIBUTO"],
    );

    Map<String, dynamic> toJson() => {
        "ID": id,
        "CUIT": cuit,
        "DES": des,
        "INSCRIPCION": inscripcion,
        "IDSEXO": idsexo,
        "IDCIVA": idciva,
        "IDTIPPER": idtipper,
        "IDIIGG": idiigg,
        "EMPLEADOR": empleador,
        "INTSOC": intsoc,
        "CATMONOTRIBUTO": catmonotributo,
        "ACTMONOTRIBUTO": actmonotributo,
    };
}
