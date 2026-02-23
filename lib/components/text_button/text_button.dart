// lib/components/text_button_component.dart
import 'package:flutter/material.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_shadows.dart';

class TextButtonComponent extends StatefulWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed; // Nullable para el estado disabled

  const TextButtonComponent({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
  });

  @override
  State<TextButtonComponent> createState() => _TextButtonComponentState();
}

class _TextButtonComponentState extends State<TextButtonComponent> {
  bool _isPressedInternal = false;

  static const double _buttonMinHeight = 40.0;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = widget.onPressed == null;

    Color textColor;
    Color iconColor;
    Color? backgroundColor;
    List<BoxShadow>? boxShadow;
    BorderRadiusGeometry? borderRadius;

    if (isDisabled) {
      textColor = AppColors.semantics.text.onDisabled;
      iconColor = AppColors.semantics.text.onDisabled;
      backgroundColor = Colors.transparent;
      boxShadow = null;
      borderRadius = null;
    } else if (_isPressedInternal) {
      textColor = AppColors.semantics.text.actionPressed;
      iconColor = AppColors.semantics.text.actionPressed;
      backgroundColor = AppColors.semantics.surface.secondaryActionPressed;
      boxShadow = AppShadows.textButtonPressedShadow;
      borderRadius = BorderRadius.circular(8.0);
    } else {
      textColor = AppColors.semantics.text.action;
      iconColor = AppColors.semantics.text.action;
      backgroundColor = Colors.transparent;
      boxShadow = null;
      borderRadius = null;
    }

    return InkWell(
      onTap: isDisabled ? null : widget.onPressed,
      onTapDown: (_) {
        if (!isDisabled) {
          setState(() {
            _isPressedInternal = true;
          });
        }
      },
      onTapUp: (_) {
        if (!isDisabled) {
          setState(() {
            _isPressedInternal = false;
          });
        }
      },
      onTapCancel: () {
        if (!isDisabled) {
          setState(() {
            _isPressedInternal = false;
          });
        }
      },
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      
      borderRadius: BorderRadius.circular(8.0),
      child: IntrinsicWidth(
        // <--- ¡NUEVA ADICIÓN AQUÍ!
        child: Center(
          child: AnimatedContainer(
            duration: Duration(milliseconds: 150),
            curve: Curves.easeInOut,
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: borderRadius,
              boxShadow: boxShadow,
            ),
            constraints: BoxConstraints(minHeight: _buttonMinHeight),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize:
                  MainAxisSize.min, // Sigue siendo importante para el Row interno
              children: [
                if (widget.icon != null) ...[ // <--- ¡CAMBIO CLAVE AQUÍ!
                Icon(widget.icon, size: 24.0, color: iconColor),
                SizedBox(width: 6.0),
              ],
                Text(
                  widget.text,
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
