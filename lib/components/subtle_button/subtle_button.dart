import 'package:flutter/material.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart'; // Importa tu archivo Fontsize
import 'package:vientri/constants/app_shadows.dart'; // Importa tu archivo de sombras

// Enum para los tipos (categorías) del SubtleButton
enum SubtleButtonType {
  brand,
  information, 
  error,
  success,
  warning,
}

// Enum para el ancho del botón (igual que SolidButton)
enum SubtleButtonWidth { full, wrap }

class SubtleButton extends StatefulWidget {
  final String text;
  final IconData? leftIcon;
  final SubtleButtonType type;
  final SubtleButtonWidth width;
  final VoidCallback? onPressed; // Nullable para deshabilitar el botón

  const SubtleButton({ // Removido 'const' por las mismas razones que SolidButton
    super.key,
    required this.text,
    this.leftIcon,
    this.type = SubtleButtonType.brand, // Por defecto 'brand'
    this.width = SubtleButtonWidth.full, // Por defecto Full Width
    this.onPressed, // Si es null, el botón estará deshabilitado
  });

  @override
  State<SubtleButton> createState() => _SubtleButtonState();
}

class _SubtleButtonState extends State<SubtleButton> {
  bool _isPressed = false; // Estado para el efecto de presionado

  // Método para obtener el color de fondo según el estado y tipo
  Color _getBackgroundColor(bool isPressed, bool isDisabled) {
    // Si está deshabilitado o no está presionado, el fondo es transparente
    if (isDisabled || !isPressed) {
      return Colors.transparent;
    }

    // Si está presionado y habilitado, usa el color de superficie correspondiente
    switch (widget.type) {
      case SubtleButtonType.brand:
        return AppColors.semantics.surface.secondaryActionPressed;
      case SubtleButtonType.information:
        return AppColors.semantics.surface.information;
      case SubtleButtonType.error:
        return AppColors.semantics.surface.error;
      case SubtleButtonType.success:
        return AppColors.semantics.surface.success;
      case SubtleButtonType.warning:
        return AppColors.semantics.surface.warning;
    }
  }

  // Método para obtener el color del texto/icono según el estado y tipo
  Color _getTextIconColor(bool isPressed, bool isDisabled) {
    if (isDisabled) {
      return AppColors.semantics.text.onDisabled;
    }

    // Si está presionado o en default (habilitado), usa el color de texto correspondiente
    switch (widget.type) {
      case SubtleButtonType.brand:
        return AppColors.semantics.text.action; // Tanto para default como pressed
      case SubtleButtonType.information:
        return AppColors.semantics.text.information;
      case SubtleButtonType.error:
        return AppColors.semantics.text.error;
      case SubtleButtonType.success:
        return AppColors.semantics.text.success;
      case SubtleButtonType.warning:
        return AppColors.semantics.text.warning;
    }
  }

  List<BoxShadow>? _getBoxShadow(bool isPressed, bool isDisabled) {
    if (isDisabled || !isPressed) {
      return null; // No hay sombra si está deshabilitado o no presionado
    }
    // Si está presionado y habilitado, aplica la sombra de presionado
    return AppShadows.buttonShadow; // O la sombra específica que quieras para el estado presionado
  }

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = widget.onPressed == null;

    return GestureDetector(
      onTapDown: (_) {
        if (!isDisabled) {
          setState(() {
            _isPressed = true;
          });
        }
      },
      onTapUp: (_) {
        if (!isDisabled) {
          setState(() {
            _isPressed = false;
          });
        }
      },
      onTapCancel: () {
        if (!isDisabled) {
          setState(() {
            _isPressed = false;
          });
        }
      },
      onTap: isDisabled ? null : widget.onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: _getBackgroundColor(_isPressed, isDisabled),
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: _getBoxShadow(_isPressed, isDisabled)// La sombra está presente en todos los estados
        ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.leftIcon != null)
                Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Icon(
                    widget.leftIcon,
                    size: 20.0,
                    color: _getTextIconColor(_isPressed, isDisabled),
                  ),
                ),
              Text(
                widget.text,
                style: TextStyle(
                  fontSize: Fontsize.h3, // H3 que es 16px
                  fontWeight: FontWeight.bold, // Weight 700
                  color: _getTextIconColor(_isPressed, isDisabled),
                ),
              ),
            ],
          ),
        ),
    );
  }
}