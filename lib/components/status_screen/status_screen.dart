// lib/components/status_screen/status_screen.dart
import 'package:flutter/material.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/components/solid_button/solid_button.dart'; // Tu SolidButton
import 'package:vientri/components/subtle_button/subtle_button.dart'; // Asumo que tienes un SubtleButton

// 1. Nuevo enum para el tipo de botón
enum StatusScreenButtonType {
  solid,
  subtle,
}

class StatusScreen extends StatelessWidget {
  final IconData icon;
  final String primaryText;
  final String secondaryText;
  final Color? iconColor;
  final Color? primaryTextColor;
  final Color? secondaryTextColor;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final StatusScreenButtonType?
      buttonType; // <--- NUEVA PROPIEDAD: Tipo de botón

  const StatusScreen({
    super.key,
    required this.icon,
    required this.primaryText,
    required this.secondaryText,
    this.iconColor,
    this.primaryTextColor,
    this.secondaryTextColor,
    this.buttonText,
    this.onButtonPressed,
    this.buttonType = StatusScreenButtonType.solid, // <--- Valor por defecto
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.semantics.surface.page,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0), // Padding general para el contenido
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icono
                        Icon(
                          icon,
                          size: 48.0,
                          color: iconColor ?? AppColors.semantics.text.secondary,
                        ),

                        // Espacio en blanco entre Icono y Texto Principal
                        const SizedBox(height: 36.0),

                        // Texto Principal (H1, Bold, Centrado)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 42.0),
                          child: Text(
                            primaryText,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: Fontsize.h1,
                              fontWeight: FontWeight.w700,
                              color: primaryTextColor ??
                                  AppColors.semantics.text.heading,
                            ),
                          ),
                        ),

                        // Espacio en blanco entre Texto Principal y Texto Secundario
                        const SizedBox(height: 24.0),

                        // Texto Secundario (Body, Regular, Centrado)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 42.0),
                          child: Text(
                            secondaryText,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: Fontsize.body,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              color: secondaryTextColor ??
                                  AppColors.semantics.text.body,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Botón de acción (solo si se proporciona)
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 24.0), // Espacio entre el contenido principal y el botón
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0), // Padding lateral para el botón
                child: SizedBox(
                  width: double.infinity, // El botón ocupará todo el ancho disponible
                  // 3. Lógica condicional para el tipo de botón
                  child: buttonType == StatusScreenButtonType.solid
                      ? SolidButton(
                          text: buttonText!,
                          onPressed: onButtonPressed!,
                        )
                      : SubtleButton( // <--- Se asume que tienes un SubtleButton
                          text: buttonText!,
                          onPressed: onButtonPressed!,
                        ),
                ),
              ),
              const SizedBox(height: 24.0), // Espacio inferior desde el borde de la pantalla
            ],
          ],
        ),
      ),
    );
  }
}