// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vientri/components/action_sheet/action_sheet.dart';
import 'package:vientri/components/action_sheet_options/action_sheet_options.dart';
import 'package:vientri/components/badge/badge.dart';
import 'package:vientri/components/heading/heading.dart';
import 'package:vientri/components/search_bar/search_bar.dart';
import 'package:vientri/components/solid_button/solid_button.dart';
import 'package:vientri/components/subtle_button/subtle_button.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/constants/app_shadows.dart';
import 'package:vientri/constants/notificaciones.dart';
import 'package:vientri/pages/controller.dart';
import 'package:vientri/pages/traslados/estado_traslado.dart';
import 'package:vientri/src/models/articulo.dart';
import 'package:vientri/src/models/entidad.dart';
import 'package:vientri/src/models/envio.dart';
import 'package:vientri/src/models/opcion.dart';

// ignore: must_be_immutable
class NuevoTraslado extends StatefulWidget {
  Entidad entidad;
  Envio? envio;
  NuevoTraslado({super.key, required this.entidad, this.envio});

  @override
  State<NuevoTraslado> createState() => _NuevoTrasladoState();
}

class _NuevoTrasladoState extends State<NuevoTraslado> {
  late Controller con;
  String? _selectedOrigen = "";
  int _selectedOrigenId = -1;
  String? _selectedDestino = "";
  int _selectedDestinoId = -1;
  String? _selectedChofer = "";
  int _selectedChoferId = -1;
  String? _observacion = "";

  bool isLoading = true;

  List<Opcion> _misUbicaciones = [];
  List<Opcion> _opcionesDeposito = [];
  List<Opcion> _opcionesEmpleados = [];
  List<Articulo> _sugerencias = [];
  List<Articulo> _articulosSeleccionados = [];

  late TextEditingController _controller;
  late FocusNode _focusNode;

  // TECLADO FIJO
  final RxBool isPressed = false.obs;
  final RxString pressedKey = ''.obs;
  final value = 0.obs;
  int i = 0;

