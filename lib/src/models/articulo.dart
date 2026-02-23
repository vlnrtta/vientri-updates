// To parse this JSON data, do
//
//     final articulo = articuloFromJson(jsonString);

import 'dart:convert';

Articulo articuloFromJson(String str) => Articulo.fromJson(json.decode(str));

String articuloToJson(Articulo data) => json.encode(data.toJson());

class Articulo {
    int? id;
    int articuloId;
    String articuloDes;
    String articuloCod;
    // ignore: prefer_typing_uninitialized_variables
    var impoconiva;
    String? hora;
    int stk;
    int rubroId;
    String rubroDes;
    int cantidad;
    String foto;
    String cBarra;

    Articulo({
        this.id,
        required this.articuloId,
        required this.articuloDes,
        required this.articuloCod,
        required this.impoconiva,
        this.hora,
        required this.stk,
        required this.rubroId,
        required this.rubroDes,
        required this.cantidad,
        required this.foto,
        required this.cBarra,
    });

    factory Articulo.fromJson(Map<String, dynamic> json) => Articulo(
        id: json["id"] ?? 0,
        articuloId: json["articuloId"] ?? 0,
        articuloDes: json["articuloDes"] ?? "",
        articuloCod: json["articuloCod"] ?? "",
        impoconiva: (json["impoconiva"] ?? 0.0),
        hora: json["hora"] ?? "",
        stk: json["stk"] ?? 0,
        rubroId: json["rubroId"] ?? 0,
        rubroDes: json["rubroDes"] ?? "",
        cantidad: json["cantidad"] ?? 0,
        foto: json["foto"] ?? "",
        cBarra: json["cBarra"] ?? ""
    );

    static List<Articulo> fromJsonList(List<dynamic> jsonList) {
      List<Articulo> toList = [];

      // ignore: avoid_function_literals_in_foreach_calls
      jsonList.forEach((item) {
        Articulo articulos = Articulo.fromJson(item);
        toList.add(articulos);
      });
      return toList;
    }

    Map<String, dynamic> toJson() => {
        "id": id,
        "articuloId": articuloId,
        "articuloDes": articuloDes,
        "articuloCod": articuloCod,
        "impoconiva": impoconiva,
        "hora": hora,
        "stk": stk,
        "rubroId": rubroId,
        "rubroDes": rubroDes,
        "cantidad": cantidad,
        "foto": foto,
        "cBarra": cBarra,
    };

}


