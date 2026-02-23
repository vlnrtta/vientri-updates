import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:vientri/components/action_sheet/action_sheet.dart';
import 'package:vientri/components/action_sheet_options/action_sheet_options.dart';
import 'package:vientri/components/solid_button/solid_button.dart';
import 'package:vientri/components/tiempo/tiempo_formateado.dart';
import 'package:vientri/constants/cronometro.dart';
import 'package:vientri/pages/comunes/master/master_principal.dart';
import 'package:vientri/pages/comunes/permisos/permisos_page.dart';
import 'package:vientri/pages/ingresos/nuevo_ingreso.dart';
import 'package:vientri/pages/stock/detalle_control.dart';
import 'package:vientri/pages/comunes/login/login_controller.dart';
import 'package:vientri/src/models/control.dart';
import 'package:get/get.dart';
import 'package:vientri/components/badge/badge.dart';
import 'package:vientri/components/heading/heading.dart';
import 'package:vientri/components/subtle_button/subtle_button.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/constants/app_shadows.dart';
import 'package:vientri/pages/controller.dart';
import 'package:flutter/material.dart';
import 'package:vientri/src/models/entidad.dart';
import 'package:vientri/src/models/opcion.dart';

// ignore: must_be_immutable
class ListaIngresos extends StatefulWidget {
  Entidad entidad;
  ListaIngresos({super.key, required this.entidad});

  @override
  State<ListaIngresos> createState() => _ListaIngresosState();
}

class _ListaIngresosState extends State<ListaIngresos> {
  final LoginController con = LoginController();
  late Controller cont;
  late Future<List<Control>> _futureIngresos;
  final cronometro = Get.put(CronometroController());
  Timer? _debounce;
  List<Opcion> _opcionesSalones = [];
  List<Opcion> optionSelectedHistory = [];
  bool _isExpanded = false;
  int _limiteHistorial = 5;

  @override
  void initState() {
    super.initState();
    cont = Get.put(Controller(widget.entidad));
    _futureIngresos = cont.listaControles();
    _opcionesSalones = widget.entidad.salones.map((item) {
      var parts = item.split(' - ');
      return Opcion(
        id: int.parse(parts[0]),
        nombre: parts[1],
      );
    }).toList();
    optionSelectedHistory = [
      Opcion(id: 5, nombre: "Últimos 5"),
      Opcion(id: 10, nombre: "Últimos 10"),
      Opcion(id: 20, nombre: "Últimos 20"),
      Opcion(id: 50, nombre: "Últimos 50"),
      Opcion(id: -1, nombre: "Todos"),
    ];
  }

  void _recargar() {
    setState(() {
      _futureIngresos = cont.listaControles();
    });
  }

