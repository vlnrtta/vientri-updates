import 'package:vientri/constants/app_colors.dart';
import 'package:flutter/material.dart';


class AppHeading extends StatelessWidget {
  final String label;
  final double fontSize;
  final TextAlign textAlign;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final VoidCallback? onLeadingIconPressed;
  final VoidCallback? onTrailingIconPressed;
  final Color? textColor;
  final double? iconSize;

  const AppHeading({
    super.key,
    required this.label,
    required this.fontSize,
    this.textAlign = TextAlign.start,
    this.leadingIcon,
    this.trailingIcon,
    this.onLeadingIconPressed,
    this.onTrailingIconPressed,
    this.textColor,
    this.iconSize
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveTextColor = textColor ?? AppColors.semantics.text.heading;

    // Constante para el tamaño de los IconButtons
    double iconButtonSize = iconSize ?? 24;
    // Padding predeterminado de IconButton, lo reducimos para controlar el tamaño visual
    const EdgeInsetsGeometry iconButtonPadding = EdgeInsets.all(0); // Elimina el padding por defecto

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icono Izquierdo (Opcional como IconButton)
        if (leadingIcon != null) ...[
          SizedBox( // Usamos SizedBox para controlar el tamaño exacto del área del botón
            width: iconButtonSize,
            height: iconButtonSize,
            child: IconButton(
              padding: iconButtonPadding, // Quitamos el padding interno de IconButton
              iconSize: iconButtonSize, // Aseguramos el tamaño del icono
              icon: Icon(
                leadingIcon,
                color: effectiveTextColor,
              ),
              onPressed: onLeadingIconPressed, // Pasamos la función
              // Deshabilitar el botón si no se proporciona onPressed
              // (Si onLeadingIconPressed es null, IconButton se deshabilitará automáticamente)
            ),
          ),
          const SizedBox(width: 8.0), // Gap de 8px
        ],

        // Texto del Heading
        Expanded(
          child: Text(
            label,
            textAlign: textAlign,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: effectiveTextColor,
            ),
          ),
        ),

        // Icono Derecho (Opcional como IconButton)
        if (trailingIcon != null) ...[
          const SizedBox(width: 8.0), // Un pequeño gap también para el icono derecho
          SizedBox( // Usamos SizedBox para controlar el tamaño exacto del área del botón
            width: iconButtonSize,
            height: iconButtonSize,
            child: IconButton(
              padding: iconButtonPadding, // Quitamos el padding interno de IconButton
              iconSize: iconButtonSize, // Aseguramos el tamaño del icono
              icon: Icon(
                trailingIcon,
                color: effectiveTextColor,
              ),
              onPressed: onTrailingIconPressed, // Pasamos la función
              // Deshabilitar el botón si no se proporciona onPressed
            ),
          ),
        ],
      ],
    );
  }
}