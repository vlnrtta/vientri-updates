// ignore_for_file: deprecated_member_use
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:vientri/components/action_sheet_options/action_sheet_options.dart';
import 'package:vientri/components/badge/badge.dart';
import 'package:vientri/components/heading/app_heading.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/constants/app_shadows.dart';
import 'package:vientri/pages/ordenes_preparacion/detalle_orden_entrega.dart';
import 'package:vientri/pages/comunes/master/master_principal.dart';
import 'package:vientri/pages/comunes/permisos/permisos_page.dart';
import 'package:vientri/pages/controller.dart';
import 'package:vientri/src/models/entidad.dart';
import 'package:vientri/src/models/opcion.dart';
import 'package:vientri/src/models/ordenEntrega.dart';
import 'package:vientri/src/models/remitoEntrega.dart';

// ignore: must_be_immutable
class ListaOrdenesEntrega extends StatefulWidget {
  final Entidad entidad;
  const ListaOrdenesEntrega({super.key, required this.entidad});

  @override
  State<ListaOrdenesEntrega> createState() => _ListaOrdenesEntregaState();
}

class _ListaOrdenesEntregaState extends State<ListaOrdenesEntrega> {
  late Controller con;

  final List<OrdenEntrega> _ordenesEntrega = [];
  final List<RemitoEntrega> _remitosEntrega = [];

  int _pageOrdenes = 1;
  int _pageRemitos = 1;
  bool _loadingOrdenes = false;
  bool _loadingRemitos = false;
  bool _hasMoreOrdenes = true;
  bool _hasMoreRemitos = true;

  List<Opcion> _opcionesDeposito = [];
  String _ubicacion = "";
  int _ubicacionId = -1;

  @override
  void initState() {
    super.initState();
    con = Get.put(Controller(widget.entidad));
    
    cargarOpciones();
  }

  void cargarOpciones() async {
    final data = await con.listaDepositos();
    setState(() {
      _opcionesDeposito = data;
      _ubicacion = _opcionesDeposito.first.nombre;
      _ubicacionId = _opcionesDeposito.first.id;
    });
    _cargarPedidosPendientes(refresh: true);
    _cargarRemitosEntrega(refresh: true);
  }

  Future<void> _cargarPedidosPendientes({bool refresh = false}) async {
    if (_loadingOrdenes || (!_hasMoreOrdenes && !refresh)) return;

    if (refresh) {
      _pageOrdenes = 1;
      _hasMoreOrdenes = true;
      _ordenesEntrega.clear();
    }

    setState(() => _loadingOrdenes = true);

    final nuevos = await con.listaOrdenesEntrega(_pageOrdenes, _ubicacionId);

    setState(() {
      _ordenesEntrega.addAll(nuevos);
      _loadingOrdenes = false;
      _pageOrdenes++;

      if (nuevos.isEmpty) {
        _hasMoreOrdenes = false;
      }
    });
  }

  Future<void> _cargarRemitosEntrega({bool refresh = false}) async {
    if (_loadingRemitos || (!_hasMoreRemitos && !refresh)) return;

    if (refresh) {
      _pageRemitos = 1;
      _hasMoreRemitos = true;
      _remitosEntrega.clear();
    }

    setState(() => _loadingRemitos = true);

    final nuevos = await con.listaRemitosEntregados(_pageRemitos, _ubicacionId);

    setState(() {
      _remitosEntrega.addAll(nuevos);
      _loadingRemitos = false;
      _pageRemitos++;

      if (nuevos.isEmpty) {
        _hasMoreRemitos = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterPage(
      title: "Órdenes de entrega",
      onBack: () => Navigator.pop(context, true),
      onKeyTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => PermisosPage(entidad: widget.entidad, titulo: "Permisos", idApp: 9),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
              return SlideTransition(position: animation.drive(tween), child: child);
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        ).then((_) async {
          setState(() {
            Get.delete<Controller>();
            con = Get.put(Controller(widget.entidad));
          });
          await _cargarPedidosPendientes(refresh: true);
          await _cargarRemitosEntrega(refresh: true);
        });
      },
      onRefresh: () async {
        await _cargarPedidosPendientes(refresh: true);
        await _cargarRemitosEntrega(refresh: true);
      },
      onLoadMore: () {},
      showKey: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          InkWell(
            onTap: () {
              ActionSheetOptions.show(
                context,
                title: "Elegir ubicación",
                options: _opcionesDeposito,
                onOptionSelected: (s) {
                  setState(() {
                    _ubicacion = con.capitalizar(s.nombre);
                    _ubicacionId = s.id;
                    _cargarPedidosPendientes(refresh: true);
                    _cargarRemitosEntrega(refresh: true);
                  });
                },
              );
            },
            child: Row(
              children: [
                Icon(Icons.location_on_outlined, color: AppColors.semantics.text.action),
                const SizedBox(width: 4),
                Text(
                  con.capitalizar(_ubicacion),
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
          _buildContenido(),
        ],
      ),
    );
  }

  Widget _buildContenido() {
    if (_ordenesEntrega.isEmpty && _loadingOrdenes) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_ordenesEntrega.isEmpty && !_loadingOrdenes) {
      return _sinVigentes("pedidos pendientes");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildVigentes(_ordenesEntrega),
        
        if (_hasMoreOrdenes)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildVerMasButton(() => _cargarPedidosPendientes(), _loadingOrdenes),
          ),
        
        const SizedBox(height: 16),

        if (_remitosEntrega.isNotEmpty)
          _buildRemitos(_remitosEntrega)
        else if (!_loadingRemitos)
          _sinVigentes("Historial (Remitos)"),

        if (_remitosEntrega.isNotEmpty && _hasMoreRemitos)
          _buildVerMasButton(() => _cargarRemitosEntrega(), _loadingRemitos),
      ],
    );
  }

