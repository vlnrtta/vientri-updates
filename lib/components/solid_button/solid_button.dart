// ignore_for_file: must_be_immutable
import 'package:vientri/constants/app_shadows.dart';
import 'package:flutter/material.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart'; // Importa tu archivo Fontsize

enum SolidButtonType { primary, secondary }
enum SolidButtonWidth { full, wrap } // full = ocupa todo el espacio, wrap = ajusta al contenido

class SolidButton extends StatefulWidget {
  final String text;
  bool? isLoading;
  final IconData? leftIcon;
  final SolidButtonType type;
  final SolidButtonWidth width;
  final VoidCallback? onPressed; // Nullable para deshabilitar el botón

  SolidButton({ // Removido 'const' porque el estado interno no puede ser constante por Fontsize
    super.key,
    required this.text,
    this.isLoading = false,
    this.leftIcon,
    this.type = SolidButtonType.primary, // Por defecto Primary
    this.width = SolidButtonWidth.full, // Por defecto Full Width
    this.onPressed, // Si es null, el botón estará deshabilitado
  });

  @override
  State<SolidButton> createState() => _SolidButtonState();
}

class _SolidButtonState extends State<SolidButton> {
  bool _isPressed = false; // Estado para el efecto de presionado

  // Método para obtener el color de fondo según el estado y tipo
  Color _getBackgroundColor(bool isPressed, bool isDisabled) {
    if (isDisabled) {
      return AppColors.semantics.surface.disabled;
    }
    if (isPressed) {
      return widget.type == SolidButtonType.primary
          ? AppColors.semantics.surface.actionPressed
          : AppColors.semantics.surface.secondaryActionPressed;
    }
    return widget.type == SolidButtonType.primary
        ? AppColors.semantics.surface.action
        : AppColors.semantics.surface.secondaryAction;
  }

  Color _getTextIconColor(bool isDisabled) {
    if (isDisabled) {
      return AppColors.semantics.text.onDisabled;
    }
    return widget.type == SolidButtonType.primary
        ? AppColors.semantics.text.onAction
        : AppColors.semantics.text.action; // Usamos .action para secundario en default/pressed
  }

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = widget.onPressed == null;
    widget.isLoading == null ? widget.isLoading = false : null;
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
        width: widget.width == SolidButtonWidth.full ? double.infinity : null,
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: _getBackgroundColor(_isPressed, isDisabled),
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: AppShadows.buttonShadow,
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.leftIcon != null)
                Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Icon(
                    widget.leftIcon,
                    size: 20.0,
                    color: _getTextIconColor(isDisabled),
                  ),
                ),
              if (widget.isLoading!)
              CircularProgressIndicator(color: Colors.white, strokeWidth: 3, constraints: BoxConstraints(maxHeight: 23, minHeight: 23, maxWidth: 23, minWidth: 23)),
              if (!widget.isLoading!)
              Text(
                widget.text,
                style: TextStyle(
                  fontSize: Fontsize.h3,
                  fontWeight: FontWeight.bold,
                  color: _getTextIconColor(isDisabled),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}