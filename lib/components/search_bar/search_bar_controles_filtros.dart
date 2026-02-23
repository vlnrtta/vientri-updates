// ignore_for_file: unused_element

import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vientri/components/solid_button/solid_button.dart';
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
  final List<Articulo>? searchResults;
  final List<Articulo>? articulosAgregados;
  final List<Articulo> sugerencias;


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
    this.onOptionSelected,
    required this.articulosAgregados,
    required this.sugerencias,

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
    ValueChanged<Articulo>? onOptionSelected,
    List<Articulo>? articulosAgregados,
    VoidCallback? onClose,
    Color barrierColor = const Color(0xB3C8C8C8),
    double blurSigma = 8.0,
    required List<Articulo> sugerencias,
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
                  filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                  child: Container(color: barrierColor),
                ),
              ),
            ),
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, -1.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: Align(
                alignment: Alignment.topCenter,
                child: Material(
                  color: Colors.transparent,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                      child: SearchBarPopup(
                        hintText: hintText,
                        initialValue: initialValue,
                        onChanged: onChanged,
                        onSearchSubmitted: onSearchSubmitted,
                        isDisabled: isDisabled,
                        searchResults: searchResults,
                        controller: controller,
                        onOptionSelected: onOptionSelected,
                        articulosAgregados: articulosAgregados,
                        sugerencias: sugerencias,
                      ),
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
  late List<Articulo> _agregadosInternos;
  bool mostrarResultados = false;
  bool mostrarRubros = false;
  String selectedFilter = 'Buscar artículo';
  bool checkedSinStk = false;
  bool checkedNoVig = false;
  bool checked = false;
  bool mostrarFiltro = true;

  List<Articulo> _results = [];
  VoidCallback? _controllerListener;

  late Map<String, List<Articulo>> rubrosMap = {};
  late List<String> listaRubros = [];
  Map<String, bool> expandido = {};

  Map<String, bool> rubroChecked = {};

  List<String> rubrosFiltrados = [];


  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();
    _controller.addListener(_onTextChanged);
    _hasText = _controller.text.isNotEmpty;
    _agregadosInternos = [...widget.articulosAgregados!];
    _results = widget.sugerencias;


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

    // Agrupa por rubro
    rubrosMap = {};
    for (var art in widget.sugerencias) {
      final rubro = art.rubroDes.trim();
      rubrosMap.putIfAbsent(rubro, () => []);
      rubrosMap[rubro]!.add(art);
    }

    // Lista ordenada de rubros
    listaRubros = rubrosMap.keys.toList()..sort();

    // Estado expandido/cerrado por cada rubro
    for (var r in listaRubros) {
      expandido[r] = false;
    }
    
    for (var r in listaRubros) {
      rubroChecked[r] = false;
    }

    inicializarRubrosChecked();

    rubrosFiltrados = List.from(listaRubros);
  }

  @override
  void dispose() {
    if (widget.controller != null && _controllerListener != null) {
      widget.controller!.resultsNotifier.removeListener(_controllerListener!);
    }
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final txt = _controller.text.toLowerCase().trim();

    setState(() {
      _hasText = txt.isNotEmpty;

      if (txt.isEmpty) {
        _results = widget.sugerencias;
        rubrosFiltrados = List.from(listaRubros);
        mostrarFiltro = true;
        return;
      }

      setState(() {
        mostrarFiltro = false;
      });

      if (selectedFilter == "Buscar artículo") {
        _results = widget.sugerencias.where((a) =>
          a.articuloDes.toLowerCase().contains(txt)
        ).toList();        
      } else {
        _results = widget.sugerencias.where((a) =>
          a.rubroDes.toLowerCase().contains(txt.toLowerCase())
        ).toList();

        if (txt.isEmpty) {
          rubrosFiltrados = List.from(listaRubros);
        } else {
          rubrosFiltrados = listaRubros.where((rubro) {
            final coincideTexto = rubro.toLowerCase().contains(txt);
            return coincideTexto;
          }).toList();
        }
      }

      if (checkedSinStk) {
          _results = _results.where((a) => a.stk <= 0).toList();
      }

      if (checkedNoVig) {
        _results = _results.where((a) => a.stk == 123456789).toList();
      }
    });

    setState(() {
      if (selectedFilter == "Buscar artículo") {
        mostrarResultados = false;
        mostrarRubros = false;
      } else if (selectedFilter == "Buscar rubro") {
        mostrarResultados = false;
        mostrarRubros = true;
      }
    });
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

  bool rubroCompleto(String rubro) {
    final articulos = rubrosMap[rubro] ?? [];
    return articulos.every(
      (art) => _agregadosInternos.any((a) => a.articuloId == art.articuloId),
    );
  }

  void inicializarRubrosChecked() {
    for (var rubro in listaRubros) {
      rubroChecked[rubro] = rubroCompleto(rubro);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
              padding: EdgeInsets.only(
                left: 8,
                right: 8,
                bottom: 16
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        GestureDetector(
                            onTap: () => Navigator.pop(context, true),
                            child: Icon(Icons.arrow_back, size: 20, color: AppColors.semantics.text.body),
                          ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            enabled: !widget.isDisabled,
                            autofocus: true,
                            onChanged: (value) {
                              setState(() {
                                if (value == "" && selectedFilter == "Buscar artículo") {
                                  mostrarResultados = false;
                                  mostrarRubros = false;
                                } else if (selectedFilter == "Buscar rubro") {
                                  mostrarResultados = false;
                                  mostrarRubros = true;
                                } else if (value != "" && selectedFilter == "Buscar artículo") {
                                  mostrarResultados = true;
                                  mostrarRubros = false;
                                }
                              });
                              widget.onChanged?.call(value);
                            },
                            onSubmitted: widget.onSearchSubmitted,
                            style: TextStyle(
                              fontSize: Fontsize.body,
                              color: AppColors.semantics.text.body,
                            ),
                            decoration: InputDecoration(
                              hintText: "Buscar",
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
                              FocusScope.of(context).unfocus();
                              _controller.clear();
                              widget.onChanged?.call('');
                              widget.controller?.updateResults(widget.searchResults ?? []);
                              setState(() { _hasText = false; mostrarResultados = false;});
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
                        Icon(Icons.search_rounded, size: 20, color: Colors.black38),
                      ],
                    ),
                  ),
                    
                  if (mostrarFiltro)
                  _filtros(),
                    
                  if (mostrarResultados)
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return NotificationListener<ScrollNotification>(
                          onNotification: (scroll) {
                            FocusScope.of(context).unfocus();
                            return false;
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              //border: Border.all(color: Colors.black12),
                              //borderRadius: const BorderRadius.all(Radius.circular(10)),
                            ),
                            child: ListView.builder(
                              padding: EdgeInsets.only(bottom: 60),
                              physics: const ClampingScrollPhysics(),
                              itemCount: _results.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                final result = _results[index];
                                
                                final bool yaAgregado = _agregadosInternos.any(
                                  (a) => a.articuloId == result.articuloId,
                                );
                            
                                return _cajaArticulo(_results[index], yaAgregado, index == _results.length - 1, index == 0);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  if (mostrarRubros)
                  Expanded(
                    child: Stack(
                      children: [
                        SafeArea(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return NotificationListener<ScrollNotification>(
                                onNotification: (scroll) {
                                  FocusScope.of(context).unfocus();
                                  return false;
                                },
                                child: Container(
                                  margin: EdgeInsets.only(top: 8),
                                  child: ListView.builder(
                                    padding: EdgeInsets.only(bottom: 70),
                                    physics: const ClampingScrollPhysics(),
                                    itemCount: rubrosFiltrados.length,
                                    itemBuilder: (context, index) {
                                      final rubro = rubrosFiltrados[index];
                                      final articulos = rubrosMap[rubro]!;
                                          
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                FocusScope.of(context).unfocus();
                                                expandido[rubro] = !(expandido[rubro] ?? false);
                                              });
                                            },
                                            child: Container(
                                              height: 50,
                                              margin: const EdgeInsets.only(top: 8),
                                              padding: const EdgeInsets.symmetric(horizontal: 16),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: expandido[rubro] == true ? BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)) : BorderRadius.all(Radius.circular(12)),
                                                border: expandido[rubro] == true ? null : Border(bottom: BorderSide(color: Colors.black12)),
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  SizedBox(
                                                    width: MediaQuery.sizeOf(context).width * 0.6,
                                                    child: Text(
                                                      capitalizar(rubro.trim()),
                                                      style: TextStyle(
                                                        color: AppColors.semantics.text.body,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: Fontsize.h3,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                          
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        expandido[rubro] == true
                                                        ? CupertinoIcons.chevron_up
                                                        : CupertinoIcons.chevron_down,
                                                      ),
                                                      const SizedBox(width: 16),
                                          
                                                      /// CHECK DEL RUBRO
                                                      InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            FocusScope.of(context).unfocus();
                                                            // Cambiar el estado del rubro
                                                            final nuevoValor = !(rubroChecked[rubro] ?? false);
                                                            rubroChecked[rubro] = nuevoValor;
                                          
                                                            // Lista de artículos del rubro actual
                                                            final articulos = rubrosMap[rubro] ?? [];
                                          
                                                            if (nuevoValor) {
                                                              // 👉 SELECCIONAR TODOS LOS ARTÍCULOS DEL RUBRO
                                                              for (var art in articulos) {
                                                                final yaAgregado = _agregadosInternos.any(
                                                                  (a) => a.articuloId == art.articuloId,
                                                                );
                                          
                                                                if (!yaAgregado) {
                                                                  // lo agrego internamente
                                                                  _agregadosInternos.add(art);
                                          
                                                                  // lo notifico al padre para que lo agregue a _articulosSeleccionados
                                                                  widget.onOptionSelected?.call(art);
                                                                }
                                                              }
                                          
                                                            } else {
                                                              // 👉 DESELECCIONAR TODOS LOS ARTÍCULOS DEL RUBRO
                                                              for (var art in articulos) {
                                                                _agregadosInternos.removeWhere(
                                                                  (p) => p.articuloId == art.articuloId,
                                                                );
                                          
                                                                // También avisar al padre para que lo saque
                                                                widget.onOptionSelected?.call(art);
                                                              }
                                                            }
                                                          });
                                                        },
                                                        child: AnimatedContainer(
                                                          duration: const Duration(milliseconds: 200),
                                                          width: 20,
                                                          height: 20,
                                                          decoration: BoxDecoration(
                                                            color: (rubroChecked[rubro] ?? false)
                                                                ? AppColors.semantics.surface.action
                                                                : Colors.white,
                                                            borderRadius: BorderRadius.circular(8),
                                                            border: Border.all(
                                                              color: (rubroChecked[rubro] ?? false)
                                                                  ? AppColors.semantics.surface.action
                                                                  : Colors.black12,
                                                              width: 1,
                                                            ),
                                                          ),
                                                          child: (rubroChecked[rubro] ?? false)
                                                              ? const Icon(
                                                                  Icons.check,
                                                                  color: Colors.white,
                                                                  size: Fontsize.body,
                                                                )
                                                              : null,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          
                                          if (expandido[rubro] == true)
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
                                                color: Colors.white,
                                              ),
                                              child: Column(
                                                children: articulos.map((articulo) {
                                                  final yaAgregado = _agregadosInternos.any(
                                                    (a) => a.articuloId == articulo.articuloId,
                                                  );
                                                  return _cajaArticulo(articulo, yaAgregado, false, false);
                                                }).toList(),
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  )
                                          
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: SafeArea(
                top: false,
                child: SolidButton(
                  text: "Listo",
                  type: SolidButtonType.primary,
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filtros() {
    mostrarResultados = false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Wrap(
            spacing: 8,
            children: ["Buscar artículo", "Buscar rubro"].map((filtro) {
              final selected = filtro == selectedFilter;
              return Theme(
                data: Theme.of(context).copyWith(
                  chipTheme: Theme.of(context).chipTheme.copyWith(
                    side: BorderSide.none,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: ChoiceChip(
                    label: Text(
                      filtro,
                      style: TextStyle(
                        color: selected ? Colors.white : AppColors.semantics.text.body,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    selected: selected,
                    onSelected: (_) {
                      setState(() {
                        selectedFilter = filtro;                        
                        _onTextChanged(); // vuelve a filtrar según el nuevo filtro
                        if (filtro == "Buscar por rubro") {
                          mostrarRubros = true;
                        }
                      });
                    },
                    selectedColor: AppColors.semantics.surface.action,
                    backgroundColor: AppColors.semantics.surface.disabled,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide.none,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  ),
                ),
              );
            }).toList(),
          ),
        ),     

        InkWell(
          onTap: () {
            setState(() {
              FocusScope.of(context).unfocus();
              checkedSinStk = !checkedSinStk;
              _onTextChanged(); // vuelve a filtrar según el nuevo filtro
            });              
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: checkedSinStk ? AppColors.semantics.surface.action : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: checkedSinStk ? AppColors.semantics.surface.action : Colors.black12,
                    width: 1,
                  ),
                ),
                child: checkedSinStk
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: Fontsize.body,
                    )
                  : null,
              ),
              const SizedBox(width: 8),
              Text(
                "Artículos sin stock o negativos",
                style: TextStyle(
                  color: AppColors.semantics.text.body,
                  fontSize: Fontsize.body,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        InkWell(
          onTap: () {
            setState(() {
              FocusScope.of(context).unfocus();
              checkedNoVig = !checkedNoVig;
            });              
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: checkedNoVig ? AppColors.semantics.surface.action : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: checkedNoVig ? AppColors.semantics.surface.action : Colors.black12,
                    width: 1,
                  ),
                ),
                child: checkedNoVig
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: Fontsize.body,
                    )
                  : null,
              ),
              const SizedBox(width: 8),
              Text(
                "Artículos no vigentes",
                style: TextStyle(
                  color: AppColors.semantics.text.body,
                  fontSize: Fontsize.body,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
  
  Widget _buildFruitImageFull(String base64Image) {
    final Uint8List decodedBytes;
    if (base64Image == "") {
      return Container(
        decoration: BoxDecoration(
          border: BoxBorder.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(12)
        ),
        child: Icon(
          Icons.image_not_supported_rounded,
          color: const Color.fromARGB(255, 223, 223, 223),
          size: MediaQuery.sizeOf(context).width * 0.1,
        ),
      );
    } else {
      decodedBytes = base64Decode(base64Image);
      try {
        return Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            border: BoxBorder.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(12)
          ),
          width: MediaQuery.sizeOf(context).width * 0.12,
          child: Image.memory(
            decodedBytes,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: BoxBorder.all(color: Colors.black12)
                ),
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: Colors.grey.shade400,
                  size: MediaQuery.sizeOf(context).width * 0.1,
                ),
              );
            },
          ),
        );
      } catch (e) {
        return Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: BoxBorder.all(color: Colors.black12)
          ),
          child: Icon(
            Icons.image_not_supported_outlined,
            color: Colors.grey.shade400,
            size: MediaQuery.sizeOf(context).width * 0.12,
          ),
        );
      }
    }
  }

  String capitalizar(String texto) {
    if (texto.isEmpty) return '';
    return texto[0].toUpperCase() + texto.substring(1).toLowerCase();
  }

  Widget _cajaArticulo(Articulo result, bool yaAgregado, bool ultimo, bool primero) {
    return Material(
      borderRadius: BorderRadius.only(
        bottomLeft: ultimo ? Radius.circular(10) : Radius.circular(0),
        bottomRight: ultimo ? Radius.circular(10) : Radius.circular(0),
        topLeft: primero ? Radius.circular(10) : Radius.circular(0),
        topRight: primero ? Radius.circular(10) : Radius.circular(0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.only(
          bottomLeft: ultimo ? Radius.circular(10) : Radius.circular(0),
          bottomRight: ultimo ? Radius.circular(10) : Radius.circular(0),
          topLeft: primero ? Radius.circular(10) : Radius.circular(0),
          topRight: primero ? Radius.circular(10) : Radius.circular(0),
        ),
        onTap: () {
          setState(() {
            FocusScope.of(context).unfocus();
            if (yaAgregado) {
                _agregadosInternos.removeWhere(
                (a) => a.articuloId == result.articuloId,
              );
              widget.onOptionSelected?.call(result);
            } else {
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
            inicializarRubrosChecked();
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
              height: 90,
              constraints: const BoxConstraints(
                minHeight: 90,
                maxHeight: 120,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black12)),
              ),
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildFruitImageFull(result.foto),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        capitalizar(result.articuloDes.trim()),
                        style: TextStyle(
                          fontSize: Fontsize.h3,
                          color: AppColors.semantics.text.body,
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
                            color: AppColors.semantics.text.secondary,
                            fontSize: Fontsize.body,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      if (yaAgregado)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.check, color: AppColors.semantics.text.success, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                "Agregado",
                                style: TextStyle(
                                  color: AppColors.semantics.text.success,
                                  fontSize: Fontsize.body,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ],
                          ),
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.3,
                            child: Text(
                              "Toca para eliminar",
                              style: TextStyle(
                                color: AppColors.semantics.text.error,
                                fontSize: Fontsize.body,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
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

}