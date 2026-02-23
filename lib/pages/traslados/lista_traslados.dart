import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:vientri/components/action_sheet_options/action_sheet_options.dart';
import 'package:vientri/components/badge/badge.dart';
import 'package:vientri/components/heading/heading.dart';
import 'package:vientri/components/solid_button/solid_button.dart';
import 'package:vientri/components/subtle_button/subtle_button.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/constants/app_shadows.dart';
import 'package:vientri/pages/comunes/master/master_principal.dart';
import 'package:vientri/pages/comunes/permisos/permisos_page.dart';
import 'package:vientri/pages/controller.dart';
import 'package:vientri/pages/comunes/login/login_controller.dart';
import 'package:vientri/pages/traslados/detalle_traslado.dart';
import 'package:vientri/pages/traslados/nuevo_traslado.dart';
import 'package:vientri/src/models/entidad.dart';
import 'package:vientri/src/models/envio.dart';
import 'package:vientri/src/models/opcion.dart';

// ignore: must_be_immutable
class ListaTraslados extends StatefulWidget {
  Entidad entidad;
  ListaTraslados({super.key, required this.entidad});

  @override
  State<ListaTraslados> createState() => _ListaTrasladosState();
}

class _ListaTrasladosState extends State<ListaTraslados> {
  final LoginController con = LoginController();
  late Controller cont;
  late Future<List<Envio>> _futureTraslados;
  List<Opcion> _opcionesSalones = [];
  bool _isExpanded = false;
  int activeIndex = 0;
  bool verVigente = true;

  @override
  void initState() {
    super.initState();
    cont = Get.put(Controller(widget.entidad));
    _futureTraslados = cont.listaTraslados();

    _opcionesSalones = widget.entidad.salones.map((item) {
      var parts = item.split(' - ');
      return Opcion(
        id: int.parse(parts[0]),
        nombre: parts[1],
      );
    }).toList();
  }

  void _recargar() {
    setState(() {
      _futureTraslados = cont.listaTraslados();
    });
  }

  Future<void> pullToRefresh() async {
    _recargar();
    await _futureTraslados;
  }

  @override
  Widget build(BuildContext context) {
    return MasterPage(
      title: "Traslados de mercadería",
      onRefresh: () async {
        setState(() {
          _futureTraslados = cont.listaTraslados();
        });
      },
      onBack: () => Navigator.pop(context, true),
      onKeyTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => PermisosPage(entidad: widget.entidad, titulo: "Permisos", idApp: 1),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
              return SlideTransition(position: animation.drive(tween), child: child);
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        ).then((_) {
          setState(() {
            Get.delete<Controller>();
            cont = Get.put(Controller(widget.entidad));
            _futureTraslados = cont.listaTraslados();
          });
        });
      },
      floatingButton: activeIndex == 1 ? _btnBottom() : null,
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

