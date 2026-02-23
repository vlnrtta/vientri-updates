// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:vientri/components/action_sheet_options/action_sheet_options.dart';
import 'package:vientri/components/heading/app_heading.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/pages/comunes/master/master_principal.dart';
import 'package:vientri/pages/controller.dart';
import 'package:vientri/pages/remito_devolucion/imprimir_comprobante_remito.dart';
import 'package:vientri/src/models/articulo.dart';
import 'package:vientri/src/models/entidad.dart';
import 'package:vientri/src/models/opcion.dart';
import 'package:vientri/src/models/remitoDevolucion.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// ignore: must_be_immutable
class ComprobanteRemito extends StatefulWidget {
  Entidad entidad;
  RemitoDevolucion remitoDevolucion;
  List<Articulo> articulos;

  ComprobanteRemito({
    super.key,
    required this.entidad,
    required this.remitoDevolucion,
    required this.articulos,
  });

  @override
  State<ComprobanteRemito> createState() => _ComprobanteRemitoState();
}

class _ComprobanteRemitoState extends State<ComprobanteRemito> {
  late Controller con;
  bool _detalleArticulosAbierto = true;
  bool _infoAdicionalAbierta = true;
  String pdfBase64 = "";

  @override
  void initState() {
    super.initState();
    con = Get.put(Controller(widget.entidad));
  }

