// ignore_for_file: use_build_context_synchronously, unused_element

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vientri/components/action_sheet/action_bottom_sheet.dart';
import 'package:vientri/components/heading/app_heading.dart';
import 'package:vientri/components/solid_button/solid_button.dart';
import 'package:vientri/components/subtle_button/subtle_button.dart';
import 'package:vientri/pages/leer_codigos/ventana_imagenes.dart';
import 'package:vientri/pages/controller.dart';
import 'package:get/get.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/src/models/articulo.dart';
import 'package:vientri/src/models/entidad.dart';
import 'package:url_launcher/url_launcher.dart';

class DetalleArticulo extends StatefulWidget {
  final Articulo articulo;
  final Entidad entidad;
  final String codigoBarras;
  final bool nuevo;
  const DetalleArticulo({
    super.key,
    required this.articulo,
    required this.entidad,
    required this.codigoBarras,
    required this.nuevo,
  });

  @override
  State<DetalleArticulo> createState() => _DetalleArticuloState();
}

class _DetalleArticuloState extends State<DetalleArticulo> {
  late Controller con;
  final TextEditingController _codigoController = TextEditingController();
  final NumberFormat formatter = NumberFormat("#,##0.00", "en_US");
  bool googleImages = false;

  @override
  void initState() {
    super.initState();
    con = Get.put(Controller(widget.entidad));
    if (widget.codigoBarras != "") {
      setState(() {
        widget.articulo.cBarra = widget.codigoBarras;
      });
    }
  }

  @override
  void dispose() {
    _codigoController.dispose();
    super.dispose();
  }

