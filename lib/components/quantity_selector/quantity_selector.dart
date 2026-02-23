// lib/components/quantity_selector/quantity_selector_component.dart
import 'package:flutter/material.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_shadows.dart';

/*class QuantitySelectorComponent extends StatefulWidget {
  final String label;
  final String? inputMessage;
  final int initialValue;
  final int minValue;
  final int maxValue;
  final int stepAmount;
  final ValueChanged<int>? onChanged; // Callback cuando el valor cambia
  final bool isDisabled; // Para el estado disabled

  const QuantitySelectorComponent({
    super.key,
    required this.label,
    this.inputMessage,
    this.initialValue = 0, // Valor por defecto
    this.minValue = 0,
    this.maxValue = 99, // Un valor máximo razonable por defecto
    this.stepAmount = 1,
    this.onChanged,
    this.isDisabled = false,
  });

  @override
  State<QuantitySelectorComponent> createState() =>
      _QuantitySelectorComponentState();
}

class _QuantitySelectorComponentState extends State<QuantitySelectorComponent> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false; // Controla el estado focused

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: widget.initialValue.toString());
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void didUpdateWidget(covariant QuantitySelectorComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si el valor inicial cambia desde fuera, actualiza el controlador
    if (widget.initialValue != int.tryParse(_controller.text)) {
      _controller.text = widget.initialValue.toString();
    }
    // Si el estado isDisabled cambia, actualizar el focus para reflejarlo
    if (oldWidget.isDisabled != widget.isDisabled) {
      if (widget.isDisabled) {
        _focusNode.unfocus();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _increment() {
    if (widget.isDisabled) return;
    int currentValue = int.tryParse(_controller.text) ?? widget.minValue;
    if (currentValue + widget.stepAmount <= widget.maxValue) {
      currentValue += widget.stepAmount;
      _controller.text = currentValue.toString();
      widget.onChanged?.call(currentValue);
    }
  }

  void _decrement() {
    if (widget.isDisabled) return;
    int currentValue = int.tryParse(_controller.text) ?? widget.minValue;
    if (currentValue - widget.stepAmount >= widget.minValue) {
      currentValue -= widget.stepAmount;
      _controller.text = currentValue.toString();
      widget.onChanged?.call(currentValue);
    }
  }

  // Método para obtener el color del texto/icono
  Color _getTextIconColor() {
    if (widget.isDisabled) {
      return AppColors.semantics.text.onDisabled;
    }
    // Si hay texto ingresado, usa text.body para default/focused. Si no, usa text.secondary para placeholder.
    if (_isFocused || _controller.text.isNotEmpty) {
      return AppColors.semantics.text.body;
    }
    return AppColors.semantics.text.secondary; // Color para placeholder en default
  }

  // Método para obtener el color del botón + y -
  Color _getButtonIconColor() {
    if (widget.isDisabled) {
      return AppColors.semantics.text.secondary;
    }
    return AppColors.semantics.text.action;
  }


  @override
  Widget build(BuildContext context) {
    // Definimos el estilo base para label y inputMessage
    final TextStyle labelInputMessageStyle = TextStyle(
      fontSize: Fontsize.bodySmall, // Asumiendo Fontsize.bodySmall es 12px
      fontWeight: FontWeight.w400,
      color: AppColors.semantics.text.body,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Label
        Text(
          widget.label,
          style: labelInputMessageStyle,
        ),
        // 2. Espacio de 8px
        const SizedBox(height: 8.0),

        // 3. Quantity Selector Core
        Container(
          width: double.infinity, // Ocupa todo el ancho posible
          decoration: BoxDecoration(
            color: widget.isDisabled
                ? AppColors.semantics.surface.disabled
                : AppColors.semantics.surface.primary,
            borderRadius: BorderRadius.circular(8.0), // Asumiendo un BorderRadius de 8px
            border: Border.all(
              color: widget.isDisabled
                  ? AppColors.semantics.border.disabled
                  : (_isFocused
                      ? AppColors.semantics.border.action
                      : Colors.transparent), // Borde transparente en default
              width: 1.0, // Ancho del borde
            ),
            boxShadow: _isFocused
                ? AppShadows.elementFocusShadow // Sombra solo en focused
                : null, // No hay sombra en default o disabled
          ),
          child: Row(
            children: [
              // Botón de decremento (-)
              GestureDetector(
                onTap: _decrement,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 8.0, 8.0, 8.0), // L:16, T:8, R:8, B:8
                  child: Icon(
                    Icons.remove,
                    size: 24.0,
                    color: _getButtonIconColor(),
                  ),
                ),
              ),

              // Área de los números (TextField)
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // Si no está deshabilitado, enfoca el TextField
                    if (!widget.isDisabled) {
                      _focusNode.requestFocus();
                    }
                  },
                  child: AbsorbPointer( // Para que el TextField no sea directamente interactuable, solo con el GestureDetector
                    absorbing: widget.isDisabled, // Absorbe punteros si está deshabilitado
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        enabled: !widget.isDisabled, // Habilitado si no está isDisabled
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        cursorColor: _isFocused ? AppColors.semantics.text.action : AppColors.semantics.text.body, // Color del cursor
                        style: TextStyle(
                          fontSize: Fontsize.body, // Asumiendo Fontsize.body es 14px
                          fontWeight: FontWeight.w400,
                          color: _getTextIconColor(),
                        ),
                        decoration: InputDecoration(
                          hintText: '0', // Placeholder predeterminado
                          hintStyle: TextStyle(
                            fontSize: Fontsize.body, // Asumiendo Fontsize.body es 14px
                            fontWeight: FontWeight.w400,
                            color: _getTextIconColor(), // Usa la misma lógica de color para el hint
                          ),
                          border: InputBorder.none, // Elimina el borde predeterminado del TextField
                          contentPadding: const EdgeInsets.symmetric(vertical: 0), // Elimina padding interno
                        ),
                        onChanged: (value) {
                          final int? parsedValue = int.tryParse(value);
                          if (parsedValue != null) {
                            if (parsedValue >= widget.minValue && parsedValue <= widget.maxValue) {
                              widget.onChanged?.call(parsedValue);
                            } else if (parsedValue < widget.minValue) {
                              _controller.text = widget.minValue.toString();
                              widget.onChanged?.call(widget.minValue);
                            } else if (parsedValue > widget.maxValue) {
                              _controller.text = widget.maxValue.toString();
                              widget.onChanged?.call(widget.maxValue);
                            }
                          } else if (value.isEmpty) {
                            // Si se borra el texto, puedes decidir qué hacer.
                            // Por ahora, no llamamos onChanged si está vacío.
                          }
                          setState(() {}); // Para forzar la actualización de color del texto
                        },
                      ),
                    ),
                  ),
                ),

              // Botón de incremento (+)
              GestureDetector(
                onTap: _increment,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 8.0, 16.0, 8.0), // L:8, T:8, R:16, B:8
                  child: Icon(
                    Icons.add,
                    size: 24.0,
                    color: _getButtonIconColor(),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 4. Espacio de 8px
        const SizedBox(height: 8.0),
        // 5. Input Message
        if (widget.inputMessage != null && widget.inputMessage!.isNotEmpty)
          Text(
            widget.inputMessage!,
            style: labelInputMessageStyle, // Mismos estilos que el label
          ),
      ],
    );
  }
}*/

class QuantitySelector extends StatefulWidget {
  final int initialValue;
  final ValueChanged<int>? onChanged;
  final int stock;

  const QuantitySelector({
    super.key,
    this.initialValue = 1,
    this.onChanged,
    required this.stock,
  });

  @override
  State<QuantitySelector> createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<QuantitySelector> {
  late int value;

  @override
  void initState() {
    super.initState();
    value = widget.initialValue;
  }

  void increment() {
    setState(() {
      value++;
    });
    widget.onChanged?.call(value);
  }

  void decrement() {
    if (value > 1) {
      setState(() {
        value--;
      });
      widget.onChanged?.call(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: AppShadows.elementFocusShadow,
        border: Border.all(color: AppColors.semantics.border.action),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.remove, color: AppColors.semantics.border.action),
            onPressed: decrement,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              value.toString(),
              style: const TextStyle(fontSize: 18),
            ),
          ),
          IconButton(
            icon: Icon(Icons.add, color: AppColors.semantics.border.action),
            onPressed: increment,
          ),
        ],
      ),
    );
  }
}