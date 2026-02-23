import 'dart:async';
import 'dart:convert';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:flutter/material.dart';
import 'package:vientri/components/action_sheet/action_bottom_sheet.dart';
import 'package:vientri/components/solid_button/solid_button.dart';
import 'package:vientri/components/subtle_button/subtle_button.dart';
import 'package:vientri/pages/asignar_codigos_imagenes/scan_screen.dart';
import 'package:vientri/pages/comunes/permisos/permisos_page.dart';
import 'package:vientri/pages/leer_codigos/detalle_articulo.dart';
import 'package:vientri/pages/leer_codigos/buscador_articulos.dart';
import 'package:vientri/pages/comunes/login/login_controller.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vientri/components/heading/heading.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/pages/controller.dart';
import 'package:vientri/src/models/articulo.dart';
import 'package:vientri/src/models/entidad.dart';


// ignore: must_be_immutable
class ListaRecientes extends StatefulWidget {
  Entidad entidad;
  ListaRecientes({super.key, required this.entidad});

  @override
  State<ListaRecientes> createState() => _ListaRecientesState();
}

class _ListaRecientesState extends State<ListaRecientes> {
  final LoginController con = LoginController();
  late Controller cont;
  List<Articulo> _recientes = [];

  Future<void> startScan() async {
    try {
      final String? scannedCode = await showDialog<String>(
        context: context,
        barrierDismissible: true,
        builder: (context) => const ScanScreen(),
      );

      if (scannedCode == null || scannedCode.isEmpty || !mounted) return;

      List<Articulo> articulo = await cont.listaArticulos(scannedCode, widget.entidad);

      if (articulo.isEmpty) {
        _bottomSheet(context, scannedCode);
      } else {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
              DetalleArticulo(
                articulo: articulo.first,
                entidad: widget.entidad,
                codigoBarras: scannedCode.trim(),
                nuevo: false
              ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              final tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        )
            .then((value) {
          if (value == true) {
            setState(() {});
          }
        });
      }
    } catch (e) {
      print('Error al escanear: $e');
    }
  }


