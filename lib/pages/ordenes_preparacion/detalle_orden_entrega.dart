// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vientri/components/action_sheet/action_sheet.dart';
import 'package:vientri/components/action_sheet_options/action_sheet_options.dart';
import 'package:vientri/components/badge/badge.dart';
import 'package:vientri/components/solid_button/solid_button.dart';
import 'package:vientri/components/subtle_button/subtle_button.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/pages/ordenes_preparacion/estado_orden_entrega.dart';
import 'package:vientri/pages/comunes/master/master_comprobante.dart';
import 'package:vientri/pages/controller.dart';
import 'package:vientri/src/models/articulo.dart';
import 'package:vientri/src/models/entidad.dart';
import 'package:vientri/src/models/opcion.dart';
import 'package:vientri/src/models/ordenEntrega.dart';

// ignore: must_be_immutable
class DetalleOrdenEntrega extends StatefulWidget {
  Entidad entidad;
  OrdenEntrega ordenEntrega;
  Opcion ubicacion;

  DetalleOrdenEntrega({
    super.key,
    required this.entidad,
    required this.ordenEntrega,
    required this.ubicacion,
  });

  @override
  State<DetalleOrdenEntrega> createState() => _DetalleOrdenEntregaState();
}

class _DetalleOrdenEntregaState extends State<DetalleOrdenEntrega> {
  late Controller con;
  List<Articulo> articulos = [];
  late Future<List<Articulo>> _futureArticulos;
  int i = 0;
  var loading = true.obs;
  var processing = false.obs;
  int? articuloActivoIndex;
  final List<Articulo> articulosSeleccionados = [];
  late int idEstado;

  @override
  void initState() {
    super.initState();
    con = Get.put(Controller(widget.entidad));
    _futureArticulos = con.articulosOrdenEntrega(widget.ordenEntrega.idFactura);
    cargarDetalle();
    idEstado = widget.ordenEntrega.idCmpEstado; // 0-preparar, 14-preparado, 87-en preparación
    if (widget.ordenEntrega.idSubEstado == 5) {
      idEstado = 14;
    }
  }

  void cargarDetalle() async {
    articulos = await _futureArticulos;
    setState(() {
    });
    loading.value = false;
  }