  Widget _buildVigentes(List<OrdenEntrega> vigentes) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: AppShadows.containerShadow,
        border: Border.all(color: AppColors.semantics.border.action),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Pendientes",
            style: TextStyle(
              fontSize: Fontsize.h3,
              fontWeight: FontWeight.bold,
              color: AppColors.semantics.text.body,
            ),
          ),

          ...vigentes.map((p) => _cardOrden(p, () {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => DetalleOrdenEntrega(entidad: widget.entidad, ordenEntrega: p, ubicacion: Opcion(id: _ubicacionId, nombre: _ubicacion)),
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
            ).then((_) async {
              await _cargarPedidosPendientes(refresh: true);
              await _cargarRemitosEntrega(refresh: true);
            });
          })),
        ],
      ),
    );
  }

  Widget _buildRemitos(List<RemitoEntrega> remitos) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: AppShadows.containerShadow,
        border: Border.all(color: AppColors.semantics.border.action),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Historial (Remitos)",
            style: TextStyle(
              fontSize: Fontsize.h3,
              fontWeight: FontWeight.bold,
              color: AppColors.semantics.text.body,
            ),
          ),

          ...remitos.map((r) => _cardRemito(r)),
        ],
      ),
    );
  }

  Widget _buildVerMasButton(VoidCallback onPressed, bool isLoading) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      child: Center(
        child: TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.semantics.text.action,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.semantics.text.action),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Ver más",
                    style: TextStyle(
                      fontSize: Fontsize.body,
                      color: AppColors.semantics.text.action,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.expand_more,
                    color: AppColors.semantics.text.action,
                    size: 20,
                  ),
                ],
              ),
        ),
      ),
    );
  }

  Widget _cardOrden(OrdenEntrega e, VoidCallback funcion) {
    return Material(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: funcion,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      con.capitalizarNombre(e.cliente),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: Fontsize.body,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1,
                    ),
                  ),
                  
                  AppBadge(
                    text: e.idCmpEstado == 14 || e.idSubEstado == 5 // Listo para facturar
                      ? "Preparado"
                      : e.idCmpEstado == 0 // Preparar
                        ? "Preparar"
                        : e.idCmpEstado == 87 // En preparación
                          ? "En preparación..."
                          : "${e.estadoCmp} ${e.idCmpEstado}",
                    type: e.idCmpEstado == 14 || e.idSubEstado == 5 // Listo para facturar
                      ? AppBadgeType.information
                      : e.idCmpEstado == 0 // Preparar
                        ? AppBadgeType.action
                        : e.idCmpEstado == 87 // En preparación
                          ? AppBadgeType.actionSecondary
                          : AppBadgeType.success,
                  )
                ],
              ),
              Text(
                e.facturaAsociada,
                style: TextStyle(
                  color: AppColors.semantics.text.body,
                  fontSize: Fontsize.body,
                  overflow: TextOverflow.ellipsis,
                )
              ),
              _tablaIconosOrden(e),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardRemito(RemitoEntrega r) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  con.capitalizarNombre(r.cliente),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: Fontsize.body,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 1,
                ),
              ),
              
              AppBadge(
                text: "Entregado",
                type: AppBadgeType.success,
              )
            ],
          ),
          Text(
            r.nroCmp,
            style: TextStyle(
              color: AppColors.semantics.text.body,
              fontSize: Fontsize.body,
              overflow: TextOverflow.ellipsis,
            )
          ),
          _tablaIconosRemito(r),
        ],
      ),
    );
  }

  Widget _tablaIconosOrden(OrdenEntrega e) {
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
              Icon(
                FontAwesomeIcons.clock,
                size: 15,
                color: AppColors.semantics.text.secondary,
              ),
              con.formatearFechayDia3(e.fechaFactura),
            ),

            _cellIcon(
              Icon(
                CupertinoIcons.cube_box,
                size: 15,
                color: AppColors.semantics.text.secondary,
              ),
              e.cantidadItems != 1 ? "${e.cantidadItems} Arts.": "${e.cantidadItems} Art.",
            ),
          ],
        ),
      ],
    );
  }

  Widget _tablaIconosRemito(RemitoEntrega r) {
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: const {
        0: IntrinsicColumnWidth(),
        1: IntrinsicColumnWidth(),
      },
      children: [
        TableRow(
          children: [
            _cellIcon(
              Icon(
                FontAwesomeIcons.calendar,
                size: 15,
                color: AppColors.semantics.text.secondary,
              ),
              con.formatearFechayDia3(r.fecCmp),
            ),

            _cellIcon(
              Icon(
                CupertinoIcons.cube_box,
                size: 15,
                color: AppColors.semantics.text.secondary,
              ),
              r.cantidaditems != 1 ? "${r.cantidaditems} Arts." : "${r.cantidaditems} Art.",
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

  Widget _sinVigentes(String titulo) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
        color: Colors.white,
      ),
      child: Column(
        children: [
          AppHeading(label: titulo, fontSize: Fontsize.h2),
          const SizedBox(height: 16),
          Text(
            "No hay ${titulo.toLowerCase()}",
            style: TextStyle(
              color: AppColors.semantics.text.secondary,
              fontSize: Fontsize.h3,
            ),
          ),
        ],
      ),
    );
  }
}
