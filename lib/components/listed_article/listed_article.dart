import 'package:flutter/material.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';

class ListedArticle extends StatelessWidget {
  // Columna 1
  final int? leadingValue; // Valor numérico opcional

  // Columna 2 (Principal)
  final List<String>? mainTexts;        // Textos superiores para unir con " | "
  final List<String>? secondaryTexts;   // Textos inferiores para unir con " | "

  // Columna 3 (Derecha)
  final List<String>? trailingMainTexts; // Textos superiores para unir con " | "
  final List<String>? trailingSecondaryTexts; // Textos inferiores para unir con " | "
  final Color? trailingMainColor;      // <--- NUEVO: Color personalizable para el texto superior de Columna 3
  final Color? trailingSecondaryColor; // <--- NUEVO: Color personalizable para el texto inferior de Columna 3

  const ListedArticle({
    super.key,
    this.leadingValue,
    this.mainTexts,
    this.secondaryTexts,
    this.trailingMainTexts,
    this.trailingSecondaryTexts,
    this.trailingMainColor,      // <--- Incluir en el constructor
    this.trailingSecondaryColor, // <--- Incluir en el constructor
  });

  @override
  Widget build(BuildContext context) {

    final bool isLeadingColumnEmpty = leadingValue == null;

    final String? mainLine = mainTexts != null && mainTexts!.isNotEmpty
        ? mainTexts!.join(' | ')
        : null;
    final String? secondaryLine = secondaryTexts != null && secondaryTexts!.isNotEmpty
        ? secondaryTexts!.join(' | ')
        : null;
    final String? trailingMainLine = trailingMainTexts != null && trailingMainTexts!.isNotEmpty
        ? trailingMainTexts!.join(' | ')
        : null;
    final String? trailingSecondaryLine = trailingSecondaryTexts != null && trailingSecondaryTexts!.isNotEmpty
        ? trailingSecondaryTexts!.join(' | ')
        : null;

    return Container(
      color: Colors.transparent, // Fondo transparente
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Columna 1: Valor Numérico
          if (!isLeadingColumnEmpty) ...[
            Text(
              leadingValue!.toString(),
              style: TextStyle(
                fontSize: Fontsize.body,
                fontWeight: FontWeight.w400,
                color: AppColors.semantics.text.body,
              ),
            ),
            const SizedBox(width: 16.0),
          ],

          // Columna 2: Textos Principal y Secundario (Expandible)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (mainLine != null)
                  Text(
                    mainLine,
                    style: TextStyle(
                      fontSize: Fontsize.body,
                      fontWeight: FontWeight.w400,
                      color: AppColors.semantics.text.body,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (secondaryLine != null) ...[
                  if (mainLine != null) const SizedBox(height: 4.0),
                  Text(
                    secondaryLine,
                    style: TextStyle(
                      fontSize: Fontsize.body,
                      fontWeight: FontWeight.w400,
                      color: AppColors.semantics.text.secondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          if (trailingMainLine != null || trailingSecondaryLine != null)
            const SizedBox(width: 16.0),

          // Columna 3: Textos Trailing Principal y Secundario
          if (trailingMainLine != null || trailingSecondaryLine != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (trailingMainLine != null)
                  Text(
                    trailingMainLine,
                    style: TextStyle(
                      fontSize: Fontsize.body,
                      fontWeight: FontWeight.w400,
                      // <--- USO DEL NUEVO PARÁMETRO DE COLOR
                      color: trailingMainColor ?? AppColors.semantics.text.body,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (trailingSecondaryLine != null) ...[
                  if (trailingMainLine != null) const SizedBox(height: 4.0),
                  Text(
                    trailingSecondaryLine,
                    style: TextStyle(
                      fontSize: Fontsize.body,
                      fontWeight: FontWeight.w400,
                      // <--- USO DEL NUEVO PARÁMETRO DE COLOR
                      color: trailingSecondaryColor ?? AppColors.semantics.text.body,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}