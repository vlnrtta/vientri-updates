// lib/components/action_sheet_options/action_sheet_options.dart

import 'package:vientri/constants/app_shadows.dart';
import 'package:flutter/material.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/components/heading/heading.dart';
import 'package:vientri/components/menu_item/menu_item.dart';
import 'dart:ui';

import 'package:vientri/src/models/opcion.dart'; // IMPORTE NECESARIO PARA ImageFilter

class ActionSheetOptions extends StatefulWidget {
  final String title;
  final List<Opcion> options;
  final Opcion? initialSelectedOption;
  final Function(Opcion selectedOption) onOptionSelected;
  final VoidCallback? onClose;
  final Color? optionsTextColor;
  final Color? selectedOptionCheckColor;

  const ActionSheetOptions({
    super.key,
    required this.title,
    required this.options,
    this.initialSelectedOption,
    required this.onOptionSelected,
    this.onClose,
    this.optionsTextColor,
    this.selectedOptionCheckColor,
  });


  // Método estático para mostrar el modal con animaciones separadas
  static Future show(
    BuildContext context, {
    required String title,
    required List<Opcion> options,
    Opcion? initialSelectedOption,
    required Function(Opcion selectedOption) onOptionSelected,
    VoidCallback? onClose,
    Color? optionsTextColor,
    Color? selectedOptionCheckColor,
    
    // Parámetros de color y blur para el fondo del Bottom Sheet
    Color barrierColor = const Color(0xB3C8C8C8), // #C8C8C8 con 70% de opacidad
    double blurSigma = 8.0, // Blur de 8px según Figma
    Duration transitionDuration = const Duration(milliseconds: 300), // Duración de la animación
  }) async {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true, // DEBE ESTAR EN TRUE PARA QUE SE CIERRE AL TOCAR FUERA
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.transparent, // <-- Mantenemos transparente aquí porque el color lo aplicamos con un Container animado
      transitionDuration: transitionDuration,
      pageBuilder: (BuildContext buildContext, Animation<double> animation, Animation<double> secondaryAnimation) {
        return Stack(
          children: [
            // El BackdropFilter y el Container de color como fondo, animado para aparecer
            // Este es el elemento que se "clickea" para cerrar si barrierDismissible es true
            FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
              child: GestureDetector( // <-- Agregamos un GestureDetector a la barrera
                onTap: () {
                  Navigator.of(buildContext).pop(); // Cierra el modal al tocar fuera
                  onClose?.call(); // Llama a tu callback onClose
                },
                behavior: HitTestBehavior.opaque, // Hace que toda el área sea "hittable"
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                  child: Container(
                    color: barrierColor, // Aplicamos tu color #C8C8C8 con 70% de opacidad
                  ),
                ),
              ),
            ),
            // Contenido del modal (ActionSheetOptions), animado para deslizarse desde abajo
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Material(
                  color: Colors.transparent,
                  child: ActionSheetOptions(
                    title: title,
                    options: options,
                    initialSelectedOption: initialSelectedOption,
                    onOptionSelected: (selected) {
                      Navigator.of(buildContext).pop();
                      onOptionSelected(selected);
                    },
                    onClose: () {
                      Navigator.of(buildContext).pop();
                      onClose?.call();
                    },
                    optionsTextColor: optionsTextColor,
                    selectedOptionCheckColor: selectedOptionCheckColor,
                  ),
                ),
              ),
            ),
          ],
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
    );
  }

  @override
  State<ActionSheetOptions> createState() => _ActionSheetOptionsState();
}

class _ActionSheetOptionsState extends State<ActionSheetOptions> {
  Opcion? _currentSelectedOption;

  @override
  void initState() {
    super.initState();
    _currentSelectedOption = widget.initialSelectedOption;
  }

  String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
  
  @override
  Widget build(BuildContext context) {
    final Color effectiveOptionsTextColor = widget.optionsTextColor ?? AppColors.semantics.text.body;
    final Color effectiveCheckColor = widget.selectedOptionCheckColor ?? AppColors.semantics.text.body;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 16,
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          decoration: BoxDecoration(
            color: AppColors.semantics.surface.primary,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: AppShadows.elementFocusShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16.0),
      
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: AppHeading(
                  label: widget.title,
                  fontSize: Fontsize.h3,
                  textColor: AppColors.semantics.text.heading,
                  textAlign: TextAlign.start,
                  trailingIcon: Icons.close,
                  onTrailingIconPressed: widget.onClose,
                ),
              ),
      
              const SizedBox(height: 24.0),
      
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: widget.options.map((option) {
                      final isSelected = _currentSelectedOption == option;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: MenuItem(
                          leftText: option.nombre,
                          leftTextColor: effectiveOptionsTextColor,
                          leftTextSize: Fontsize.body,
                          onTap: () {
                            setState(() {
                              _currentSelectedOption = option;
                            });
                            widget.onOptionSelected(option);
                          },
                          rightIcon: isSelected ? Icons.check : null,
                          rightIconColor: effectiveCheckColor,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
      
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}