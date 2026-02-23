import 'package:flutter/material.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/components/badge/badge.dart';

// --- Definición de los Tipos de Contenido para ListedElement ---
// Estos son los "parametros" que pasaremos a cada columna

// Clase base para el contenido de una columna
abstract class ListedElementColumnContent {}

// Contenido de Texto Simple
class ListedElementTextContent implements ListedElementColumnContent {
  final String text;
  final TextAlign? textAlign;
  final Color? textColor;
  final FontWeight? fontWeight;
  final double? fontSize;

  ListedElementTextContent({
    required this.text,
    this.textAlign,
    this.textColor,
    this.fontWeight,
    this.fontSize,
  });
}

// Contenido de Texto Doble
class ListedElementDoubleTextContent implements ListedElementColumnContent {
  final String topText;
  final String bottomText;
  final TextAlign? textAlign;
  final Color? topTextColor;
  final Color? bottomTextColor;
  final FontWeight? topFontWeight;
  final FontWeight? bottomFontWeight;
  final double? topFontSize;
  final double? bottomFontSize;

  ListedElementDoubleTextContent({
    required this.topText,
    required this.bottomText,
    this.textAlign,
    this.topTextColor,
    this.bottomTextColor,
    this.topFontWeight,
    this.bottomFontWeight,
    this.topFontSize,
    this.bottomFontSize,
  });
}

// Contenido de Icono de Botón
class ListedElementIconButtonContent implements ListedElementColumnContent {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? iconColor;

  ListedElementIconButtonContent({
    required this.icon,
    this.onPressed,
    this.iconColor,
  });
}

// Contenido de Badge
class ListedElementBadgeContent implements ListedElementColumnContent {
  final String text;
  final AppBadgeType type;

  ListedElementBadgeContent({
    required this.text,
    required this.type,
  });
}


class ListedElement extends StatelessWidget {
  final ListedElementColumnContent? column1Content;
  final int flex1;
  final ListedElementColumnContent? column2Content;
  final int flex2;
  final ListedElementColumnContent? column3Content;
  final int flex3;

  const ListedElement({
    super.key,
    this.column1Content,
    this.flex1 = 1,
    this.column2Content,
    this.flex2 = 1,
    this.column3Content,
    this.flex3 = 1,
  });

  // Método auxiliar para construir el widget de contenido real
  Widget? _buildContentWidget(ListedElementColumnContent? content) {
    if (content == null) {
      return null;
    } else if (content is ListedElementTextContent) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 21.0),
        child: Text(
          content.text,
          textAlign: content.textAlign,
          style: TextStyle(
            color: content.textColor ?? AppColors.semantics.text.body,
            fontSize: content.fontSize ?? Fontsize.body,
            fontWeight: content.fontWeight ?? FontWeight.normal,
          ),
        ),
      );
    } else if (content is ListedElementDoubleTextContent) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: _getCrossAxisAlignment(content.textAlign),
          children: [
            Text(
              content.topText,
              textAlign: content.textAlign,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: content.topTextColor ?? AppColors.semantics.text.body,
                fontSize: content.topFontSize ?? Fontsize.body,
                fontWeight: content.topFontWeight ?? FontWeight.normal,
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              content.bottomText,
              textAlign: content.textAlign,
              style: TextStyle(
                color: content.bottomTextColor ?? AppColors.semantics.text.secondary,
                fontSize: content.bottomFontSize ?? Fontsize.bodySmall,
                fontWeight: content.bottomFontWeight ?? FontWeight.normal,
              ),
            ),
          ],
        ),
      );
    } else if (content is ListedElementIconButtonContent) {
      const double iconSize = 24.0;
      return SizedBox(
        width: iconSize,
        height: iconSize,
        child: IconButton(
          padding: EdgeInsets.zero,
          iconSize: iconSize,
          icon: Icon(
            content.icon,
            color: content.iconColor ?? AppColors.semantics.text.action,
          ),
          onPressed: content.onPressed,
        ),
      );
    } else if (content is ListedElementBadgeContent) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 18.0),
        child: AppBadge(text: content.text, type: content.type),
      );
    }
    return null;
  }

  // Ayudante para alinear el texto de la columna (duplicado pero necesario aquí)
  CrossAxisAlignment _getCrossAxisAlignment(TextAlign? align) {
    switch (align) {
      case TextAlign.left:
        return CrossAxisAlignment.start;
      case TextAlign.right:
        return CrossAxisAlignment.end;
      case TextAlign.center:
        return CrossAxisAlignment.center;
      default:
        return CrossAxisAlignment.start;
    }
  }

@override
Widget build(BuildContext context) {
  final Widget? builtColumn1Content = _buildContentWidget(column1Content);
  final Widget? builtColumn2Content = _buildContentWidget(column2Content);
  final Widget? builtColumn3Content = _buildContentWidget(column3Content);

  return Container(
    decoration: BoxDecoration(
      color: AppColors.semantics.surface.primary,
      border: Border(
        bottom: BorderSide(
          color: AppColors.semantics.border.primary,
          width: 1.0,
        ),
      ),
    ),
    child: IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: builtColumn1Content ?? const SizedBox(),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: builtColumn2Content ?? const SizedBox(),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: builtColumn3Content ?? const SizedBox(),
                  ),
                ),
              ],
            ),
          ),
        ],
      )
    ),
  );
}

}