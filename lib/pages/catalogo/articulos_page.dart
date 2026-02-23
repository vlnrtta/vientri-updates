// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'dart:ui';
import 'package:vientri/components/action_sheet/action_bottom_sheet.dart';
import 'package:vientri/components/subtle_button/subtle_button.dart';
import 'package:vientri/constants/app_shadows.dart';
import 'package:vientri/pages/controller.dart';
import 'package:vientri/components/search_bar/search_bar_control.dart';
import 'package:vientri/src/models/contacto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vientri/components/solid_button/solid_button.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/pages/catalogo/carrito_page.dart';
import 'package:vientri/src/models/articulo.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:vientri/src/models/entidad.dart';
import 'package:vientri/src/models/pedido.dart';

// ignore: must_be_immutable
class ArticuloPage extends StatefulWidget {
  int id;
  String filtro;
  String? rubroDes;
  Entidad entidad;
  Pedido pedido;

  ArticuloPage({super.key, required this.id, required this.filtro, required this.entidad, required this.pedido, this.rubroDes});

  @override
  State<ArticuloPage> createState() => _ArticuloPageState();
}

class _ArticuloPageState extends State<ArticuloPage> {
  late Controller con;
  final selectorCantidad = 1.obs;
  final unitario = "".obs;
  final descuento = 0.0.obs;
  var buscador = "".obs;
  List<Articulo> _articulos = [];
  bool _loading = true;
  bool _error = false;

    // TECLADO FIJO
  final RxBool isPressed = false.obs;
  final RxString pressedKey = ''.obs;
  final _input = "".obs;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final NumberFormat formatter = NumberFormat("#,##0.00", "en_US");
  int _descuentoActual = 0;


  final ScrollController _scrollController = ScrollController();
  final _showHeader = false.obs;
  final Rx<Color> _headerColor = Rx<Color>(const Color.fromARGB(255, 177, 177, 177).withOpacity(0.15));

  void _requestFocus() {
    if (!_focusNode.hasFocus && _controller.value.text.isNotEmpty) {
      // Solo selecciona si el campo no es vacío y no está ya enfocado
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    }
  }

  void _actualizarTexto(Articulo a) {
    String entrada = _input.value;

    double valor = 0;

    if (entrada.isNotEmpty) {
      entrada = entrada.replaceAll(',', '');
      double base = double.tryParse(entrada) ?? 0;

      if (entrada.contains('.') || entrada.length > 4) {
        // ya es decimal o un valor completo, no escalar
        valor = base;
      } else {
        int longitud = entrada.length;

        if (longitud <= 2) {
          valor = base * 1000;
        } else if (longitud == 3) {
          valor = base * 100;
        } else if (longitud == 4) {
          valor = base * 10;
        } else {
          valor = base * 1;
        }
      }
    }

    _controller.text = formatter.format(valor);
    unitario.value = _controller.text;
    
    double base = double.parse(formatter.format(a.impoconiva).replaceAll(",", ""));
    double nuevoUnitario = double.parse(unitario.value.replaceAll(",", ""));
    double diferencia = nuevoUnitario - base;
    descuento.value = (diferencia / base) * 100;
  }

  void _onKeyTap(BuildContext context, String value, Articulo a) {
    isPressed.value = true;

    if (value == '⌫') {
      if (_controller.selection.baseOffset == 0 &&
          _controller.selection.extentOffset == _controller.text.length) {
        _input.value = '';
        _descuentoActual = 0;
        _actualizarTexto(a);
      } else if (_descuentoActual > 0) {
        _descuentoActual -= 5;

        double precioLista = double.parse((a.impoconiva).toString());
        double nuevoPrecio = precioLista * (1 - (_descuentoActual / 100.0));

        _controller.text = formatter.format(nuevoPrecio);
      } else if (_input.value.isNotEmpty) {
        _input.value = _input.value.substring(0, _input.value.length - 1);
        _actualizarTexto(a);
      }
    } else if (value == '➤') {
      _agregar(a);
    } else if (_controller.selection.baseOffset == 0 &&
        _controller.selection.extentOffset == _controller.text.length &&
        value != '⌫' &&
        value != '➤' &&
        value != '-5%') {
      _input.value = value;
      _actualizarTexto(a);
    } else if (value == '-5%') {
      if (_descuentoActual < 50) {
        _descuentoActual += 5;
      }

      double precioLista = double.parse((a.impoconiva).toString());
      double nuevoPrecio = precioLista * (1 - (_descuentoActual / 100.0));

      _controller.text = formatter.format(nuevoPrecio);
    } else {
      _input.value += value;
      _actualizarTexto(a);
    }
  }

