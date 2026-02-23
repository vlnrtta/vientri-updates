// To parse this JSON data, do
//
//     final tiqueDetalle = tiqueDetalleFromJson(jsonString);

import 'dart:convert';


TiqueDetalle tiqueDetalleFromJson(String str) => TiqueDetalle.fromJson(json.decode(str));

String tiqueDetalleToJson(TiqueDetalle data) => json.encode(data.toJson());

class TiqueDetalle {
    int id;
    int idbasesdedatos;
    int idusrvientriSolicito;
    int idusrvientriElegido;
    int idtipopedidovientri;
    bool urgente;
    String asunto;
    int idcmp;
    int idmn;
    int idreporte;
    int idestadovientri;
    String detalle;
    String fecLimite;
    String respuesta;
    int tiempoestimado;
    String? fecCierre;
    int idusrvientriRespondio;
    int tiempo1;
    int idusrvientriAsignado;
    int tiempo2;
    String adjuntos;
    bool finalizado;
    int puntuacion;
    String notasusuario;
    String fecsys;
    String utransac;
    String fecins;
    int versionrequerida;
    int idrespuestavientri;
    bool facil;
    int nropedido;
    int idinstructivovientri;
    dynamic fecToque;
    bool pateado;
    int idusrvientri;
    bool mastarde;
    String img;
    dynamic usointerno;
    dynamic adjunto;
    int nivelurgencia;
    Des? tipoPedido;
    Des? estado;
    Des? tiqueDetalleRespuesta;
    Des? usuarioSolicitante;
    Des? usuarioElegido;
    String empresa;

    TiqueDetalle({
        required this.id,
        required this.idbasesdedatos,
        required this.idusrvientriSolicito,
        required this.idusrvientriElegido,
        required this.idtipopedidovientri,
        required this.urgente,
        required this.asunto,
        required this.idcmp,
        required this.idmn,
        required this.idreporte,
        required this.idestadovientri,
        required this.detalle,
        required this.fecLimite,
        required this.respuesta,
        required this.tiempoestimado,
        this.fecCierre,
        required this.idusrvientriRespondio,
        required this.tiempo1,
        required this.idusrvientriAsignado,
        required this.tiempo2,
        required this.adjuntos,
        required this.finalizado,
        required this.puntuacion,
        required this.notasusuario,
        required this.fecsys,
        required this.utransac,
        required this.fecins,
        required this.versionrequerida,
        required this.idrespuestavientri,
        required this.facil,
        required this.nropedido,
        required this.idinstructivovientri,
        this.fecToque,
        required this.pateado,
        required this.idusrvientri,
        required this.mastarde,
        required this.img,
        this.usointerno,
        this.adjunto,
        required this.nivelurgencia,
        this.tipoPedido,
        this.estado,
        this.tiqueDetalleRespuesta,
        this.usuarioSolicitante,
        this.usuarioElegido,
        required this.empresa,
    });

    factory TiqueDetalle.fromJson(Map<String, dynamic> json) => TiqueDetalle(
        id: json["ID"],
        idbasesdedatos: json["IDBASESDEDATOS"],
        idusrvientriSolicito: json["IDUSRVIENTRI_SOLICITO"],
        idusrvientriElegido: json["IDUSRVIENTRI_ELEGIDO"],
        idtipopedidovientri: json["IDTIPOPEDIDOVIENTRI"],
        urgente: json["URGENTE"],
        asunto: json["ASUNTO"],
        idcmp: json["IDCMP"],
        idmn: json["IDMN"],
        idreporte: json["IDREPORTE"],
        idestadovientri: json["IDESTADOVIENTRI"] ?? -1,
        detalle: json["DETALLE"],
        fecLimite: json["FEC_LIMITE"],
        respuesta: json["RESPUESTA"],
        tiempoestimado: json["TIEMPOESTIMADO"],
        fecCierre: json["FEC_CIERRE"],
        idusrvientriRespondio: json["IDUSRVIENTRI_RESPONDIO"],
        tiempo1: json["TIEMPO1"],
        idusrvientriAsignado: json["IDUSRVIENTRI_ASIGNADO"],
        tiempo2: json["TIEMPO2"],
        adjuntos: json["ADJUNTOS"],
        finalizado: json["FINALIZADO"],
        puntuacion: json["PUNTUACION"],
        notasusuario: json["NOTASUSUARIO"],
        fecsys: json["FECSYS"],
        utransac: json["UTRANSAC"],
        fecins: json["FECINS"],
        versionrequerida: json["VERSIONREQUERIDA"],
        idrespuestavientri: json["IDRESPUESTAVIENTRI"],
        facil: json["FACIL"],
        nropedido: json["NROPEDIDO"],
        idinstructivovientri: json["IDINSTRUCTIVOVIENTRI"],
        fecToque: json["FEC_TOQUE"],
        pateado: json["PATEADO"],
        idusrvientri: json["IDUSRVIENTRI"],
        mastarde: json["MASTARDE"],
        img: json["IMG"],
        usointerno: json["USOINTERNO"],
        adjunto: json["ADJUNTO"],
        nivelurgencia: json["NIVELURGENCIA"],
        tipoPedido: Des.fromJson(json["tipoPedido"] ?? {}),
        estado: Des.fromJson(json["estado"] ?? {}),
        tiqueDetalleRespuesta: Des.fromJson(json["respuesta"] ?? {}),
        usuarioSolicitante: Des.fromJson(json["usuarioSolicitante"] ?? {}),
        usuarioElegido: Des.fromJson(json["usuarioElegido"] ?? {}),
        empresa: json["empresa"],
    );

