import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vientri/components/badge/badge.dart';
import 'package:vientri/components/heading/heading.dart';
import 'package:vientri/components/listed_element/listed_element.dart';
import 'package:vientri/components/subtle_button/subtle_button.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/constants/app_shadows.dart';
import 'package:vientri/pages/catalogo/carrito_page.dart';
import 'package:vientri/pages/catalogo/rubros_page.dart';
import 'package:vientri/pages/comunes/login/login_controller.dart';
import 'package:vientri/pages/comunes/master/master_principal.dart';
import 'package:vientri/pages/comunes/permisos/permisos_page.dart';
import 'package:vientri/pages/controller.dart';
import 'package:vientri/src/models/entidad.dart';
import 'package:vientri/src/models/pedido.dart';

class ListaPedidos extends StatefulWidget {
  final Entidad entidad;
  final Pedido? pedido;

  const ListaPedidos({super.key, required this.entidad, this.pedido});

  @override
  State<ListaPedidos> createState() => _ListaPedidosState();
}

class _ListaPedidosState extends State<ListaPedidos> {
  final LoginController con = LoginController();
  late Controller cont;
  late Future<List<Pedido>> _futurePedidos;
  int cant = 10;
  final List<String> opciones = ["5", "10", "20", "50", "todos"];
  bool _isExpanded = false;

  String formatearFecha(String fechaStr) {
    final partes = fechaStr.split('-');
    if (partes.length != 3) return fechaStr;

    final year = int.tryParse(partes[0]);
    final month = int.tryParse(partes[1]);
    final day = int.tryParse(partes[2]);

    if (year == null || month == null || day == null) return fechaStr;

    final fecha = DateTime(year, month, day);
    final hoy = DateTime.now();
    final ayer = hoy.subtract(const Duration(days: 1));

    final fechaSolo = DateTime(fecha.year, fecha.month, fecha.day);
    final hoySolo = DateTime(hoy.year, hoy.month, hoy.day);
    final ayerSolo = DateTime(ayer.year, ayer.month, ayer.day);

    if (fechaSolo == hoySolo) {
      return 'Hoy';
    } else if (fechaSolo == ayerSolo) {
      return 'Ayer';
    } else {
      return DateFormat('d MMM. yyyy', 'es_ES').format(fecha);
    }
  }

  @override
  void initState() {
    super.initState();
    Get.delete<Controller>();
    cont = Get.put(Controller(widget.entidad));
    _futurePedidos = cont.listaPedidos();
  }

  void _recargar() {
    setState(() {
      _futurePedidos = cont.listaPedidos();
    });
  }

  Future<void> _pullToRefresh() async {
    _recargar();
    await _futurePedidos;
  }