  @override
  void initState() {
    super.initState();
    con = Get.put(Controller(widget.entidad));
    _initCargarDatos();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    if (widget.envio != null) {
      _selectedOrigen = widget.envio!.origen;
      _selectedOrigenId = widget.envio!.origenId;
      _selectedDestino = widget.envio!.destino;
      _selectedDestinoId = widget.envio!.destinoId;
      _selectedChofer = widget.envio!.chofer;
      _selectedChoferId = widget.envio!.choferId;
      _observacion = widget.envio!.observacionReceptor;
      setState(() {
        _articulosSeleccionados = widget.envio!.articulos.map((art) {
          return Articulo(
            id: art.id,
            articuloDes: art.articuloDes,
            rubroDes: art.rubroDes,
            articuloCod: art.articuloCod,
            foto: art.foto,
            articuloId: art.articuloId,
            impoconiva: art.impoconiva,
            stk: art.stk - art.cantidad,
            rubroId: art.rubroId,
            cantidad: art.cantidad,
            cBarra: art.cBarra,
          );
        }).toList();
      });

    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onKeyTap(BuildContext context, String key) {
    if (key == '⌫') {
      if (value.value > 0) {
        final str = value.value.toString();
        value.value = str.length > 1 ? int.parse(str.substring(0, str.length - 1)) : 0;
      }
    } else {
      final newValue = value.value == 0 ? key : '${value.value}$key';
      final parsed = int.parse(newValue);

      if (parsed <= 9999999) {
        value.value = parsed;
      }
    }
  }

/*
  void abrirBusqueda2() async {
    value.value = 0;
    final popupController = SearchBarPopupController();
    SearchBarPopup.show(
      context,
      hintText: "Buscar artículo",
      searchResults: _sugerencias,
      mostrarCheckAgregado: false,
      controller: popupController,
      onChanged: (value) async {
        await Future.delayed(const Duration(milliseconds: 200));

        if (value.trim().isEmpty) {
          popupController.updateResults(_sugerencias);
        } else {
          final query = normalize(value);
          final terms = query.split(" ");

          final filtrados = _sugerencias.where((art) {
            final nombre = normalize(art.articuloDes.trim());
            final id = art.articuloCod.trim();
            return terms.every((t) => nombre.contains(t) || id.contains(t));
          }).toList();
          popupController.updateResults(filtrados);
        }
      },
      onOptionSelected: (mapaSeleccionado) {
        ActionSheet.show(
          context,
          title: "",
          onClose: () {
            Navigator.pop(context);
          },
          content: Column(
            children: [
              
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Row(
                  children: [
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildFruitImageFull(mapaSeleccionado.foto),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mapaSeleccionado.rubroDes.trimRight(),
                                style: TextStyle(
                                  fontSize: Fontsize.bodySmall,
                                  color: AppColors.semantics.text.body,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "#${mapaSeleccionado.articuloCod.toString().trim()}",
                                style: TextStyle(
                                  color: AppColors.semantics.text.secondary,
                                  fontSize: Fontsize.bodySmall,
                                )
                              ),
                            ],
                          ),
                          Text(
                            mapaSeleccionado.articuloDes.trim(),
                            style: TextStyle(
                              fontSize: Fontsize.body,
                              fontWeight: FontWeight.bold,
                              color: AppColors.semantics.text.body,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                    AppBadge(
                      text: "Stock: ${mapaSeleccionado.stk}",
                      type: AppBadgeType.warning,
                    )
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 32),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: AppShadows.elementFocusShadow,
                    border: Border.all(color: AppColors.semantics.border.action),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove, color: AppColors.semantics.border.action),
                        onPressed: () {
                          if (value.value > 0) value.value--;
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          value.value.toString(),
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add, color: AppColors.semantics.border.action),
                        onPressed: () {
                          if (value.value < 9999) value.value++;
                        },
                      ),
                    ],
                  ))
                )
              ),

              _teclado(),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: SubtleButton(
                        text: "Cancelar",
                        type: SubtleButtonType.error,
                        onPressed: () {Navigator.pop(context);}
                      ),
                    ),

                    Expanded(
                      child: SolidButton(
                        text: "Agregar",
                        leftIcon: Icons.add_rounded,
                        onPressed: () {
                          setState(() {
                            _articulosSeleccionados.add(
                              Articulo(
                                id: 1000 + Random().nextInt(99999 - 1000 + 1),
                                articuloDes: mapaSeleccionado.articuloDes,
                                rubroDes: mapaSeleccionado.rubroDes,
                                articuloCod: mapaSeleccionado.articuloCod,
                                foto: mapaSeleccionado.foto,
                                articuloId: mapaSeleccionado.articuloId,
                                impoconiva: mapaSeleccionado.impoconiva,
                                stk: mapaSeleccionado.stk - value.value,
                                rubroId: mapaSeleccionado.rubroId,
                                cantidad: value.value,
                                cBarra: mapaSeleccionado.cBarra
                              )
                            );
                            value.value = 0;
                            Navigator.pop(context);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
*/

  void abrirBusqueda(BuildContext context) async {
    value.value = 0;
    final popupController = SearchBarPopupController();
    popupController.updateResults(_sugerencias);
    SearchBarPopup.show(
      context,
      hintText: "Buscar artículo",
      searchResults: _sugerencias,
      mostrarCheckAgregado: true,
      controller: popupController,
      articulosAgregados: _articulosSeleccionados,
      onChanged: (value) async {
        await Future.delayed(const Duration(milliseconds: 200));

        if (value.trim().isEmpty) {
          popupController.updateResults(_sugerencias);
        } else {
          final query = normalize(value);
          final terms = query.split(" ");

          final filtrados = _sugerencias.where((art) {
            final nombre = normalize(art.articuloDes.trim());
            final id = art.articuloCod.trim();
            return terms.every((t) => nombre.contains(t) || id.contains(t));
          }).toList();

          popupController.updateResults(filtrados);
        }
      },
      onOptionSelected: (mapaSeleccionado) {
        setState(() {
          final existe = _articulosSeleccionados.any(
            (a) => a.articuloId == mapaSeleccionado.articuloId,
          );

          if (existe) {
            _articulosSeleccionados.removeWhere(
              (a) => a.articuloId == mapaSeleccionado.articuloId,
            );

            Get.rawSnackbar(
              message: "Eliminado: ${con.capitalizar(mapaSeleccionado.articuloDes.trim())}",
              backgroundColor: AppColors.semantics.text.error,
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(milliseconds: 1400),
              animationDuration: const Duration(milliseconds: 200),
            );
          } else {
            _modificarCantidades(mapaSeleccionado, false);
          }
        });
      },
    );
  }

  String normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[áàä]'), 'a')
        .replaceAll(RegExp(r'[éèë]'), 'e')
        .replaceAll(RegExp(r'[íìï]'), 'i')
        .replaceAll(RegExp(r'[óòö]'), 'o')
        .replaceAll(RegExp(r'[úùü]'), 'u')
        .replaceAll(RegExp(r'[^a-z0-9 ]'), '');
  }

  Future<void> _initCargarDatos() async {
    setState(() => isLoading = true);

    try {
      await Future.wait([
        cargarOpciones(),
        cargarArticulos(),
      ]);

      value.value = 0;
      _selectedOrigen = widget.entidad.ubicacion;
      _selectedOrigenId = widget.entidad.ubicacionId;
    } catch (e) {
      debugPrint("Error cargando datos: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> cargarOpciones() async {
    final data = widget.entidad.salones;
    final data2 = await con.listaEmpleados();
    final data3 = await con.listaDepositos();

    setState(() {
      _misUbicaciones = data.map((item) {
        var parts = item.split(' - ');
        return Opcion(
          id: int.parse(parts[0]),
          nombre: parts[1],
        );
      }).toList();
      _opcionesEmpleados = data2.toList()..sort((a, b) => a.nombre.compareTo(b.nombre));
      _opcionesDeposito = data3;
    });
  }

  Future<void> cargarArticulos() async {
    final data = await con.listaArticulos("", widget.entidad);
    setState(() {
      _sugerencias = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Container(
          color: const Color(0xFFF5F2FA),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título simulado
                _skeleton(width: 180, height: 22, borderRadius: 8),
                const SizedBox(height: 24),

                // Campos tipo formulario
                _skeleton(width: double.infinity, height: 45, borderRadius: 12),
                const SizedBox(height: 16),
                _skeleton(width: double.infinity, height: 45, borderRadius: 12),
                const SizedBox(height: 16),
                _skeleton(width: double.infinity, height: 45, borderRadius: 12),
                const SizedBox(height: 16),

                // Lista simulada de opciones
                Expanded(
                  child: ListView.builder(
                    itemCount: 2,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _skeleton(
                        width: double.infinity,
                        height: 150,
                        borderRadius: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: NotificationWrapper(
        child: Scaffold(
          body: Stack(
            children: [
              Container(
                color: const Color(0xFFF5F2FA)
              ),
              ListView(
                physics: const ClampingScrollPhysics(),
                children: [
                  const SizedBox(height: 20),
                  
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: AppHeading(
                            label: widget.envio != null ? "Editar envío" : "Nuevo envío",
                            fontSize: Fontsize.h1,
                            leadingIcon: Icons.arrow_back,
                            iconSize: 26,
                            onLeadingIconPressed: () {
                              Navigator.pop(context, true);
                            },
                          ),
                        ),
                        AppBadge(text: widget.envio != null ? "Editando" : "Preparando", type: AppBadgeType.action)
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black12)
                    ),
                    child: Column(
                      children: [
                        const AppHeading(
                          label: "Datos de traslado",
                          fontSize: Fontsize.h3,
                        ),
                        GestureDetector(
                          onTap: () {
                            if (widget.envio != null) return;
                            if (_misUbicaciones.isEmpty) return;
        
                            ActionSheetOptions.show(
                              context,
                              title: "Elegir origen",
                              options: _misUbicaciones,
                              onOptionSelected: (s) {
                                setState(() {
                                  _selectedOrigen = con.capitalizar(s.nombre);
                                  _selectedOrigenId = s.id;
                                });
                              },
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.black12),
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  "Origen",
                                  style: TextStyle(
                                    fontSize: Fontsize.body,
                                    color: AppColors.semantics.text.body,
                                  ),
                                ),
                                const Spacer(),
                                SizedBox(
                                  width: 200,
                                  child: Text(
                                    _misUbicaciones != [] ? con.capitalizar(_misUbicaciones.first.nombre) : "Elige un origen",
                                    style: TextStyle(
                                      color: widget.envio != null ? AppColors.semantics.text.secondary : AppColors.semantics.text.body,
                                      fontSize: Fontsize.body,
                                    ),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: Fontsize.h2,
                                  color: widget.envio != null ? AppColors.semantics.text.secondary : AppColors.semantics.text.body,
                                )
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (_opcionesDeposito.isEmpty) return;
        
                            ActionSheetOptions.show(
                              context,
                              title: "Elegir destino",
                              options: _opcionesDeposito,
                              onOptionSelected: (s) {
                                setState(() {
                                  _selectedDestino = con.capitalizar(s.nombre);
                                  _selectedDestinoId = s.id;
                                });
                              },
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.black12),
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  "Destino",
                                  style: TextStyle(
                                    fontSize: Fontsize.body,
                                    color: AppColors.semantics.text.body
                                  ),
                                ),
                                const Spacer(),
                                SizedBox(
                                  width: 200,
                                  child: Text(
                                    _selectedDestino == "" ? "Eige un destino" : con.capitalizar(_selectedDestino!),
                                    style: TextStyle(
                                      color: _selectedDestino == "" ? AppColors.semantics.text.secondary : AppColors.semantics.text.body,
                                      fontSize: Fontsize.body,
                                      overflow: TextOverflow.ellipsis
                                    ),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: Fontsize.h2,
                                  color: AppColors.semantics.text.body,
                                )
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (_opcionesDeposito.isEmpty) return;
        
                            ActionSheetOptions.show(
                              context,
                              title: "Elegir chofer",
                              options: _opcionesEmpleados,
                              onOptionSelected: (s) {
                                setState(() {
                                  _selectedChofer = con.capitalizar( s.nombre);
                                  _selectedChoferId = s.id;
                                });
                              },
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.black12),
                          
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  "Chofer",
                                  style: TextStyle(
                                    fontSize: Fontsize.body,
                                    color: AppColors.semantics.text.body
                                  ),
                                ),
                                const Spacer(),
                                SizedBox(
                                  width: 200,
                                  child: Text(
                                    _selectedChofer == "" ? "Eige un chofer" : con.capitalizarNombre(_selectedChofer!),
                                    style: TextStyle(
                                      color: _selectedChofer == "" ? AppColors.semantics.text.secondary : AppColors.semantics.text.body,
                                      fontSize: Fontsize.body
                                    ),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: Fontsize.h2,
                                  color: AppColors.semantics.text.body,
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  ),
                  
                  const SizedBox(height: 16),
                 
                  if (_articulosSeleccionados.isNotEmpty)
                  ClipRRect(
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              abrirBusqueda(context);
                            },
                            child: Container(
                              height: 50,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.black12)
                              ),  
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Buscar artículos",
                                    style: TextStyle(
                                      color: AppColors.semantics.text.secondary,
                                      fontSize: Fontsize.body
                                    ),
                                  ),
                                  Icon(
                                    Icons.search_rounded,
                                    color: AppColors.semantics.text.secondary,
                                    size: Fontsize.h2
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black12)
                          ),
                          child: Column(
                            children: [
                              ..._articulosSeleccionados.map((art) {
                                i++;
                                return Material(
                                  child: InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: () {
                                        _modificarCantidades(art, true);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    SizedBox(
                                                      width: MediaQuery.sizeOf(context).width * 0.5,
                                                      child: Text(
                                                        con.capitalizar(art.articuloDes.trim()),
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          color: AppColors.semantics.text.body,
                                                          fontSize: Fontsize.h3
                                                        ),
                                                        maxLines: 2,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(width: 8),
                                                Text("#${art.articuloCod.toString().trim()}", style: TextStyle(color: AppColors.semantics.text.secondary, fontSize: Fontsize.h3)),
                                                InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      _articulosSeleccionados.removeWhere(
                                                        (a) => a.articuloId == art.articuloId,
                                                      );
                                                      NotificationHelper.showError(
                                                        'Artículo eliminado',
                                                        onUndo: () {
                                                          setState(() {
                                                            _articulosSeleccionados.add(
                                                              Articulo(
                                                                id: art.id,
                                                                articuloDes: art.articuloDes,
                                                                rubroDes: art.rubroDes,
                                                                articuloCod: art.articuloCod,
                                                                foto: art.foto,
                                                                articuloId: art.articuloId,
                                                                impoconiva: art.impoconiva,
                                                                stk: art.stk - art.cantidad,
                                                                rubroId: art.rubroId,
                                                                cantidad: art.cantidad,
                                                                cBarra: art.cBarra
                                                              )
                                                            );
                                                          });
                                                          NotificationHelper.showSuccess('Artículo restaurado');
                                                        },
                                                      );
                                                    });
                                                  },
                                                  child: Icon(CupertinoIcons.delete, color: AppColors.semantics.text.error, size: 20)
                                                )
                                              ],
                                            ),
                                            Text(
                                              con.capitalizar(art.rubroDes.trim()),
                                              style: TextStyle(color: AppColors.semantics.text.body, fontSize: Fontsize.body, fontWeight: FontWeight.w100),
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                _filaIconos(
                                                  Icon(FontAwesomeIcons.warehouse, size: 15, color: AppColors.semantics.text.secondary),
                                                  art.stk.toString().trim(),
                                                  null
                                                ),
                                                _filaIconos(
                                                  Icon(CupertinoIcons.cube_box, size: 18, color: AppColors.semantics.text.secondary),
                                                  art.cantidad.toString(),
                                                  null
                                                ),
                                              ],
                                            ),
                                            if (i != _articulosSeleccionados.length)
                                            Divider(color: Colors.black12)
                                          ],
                                        ),
                                      ),
                                    ),
                                );
                              }),
                            ]
                          ),
                        ),
                      ]
                    )
                  ),

                  if (_articulosSeleccionados.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DottedBorder(
                      color: AppColors.semantics.text.action,
                      strokeWidth: 1,
                      dashPattern: const [12, 6],
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(8),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            AppHeading(label: "Artículos", fontSize: Fontsize.h3, textColor: AppColors.semantics.text.action),
                            const SizedBox(height: 16),
                                
                            SubtleButton(
                              text: "Agregar",
                              leftIcon: Icons.add_rounded,
                              onPressed: () {
                                abrirBusqueda(context);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  if (_observacion != "")
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
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
                              AppHeading(
                                label: "Observaciones",
                                fontSize: Fontsize.h3,
                                trailingIcon: Icons.delete_outline_rounded,
                                onTrailingIconPressed: () {
                                  setState(() {
                                    _observacion = "";
                                  });
                                },
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: const BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Colors.black12))
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(_observacion!, style: TextStyle(fontWeight: FontWeight.w100, color: AppColors.semantics.text.body)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              SubtleButton(
                                text: "Editar",
                                leftIcon: Icons.edit_rounded,
                                onPressed: () {
                                  _mostrarDialogoProblema();
                                  /*TextInputOverlay.show(
                                    context,
                                    hintText: "",
                                    initialText: _observacion ?? "",
                                    onSubmitted: (value) {
                                      setState(() {
                                        _observacion = value;
                                        Navigator.of(context).pop();
                                      });
                                    },
                                  );*/
                                },
                              ),
                            ],
                          )
                          ),
                      ],
                    ),
                  ),
                  
                  if (_observacion == "")
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        DottedBorder(
                          color: AppColors.semantics.text.action,
                          strokeWidth: 1,
                          dashPattern: const [12, 6],
                          borderType: BorderType.RRect,
                          radius: const Radius.circular(8),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                AppHeading(label: "Observaciones", fontSize: Fontsize.h3, textColor: AppColors.semantics.text.action),
                                const SizedBox(height: 16),
                                SubtleButton(
                                  text: "Agregar",
                                  leftIcon: Icons.add_rounded,
                                  onPressed: () {
                                    _mostrarDialogoProblema();
                                    /*TextInputOverlay.show(
                                      context,
                                      hintText: "Escribe una observación",
                                      onSubmitted: (value) {
                                        setState(() {
                                          _observacion = value;
                                          Navigator.of(context).pop();
                                        });
                                      },
                                    );*/
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SubtleButton(text: "Cancelar operación", type: SubtleButtonType.error, onPressed: () {
                      if (_selectedOrigen != "" || _selectedDestino != "" || _selectedChofer != "" || _articulosSeleccionados.isNotEmpty || _observacion != "") {
                        ActionSheet.show(
                          context,
                          title: "¿Cancelar operación?",
                          content: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Se eliminará el pedido actual.",
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
                                SubtleButton(
                                  text: "Eliminar envío",
                                  type: SubtleButtonType.error,
                                  onPressed: () {Navigator.pop(context); Navigator.pop(context);},
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        Navigator.pop(context);
                      }
                    }),
                  ),
                  
                  const SizedBox(height: 100),
                ]
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: _btnBottom()
              )
            ],
          ),
        ),
      ),
    );
  }

  void _modificarCantidades(Articulo art, bool modificar) {
    modificar ? value.value = art.cantidad : null;
    modificar
    ? ActionSheet.show(
      context,
      title: "",
      content: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Row(
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildFruitImageFull(art.foto),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            art.rubroDes.trimRight(),
                            style: TextStyle(
                              fontSize: Fontsize.bodySmall,
                              color: AppColors.semantics.text.body,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "#${art.articuloCod.toString().trim()}",
                            style: TextStyle(
                              color: AppColors.semantics.text.secondary,
                              fontSize: Fontsize.bodySmall,
                            )
                          ),
                        ],
                      ),
                      Text(
                        art.articuloDes.trim(),
                        style: TextStyle(
                          fontSize: Fontsize.body,
                          fontWeight: FontWeight.bold,
                          color: AppColors.semantics.text.body,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                AppBadge(
                  text: "Stock: ${art.stk}",
                  type: AppBadgeType.warning,
                )
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 32),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: AppShadows.elementFocusShadow,
                border: Border.all(color: AppColors.semantics.border.action),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove, color: AppColors.semantics.border.action),
                    onPressed: () {
                      if (value.value > 0) value.value--;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      value.value.toString(),
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: AppColors.semantics.border.action),
                    onPressed: () {
                      if (value.value < 9999) value.value++;
                    },
                  ),
                ],
              ))
            )
          ),

          _teclado(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SubtleButton(
                    text: "Cancelar",
                    type: SubtleButtonType.error,
                    onPressed: () {Navigator.pop(context);}
                  ),
                ),

                Expanded(
                  child: SolidButton(
                    text: "Guardar",
                    leftIcon: Icons.check,
                    onPressed: () {
                      setState(() {
                        final index = _articulosSeleccionados.indexWhere((a) => a.id == art.id);
                        _articulosSeleccionados[index].cantidad = value.value;

                        Get.rawSnackbar(
                          message: "Editado: ${con.capitalizar(art.articuloDes.trim())}",
                          backgroundColor: AppColors.semantics.text.success,
                          snackPosition: SnackPosition.BOTTOM,
                          duration: const Duration(milliseconds: 1400),
                          animationDuration: const Duration(milliseconds: 200),
                        );

                        value.value = 0;
                        Navigator.pop(context);
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
    : ActionSheet.show(
      context,
      title: "",
      onClose: () {
        Navigator.pop(context);
      },
      content: Column(
        children: [
          
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Row(
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildFruitImageFull(art.foto),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            art.rubroDes.trimRight(),
                            style: TextStyle(
                              fontSize: Fontsize.bodySmall,
                              color: AppColors.semantics.text.body,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "#${art.articuloCod.toString().trim()}",
                            style: TextStyle(
                              color: AppColors.semantics.text.secondary,
                              fontSize: Fontsize.bodySmall,
                            )
                          ),
                        ],
                      ),
                      Text(
                        art.articuloDes.trim(),
                        style: TextStyle(
                          fontSize: Fontsize.body,
                          fontWeight: FontWeight.bold,
                          color: AppColors.semantics.text.body,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                AppBadge(
                  text: "Stock: ${art.stk}",
                  type: AppBadgeType.warning,
                )
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 32),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: AppShadows.elementFocusShadow,
                border: Border.all(color: AppColors.semantics.border.action),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove, color: AppColors.semantics.border.action),
                    onPressed: () {
                      if (value.value > 0) value.value--;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      value.value.toString(),
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: AppColors.semantics.border.action),
                    onPressed: () {
                      if (value.value < 9999) value.value++;
                    },
                  ),
                ],
              ))
            )
          ),

          _teclado(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SubtleButton(
                    text: "Cancelar",
                    type: SubtleButtonType.error,
                    onPressed: () {Navigator.pop(context);}
                  ),
                ),

                Expanded(
                  child: SolidButton(
                    text: "Agregar",
                    leftIcon: Icons.add_rounded,
                    onPressed: () {
                      setState(() {
                        _articulosSeleccionados.add(
                          Articulo(
                            id: art.id,
                            articuloDes: art.articuloDes,
                            rubroDes: art.rubroDes,
                            articuloCod: art.articuloCod,
                            foto: art.foto,
                            articuloId: art.articuloId,
                            impoconiva: art.impoconiva,
                            hora: art.hora,
                            stk: art.stk,
                            rubroId: art.rubroId,
                            cantidad: value.value,
                            cBarra: art.cBarra,
                          ),
                        );

                        Get.rawSnackbar(
                          message: "Añadido: ${con.capitalizar(art.articuloDes.trim())}",
                          backgroundColor: AppColors.semantics.text.success,
                          snackPosition: SnackPosition.BOTTOM,
                          duration: const Duration(milliseconds: 1400),
                          animationDuration: const Duration(milliseconds: 200),
                        );

                        value.value = 0;
                        Navigator.pop(context);
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFruitImageFull(String base64Image) {
    final Uint8List decodedBytes;
    if (base64Image == "") {
      return Container(
        color: Colors.grey.shade100,
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.grey.shade400,
          size: MediaQuery.sizeOf(context).height * 0.05,
        ),
      );
    } else {
      decodedBytes = base64Decode(base64Image);
      try {
        return Image.memory(
          decodedBytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade100,
              child: Icon(
                Icons.image_not_supported_outlined,
                color: Colors.grey.shade400,
                size: MediaQuery.sizeOf(context).height * 0.05,
              ),
            );
          },
        );
      } catch (e) {
        return Container(
          color: Colors.grey.shade100,
          child: Icon(
            Icons.image_not_supported_outlined,
            color: Colors.grey.shade400,
            size: MediaQuery.sizeOf(context).height * 0.05,
          ),
        );
      }
    }
  }

  Widget _btnBottom() {
    return SolidButton(
      type: SolidButtonType.primary,
      text: "Enviar",
      leftIcon: Icons.local_shipping_outlined,
      onPressed: _selectedOrigen != "" && _selectedDestino != "" && _selectedChofer != "" && _articulosSeleccionados.isNotEmpty
      ? widget.envio != null
        ? () async {
          print("SE EDITO UN PEDIDO");
          bool ok = await con.editarTraslado(widget.envio!);
          if (ok) {
            Navigator.of(context).push(PageRouteBuilder( pageBuilder: (context, animation, secondaryAnimation) => EstadoTraslado(
                entidad: widget.entidad,
                envio: widget.envio!,
                label: "Envío editado",
                icon: Icons.check_circle_outline_rounded,
                color: AppColors.semantics.text.success,
                observacion: _observacion ?? "",
              ),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
                return SlideTransition(position: animation.drive(tween), child: child);
              },
              transitionDuration: const Duration(milliseconds: 400),
            ));
          } else {
            Get.rawSnackbar(
              message: "Error: No se pudo editar el envío",
              backgroundColor: AppColors.semantics.text.error,
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(milliseconds: 2000),
              animationDuration: const Duration(milliseconds: 250),
            );
          }
        }
       : () async {
          print("SE REALIZO UN ENVIO");
          Envio envio = Envio(
            id: 0,
            estadoId: 0,
            estadoName: "",
            emisor: widget.entidad.nombre,
            emisorId: widget.entidad.id,
            receptor: "",
            receptorId: -1,
            origen: _selectedOrigen!,
            origenId: _selectedOrigenId,
            destino: _selectedDestino!,
            destinoId: _selectedDestinoId,
            chofer: _selectedChofer!,
            choferId: _selectedChoferId,
            observacionEmisor: _observacion ?? "",
            observacionReceptor: "",
            cantidad: _articulosSeleccionados.length,
            hora: DateFormat('HH:mm').format(DateTime.now()),
            fecha: DateFormat('dd/MM/yyyy').format(DateTime.now()),
            articulos: _articulosSeleccionados,
          );
          bool rtaOk = await con.registrarTraslado(envio);
          if (rtaOk) {
            Navigator.of(context).push(PageRouteBuilder( pageBuilder: (context, animation, secondaryAnimation) => EstadoTraslado(
                entidad: widget.entidad,
                envio: envio,
                label: "Pedido enviado",
                icon: Icons.check_circle_outline_rounded,
                color: AppColors.semantics.text.success,
                observacion: _observacion ?? "",
              ),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
                return SlideTransition(position: animation.drive(tween), child: child);
              },
              transitionDuration: const Duration(milliseconds: 400),
            ));
          } else {
            Get.rawSnackbar(
              message: "Error: No se pudo envíar",
              backgroundColor: AppColors.semantics.text.error,
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(milliseconds: 2000),
              animationDuration: const Duration(milliseconds: 250),
            );
          }
        }
      : null
    );
  }

  Widget _teclado() {
    const keyStyle = TextStyle(fontSize: 24, fontWeight: FontWeight.w600);

    Widget buildKey(
      String key, {
      Color? color,
      Color? textColor,
      IconData? icon,
      bool? agregar,
      double? height,
      double? width,
    }) {
      return Obx(() {
        final isPressedKey = pressedKey.value == key;
        return GestureDetector(
          onTapDown: (_) => pressedKey.value = key,
          onTapUp: (_) {
            Future.delayed(const Duration(milliseconds: 100), () {
              pressedKey.value = '';
            });
            _onKeyTap(context, key);
          },
          onTapCancel: () => pressedKey.value = '',
          child: AnimatedContainer(
            margin: const EdgeInsets.only(bottom: 16),
            height: height,
            duration: const Duration(milliseconds: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              boxShadow: isPressedKey
              ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 0,
                  offset: const Offset(0, 0),
                ),
              ]
              : []
            ),
            child: Center(
              child: Text(key, style: keyStyle.copyWith(color: textColor, fontSize: 24, fontWeight: FontWeight.w500 )),
            ),
          ),
        );
      });
    }

    final keyWidth = MediaQuery.sizeOf(context).width / 5;
    final keyHeight = MediaQuery.sizeOf(context).height * 0.06;
    return Container(
        margin: const EdgeInsets.only(left: 32, right: 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Table(
              defaultColumnWidth: const FlexColumnWidth(1),
              children: [
                TableRow(children: [
                  buildKey('1', width: keyWidth, height: keyHeight),
                  buildKey('2', width: keyWidth, height: keyHeight),
                  buildKey('3', width: keyWidth, height: keyHeight),
                ]),
                TableRow(children: [
                  buildKey('4', width: keyWidth, height: keyHeight),
                  buildKey('5', width: keyWidth, height: keyHeight),
                  buildKey('6', width: keyWidth, height: keyHeight),
                ]),
                TableRow(children: [
                  buildKey('7', width: keyWidth, height: keyHeight),
                  buildKey('8', width: keyWidth, height: keyHeight),
                  buildKey('9', width: keyWidth, height: keyHeight),
                ]),
                TableRow(children: [
                  const SizedBox.shrink(),
                  buildKey('0', width: keyWidth, height: keyHeight),
                  buildKey('⌫', width: keyWidth, height: keyHeight),
                ]),
              ],
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
                    text: "Aceptar",
                    onPressed: () async {
                      setState(() {
                        _observacion = _controller.text;
                      });
                      Navigator.pop(context, true);
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

  Widget _skeleton({
    required double width,
    required double height,
    double borderRadius = 8,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.white.withOpacity(0.4),
            Colors.white.withOpacity(0.7),
            Colors.white.withOpacity(0.4),
          ],
          stops: const [0.1, 0.3, 0.9],
        ),
      ),
    );
  }

  Widget _filaIconos(Icon icon, String content, Color? color) {
    return Row(
      children: [
        icon,
        const SizedBox(width: 8),
        Text(
          content,
          style: TextStyle(
            color: color ?? AppColors.semantics.text.secondary,
            fontSize: Fontsize.body,
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }


}