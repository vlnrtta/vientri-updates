import 'package:flutter/material.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';

class MenuItem extends StatelessWidget {
  // --- Parámetros para el Lado Izquierdo ---
  final IconData? leftIcon;
  final Color? leftIconColor;
  final String leftText;
  final double leftTextSize;
  final Color? leftTextColor;
  final FontWeight leftTextWeight;
  final FontStyle leftTextStyle;

  // --- Parámetros para el Lado Derecho (todos opcionales) ---
  final IconData? rightIcon;
  final Color? rightIconColor;
  final String? rightText; // Opcional
  final double rightTextSize;
  final Color? rightTextColor;
  final FontWeight rightTextWeight;
  final FontStyle rightTextStyle;

  // --- Parámetros de Comportamiento ---
  final VoidCallback? onTap;

  const MenuItem({
    super.key,
    // Lado Izquierdo: al menos un texto es requerido
    this.leftIcon,
    this.leftIconColor,
    required this.leftText, // Texto izquierdo es mandatorio
    this.leftTextSize = Fontsize.body, // Default size
    this.leftTextColor, // Default color
    this.leftTextWeight = FontWeight.normal, // Default weight
    this.leftTextStyle = FontStyle.normal, // Default style

    // Lado Derecho: todos opcionales
    this.rightIcon,
    this.rightIconColor,
    this.rightText,
    this.rightTextSize = Fontsize.body, // Default size
    this.rightTextColor, // Default color
    this.rightTextWeight = FontWeight.normal, // Default weight
    this.rightTextStyle = FontStyle.normal, // Default style

    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell( // Usamos InkWell para el efecto de toque y para onTap
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.gray.c300, // Usamos un gris como default si no hay semantics.border.primary
              width: 1.0,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // --- Contenido del Lado Izquierdo ---
            Row(
              mainAxisSize: MainAxisSize.min, // Para que el Row ocupe el mínimo espacio posible
              children: [
                if (leftIcon != null) // Si hay icono izquierdo, lo mostramos
                  Padding(
                    padding: const EdgeInsets.only(right: 4.0), // Separación de 4px
                    child: Icon(
                      leftIcon,
                      color: leftIconColor ?? AppColors.gray.c700, // Color default para icono
                      size: 20.0, // Tamaño fijo
                    ),
                  ),
                Flexible( // Usamos Flexible para que el texto se adapte y no haga overflow
                  child: Text(
                    leftText,
                    style: TextStyle(
                      fontSize: leftTextSize,
                      color: leftTextColor,
                      fontWeight: leftTextWeight,
                      fontStyle: leftTextStyle,
                    ),
                    overflow: TextOverflow.ellipsis, // Para manejar texto largo
                  ),
                ),
              ],
            ),

            // --- Contenido del Lado Derecho ---
            Row(
              mainAxisSize: MainAxisSize.min, // Para que el Row ocupe el mínimo espacio posible
              children: [
                if (rightText != null) // Si hay texto derecho, lo mostramos
                  Padding(
                    padding: EdgeInsets.only(right: rightIcon != null ? 4.0 : 0.0), // 4px de separación si hay icono
                    child: Flexible( // Flexible para el texto derecho también
                      child: Text(
                        rightText!,
                        style: TextStyle(
                          fontSize: rightTextSize,
                          color: rightTextColor,
                          fontWeight: rightTextWeight,
                          fontStyle: rightTextStyle,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                if (rightIcon != null) // Si hay icono derecho, lo mostramos
                  Icon(
                    rightIcon,
                    color: rightIconColor ?? AppColors.gray.c700, // Color default para icono
                    size: 20.0, // Tamaño fijo
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}