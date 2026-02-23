// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, unused_element
import 'dart:convert';
import 'dart:typed_data';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vientri/components/action_sheet/action_sheet.dart';
import 'package:vientri/components/action_sheet_options/action_sheet_options.dart';
import 'package:vientri/components/badge/badge.dart';
import 'package:vientri/components/heading/heading.dart';
import 'package:vientri/components/search_bar/search_bar_controles_filtros.dart';
import 'package:vientri/components/solid_button/solid_button.dart';
import 'package:vientri/components/subtle_button/subtle_button.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/constants/notificaciones.dart';
import 'package:vientri/pages/controller.dart';
import 'package:vientri/pages/stock/estado_control.dart';
import 'package:vientri/src/models/articulo.dart';
import 'package:vientri/src/models/control.dart';
import 'package:vientri/src/models/entidad.dart';
import 'package:vientri/src/models/opcion.dart';

// ignore: must_be_immutable
class AsignarControl extends StatefulWidget {
  Entidad entidad;
  AsignarControl({super.key, required this.entidad});

  @override
  State<AsignarControl> createState() => _AsignarControlState();
}

class _AsignarControlState extends State<AsignarControl> {
  late Controller con;
  String? _selectedOrigen = "";
  int _selectedOrigenId = -1;
  String? _selectedEmpleado = "";
  int _selectedEmpleadoId = -1;
  int i = 0;

  List<Opcion> _opcionesDeposito = [];
  List<Opcion> _opcionesEmpleados = [];
  List<Articulo> _sugerencias = [];
  final List<Articulo> _articulosSeleccionados = [];
  
  @override
  void initState() {
    super.initState();
    con = Get.put(Controller(widget.entidad));
    cargarOpciones();
    cargarArticulos();
    _selectedOrigen = widget.entidad.ubicacion;
    _selectedOrigenId = widget.entidad.ubicacionId;
  }

  void abrirBusqueda(BuildContext context) async {
    final popupController = SearchBarPopupController();

    popupController.updateResults(_sugerencias);

    SearchBarPopup.show(
      context,
      hintText: "Buscar artículo",
      sugerencias: _sugerencias,
      controller: popupController,
      articulosAgregados: _articulosSeleccionados,
      onOptionSelected: (mapaSeleccionado) {
        setState(() {
          final existe = _articulosSeleccionados.any(
            (a) => a.articuloId == mapaSeleccionado.articuloId,
          );

          if (existe) {
            _articulosSeleccionados.removeWhere(
              (a) => a.articuloId == mapaSeleccionado.articuloId,
            );
            /*
            Get.rawSnackbar(
              message: "Eliminado: ${con.capitalizar(mapaSeleccionado.articuloDes.trim())}",
              backgroundColor: AppColors.semantics.text.error,
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(milliseconds: 1400),
              animationDuration: const Duration(milliseconds: 200),
            );*/
          } else {
            _articulosSeleccionados.add(
              Articulo(
                id: mapaSeleccionado.id,
                articuloDes: mapaSeleccionado.articuloDes,
                rubroDes: mapaSeleccionado.rubroDes,
                articuloCod: mapaSeleccionado.articuloCod,
                foto: mapaSeleccionado.foto,
                articuloId: mapaSeleccionado.articuloId,
                impoconiva: mapaSeleccionado.impoconiva,
                hora: mapaSeleccionado.hora,
                stk: mapaSeleccionado.stk,
                rubroId: mapaSeleccionado.rubroId,
                cantidad: mapaSeleccionado.stk,
                cBarra: mapaSeleccionado.cBarra,
              ),
            );
            /*
            Get.rawSnackbar(
              message: "Añadido: ${con.capitalizar(mapaSeleccionado.articuloDes.trim())}",
              backgroundColor: AppColors.semantics.text.success,
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(milliseconds: 1400),
              animationDuration: const Duration(milliseconds: 200),
            );*/
          }
        });
      },

    );
  }

