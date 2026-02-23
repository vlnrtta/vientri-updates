// ignore_for_file: use_build_context_synchronously
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vientri/components/action_sheet/action_sheet.dart';
import 'package:vientri/components/action_sheet_options/action_sheet_options.dart';
import 'package:vientri/components/heading/app_heading.dart';
import 'package:vientri/components/solid_button/solid_button.dart';
import 'package:vientri/components/subtle_button/subtle_button.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/constants/app_shadows.dart';
import 'package:vientri/pages/comunes/master/master_comprobante.dart';
import 'package:vientri/pages/controller.dart';
import 'package:vientri/pages/remito_devolucion/estado_remito.dart';
import 'package:vientri/src/models/articulo.dart';
import 'package:vientri/src/models/entidad.dart';
import 'package:vientri/src/models/opcion.dart';
import 'package:vientri/src/models/remitoDevolucion.dart';

// ignore: must_be_immutable
class ConfirmarRemito extends StatefulWidget {
  Entidad entidad;
  RemitoDevolucion remitoDevolucion;
  List<Articulo> articulos;
  
  ConfirmarRemito({
    super.key,
    required this.entidad,
    required this.remitoDevolucion,
    required this.articulos,
  });

  @override
  State<ConfirmarRemito> createState() => _ConfirmarRemitoState();
}

class _ConfirmarRemitoState extends State<ConfirmarRemito> {
  late Controller con;
  //String? _selectedDestino = "";
  String? _selectedChofer = "";
  String? _selectedOrigen = "";
  //int _selectedDestinoId = -1;
  int _selectedChoferId = -1;
  int _selectedOrigenId = -1;

  List<Opcion> _depositos = [];
  List<Opcion> _choferes = [];

  String? _observacion = "";
  late TextEditingController _controller;
  late FocusNode _focusNode;

