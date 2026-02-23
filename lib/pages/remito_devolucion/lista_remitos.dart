// ignore_for_file: deprecated_member_use
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:vientri/components/heading/app_heading.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/pages/comunes/master/master_principal.dart';
import 'package:vientri/pages/controller.dart';
import 'package:vientri/pages/remito_devolucion/detalle_remito.dart';
import 'package:vientri/src/models/entidad.dart';
import 'package:vientri/src/models/remitoDevolucion.dart';

// ignore: must_be_immutable
class ListaRemitos extends StatefulWidget {
  final Entidad entidad;
  const ListaRemitos({super.key, required this.entidad});

  @override
  State<ListaRemitos> createState() => _ListaRemitosState();
}

class _ListaRemitosState extends State<ListaRemitos> {
  late Controller con;
  int activeIndex = 0;

  final List<RemitoDevolucion> _remitos = [];
  int _page = 1;
  bool _loading = false;
  bool _hasMore = true;

  final TextEditingController _controllerSearch = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  var equis = false.obs;
  var filtro = "".obs;

  final List<RemitoDevolucion> _remitosFiltrados = [];
  bool _buscando = false;

  @override
  void initState() {
    super.initState();
    con = Get.put(Controller(widget.entidad));
    _cargarRemitosDevolucion();
  }

  bool _match(RemitoDevolucion r, String q) {
    final query = q.toLowerCase();

    return r.cliente.toLowerCase().contains(query) ||
          r.idRemito.toString().contains(query) ||
          r.numeroRemito.toString().contains(query);
  }

  Future<void> _buscarRemitos(String value) async {
    filtro.value = value;
    _remitosFiltrados.clear();

    if (value.isEmpty) {
      setState(() {});
      return;
    }

    _buscando = true;

    int pageTmp = 1;
    bool hasMoreTmp = true;

    while (hasMoreTmp && _remitosFiltrados.isEmpty) {
      final nuevos = await con.listaRemitosDevolucion(pageTmp);

      if (nuevos.isEmpty) {
        hasMoreTmp = false;
        break;
      }

      final encontrados = nuevos.where((r) => _match(r, value)).toList();
      _remitosFiltrados.addAll(encontrados);

      pageTmp++;
    }

    _buscando = false;
    setState(() {});
  }

  Future<void> _cargarRemitosDevolucion({bool refresh = false}) async {
    if (_loading || (!_hasMore && !refresh)) return;

    if (refresh) {
      _page = 1;
      _hasMore = true;
      _remitos.clear();
    }

    setState(() => _loading = true);

    final nuevos = await con.listaRemitosDevolucion(_page);

    setState(() {
      _remitos.addAll(nuevos);
      _loading = false;
      _page++;

      if (nuevos.isEmpty) {
        _hasMore = false;
      }
    });
  }

  @override
  void dispose() {
    _controllerSearch.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MasterPage(
      title: "Emitir remito de devolución",
      onBack: () => Navigator.pop(context, true),
      onRefresh: () async {
        await _cargarRemitosDevolucion(refresh: true);
      },
      onLoadMore: () {
        _cargarRemitosDevolucion();
      },
      showKey: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                _menuItem(CupertinoIcons.square_pencil, "Emitir", 0),
                _menuItem(CupertinoIcons.book, "Historial", 1),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildContenido(),
        ],
      ),
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
                size: 20,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  softWrap: false,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isActive ? FontWeight.w500 : FontWeight.w400, color: isActive ? Colors.black87 : Colors.grey,
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

  Widget _buildContenido() {
    if (_remitos.isEmpty && _loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_remitos.isEmpty && !_loading) {
      return _sinVigentes("devoluciones pendientes");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchBar(),
        const SizedBox(height: 16),
        Text(
          "Seleccioná un remito para vincularle una devolución de artículos",
          style: TextStyle(
            fontSize: Fontsize.h3,
            color: AppColors.semantics.text.body,
          ),
        ),
        const SizedBox(height: 16),

        _buildVigentes(
          filtro.value.isEmpty ? _remitos : _remitosFiltrados
        ),

        if (_buscando)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: CircularProgressIndicator(),
        ),

        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            size: 20,
            color: Colors.grey.shade500,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onSubmitted: (value) {},
              focusNode: _focusNode,
              controller: _controllerSearch,
              onChanged: (value) {
                equis.value = value.isNotEmpty;
                _buscarRemitos(value);
              },
              decoration: InputDecoration(
                hintText: "Buscar remito",
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                isDense: true,
              ),
            ),
          ),
          if (equis.value)
          GestureDetector(
            onTap: () {
              _controllerSearch.clear();
              filtro.value = "";
              equis.value = false;
              _remitosFiltrados.clear();
              setState(() {});
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVigentes(List<RemitoDevolucion> vigentes) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Remitos de entrega sin facturar recientes",
            style: TextStyle(
              fontSize: Fontsize.h3,
              fontWeight: FontWeight.bold,
              color: AppColors.semantics.text.body,
            ),
          ),

          const SizedBox(height: 8),

          ...vigentes.map((t) => _card(t, () {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => DetalleRemito(entidad: widget.entidad, remitoDevolucion: t),
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
                _cargarRemitosDevolucion();
              }
            });
          })),
        ],
      ),
    );
  }

  Widget _card(RemitoDevolucion e, VoidCallback funcion) {
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
              Text(
                e.cliente,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: Fontsize.body,
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 1,
              ),
              Text(
                "ID ${e.idRemito}",
                style: TextStyle(
                  color: AppColors.semantics.text.body,
                  fontSize: Fontsize.body,
                  overflow: TextOverflow.ellipsis,
                )
              ),
              _tablaIconos(e),
            ],
          ),
        ),
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
              Icon(
                FontAwesomeIcons.clock,
                size: 15,
                color: AppColors.semantics.text.secondary,
              ),
              con.formatearFechayDia3(e.fechaRemito),
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
