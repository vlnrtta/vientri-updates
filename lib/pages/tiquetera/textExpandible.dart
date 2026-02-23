import 'package:flutter/material.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';

class TextoExpandable extends StatefulWidget {
  final String texto;
  final int maxLines;
  final TextAlign aligment;
  final CrossAxisAlignment crossAxisAlignment;
  final TextStyle? style;

  const TextoExpandable({
    super.key,
    required this.texto,
    required this.aligment,
    required this.crossAxisAlignment,
    this.maxLines = 3,
    this.style,
  });

  @override
  State<TextoExpandable> createState() => _TextoExpandableState();
}

class _TextoExpandableState extends State<TextoExpandable> {
  bool _expandido = false;
  bool _mostrarBoton = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(text: widget.texto, style: widget.style),
          maxLines: widget.maxLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        _mostrarBoton = textPainter.didExceedMaxLines;

        return Column(
          crossAxisAlignment: widget.crossAxisAlignment,
          children: [
            Text(
              widget.texto,
              style: widget.style,
              maxLines: _expandido ? null : widget.maxLines,
              overflow: _expandido ? TextOverflow.visible : TextOverflow.ellipsis,
              textAlign: widget.aligment,
            ),
            if (_mostrarBoton)
            TextButton(
              onPressed: () {
                setState(() {
                  _expandido = !_expandido;
                });
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                _expandido ? "Leer menos" : "Leer más",
                style: TextStyle(
                  color: AppColors.semantics.surface.actionPressed,
                  fontSize: Fontsize.body,
                  fontWeight: FontWeight.w600,

                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