  var _loading = false.obs;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    con = Get.put(Controller(widget.entidad));
    cargarOpciones();
  }

  Future<void> cargarOpciones() async {
    final dataDepositos = await con.listaDepositos();
    final dataChoferes = await con.listaEmpleados();

    setState(() {
      _depositos = dataDepositos.toList()..sort((a, b) => a.nombre.compareTo(b.nombre));
      _choferes = dataChoferes.toList()..sort((a, b) => a.nombre.compareTo(b.nombre));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MasterComprobante(
      title: "Confirmar los datos",
      onBack: () => Navigator.pop(context, true),
      floatingButton: Obx(() => Stack(
        children: [
          SolidButton(
            type: SolidButtonType.primary,
            text: _loading.value ? "" : "Emitir remito de devolución",
            onPressed: !_loading.value ? () async {
              if (_selectedOrigen == "") {
                con.mostrarSnackbar(titulo: "Atención", mensaje: "Seleccioná un origen", esError: true);
                return;
              }
              if (_selectedChofer == "") {
                con.mostrarSnackbar(titulo: "Atención", mensaje: "Seleccioná un chofer", esError: true);
                return;
              }
              widget.remitoDevolucion.origen = _selectedOrigen;
              widget.remitoDevolucion.origenId = _selectedOrigenId;
              widget.remitoDevolucion.chofer = _selectedChofer;
              widget.remitoDevolucion.choferId = _selectedChoferId;
              widget.remitoDevolucion.emisor = con.capitalizarNombre(widget.entidad.nombre.replaceAll(".", " "));
              
              _loading.value = true;
              bool ok = true;// await con.registrarCmpRemito(widget.remitoDevolucion, widget.articulos);
              if (ok) {
                _loading.value = false;
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => EstadoRemito(
                      entidad: widget.entidad,
                      remitoDevolucion: widget.remitoDevolucion,
                      articulos: widget.articulos,
                      titulo: "Remito de devolución emitido",
                      texto: "Los artículos fueron ingresados al depósito",
                      observacion: _observacion.toString(),
                      icon: Icons.check_circle_outline_rounded,
                      color: AppColors.semantics.text.success,
                    ),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
                      return SlideTransition(position: animation.drive(tween), child: child);
                    },
                    transitionDuration: const Duration(milliseconds: 400),
                  ),
                );
              } else {
                _loading.value = false;
                return;
              }
            }
            : () {}
          ),
        
          if (_loading.value)
          Center(child: CircularProgressIndicator(color: Colors.white, constraints: BoxConstraints(maxHeight: 30, maxWidth: 30, minHeight: 30, minWidth: 30), padding: EdgeInsets.only(top: 10)))
        ],
      )),
      label1: "Vinculado al remito",
      cab1: "${widget.remitoDevolucion.numeroRemito} | ID ${widget.remitoDevolucion.idRemito}",
      
      label3: "Fecha",
      cab3: con.formatearFechayDia3(widget.remitoDevolucion.fecEmision!),
    
      label4: "Cliente",
      cab4: widget.remitoDevolucion.cliente.trim(),
    
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black12)
              ),
              child: Column(
                children: [
                  const AppHeading(
                    label: "Datos de remito",
                    fontSize: Fontsize.h3,
                  ),
                  
                  GestureDetector(
                    onTap: () {
                      ActionSheetOptions.show(
                        context,
                        title: "Seleccionar origen",
                        options: _depositos,
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
                              _selectedOrigen == "" ? "Seleccionar origen" : _selectedOrigen.toString(),
                              style: TextStyle(
                                color: _selectedOrigen == "" ? AppColors.semantics.text.secondary : AppColors.semantics.text.body,
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
                      /*ActionSheetOptions.show(
                        context,
                        title: "Seleccionar destino",
                        options: _destinos,
                        onOptionSelected: (s) {
                          setState(() {
                            _selectedDestino = con.capitalizar(s.nombre);
                            _selectedDestinoId = s.id;
                          });
                        },
                      );*/
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
                              color: AppColors.semantics.text.body,
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: 200,
                            child: Text(
                              "Depósito de devoluciones",
                              //_selectedDestino == "" ? "Depósito de devoluciones" : _selectedDestino.toString(),
                              style: TextStyle(
                                color: AppColors.semantics.text.secondary,
                                fontSize: Fontsize.body,
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: Fontsize.h2,
                            color: AppColors.semantics.text.secondary,
                          )
                        ],
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      ActionSheetOptions.show(
                        context,
                        title: "Seleccionar chofer",
                        options: _choferes,
                        onOptionSelected: (s) {
                          setState(() {
                            _selectedChofer = con.capitalizar(s.nombre);
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
                              color: AppColors.semantics.text.body,
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: 200,
                            child: Text(
                              _selectedChofer == "" ? "Seleccionar chofer" : _selectedChofer.toString(),
                              style: TextStyle(
                                color: _selectedChofer == "" ? AppColors.semantics.text.secondary : AppColors.semantics.text.body,
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
                ]
              ),
            ),

            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black12)
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: const AppHeading(
                          label: "Artículos",
                          fontSize: Fontsize.h3,
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context, true);
                        },
                        child: Icon(
                          Icons.edit_outlined,
                          color: AppColors.semantics.text.action,
                        ),
                      )
                    ],
                  ),
                  ...widget.articulos.asMap().entries.map((entry) {
                    final art = entry.value;
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    con.capitalizar(art.articuloDes),
                                    style: TextStyle(
                                      color: AppColors.semantics.text.body,
                                      fontSize: Fontsize.h3,
                                    ),
                                    maxLines: 2,
                                  ),
                                  Text(
                                    "#${art.articuloCod}",
                                    style: TextStyle(
                                      fontSize: Fontsize.body,
                                      color: AppColors.semantics.text.secondary
                                    ),
                                  ),
                                ],
                              ),
                              
                              Text(
                                art.cantidad.toString(),
                                style: TextStyle(
                                  fontSize: Fontsize.h3,
                                  color: AppColors.semantics.text.body,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ]
              ),
            ),
            
            if (_observacion != "")
            Column(
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
                        },
                      ),
                    ],
                  )
                  ),
              ],
            ),
            
            if (_observacion == "")
            const SizedBox(height: 16),
            if (_observacion == "")
            SubtleButton(
              text: "Añadir observaciones",
              leftIcon: CupertinoIcons.chat_bubble,
              onPressed: () {
                _mostrarDialogoProblema();
              },
            ),

            const SizedBox(height: 8),

            SubtleButton(
              text: "Cancelar operación",
              type: SubtleButtonType.error,
              onPressed: () {
                Navigator.pop(context, true);
                Navigator.pop(context, true);
              },
            ),

          ],
        ),
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

}