  void toggleArticulo(int index) {
    final art = articulos[index];

    setState(() {
      if (articulosSeleccionados.contains(art)) {
        articulosSeleccionados.remove(art);
      } else {
        articulosSeleccionados.add(art);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading.value) return Scaffold();

    return Obx(() => Stack(
      children: [
        AbsorbPointer(
          absorbing: processing.value,
          child: MasterComprobante(
            title: con.capitalizarNombre(widget.ordenEntrega.cliente),
            onBack: () => Navigator.pop(context, true),
            floatingButton: idEstado == 0
              ? SolidButton(
                type: SolidButtonType.primary,
                text: "Iniciar preparación",
                onPressed: () async {
                  try {
                    processing.value = true;
                    bool ok = await con.cambioEstadoOrdenEntrega(widget.ordenEntrega.idFactura, 87, widget.entidad.usuarioId);
                    if (ok) {
                      setState(() {
                        idEstado = 87;
                      });
                    } else {
                      con.mostrarSnackbar(titulo: "Error", mensaje: "Hubo un error al inciar la preparación", esError: true, seconds: 3000);
                      return;
                    }
                  } finally {
                    processing.value = false;
                  }
                  
                },
              )
              : idEstado == 14
                ? SolidButton(
                  type: SolidButtonType.primary,
                  text: "Confirmar entrega (Generar remito)",
                  onPressed: () {
                    _confirmarEntrega();
                  },
                )
                : idEstado == 90
                  ? SolidButton(
                    type: SolidButtonType.primary,
                    text: "Inicio",
                    onPressed: () => Navigator.pop(context, true),
                  )
                  : SolidButton(
                    type: SolidButtonType.primary,
                    text: "Marcar como preparado",
                    onPressed: articulosSeleccionados.isEmpty
                    ? null
                    : () => _marcarComoPreparado(),
                  ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppBadge(
                      text: idEstado == 14 // Listo para facturar
                        ? "Preparado"
                        : idEstado == 0 // Preparar
                          ? "Preparar"
                          : idEstado == 87 // En preparación
                            ? "En preparación..."
                            : idEstado == 90 // Entregado
                              ? "Entregado"
                              : "${widget.ordenEntrega.estadoCmp} $idEstado",
                      type: idEstado == 14 // Listo para facturar
                        ? AppBadgeType.information
                        : idEstado == 0 // Preparar
                          ? AppBadgeType.action
                          : idEstado == 87 // En preparación
                            ? AppBadgeType.actionSecondary
                            : idEstado == 90 // Entregado
                              ? AppBadgeType.success
                              : AppBadgeType.warning,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Orden de entrega | ID ${widget.ordenEntrega.idFactura}",
                        style: TextStyle(
                          color: AppColors.semantics.text.secondary,
                          fontSize: Fontsize.body,
                        ),
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fila("Fecha", con.formatearFechayDia3(widget.ordenEntrega.fechaFactura)),
                          _fila("Sujeto a factura", widget.ordenEntrega.facturaAsociada),
                          if (idEstado == 14 || idEstado == 90)
                          _fila("Preparador", ""),
                          if (idEstado == 14 || idEstado == 90)
                          _fila("Entregado a cliente", ""),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fila(idEstado == 14 
                            ? "Preparado en"
                            : idEstado == 90 
                              ? "Entregado en"
                              : "Preparar en", con.capitalizar(widget.ubicacion.nombre)),
                          _fila("ID factura", widget.ordenEntrega.idFactura.toString()),
                          if (idEstado == 14 || idEstado == 90)
                          _fila("Entregado por", ""),
                          if (idEstado == 14 || idEstado == 90)
                          _fila("CUIT", ""),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.black12),
                const SizedBox(height: 16),
                SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      ...articulos.asMap().entries.map((entry) {
                        final int index = entry.key;
                        final art = entry.value;
                        final bool seleccionado = articulosSeleccionados.contains(art);
                        
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: idEstado == 14 || idEstado == 90 || idEstado == 0
                              ? null
                              : () => toggleArticulo(index),
                              child: Column(
                                children: [

                                  if(idEstado == 14 || idEstado == 90)
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: MediaQuery.sizeOf(context).width * 0.85,
                                            child: Text(
                                              con.capitalizarNombre(art.articuloDes),
                                              style: TextStyle(
                                                fontSize: Fontsize.h3,
                                                color: AppColors.semantics.text.body,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "ID ${art.id}",
                                            style: TextStyle(
                                              fontSize: Fontsize.body,
                                              color: AppColors.semantics.text.secondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        art.cantidad.toString(),
                                        style: TextStyle(
                                          fontSize: Fontsize.h3,
                                          color: AppColors.semantics.text.body,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                
                                  if(idEstado != 14 && idEstado != 90)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          /// CHECK
                                          GestureDetector(
                                            behavior: HitTestBehavior.translucent,
                                            onTap: idEstado == 0 ? null : () => toggleArticulo(index),
                                            child: Container(
                                              width: 25,
                                              height: 25,
                                              decoration: BoxDecoration(
                                                color: idEstado == 0
                                                ? AppColors.semantics.surface.disabled
                                                : seleccionado
                                                  ? AppColors.semantics.text.action
                                                  : Colors.transparent,
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: idEstado == 0
                                                  ? AppColors.semantics.surface.disabled
                                                  : seleccionado
                                                      ? AppColors.semantics.text.action
                                                      : Colors.black12,
                                                  width: 1,
                                                ),
                                              ),
                                              child: seleccionado
                                                ? const Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: 20,
                                                )
                                                : null,
                                            ),
                                          ),
                                    
                                          const SizedBox(width: 16),
                                    
                                          Row(
                                            children: [
                                              SizedBox(
                                                width: MediaQuery.sizeOf(context).width * 0.075,
                                                child: Text(
                                                  art.cantidad.toString(),
                                                  style: TextStyle(
                                                    fontSize: Fontsize.h3,
                                                    fontWeight: FontWeight.bold,
                                                    color: seleccionado
                                                      ? AppColors.semantics.text.secondary
                                                      : AppColors.semantics.text.body,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    width: MediaQuery.sizeOf(context).width * 0.65,
                                                    child: Text(
                                                      con.capitalizarNombre(art.articuloDes),
                                                      style: TextStyle(
                                                        fontSize: Fontsize.h3,
                                                        color: seleccionado
                                                          ? AppColors.semantics.text.secondary
                                                          : AppColors.semantics.text.body,
                                                      ),
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    "ID ${art.id}",
                                                    style: TextStyle(
                                                      fontSize: Fontsize.body,
                                                      color: AppColors.semantics.text.secondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 8)
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 100),
                    ]
                  ),
                ),
              ],
            ),
          ),
        ),

        if (processing.value)
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.35),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ],
    ));
  }

  Widget _fila(String label, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.semantics.text.secondary,
              fontSize: Fontsize.body
            ),
          ),
          const SizedBox(height: 4),
          Text(
            text == "" ? "--" : text,
            style: TextStyle(
              color: AppColors.semantics.text.body,
              fontSize: Fontsize.body
            ),
          ),
        ],
      ),
    );
  }

  _marcarComoPreparado() {
    if (!con.contienePermiso(259)) {
      con.mostrarSnackbar(titulo: "Error de permisos", mensaje: "Requiere el permiso 259 para continuar", esError: true, seconds: 3000);
      return;
    }
    ActionSheetOptions.show(
      context,
      title: "Siguente acción",
      options: [
        Opcion(id: 0, nombre: "Dejar preparado (Entrega pendiente)"),
        Opcion(id: 1, nombre: "Confirmar entrega (Emitir remito)"),
      ],
      onOptionSelected: (s) async {
        if (s.id == 0) {
          try {
            processing.value = true;
            bool ok = await con.cambioEstadoOrdenEntrega(widget.ordenEntrega.idFactura, 5, widget.entidad.usuarioId);
            if (ok) {
              setState(() {
                idEstado = 14;
              });
            } else {
              con.mostrarSnackbar(titulo: "Error", mensaje: "Hubo un error al marcar la orden como preparada", esError: true, seconds: 3000);
              return;
            }
          } finally {
            processing.value = false;
          }
        } else if (s.id == 1) {
          _generarRemito();
        }
      },
    );
  }

  _confirmarEntrega() {
    if (!con.contienePermiso(259)) {
      con.mostrarSnackbar(titulo: "Error de permisos", mensaje: "Requiere el permiso 259 para continuar", esError: true, seconds: 3000);
      return;
    }
    ActionSheet.show(
      context,
      title: "Confirmar entrega",
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Text(
              "Se generará un remito nuevo",
              style: TextStyle(
                color: AppColors.semantics.text.body,
                fontSize: Fontsize.body,
              ),
            ),
            const SizedBox(height: 8),
            SubtleButton(
              text: "Volver",
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: 8),
            SolidButton(
              text: "Confirmar entrega y generar remito",
              onPressed: () async {
                _generarRemito();
              },
            )
          ],
        ),
      )
    );
  }

  _generarRemito() async {
    try {
      processing.value = true;
      bool ok = await con.registrarOrdenPreparacion(widget.ordenEntrega, articulosSeleccionados);
      if (ok) {
        if (idEstado == 14) {
          Navigator.pop(context);
        }
        setState(() {
          idEstado = 90;
        });
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
              EstadoOrdenEntrega(
                entidad: widget.entidad,
                ordenEntrega: widget.ordenEntrega,
                titulo: "Pedido entregado",
                icon: Icons.check_circle_outline_rounded,
                color: AppColors.semantics.text.success,
                texto: "Remito emitido",
              ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      } else {
        con.mostrarSnackbar(titulo: "Error", mensaje: "Hubo un error al generar el remito", esError: true, seconds: 3000);
        return;
      }
    } finally {
      processing.value = false;
    }
  }


}
