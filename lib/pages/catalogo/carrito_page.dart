// ignore_for_file: unused_local_variable, use_build_context_synchronously
import 'dart:convert';
import 'dart:ui';
import 'package:vientri/components/action_sheet/action_bottom_sheet.dart';
import 'package:vientri/constants/app_shadows.dart';
import 'package:vientri/pages/contacto/buscador_contacto_page.dart';
import 'package:vientri/pages/controller.dart';
import 'package:vientri/src/models/contacto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vientri/components/badge/badge.dart';
import 'package:vientri/components/solid_button/solid_button.dart';
import 'package:vientri/components/subtle_button/subtle_button.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/constants/notificaciones.dart';
import 'package:vientri/pages/contacto/contacto_controller.dart';
import 'package:vientri/src/models/entidad.dart';
import 'package:vientri/src/models/pedido.dart';

// ignore: must_be_immutable
class CarritoPage extends StatefulWidget {
  Entidad entidad;
  Pedido pedido;
  CarritoPage({super.key, required this.entidad, required this.pedido});

  @override
  State<CarritoPage> createState() => _CarritoPageState();
}

class _CarritoPageState extends State<CarritoPage>
  with SingleTickerProviderStateMixin {
  late Controller con;
  late Future<List<Detalle>> _futureDetalle;
  final ScrollController _scrollController = ScrollController();
  final _showHeader = false.obs;
  final Rx<Color> _headerColor = Rx<Color>(const Color.fromARGB(255, 177, 177, 177).withOpacity(0.15));
  late Contacto contacto;
  late ContactoController contactoController;
  bool mostrarCarga = true;

  final selectorCantidad = 1.obs;
  final unitario = "".obs;
  final descuento = 0.0.obs;

    // TECLADO FIJO
  final RxBool isPressed = false.obs;
  final RxString pressedKey = ''.obs;
  final _input = "".obs;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final NumberFormat formatter = NumberFormat("#,##0.00", "en_US");
  int _descuentoActual = 0;

  void _requestFocus() {
    if (!_focusNode.hasFocus && _controller.value.text.isNotEmpty) {
      // Solo selecciona si el campo no es vacío y no está ya enfocado
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    }
  }

  void _actualizarTexto(Detalle d) {
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
    
    double base = double.parse(formatter.format(d.unifinal).replaceAll(",", ""));
    double nuevoUnitario = double.parse(unitario.value.replaceAll(",", ""));
    double diferencia = nuevoUnitario - base;
    descuento.value = (diferencia / base) * 100;
  }

  void _onKeyTap(BuildContext context, String value, Detalle d) {
    isPressed.value = true;

    if (value == '⌫') {
      if (_controller.selection.baseOffset == 0 &&
          _controller.selection.extentOffset == _controller.text.length) {
        _input.value = '';
        _descuentoActual = 0;
        _actualizarTexto(d);
      } else if (_descuentoActual > 0) {
        _descuentoActual -= 5;

        double precioLista = double.parse((d.unifinal).toString());
        double nuevoPrecio = precioLista * (1 - (_descuentoActual / 100.0));

        _controller.text = formatter.format(nuevoPrecio);
      } else if (_input.value.isNotEmpty) {
        _input.value = _input.value.substring(0, _input.value.length - 1);
        _actualizarTexto(d);
      }
    } else if (value == '➤') {
      _editar(d);
    } else if (_controller.selection.baseOffset == 0 &&
        _controller.selection.extentOffset == _controller.text.length &&
        value != '⌫' &&
        value != '➤' &&
        value != '-5%') {
      _input.value = value;
      _actualizarTexto(d);
    } else if (value == '-5%') {
      if (_descuentoActual < 50) {
        _descuentoActual += 5;
      }

      double precioLista = double.parse((d.unifinal).toString());
      double nuevoPrecio = precioLista * (1 - (_descuentoActual / 100.0));

      _controller.text = formatter.format(nuevoPrecio);
    } else {
      _input.value += value;
      _actualizarTexto(d);
    }
  }

  void _eliminarItem(Detalle item) {
    setState(() {
      widget.pedido.detalle.removeWhere((elemento) =>
        elemento.itemId == item.itemId
      );
      if (widget.pedido.detalle.isEmpty) {
      }
    });
  }

  @override
  void initState() {
    super.initState();
    contactoController = Get.put(ContactoController(widget.entidad));
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
    
    if (widget.pedido.items > 0) {
      Future.delayed(const Duration(milliseconds: 800), () {
        setState(() {
          mostrarCarga = false;
        });
      });
      _futureDetalle = con.listaDetalles(widget.pedido.id);
    } else {
      mostrarCarga = false;
    }
  }



  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if (mostrarCarga) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFF0E4FF),
                Color(0xFFF5F5F5)
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              children: [
                const SizedBox(height: 60),
                // Nombre del cliente
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    height: 20,
                    width: 100, 
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Lista de artículos
                Expanded(
                  child: ListView.builder(
                    itemCount: 10,
                    itemBuilder: (_, __) => _buildShimmerItem(),
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Container(height: 20, width: 80, decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const Spacer(),
                      Container(height: 20, width: 120, decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    height: 48,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      );
    }

    return NotificationWrapper(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFF0E4FF),
                    Color(0xFFF5F5F5)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            widget.pedido.items == 0
            ? Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(),
                Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.semantics.surface.glassFill,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add_shopping_cart_outlined,
                        size: 60,
                        color: AppColors.semantics.surface.action,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tu carrito está vacío',
                      style: TextStyle(
                        fontSize: Fontsize.h1,
                        color: AppColors.semantics.text.body,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SolidButton(
                    type: SolidButtonType.primary,
                    text: "Ir a comprar",
                    leftIcon: Icons.add_shopping_cart_rounded,
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ),
              ],
            )
            : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
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
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context, true);
                                },
                                child: Icon(
                                  Icons.arrow_back_rounded,
                                  color: AppColors.semantics.text.body,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 8),
                              widget.pedido.nameContacto != ""
                              ? SizedBox(
                                width: MediaQuery.sizeOf(context).width * 0.5,
                                child: Text(
                                  contactoController.capitalizarNombre(widget.pedido.nameContacto),
                                  style: TextStyle(
                                    color: AppColors.semantics.text.body,
                                    fontSize: Fontsize.h2,
                                    fontWeight: FontWeight.w300,
                                    overflow: TextOverflow.clip
                                  ),
                                  maxLines: 2,
                                ),
                              )
                              : ConstrainedBox(
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
                              const Spacer(),
                              AppBadge(
                                text: widget.pedido.estado.toUpperCase() == "EN CURSO"
                                  ? "En curso"
                                  : widget.pedido.estado.toUpperCase() == "EN CAJA"
                                    ? "En caja"
                                    : widget.pedido.estado.toUpperCase() == "COBRADO"
                                      ? "Cobrado"
                                      : "S/D",
                                type: widget.pedido.estado.toUpperCase() == "EN CURSO"
                                  ? AppBadgeType.action
                                  : widget.pedido.estado.toUpperCase() == "EN CAJA" || widget.pedido.estado.toUpperCase() == "COBRADO"
                                    ? AppBadgeType.success
                                    : AppBadgeType.information,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
               
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Fecha",
                        style: TextStyle(
                          color: AppColors.semantics.text.secondary,
                          fontSize: Fontsize.body
                        ),
                      ),
                      Text(
                        DateFormat("d MMM. yyyy", "es_ES").format(DateTime.parse(widget.pedido.fecha)),
                        style: TextStyle(
                          color: AppColors.semantics.text.body,
                          fontSize: Fontsize.h3
                        ),
                      ),
                    ],
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
      ),
    );
  }

  Widget _buildContent() {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      child: FutureBuilder(
        future: _futureDetalle,
        builder: (context, AsyncSnapshot<List<Detalle>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: AppColors.semantics.text.action,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Cargando productos...",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 70, color: AppColors.semantics.text.error),
                  const SizedBox(height: 16),
                  const Text(
                    "No se pudo cargar",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Intenta nuevamente más tarde",
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      _futureDetalle = con.listaDetalles(widget.pedido.id);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text("Reintentar"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.semantics.text.action,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 70, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      "No se encontraron productos",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Intenta en otro momento",
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              );
            }
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(8)),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(36, 63, 63, 63),
                    blurRadius: 5,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.all(0),
                itemCount: snapshot.data!.length,
                itemBuilder: (_, index) {
                  bool ultimo = snapshot.data!.length -1 == index;
                  return _buildCartItem(snapshot.data![index], ultimo);
                },
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget _buildCartItem(Detalle item, bool ultimo) {
    final String discountText = item.tieneDescuento ? "-${(item.pdto).toStringAsFixed(0)}%" : "";
    return widget.pedido.estado == "EN CURSO"
    ? Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) {
              _eliminarItem(item);
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete_rounded,
            label: 'Eliminar',
            padding: const EdgeInsets.all(0),
          ),
        ]),
        child: Container(
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
              onTap: () {
                _bottomSheet(context, item);
                _requestFocus();
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Quantity indicator
                    Container(
                      width: 30,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${item.cantidad}',
                        style: const TextStyle(
                          fontSize: Fontsize.body,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    // Product details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: Fontsize.body,
                                color: AppColors.semantics.text.secondary,
                              ),
                              children: [
                                TextSpan(
                                  text: item.rubroDes.toString().trim(),
                                  style: TextStyle(fontSize: Fontsize.body, color: AppColors.semantics.text.body),
                                ),
                                const TextSpan(text: " | "),
                                TextSpan(
                                  text: "\$${NumberFormat("#,##0.00", "en_US").format(item.unifinal)} ",
                                  style: TextStyle(fontSize: Fontsize.body, color: AppColors.semantics.text.body),
                                ),
                              ],
                            ),
                          ),
                          // Product code and description
                          const SizedBox(height: 4),
                          Text(
                            "#${item.articuloId} | ${item.articuloDes}",
                            style: TextStyle(
                              fontSize: Fontsize.body,
                              color: AppColors.semantics.text.secondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Total price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Center(
                          child: Text(
                            "\$${NumberFormat("#,##0.00", "en_US").format(item.total)}",
                            style: TextStyle(
                              fontSize: Fontsize.body,
                              color: AppColors.semantics.text.body,
                            ),
                          ),
                        ),
                        if (item.tieneDescuento)
                        Text(
                          discountText,
                          style: TextStyle(fontSize: Fontsize.bodySmall, color: AppColors.semantics.text.success),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
    )
    : Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Quantity indicator
            Container(
              width: 30,
              alignment: Alignment.centerLeft,
              child: Text(
                '${item.cantidad}',
                style: const TextStyle(
                  fontSize: Fontsize.body,
                  color: Colors.black87,
                ),
              ),
            ),
            // Product details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: Fontsize.body,
                        color: AppColors.semantics.text.secondary,
                      ),
                      children: [
                        TextSpan(
                          text: item.rubroDes.toString().trim(),
                          style: TextStyle(fontSize: Fontsize.body, color: AppColors.semantics.text.body),
                        ),
                        const TextSpan(text: " | "),
                        TextSpan(
                          text: "\$${NumberFormat("#,##0.00", "en_US").format(item.unifinal)} ",
                          style: TextStyle(fontSize: Fontsize.body, color: AppColors.semantics.text.body),
                        ),
                      ],
                    ),
                  ),
                  
                  // Product code and description
                  const SizedBox(height: 4),
                  Text(
                    "#${item.articuloId} | ${item.articuloDes}",
                    style: TextStyle(
                      fontSize: Fontsize.body,
                      color: AppColors.semantics.text.secondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Total price
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "\$${NumberFormat("#,##0.00", "en_US").format(item.total)}",
                    style: TextStyle(
                      fontSize: Fontsize.body,
                      color: AppColors.semantics.text.body,
                    ),
                  ),
                  if (item.tieneDescuento)
                  Text(
                    discountText,
                    style: TextStyle(fontSize: Fontsize.bodySmall, color: AppColors.semantics.text.success),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Cantidad
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 12),
          // Descripción
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 12,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Precio
          Container(
            height: 14,
            width: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
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
          Column(
            children: [
              widget.pedido.estado == "EN CAJA"
              ? SolidButton(
                type: SolidButtonType.secondary,
                text: "Enviar al cliente",
                leftIcon: Icons.phone_rounded,
                onPressed: () async {
                  /*con.cargarCarritoDesdeStorage();
                  String resumen = con.generarResumenPedido(con.carrito);
                  Contacto contactoSeleccionado2 = GetStorage().read('contacto') != null ? Contacto.fromJson(GetStorage().read('contacto')) : Contacto(id: 0, idPer: 0, idArea: 0, email: "", telefono: "", horario: "", ccsiempre: false, obs: "", enviarDocumentos: false, des: "", idTipoClasificacion: 0, fecsys: "", fecins: "", nomCliente: "");
                  con.enviarMensajeWhatsApp(contactoSeleccionado2.telefono!, resumen);*/
                }
              )
              : SubtleButton(
                text: "Añadir artículo",
                leftIcon: CupertinoIcons.add,
                type: SubtleButtonType.brand,
                onPressed: () => Navigator.pop(context, true),
              ),
              const SizedBox(height: 10),
              SolidButton(
                type: SolidButtonType.primary,
                text: widget.pedido.estado == "EN CAJA" ? "Editar pedido" : "Enviar a caja",
                leftIcon: widget.pedido.estado == "EN CURSO" ? CupertinoIcons.paperplane : null,
                onPressed: () async {
                  if (widget.pedido.estado == "EN CAJA") {
                    con.cambiarEstadoPedido(widget.pedido.id, "EN CURSO", widget.entidad);
                    setState(() {
                      widget.pedido.estado = "EN CURSO";
                    });
                  } else if (widget.pedido.estado == "EN CURSO") {
                    con.cambiarEstadoPedido(widget.pedido.id, "EN CAJA", widget.entidad);
                    setState(() {
                      widget.pedido.estado = "EN CAJA";
                    });
                  }
                }
              ),
            ],
          )
        ],
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

  Future _bottomSheet(BuildContext context, Detalle detalle) {
    //  reseteo de variables
    _input.value = "";
    selectorCantidad.value = detalle.cantidad;
    descuento.value = -detalle.pdto;
    _controller.text = formatter.format(detalle.unifinalcdto);
    unitario.value = _controller.text;
    // fin de reseteo de variables

    return ActionBottomSheet.show(
      context,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildFruitImage(detalle.foto),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detalle.rubroDes,
                  style: TextStyle(
                    fontSize: Fontsize.h3,
                    color: AppColors.semantics.text.body,
                  ),
                ),
                Text(
                  detalle.articuloDes.toUpperCase(),
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
                  '#${detalle.articuloId} | \$${formatter.format(detalle.unifinal)}',
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
                        onTap: (unitario.value != formatter.format(detalle.unifinal))
                          ? () {
                              unitario.value = formatter.format(detalle.unifinal);
                              _controller.text = formatter.format(detalle.unifinal);
                              descuento.value = 0.0;
                              _input.value = "";
                            }
                          : null,
                        child: Icon(
                          CupertinoIcons.arrow_2_circlepath,
                          color: unitario.value == formatter.format(detalle.unifinal)
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
                    
                    if (detalle.tieneDescuento)
                    Obx(() => Text(
                      '${descuento.value.toStringAsFixed(2)}%',
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
              _pill(-0, double.parse(detalle.unifinal.toString())),
              _pill(-5, double.parse(detalle.unifinal.toString())),
              _pill(-10, double.parse(detalle.unifinal.toString())),
              _pill(-15, double.parse(detalle.unifinal.toString())),
              _pill(-20, double.parse(detalle.unifinal.toString())),
            ],
          ),
          const SizedBox(height: 16),
          _teclado(detalle),
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
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SolidButton(
                    text: "Agregar",
                    leftIcon: Icons.shopping_cart_checkout_outlined,
                    type: SolidButtonType.primary,
                    onPressed: () {
                      setState(() {
                        _editar(detalle);
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

  Widget _teclado(Detalle detalle) {
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
            _onKeyTap(context, key, detalle);
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

  void _editar(Detalle d) async {
    widget.pedido.total = 0;
    widget.pedido.items = 0;

    Detalle detalle = Detalle(
      itemId: d.itemId,
      cantidad: selectorCantidad.value,
      unifinal: double.parse(d.unifinal.toString()),
      unifinalcdto: double.parse( (unitario.value.replaceAll(",", "")) ),
      pdto: -descuento.value,
      total: double.parse( (unitario.value.replaceAll(",", "")) ) * selectorCantidad.value,
      articuloId: d.articuloId,
      articuloDes: d.articuloDes.trim(),
      articuloCod: d.articuloCod,
      rubroId: d.rubroId,
      subRubroId: 0,
      rubroDes: d.rubroDes.trim(),
      subRubroDes: "",
      foto: d.foto
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

    for (int i = 0; i < widget.pedido.detalle.length; i++) {
      if (widget.pedido.detalle[i].itemId == detalle.itemId) {
        widget.pedido.detalle[i] = detalle;
      }
    }

    double valorNeto = 0.0;
    double valorUni = 0.0;

    for (var detalle in widget.pedido.detalle) {
      valorNeto += detalle.unifinal;
      valorUni += detalle.unifinalcdto;
      widget.pedido.total += detalle.total;
      widget.pedido.items += detalle.cantidad;
    }

    double diferencia = valorNeto - valorUni;
    widget.pedido.pdto = (diferencia / valorNeto) * 100;

    Navigator.pop(context, true);
    setState(() {
      _futureDetalle = con.listaDetalles(widget.pedido.id);
    });

  }

}