  Future<Articulo?> obtenerArticuloDesdePricely(String codigoBarra) async {
    try {
      final url = Uri.parse('https://pricely.ar/product/$codigoBarra');
      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception('No se pudo obtener la página.');
      }

      final document = parser.parse(response.body);

      // 🔹 Tomamos solo el contenido dentro de <main>
      final mainContent = document.querySelector('main');
      if (mainContent == null) {
        throw Exception('No se encontró el contenido principal (<main>).');
      }

      // 🔹 Nombre del producto
      final nombre = mainContent
          .querySelector('h1.text-2xl, h1.md\\:text-3xl')
          ?.text
          .trim() ?? '';

      // 🔹 Imagen principal
      final imgElement = mainContent.querySelector('img.image');
      final imgUrl = imgElement?.attributes['src'] ?? '';

      // 🔹 Código EAN
      final eanDiv = mainContent.querySelector('div.mb-1.text-zinc-400.text-xs.mt-2');
      final ean = eanDiv?.text.replaceAll('EAN', '').trim() ?? codigoBarra;

      // 🔹 Precio
      final precioDiv = mainContent.querySelector('div.mb-1.text-zinc-600.text-xs.mt-2');
      final precioTexto = precioDiv?.text.replaceAll('\$', '').trim() ?? '';
      final precio = double.tryParse(precioTexto.replaceAll(',', '.')) ?? 0.0;

      // 🔹 Descargar y convertir la imagen a Base64
      String fotoBase64 = '';
      if (imgUrl.isNotEmpty) {
        final imgResponse = await http.get(Uri.parse(imgUrl));
        if (imgResponse.statusCode == 200) {
          fotoBase64 = base64Encode(imgResponse.bodyBytes);
        }
      }

      // 🔹 Crear objeto Articulo
      final articulo = Articulo(
        articuloId: 0,
        articuloDes: nombre,
        articuloCod: "0",
        impoconiva: precio,
        stk: 0,
        rubroId: 0,
        rubroDes: '',
        cantidad: 1,
        foto: fotoBase64,
        cBarra: ean,
      );

      return articulo;
    } catch (e) {
      print('⚠️ Error obteniendo artículo: $e');
      return null;
    }
  }
    
  @override
  void initState() {
    super.initState();
    widget.entidad = Entidad.fromJson(GetStorage().read("user"));
    cont = Get.put(Controller(widget.entidad));
    _recargar();
  }
   
  void _recargar() {
    setState(() {
      _recientes = ArticulosRecientesMemoria.obtener();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.entidad.rol = "Emisor";
    if (cont.contienePermiso([209, 210, 211, 212, 213, 214, 215])) {
      widget.entidad.rol = "Administrador";
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context, true),
                        child: const Icon(
                          Icons.arrow_back,
                          size: 26,
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) => PermisosPage(entidad: widget.entidad, titulo: "Permisos", idApp: 4),
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
                            });
                          });
                        },//cont.screenPermisos(context, widget.entidad, "Permisos", 4),
                        child: SvgPicture.asset("assets/key.svg", width: 30, height: 30),
                      )
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AppHeading(
                  label: "Escaneo de artículos",
                  fontSize: Fontsize.h1,
                  trailingIcon: Icons.search_rounded,
                  onTrailingIconPressed: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => BuscadorArticulos(entidad: widget.entidad, titulo: "Buscar artículo", codigoBarras: ""),
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
                          _recargar();
                        });
                      }
                    });
                  }
                ),
              ),

              const SizedBox(height: 16),
              
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 16, right: 16, bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: _buildContent(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SolidButton(
                  text: "Escanear",
                  leftIcon: Icons.barcode_reader,
                  type: SolidButtonType.primary,
                  onPressed: () {
                    setState(() {
                      startScan();
                    });
                  },
                ),
              ),
            ]
          ),
        ]
      ),
    );
  }

  Widget _buildContent() {
    if (_recientes.isEmpty) {
      return Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "Recientes",
                style: TextStyle(
                  color: AppColors.semantics.text.body,
                  fontWeight: FontWeight.bold,
                  fontSize: Fontsize.h2,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  "No hay artículos recientes",
                  style: TextStyle(
                    color: AppColors.semantics.text.body,
                    fontSize: Fontsize.body,
                  ),
                ),
              ),
            ),
          ]
        )
      );
    }

    return ClipRRect(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "Recientes",
                style: TextStyle(
                  color: AppColors.semantics.text.body,
                  fontWeight: FontWeight.bold,
                  fontSize: Fontsize.h2,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(0),
                physics: const ClampingScrollPhysics(),
                itemCount: _recientes.length,
                itemBuilder: (_, index) {
                  final articulo = _recientes[index];
                  bool ultimo = index == _recientes.length - 1;
                  return _buildCard(context, articulo, ultimo);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future _bottomSheet(BuildContext context, String scannedCode) async {
    String? base64Image = await cont.buscarPrimeraImagenBase64(scannedCode);
    final decodedBytes = base64Decode(base64Image! != "" ? base64Image : "iVBORw0KGgoAAAANSUhEUgAAAfQAAAF3CAMAAABkLEnOAAAAA3NCSVQICAjb4U/gAAAAclBMVEX////+/v79/f38/Pz7+/v6+vr5+fn4+Pj39/f29vb19fX09PTz8/Py8vLx8fHw8PDv7+/u7u7t7e3s7Ozr6+vq6urp6eno6Ojn5+fm5ubl5eXk5OTj4+Pi4uLh4eHg4ODf39/e3t7d3d3c3Nzb29va2to+nfFuAAAACXBIWXMAAAsSAAALEgHS3X78AAAAFnRFWHRDcmVhdGlvbiBUaW1lADA5LzEzLzEyU4V0gAAAABh0RVh0U29mdHdhcmUAQWRvYmUgRmlyZXdvcmtzT7MfTgAABtBJREFUeJzt3dta2koAgNHugtoWrSfqCVsVy/u/4i6WiQEmQwwhE8paV60opv2/kGQmh0+fAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA2GQyuTzJvQx0bPbH9P77MPdy0J3RbOH5x+hz7oWhGzezksfrb7mXhw78mq14uDzOvUzs1nC1+dzL3dkg94KxO2ex6HNPY5v4f9VdVfS5ydWX3MvHDkxT0efuL45yLyPtOtnU/G0Tf3tqE/8PuQxhh6c3L6nwv8bf/su9sLTjYdH0Yf6Xo/P75Ke98dp/w+9Fz8vwhS9Xk1R347X772uIubQKj8ZrIzZlxmv32ziswKsvDM7ukpt447X76+ei4V3sxaPLh9dUeOO1e2kQ+n2v+o6v14+p7sZr989piJfcORuNn1Phn8YjB3N7JEyr/tr0jcOzu/TBnPHavRHW4Js633xyOfmdCm+8di8U06qjuj/x7fpnqrvx2v47D7E+ctg9OL1JbuKN1/ZbmFZ9/OgPDo3X7q0Q7rrJD59cJTfxxmv7qZhW/dr0Hb5tGK/1Od87xbTqNm8yOL2tHK/deCRI58J02sO2b3R0ER+vHbexlLQqbJLP23iz2JSsOZneGZwvtLbDNRo/LUW3ST8Mg9J47ST3wtCdtbNx6EjqUGp7qYO8+Nk4dCBf9Mqzcdi1fNGTZ+OwS9miF2fjtHIkyEdki15cEWnovXPZooezcZ47+6cSZIseRuJrnY1Dq3JFL87GOe3wH8tf4f/+7KRNrxujF2fjOG+qe+H/vt0Rks3Rw9k4P1v9vdSSK3oYeTetmkGm6F82b/XZmUzRi7NxTKtmkCl6uPJt67NxaCBTdNOqOeWJPtrNr6WePNFNq2aVJ3o4Dd60ahZZom++yQG7lCW6adW8KqMPv2xRZEP028XLT81/A1uoiH4+HyadNj6g2hDdtGpe8ejhKpTHhjeCS0c/Dr+09k0OaFU0+o/w1aa71+noplUzi0UvP8Vhwy3gbuNfTkcPN5r98E0OaEcs+kUp+lXypy8qLj5MRw+vNrrJAduLRf9Ril6xKv919Pp6H30hGb24tMW0aiax6ONS9OQO9mPVdjkZ/Sq89xaLzTZi0csP6UldivC2GYge1iWjm1bNLRa99MCWaeKY7egt7XPspWT08N4XWyw224hGf1/VUyv6Yo2N7cqloptWzS5e4GxRLTUhEvbxY7tyqehhN/Flm8VmGxWr3XA8eZmMU6PvR8U9gyLflYpuWjW7xp+17/d3jxzKJ6IXIz9nTRaXNtSNPnha/o7SAE7kczoRvdhfMAabTd3oN7Np+VveP9xnsXmTRPRwaYs7BuZTM/p8FK1cfenhHesH3InoLm3Jr2b0t72v9+rl0flZZFeuOnpxo1nTqvnUi764ICVUX/pwn0VmTqqju7SlB2pFH4aI078zrat3+lw7k7k6umnVHqgV/eE977z6+WzV6p0FqqO7tKUH6kQ/LeX9U331w322fqfPyuimVfugKvpxaU516Ubt0+PYk3VXHsBUGd2lLX1QFf3ufSZ9vN54zcoBWGX0cMdA06o5VUSfn7C6OGnmZK1wxHR5Z7wqujsG9kJF9Ldxs7/Vk09YKyzvylVFL/YOPI8vp3j0xZnp84mw9V31qOVduaro4Y6BplWzike/n4Xqw/Vd9bildbcq+oee38muRKMXl6DM7u9nNS3tylVEN63aD9HotUuXLO3KVUR3aUs/xKIfrxWto7z2VkQ3rdoPsehNVvTl0fRy9PP3rb1p1X6IRK91YB5RuuytHP319fVm9HnpjT2ILa9I9GYr+tL6uxT97U+TqxPTqn2xHr3pil7elVuPPn89fLp7EFtm69GbrujlXblo9IJp1czWojde0cu7cunoLm3JbC3EYIt7+xfvmoxuWjW33ax9yegubcktQ3TTqrlliO6Ogbl1H/251d9EA91HN62aXffRPYgtu+6jm1bNLqS4v2nT7+roHsSW32ynItFNq+bXeXSXtuTXeXTTqvl1Hd2lLT3QdXTTqj3QdXTTqj3QcXTTqn3QcXTTqn3QcXSXtvTB7qNPy18wrdoHu49evo+FS1t6odvoplV7odvo7hjYC91Gb/hsP9rVaXR3DOyH3Uf/el3ctcaD2Pph99H/GJzevpT+SmadRJ87unwwBtsTnUWnP0Q/QKIfINEPkOgHSPQDJPoBEv0AiX6ARAcAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACgc/8D1DMkewea1FYAAAAASUVORK5CYII=");
    return ActionBottomSheet.show(
      context,
      title: Text(
        "Artículo sin identificar",
        style: TextStyle(
          color: AppColors.semantics.text.body,
          fontSize: Fontsize.h2,
          fontWeight: FontWeight.bold
        ),
      ),
      content: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "El código escaneado no está en la base",
                  style: TextStyle(
                    color: AppColors.semantics.text.body,
                    fontSize: Fontsize.body,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: MediaQuery.sizeOf(context).height * 0.4,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: InteractiveViewer(
                      child: Image.memory(
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
                      ),
                    )
                  )
                ),
                const SizedBox(height: 8),
                Text(
                  "Imagen sugerida de Google imágenes",
                  style: TextStyle(
                    fontSize: Fontsize.bodySmall,
                    color: AppColors.semantics.text.secondary
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "COD ${scannedCode.trim()}",
                  style: TextStyle(
                    fontSize: Fontsize.body,
                    color: AppColors.semantics.text.body
                  ),
                ),
                const SizedBox(height: 16),
                SubtleButton(
                  text: "Cancelar",
                  type: SubtleButtonType.error,
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 8),
                
                SolidButton(
                  text: "Nuevo artículo",
                  type: SolidButtonType.secondary,
                  onPressed: () async {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const Center(child: CircularProgressIndicator()),
                    );

                    final articulo = await obtenerArticuloDesdePricely(scannedCode.trim());

                    Navigator.of(context).pop();

                    if (articulo == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("No se pudo obtener la información del producto.")),
                      );
                      return;
                    }

                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            DetalleArticulo(
                          entidad: widget.entidad,
                          codigoBarras: scannedCode.trim(),
                          articulo: articulo,
                          nuevo: true,
                        ),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          final tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: Curves.ease));
                          return SlideTransition(position: animation.drive(tween), child: child);
                        },
                        transitionDuration: const Duration(milliseconds: 400),
                      ),
                    );
                  }
                ),

                const SizedBox(height: 8),
                SolidButton(
                  text: "Vincular a un artículo existente",
                  type: SolidButtonType.primary,
                  onPressed: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => BuscadorArticulos(entidad: widget.entidad, titulo: "Vincular código", codigoBarras: scannedCode.trim()),
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
                          _recargar();
                        });
                      }
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, Articulo articulo, bool ultimo) {
    return Container(
      decoration: BoxDecoration(
        border: !ultimo
        ? Border(
          bottom: BorderSide(color: AppColors.semantics.text.secondary.withOpacity(0.2))
        )
        : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => DetalleArticulo(
                  articulo: articulo,
                  entidad: widget.entidad,
                  codigoBarras: "",
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
            padding: const EdgeInsets.all(12),
            child: Row(
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                articulo.rubroDes.trim(),
                                style: TextStyle(
                                  fontSize: Fontsize.bodySmall,
                                  color: AppColors.semantics.text.body,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                "#${articulo.articuloId}",
                                style: TextStyle(
                                  color: AppColors.semantics.text.secondary,
                                  fontSize: Fontsize.bodySmall,
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      Text(
                        articulo.articuloDes.trim(),
                        style: TextStyle(
                          fontSize: Fontsize.body,
                          fontWeight: FontWeight.bold,
                          color: AppColors.semantics.text.body,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
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
          size: 30,
        ),
      );
    }

    try {
      final decodedBytes = base64Decode(base64Image);
      return Image.memory(
        decodedBytes,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade100,
            child: Icon(
              Icons.image_not_supported_outlined,
              color: Colors.grey.shade400,
              size: 30,
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
          size: 30,
        ),
      );
    }
  }

}
