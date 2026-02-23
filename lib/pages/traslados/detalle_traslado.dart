// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vientri/components/action_sheet/action_sheet.dart';
import 'package:vientri/components/badge/badge.dart';
import 'package:vientri/components/solid_button/solid_button.dart';
import 'package:vientri/components/subtle_button/subtle_button.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/constants/app_shadows.dart';
import 'package:vientri/pages/comunes/master/master_principal.dart';
import 'package:vientri/pages/controller.dart';
import 'package:vientri/pages/traslados/estado_traslado.dart';
import 'package:vientri/pages/traslados/nuevo_traslado.dart';
import 'package:vientri/src/models/entidad.dart';
import 'package:vientri/src/models/envio.dart';

// ignore: must_be_immutable
class DetalleTraslado extends StatefulWidget {
  Entidad entidad;
  Envio envio;

  DetalleTraslado({
    super.key,
    required this.entidad,
    required this.envio,
  });

  @override
  State<DetalleTraslado> createState() => _DetalleTrasladoState();
}

class _DetalleTrasladoState extends State<DetalleTraslado> {
  late Controller con;
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late Envio _envio;

  String formatearFecha(String fechaStr) {
    final partes = fechaStr.split('-');
    if (partes.length != 3) return fechaStr;

    final year = int.tryParse(partes[0]);
    final month = int.tryParse(partes[1]);
    final day = int.tryParse(partes[2]);
    if (year == null || month == null || day == null) return fechaStr;

    final fecha = DateTime(year, month, day);
    return DateFormat('d MMM. yyyy', 'es_ES').format(fecha);
  }

  @override
  void initState() {
    super.initState();
    con = Get.put(Controller(widget.entidad));
    _envio = widget.envio;
    cargarTraslado();
    _controller = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }


