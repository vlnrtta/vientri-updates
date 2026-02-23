// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, must_be_immutable
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vientri/components/action_sheet/action_bottom_sheet.dart';
import 'package:vientri/components/heading/app_heading.dart';
import 'package:vientri/components/solid_button/solid_button.dart';
import 'package:vientri/components/subtle_button/subtle_button.dart';
import 'package:vientri/pages/asignar_codigos_imagenes/scan_screen.dart';
import 'package:vientri/pages/leer_codigos/ventana_imagenes.dart';
import 'package:vientri/pages/controller.dart';
import 'package:get/get.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/src/models/articulo.dart';
import 'package:vientri/src/models/entidad.dart';

class FichaArticulo extends StatefulWidget {
  Articulo articulo;
  Entidad entidad;
  FichaArticulo({
    super.key,
    required this.articulo,
    required this.entidad,
  });

  @override
  State<FichaArticulo> createState() => _FichaArticuloState();
}

class _FichaArticuloState extends State<FichaArticulo> {
  late Controller con;
  final TextEditingController _codigoController = TextEditingController();
  final NumberFormat formatter = NumberFormat("#,##0.00", "en_US");
  List<Articulo> _articulos = [];

  @override
  void initState() {
    super.initState();
    con = Get.put(Controller(widget.entidad));
  }

  @override
  void dispose() {
    _codigoController.dispose();
    super.dispose();
  }


Future<void> startScan() async {
  try {
    final String? scannedCode = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ScanScreen(),
      ),
    );

    if (scannedCode == null || scannedCode.isEmpty || !mounted) return;

    _articulos = await con.listaArticulos(scannedCode, widget.entidad);

    if (_articulos.isEmpty) {
      setState(() {
        con.asignarCodigo(context, widget.articulo.articuloId, scannedCode.trim());
        widget.articulo.cBarra = scannedCode.trim();
      });
    } else {
      _bottomSheet(context, scannedCode, _articulos);
    }
  } catch (e) {
    print('Error al escanear: $e');
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

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, true),
                    child: const Icon(
                      Icons.arrow_back,
                      size: 26,
                    ),
                  ),
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: AppHeading(
                  label: "Detalle",
                  fontSize: Fontsize.h1,
                ),
              ),

              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(0),
                  physics: const ClampingScrollPhysics(),
                  children: [
                    Center(
                      child: Container(
                        height: MediaQuery.sizeOf(context).height * 0.4,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
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
                        fontSize: Fontsize.h2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListView(
                      padding: const EdgeInsets.all(0),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _detail("Rubro", widget.articulo.rubroDes.trim()),
                        _detail("Código", widget.articulo.articuloCod.trim()),
                        _detail("Código de barras", widget.articulo.cBarra.trim() == "" ? "--" : widget.articulo.cBarra.trim()),
                      ],
                    ),
                    if(widget.articulo.cBarra.trim() == "")
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "El artículo no tiene código de barras asignado."
                          ),
                          const SizedBox(height: 16),
                          SolidButton(
                            text: "Asignar código de barras",
                            leftIcon: Icons.barcode_reader,
                            onPressed: () {
                              setState(() {
                                startScan();
                              });
                            },
                          ),
                        ],
                      )
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ]
      ),
    );
  }

  Widget _detail(String campo, String valor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
          Text(
            campo,
            style: TextStyle(
              color: AppColors.semantics.text.body,
              fontSize: Fontsize.body,
              fontWeight: FontWeight.bold,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: campo == "Código de barras" 
            ? InkWell(
              onTap: () {
                setState(() {
                  startScan();
                });
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    valor,
                    style: TextStyle(
                      color: AppColors.semantics.text.body,
                      fontSize: Fontsize.body,
                    ),
                  ),
                  if (widget.articulo.cBarra.trim() != "")
                  Text(
                    "Cambiar",
                    style: TextStyle(
                      color: AppColors.semantics.text.action,
                      fontSize: Fontsize.body,
                      fontWeight: FontWeight.w100,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.semantics.text.action,
                    ),
                  ),
                ],
              ),
            )
            : Text(
              valor,
              style: TextStyle(
                color: AppColors.semantics.text.body,
                fontSize: Fontsize.body,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future _bottomSheet(BuildContext context, String codigoBarra, List<Articulo> articulos) {
    final double maxHeight = MediaQuery.of(context).size.height * 0.5;

    return ActionBottomSheet.show(
      context,
      title: Text(
        "El código de barras también pertenece a:",
        style: TextStyle(
          fontSize: Fontsize.h2,
          color: AppColors.semantics.text.body,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          height: maxHeight,
          child: Column(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: const ClampingScrollPhysics(),
                    itemCount: articulos.length,
                    itemBuilder: (context, index) {
                      final articulo = articulos[index];
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              widget.articulo = articulo;
                            });
                            Navigator.pop(context, true);
                          },
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 48,
                                    height: 48,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: _buildArticuloImage(articulo.foto),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Wrap(
                                          crossAxisAlignment: WrapCrossAlignment.center,
                                          children: [
                                            Text(
                                              con.capitalizar(articulo.articuloDes.trimRight()),
                                              style: TextStyle(
                                                fontSize: Fontsize.h3,
                                                color: AppColors.semantics.text.body,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              "#${articulo.articuloCod.trim()}",
                                              style: TextStyle(
                                                color: AppColors.semantics.text.secondary,
                                                fontSize: Fontsize.body,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          articulo.cBarra.trim() != ""
                                            ? "COD ${articulo.cBarra.trim()}"
                                            : "Sin código",
                                          style: TextStyle(
                                            fontSize: Fontsize.h3,
                                            color: AppColors.semantics.text.secondary,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              SolidButton(
                text: "Asignar de todos modos",
                onPressed: () {
                  setState(() {
                    con.asignarCodigo(context, widget.articulo.articuloId, codigoBarra.trim());
                    widget.articulo.cBarra = codigoBarra.trim();
                  });
                  Navigator.pop(context, true);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArticuloImage(String base64Image) {
    if (base64Image.isEmpty) {
      return Container(
        color: Colors.grey.shade100,
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.grey.shade400,
          size: 24,
        ),
      );
    }

    try {
      final decodedBytes = base64Decode(base64Image);
      return Image.memory(
        decodedBytes,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade100,
            child: Icon(
              Icons.image_not_supported_outlined,
              color: Colors.grey.shade400,
              size: 24,
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
          size: 24,
        ),
      );
    }
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
              con.asignarFoto(context, widget.articulo.articuloId, base64Image, widget.articulo.foto.trim() == "" ? 0 : 1);
              widget.articulo.foto = base64Image;
            });
          },
        ),
      )
    );
  }

}
