import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/src/models/control.dart';

class SearchBarPopupController {
  final ValueNotifier<List<Control>> resultsNotifier =
      ValueNotifier<List<Control>>([]);

  void updateResults(List<Control> results) {
    resultsNotifier.value = results;
  }

  void dispose() {
    resultsNotifier.dispose();
  }
}

class SearchBarPopup extends StatefulWidget {
  final String hintText;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final bool isDisabled;
  final List<Control>? searchResults;
  final VoidCallback? onClose;
  final SearchBarPopupController? controller;

  final ValueChanged<Control>? onOptionSelected;

  const SearchBarPopup({
    super.key,
    required this.hintText,
    this.initialValue,
    this.onChanged,
    this.isDisabled = false,
    this.searchResults,
    this.controller,
    this.onOptionSelected,
    this.onClose
  });

static Future<void> show(
  BuildContext context, {
  required String hintText,
  String? initialValue,
  ValueChanged<String>? onChanged,
  bool isDisabled = false,
  SearchBarPopupController? controller,
  ValueChanged<Control>? onOptionSelected,
  VoidCallback? onClose,
}) async {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  void closePopup() {
    entry.remove();
    onClose?.call();
  }

  entry = OverlayEntry(
    builder: (context) => Stack(
      children: [
        // Fondo transparente que permite scroll
        Positioned.fill(
          child: ModalBarrier(
            color: Colors.transparent,
            dismissible: true,
            onDismiss: closePopup,
          ),
        ),
        // Popup con blur
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Material(
                color: Colors.white,
                child: Container(
                  height: 150,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: SearchBarPopup(
                    hintText: hintText,
                    initialValue: initialValue,
                    onChanged: onChanged,
                    controller: controller,
                    onClose: closePopup,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  overlay.insert(entry);
}

  @override
  State<SearchBarPopup> createState() => _SearchBarPopupState();
}

class _SearchBarPopupState extends State<SearchBarPopup> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  VoidCallback? _controllerListener;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.isDisabled) _focusNode.requestFocus();
    });

    // Llamar onChanged cuando el usuario escribe
    _controller.addListener(() {
      widget.onChanged?.call(_controller.text);
    });

    if (widget.controller != null) {
      _controllerListener = () {
        _controllerListener = () {
          if (!mounted) return;
          if (widget.controller!.resultsNotifier.value.isNotEmpty) {
          }
        };
      };

      // Inicializar resultados si vienen desde props
      if ((widget.searchResults ?? []).isNotEmpty) {
        widget.controller!.updateResults(widget.searchResults!);
      }
    }
  }

  @override
  void dispose() {
    if (widget.controller != null && _controllerListener != null) {
      widget.controller!.resultsNotifier.removeListener(_controllerListener!);
    }
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.semantics.border.action),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Material(
          color: Colors.transparent,
          child: TextField(
            controller: _controller,
            enabled: !widget.isDisabled,
            focusNode: _focusNode,
            textAlign: TextAlign.left,
            textAlignVertical: TextAlignVertical.center,
            style: TextStyle(
              fontSize: Fontsize.body,
              color: AppColors.semantics.text.body,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              hintText: widget.hintText,
              hintStyle: TextStyle(
                fontSize: Fontsize.body,
                color: AppColors.semantics.text.secondary,
              ),
              suffixIcon: GestureDetector(
                onTap: () {
                    widget.onClose?.call();
                },//_handleSuffixIconTap,
                child: Icon(Icons.close_rounded, size: 20.0, color: AppColors.semantics.text.body),
              ),
            ),
          ),
        ),
      ),
    );
  }

}