  Future<Uint8List> _buildPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (_) => [ /* contenido */ ],
      ),
    );

    return pdf.save();
  }

  Future<void> _generarPdfRemito() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            pw.Text(
              'Remito de devolución',
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 8),

            pw.Text(
              '${widget.remitoDevolucion.numeroRemito} | ID ${widget.remitoDevolucion.idRemito}',
              style: const pw.TextStyle(fontSize: 10),
            ),

            pw.Divider(),

            _pdfInfo('Chofer', widget.remitoDevolucion.chofer),
            _pdfInfo('Emisor', widget.remitoDevolucion.emisor),
            _pdfInfo(
              'Emisión',
              con.formatearFechayDia3(widget.remitoDevolucion.fecEmision!),
            ),

            pw.SizedBox(height: 16),

            pw.Text('Cliente', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(widget.remitoDevolucion.cliente),

            pw.SizedBox(height: 16),
            pw.Divider(),

            pw.Text(
              'Detalle de artículos',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),

            pw.Table(
              columnWidths: {
                0: const pw.FlexColumnWidth(4),
                1: const pw.FlexColumnWidth(1),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text('Artículo'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text('Cant.'),
                    ),
                  ],
                ),
                ...widget.articulos.map(
                  (art) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          '${con.capitalizar(art.articuloDes)}\n#${art.articuloCod}',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          art.cantidad.toString(),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ];
        },
      ),
    );

    final bytes = await pdf.save(); // ✅ AL FINAL
    pdfBase64 = base64Encode(bytes);

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => bytes,
    );
  }

  pw.Widget _pdfInfo(String label, String? value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value ?? '',
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterPage(
      title: "Remito de devolución",
      fondo: Colors.white,
      showShare: true,
      onShare: () => _abrirMenuCompartir(),
      showKey: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /*Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context, true),
                child: Icon(
                  Icons.arrow_back,
                  color: AppColors.semantics.text.action,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _abrirMenuCompartir,
                    child: Icon(
                      CupertinoIcons.share,
                      color: AppColors.semantics.text.action,
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  GestureDetector(
                    onTap: () { },
                    child: Icon(
                      FontAwesomeIcons.ellipsisVertical,
                      color: AppColors.semantics.text.action,
                      size: 22,
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),*/
          Text(
            "${widget.remitoDevolucion.numeroRemito} | ID ${widget.remitoDevolucion.idRemito} (aca debe ir el nuevo)",
            style: TextStyle(
              color: AppColors.semantics.text.secondary,
              fontSize: Fontsize.body
            ),
          ),
          const SizedBox(height: 16),
          _info("Chofer", con.capitalizarNombre(widget.remitoDevolucion.chofer ?? "")),
          _info("Emisor", con.capitalizarNombre(widget.remitoDevolucion.emisor ?? "")),
          _info("Emisión", con.formatearFechayDia3(widget.remitoDevolucion.fecEmision ?? "2026-01-01T00:00:00.000Z")),
          const SizedBox(height: 16),
          Divider(color: Colors.black12),
          const SizedBox(height: 16),
          AppHeading(
            label: "Cliente",
            fontSize: Fontsize.body
          ),
          AppHeading(
            label: widget.remitoDevolucion.cliente,
            fontSize: Fontsize.h2
          ),
          const SizedBox(height: 8),
          _info("ID", ""),
          _info("CUIT", ""),
          _info("ll.BB.", ""),
          _info("Inicio de Acts.", ""),
          _info("IVA", ""),
          const SizedBox(height: 16),
          Divider(color: Colors.black12),
          const SizedBox(height: 16),
          AppHeading(
            label: "En concepto de",
            fontSize: Fontsize.body
          ),
          AppHeading(
            label: '"Devolución de mercadería por falla"',
            fontSize: Fontsize.h2
          ),
          const SizedBox(height: 16),
          AppHeading(
            label: "Comprobante asociado",
            fontSize: Fontsize.body
          ),
          const SizedBox(height: 16),
          Material(
            child: InkWell(
              onTap: () {
                
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.remitoDevolucion.numeroRemito,
                          style: TextStyle(
                            color: AppColors.semantics.text.body,
                            fontSize: Fontsize.h3
                          ),
                        ),
                        GestureDetector(
                          onTap: () { },
                          child: Icon(
                            FontAwesomeIcons.ellipsisVertical,
                            color: AppColors.semantics.text.action,
                            size: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "ID ${widget.remitoDevolucion.idRemito}",
                      style: TextStyle(
                        color: AppColors.semantics.text.body,
                        fontSize: Fontsize.body
                      ),
                    ),
                    const SizedBox(height: 4),
                    _tablaIconos(widget.remitoDevolucion)
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.black12),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppHeading(
                  label: "Detalle de artículos",
                  fontSize: Fontsize.h2
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _detalleArticulosAbierto = !_detalleArticulosAbierto;
                  });
                },
                child: AnimatedRotation(
                  turns: _detalleArticulosAbierto ? 0 : 0.5,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    CupertinoIcons.chevron_up,
                    color: AppColors.semantics.text.action,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: widget.articulos.asMap().entries.map((entry) {
                final art = entry.value;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                con.capitalizar(art.articuloDes),
                                style: TextStyle(
                                  color: AppColors.semantics.text.body,
                                  fontSize: Fontsize.h3,
                                ),
                                maxLines: 2,
                              ),
                              Text(
                                "#${art.articuloCod}",
                                style: TextStyle(
                                  fontSize: Fontsize.body,
                                  color: AppColors.semantics.text.secondary,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            art.cantidad.toString(),
                            style: TextStyle(
                              fontSize: Fontsize.h3,
                              color: AppColors.semantics.text.body,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            crossFadeState: _detalleArticulosAbierto
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.black12),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppHeading(
                  label: "Información adicional",
                  fontSize: Fontsize.h2,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _infoAdicionalAbierta = !_infoAdicionalAbierta;
                  });
                },
                child: AnimatedRotation(
                  turns: _infoAdicionalAbierta ? 0 : 0.5,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    CupertinoIcons.chevron_up,
                    color: AppColors.semantics.text.action,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                const SizedBox(height: 16),
                _info("N° de CAE", ""),
                _info("Vencimiento", ""),
              ],
            ),
            crossFadeState: _infoAdicionalAbierta
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _info(label, text) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.semantics.text.secondary,
                fontSize: Fontsize.body
              ),
            ),
          ),
          Expanded(
            child: Text(
              text ?? "Prueba",
              style: TextStyle(
                color: AppColors.semantics.text.body,
                fontSize: Fontsize.body
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tablaIconos(RemitoDevolucion e) {
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: const {
        0: IntrinsicColumnWidth(),
        1: IntrinsicColumnWidth(),
        2: IntrinsicColumnWidth(),
        3: IntrinsicColumnWidth(),
      },
      children: [
        TableRow(
          children: [
            _cellIcon(
              Icon(FontAwesomeIcons.calendar, size: 15, color: AppColors.semantics.text.secondary),
              con.formatearFechayDia3(e.fechaRemito),
            ),

            _cellIcon(
              Icon(CupertinoIcons.person, size: 18, color: AppColors.semantics.text.secondary),
              e.cliente.trim(),
            ),

            _cellIcon(
              Icon(CupertinoIcons.cube_box, size: 18, color: AppColors.semantics.text.secondary),
              e.cantidadItems == 1 ? "${e.cantidadItems.toString()} Art." : "${e.cantidadItems.toString()} Arts.",
            ),

          ],
        ),
      ],
    );
  }

  Widget _cellIcon(Icon icon, String text, [Color? color]) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color ?? AppColors.semantics.text.secondary,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _abrirMenuCompartir() {
    ActionSheetOptions.show(
      context,
      title: "Acciones",
      options: [
        Opcion(id: 0, nombre: "Compartir por WhatsApp"),
        Opcion(id: 1, nombre: "Imprimir"),
      ],
      onOptionSelected: (s) async {
        if (s.id == 0) {
          final bytes = await _buildPdf();
          pdfBase64 = base64Encode(bytes);

          Printing.layoutPdf(onLayout: (_) async => bytes);

          _compartirPdfWpp();
        } else if (s.id == 1) {
          _generarPdfRemito();
        }
      },
    );
  }

  void _compartirPdfWpp() {
    con.mostrarSnackbar(titulo: "Error", mensaje: "El servicio de WhatsApp no se encuentra disponible", esError: true, seconds: 3000);
    //con.enviarWppPdfCmpRemito("nvv1uqRNvqGHaGQ0", "", "", pdfBase64, widget.remitoDevolucion.idRemito.toString());
  }

  void irImprimirComprobanteRemito(int accion) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ImprimirComprobanteRemito(entidad: widget.entidad, remitoDevolucion: widget.remitoDevolucion, articulos: widget.articulos, accion: accion),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

}