  void cargarTraslado() async {
    final data = await con.detalleTraslado(context, widget.envio.id);
    setState(() {
      _envio = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> observaciones = [
      {"tipo": "Emisor", "texto": _envio.observacionEmisor},
      {"tipo": "Receptor", "texto": _envio.observacionReceptor},
    ].where((o) => (o["texto"] ?? "").trim().isNotEmpty).toList();

    final badge = AppBadge(
      text: widget.envio.estadoId == 109
          ? "Enviado"
          : widget.envio.estadoId == 110
              ? "Recibido"
              : widget.envio.estadoId == 111
                  ? "Observado"
                  : "Sin determinar",
      type: widget.envio.estadoId == 109
          ? AppBadgeType.information
          : widget.envio.estadoId == 110
              ? AppBadgeType.success
              : widget.envio.estadoId == 111
                  ? AppBadgeType.warning
                  : AppBadgeType.action,
    );

    return MasterPage(
      title: "${con.capitalizar(_envio.origen)} → ${con.capitalizar(_envio.destino)}",
      onBack: () => Navigator.pop(context, true),
      showKey: false,
      fondo: Colors.white,
      floatingButton: _btnBottom(),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            badge,

            const SizedBox(height: 20),

            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _infoItem("Fecha", "${formatearFecha(_envio.fecha)}, ${_envio.hora}"),
                _infoItem("Chofer", con.capitalizarNombre(_envio.chofer.trim())),
              ],
            ),

            const SizedBox(height: 20),

            if (observaciones.isNotEmpty) ...[
              Text(
                "Observaciones",
                style: TextStyle(
                  fontSize: Fontsize.h3,
                  color: AppColors.semantics.text.body,
                ),
              ),

              ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: observaciones.map((obs) {
                  final tipo = obs["tipo"]!;
                  final texto = obs["texto"]!;
                  final esEmisor = tipo == "Emisor";

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tipo,
                          style: TextStyle(
                            color: esEmisor
                                ? AppColors.semantics.text.secondary
                                : AppColors.semantics.text.warning,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          texto,
                          style: TextStyle(
                            fontSize: Fontsize.body,
                            color: esEmisor
                                ? AppColors.semantics.text.secondary
                                : AppColors.semantics.text.warning,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],

            const Divider(color: Colors.black12),

            const SizedBox(height: 20),

            ..._envio.articulos.map((art) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                art.rubroDes.trim(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w100,
                                  color: AppColors.semantics.text.body,
                                  fontSize: Fontsize.body,
                                ),
                              ),
                              Text(
                                " #${art.articuloCod.trim()}",
                                style: TextStyle(
                                  color: AppColors.semantics.text.secondary,
                                  fontSize: Fontsize.body,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            art.articuloDes.trim(),
                            style: TextStyle(
                              color: AppColors.semantics.text.secondary,
                              fontSize: Fontsize.body,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      art.cantidad.toString(),
                      style: TextStyle(
                        color: AppColors.semantics.text.body,
                        fontSize: Fontsize.h3,
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 20),

            if (_envio.estadoId == 109 && ((con.contienePermiso(210) && _envio.destinoId == widget.entidad.ubicacionId) || con.contienePermiso(215)))
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: SubtleButton(
                  text: "Notificar problema",
                  type: SubtleButtonType.warning,
                  onPressed: _mostrarDialogoProblema,
                ),
              ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.semantics.text.secondary,
              fontSize: Fontsize.h3
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppColors.semantics.text.body,
              fontSize: Fontsize.h3
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoProblema() {
    ActionSheet.show(
      context,
      title: "Añadir observaciones",
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "El stock no se dará de alta en destino.",
              style: TextStyle(
                color: AppColors.semantics.text.body,
                fontSize: Fontsize.body,
                fontWeight: FontWeight.w100,
              ),
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
                  contentPadding:
                      const EdgeInsets.fromLTRB(16.0, 13.0, 16.0, 13.0),
                  hintText: "Escriba una observación...",
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
                      bool ok = await con.cambioEstadoTraslado(_envio.id, 111, _controller.text);
                      if (ok) {
                        Navigator.of(context).push(PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              EstadoTraslado(
                            entidad: widget.entidad,
                            envio: _envio,
                            label: "Pedido observado",
                            icon: Icons.warning_amber_rounded,
                            color: AppColors.semantics.text.warning,
                            observacion: _controller.text,
                          ),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0);
                            const end = Offset.zero;
                            final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
                            return SlideTransition(position: animation.drive(tween), child: child);
                          },
                          transitionDuration: const Duration(milliseconds: 400),
                        ));
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      _focusNode.requestFocus();
    });
  }

  Widget _btnBottom() {
    return SolidButton(
      type: SolidButtonType.primary,
      text: (_envio.estadoId == 109) && ((_envio.destinoId == widget.entidad.ubicacionId && con.contienePermiso(209)) || (_envio.destinoId != widget.entidad.ubicacionId && con.contienePermiso(214)))
      ? "Confirmar recepción"
      : (_envio.estadoId == 111 && _envio.origenId == widget.entidad.ubicacionId)
        ? "Acciones"
        : "Inicio",
      onPressed: () async {
        if ((_envio.estadoId == 109) && ((_envio.destinoId == widget.entidad.ubicacionId && con.contienePermiso(209)) || (_envio.destinoId != widget.entidad.ubicacionId && con.contienePermiso(214)))) {
          bool ok = await con.cambioEstadoTraslado(_envio.id, 110, "");
          if (ok) {
            Navigator.of(context).push(PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => EstadoTraslado(
                entidad: widget.entidad,
                envio: _envio,
                label: "Mercadería recibida",
                icon: Icons.check_circle_outline_rounded,
                color: AppColors.semantics.text.success,
                observacion: "",
              ),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
                return SlideTransition(position: animation.drive(tween), child: child);
              },
              transitionDuration: const Duration(milliseconds: 400),
            ));
          }
        }
        else if (_envio.estadoId == 111 && _envio.origenId == widget.entidad.ubicacionId) {
          _accionesObservado();
        }
        else {
          Navigator.pop(context, true);
        }
      },
    );
  }

  void _accionesObservado() {
    ActionSheet.show(
      context,
      title: "Acciones",
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      NuevoTraslado(
                    entidad: widget.entidad,
                    envio: _envio,
                  ),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    final tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: Curves.ease));
                    return SlideTransition(
                        position: animation.drive(tween), child: child);
                  },
                  transitionDuration: const Duration(milliseconds: 400),
                ));
              },
              child: _opcionAccion("Editar envío"),
            ),
            GestureDetector(
              onTap: () {
                ActionSheet.show(
                  context,
                  title: "¿Cancelar operación?",
                  content: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "El stock será dado de alta nuevamente en origen.",
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
                          onPressed: () => Navigator.pop(context, true),
                        ),
                        SubtleButton(
                          text: "Eliminar envío",
                          type: SubtleButtonType.error,
                          onPressed: () async {
                            bool ok = await con.eliminarTraslado(widget.envio.id.toString());
                            if (ok) {
                              Navigator.pop(context, true);
                              Navigator.pop(context, true);
                              Navigator.pop(context, true);
                            } else {
                              con.mostrarSnackbar(esError: true, mensaje: "No se pudo eliminar el envío, vuelve a intentarlo mas tarde", titulo: "Error");
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: _opcionAccion("Eliminar envío"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _opcionAccion(String texto) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black12),
        ),
      ),
      child: Text(
        texto,
        style: TextStyle(fontSize: Fontsize.h3, color: AppColors.semantics.text.body),
      ),
    );
  }

}