  @override
  void initState() {
    super.initState();
    con = Get.put(Controller(widget.entidad));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    });

    _scrollController.addListener(() {
      final offset = _scrollController.offset;

      if (offset > 50 && !_showHeader.value) {
        _showHeader.value = true;
      } else if (offset <= 50 && _showHeader.value) {
        _showHeader.value = false;
      }

      double factor = (offset / 200).clamp(0.0, 1.0);
      Color base = const Color.fromARGB(87, 255, 255, 255);
      Color dark = const Color.fromARGB(255, 255, 255, 255);

      _headerColor.value = Color.lerp(base, dark, factor)!.withOpacity(0.1 + 0.1 * factor);
    });

    if (ArticuloMemoria.lista.isEmpty) {
      _cargarArticulos();
    } else {
      setState(() {
        _articulos = ArticuloMemoria.lista;
      });
    }
  }

  Future<void> _cargarArticulos({bool forceRefresh = false}) async {
    if (ArticuloMemoria.lista.isNotEmpty && !forceRefresh) {
      setState(() {
        _articulos = ArticuloMemoria.lista;
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
      final lista = await con.listaArticulos(widget.rubroDes ?? "", widget.entidad);
      setState(() {
        _articulos = lista;
        ArticuloMemoria.lista = lista;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  void abrirBusqueda() {
    final popupController = SearchBarPopupController();
    SearchBarPopup.show(
      context,
      hintText: "Buscar artículo",
      controller: popupController,
      onChanged: (value) {
        buscador.value = value;
      },
    );
  }

  @override
  void dispose() {
    ArticuloMemoria.lista.clear();
    _focusNode.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Obx(() => Stack(
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context, true);
                                },
                                child: Icon(Icons.arrow_back, color: AppColors.semantics.text.body)
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: MediaQuery.sizeOf(context).width * 0.6,
                                child: Text(
                                  con.capitalizar(widget.rubroDes ?? ""),
                                  style: TextStyle(
                                    color: AppColors.semantics.text.body,
                                    fontSize: Fontsize.h2,
                                    fontWeight: FontWeight.w300
                                  ),
                                ),
                              )
                            ],
                          ),
                          IconButton(
                            icon: Icon(Icons.search, color: AppColors.semantics.text.body),
                            tooltip: 'Buscar',
                            onPressed: () {
                              abrirBusqueda();
                            },
                          ),
                        ],
                      ),
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

          if (widget.pedido.items != 0)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: _buildBottomButton(),
          )
        ],
      ),
    ));
  }

  Widget _buildContent() {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.semantics.text.action),
            const SizedBox(height: 20),
            Text(
              "Cargando productos...",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (_error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 70, color: Colors.red.shade300),
            const SizedBox(height: 16),
            const Text("No se pudo cargar el catálogo",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Intenta nuevamente más tarde",
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _cargarArticulos(forceRefresh: true),
              icon: const Icon(Icons.refresh),
              label: const Text("Reintentar"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.semantics.text.action,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    final filtrados = _articulos
      .where((a) => buscador.isEmpty
        ? true
        : a.articuloDes.toLowerCase().contains(buscador.value))
      .toList();

    if (filtrados.isEmpty) {
      return Center(
        child: Text(
          "No se encontraron resultados",
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      child: Container(
        color: Colors.white,
        child: ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.all(0),
          physics: const ClampingScrollPhysics(),
          itemCount: filtrados.length,
          itemBuilder: (_, index) {
            final articulo = filtrados[index];
            bool ultimo = index == filtrados.length - 1;
            return _buildCard(context, articulo, ultimo);
          },
        ),
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
            _requestFocus();
            _bottomSheet(context, articulo);
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                articulo.foto != "" ? _buildFruitImage(articulo.foto) : const SizedBox(width: 62),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.5,
                            child: Text(
                              articulo.rubroDes.trimRight(),
                              style: TextStyle(
                                fontSize: Fontsize.bodySmall,
                                color: AppColors.semantics.text.body,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "#${articulo.articuloId}",
                            style: TextStyle(
                              color: AppColors.semantics.text.secondary,
                              fontSize: Fontsize.bodySmall,
                            )
                          ),
                        ],
                      ),
                      Text(
                        articulo.articuloDes,
                        style: TextStyle(
                          fontSize: Fontsize.body,
                          fontWeight: FontWeight.bold,
                          color: AppColors.semantics.text.body,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "\$${NumberFormat("#,##0.00", "en_US").format(articulo.impoconiva)}",
                            style: TextStyle(
                              color: AppColors.semantics.text.body,
                              fontSize: Fontsize.body,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color:AppColors.semantics.surface.warning,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "Stock: ${articulo.cantidad}",
                              style: TextStyle(
                                color: AppColors.semantics.text.warning,
                                fontSize: Fontsize.bodySmall,
                              ),
                            ),
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
  }

  Widget _buildFruitImage(String base64Image) {
    final Uint8List decodedBytes;
    if (base64Image == "") {
      return const SizedBox();
    } else {
      decodedBytes = base64Decode(base64Image);
      try {
        return Container(
          width: 50,
          height: 50,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.memory(
              decodedBytes,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox();
              },
            ),
          ),
        );
      } catch (e) {
        return Container(
          width: MediaQuery.sizeOf(context).width * 0.18,
          height: MediaQuery.sizeOf(context).width * 0.18,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            Icons.image_not_supported_outlined,
            color: Colors.grey.shade400,
            size: MediaQuery.sizeOf(context).width * 0.1,
          ),
        );
      }
    }
  }

  Future _bottomSheet(BuildContext context, Articulo articulo) {
    //  reseteo de variables
    _input.value = "";
    selectorCantidad.value = 1;
    descuento.value = 0.0;
    _controller.text = formatter.format(articulo.impoconiva);
    unitario.value = _controller.text;
    // fin de reseteo de variables

    return ActionBottomSheet.show(
      context,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildFruitImage(articulo.foto),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  articulo.rubroDes,
                  style: TextStyle(
                    fontSize: Fontsize.h3,
                    color: AppColors.semantics.text.body,
                  ),
                ),
                Text(
                  articulo.articuloDes.toUpperCase(),
                  style: TextStyle(
                    fontSize: Fontsize.h3,
                    color: AppColors.semantics.text.body,
                    fontWeight: FontWeight.bold
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '#${articulo.articuloId} | \$${formatter.format(articulo.impoconiva)}',
                  style: TextStyle(
                    fontSize: Fontsize.body,
                    color: AppColors.semantics.text.secondary,
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
      content: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 32),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.semantics.text.secondary),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(CupertinoIcons.minus, color: AppColors.semantics.border.action),
                    onPressed: () {
                      if (selectorCantidad.value > 0) selectorCantidad.value--;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      selectorCantidad.value.toString(),
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  IconButton(
                    icon: Icon(CupertinoIcons.add, color: AppColors.semantics.border.action),
                    onPressed: () {
                      if (selectorCantidad.value < 9999) selectorCantidad.value++;
                    },
                  ),
                ],
              ))
            )
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.45,
                  child: Text('Precio unitario', style: TextStyle(fontSize: Fontsize.h3, fontWeight: FontWeight.bold, color: AppColors.semantics.text.body))
                ),
                const SizedBox(width: 16),
                Text('Importe', style: TextStyle(fontSize: Fontsize.h3, fontWeight: FontWeight.bold, color: AppColors.semantics.text.body)),
              ]
            ),
          ),

          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Precio unitario
                Container(
                  width: MediaQuery.sizeOf(context).width * 0.45,
                  padding: const EdgeInsets.only(left: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.semantics.border.action),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppShadows.elementFocusShadow
                  ),
                  child: Obx(() => TextField(
                    maxLengthEnforcement: MaxLengthEnforcement.enforced, 
                    focusNode: _focusNode,
                    showCursor: true,
                    readOnly: true,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    controller: _controller,
                    style: TextStyle(
                      fontSize: Fontsize.h2,
                      color: AppColors.semantics.text.body,
                      overflow: TextOverflow.clip,
                    ), 
                    minLines: 1,
                    maxLines: null,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.only(top: 10),
                      counterText: "",
                      suffixIcon: GestureDetector(
                        onTap: (unitario.value != formatter.format(articulo.impoconiva))
                          ? () {
                              unitario.value = formatter.format(articulo.impoconiva);
                              _controller.text = formatter.format(articulo.impoconiva);
                              descuento.value = 0.0;
                              _input.value = "";
                            }
                          : null,
                        child: Icon(
                          CupertinoIcons.arrow_2_circlepath,
                          color: unitario.value == formatter.format(articulo.impoconiva)
                            ? AppColors.semantics.text.secondary
                            : AppColors.semantics.text.action,
                        ),
                      ),
                    ),
                  )),
                ),

                const SizedBox(width: 16),

                // Importe y descuento
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: MediaQuery.sizeOf(context).width * 0.35,
                        child: Obx(() => Text(
                          '\$${formatter.format( double.parse( (unitario.value.replaceAll(",", "")) ) * selectorCantidad.value )}',
                          style: TextStyle(
                            fontSize: Fontsize.h2,
                            fontWeight: FontWeight.bold,
                            color: AppColors.semantics.text.body,
                          ),
                          maxLines: null,
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        )),
                      ),
                    ),

                    Obx(() => Text(
                      descuento.value < 0
                      ? '${descuento.value.toStringAsFixed(2)}%'
                      : "",
                      style: TextStyle(
                        color: AppColors.semantics.text.success,
                        fontWeight: FontWeight.w600,
                        fontSize: Fontsize.body
                      ),
                    )),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
                
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _pill(-0, double.parse(articulo.impoconiva.toString())),
              _pill(-5, double.parse(articulo.impoconiva.toString())),
              _pill(-10, double.parse(articulo.impoconiva.toString())),
              _pill(-15, double.parse(articulo.impoconiva.toString())),
              _pill(-20, double.parse(articulo.impoconiva.toString())),
            ],
          ),
          const SizedBox(height: 16),
          _teclado(articulo),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SubtleButton(
                    text: "Quitar",
                    leftIcon: Icons.delete_outline_rounded,
                    type: SubtleButtonType.error,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SolidButton(
                    text: "Agregar",
                    leftIcon: Icons.shopping_cart_checkout_outlined,
                    type: SolidButtonType.primary,
                    onPressed: () {
                      Navigator.pop(context, true);
                      _agregar(articulo);
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
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _teclado(Articulo articulo) {
    const keyStyle = TextStyle(fontSize: 24, fontWeight: FontWeight.w600);
    final keyHeight = MediaQuery.sizeOf(context).height * 0.06;
    
    Widget buildKey(String key) {
      return Obx(() {
        final isPressedKey = pressedKey.value == key;
        return GestureDetector(
          onTapDown: (_) => pressedKey.value = key,
          onTapUp: (_) {
            Future.delayed(const Duration(milliseconds: 100), () {
              pressedKey.value = '';
            });
            _onKeyTap(context, key, articulo);
          },
          onTapCancel: () => pressedKey.value = '',
          child: AnimatedContainer(
            margin: const EdgeInsets.only(bottom: 16),
            height: keyHeight,
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
              child: Text(key, style: keyStyle.copyWith(color: AppColors.semantics.text.body, fontSize: 24, fontWeight: FontWeight.w600)),
            ),
          ),
        );
      });
    }

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Table(
              defaultColumnWidth: const FlexColumnWidth(1),
              children: [
                TableRow(children: [
                  buildKey('1'),
                  buildKey('2'),
                  buildKey('3'),
                ]),
                TableRow(children: [
                  buildKey('4'),
                  buildKey('5'),
                  buildKey('6'),
                ]),
                TableRow(children: [
                  buildKey('7'),
                  buildKey('8'),
                  buildKey('9'),
                ]),
                TableRow(children: [
                  buildKey('.'),
                  buildKey('0'),
                  buildKey('⌫'),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(int porcentaje, double precioLista) {
    return Obx(() => InkWell(
      onTap: () {
        descuento.value = double.parse(porcentaje.toString());
        _controller.text = formatter.format(precioLista);
        _controller.text = formatter.format(double.parse((_controller.text.replaceAll(",", ""))) - double.parse((_controller.text.replaceAll(",", ""))) * (-descuento.value / 100));
        unitario.value = _controller.text;
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: descuento.value == porcentaje ? AppColors.semantics.surface.action : AppColors.semantics.surface.disabled,
          borderRadius: BorderRadius.circular(12)
        ),
        child: Text(
          "${porcentaje.toString()}%",
          style: TextStyle(
            color: descuento.value == porcentaje ? Colors.white : AppColors.semantics.text.body,
            fontSize: Fontsize.h3
          ),
        ),
      ),
    ));
  }

  void _agregar(Articulo articulo) async {    
    widget.pedido.total += double.parse(_controller.text.replaceAll(",", "")) * selectorCantidad.value;
    widget.pedido.items += selectorCantidad.value;

    Detalle detalle = Detalle(
      itemId: 0,
      cantidad: selectorCantidad.value,
      unifinal: double.parse(articulo.impoconiva.toString()),
      unifinalcdto: double.parse( (unitario.value.replaceAll(",", "")) ),
      pdto: (descuento.value >= 0) ? 0 : -descuento.value,
      total: double.parse( (unitario.value.replaceAll(",", "")) ) * selectorCantidad.value,
      articuloId: articulo.articuloId,
      articuloDes: articulo.articuloDes.trim(),
      articuloCod: articulo.articuloCod,
      rubroId: articulo.rubroId,
      subRubroId: 0,
      rubroDes: articulo.rubroDes.trim(),
      subRubroDes: "",
      foto: articulo.foto
    );

    final data = GetStorage().read("contacto");
    Contacto contacto = data != null ? Contacto.fromJson(data) : Contacto(email: "", telefono: "", horario: "", obs: "", des: "", fecsys: "", fecins: "", nomCliente: "", id: -1, idPer: -1, idArea: -1);
    widget.pedido.idContactoPer = contacto.id;
    widget.pedido.nameContacto = contacto.des;
    widget.pedido.telefono = contacto.telefono;
    widget.pedido.idPer = contacto.idPer;
    widget.pedido.fecha = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());

    if (widget.pedido.id == 0) {
      widget.pedido.id = await con.actualizarPedido(context, widget.entidad, widget.pedido);
      detalle.itemId = await con.actualizarPedidoItem(context, widget.entidad, widget.pedido, detalle);
      con.cambiarEstadoPedido(widget.pedido.id, "EN CURSO", widget.entidad);
    } else {
      detalle.itemId = await con.actualizarPedidoItem(context, widget.entidad, widget.pedido, detalle);
    }

    widget.pedido.detalle.add(detalle);
    double valorNeto = 0.0;
    double valorUni = 0.0;

    for (var detalle in widget.pedido.detalle) {
      valorNeto += detalle.unifinal;
      valorUni += detalle.unifinalcdto;
    }

    double diferencia = valorNeto - valorUni;
    widget.pedido.pdto = (diferencia / valorNeto) * 100;

    Navigator.pop(context, true);
  }

}

class ArticuloMemoria {
  static List<Articulo> lista = [];
}