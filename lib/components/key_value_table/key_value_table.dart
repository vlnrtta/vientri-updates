import 'package:flutter/material.dart';
import 'package:vientri/constants/app_colors.dart';
// Nuevo modelo de datos para las especificaciones de estilo de un texto
class TextSpec {
  final String text;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;

  TextSpec({
    required this.text,
    this.color,
    this.fontSize,
    this.fontWeight,
  });
}

// Este es el modelo de datos para cada fila (par clave-valor)
class KeyValueItem {
  // Ahora label y value son listas de TextSpec para permitir múltiples líneas y estilos
  final List<TextSpec> label;
  final List<TextSpec> value;

  KeyValueItem({
    required this.label,
    required this.value,
  });
}

class KeyValueTable extends StatelessWidget {
  final List<KeyValueItem> items;

  const KeyValueTable({
    super.key,
    required this.items,
  });

  // Widget auxiliar para construir texto (simple o doble) con estilos detallados
  Widget _buildTextWidget(List<TextSpec> textSpecs, {required TextAlign textAlign, required Color defaultColor, required double defaultFontSize, required FontWeight defaultFontWeight}) {
    // Si la lista de especificaciones tiene un solo elemento, simplemente retornamos un Text
    if (textSpecs.length == 1) {
      final spec = textSpecs.first;
      return Text(
        spec.text,
        textAlign: textAlign,
        style: TextStyle(
          color: spec.color ?? defaultColor,
          fontSize: spec.fontSize ?? defaultFontSize,
          fontWeight: spec.fontWeight ?? defaultFontWeight,
        ),
      );
    }
    
    // Si hay múltiples elementos, retornamos una Column
    return Column(
      crossAxisAlignment: textAlign == TextAlign.left ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: textSpecs.map((spec) => Text(
        spec.text,
        textAlign: textAlign,
        style: TextStyle(
          color: spec.color ?? defaultColor,
          fontSize: spec.fontSize ?? defaultFontSize,
          fontWeight: spec.fontWeight ?? defaultFontWeight,
        ),
      )).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double baseFontSize = 14.0;
    const FontWeight baseFontWeight = FontWeight.w400;

    List<Widget> rowWidgets = [];
    for (int i = 0; i < items.length; i++) {
      final item = items[i];

      // Determina el color predeterminado. El isBold ya no es un parámetro de la fila,
      // sino que se controla a nivel de cada TextSpec
      final Color defaultLabelColor = AppColors.semantics.text.body;
      final Color defaultValueColor = AppColors.semantics.text.body;

      rowWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center, // Alineamos al inicio para doble texto
            children: [
              Expanded(
                child: _buildTextWidget(
                  item.label,
                  textAlign: TextAlign.left,
                  defaultColor: defaultLabelColor,
                  defaultFontSize: baseFontSize,
                  defaultFontWeight: baseFontWeight,
                ),
              ),
              _buildTextWidget(
                item.value,
                textAlign: TextAlign.right,
                defaultColor: defaultValueColor,
                defaultFontSize: baseFontSize,
                defaultFontWeight: baseFontWeight,
              ),
            ],
          ),
        ),
      );

      if (i < items.length - 1) {
        rowWidgets.add(const SizedBox(height: 12.0));
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: rowWidgets,
    );
  }
}