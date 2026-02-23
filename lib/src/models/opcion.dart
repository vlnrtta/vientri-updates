// To parse this JSON data, do
//
//     final opcion = opcionFromJson(jsonString);

import 'dart:convert';

Opcion opcionFromJson(String str) => Opcion.fromJson(json.decode(str));

String opcionToJson(Opcion data) => json.encode(data.toJson());

class Opcion {
    int id;
    String nombre;
    List? permisos;

    Opcion({
        required this.id,
        required this.nombre,
        this.permisos,
    });

    factory Opcion.fromJson(Map<String, dynamic> json) => Opcion(
        id: json["id"],
        nombre: (json['apenom'] ?? '').trim(),
        permisos: json["permisos"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "nombre": nombre,
        "permisos": permisos
    };
}
