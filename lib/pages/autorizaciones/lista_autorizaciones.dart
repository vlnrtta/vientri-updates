import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vientri/pages/autorizaciones/detalle_autorizacion.dart';
import 'package:vientri/pages/comunes/master/master_principal.dart';
import 'package:vientri/pages/comunes/permisos/permisos_page.dart';
import 'package:get/get.dart';
import 'package:vientri/components/heading/heading.dart';
import 'package:vientri/components/subtle_button/subtle_button.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/constants/app_shadows.dart';
import 'package:vientri/pages/controller.dart';
import 'package:flutter/material.dart';
import 'package:vientri/src/models/autorizacion.dart';
import 'package:vientri/src/models/entidad.dart';
import 'package:vientri/src/models/opcion.dart';

// ignore: must_be_immutable
class ListaAutorizaciones extends StatefulWidget {
  Entidad entidad;
  ListaAutorizaciones({super.key, required this.entidad});

  @override
  State<ListaAutorizaciones> createState() => _ListaAutorizacionesState();
}

class _ListaAutorizacionesState extends State<ListaAutorizaciones> {
  late Controller cont;
  late Future<List<Autorizacion>> _futureAutorizaciones;
  List<Opcion> optionSelectedHistory = [];
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    cont = Get.put(Controller(widget.entidad));
    _futureAutorizaciones = cont.listaAutorizaciones();
  }

  void _recargar() {
    setState(() {
      _futureAutorizaciones = cont.listaAutorizaciones();
    });
  }

  Future<void> _pullToRefresh() async {
    _recargar();
    await _futureAutorizaciones;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MasterPage(
      title: "Autorizaciones",
      onBack: () => Navigator.pop(context, true),
      onKeyTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) => PermisosPage(entidad: widget.entidad, titulo: "Permisos", idApp: 3),
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
            _futureAutorizaciones = cont.listaAutorizaciones();
          });
        });
      },//cont.screenPermisos(context, widget.entidad, "Permisos", 3),
      onRefresh: () async {
        setState(() {
          _futureAutorizaciones = cont.listaAutorizaciones();
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          RefreshIndicator(
            onRefresh: _pullToRefresh,
            child: FutureBuilder<List<Autorizacion>>(
              future: _futureAutorizaciones,
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
                        AppHeading(label: "Entrantes", fontSize: Fontsize.h2),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            "No hay autorizaciones pendientes",
                            style: TextStyle(
                              color: AppColors.semantics.text.secondary,
                              fontSize: Fontsize.h3
                            ),
                          ),
                        )
                      ],
                    )
                  );
                }
                
                final autorizaciones = snapshot.data!;
                
                var vigentes = autorizaciones
                  .toList()
                  ..sort((a, b) => b.fecha.compareTo(a.fecha));
          
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
                             "Entrantes",
                              style: TextStyle(
                                color: AppColors.semantics.text.action,
                                fontSize: Fontsize.h2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...vigentes.map((v) =>
                            _card(
                              v, 
                              () {
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) => DetalleAutorizacion(entidad: widget.entidad, autorizacion: v),
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
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Column(
                        children: [
                          AppHeading(label: "Entrantes", fontSize: Fontsize.h2),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              "No hay autorizaciones pendientes",
                              style: TextStyle(
                                color: AppColors.semantics.text.secondary,
                                fontSize: Fontsize.h3
                              ),
                            ),
                          )
                        ],
                      )
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(Autorizacion autorizacion, VoidCallback funcion) {
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
                    child: Text(
                      cont.capitalizar(autorizacion.tipoAutorizacion.trim()),
                      style: TextStyle(
                        color: AppColors.semantics.text.body,
                        fontSize: Fontsize.body,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              Expanded(
                child: Text(
                  cont.capitalizarNombre(autorizacion.apeNomCliente.trim()),
                  style: TextStyle(
                    color: AppColors.semantics.text.body,
                    fontSize: Fontsize.body,
                  ),
                ),
              ),

              Expanded(
                child: _tablaIconos(autorizacion),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tablaIconos(Autorizacion autorizacion) {
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
              Icon(CupertinoIcons.calendar, size: 18, color: AppColors.semantics.text.secondary,),
              cont.formatearFechayDia3(autorizacion.fecha),
            ),

            _cellIcon(
              Icon(FontAwesomeIcons.user, size: 15, color: AppColors.semantics.text.secondary,),
              cont.capitalizarNombre(autorizacion.apeNomUsuario),
            ),

          ],
        ),
      ],
    );
  }

  Widget emptyCell() {
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