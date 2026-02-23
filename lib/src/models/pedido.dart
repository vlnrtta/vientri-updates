import 'dart:convert';
String pedidoToJson(Pedido data) => json.encode(data.toJson());

class Pedido {
  int id;
  String namePer;
  int idPer;
  int idContactoPer;
  String nameContacto;
  String nameUsr;
  String estado;
  int estadoId;
  String fecha;
  double total;
  double pdto;
  String telefono;
  int idUsr;
  int items;
  List<Detalle> detalle;

  Pedido({
    required this.id,
    required this.namePer,
    required this.idPer,
    required this.idContactoPer,
    required this.nameContacto,
    required this.nameUsr,
    required this.estado,
    required this.estadoId,
    required this.fecha,
    required this.total,
    required this.pdto,
    required this.telefono,
    required this.idUsr,
    required this.items,
    required this.detalle,
  });



  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      id: json['ID'],
      namePer: json['NAMEPER']?.trim(),
      idPer: json['IDPER'],
      idContactoPer: json['IDCONTACTOPER'],
      nameContacto: json['NAMECONTACTO']?.trim(),
      nameUsr: json['NAMEUSR']?.trim(),
      estado: json['ESTADO']?.trim(),
      estadoId: json['ESTADOID'],
      fecha: json['FECHA'],
      total: json['TOTAL'] == null ? 0 : (json['TOTAL'] as num).toDouble(),
      pdto: json['PDTO'] == null ? 0 : (json['PDTO'] as num).toDouble(),
      telefono: (json['TELEFONO'] == null || json['TELEFONO'].toString().trim().isEmpty)
          ? "Sin teléfono"
          : json['TELEFONO'].toString().trim(),
      idUsr: json['IDUSR'],
      items: json['ITEMS'],
      detalle: json['detalle'] != null
          ? (json['detalle'] as List)
              .map((e) => Detalle.fromJson(e))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'NAMEPER': namePer,
      'NAMECONTACTO': nameContacto,
      'NAMEUSR': nameUsr,
      'ESTADO': estado,
      'ESTDOID': estadoId,
      'FECHA': fecha,
      'TOTAL': total,
      'PDTO': pdto,
      'TELEFONO': telefono,
      'IDUSR': idUsr,
      'ITEMS': items,
      'detalle': detalle.map((d) => d.toJson()).toList(),
    };
  }

  static List<Pedido> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((e) => Pedido.fromJson(e)).toList();
  }
}

String detalleToJson(Detalle data) => json.encode(data.toJson());

class Detalle {
  int cantidad;
  double unifinal;
  double unifinalcdto;
  double pdto;
  double total;
  int articuloId;
  int itemId;
  String articuloDes;
  String articuloCod;
  int rubroId;
  int subRubroId;
  String rubroDes;
  String subRubroDes;
  String foto;

  Detalle({
    required this.cantidad,
    required this.unifinal,
    required this.unifinalcdto,
    required this.pdto,
    required this.total,
    required this.articuloId,
    required this.itemId,
    required this.articuloDes,
    required this.articuloCod,
    required this.rubroId,
    required this.subRubroId,
    required this.rubroDes,
    required this.subRubroDes,
    required this.foto,
  });

  bool get tieneDescuento => pdto > 0;

  factory Detalle.fromJson(Map<String, dynamic> json) {
    return Detalle(
      cantidad: json['cantidad'],
      unifinal: double.parse(json['unifinal'].toString()),
      unifinalcdto: double.parse(json['unifinalcdto'].toString()),
      pdto: double.parse(json['pdto'].toString()),
      total: double.parse(json['total'].toString()),
      articuloId: json['articuloId'],
      itemId: json['itemId'],
      articuloDes: json['articuloDes']?.trim() ?? '',
      articuloCod: json['articuloCod']?.trim() ?? '',
      rubroId: json['rubroId'] ?? 0,
      subRubroId: json['subRubroId'],
      rubroDes: json['rubroDes']?.trim() ?? '',
      subRubroDes: json['subRubroDes']?.trim() ?? '',
      foto: json['foto'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    "cantidad": cantidad,
    "unifinal": unifinal,
    "unifinalcdto": unifinalcdto,
    "pdto": pdto,
    "total": total,
    "articuloId": articuloId,
    "itemId": itemId,
    "articuloDes": articuloDes,
    "articuloCod": articuloCod,
    "rubroId": rubroId,
    "subRubroId": subRubroId,
    "rubroDes": rubroDes,
    "subRubroDes": subRubroDes,
    "foto": foto,
  };


  static List<Detalle> fromJsonList(List<dynamic> jsonList) {
    List<Detalle> toList = [];

    // ignore: avoid_function_literals_in_foreach_calls
    jsonList.forEach((item) {
      Detalle articulos = Detalle.fromJson(item);
      toList.add(articulos);
    });
    return toList;
  }

}
