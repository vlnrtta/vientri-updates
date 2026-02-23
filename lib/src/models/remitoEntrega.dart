// To parse this JSON data, do
//
//     final remitoEntrega = remitoEntregaFromJson(jsonString);

import 'dart:convert';

RemitoEntrega remitoEntregaFromJson(String str) => RemitoEntrega.fromJson(json.decode(str));

String remitoEntregaToJson(RemitoEntrega data) => json.encode(data.toJson());

class RemitoEntrega {
    int id;
    int idtcmp;
    int idstcmp;
    int idcmpestado;
    int idper;
    int idperVen;
    String nomcmp;
    String letCmp;
    String sucCmp;
    String nroCmp;
    String fecCmp;
    String fecVto;
    int iddivisa;
    String cotizDivisa;
    String interes;
    String neto;
    String descuento;
    String iva;
    String sobretasaiva;
    String retiva;
    String periva;
    String otrper;
    String cng;
    String total;
    String obs;
    int idccosto;
    int idsubtcmp;
    int idfpgo;
    String fecsys;
    String utransac;
    int idcmpAso;
    String efecto;
    String nombrecf;
    String importependiente;
    String cliente;
    String descripcionestado;
    int cantidaditems;

    RemitoEntrega({
        required this.id,
        required this.idtcmp,
        required this.idstcmp,
        required this.idcmpestado,
        required this.idper,
        required this.idperVen,
        required this.nomcmp,
        required this.letCmp,
        required this.sucCmp,
        required this.nroCmp,
        required this.fecCmp,
        required this.fecVto,
        required this.iddivisa,
        required this.cotizDivisa,
        required this.interes,
        required this.neto,
        required this.descuento,
        required this.iva,
        required this.sobretasaiva,
        required this.retiva,
        required this.periva,
        required this.otrper,
        required this.cng,
        required this.total,
        required this.obs,
        required this.idccosto,
        required this.idsubtcmp,
        required this.idfpgo,
        required this.fecsys,
        required this.utransac,
        required this.idcmpAso,
        required this.efecto,
        required this.nombrecf,
        required this.importependiente,
        required this.cliente,
        required this.descripcionestado,
        required this.cantidaditems,
    });

    factory RemitoEntrega.fromJson(Map<String, dynamic> json) => RemitoEntrega(
        id: json["ID"],
        idtcmp: json["IDTCMP"],
        idstcmp: json["IDSTCMP"],
        idcmpestado: json["IDCMPESTADO"],
        idper: json["IDPER"],
        idperVen: json["IDPER_VEN"],
        nomcmp: json["NOMCMP"],
        letCmp: json["LET_CMP"],
        sucCmp: json["SUC_CMP"],
        nroCmp: json["NRO_CMP"],
        fecCmp: json["FEC_CMP"],
        fecVto: json["FEC_VTO"],
        iddivisa: json["IDDIVISA"],
        cotizDivisa: json["COTIZ_DIVISA"],
        interes: json["INTERES"],
        neto: json["NETO"],
        descuento: json["DESCUENTO"],
        iva: json["IVA"],
        sobretasaiva: json["SOBRETASAIVA"],
        retiva: json["RETIVA"],
        periva: json["PERIVA"],
        otrper: json["OTRPER"],
        cng: json["CNG"],
        total: json["TOTAL"],
        obs: json["OBS"],
        idccosto: json["IDCCOSTO"],
        idsubtcmp: json["IDSUBTCMP"],
        idfpgo: json["IDFPGO"],
        fecsys: json["FECSYS"],
        utransac: json["UTRANSAC"],
        idcmpAso: json["IDCMP_ASO"],
        efecto: json["EFECTO"],
        nombrecf: json["NOMBRECF"],
        importependiente: json["IMPORTEPENDIENTE"],
        cliente: json["CLIENTE"],
        descripcionestado: json["DESCRIPCIONESTADO"],
        cantidaditems: json["CANTIDADITEMS"],
    );

    Map<String, dynamic> toJson() => {
        "ID": id,
        "IDTCMP": idtcmp,
        "IDSTCMP": idstcmp,
        "IDCMPESTADO": idcmpestado,
        "IDPER": idper,
        "IDPER_VEN": idperVen,
        "NOMCMP": nomcmp,
        "LET_CMP": letCmp,
        "SUC_CMP": sucCmp,
        "NRO_CMP": nroCmp,
        "FEC_CMP": fecCmp,
        "FEC_VTO": fecVto,
        "IDDIVISA": iddivisa,
        "COTIZ_DIVISA": cotizDivisa,
        "INTERES": interes,
        "NETO": neto,
        "DESCUENTO": descuento,
        "IVA": iva,
        "SOBRETASAIVA": sobretasaiva,
        "RETIVA": retiva,
        "PERIVA": periva,
        "OTRPER": otrper,
        "CNG": cng,
        "TOTAL": total,
        "OBS": obs,
        "IDCCOSTO": idccosto,
        "IDSUBTCMP": idsubtcmp,
        "IDFPGO": idfpgo,
        "FECSYS": fecsys,
        "UTRANSAC": utransac,
        "IDCMP_ASO": idcmpAso,
        "EFECTO": efecto,
        "NOMBRECF": nombrecf,
        "IMPORTEPENDIENTE": importependiente,
        "CLIENTE": cliente,
        "DESCRIPCIONESTADO": descripcionestado,
        "CANTIDADITEMS": cantidaditems,
    };
}
