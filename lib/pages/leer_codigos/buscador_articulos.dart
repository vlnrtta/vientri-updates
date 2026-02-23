// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:convert';
import 'package:flutter_svg/svg.dart';
import 'package:vientri/components/solid_button/solid_button.dart';
import 'package:vientri/constants/app_shadows.dart';
import 'package:vientri/pages/leer_codigos/detalle_articulo.dart';
import 'package:vientri/pages/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/src/models/articulo.dart';
import 'package:vientri/src/models/entidad.dart';

// ignore: must_be_immutable
class BuscadorArticulos extends StatefulWidget {
  Entidad entidad;
  String titulo;
  String codigoBarras;
  BuscadorArticulos({super.key, required this.entidad, required this.titulo, required this.codigoBarras});

  @override
  State<BuscadorArticulos> createState() => _BuscadorArticulosState();
}

class _BuscadorArticulosState extends State<BuscadorArticulos> {
  late Controller con;
  
  //  BUSCADOR
  final TextEditingController _controllerSearch = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  var equis = false.obs;
  var filtro = "".obs;
  Timer? _debounce;

  List<Articulo> _articulos = [];
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    con = Get.put(Controller(widget.entidad));

    _cargarArticulos();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });

    ever(filtro, (value) {
      if (value.toString().isEmpty) {
        setState(() => _articulos = []);
        return;
      }
      _buscarArticulosRemoto(value.toString());
    });
  }

  void _buscarArticulosRemoto(String valor) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        setState(() => _loading = true);
        final lista = await con.listaArticulos(valor, widget.entidad);
        setState(() {
          _articulos = lista;
          _loading = false;
          _error = false;
        });
      } catch (e) {
        setState(() {
          _error = true;
          _loading = false;
        });
      }
    });
  }

  Future<void> _cargarArticulos() async {
    try {
      final lista = await con.listaArticulos("", widget.entidad);
      setState(() {
        _articulos = lista;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controllerSearch.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Obx(() => Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF0E4FF), Color(0xFFF5F5F5)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          Column(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context, true),
                        child: Icon(Icons.arrow_back, color: AppColors.semantics.text.body),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.titulo,
                        style: TextStyle(
                          color: AppColors.semantics.text.body,
                          fontSize: Fontsize.h2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              _buildSearchBar(),

              if (filtro.value.isNotEmpty)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 80),
                  child: _buildSugerencias(),
                ),
              ),
            ],
          ),

          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SolidButton(
              text: "Nuevo artículo",
              type: SolidButtonType.secondary,
              onPressed: () {
                // acción aquí
              },
            ),
          ),
        ],
      )),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.semantics.text.action),
        boxShadow: AppShadows.elementFocusShadow,
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
              onChanged: (value) => {
                if (value != "") {
                  filtro.value = value,
                  equis.value = true
                } else {
                  filtro.value = "",
                  equis.value = false
                }
              },
              decoration: InputDecoration(
                hintText: "Buscar artículo",
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                isDense: true,
              ),
            ),
          ),
          if (equis.value)
          GestureDetector(
            onTap: () {
              filtro.value = "";
              _controllerSearch.clear();
              equis.value = false;
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

  Widget _buildSugerencias() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error) {
      return const Center(child: Text("Error al cargar artículos"));
    }

    if (_articulos.isEmpty && filtro.value.isNotEmpty) {
      return const Center(child: Text("Sin resultados"));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
            boxShadow: AppShadows.containerShadow,
          ),
          child: ListView.builder(
            padding: EdgeInsets.zero,
            physics: const ClampingScrollPhysics(),
            shrinkWrap: true,
            itemCount: _articulos.length,
            itemBuilder: (context, index) {
              final articulo = _articulos[index];
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    FocusScope.of(context).unfocus();

                    ArticulosRecientesMemoria.agregar(articulo);

                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => DetalleArticulo(
                          articulo: articulo,
                          entidad: widget.entidad,
                          codigoBarras : widget.codigoBarras,
                          nuevo: false,
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
                      )
                    ).then((value) {
                      if (value == true) {
                        setState(() {
                          
                        });
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.black12)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 94,
                            height: 94,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: _buildArticuloImage(articulo.foto),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  con.capitalizar(articulo.articuloDes.trimRight()),
                                  style: TextStyle(
                                    fontSize: Fontsize.h3,
                                    color: AppColors.semantics.text.body,
                                    height: 1.2
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "#${articulo.articuloCod.trimLeft().trimRight()}",
                                  style: TextStyle(
                                    color: AppColors.semantics.text.secondary,
                                    fontSize: Fontsize.body,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    if (articulo.cBarra.trim() != "")
                                    SvgPicture.asset("assets/barcode.svg", width: 24, height: 24, colorFilter: ColorFilter.mode(AppColors.semantics.text.secondary, BlendMode.srcATop)),
                                    if (articulo.cBarra.trim() != "")
                                    const SizedBox(width: 8),
                                    Text(
                                      articulo.cBarra.trim() != "" ? articulo.cBarra.trim() : "Sin código de barras",
                                      style: TextStyle(
                                        fontSize: Fontsize.h3,
                                        color: articulo.cBarra.trim() != "" ? AppColors.semantics.text.secondary : AppColors.semantics.text.action,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
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
        );
      },
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

}

class ArticulosRecientesMemoria {
  static final List<Articulo> _lista = [];

  static void agregar(Articulo articulo) {
    // Si ya está, eliminarlo primero (para reinsertarlo al inicio)
    _lista.removeWhere((a) => a.articuloCod == articulo.articuloCod);

    // Insertar al inicio (más reciente primero)
    _lista.insert(0, articulo);

    // Mantener solo los 30 más recientes
    if (_lista.length > 30) {
      _lista.removeRange(30, _lista.length);
    }
  }

  static List<Articulo> obtener() {
    return List.unmodifiable(_lista);
  }

  static void limpiar() {
    _lista.clear();
  }
}