                /*Text(
                  "Cambiar mi ubicación",
                  style: TextStyle(
                    color: AppColors.semantics.text.action,
                    fontSize: Fontsize.h3,
                  ),
                ),*/
              ],
            )
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F0FA),
              borderRadius: BorderRadius.circular(50),
            ),

            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _menuItem(CupertinoIcons.arrow_down_right, "Entradas", 0),
                _menuItem(CupertinoIcons.arrow_up_right, "Salidas", 1),
                if (cont.contienePermiso(212) || cont.contienePermiso(213))
                _menuItem(FontAwesomeIcons.warehouse, "Otras ubics.", 2),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          FutureBuilder<List<Envio>>(
            future: _futureTraslados,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                final errorText = snapshot.error.toString();
                String headerText;
                if (errorText.contains("SocketException") ||
                    errorText.contains("Connection timed out")) {
                  headerText =
                      "Error de conexión: se recomienda avisar a VIENTRI";
                } else if (errorText
                    .contains("Connection closed before full header")) {
                  headerText =
                      "Error de servidor: la conexión se cerró inesperadamente";
                } else if (errorText.contains("HttpException") ||
                    errorText.contains("Response status code")) {
                  headerText =
                      "Error HTTP: hubo un problema con la respuesta del servidor";
                } else {
                  headerText = "Error";
                }
                    
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
                              onTap: () =>
                                  setState(() => _isExpanded = !_isExpanded),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                    _isExpanded
                                        ? Icons.expand_less
                                        : Icons.expand_more,
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
                return _sinVigentes("Vigentes");
              }
          
              String tituloVigentes = "Vigentes";
              String tituloHistorial = "Historial";
              List<Envio> vigentes = [];
              List<Envio> historial = [];
              final traslados = snapshot.data!;
          
              List<Envio> misEntradasVigentes = traslados.where((e) => (e.estadoId == 109 || e.estadoId == 111) && e.destinoId == widget.entidad.ubicacionId).toList();
              List<Envio> misSalidasVigentes = traslados.where((e) => (e.estadoId == 109 || e.estadoId == 111) && e.destinoId != widget.entidad.ubicacionId && e.origenId == widget.entidad.ubicacionId).toList();
              List<Envio> todasSalidasVigentes = traslados.where((e) => (e.estadoId == 109 || e.estadoId == 111) && e.destinoId != widget.entidad.ubicacionId && e.origenId != widget.entidad.ubicacionId).toList();
              
              List<Envio> misEntradasHistorial = traslados.where((e) =>(e.estadoId != 109 && e.estadoId != 111) && e.destinoId == widget.entidad.ubicacionId).toList();
              List<Envio> misSalidasHistorial = traslados.where((e) => (e.estadoId != 109 && e.estadoId != 111) && e.destinoId != widget.entidad.ubicacionId && e.origenId == widget.entidad.ubicacionId).toList();
              List<Envio> todasSalidasHistorial = traslados.where((e) => (e.estadoId != 109 && e.estadoId != 111) && e.destinoId != widget.entidad.ubicacionId && e.origenId != widget.entidad.ubicacionId).toList();
              
              if (activeIndex == 0) {
                tituloVigentes = "Entradas vigentes";
                verVigente = true;
                vigentes = misEntradasVigentes;
              } else if (activeIndex == 1) {
                tituloVigentes = "Salidas vigentes";
                verVigente = false;
                if (cont.contienePermiso(207)) {
                  verVigente = true;
                  vigentes = misSalidasVigentes;
                }
              } else if (activeIndex == 2) {
                verVigente = false;
                if (cont.contienePermiso(212)) {
                  vigentes = todasSalidasVigentes;
                  verVigente = true;
                }
              }
          
              if (activeIndex == 0) {
                tituloHistorial = "Historial de entrantes";
                if (cont.contienePermiso(211)) {
                  historial = misEntradasHistorial;
                }
              } else if (activeIndex == 1) {
                tituloHistorial = "Historial de salidas";
                if (cont.contienePermiso(208)) {
                  historial = misSalidasHistorial;
                }
              } else if (activeIndex == 2) {
                if (cont.contienePermiso(213)) {
                  historial = todasSalidasHistorial;
                }
              }
          
              //  -------------------------  //
              /*final envios = snapshot.data!;
              if (activeIndex == 0) {
                tituloVigentes = "Entradas vigentes";
                vigentes = envios
                    .where((e) =>
                        e.estadoId == 109 &&
                        e.destinoId == widget.entidad.ubicacionId)
                    .toList();
                verVigente = true;
              } else if (activeIndex == 1) {
                tituloVigentes = "Salidas vigentes";
                if (cont.contienePermiso(207)) {
                  vigentes = envios
                      .where((e) =>
                          e.estadoId == 109 &&
                          e.destinoId != widget.entidad.ubicacionId &&
                          e.origenId == widget.entidad.ubicacionId)
                      .toList();
                  verVigente = true;
                } else {
                  verVigente = false;
                }
              } else if (activeIndex == 2) {
                if (cont.contienePermiso(209)) {
                  vigentes = envios
                      .where((e) =>
                          e.estadoId == 109 &&
                          e.destinoId != widget.entidad.ubicacionId &&
                          e.origenId != widget.entidad.ubicacionId)
                      .toList();
                  verVigente = true;
                } else {
                  verVigente = false;
                }
              }
                    
              List<Envio> otros = [];
              String tituloHistorial = "Historial";
              if (activeIndex == 0) {
                tituloHistorial = "Historial de entrantes";
                if (cont.contienePermiso(213)) {
                  otros = envios
                      .where((e) =>
                          e.estadoId != 109 &&
                          e.destinoId == widget.entidad.ubicacionId)
                      .toList();
                }
              } else if (activeIndex == 1) {
                tituloHistorial = "Historial de salidas";
                if (cont.contienePermiso(208)) {
                  otros = envios
                      .where((e) =>
                          e.estadoId != 109 &&
                          e.origenId == widget.entidad.ubicacionId)
                      .toList();
                }
              } else if (activeIndex == 2) {
                if (cont.contienePermiso(215)) {
                  otros = envios
                      .where((e) =>
                          e.estadoId != 109 &&
                          e.origenId != widget.entidad.ubicacionId &&
                          e.destinoId != widget.entidad.ubicacionId)
                      .toList();
                }
              }*/
                    
              return ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildVigentes(vigentes, tituloVigentes),
                  if (historial.isNotEmpty)
                  _buildHistorial(historial, tituloHistorial),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVigentes(List<Envio> vigentes, String tituloVigentes) {
    if (!verVigente) {
      return _permisoDenegado(tituloVigentes);
    }
    if (vigentes.isEmpty) {
      return _sinVigentes(tituloVigentes);
    }

    return Container(
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
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.info_circle,
                  size: 28,
                  color: AppColors.semantics.border.action
                ),
                const SizedBox(width: 8),
                Text(
                  tituloVigentes,
                  style: TextStyle(
                    color: AppColors.semantics.text.body,
                    fontSize: Fontsize.h2,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ...vigentes.map((e) => _card(
            e,
            () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => DetalleTraslado(entidad: widget.entidad, envio: e),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
                    return SlideTransition(position: animation.drive(tween), child: child);
                  },
                  transitionDuration: const Duration(milliseconds: 400),
                ),
              ).then((value) {
                if (value) {
                  setState(() {
                    _futureTraslados = cont.listaTraslados();
                  });
                }
              });
            }
          )),
        ],
      ),
    );
  }

  Widget _buildHistorial(List<Envio> otros, String tituloHistorial) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              tituloHistorial,
              style: TextStyle(
                  color: AppColors.semantics.text.body,
                  fontSize: Fontsize.h2,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          ...otros.map((e) => _card(
            e,
            () {
              if (e.estadoName.toLowerCase() != "cancelado") {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => DetalleTraslado(entidad: widget.entidad, envio: e),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
                      return SlideTransition(position: animation.drive(tween), child: child);
                    },
                    transitionDuration: const Duration(milliseconds: 400),
                  ),
                ).then((value) {
                  if (value) {
                    setState(() {
                      _futureTraslados = cont.listaTraslados();
                    });
                  }
                });
              }
            }
          )),
        ],
      ),
    );
  }

  Widget _permisoDenegado(String tituloVigentes) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          AppHeading(label: "Vista ${tituloVigentes.toLowerCase()} no disponible", fontSize: 16,),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              tituloVigentes.toLowerCase() == "entradas vigentes"
                  ? "Solicite permisos '212' y '213'"
                  : tituloVigentes.toLowerCase() == "salidas vigentes"
                      ? "Solicite permiso '207'"
                      : "",
              style: TextStyle(
                color: AppColors.semantics.text.secondary,
                fontSize: Fontsize.h3,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _sinVigentes(String tituloVigentes) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          AppHeading(label: tituloVigentes, fontSize: Fontsize.h2),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              "No hay ${tituloVigentes.toLowerCase()}",
              style: TextStyle(
                  color: AppColors.semantics.text.secondary,
                  fontSize: Fontsize.h3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(Envio e, VoidCallback funcion) {
    return Material(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: funcion,
        child: Container(
          height: 80,
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black12))
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      activeIndex == 0
                      ? "De ${cont.capitalizar(e.origen)}"
                      : activeIndex  == 1
                        ?  "A ${cont.capitalizar(e.destino)}"
                        : "${cont.capitalizar(e.origen)} → ${cont.capitalizar(e.destino)}",
                      style: TextStyle(
                        color: AppColors.semantics.text.body,
                        fontSize: Fontsize.body,
                        overflow: TextOverflow.ellipsis
                      ),
                      maxLines: 2,
                    )
                  ),
                  Expanded( 
                    flex: 2,
                    child: AppBadge(
                      text: e.estadoId == 109 ? "Enviado" : e.estadoId == 110 ? "Recibido" : e.estadoId == 111 ? "Observado" : "S/D",
                      type: e.estadoId == 109 ? AppBadgeType.information : e.estadoId == 110 ? AppBadgeType.success : e.estadoId == 111 ? AppBadgeType.warning : AppBadgeType.error,
                    )
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _tablaIconos(e)
            ],
          ),
        ),
      ),
    );
  }

  Widget _btnBottom() {
    return SolidButton(
      type: SolidButtonType.primary,
      leftIcon: Icons.add_rounded,
      text: "Nuevo traslado",
      onPressed: cont.contienePermiso(206)
          ? () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      NuevoTraslado(entidad: widget.entidad),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
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
            }
          : null,
    );
  }

  Widget _menuItem(IconData icon, String label, int index) {
    final bool isActive = activeIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => activeIndex = index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 0),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          constraints: const BoxConstraints(minHeight: 50),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(40),
            boxShadow: isActive
            ? [
              BoxShadow(
                color: Colors.black12.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ]
            : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isActive ? Colors.black87 : Colors.grey,
                size: icon == FontAwesomeIcons.warehouse ? 17 : 20,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  softWrap: false,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                    color: isActive ? Colors.black87 : Colors.grey,
                    overflow: TextOverflow.fade,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tablaIconos(Envio e) {
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
              Icon(FontAwesomeIcons.clock, size: 15, color: AppColors.semantics.text.secondary),
              "${cont.formatearFechayDia2(e.fecha)}, ${e.hora}",
            ),

            _cellIcon(
              Icon(CupertinoIcons.cube_box, size: 18, color: AppColors.semantics.text.secondary),
              e.cantidad.toString(),
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

}