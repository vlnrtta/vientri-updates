// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vientri/components/action_sheet/action_sheet.dart';
import 'package:vientri/components/badge/badge.dart';
import 'package:vientri/components/solid_button/solid_button.dart';
import 'package:vientri/components/subtle_button/subtle_button.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/constants/app_shadows.dart';
import 'package:vientri/pages/comunes/master/master_comprobante.dart';
import 'package:vientri/pages/controller.dart';
import 'package:vientri/src/models/articulo.dart';
import 'package:vientri/src/models/control.dart';
import 'package:vientri/src/models/entidad.dart';

// ignore: must_be_immutable
class DetalleControl extends StatefulWidget {
  Entidad entidad;
  Control control;

  DetalleControl({
    super.key,
    required this.entidad,
    required this.control,
  });

  @override
  State<DetalleControl> createState() => _DetalleControlState();
}

class _DetalleControlState extends State<DetalleControl> {
  late Controller con;
  String horaIni = "00:00";
  String horaFin = "00:00";
  String duracionFormateado = "00:00";
  late TextEditingController _controller;
  late FocusNode _focusNode;
  final GlobalKey _captureKey = GlobalKey();
  var duracion = "".obs;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    con = Get.put(Controller(widget.entidad));
    _controller = TextEditingController();
    _focusNode = FocusNode();
    cargarControl();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void cargarControl() async {
    final data = await con.detalleControl(widget.control.id);
    setState(() {
      widget.control = data;
      if (widget.control.estadoId == 10823) {
        final fechaIni = DateTime.parse(widget.control.horaIni);
        timer?.cancel();
        // Crear un nuevo timer que actualice cada segundo
        timer = Timer.periodic(const Duration(seconds: 1), (_) {
          final ahora = DateTime.now().subtract(const Duration(hours: 3));
          final diferencia = ahora.difference(fechaIni);

          final horas = diferencia.inHours.toString().padLeft(2, '0');
          final minutos = (diferencia.inMinutes % 60).toString().padLeft(2, '0');
          final segundos = (diferencia.inSeconds % 60).toString().padLeft(2, '0');

          duracion.value = horas.toString().padLeft(2, '0') != "00" 
        ? "${horas.toString().padLeft(2, '0')}:${minutos.toString().padLeft(2, '0')}:${segundos.toString().padLeft(2, '0')}"
        : "${minutos.toString().padLeft(2, '0')}:${segundos.toString().padLeft(2, '0')}";
        });
      }
      if (widget.control.estadoId == 10824) {
        final fechaIni = DateTime.parse(widget.control.horaIni);
        final fechaFin = DateTime.parse(widget.control.horaFin);
        horaIni = DateFormat('HH:mm').format(fechaIni);
        horaFin = DateFormat('HH:mm').format(fechaFin);
        final duracion = fechaFin.difference(fechaIni);
        final horas = duracion.inHours;
        final minutos = duracion.inMinutes % 60;
        final segundos = duracion.inSeconds % 60;
        duracionFormateado = horas.toString().padLeft(2, '0') != "00" 
        ? "${horas.toString().padLeft(2, '0')}:${minutos.toString().padLeft(2, '0')}:${segundos.toString().padLeft(2, '0')}"
        : "${minutos.toString().padLeft(2, '0')}:${segundos.toString().padLeft(2, '0')}";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MasterComprobante(
          title: "Recuento en ${con.capitalizar(widget.control.ubicacion)}",
          onBack: () => Navigator.pop(context, true),
          appBadge: _badgeEstado(),
          floatingButton: SolidButton(
            type: SolidButtonType.primary,
            text: "Inicio",
            onPressed: () => Navigator.pop(context),
          ),
          icon: CupertinoIcons.share,
          onIconTap: () => _escribirMsj(),
          child: Column(
            children: [
              _listaArticulos(),
              if (widget.control.estadoId == 10822)
              Padding(
                padding: const EdgeInsets.only(bottom: 30, left: 16, right: 16),
                child: _btnCancelar(),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _listaArticulos() {
    return RepaintBoundary(
      key: _captureKey,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12)
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _comprobante(),
              for (var art in widget.control.articulos)
              widget.control.estadoId == 10824 
              ? _card(art, art.cantidad - art.stk)
              : _cardSimple(art),
            ],
          ),
        )
      ),
    );
  }
  
  Widget _comprobante() {
    return Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _cabecera("Enviado", "${con.formatearFecha(widget.control.fecha)}, ${widget.control.hora}"),
                      _cabecera("Enviado por", con.capitalizarNombre(widget.control.usrSolicita)),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _cabecera(
                        (widget.control.estadoId == 10822 || widget.control.estadoId == 10824)
                          ? "Comienzo/Final"
                          : "Comienzo",
                        (widget.control.estadoId == 10822)
                          ? "--"
                          : widget.control.estadoId == 10824
                            ? "$horaIni → $horaFin ($duracionFormateado)"
                            : "",
                      ),
                      _cabecera(
                        (widget.control.estadoId == 10822 || widget.control.estadoId == 10824)
                          ? "Recontador"
                          : "Recontado por",
                        con.capitalizarNombre(widget.control.empleado),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.black12),
                ],
              ),
            ),
          ],
        ),
    );

  }

  Widget _cabecera(String label, String cab) {
    if (widget.control.estadoId == 10823 && label == "Comienzo") {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppColors.semantics.text.secondary,
                  fontSize: Fontsize.body,
                  
                ),
              ),
              const SizedBox(height: 8),
              Obx(() => Row(
                children: [
                  Text(
                    DateFormat('HH:mm').format(DateTime.parse(widget.control.horaIni)),
                    style: TextStyle(
                      color: AppColors.semantics.text.body,
                      fontSize: Fontsize.body,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "(${duracion.value})",
                    style: TextStyle(
                      color: AppColors.semantics.text.action,
                      fontSize: Fontsize.body,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )),
            ],
          ),
        )
      );
    }
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppColors.semantics.text.secondary,
                fontSize: Fontsize.body,
                
              ),
            ),
            const SizedBox(height: 8),
            Text(
              cab,
              style: TextStyle(
                color: AppColors.semantics.text.body,
                fontSize: Fontsize.body,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      )
    );
  }

  Widget _card(Articulo articulo, int diferencia) {
    return Material(
      child: Container(
        height: 90,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black12))
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Text(
                con.capitalizar(articulo.articuloDes.trim()),
                style: TextStyle(
                  color: AppColors.semantics.text.body,
                  fontSize: Fontsize.body,
                  fontWeight: FontWeight.bold
                )
              )
            ),
            Expanded(
              child: Text(
                "#${articulo.articuloCod.trim()} ${con.capitalizar(articulo.rubroDes.trim())}",
                style: TextStyle(
                  color: AppColors.semantics.text.body,
                  fontSize: Fontsize.body,
                )
              )
            ),
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.9,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _filaIconos(
                    Icon(FontAwesomeIcons.clock, size: 15, color: AppColors.semantics.text.secondary),
                    articulo.hora ?? "",
                    null
                  ),
                  _filaIconos(
                    Icon(Icons.warehouse_outlined, size: 20, color: AppColors.semantics.text.secondary),
                    articulo.stk.toString(),
                    null
                  ),
                  _filaIconos(
                    Icon(FontAwesomeIcons.clipboard, size: 15, color: AppColors.semantics.text.secondary),
                    articulo.cantidad.toString(),
                    null
                  ),
                  _filaIconos(
                    Icon((articulo.cantidad - articulo.stk) >= 0 ? FontAwesomeIcons.plus : FontAwesomeIcons.minus, size: 15, 
                      color: (articulo.cantidad - articulo.stk) == 0
                      ? AppColors.semantics.text.success
                      : (articulo.cantidad - articulo.stk) <= -10 || (articulo.cantidad - articulo.stk) >= 10
                        ? AppColors.semantics.text.error
                        : AppColors.semantics.text.warning
                    ),
                    (articulo.cantidad - articulo.stk) >= 0 ? (articulo.cantidad - articulo.stk).toString() : ((articulo.cantidad - articulo.stk) * -1).toString(),
                    (articulo.cantidad - articulo.stk) == 0
                    ? AppColors.semantics.text.success
                    : (articulo.cantidad - articulo.stk) <= -10 || (articulo.cantidad - articulo.stk) >= 10
                      ? AppColors.semantics.text.error
                      : AppColors.semantics.text.warning
                  ),
                ],
              ),
            )
          ],
        )
      ),
    );
  }

  Widget _filaIconos(Icon icon, String content, Color? color) {
    return Expanded(
      flex: 1,
      child: Row(
        children: [
          icon,
          const SizedBox(width: 8),
          Text(
            content,
            style: TextStyle(
              color: color ?? AppColors.semantics.text.secondary,
              fontSize: Fontsize.body,
            ),
          )
        ],
      )
    );
  }

  Widget _cardSimple(Articulo articulo) {
    return Material(
      child: Container(
        width: double.infinity,
        height: 70,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black12))
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                con.capitalizar(articulo.articuloDes.trim()),
                style: TextStyle(
                  color: AppColors.semantics.text.body,
                  fontSize: Fontsize.body,
                  fontWeight: FontWeight.bold
                )
              )
            ),
            Expanded(
              child: Text(
                "#${articulo.articuloCod.trim()} ${con.capitalizar(articulo.rubroDes.trim())}",
                style: TextStyle(
                  color: AppColors.semantics.text.body,
                  fontSize: Fontsize.body,
                )
              )
            ),
          ],
        )
      ),
    );
  }

  void _escribirMsj() async {
    await Future.delayed(const Duration(milliseconds: 10));
    await WidgetsBinding.instance.endOfFrame;

    final base64img = await con.capturarBase64(_captureKey);
    final base64pdf = await generarPdfDesdeBase64(base64img ?? "");
    if (base64img == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No se pudo generar la previsualización"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final tempDir = await getTemporaryDirectory();
    final path = '${tempDir.path}/preview_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File(path);

    ActionSheet.show(
      context,
      title: "Enviar comprobante",
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => Dialog(
                    backgroundColor: Colors.black26,
                    insetPadding: const EdgeInsets.all(40),
                    child: InteractiveViewer(
                      clipBehavior: Clip.none,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Image.file(file, fit: BoxFit.contain),
                      ),
                    ),
                  ),
                );
              },
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        file,
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                    ),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 100,
                        width: 100,
                        color: const Color.fromARGB(20, 0, 0, 0),
                      ),
                    ),

                    Positioned.fill(
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black26,
                          ),
                          child: Icon(Icons.fullscreen, color: Colors.white, size: 34),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ),
            const SizedBox(height: 16),

            Container(
              constraints: const BoxConstraints(maxWidth: 348.0),
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: AppColors.semantics.border.action),
                boxShadow: AppShadows.elementFocusShadow,
                color: Colors.white,
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                style: TextStyle(
                  fontSize: Fontsize.body,
                  fontWeight: FontWeight.w400,
                  color: AppColors.semantics.text.body,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.fromLTRB(16.0, 13.0, 16.0, 13.0),
                  hintText: "Escribe un mensaje...",
                  hintStyle: TextStyle(
                    fontSize: Fontsize.body,
                    color: AppColors.semantics.text.secondary,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: SubtleButton(
                    text: "Volver",
                    type: SubtleButtonType.brand,
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ),
                Expanded(
                  child: SolidButton(
                    text: "Enviar",
                    onPressed: () async {
                      Navigator.pop(context, true);
                      final texto = _controller.text.trim();

                      final enviado = await con.enviarWpp(
                        context,
                        "5493571526683",
                        texto.isEmpty ? "Sin mensaje" : texto,
                        base64pdf,
                        path,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(enviado
                              ? "Mensaje enviado"
                              : "No se pudo enviar el mensaje"),
                          backgroundColor:
                              enviado ? Colors.green : Colors.red,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    // Enfocamos el TextField automáticamente
    Future.delayed(const Duration(milliseconds: 100), () {
      _focusNode.requestFocus();
    });
  }

  Future<String> generarPdfDesdeBase64(String base64Imagen) async {
    // 1) Decodificar la imagen capturada
    Uint8List imagenBytes = base64Decode(base64Imagen);

    // 2) Crear documento PDF
    final pdf = pw.Document();

    // 3) Construir el PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(
              pw.MemoryImage(imagenBytes),
            ),
          );
        },
      ),
    );

    // 4) Obtener bytes del PDF
    Uint8List pdfBytes = await pdf.save();

    // 5) Convertir PDF a base64
    String pdfBase64 = base64Encode(pdfBytes);

    return pdfBase64;
  }

  Widget _badgeEstado() {
    return AppBadge(
      text: widget.control.estadoId == 10822
        ? con.contienePermiso(217) ? "Pendiente" : "Enviado"
        : widget.control.estadoId == 10823
          ? "En curso"
          : "Finalizado",
      type: widget.control.estadoId == 10822
        ? con.contienePermiso(217) ? AppBadgeType.warning : AppBadgeType.information
        : widget.control.estadoId == 10823
          ? AppBadgeType.action
          : AppBadgeType.success
      );
  }

  Widget _btnCancelar() {
    return SubtleButton(
      text: "Cancelar envío",
      type: SubtleButtonType.error,
      onPressed: () {
        ActionSheet.show(
          context,
          title: "¿Cancelar operación?",
          content: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Se eliminará el envío vigente.",
                  style: TextStyle(
                    color: AppColors.semantics.text.body,
                    fontSize: Fontsize.body,
                    fontWeight: FontWeight.w100,
                  ),
                ),
                const SizedBox(height: 16),
                SubtleButton(
                  text: "Volver",
                  type: SubtleButtonType.brand,
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 16),
                SubtleButton(
                  text: "Eliminar envío",
                  type: SubtleButtonType.error,
                  onPressed: () async {
                    bool ok = await con.cancelarEnvio(context, widget.control.id.toString());
                    if (ok) {
                      Navigator.pop(context, true);
                      Navigator.pop(context, true);
                    } else {
                      Navigator.pop(context, true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("No se pudo cancelar el envío, vuelva a intentarlo"),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}
