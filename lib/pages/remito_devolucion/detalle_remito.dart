// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vientri/components/solid_button/solid_button.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/pages/asignar_codigos_imagenes/lista_articulos.dart';
import 'package:vientri/pages/comunes/master/master_comprobante.dart';
import 'package:vientri/pages/controller.dart';
import 'package:vientri/pages/remito_devolucion/confirmar_remito.dart';
import 'package:vientri/src/models/articulo.dart';
import 'package:vientri/src/models/entidad.dart';
import 'package:vientri/src/models/remitoDevolucion.dart';

// ignore: must_be_immutable
class DetalleRemito extends StatefulWidget {
  Entidad entidad;
  RemitoDevolucion remitoDevolucion;

  DetalleRemito({
    super.key,
    required this.entidad,
    required this.remitoDevolucion,
  });

  @override
  State<DetalleRemito> createState() => _DetalleRemitoState();
}

class _DetalleRemitoState extends State<DetalleRemito> {
  late Controller con;
  late ListaArticulos detalle;
  List<Articulo> articulosRemito = [];
  late Future<List<Articulo>> _futureArticulosRemito;
  int i = 0;
  var loading = true.obs;
  int? articuloActivoIndex;
  final Map<int, TextEditingController> cantidadControllers = {};
  final Set<int> articulosSeleccionados = {};
  final Map<int, FocusNode> cantidadFocusNodes = {};

  @override
  void initState() {
    super.initState();
    con = Get.put(Controller(widget.entidad));
    _futureArticulosRemito = con.articulosRemitoDevolucion(widget.remitoDevolucion.idRemito);
    cargarDetalle();
  }

  void cargarDetalle() async {
    articulosRemito = await _futureArticulosRemito;
    setState(() {
    });
    loading.value = false;
  }

  bool _tieneCantidad(int articuloId) {
    final txt = cantidadControllers[articuloId]?.text.trim() ?? "";
    
    return txt.isNotEmpty;
  }

  int _totalCantidad() {
    return cantidadControllers.values
        .where((c) => int.tryParse(c.text.trim()) != null && int.parse(c.text.trim()) > 0)
        .length;
  }

  List<Articulo> _articulosSeleccionadosConCantidad() {
    return articulosRemito
      .where((art) {
        final id = art.id!;
        final txt = cantidadControllers[id]?.text.trim() ?? "";
        final cant = int.tryParse(txt);
        return cant != null && cant > 0;
      })
      .map((art) {
        final id = art.id!;
        final cant = int.parse(cantidadControllers[id]!.text.trim());

        return Articulo(
          id: art.id,
          articuloCod: art.articuloCod,
          articuloDes: art.articuloDes,
          cantidad: cant,
          articuloId: art.articuloId,
          impoconiva: art.impoconiva,
          stk: art.stk,
          rubroId: art.rubroId,
          rubroDes: art.rubroDes,
          foto: art.foto,
          cBarra: art.cBarra
        );
      }
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return loading.value
    ? Scaffold()
    : MasterComprobante(
      title: "Seleccioná los artículos a devolver",
      onBack: () => Navigator.pop(context, true),
      floatingButton: SolidButton(
        type: SolidButtonType.primary,
        text: "Siguiente",
        onPressed: () {
          final articulosSeleccionados = _articulosSeleccionadosConCantidad();

          if (articulosSeleccionados.isEmpty) {
            con.mostrarSnackbar(titulo: "Atención", mensaje: "Seleccioná al menos un artículo", esError: true);
            return;
          }

          widget.remitoDevolucion.fecEmision = con.getFechaHoraActual();

          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  ConfirmarRemito(
                    entidad: widget.entidad,
                    remitoDevolucion: widget.remitoDevolucion,
                    articulos: articulosSeleccionados,
                  ),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                final tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: Curves.ease));
                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
        },
      ),
      cab1: "",
      label1: "${widget.remitoDevolucion.numeroRemito} | ID ${widget.remitoDevolucion.idRemito}",

      cab3: con.formatearFechayDia3(widget.remitoDevolucion.fechaRemito),
      label3: "Fecha",
    
      cab4: widget.remitoDevolucion.cliente.trim(),
      label4: "Cliente",
    
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                ...articulosRemito.asMap().entries.map((entry) {
                  final art = entry.value;
                  final id = art.id!;
                  cantidadControllers.putIfAbsent(
                    id,
                    () => TextEditingController(),
                  );
                  cantidadFocusNodes.putIfAbsent(
                    id,
                    () => FocusNode(),
                  );
                  final bool tieneCantidad = _tieneCantidad(id);
                  final bool expandido = tieneCantidad || articuloActivoIndex == id;
                  final bool seleccionado = tieneCantidad || articulosSeleccionados.contains(id);
                  final bool esActivo = articuloActivoIndex == id;
                  final Color colorEstado = esActivo
                  ? AppColors.semantics.surface.action
                  : tieneCantidad
                      ? AppColors.semantics.text.secondary
                      : seleccionado
                          ? AppColors.semantics.text.secondary
                          : const Color.fromARGB(31, 139, 139, 139);

                  cantidadControllers.putIfAbsent(
                    id,
                    () => TextEditingController(),
                  );

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          // 🛑 Si toco el MISMO activo → solo aseguro foco
                          if (articuloActivoIndex == id) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              cantidadFocusNodes[id]?.requestFocus();
                            });
                            return;
                          }

