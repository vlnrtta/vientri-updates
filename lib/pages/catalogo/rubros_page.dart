import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:vientri/constants/app_shadows.dart';
import 'package:vientri/pages/controller.dart';
import 'package:vientri/pages/catalogo/articulos_page.dart';
import 'package:vientri/pages/catalogo/carrito_page.dart';
import 'package:vientri/src/models/rubro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:vientri/components/solid_button/solid_button.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/pages/contacto/buscador_contacto_page.dart';
import 'package:vientri/pages/contacto/contacto_controller.dart';
import 'package:vientri/src/models/contacto.dart';
import 'package:vientri/src/models/entidad.dart';
import 'package:vientri/src/models/pedido.dart';

// ignore: must_be_immutable
class RubroPage extends StatefulWidget {
  Entidad entidad;
  int? carritoId;
  Pedido pedido;
  RubroPage({super.key, required this.entidad, this.carritoId, required this.pedido});

  @override
  State<RubroPage> createState() => _RubroPage();
}

class _RubroPage extends State<RubroPage> {
  late Controller cont;
  String? seleccion;
  final TextEditingController _controllerSearch = TextEditingController();
  var equis = false.obs;
  Contacto contactoSeleccionado = GetStorage().read('contacto') != null ? Contacto.fromJson(GetStorage().read('contacto')) : Contacto(id: 0, idPer: 0, idArea: 0, email: "", telefono: "", horario: "", ccsiempre: false, obs: "", enviarDocumentos: false, des: "", idTipoClasificacion: 0, fecsys: "", fecins: "", nomCliente: "");
  late ContactoController contactoController;
  late Contacto contacto;
  List<Rubro> _rubros = [];
  bool _loading = true;
  bool _error = false;
  final filtro = "".obs;
  final Rx<Color> _headerColor = Rx<Color>(const Color.fromARGB(255, 177, 177, 177).withOpacity(0.15));


  int obtenerNumeroRandom({int min = 0, int max = 100}) {
    final random = Random();
    return min + random.nextInt(max - min + 1);
  }

