// lib/components/text_input/text_input_component.dart

import 'package:flutter/material.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/constants/app_shadows.dart';

class TextInputComponent extends StatefulWidget {
  final String? labelText;
  final String hintText;
  final String?
  inputMessage; // Volvemos a inputMessage para el mensaje general (error o ayuda)
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final bool enabled;
  final bool
  hasError; // <-- Controla si el input está en estado de error (borde rojo, icono X)
  final Widget? suffixIcon;
  final VoidCallback? onTapSuffixIcon;
  final Function(String)? onChanged;
  final bool
  isValidState; // <-- ¡NUEVO! true si el input está en un estado válido (borde verde)

  const TextInputComponent({
    super.key,
    this.labelText,
    required this.hintText,
    this.inputMessage, // Puede ser mensaje de error o mensaje de ayuda/info
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    this.hasError = false,
    this.suffixIcon,
    this.onTapSuffixIcon,
    this.onChanged,
    this.isValidState = false, // Por defecto no está en estado válido (verde)
  });

  @override
  State<TextInputComponent> createState() => _TextInputComponentState();
}

class _TextInputComponentState extends State<TextInputComponent> {
  final FocusNode _focusNode = FocusNode();
  late final TextEditingController _internalController;

  @override
  void initState() {
    super.initState();
    _internalController = widget.controller ?? TextEditingController();
    _focusNode.addListener(_onFocusChange);
    // Ya no es necesario un listener interno para setState si el onChanged ya lo notifica
    // _internalController.addListener(_onTextChanged); // Removido para evitar doble llamada o confusión
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    // _internalController.removeListener(_onTextChanged); // Removido
    if (widget.controller == null) {
      _internalController.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      // Reconstruir para aplicar los estilos de foco
    });
  }

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Color fillColor;
    Color hintTextColor;
    Color inputTextColor;
    Color labelMessageColor;
    List<BoxShadow>? boxShadow;
    Color effectiveInputMessageColor;

    if (!widget.enabled) {
      borderColor = AppColors.semantics.border.disabled;
      fillColor = AppColors.semantics.surface.disabled;
      inputTextColor = AppColors.semantics.text.onDisabled;
      hintTextColor = AppColors.semantics.text.onDisabled;
      labelMessageColor = AppColors.semantics.text.onDisabled;
      effectiveInputMessageColor = AppColors.semantics.text.onDisabled;
      boxShadow = null;
    } else if (widget.hasError) {
      // Si hay un error explícito
      borderColor = AppColors.semantics.border.error;
      fillColor = AppColors.semantics.surface.primary;
      inputTextColor = AppColors.semantics.text.body;
      hintTextColor = AppColors.semantics.text.secondary;
      labelMessageColor = AppColors.semantics.text.error;
      effectiveInputMessageColor = AppColors.semantics.text.error;
      boxShadow = null;
    } else if (widget.isValidState) {
      // ¡NUEVO ESTADO!: Borde verde (solo si no hay error explícito)
      borderColor = AppColors.semantics.border.success;
      fillColor = AppColors.semantics.surface.primary;
      inputTextColor = AppColors.semantics.text.body;
      hintTextColor = AppColors.semantics.text.secondary;
      labelMessageColor = AppColors.semantics.text.body; // Label normal
      effectiveInputMessageColor =
          AppColors.semantics.text.secondary; // Mensaje normal
      boxShadow = null;
    } else if (_focusNode.hasFocus) {
      borderColor = AppColors.semantics.border.action;
      fillColor = AppColors.semantics.surface.primary;
      inputTextColor = AppColors.semantics.text.body;
      hintTextColor = AppColors.semantics.text.secondary;
      labelMessageColor = AppColors.semantics.text.body;
      effectiveInputMessageColor = AppColors.semantics.text.secondary;
      boxShadow = AppShadows.elementFocusShadow;
    } else {
      borderColor = AppColors.semantics.border.primary;
      fillColor = AppColors.semantics.surface.primary;
      inputTextColor = AppColors.semantics.text.body;
      hintTextColor = AppColors.semantics.text.secondary;
      labelMessageColor = AppColors.semantics.text.secondary;
      effectiveInputMessageColor = AppColors.semantics.text.secondary;
      boxShadow = null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // --- LABEL ---
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: TextStyle(
              fontSize: Fontsize.bodySmall,
              fontWeight: FontWeight.w400,
              color: labelMessageColor,
            ),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 8.0),
        ],

        // --- TEXT FIELD CONTAINER ---
        Container(
          constraints: const BoxConstraints(maxWidth: 348.0),
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: borderColor, width: 1.0),
            boxShadow: boxShadow,
          ),
          

          child: TextField(
            controller: _internalController,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            enabled: widget.enabled,
            focusNode: _focusNode,
            textAlign: TextAlign.left,
            textAlignVertical: TextAlignVertical.center,
            style: TextStyle(
              fontSize: Fontsize.body,
              fontWeight: FontWeight.w400,
              color: inputTextColor,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.fromLTRB(16.0, 13.0, 16.0, 13.0),
              hintText: widget.hintText,
              hintStyle: TextStyle(
                fontSize: Fontsize.body,
                fontWeight: FontWeight.w400,
                color: hintTextColor,
              ),
              border: InputBorder.none,
              suffixIcon: widget.suffixIcon != null
                  ? GestureDetector(
                      onTap: widget.onTapSuffixIcon,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: widget.suffixIcon,
                      ),
                    )
                  : null,
              suffixIconConstraints: BoxConstraints.tightFor(
                width: widget.suffixIcon != null ? 40.0 : 0.0,
                height: 24.0,
              ),
            ),
            onChanged: (value) {
              setState(
                () {},
              ); // Forzar reconstrucción para actualizar el borde/color en caso de error/foco
              if (widget.onChanged != null) {
                widget.onChanged!(value);
              }
            },
          ),
        ),

        // --- INPUT MESSAGE (Error o ayuda general) ---
        if (widget.inputMessage != null) ...[
          const SizedBox(height: 8.0),
          Row(
            children: [
              if (widget.hasError) // Muestra el icono solo si hay error
                Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Icon(
                    Icons.close, // Icono de 'X'
                    color: AppColors.semantics.text.error,
                    size: 20.0,
                  ),
                ),
              Flexible(
                child: Text(
                  widget.inputMessage!,
                  style: TextStyle(
                    fontSize: Fontsize.bodySmall,
                    fontWeight: FontWeight.w400,
                    color: effectiveInputMessageColor,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
