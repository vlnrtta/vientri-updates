import 'package:flutter/material.dart';
import 'package:vientri/constants/app_colors.dart';

class PasswordFieldComponent extends StatefulWidget {
  final String leftLabel;
  final TextEditingController? controller;
  final String? inputMessage;
  final bool
  hasError; // Se mantiene para el inputMessage, pero no para el borde del TextField.
  final bool isValidState; // Se mantiene solo para el color del borde inferior.
  final Function(String)? onChanged;
  final bool enabled;

  const PasswordFieldComponent({
    super.key,
    required this.leftLabel,
    this.controller,
    this.inputMessage,
    this.hasError = false,
    this.isValidState = false,
    this.onChanged,
    this.enabled = true,
  });

  @override
  State<PasswordFieldComponent> createState() => _PasswordFieldComponentState();
}

class _PasswordFieldComponentState extends State<PasswordFieldComponent> {
  late final TextEditingController _internalController;
  // FocusNode ya no es necesario si quitamos la dinámica de foco del borde.
  // final FocusNode _focusNode = FocusNode();
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _internalController = widget.controller ?? TextEditingController();
    // _focusNode.addListener(_onFocusChange); // Eliminar listener de foco
  }

  @override
  void dispose() {
    // _focusNode.removeListener(_onFocusChange); // Eliminar listener de foco
    if (widget.controller == null) {
      _internalController.dispose();
    }
    // _focusNode.dispose(); // Eliminar dispose de FocusNode
    super.dispose();
  }

  // void _onFocusChange() { // Eliminar este método
  //   setState(() {});
  // }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color borderColor;

    // Lógica del color del borde: solo si isValidState es true, es success, sino, primary.
    if (widget.isValidState && _internalController.text.isNotEmpty) {
      borderColor = AppColors.semantics.border.success;
    } else {
      borderColor = AppColors.semantics.border.primary;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 32),
          decoration: BoxDecoration(
            color: Colors.transparent, // Color de fondo del campo
            // Sin boxShadow
            border: Border(
              bottom: BorderSide(
                color: borderColor, // Borde siempre presente, cambia de color.
                width: 1.0,
              ),
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 0.0),
                  child: Text(
                    widget.leftLabel,
                    style: TextStyle(
                      fontSize:
                          14.0, // Hardcodeado según tu especificación anterior
                      fontWeight: FontWeight.w600,
                      color: AppColors.semantics.text.body,
                    ),
                  ),
                ),
                const SizedBox(width: 0.0),
                Expanded(
                  child: TextField(
                    textAlign: TextAlign.right,
                    controller: _internalController,
                    obscureText: _obscureText,
                    enabled: widget.enabled,
                    // focusNode: _focusNode, // Eliminar FocusNode del TextField
                    keyboardType: TextInputType.visiblePassword,
                    textAlignVertical: TextAlignVertical.center,
                    style: TextStyle(
                      fontSize:
                          16.0, // Hardcodeado según tu especificación anterior
                      fontWeight: FontWeight.w400,
                      color: AppColors.semantics.text.body,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 13.0,
                      ),
                      hintText: '',
                      hintStyle: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                        color: AppColors.semantics.text.secondary,
                      ),
                      fillColor: Colors.transparent,
                      filled: true,
                      border: InputBorder
                          .none, // Eliminar los bordes propios del TextField
                    ),
                    onChanged: (value) {
                      setState(
                        () {},
                      ); // Se mantiene para que el borde se actualice si isValidState cambia.
                      if (widget.onChanged != null) {
                        widget.onChanged!(value);
                      }
                    },
                  ),
                ),
                GestureDetector(
                  onTap: _toggleObscureText,
                  child: Padding(
                    padding: EdgeInsets.only(right: 0.0, left: 8.0),
                    child: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.semantics.text.body,
                      size: 20.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
