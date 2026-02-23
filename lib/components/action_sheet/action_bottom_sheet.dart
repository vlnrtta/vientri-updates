import 'package:vientri/constants/app_shadows.dart';
import 'package:flutter/material.dart';
import 'package:vientri/constants/app_colors.dart';
import 'dart:ui';

class ActionBottomSheet extends StatefulWidget {
  final Widget title;        // ahora es Widget
  final VoidCallback? onClose;
  final Widget? content;

  const ActionBottomSheet({
    super.key,
    required this.title,
    this.onClose,
    this.content,
  });

  /// Método para mostrar el BottomSheet
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget title,
    required Widget content,
    VoidCallback? onClose,
    Color barrierColor = const Color(0xB3C8C8C8),
    double blurSigma = 8.0,
    Duration transitionDuration = const Duration(milliseconds: 300),
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.transparent,
      transitionDuration: transitionDuration,
      pageBuilder: (BuildContext buildContext, Animation<double> animation, Animation<double> secondaryAnimation) {
        return Stack(
          children: [
            FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(buildContext).pop();
                  onClose?.call();
                },
                behavior: HitTestBehavior.opaque,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                  child: Container(color: barrierColor),
                ),
              ),
            ),
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
                  child: ActionBottomSheet(
                    title: title,
                    onClose: () {
                      Navigator.of(buildContext).pop();
                      onClose?.call();
                    },
                    content: content,
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
  State<ActionBottomSheet> createState() => _ActionBottomSheetState();
}

class _ActionBottomSheetState extends State<ActionBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 0),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 16,
            maxHeight: MediaQuery.of(context).size.height * 0.9,
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: widget.title), // ahora recibe cualquier widget
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: widget.onClose,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),
              Flexible(
                child: SingleChildScrollView(
                  child: widget.content ?? const SizedBox.shrink(),
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
