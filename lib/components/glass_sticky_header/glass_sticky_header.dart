import 'package:flutter/material.dart';
import 'dart:ui'; // Necesario para ImageFilter y BackdropFilter

import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';

class GlassyStickyHeader extends StatelessWidget implements PreferredSizeWidget {
  // Parámetros para el contenido del encabezado
  final String title;
  final IconData? leftIcon; // Opcional, como el icono de flecha hacia atrás
  final VoidCallback? onLeftIconPressed;
  final IconData? rightIcon; // Opcional, como el icono de menú o más opciones
  final VoidCallback? onRightIconPressed;
  final double height; // Altura fija del encabezado

  // Parámetros para el efecto Glass
  final double blurSigmaX;
  final double blurSigmaY;
  final Color backgroundColor;

  const GlassyStickyHeader({
    super.key,
    required this.title,
    this.leftIcon,
    this.onLeftIconPressed,
    this.rightIcon,
    this.onRightIconPressed,
    this.height = 56.0, // Altura estándar de un AppBar, puedes ajustarla
    this.blurSigmaX = 5.0, // Grado de desenfoque horizontal
    this.blurSigmaY = 5.0, // Grado de desenfoque vertical
    // Color de fondo semitransparente por defecto
    this.backgroundColor = const Color(0x66FFFFFF), // Blanco con 40% de opacidad
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect( // ClipRRect para asegurar que el desenfoque no se salga de los bordes
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigmaX, sigmaY: blurSigmaY),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor, // Fondo semitransparente
            border: Border(
              bottom: BorderSide(
                color: AppColors.gray.c300, // Un borde sutil en la parte inferior del glass
                width: 0.5,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0), // Padding interno
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icono Izquierdo y Título
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (leftIcon != null)
                      IconButton(
                        icon: Icon(leftIcon, color: AppColors.gray.c900),
                        onPressed: onLeftIconPressed,
                      ),
                    Flexible(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: Fontsize.h3, // Título como h3
                          fontWeight: FontWeight.bold,
                          color: AppColors.gray.c900,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                // Icono Derecho
                if (rightIcon != null)
                  IconButton(
                    icon: Icon(rightIcon, color: AppColors.gray.c900),
                    onPressed: onRightIconPressed,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}