  Future<void> _pullToRefresh() async {
    _recargar();
    await _futureIngresos;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MasterPage(
      title: "Control de ingresos de mercadería",
      onBack: () => Navigator.pop(context, true),
      onKeyTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) => PermisosPage(entidad: widget.entidad, titulo: "Permisos", idApp: -1),
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
        )).then((value) {
          setState(() {
            Get.delete<Controller>();
            cont = Get.put(Controller(widget.entidad));
            _futureIngresos = cont.listaControles();
          });
        });
      },
      floatingButton: cont.contienePermiso(218)
      ? SolidButton(
        text: "Nuevo ingreso",
        leftIcon: Icons.add,
        onPressed: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => NuevoIngreso(entidad: widget.entidad),
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
          ).then((value) {
            if (value == true) {
              setState(() {
                _recargar();
              });
            }
          });
        },
      )
      : null,
      onRefresh: () async {
        setState(() {
          _futureIngresos = cont.listaControles();
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              ActionSheetOptions.show(
                context,
                title: "Elegir ubicación",
                options: _opcionesSalones,
                onOptionSelected: (s) {
                  setState(() {
                    widget.entidad.ubicacion = cont.capitalizar(s.nombre);
                    widget.entidad.ubicacionId = s.id;
                    _futureIngresos = cont.listaControles();
                  });
                },
              );
            },
            child: Row(
              children: [
                Icon(Icons.location_on_outlined, color: AppColors.semantics.text.action),
                const SizedBox(width: 4),
                Text(
                  cont.capitalizarNombre(widget.entidad.ubicacion),
                  style: TextStyle(
                    color: AppColors.semantics.text.body,
                    fontSize: Fontsize.h2,
                    fontWeight: FontWeight.bold
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.semantics.text.body, size: 30),
              ],
            )
          ),

          const SizedBox(height: 16),
          RefreshIndicator(
            onRefresh: _pullToRefresh,
            child: FutureBuilder<List<Control>>(
              future: _futureIngresos,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 100),
                      child: const CircularProgressIndicator.adaptive(),
                    )
                  );
                } else if (snapshot.hasError) {
                  final errorText = snapshot.error.toString();
                  final isConnectionError = errorText.contains("ClientException with SocketException") && errorText.contains("net.vientri.com");
                  final headerText = isConnectionError ? "Error de conexión: se recomienda avisar a VIENTRI" : "Error";
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 42),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(16)),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () => setState(() => _isExpanded = !_isExpanded),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        headerText,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                                      size: 24,
                                    ),
                                  ],
                                ),
                              ),
                              if (_isExpanded) ...[
                                const SizedBox(height: 8),
                                Text(
                                  errorText,
                                  style: TextStyle(
                                    color: AppColors.semantics.text.secondary,
                                    fontSize: Fontsize.h3,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SubtleButton(
                          text: "Volver a cargar",
                          onPressed: _recargar,
                        ),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No hay controles"));
                }
                
                final controles = snapshot.data!;
                
                var vigentes = controles
                    .where((p) => p.estadoId != 10824 && p.empleadoId == widget.entidad.usuarioId && p.ubicacionId == widget.entidad.ubicacionId)
                    .toList()
                  ..sort((a, b) => b.id.compareTo(a.id));
          
                var historial = controles
                    .where((p) => p.estadoId == 10824 && p.empleadoId == widget.entidad.usuarioId && p.ubicacionId == widget.entidad.ubicacionId)
                    .toList()
                  ..sort((a, b) => b.id.compareTo(a.id));
          
                if (_limiteHistorial != -1) {
                  historial = historial.take(_limiteHistorial).toList();
                }
          
                if (cont.contienePermiso(218)) {
                  vigentes = controles
                    .where((p) => p.estadoId != 10824 && p.ubicacionId == widget.entidad.ubicacionId)
                    .toList()
                  ..sort((a, b) => b.id.compareTo(a.id));
          
                  historial = controles
                    .where((p) => p.estadoId == 10824 && p.ubicacionId == widget.entidad.ubicacionId)
                    .toList()
                  ..sort((a, b) => DateTime.parse(b.horaFin).compareTo(DateTime.parse(a.horaFin)));

          
                  if (_limiteHistorial != -1) {
                    historial = historial.take(_limiteHistorial).toList();
                  }
                }
          
                return Column(
                  children: [
                    vigentes.isNotEmpty
                    ? Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.semantics.border.action),
                        boxShadow: AppShadows.elementFocusShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              cont.contienePermiso(217) ? "Entrantes" : "Vigentes",
                              style: TextStyle(
                                color: AppColors.semantics.text.action,
                                fontSize: Fontsize.h2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...vigentes.map((v) => v.estadoId == 10823
                            ? CronometroListedElement(control: v, funcion: () {
                                if (cont.contienePermiso(217) || v.empleadoId == widget.entidad.usuarioId) {
                                  Navigator.of(context).push(
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation, secondaryAnimation) => NuevoIngreso(entidad: widget.entidad),
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
                                  ).then((value) {
                                    if (value == true) {
                                      setState(() {
                                        _recargar();
                                      });
                                    }
                                  });
                                } else {
                                  Navigator.of(context).push(
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation, secondaryAnimation) => DetalleControl(entidad: widget.entidad, control: v),
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
                                  ).then((value) {
                                    if (value == true) {
                                      setState(() {
                                        _recargar();
                                      });
                                    }
                                  });
                                }
                              }
                            )
                            : _card(
                              v, 
                              () {
                                if (cont.contienePermiso(217)) {
                                  ActionSheet.show(
                                    context,
                                    title: "¿Iniciar control?",
                                    content: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Se iniciará un cronómetro.",
                                            style: TextStyle(
                                              color: AppColors.semantics.text.body,
                                              fontSize: Fontsize.body,
                                              fontWeight: FontWeight.w100
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          SubtleButton(
                                            text: "Volver",
                                            type: SubtleButtonType.brand,
                                            onPressed: () => Navigator.pop(context),
                                          ),
                                          const SizedBox(height: 16),
                                          SolidButton(
                                            text: "Iniciar",
                                            type: SolidButtonType.primary,
                                            onPressed: () {
                                              cont.actualizaEstado(context, v.id, 10823); // estado iniciado
                                              Navigator.pop(context, true);
                                              Navigator.of(context).push(
                                                PageRouteBuilder(
                                                  pageBuilder: (context, animation, secondaryAnimation) => NuevoIngreso(entidad: widget.entidad),
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
                                              ).then((value) {
                                                if (value == true) {
                                                  setState(() {
                                                    _recargar();
                                                  });
                                                }
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                } else if (v.empleadoId == widget.entidad.usuarioId) {
                                  ActionSheet.show(
                                    context,
                                    title: "Ver o iniciar control",
                                    content: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Usted puede ver el detalle del recuento o iniciarlo.",
                                            style: TextStyle(
                                              color: AppColors.semantics.text.body,
                                              fontSize: Fontsize.body,
                                              fontWeight: FontWeight.w100
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          SubtleButton(
                                            text: "Volver",
                                            type: SubtleButtonType.brand,
                                            onPressed: () => Navigator.pop(context),
                                          ),
                                          const SizedBox(height: 8),
                                          SolidButton(
                                            text: "Ver",
                                            type: SolidButtonType.secondary,
                                            onPressed: () {
                                              Navigator.pop(context, true);
                                              Navigator.of(context).push(
                                                PageRouteBuilder(
                                                  pageBuilder: (context, animation, secondaryAnimation) => DetalleControl(entidad: widget.entidad, control: v),
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
                                              ).then((value) {
                                                if (value == true) {
                                                  setState(() {
                                                    _recargar();
                                                  });
                                                }
                                              });
                                            },
                                          ),
                                          const SizedBox(height: 8),
                                          SolidButton(
                                            text: "Iniciar",
                                            type: SolidButtonType.primary,
                                            onPressed: () {
                                              cont.actualizaEstado(context, v.id, 10823); // estado iniciado
                                              Navigator.pop(context, true);
                                              Navigator.of(context).push(
                                                PageRouteBuilder(
                                                  pageBuilder: (context, animation, secondaryAnimation) => NuevoIngreso(entidad: widget.entidad),
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
                                              ).then((value) {
                                                if (value == true) {
                                                  setState(() {
                                                    _recargar();
                                                  });
                                                }
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                } else {
                                  Navigator.of(context).push(
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation, secondaryAnimation) => DetalleControl(entidad: widget.entidad, control: v),
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
                                  ).then((value) {
                                    if (value == true) {
                                      setState(() {
                                        _recargar();
                                      });
                                    }
                                  });
                                }
                              },
                              AppBadge(
                                text: cont.contienePermiso(217) ? "Pendiente" : "Enviado",
                                type: cont.contienePermiso(217) ? AppBadgeType.warning : AppBadgeType.information,
                              )
                            ),
                          )
                        ],
                      ),
                    )
                    : Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          AppHeading(label: cont.contienePermiso(217) ? "Entrantes" : "Vigentes", fontSize: Fontsize.h2),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              "No hay nuevos controles",
                              style: TextStyle(
                                color: AppColors.semantics.text.secondary,
                                fontSize: Fontsize.h3
                              ),
                            ),
                          )
                        ],
                      )
                    ),
                    
                    historial.isNotEmpty
                    ? Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Historial",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.semantics.text.body,
                                  ),
                                ),

                                InkWell(
                                  onTap: () {
                                    ActionSheetOptions.show(
                                      context,
                                      title: "Mostrar",
                                      options: optionSelectedHistory,
                                      onOptionSelected: (s) {
                                        setState(() {
                                          _limiteHistorial = s.id;
                                        });
                                      },
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        _limiteHistorial != -1 ? "Ult. $_limiteHistorial" : "Todos",
                                        style: TextStyle(
                                          color: AppColors.semantics.text.body,
                                          fontSize: Fontsize.body,
                                        ),
                                      ),
                                      Icon(Icons.chevron_right, color: AppColors.semantics.text.body, size: 30),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ),
                          const SizedBox(height: 8),
                          ...historial.map((a) => 
                            _card(
                              a, 
                              () {
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) => DetalleControl(entidad: widget.entidad, control: a),
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
                                ).then((value) {
                                  if (value == true) {
                                    setState(() {
                                      _recargar();
                                    });
                                  }
                                });
                              },
                              AppBadge(
                                text: "Finalizado",
                                type: AppBadgeType.success,
                              )
                            )
                          )
                        ]
                      )
                    )
                    : const SizedBox(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(Control control, VoidCallback funcion, Widget badge) {
    return Material(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: funcion,
        child: Container(
          height: 90,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 5,
                    child: Text(
                      cont.capitalizar(control.ubicacion.trim()),
                      style: TextStyle(
                        color: AppColors.semantics.text.body,
                        fontSize: Fontsize.body,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: badge,
                  ),
                ],
              ),

              Expanded(
                child: Text(
                  cont.capitalizarNombre(control.empleado.trim()),
                  style: TextStyle(
                    color: AppColors.semantics.text.body,
                    fontSize: Fontsize.body,
                  ),
                ),
              ),

              Expanded(
                child: _tablaIconos(control),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tablaIconos(Control control) {
    var duracionFormateado = '00:00';
    if (control.estadoId == 10824) {
      final fechaIni = DateTime.parse(control.horaIni);
      final fechaFin = DateTime.parse(control.horaFin);
      final duracion = fechaFin.difference(fechaIni);
      final horas = duracion.inHours;
      final minutos = duracion.inMinutes % 60;
      final segundos = duracion.inSeconds % 60;
      duracionFormateado = horas.toString().padLeft(2, '0') != "00" 
      ? "${horas.toString().padLeft(2, '0')}:${minutos.toString().padLeft(2, '0')}:${segundos.toString().padLeft(2, '0')}"
      : "${minutos.toString().padLeft(2, '0')}:${segundos.toString().padLeft(2, '0')}";
    }
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
              Icon(control.estadoId == 10824 ? Icons.check : CupertinoIcons.time, size: 18, color: control.estadoId == 10824 ? AppColors.semantics.text.secondary : AppColors.semantics.text.secondary),
              control.estadoId == 10824 ? cont.formatearFechayDia3(control.horaFin) : "${cont.formatearFechayDia2(control.fecha)}, ${control.hora}",
            ),

            _cellIcon(
              Icon(CupertinoIcons.cube_box, size: 18, color: AppColors.semantics.text.secondary,),
              control.items.toString(),
            ),

            control.estadoId == 10824
                ? _cellIcon(
                    Icon(CupertinoIcons.stopwatch, size: 18, color: AppColors.semantics.text.secondary,),
                    duracionFormateado,
                  )
                : _emptyCell(),

            control.estadoId == 10824
                ? _cellIcon(
                    Icon(control.diferencias == "0" ? Icons.check_circle_outline : Icons.warning_amber_rounded, size: 20, color: control.diferencias == "0" ? AppColors.semantics.text.success : AppColors.semantics.text.warning),
                    control.diferencias,
                    control.diferencias == "0" ? AppColors.semantics.text.success : AppColors.semantics.text.warning,
                  )
                : _emptyCell(),
          ],
        ),
      ],
    );
  }

  Widget _emptyCell() {
    return const Padding(
      padding: EdgeInsets.only(right: 16),
      child: SizedBox(
        width: 0,
        height: 20,
      ),
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

}