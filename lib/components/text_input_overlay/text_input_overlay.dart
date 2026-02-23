import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/constants/app_shadows.dart';

class TextInputOverlay extends StatefulWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool isDisabled;
  final String? initialText; // ← texto predeterminado opcional

  const TextInputOverlay({
    super.key,
    required this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.isDisabled = false,
    this.initialText, // ← agregado
  });

  static Future show(
    BuildContext context, {
    required String hintText,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    bool isDisabled = false,
    String? initialText, // ← agregado
    VoidCallback? onClose,
    Color barrierColor = const Color(0xB3C8C8C8),
    double blurSigma = 8.0,
  }) async {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Stack(
          children: [
            FadeTransition(
              opacity: animation,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
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
                begin: const Offset(0.0, -1.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: Align(
                alignment: Alignment.topCenter,
                child: Material(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 80, left: 16, right: 16),
                    child: TextInputOverlay(
                      hintText: hintText,
                      onChanged: onChanged,
                      onSubmitted: onSubmitted,
                      isDisabled: isDisabled,
                      initialText: initialText, // ← agregado
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  State<TextInputOverlay> createState() => _TextInputOverlayState();
}

class _TextInputOverlayState extends State<TextInputOverlay> {
  late FocusNode _focusNode;
  late TextEditingController _controller; // ← controlador para texto inicial
  bool _isSearchBarFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _controller = TextEditingController(text: widget.initialText ?? '');
    _focusNode.addListener(_onFocusChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.isDisabled) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() => _isSearchBarFocused = _focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    final Color contentBackgroundColor = AppColors.semantics.surface.glassFill;
    final List<BoxShadow>? mainContainerShadow =
        _isSearchBarFocused && !widget.isDisabled
            ? AppShadows.containerShadow
            : null;

    final textFieldBorderColor = _isSearchBarFocused
        ? AppColors.semantics.border.action
        : AppColors.semantics.border.primary;

    return Container(
      decoration: BoxDecoration(
        color: contentBackgroundColor,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: mainContainerShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.semantics.surface.primary,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: textFieldBorderColor, width: 1.0),
            ),
            child: TextField(
              controller: _controller,
              enabled: !widget.isDisabled,
              focusNode: _focusNode,
              style: TextStyle(
                fontSize: Fontsize.body,
                color: AppColors.semantics.text.body,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.fromLTRB(16.0, 13.0, 16.0, 13.0),
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  fontSize: Fontsize.body,
                  color: AppColors.semantics.text.secondary,
                ),
                border: InputBorder.none,
              ),
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
            ),
          ),
        ],
      ),
    );
  }
}
