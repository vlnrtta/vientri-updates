import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:flutter/material.dart';

enum AppBadgeType { warning, error, success, information, action, actionSecondary }

// ignore: must_be_immutable
class AppBadge extends StatelessWidget {
  final String text;
  final AppBadgeType type;
  bool? italic = false;

  AppBadge({
    super.key,
    required this.text,
    required this.type,
    this.italic,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (type) {
      case AppBadgeType.warning:
        backgroundColor = AppColors.semantics.surface.warning;
        textColor = AppColors.semantics.text.warning;
        break;
      case AppBadgeType.error:
        backgroundColor = AppColors.semantics.surface.error;
        textColor = AppColors.semantics.text.error;
        break;
      case AppBadgeType.success:
        backgroundColor = AppColors.semantics.surface.success;
        textColor = AppColors.semantics.text.success;
        break;
      case AppBadgeType.information:
        backgroundColor = AppColors.semantics.surface.information;
        textColor = AppColors.semantics.text.information;
        break;
      case AppBadgeType.action:
        backgroundColor = AppColors.semantics.surface.action;
        textColor = AppColors.semantics.text.onAction;
        break;
      case AppBadgeType.actionSecondary:
        backgroundColor = const Color(0xFFFFF1EA);
        textColor = const Color(0xFFDF8600);
        italic = true;
        break;
    }

    return IntrinsicWidth(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: Fontsize.bodySmall,
            fontWeight: FontWeight.w400,
            color: textColor,
            fontStyle: italic == true ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ),
    );
  }
}



/*import 'package:tanus_jalil/constants/app_colors.dart';
import 'package:tanus_jalil/constants/app_fontsize.dart';
import 'package:flutter/material.dart';

// Definición de los tipos de badge para un control estricto
enum AppBadgeType { warning, error, success, information, action }

class AppBadge extends StatelessWidget {
  final String text;
  final AppBadgeType type; // El tipo de badge (warning, error, etc.)

  const AppBadge({
    super.key,
    required this.text,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    // Determinamos el color de fondo y de texto basado en el tipo de badge
    Color backgroundColor;
    Color textColor;

    switch (type) {
      case AppBadgeType.warning:
        backgroundColor = AppColors.semantics.surface.warning;
        textColor = AppColors.semantics.text.warning;
        break;
      case AppBadgeType.error:
        backgroundColor = AppColors.semantics.surface.error;
        textColor = AppColors.semantics.text.error;
        break;
      case AppBadgeType.success:
        backgroundColor = AppColors.semantics.surface.success;
        textColor = AppColors.semantics.text.success;
        break;
      case AppBadgeType.information:
        backgroundColor = AppColors.semantics.surface.information;
        textColor = AppColors.semantics.text.information;
        break;
      case AppBadgeType.action:
        backgroundColor = AppColors.semantics.surface.action;
        textColor = AppColors.semantics.text.onAction; // Los colores de "action" suelen tener texto blanco o contrastante
        break;
    }

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), // Padding
      decoration: BoxDecoration(
        color: backgroundColor, // Color de fondo
        borderRadius: BorderRadius.circular(8.0), // Esquinas redondeadas
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: Fontsize.bodySmall, // Tamaño de fuente 'Body Small'
          fontWeight: FontWeight.w400, // Peso 400 (Regular)
          fontStyle: FontStyle.normal, // Estilo Regular
          color: textColor, // Color del texto
        ),
      ),
    );
  }
}*/