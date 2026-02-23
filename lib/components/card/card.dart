// lib/components/card_component.dart
import 'package:flutter/material.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_shadows.dart';

class CardComponent extends StatelessWidget {
  final List<Widget> children; // La lista de componentes que contendrá la Card

  const CardComponent({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0), // Padding de 16px en todas las direcciones
      decoration: BoxDecoration(
        color: AppColors.semantics.surface.primary, // Color de fondo surface/primary
        borderRadius: BorderRadius.circular(8.0), // Border radius de 8px
        boxShadow: AppShadows.containerShadow, // La nueva sombra
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // La columna ocupa solo el espacio de sus hijos
        children: List.generate(children.length, (index) {
          return Column( // Usamos una columna para cada hijo con un SizedBox condicional
            children: [
              children[index], // El hijo actual (ej. ListedArticle)
              if (index < children.length - 1) // Agrega gap si no es el último elemento
                const SizedBox(height: 24.0), // Gap de 16px entre los componentes internos
            ],
          );
        }),
      ),
    );
  }
}