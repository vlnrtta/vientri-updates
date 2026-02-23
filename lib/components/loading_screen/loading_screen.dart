// lib/components/loading_screen/loading_screen_component.dart
import 'package:flutter/material.dart';
import 'package:vientri/constants/app_colors.dart'; // Tus colores
import 'package:vientri/constants/app_fontsize.dart'; // Tu clase Fontsize

class LoadingScreenComponent extends StatelessWidget {
  final IconData icon; // El ícono a mostrar
  final String text; // El texto (nombre de la app/módulo)

  const LoadingScreenComponent({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold( // Usa Scaffold para ocupar toda la pantalla y manejar el fondo
      backgroundColor: AppColors.semantics.surface.action, // Color de fondo surface/action
      body: Center( // Centra todo el contenido vertical y horizontalmente
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centra verticalmente los elementos de la columna
          mainAxisSize: MainAxisSize.min, // La columna ocupa el mínimo espacio vertical posible
          children: [
            Icon(
              icon, // Ícono pasado por parámetro
              size: 105.0, // Tamaño 105x105 px
              color: AppColors.gray.white, // Color gray.white
            ),
            const SizedBox(height: 18.0), // Separación de 18px
            Text(
              text, // Texto pasado por parámetro
              style: TextStyle(
                fontSize: Fontsize.h1, // H1 (24px)
                fontWeight: FontWeight.w700, // Weight 700 (Bold)
                color: AppColors.gray.white, // Color gray.white
              ),
              textAlign: TextAlign.center, // Centra el texto si es multilinea
            ),
          ],
        ),
      ),
    );
  }
}