  @override
  void initState() {
    super.initState();
    contactoController = Get.put(ContactoController(widget.entidad));
    cont = Get.put(Controller(widget.entidad));
    if (RubroMemoria.lista.isEmpty) {
      _cargarRubros();
    } else {
      setState(() {
        _rubros = RubroMemoria.lista;
        _loading = false;
        _error = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _cargarRubros({bool forceRefresh = false}) async {
    if (RubroMemoria.lista.isNotEmpty && !forceRefresh) {
      setState(() {
        _rubros = RubroMemoria.lista;
        _loading = false;
        _error = false;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = false;
    });

    try {
      final lista = await cont.listaRubros(widget.entidad);
      setState(() {
        _rubros = lista;
        RubroMemoria.lista = lista; // Guarda en memoria
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
  Widget build(BuildContext context) {
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
            children: [
              ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: _headerColor.value,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: _buildHeader(),
                    ),
                  ),
                ),
              ),
              
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 16 + MediaQuery.of(context).viewInsets.top, left: 16, right: 16, bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: _buildContent(),
                ),
              ),
          
              if (widget.pedido.items > 0)
              Padding(
                padding: const EdgeInsets.all(16),
                child: _buildBottomButton(),
              ),
          
           ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(widget.pedido.items <= 0 ? 0 : 16),
        bottomRight: Radius.circular(widget.pedido.items <= 0 ? 0 : 16),
        topLeft: const Radius.circular(16),
        topRight: const Radius.circular(16),
      ),
      child: _loading
      ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.semantics.text.action),
            const SizedBox(height: 20),
            Text(
              "Cargando categorías...",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      )
      : _error
        ? _buildErrorUI()
        : _rubros.isEmpty
          ? _buildEmptyUI()
          : Obx(() {
            final filtroValue = filtro.value;
    
            final rubrosFiltrados = _rubros.where((r) =>
              filtroValue.isEmpty
                ? true
                : r.rubroDes.toLowerCase().contains(filtroValue.toLowerCase())
            ).toList();
            return LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                int crossAxisCount;
                if (screenWidth >= 900) {
                  crossAxisCount = 5;
                } else if (screenWidth >= 600) {
                  crossAxisCount = 4;
                } else {
                  crossAxisCount = 3;
                }
                double childAspectRatio = 1.3;
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(36, 63, 63, 63),
                        blurRadius: 5,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: childAspectRatio,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 0,
                    ),
                    itemCount: rubrosFiltrados.length,
                    itemBuilder: (_, index) {
                      double cellWidth =
                          (screenWidth - (crossAxisCount - 1) * 12 - 32) / crossAxisCount;
                      double imageSize = cellWidth * 0.5;
                      return _buildFruitCard(rubrosFiltrados[index], imageSize);
                    },
                  ),
                );
              },
            );
          },
        )
      );
  }

  Widget _buildHeader() {
    return SafeArea(
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context, true);
                  },
                  child: Icon(Icons.arrow_back, color: AppColors.semantics.text.body)
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 300,
                  ),
                  child: IntrinsicWidth(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => BuscadorContactoPage(entidad: widget.entidad, pedido: widget.pedido),
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
                              final data = GetStorage().read("contacto");
                              contacto = data != null ? Contacto.fromJson(data) : Contacto(email: "", telefono: "", horario: "", obs: "", des: "", fecsys: "", fecins: "", nomCliente: "", id: -1, idPer: -1, idArea: -1);
                              widget.pedido.idContactoPer = contacto.id;
                              widget.pedido.nameContacto = contacto.des;
                              widget.pedido.telefono = contacto.telefono;
                              widget.pedido.idPer = contacto.idPer;
                            });
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.all(Radius.circular(999)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.person,
                              color: widget.pedido.telefono == "" ? AppColors.semantics.text.secondary : AppColors.semantics.text.body,
                              size: Fontsize.h1,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                widget.pedido.telefono == ""
                                ? "Seleccionar contacto"
                                : widget.pedido.nameContacto == ""
                                  ? widget.pedido.telefono
                                  : contactoController.capitalizarNombre(widget.pedido.nameContacto),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: widget.pedido.telefono == "" ? AppColors.semantics.text.secondary : AppColors.semantics.text.body,
                                  fontSize: Fontsize.body,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              CupertinoIcons.chevron_down,
                              color: AppColors.semantics.text.secondary,
                              size: Fontsize.body,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => CarritoPage(entidad: widget.entidad, pedido: widget.pedido),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          final tween = Tween(begin: begin, end: end)
                            .chain(CurveTween(curve: Curves.ease));
                          return SlideTransition(
                            position: animation.drive(tween), 
                            child: child
                          );
                        },
                        transitionDuration: const Duration(milliseconds: 400),
                      ),
                    ).then((value) {
                      if (value == true) {
                        setState(() {
                          widget.pedido = widget.pedido;
                        });
                      }
                    });
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        color: AppColors.semantics.text.body,
                      ),
                      Positioned(
                        right: -10,
                        top: -16,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                          child: Center(
                            child: Text(
                              widget.pedido.items.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSearchBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Obx(() => Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
              onSubmitted: (value) {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => ArticuloPage(id: -1, filtro: value, entidad: widget.entidad, pedido: widget.pedido),
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
                hintText: "Buscar artículo...",
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
    ));
  }

  Widget _buildErrorUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 70, color: Colors.red.shade300),
          const SizedBox(height: 16),
          const Text("No se pudo cargar el catálogo", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Intenta nuevamente más tarde", style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _cargarRubros,
            icon: const Icon(Icons.refresh),
            label: const Text("Reintentar"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 70, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text("No se encontraron categorías", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Error de conexión", style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _controllerSearch.text = "";
              setState(() {
                _cargarRubros();
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text("Reintentar"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.semantics.surface.action,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFruitCard(Rubro rubro, double imageSize) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Material(
        child: InkWell(
          onTap: () => {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => ArticuloPage(id: rubro.rubroId, filtro: "", rubroDes: rubro.rubroDes, entidad: widget.entidad, pedido: widget.pedido),
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
            })
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: imageSize,
                width: imageSize,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(imageSize / 2),
                  child: _buildFruitImageFull(rubro.foto),
                ),
              ),
              Text(
                rubro.rubroDes,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF333333),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFruitImageFull(String base64Image) {
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
              size: 20,
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
          size: 20,
        ),
      );
    }
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.containerShadow
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Artículos',
                style: TextStyle(
                  fontSize: Fontsize.h3,
                  color: AppColors.semantics.text.body,
                ),
              ),
              Text(
                widget.pedido.items.toString(),
                style: TextStyle(
                  fontSize: Fontsize.h3,
                  color: AppColors.semantics.text.body,
                ),
              ),
            ],
          ),
          
          if (widget.pedido.pdto > 0)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Descuento',
                    style: TextStyle(
                      fontSize: Fontsize.h3,
                      color: AppColors.semantics.text.body,
                    ),
                  ),
                  Text(
                    'Descuento general ${widget.pedido.pdto.toStringAsFixed(2)}%',
                    style: TextStyle(
                      fontSize: Fontsize.body,
                      color: AppColors.semantics.text.success,
                    ),
                  ),
                ],
              ),
              Text(
                "\$${NumberFormat("#,##0.00", "en_US").format( ((widget.pedido.total) / (1 - (widget.pedido.pdto / 100))) - widget.pedido.total)}",
                style: TextStyle(
                  fontSize: Fontsize.h2,
                  color: AppColors.semantics.text.body,
                ),
              ),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontSize: Fontsize.h3,
                  color: AppColors.semantics.text.body,
                ),
              ),
              Text(
                "\$${NumberFormat("#,##0.00", "en_US").format(widget.pedido.total)}",
                style: TextStyle(
                  fontSize: Fontsize.h2,
                  fontWeight: FontWeight.bold,
                  color: AppColors.semantics.text.body,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          SolidButton(
            text: "Carrito",
            leftIcon: Icons.shopping_cart_outlined,
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => CarritoPage(entidad: widget.entidad, pedido: widget.pedido),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    final tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: Curves.ease));
                    return SlideTransition(
                      position: animation.drive(tween), 
                      child: child
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 400),
                ),
              ).then((value) {
                if (value == true) {
                  setState(() {
                    widget.pedido = widget.pedido;
                  });
                }
              });
            },
          ),
        ],
      ),
    );
  }

}

class RubroMemoria {
  static List<Rubro> lista = [];
}