  @override
  Widget build(BuildContext context) {
    return MasterPage(
      title: "Pedidos",
      onBack: () => Navigator.pop(context, true),
      onKeyTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) => PermisosPage(entidad: widget.entidad, titulo: "Permisos", idApp: 2),
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
        )).then((value) {
          setState(() {
            Get.delete<Controller>();
            cont = Get.put(Controller(widget.entidad));
            _futurePedidos = cont.listaPedidos();
          });
        });
      },
      //cont.screenPermisos(context, widget.entidad, "Permisos", 2),
      child: RefreshIndicator(
        onRefresh: _pullToRefresh,
        child: FutureBuilder<List<Pedido>>(
          future: _futurePedidos,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              final errorText = snapshot.error.toString();
              final isConnectionError = errorText.contains("ClientException with SocketException") &&
                  errorText.contains("net.vientri.com");
              final headerText = isConnectionError
                  ? "Error de conexión: se recomienda avisar a VIENTRI"
                  : "Error";

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
              return _sinVigentes();
            }

            final pedidos = snapshot.data!;
            final vigentes = pedidos
                .where((p) => p.estado.toUpperCase() == "EN CURSO")
                .toList()
              ..sort((a, b) => b.id.compareTo(a.id));

            final anteriores = pedidos
                .where((p) => p.estado.toUpperCase() != "EN CURSO")
                .toList()
              ..sort((a, b) => b.id.compareTo(a.id));

            final anterioresLimitados = anteriores.take(cant).toList();

            return Column(
              children: [
                // Vigentes
                vigentes.isNotEmpty
                    ? Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.semantics.border.action),
                          boxShadow: AppShadows.elementFocusShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  CupertinoIcons.info_circle,
                                  size: 28,
                                  color: AppColors.semantics.border.action,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Vigentes",
                                  style: TextStyle(
                                    color: AppColors.semantics.text.body,
                                    fontSize: Fontsize.h2,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ...vigentes.map(
                              (v) => InkWell(
                                onTap: () {
                                  Navigator.of(context)
                                      .push(
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation, secondaryAnimation) =>
                                          RubroPage(entidad: widget.entidad, pedido: v),
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
                                      transitionDuration:
                                          const Duration(milliseconds: 400),
                                    ),
                                  ).then((value) {
                                    if (value == true) _recargar();
                                  });
                                },
                                child: ListedElement(
                                  column1Content: ListedElementDoubleTextContent(
                                    topText:
                                        v.nameContacto != "" ? v.nameContacto : v.telefono,
                                    bottomText: v.telefono,
                                  ),
                                  column2Content: ListedElementTextContent(
                                    text: v.items == 1
                                        ? "${v.items} Art."
                                        : "${v.items} Arts.",
                                  ),
                                  column3Content: ListedElementBadgeContent(
                                    text: "En curso",
                                    type: AppBadgeType.action,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : _sinVigentes(),
            
                // Anteriores
                if (anteriores.isNotEmpty)
                  _anteriores(anteriores, anterioresLimitados),
              ],
            );
          },
        )
      )
    );
  }

  Widget _sinVigentes() => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.black12),
    ),
    child: Column(
      children: [
        const AppHeading(label: "Vigentes", fontSize: Fontsize.h2),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            "No hay pedidos vigentes",
            style: TextStyle(
              color: AppColors.semantics.text.secondary,
              fontSize: Fontsize.h3,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _anteriores(List<Pedido> anteriores, List<Pedido> anterioresLimitados) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Anteriores",
                    style: TextStyle(
                      color: AppColors.semantics.text.body,
                      fontSize: Fontsize.h2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        "Mostrar: ",
                        style: TextStyle(
                          color: AppColors.semantics.text.secondary,
                          fontSize: Fontsize.body,
                        ),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: cant == 99999 ? "todos" : cant.toString(),
                        items: ["5", "10", "20", "50", "todos"]
                            .map((opcion) => DropdownMenuItem<String>(
                                  value: opcion,
                                  child: Text(opcion),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            if (value == "todos") {
                              cant = 99999;
                            } else {
                              cant = int.parse(value!);
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...anterioresLimitados.map(
                (a) => InkWell(
                  onTap: () {
                    if (a.estado.toLowerCase() != "cancelado") {
                      Navigator.of(context)
                          .push(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              CarritoPage(entidad: widget.entidad, pedido: a),
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
                      )
                          .then((value) {
                        if (value == true) _recargar();
                      });
                    }
                  },
                  child: ListedElement(
                    column1Content: ListedElementDoubleTextContent(
                      topText: a.nameContacto != "" ? a.nameContacto : a.telefono,
                      bottomText: a.telefono,
                    ),
                    column2Content: ListedElementTextContent(
                      text: a.items == 1
                          ? "${a.items} Art."
                          : "${a.items} Arts.",
                    ),
                    column3Content: ListedElementBadgeContent(
                      text: a.estado.toUpperCase() == "EN CAJA"
                          ? "En caja"
                          : a.estado.toUpperCase() == "COBRADO"
                              ? "Cobrado"
                              : "S/D",
                      type: a.estado.toUpperCase() == "EN CAJA" ||
                              a.estado.toUpperCase() == "COBRADO"
                          ? AppBadgeType.success
                          : AppBadgeType.information,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (anteriores.length > 10)
          Center(
            child: InkWell(
              onTap: () {
                setState(() {
                  cant = anteriores.length < cant ? 10 : cant + 10;
                });
              },
              child: Text(
                anteriores.length < cant ? "Ver menos" : "Ver más",
                style: TextStyle(
                  color: AppColors.semantics.text.action,
                  fontSize: Fontsize.h3,
                ),
              ),
            ),
          ),
        const SizedBox(height: 64),
      ],
    );
  }
}
