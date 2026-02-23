class Tique {
  int id;
  String asunto;
  String detalle;
  int idTipoPedido;
  String tipoPedido;
  int idEstado;
  String estado;
  int idRespuesta;
  String respuesta;
  int idUsuarioSolicitante;
  String usuarioSolicitante;
  int idUsuarioElegido;
  String usuarioElegido;
  String empresa;
  bool urgente;
  bool finalizado;
  int puntuacion;
  String? fecLimite;
  String? fecCierre;
  String? fecSys;
  String utransac;

  Tique({
    required this.id,
    required this.asunto,
    required this.detalle,
    required this.idTipoPedido,
    required this.tipoPedido,
    required this.idEstado,
    required this.estado,
    required this.idRespuesta,
    required this.respuesta,
    required this.idUsuarioSolicitante,
    required this.usuarioSolicitante,
    required this.idUsuarioElegido,
    required this.usuarioElegido,
    required this.empresa,
    required this.urgente,
    required this.finalizado,
    required this.puntuacion,
    this.fecLimite,
    this.fecCierre,
    this.fecSys,
    required this.utransac,
  });

  factory Tique.fromJson(Map<String, dynamic> json) => Tique(
        id: json["id"],
        asunto: json["asunto"] ?? "",
        detalle: json["detalle"] ?? "",
        idTipoPedido: json["idTipoPedido"],
        tipoPedido: json["tipoPedido"] ?? "",
        idEstado: json["idEstado"] ?? -1,
        estado: json["estado"] ?? "",
        idRespuesta: json["idRespuesta"] ?? 0,
        respuesta: json["respuesta"] ?? "",
        idUsuarioSolicitante: json["idUsuarioSolicitante"],
        usuarioSolicitante: json["usuarioSolicitante"] ?? "",
        idUsuarioElegido: json["idUsuarioElegido"] ?? 0,
        usuarioElegido: json["usuarioElegido"] ?? "",
        empresa: json["empresa"] ?? "",
        urgente: json["urgente"] ?? false,
        finalizado: json["finalizado"] ?? false,
        puntuacion: json["puntuacion"] ?? 0,
        fecLimite: json["fecLimite"],
        fecCierre: json["fecCierre"],
        fecSys: json["fecSys"],
        utransac: json["utransac"] ?? "",
      );
}