  void cargarArticulos() async {
    final data = await con.listaArticulos("", widget.entidad);
    setState(() {
      _sugerencias = data;
    });
  }
  
  void cargarOpciones() async {
    final data = await con.listaDepositos();
    final data2 = await con.listaEmpleados([217, 218]);
    setState(() {
      _opcionesDeposito = data;
      _opcionesEmpleados = data2.toList()..sort((a, b) => a.nombre.compareTo(b.nombre));
    });
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

  @override
  Widget build(BuildContext context) {
    i = 0;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: NotificationWrapper(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFF0E4FF),
                      Color(0xFFF5F5F5),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

              ListView(
                physics: const ClampingScrollPhysics(),
                children: [
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: AppHeading(
                              label: "Nuevo control",
                              fontSize: Fontsize.h1,
                              leadingIcon: Icons.arrow_back,
                              iconSize: 26,
                              onLeadingIconPressed: () {
                                Navigator.pop(context, true);
                              },
                            ),
                          ),
                          AppBadge(
                            text: "Borrador",
                            type: AppBadgeType.warning
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(8),
                      /*boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],*/
                    ),
                    child: Column(
                      children: [
                        const AppHeading(
                          label: "Datos del control",
                          fontSize: Fontsize.h3,
                        ),
                        GestureDetector(
                          onTap: () {
                            if (_opcionesDeposito.isEmpty) return;
        
                            ActionSheetOptions.show(
                              context,
                              title: "Elegir ubicación",
                              options: _opcionesDeposito,
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
                                  "Ubicación",
                                  style: TextStyle(
                                    fontSize: Fontsize.body,
                                    color: AppColors.semantics.text.body,
                                  ),
                                ),
                                const Spacer(),
                                SizedBox(
                                  child: Text(
                                    _selectedOrigen == "" ? "Eige una ubicación" : con.capitalizar(_selectedOrigen!),
                                    style: TextStyle(
                                      color: AppColors.semantics.text.body,
                                      fontSize: Fontsize.body,
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
                            if (_opcionesEmpleados.isEmpty) return;
                            ActionSheetOptions.show(
                              context,
                              title: "Elegir empleado",
                              options: _opcionesEmpleados,
                              onOptionSelected: (s) {
                                setState(() {
                                  _selectedEmpleado = con.capitalizar(s.nombre);
                                  _selectedEmpleadoId = s.id;
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
                                  "Empleado",
                                  style: TextStyle(
                                    fontSize: Fontsize.body,
                                    color: AppColors.semantics.text.body
                                  ),
                                ),
                                const Spacer(),
                                SizedBox(
                                  child: Text(
                                    _selectedEmpleado == "" ? "Eige un empleado" : con.capitalizar(_selectedEmpleado!),
                                    style: TextStyle(
                                      color: _selectedEmpleado == "" ? AppColors.semantics.text.secondary : AppColors.semantics.text.body,
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
                      ],
                    )
                  ),
                  
                  const SizedBox(height: 20),

                  if (_articulosSeleccionados.isNotEmpty)
                  ClipRRect(
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            /*boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],*/
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
                            /*boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],*/
                          ),
                          child: Column(
                            children: [
                              ..._articulosSeleccionados.map((art) {
                                i++;
                                return Material(
                                  child: InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: () {
                                        /*
                                        ActionBottomSheet.show(
                                          context,
                                          title: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: _buildFruitImageFull(art.foto),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      con.capitalizar(art.articuloDes.trim()),
                                                      style: TextStyle(
                                                        fontSize: Fontsize.body,
                                                        color: AppColors.semantics.text.body,
                                                        fontWeight: FontWeight.bold
                                                      ),
                                                    ),
                                                    Text(
                                                      con.capitalizar(art.rubroDes.trim()),
                                                      style: TextStyle(
                                                        fontSize: Fontsize.body,
                                                        color: AppColors.semantics.text.body,
                                                      ),
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          '#${art.articuloCod}',
                                                          style: TextStyle(
                                                            fontSize: Fontsize.body,
                                                            color: AppColors.semantics.text.secondary,
                                                          ),
                                                        ),
                                                        const Spacer(),
                                                        Text(
                                                          "Stock: ${art.cantidad}",
                                                          style: TextStyle(
                                                            color: AppColors.semantics.text.secondary,
                                                            fontSize: Fontsize.body,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 4),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          content: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: SubtleButton(
                                                    text: "Cancelar",
                                                    leftIcon: Icons.close,
                                                    type: SubtleButtonType.brand,
                                                    onPressed: () {
                                                      Navigator.pop(context, true);
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: SubtleButton(
                                                    text: "Aceptar",
                                                    type: SubtleButtonType.success,
                                                    onPressed: () {
                                                      Navigator.pop(context, true);
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                        */
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
                                            Text(
                                              "Stock: ${art.cantidad.toString()}",
                                              style: TextStyle(color: AppColors.semantics.text.secondary, fontSize: Fontsize.body, fontWeight: FontWeight.w100),
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

                  const SizedBox(height: 8),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SubtleButton(text: "Cancelar operación", type: SubtleButtonType.error, onPressed: () {
                      if (_selectedOrigen != "" || _selectedEmpleado != "" || _articulosSeleccionados.isNotEmpty) {
                        ActionSheet.show(
                          context,
                          title: "¿Cancelar operación?",
                          content: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Se eliminará el control actual.",
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
                                  text: "Eliminar control",
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
                ],
              ),
              
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _btnBottom()
              ),
            ],
          ),
        ),
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
          color: const Color.fromARGB(255, 223, 223, 223),
          size: MediaQuery.sizeOf(context).width * 0.2,
        ),
      );
    } else {
      decodedBytes = base64Decode(base64Image);
      try {
        return Image.memory(
          decodedBytes,
          fit: BoxFit.cover,
          width: MediaQuery.sizeOf(context).width * 0.2,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade100,
              child: Icon(
                Icons.image_not_supported_outlined,
                color: Colors.grey.shade400,
                size: MediaQuery.sizeOf(context).width * 0.2,
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
            size: MediaQuery.sizeOf(context).width * 0.02,
          ),
        );
      }
    }
  }

  Widget _btnBottom() {
    return Container(
      padding: const EdgeInsets.only(bottom: 16, right: 16, left: 16),
      color: Colors.white,
      child: SolidButton(
        type: SolidButtonType.primary,
        text: "Enviar",
        leftIcon: CupertinoIcons.paperplane,
        onPressed: _selectedOrigen != "" && _selectedEmpleado != "" && _articulosSeleccionados.isNotEmpty
        ? () async {
          Control control = Control(
            id: 0,
            ubicacion: _selectedOrigen!,
            ubicacionId: _selectedOrigenId,
            empleado: _selectedEmpleado!,
            empleadoId: _selectedEmpleadoId,
            idUsrSolicita: widget.entidad.usuarioId,
            usrSolicita: widget.entidad.usuario,
            fecha: con.getFechaHoraActual(),
            hora: con.getHoraActual(),
            estadoId: 10822,
            duracion: "",
            horaIni: "",
            horaFin: "",
            items: _articulosSeleccionados.length,
            diferencias: "",
            articulos: _articulosSeleccionados
          );

          control.id = await con.actualizaControl(context, control);

          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => EstadoControl(
                entidad: widget.entidad,
                control: Control(id: 0, diferencias: "", ubicacion: _selectedOrigen.toString(), ubicacionId: _selectedOrigenId, empleado: _selectedEmpleado.toString(), empleadoId: _selectedEmpleadoId, fecha: "", hora: "", usrSolicita: "", idUsrSolicita: 0, estadoId: 0, duracion: "", horaIni: "", horaFin: "", items: 0, articulos: []),
                label: "Control de stock enviado",
                icon: Icons.check_circle_outline_rounded,
                color: AppColors.semantics.text.success,
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
        }
        : null
      ),
    );
  }

}