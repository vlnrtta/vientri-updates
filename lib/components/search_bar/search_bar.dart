// ignore_for_file: unused_element, avoid_print

import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vientri/components/badge/badge.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/constants/app_shadows.dart';
import 'package:vientri/src/models/articulo.dart';

class SearchBarPopupController {
  final ValueNotifier<List<Articulo>> resultsNotifier =
      ValueNotifier<List<Articulo>>([]);

  void updateResults(List<Articulo> results) {
    resultsNotifier.value = results;
  }

  void dispose() {
    resultsNotifier.dispose();
  }
}

class SearchBarPopup extends StatefulWidget {
  final String hintText;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSearchSubmitted;
  final bool isDisabled;
  final bool mostrarCheckAgregado;
  final List<Articulo>? searchResults;
  final List<Articulo>? articulosAgregados;

  final SearchBarPopupController? controller;

  final ValueChanged<Articulo>? onOptionSelected;

  const SearchBarPopup({
    super.key,
    required this.hintText,
    this.initialValue,
    this.onChanged,
    this.onSearchSubmitted,
    this.isDisabled = false,
    this.searchResults,
    this.controller,
    required this.mostrarCheckAgregado,
    this.onOptionSelected,
    required this.articulosAgregados,
  });

  static Future show(
    BuildContext context, {
    required String hintText,
    String? initialValue,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSearchSubmitted,
    bool isDisabled = false,
    List<Articulo>? searchResults,
    SearchBarPopupController? controller,
    required bool mostrarCheckAgregado,
    ValueChanged<Articulo>? onOptionSelected,
    List<Articulo>? articulosAgregados,
    VoidCallback? onClose,
    Color barrierColor = const Color(0xB3C8C8C8),
    double blurSigma = 8.0,
  }) async {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Stack(
          children: [
            FadeTransition(
              opacity: animation,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  onClose?.call();
                },
                behavior: HitTestBehavior.opaque,
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: blurSigma,
                    sigmaY: blurSigma,
                  ),
                  child: Container(color: barrierColor),
                ),
              ),
            ),
            SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0.0, -1.0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: Align(
                alignment: Alignment.topCenter,
                child: Material(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 80,
                      left: 16,
                      right: 16,
                    ),
                    child: SearchBarPopup(
                      hintText: hintText,
                      initialValue: initialValue,
                      onChanged: onChanged,
                      onSearchSubmitted: onSearchSubmitted,
                      isDisabled: isDisabled,
                      searchResults: searchResults,
                      controller: controller,
                      mostrarCheckAgregado: mostrarCheckAgregado,
                      onOptionSelected: onOptionSelected,
                      articulosAgregados: articulosAgregados,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  State<SearchBarPopup> createState() => _SearchBarPopupState();
}

class _SearchBarPopupState extends State<SearchBarPopup> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _hasText = false;
  bool _isSearchBarFocused = false;
  late List<Articulo> _agregadosInternos;

  List<Articulo> _results = [];
  VoidCallback? _controllerListener;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_onTextChanged);
    _hasText = _controller.text.isNotEmpty;
    _agregadosInternos = [...widget.articulosAgregados!];
    _results = widget.searchResults ?? [];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.isDisabled) _focusNode.requestFocus();
    });

    if (widget.controller != null) {
      _controllerListener = () {
        setState(() {
          _results = widget.controller!.resultsNotifier.value;
        });
      };
      widget.controller!.resultsNotifier.addListener(_controllerListener!);

      if ((widget.searchResults ?? []).isNotEmpty) {
        widget.controller!.updateResults(widget.searchResults!);
      }
    }
  }

  @override
  void dispose() {
    if (widget.controller != null && _controllerListener != null) {
      widget.controller!.resultsNotifier.removeListener(_controllerListener!);
    }
    _focusNode.removeListener(_onFocusChange);
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() => _isSearchBarFocused = _focusNode.hasFocus);
  }

  void _onTextChanged() {
    setState(() => _hasText = _controller.text.isNotEmpty);
    widget.onChanged?.call(_controller.text);
  }

  void _handleSuffixIconTap() {
    if (widget.isDisabled) return;
    if (_hasText) {
      _controller.clear();
      widget.onChanged?.call('');
      setState(() => _hasText = false);
      widget.controller?.updateResults(widget.searchResults ?? []);
    } else {
      widget.onSearchSubmitted?.call(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool mostrarResultados = _isSearchBarFocused && _results.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(color: Colors.transparent),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Barra de búsqueda
          Container(
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
                    controller: _controller,
                    focusNode: _focusNode,
                    enabled: !widget.isDisabled,
                    autofocus: true,
                    onChanged: (value) => widget.onChanged?.call(value),
                    onSubmitted: widget.onSearchSubmitted,
                    style: TextStyle(
                      fontSize: Fontsize.body,
                      color: AppColors.semantics.text.body,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 16,
                      ),
                      isDense: true,
                    ),
                  ),
                ),
                if (_hasText)
                  GestureDetector(
                    onTap: () {
                      _controller.clear();
                      widget.onChanged?.call('');
                      widget.controller?.updateResults(
                        widget.searchResults ?? [],
                      );
                      setState(() => _hasText = false);
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
                  )
                else
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close_rounded, size: 20),
                  ),
              ],
            ),
          ),

          // Sugerencias
          if (mostrarResultados && !widget.mostrarCheckAgregado)
            LayoutBuilder(
              builder: (context, constraints) {
                final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
                final screenHeight = MediaQuery.of(context).size.height;
                final searchBarHeight = 130.0 + 16.0; // altura + margen
                final availableHeight =
                    screenHeight -
                    searchBarHeight -
                    (keyboardHeight > 0 ? keyboardHeight : 0);

                // Altura de cada ítem aprox
                const itemHeight = 74.0; // depende del diseño de tu fila
                final listHeight = (_results.length * itemHeight).clamp(
                  0,
                  availableHeight,
                );

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                    boxShadow: AppShadows.containerShadow,
                  ),
                  constraints: BoxConstraints(
                    // Si hay teclado, ocupa hasta arriba del teclado.
                    // Si no hay, hasta el borde inferior.
                    maxHeight: listHeight.toDouble(),
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _results.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final result = _results[index];
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => widget.onOptionSelected?.call(result),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.black12),
                                ),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: _buildFruitImageFull(result.foto),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          capitalizar(
                                            result.articuloDes.trim(),
                                          ),
                                          style: TextStyle(
                                            fontSize: Fontsize.h3,
                                            color:
                                                AppColors.semantics.text.body,
                                            height: 1.2,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                "#${result.articuloCod.trim()} | ${capitalizar(result.rubroDes.trim())}",
                                                style: TextStyle(
                                                  color: AppColors
                                                      .semantics
                                                      .text
                                                      .secondary,
                                                  fontSize: Fontsize.body,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: AppBadge(
                                                text: "Stock: ${result.stk}",
                                                type: AppBadgeType.warning,
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
                    },
                  ),
                );
              },
            ),

          if (mostrarResultados && widget.mostrarCheckAgregado)
            LayoutBuilder(
              builder: (context, constraints) {
                final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
                final screenHeight = MediaQuery.of(context).size.height;
                final searchBarHeight = 130.0 + 16.0;
                final availableHeight =
                    screenHeight -
                    searchBarHeight -
                    (keyboardHeight > 0 ? keyboardHeight : 0);

                const itemHeight = 80;
                final listHeight = (_results.length * itemHeight).clamp(
                  0,
                  availableHeight,
                );

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                    boxShadow: AppShadows.containerShadow,
                  ),
                  constraints: BoxConstraints(
                    // Si hay teclado, ocupa hasta arriba del teclado.
                    // Si no hay, hasta el borde inferior.
                    maxHeight: listHeight.toDouble(),
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _results.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final result = _results[index];
                      final bool yaAgregado = _agregadosInternos.any(
                        (a) => a.articuloId == result.articuloId,
                      );

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              if (yaAgregado) {
                                // eliminar
                                print("eliminado");
                                _agregadosInternos.removeWhere(
                                  (a) => a.articuloId == result.articuloId,
                                );
                                widget.onOptionSelected?.call(result);
                              } else {
                                // agregar
                                print("agregado");
                                _agregadosInternos.add(
                                  Articulo(
                                    id: result.id,
                                    articuloDes: result.articuloDes,
                                    rubroDes: result.rubroDes,
                                    articuloCod: result.articuloCod,
                                    foto: result.foto,
                                    articuloId: result.articuloId,
                                    impoconiva: result.impoconiva,
                                    hora: result.hora,
                                    stk: result.stk,
                                    rubroId: result.rubroId,
                                    cantidad: result.stk,
                                    cBarra: result.cBarra,
                                  ),
                                );
                                widget.onOptionSelected?.call(result);
                              }
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Container(
                              height: 90,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.black12),
                                ),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: _buildFruitImageFull(result.foto),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          capitalizar(
                                            result.articuloDes.trim(),
                                          ),
                                          style: TextStyle(
                                            fontSize: Fontsize.h3,
                                            color:
                                                AppColors.semantics.text.body,
                                            height: 1.2,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            "#${result.articuloCod.trim()} | ${capitalizar(result.rubroDes.trim())}",
                                            style: TextStyle(
                                              color: AppColors
                                                  .semantics
                                                  .text
                                                  .secondary,
                                              fontSize: Fontsize.body,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ),
                                        if (yaAgregado)
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.check,
                                                color: AppColors
                                                    .semantics
                                                    .text
                                                    .success,
                                                size: 20,
                                              ),
                                              Text(
                                                "Agregado",
                                                style: TextStyle(
                                                  color: AppColors
                                                      .semantics
                                                      .text
                                                      .success,
                                                  fontSize: Fontsize.body,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                              ),
                                              const SizedBox(width: 20),
                                              Text(
                                                "Toca para eliminar",
                                                style: TextStyle(
                                                  color: AppColors
                                                      .semantics
                                                      .text
                                                      .error,
                                                  fontSize: Fontsize.body,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
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
          color: const Color.fromARGB(255, 223, 223, 223),
          size: MediaQuery.sizeOf(context).width * 0.1,
        ),
      );
    } else {
      decodedBytes = base64Decode(base64Image);
      try {
        return Image.memory(
          decodedBytes,
          fit: BoxFit.cover,
          width: MediaQuery.sizeOf(context).width * 0.1,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade100,
              child: Icon(
                Icons.image_not_supported_outlined,
                color: Colors.grey.shade400,
                size: MediaQuery.sizeOf(context).width * 0.1,
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
            size: MediaQuery.sizeOf(context).width * 0.01,
          ),
        );
      }
    }
  }

  String capitalizar(String texto) {
    if (texto.isEmpty) return '';
    return texto[0].toUpperCase() + texto.substring(1).toLowerCase();
  }
}
