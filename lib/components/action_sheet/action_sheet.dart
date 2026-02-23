import 'package:vientri/constants/app_shadows.dart';
import 'package:flutter/material.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/components/heading/heading.dart';
import 'dart:ui';

class ActionSheet extends StatefulWidget {
  final String title;
  final VoidCallback? onClose;
  final Widget? content;

  const ActionSheet({
    super.key,
    required this.title,
    this.onClose,
    this.content,
  });

  static Future show(
    BuildContext context, {
    required String title,
    VoidCallback? onClose,
    Widget? content,
    Color barrierColor = const Color(0xB3C8C8C8),
    double blurSigma = 8.0,
    Duration transitionDuration = const Duration(milliseconds: 300),
  }) async {
    return showGeneralDialog(
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
                  child: ActionSheet(
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
  State<ActionSheet> createState() => _ActionSheetState();
}

class _ActionSheetState extends State<ActionSheet> {
  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;

    return SafeArea(
      child: AnimatedPadding(
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
                    child: widget.content ?? const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(height: 16.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
