// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:vientri/components/action_sheet/action_sheet.dart';
import 'package:vientri/components/solid_button/solid_button.dart';
import 'package:vientri/components/subtle_button/subtle_button.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/constants/app_shadows.dart';
import 'package:vientri/pages/comunes/master/master_principal.dart';
import 'package:vientri/pages/controller.dart';
import 'package:vientri/src/models/contacto.dart';
import 'package:vientri/src/models/entidad.dart';
import 'package:flutter/material.dart';

class DetalleContacto extends StatefulWidget {
  final Entidad entidad;
  final Contacto contacto;
  const DetalleContacto({super.key, required this.entidad, required this.contacto});

  @override
  State<DetalleContacto> createState() => _DetalleContactoState();
}

class _DetalleContactoState extends State<DetalleContacto> {
  late Controller con;
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    con = Get.put(Controller(widget.entidad));
    _controller = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MasterPage(
      title: widget.contacto.des.trim() == "" ? widget.contacto.telefono : con.capitalizarNombre(widget.contacto.des.trim()),
      onBack: () => Navigator.pop(context, true),
      showKey: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          _fila("Celular", widget.contacto.telefono, Icon(CupertinoIcons.chat_bubble_text, color: AppColors.semantics.text.success, size: 25), () => escribirMsj()),
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  Widget _fila(String label, String content, Icon? icon, VoidCallback? onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.black12),
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: Fontsize.h3,
                fontWeight: FontWeight.bold,
                color: AppColors.semantics.text.body,
              ),
            ),
            Expanded(
              child: Text(
                content,
                style: TextStyle(
                  color: AppColors.semantics.text.body,
                  fontSize: Fontsize.body,
                ),
                textAlign: TextAlign.end,
              ),
            ),
            if (icon != null)
            const SizedBox(width: 4),
            if (icon != null)
            icon
          ],
        ),
      ),
    );
  }

  void escribirMsj() {
    ActionSheet.show(
      context,
      title: widget.contacto.des.trim() != "" ? "Nuevo mensaje para ${con.capitalizarNombre(widget.contacto.des.trim())}" : "Nuevo mensaje para ${widget.contacto.telefono.trim()}",
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 348.0),
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: AppColors.semantics.border.action),
                boxShadow: AppShadows.elementFocusShadow,
                color: Colors.white,
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                style: TextStyle(
                  fontSize: Fontsize.body,
                  fontWeight: FontWeight.w400,
                  color: AppColors.semantics.text.body,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.fromLTRB(16.0, 13.0, 16.0, 13.0),
                  hintText: "Escriba un mensaje..",
                  hintStyle: TextStyle(
                    fontSize: Fontsize.body,
                    color: AppColors.semantics.text.secondary,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SubtleButton(
                    text: "Cancelar",
                    type: SubtleButtonType.brand,
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ),
                Expanded(
                  child: SolidButton(
                    text: "Enviar",
                    onPressed: () async {
                      final exito = await con.enviarWpp(
                        context,
                        widget.contacto.telefono,
                        _controller.text,
                        "",
                        ""
                      );

                      if (exito) {
                        Get.snackbar(
                          "Mensaje enviado",
                          "El mensaje fue enviado correctamente",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green.shade600,
                          colorText: Colors.white,
                          margin: const EdgeInsets.all(12),
                          duration: const Duration(seconds: 2),
                        );
                        Navigator.pop(context);
                      } else {
                        Get.snackbar(
                          "Error",
                          "No se pudo enviar el mensaje",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red.shade600,
                          colorText: Colors.white,
                          margin: const EdgeInsets.all(12),
                          duration: const Duration(seconds: 2),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      _focusNode.requestFocus();
    });
  }



}