                          setState(() {
                            // 🔴 Manejo del activo anterior
                            if (articuloActivoIndex != null) {
                              final anteriorId = articuloActivoIndex!;

                              // si NO tenía cantidad → se colapsa
                              if (!_tieneCantidad(anteriorId)) {
                                articulosSeleccionados.remove(anteriorId);
                              }
                              // si tenía cantidad → queda confirmado (expandido secundario)
                            }

                            // 🟢 Activar el nuevo
                            articulosSeleccionados.add(id);
                            articuloActivoIndex = id;
                          });

                          // 🟢 Foco + cursor (cuando el TextField YA EXISTE)
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            final focusNode = cantidadFocusNodes[id];
                            final controller = cantidadControllers[id];

                            focusNode?.requestFocus();

                            if (controller != null) {
                              controller.selection = TextSelection.fromPosition(
                                TextPosition(offset: controller.text.length),
                              );
                            }
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              /// ---------- FILA PRINCIPAL ----------
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      /// CHECK
                                      GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        onTap: () {
                                          if (tieneCantidad || cantidadControllers[id]?.text != "") {
                                            setState(() {
                                              // vaciar cantidad
                                              cantidadControllers[id]?.clear();

                                              // quitar selección
                                              articulosSeleccionados.remove(id);

                                              // si era el activo, se desactiva
                                              if (articuloActivoIndex == id) {
                                                articuloActivoIndex = null;
                                              }
                                            });
                                          }
                                          // ⛔ no hacemos nada si no tiene cantidad
                                          // (el tap cae al InkWell padre)
                                        },
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          width: 20,
                                          height: 20,
                                          
                                          decoration: BoxDecoration(
                                            color: colorEstado,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: colorEstado,
                                              width: 1,
                                            ),
                                          ),
                                          child: seleccionado
                                            ? const Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: Fontsize.body,
                                              )
                                            : null,
                                        ),

                                      ),

                                      const SizedBox(width: 8),

                                      SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.6,
                                        child: Text(
                                          "#${art.articuloCod} | ${con.capitalizar(art.articuloDes)}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: Fontsize.h3,
                                          ),
                                          maxLines: 2,
                                        ),
                                      ),
                                    ],
                                  ),

                                  Text(
                                    art.cantidad.toString(),
                                    style: TextStyle(fontSize: Fontsize.h3),
                                  ),
                                ],
                              ),
                              AnimatedCrossFade(
                                firstChild: const SizedBox(),
                                secondChild: Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 80,
                                        child: TextField(
                                          controller: cantidadControllers[id],
                                          focusNode: cantidadFocusNodes[id],
                                          keyboardType: TextInputType.number,
                                          onChanged: (value) {
                                            final max = art.cantidad; // cantidad original del remito
                                            final parsed = int.tryParse(value);

                                            if (parsed == null) {
                                              cantidadControllers[id]!.clear();
                                              return;
                                            }

                                            if (parsed > max) {
                                              // 🔒 Limitar al máximo permitido
                                              cantidadControllers[id]!
                                                ..text = max.toString()
                                                ..selection = TextSelection.fromPosition(
                                                  TextPosition(offset: max.toString().length),
                                                );

                                              con.mostrarSnackbar(
                                                titulo: "Atención",
                                                mensaje: "No podés devolver más de $max unidades",
                                                esError: true,
                                              );
                                            }

                                            setState(() {});
                                          },
                                          decoration: InputDecoration(
                                            isDense: true,
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 8,
                                            ),

                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                color: seleccionado
                                                    ? (tieneCantidad
                                                        ? AppColors.semantics.text.secondary
                                                        : AppColors.semantics.surface.action)
                                                    : Colors.grey.shade300,
                                              ),
                                            ),

                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                color: AppColors.semantics.surface.action,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text("Devuelto(s)"),
                                    ],
                                  ),
                                ),
                                crossFadeState: expandido
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                                duration: const Duration(milliseconds: 200),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                Divider(color: Colors.black12)
              ]
            ),

            const SizedBox(height: 16),

            Center(
              child: Text(
                _totalCantidad() == 1 ? "${_totalCantidad()} artículo" : "${_totalCantidad()} artículos",
                style: TextStyle(
                  color: AppColors.semantics.text.action,
                  fontSize: Fontsize.h3,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