    Map<String, dynamic> toJson() => {
        "ID": id,
        "IDBASESDEDATOS": idbasesdedatos,
        "IDUSRVIENTRI_SOLICITO": idusrvientriSolicito,
        "IDUSRVIENTRI_ELEGIDO": idusrvientriElegido,
        "IDTIPOPEDIDOVIENTRI": idtipopedidovientri,
        "URGENTE": urgente,
        "ASUNTO": asunto,
        "IDCMP": idcmp,
        "IDMN": idmn,
        "IDREPORTE": idreporte,
        "IDESTADOVIENTRI": idestadovientri,
        "DETALLE": detalle,
        "FEC_LIMITE": fecLimite,
        "RESPUESTA": respuesta,
        "TIEMPOESTIMADO": tiempoestimado,
        "FEC_CIERRE": fecCierre,
        "IDUSRVIENTRI_RESPONDIO": idusrvientriRespondio,
        "TIEMPO1": tiempo1,
        "IDUSRVIENTRI_ASIGNADO": idusrvientriAsignado,
        "TIEMPO2": tiempo2,
        "ADJUNTOS": adjuntos,
        "FINALIZADO": finalizado,
        "PUNTUACION": puntuacion,
        "NOTASUSUARIO": notasusuario,
        "FECSYS": fecsys,
        "UTRANSAC": utransac,
        "FECINS": fecins,
        "VERSIONREQUERIDA": versionrequerida,
        "IDRESPUESTAVIENTRI": idrespuestavientri,
        "FACIL": facil,
        "NROPEDIDO": nropedido,
        "IDINSTRUCTIVOVIENTRI": idinstructivovientri,
        "FEC_TOQUE": fecToque,
        "PATEADO": pateado,
        "IDUSRVIENTRI": idusrvientri,
        "MASTARDE": mastarde,
        "IMG": img,
        "USOINTERNO": usointerno,
        "ADJUNTO": adjunto,
        "NIVELURGENCIA": nivelurgencia,
        "tipoPedido": tipoPedido != null ? tipoPedido!.toJson() : "",
        "estado": estado != null ? estado!.toJson() : "",
        "respuesta": tiqueDetalleRespuesta != null ? tiqueDetalleRespuesta!.toJson() : "",
        "usuarioSolicitante": usuarioSolicitante != null ? usuarioSolicitante!.toJson() : "",
        "usuarioElegido": usuarioElegido != null ? usuarioElegido!.toJson() : "",
        "empresa": empresa,
    };
}

class Des {
    String? des;
    String? telefono;
    int? idUsr;
    int? idbasededatos;
    String? contextId;

    Des({
      this.des,
      this.telefono,
      this.idUsr,
      this.idbasededatos,
      this.contextId,
    });

    factory Des.fromJson(Map<String, dynamic> json) => Des(
        des: json["DES"] ?? "",
        telefono: json["TELEFONO"] ?? "",
        idUsr: json["IDUSR"] ?? -1,
        idbasededatos: json["IDBASESDEDATOS"] ?? -1,
        contextId: json["CONTEXTID"] ?? "",
    );

    Map<String, dynamic> toJson() => {
        "DES": des,
        "TELEFONO": telefono,
        "IDUSR": idUsr,
        "IDBASESDEDATOS": idbasededatos,
        "CONTEXTID": contextId,
    };
}
