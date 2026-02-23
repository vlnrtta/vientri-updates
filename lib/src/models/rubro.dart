import 'dart:convert';

Rubro rubroFromJson(String str) => Rubro.fromJson(json.decode(str));

String rubroToJson(Rubro data) => json.encode(data.toJson());

class Rubro {
    String rubroDes;
    int rubroId;
    int cantidad;
    String foto;

    Rubro({
        required this.rubroDes,
        required this.rubroId,
        required this.cantidad,
        required this.foto,
    });

    factory Rubro.fromJson(Map<String, dynamic> json) => Rubro(
        rubroDes: json["rubroDes"],
        rubroId: json["rubroId"],
        cantidad: json["cantidad"],
        foto: json["foto"],
    );

    static List<Rubro> fromJsonList(List<dynamic> jsonList) {
      List<Rubro> toList = [];

      // ignore: avoid_function_literals_in_foreach_calls
      jsonList.forEach((item) {
        Rubro rubros = Rubro.fromJson(item);
        toList.add(rubros);
      });
      return toList;
    }

    Map<String, dynamic> toJson() => {
        "rubroDes": rubroDes,
        "rubroId": rubroId,
        "cantidad": cantidad,
        "foto": foto,
    };
}