  Future<void> buscarImagenEnGoogle(String codigo) async {
    final query = Uri.encodeComponent(codigo);
    final url = "https://www.google.com/search?tbm=isch&q=$query";

    try {
      final uri = Uri.parse(url);

      // Intentar abrir con navegador externo
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalNonBrowserApplication,
      );

      // Si no se pudo abrir externamente, abrir dentro del navegador del sistema
      if (!launched) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      // Si todo falla, mostrar mensaje al usuario
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir Google Imágenes')),
      );
      print("Error al abrir Google Imágenes: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final decodedBytes = base64Decode(widget.articulo.foto != "" ? widget.articulo.foto : "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");

    return Scaffold(
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

          Positioned.fill(
            child: SafeArea(
              child: ListView(
                physics: const ClampingScrollPhysics(),
                children: [
                  const SizedBox(height: 16),
              
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: AppHeading(
                      label: "Volver",
                      fontSize: Fontsize.h1,
                      leadingIcon: Icons.arrow_back,
                      onLeadingIconPressed: () {
                        Navigator.pop(context, true);
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  /*Container(
                    height: MediaQuery.sizeOf(context).height * 0.4,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: InteractiveViewer(
                        child: widget.articulo.foto.trim() != "" 
                        ? Image.memory(
                          decodedBytes,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade100,
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: Colors.grey.shade400,
                                size: 60,
                              ),
                            );
                          },
                        )
                        : Container(
                          color: Colors.grey.shade100,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported_outlined,
                                color: Colors.grey.shade400,
                                size: 60,
                              ),
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: SubtleButton(
                                  text: "Agregar imagen",
                                  type: SubtleButtonType.brand,
                                  onPressed: () => _bottomSheet(context, widget.articulo.cBarra.trim())
                                ),
                              ),
                            ],
                          ),
                        )
                      )
                    )
                  ),*/
              
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      height: MediaQuery.sizeOf(context).height * 0.4,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        
                        child: InteractiveViewer(
                          child: widget.articulo.foto.trim() != ""
                              ? Container(
                                constraints: const BoxConstraints(
                                  maxWidth: 240,
                                  maxHeight: 200,
                                ),
                                child: Image.memory(
                                    decodedBytes,
                                    fit: BoxFit.none,
                                  ),
                              )
                              : Container(
                                  color: Colors.grey.shade100,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.image_not_supported_outlined,
                                          color: Colors.grey.shade400, size: 60),
                                      const SizedBox(height: 16),
                                      SubtleButton(
                                        text: "Agregar imagen",
                                        type: SubtleButtonType.brand,
                                        onPressed: () => _bottomSheetImagenes(
                                          context,
                                          widget.articulo.cBarra.trim(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                  
                  /*const SizedBox(height: 16),
                  widget.articulo.foto.trim() != "" && !googleImages
                  ? SubtleButton(
                    text: "Elegir otra imagen",
                    type: SubtleButtonType.brand,
                    onPressed: () => _bottomSheet(context, widget.articulo.cBarra.trim())//_abrirPopup(context, widget.articulo.cBarra),
                  )
                  : widget.articulo.foto.trim() != "" && googleImages
                    ? Column(
                      children: [
                        Text(
                          "Imagen sugerida de Google Imágenes",
                          style: TextStyle(
                            color: AppColors.semantics.text.body,
                            fontSize: Fontsize.body
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: SubtleButton(
                                text: "Elegir otra imagen",
                                type: SubtleButtonType.brand,
                                onPressed: () => _bottomSheet(context, widget.articulo.cBarra.trim())//_abrirPopup(context, widget.articulo.cBarra),
                              )
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: SubtleButton(
                                text: "Quitar imagen",
                                type: SubtleButtonType.error,
                                onPressed: () {
                                  setState(() {
                                    widget.articulo.foto = "";
                                  });
                                },
                              )
                            )
                          ],
                        )
                      ],
                    )
                  : const SizedBox(),*/
              
                  const SizedBox(height: 16),
                  if (widget.articulo.foto.trim() != "")
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SubtleButton(
                      text: "Elegir otra imagen",
                      type: SubtleButtonType.brand,
                      onPressed: () => _bottomSheetImagenes(context, widget.articulo.cBarra.trim())
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: AppHeading(
                      label: "${con.capitalizar(widget.articulo.articuloDes.trim())} | ${con.capitalizar(widget.articulo.rubroDes.trim())}",
                      fontSize: Fontsize.h3,
                    ),
                  ),
                 
                  ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _detail("ID", widget.articulo.articuloId.toString()),
                      _detail("Código", widget.articulo.articuloCod.trim()),
                      _detail("Stock", widget.articulo.stk.toString()),
                      _detail("Código de barras", widget.articulo.cBarra.trim()),
                      _detail("Precio", "\$${formatter.format(widget.articulo.impoconiva)}"),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SolidButton(
                      text: "Guardar cambios",
                      onPressed: widget.nuevo
                      ? null
                      : () => {
                        con.asignarFoto(context, widget.articulo.articuloId, widget.articulo.foto, widget.articulo.foto.trim() == "" ? 0 : 1),
                        con.asignarCodigo(context, widget.articulo.articuloId, widget.articulo.cBarra)
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ]
      ),
    );
  }

  Widget _detail(String campo, String valor) {
    final editableFields = ['Código', 'Stock', 'Precio'];

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.black12,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          widget.nuevo && editableFields.contains(campo)
          ? Text(
            campo,
            style: TextStyle(
              color: AppColors.semantics.text.body,
              fontSize: Fontsize.body,
              fontWeight: FontWeight.bold,
            ),
          )
          : Text(
            campo,
            style: TextStyle(
              color: AppColors.semantics.text.secondary,
              fontSize: Fontsize.body,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Si es editable, mostramos un TextField
          widget.nuevo && editableFields.contains(campo)
          ? SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.3,
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: TextField(
                  textAlign: TextAlign.end,
                  controller: TextEditingController(text: valor),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                  style: TextStyle(
                    color: AppColors.semantics.text.body,
                    fontSize: Fontsize.body,
                  ),
                  onChanged: (newValue) {
                    // Aquí puedes actualizar el valor en tu modelo
                  },
                ),
              ),
            )
          : Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
                valor,
                style: TextStyle(
                  color: AppColors.semantics.text.secondary,
                  fontSize: Fontsize.body,
                ),
              ),
          ),
        ],
      ),
    );
  }

  Future _bottomSheet(BuildContext context, String codigoBarra) {
    return ActionBottomSheet.show(
      context,
      title: Text(
        "Buscar imagen",
        style: TextStyle(
          fontSize: Fontsize.h2,
          color: AppColors.semantics.text.body,
          fontWeight: FontWeight.bold
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ImagenesArticuloScreen(
          codigoBarra: codigoBarra,
          articuloDes: widget.articulo.articuloDes,
          rubroDes: widget.articulo.rubroDes,
          onImageSelected: (base64Image) {
            setState(() {
              widget.articulo.foto = base64Image;
              googleImages = true;
            });
          },
        ),
      )
    );
  }

  Future _bottomSheetImagenes(BuildContext context, String codigoBarra) {
    return ActionBottomSheet.show(
      context,
      title: Text(
        "Buscar imagen",
        style: TextStyle(
          fontSize: Fontsize.h2,
          color: AppColors.semantics.text.body,
          fontWeight: FontWeight.bold
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ImagenesArticuloScreen(
          codigoBarra: codigoBarra,
          articuloDes: widget.articulo.articuloDes,
          rubroDes: widget.articulo.rubroDes,
          onImageSelected: (base64Image) {
            setState(() {
              widget.articulo.foto = base64Image;
            });
          },
        ),
      )
    );
  }

}
