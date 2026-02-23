// ignore_for_file: prefer_const_declarations

import 'package:flutter/material.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/constants/app_shadows.dart';

// El componente principal de la barra de navegación
class NavBar extends StatefulWidget {
  final List<String> items; // Lista de textos para los ítems de la barra
  final int initialSelectedIndex; // Índice del ítem seleccionado inicialmente
  final ValueChanged<int>? onItemSelected; // Callback cuando se selecciona un ítem

  const NavBar({
    super.key,
    required this.items,
    this.initialSelectedIndex = 0,
    this.onItemSelected,
  }) : assert(initialSelectedIndex >= 0 && initialSelectedIndex < items.length,
            'initialSelectedIndex must be a valid index within the items list');

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  late int _selectedIndex; // Estado interno para el ítem seleccionado
  final GlobalKey _rowKey = GlobalKey(); // Key para obtener el tamaño y posición de la fila de ítems
  final Map<int, GlobalKey> _itemKeys = {}; // Keys para cada ítem individual
  double _indicatorX = 0.0; // Posición X del indicador deslizante
  double _indicatorWidth = 0.0; // Ancho del indicador deslizante

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialSelectedIndex;
    // Inicializar las keys para cada ítem
    for (int i = 0; i < widget.items.length; i++) {
      _itemKeys[i] = GlobalKey();
    }

    // Usar addPostFrameCallback para calcular las posiciones después de que el widget se haya renderizado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateIndicatorPosition(initial: true);
    });
  }

  @override
  void didUpdateWidget(covariant NavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si la lista de ítems cambia, reinicializar las keys y recalcular posiciones
    if (widget.items.length != oldWidget.items.length) {
      _itemKeys.clear();
      for (int i = 0; i < widget.items.length; i++) {
        _itemKeys[i] = GlobalKey();
      }
      // Recalcular la posición después del siguiente frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateIndicatorPosition(initial: true);
      });
    }
    // Si el initialSelectedIndex cambió desde fuera, actualizamos y animamos
    if (widget.initialSelectedIndex != oldWidget.initialSelectedIndex && widget.initialSelectedIndex != _selectedIndex) {
      setState(() {
        _selectedIndex = widget.initialSelectedIndex;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateIndicatorPosition();
      });
    }
  }


  void _updateIndicatorPosition({bool initial = false}) {
    if (_itemKeys[_selectedIndex]?.currentContext != null) {
      final RenderBox itemRenderBox = _itemKeys[_selectedIndex]!.currentContext!.findRenderObject() as RenderBox;
      final RenderBox rowRenderBox = _rowKey.currentContext!.findRenderObject() as RenderBox;

      // Calcular la posición del ítem relativa a la fila (Row)
      final Offset itemPosition = itemRenderBox.localToGlobal(Offset.zero, ancestor: rowRenderBox);

      setState(() {
        _indicatorX = itemPosition.dx; // Posición X
        _indicatorWidth = itemRenderBox.size.width; // Ancho del ítem
      });
    }
  }

  void _handleItemTap(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
      // Recalcular la posición del indicador después de actualizar el índice
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateIndicatorPosition();
      });
      widget.onItemSelected?.call(index); // Llama al callback externo
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculamos la altura del indicador de forma dinámica basada en el padding y el tamaño de fuente 'body'
    // Padding vertical: 5.0 + 5.0 = 10.0
    // Altura de fuente body: _fontSize.body
    final double indicatorHeight = 10.0 + Fontsize.body;

    return Container(
      color: Colors.transparent, // Fondo transparente para la NavBar principal
      child: Stack( // Usamos Stack para superponer la barra deslizante
        alignment: Alignment.centerLeft, // Alineamos a la izquierda para control de posicionamiento
        children: [
          // 1. El indicador deslizante (AnimatedPositioned)
          AnimatedPositioned(
            duration: Duration(milliseconds: 200), // <--- VELOCIDAD AJUSTADA (antes 300)
            curve: Curves.easeInOut,
            left: _indicatorX,
            width: _indicatorWidth,
            height: indicatorHeight, // Altura calculada dinámicamente
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.semantics.surface.page,
                borderRadius: BorderRadius.circular(8.0), // <--- BORDER RADIUS AÑADIDO
                boxShadow: AppShadows.buttonShadow,
              ),
            ),
          ),
          // 2. La fila de ítems de texto (encima del indicador)
          Builder(
            key: _rowKey,
            builder: (BuildContext context) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(widget.items.length, (index) {
                  final bool isSelected = _selectedIndex == index;
                  return Padding(
                    key: _itemKeys[index],
                    padding: EdgeInsets.symmetric(horizontal: 4.0),
                    child: _NavItemContent(
                      text: widget.items[index],
                      isSelected: isSelected,
                      onTap: () => _handleItemTap(index),
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Sub-componente para el CONTENIDO de cada ítem (solo el texto y su estilo)
class _NavItemContent extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItemContent({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    Color textColor = isSelected ? AppColors.semantics.text.body : AppColors.semantics.text.secondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: Fontsize.body,
            fontWeight: FontWeight.w400,
            color: textColor,
          ),
        ),
      ),
    );
  }
}