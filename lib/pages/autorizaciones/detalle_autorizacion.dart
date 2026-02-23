// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vientri/components/solid_button/solid_button.dart';
import 'package:vientri/components/subtle_button/subtle_button.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/pages/autorizaciones/estado_autorizacion.dart';
import 'package:vientri/pages/comunes/master/master_principal.dart';
import 'package:vientri/pages/controller.dart';
import 'package:vientri/src/models/autorizacion.dart';
import 'package:vientri/src/models/entidad.dart';

// ignore: must_be_immutable
class DetalleAutorizacion extends StatefulWidget {
  Entidad entidad;
  Autorizacion autorizacion;
  DetalleAutorizacion({super.key, required this.entidad, required this.autorizacion});

  @override
  State<DetalleAutorizacion> createState() => _DetalleAutorizacionState();
}

class _DetalleAutorizacionState extends State<DetalleAutorizacion> {
  late Controller con;
  late TextEditingController _controller;
  late FocusNode _focusNode;

  final formatter = NumberFormat.currency(
    locale: 'es_AR',
    decimalDigits: 2,
    symbol: '',
  );

  @override
  void initState() {
    super.initState();
    con = Get.put(Controller(widget.entidad));
    cargarAutorizacion();
    _controller = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void cargarAutorizacion() async {
    final data = await con.detalleAutorizacion(widget.autorizacion.idAutorizacion);
    setState(() {
      int idSalon = widget.autorizacion.idSalon;
      widget.autorizacion = data;
      widget.autorizacion.idSalon = idSalon;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterPage(
      title: con.capitalizarNombre(widget.autorizacion.apeNomCliente),
      onBack: () => Navigator.pop(context, true),
      showKey: false,
      fondo: Colors.white,
      floatingButton: _btnAutorizar(),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _infoItem("Fecha", con.formatearFechayDia3(widget.autorizacion.fecha)),
                _infoItem("Usuario", con.capitalizarNombre(widget.autorizacion.apeNomUsuario)),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _infoItem("Tipo autorización", con.capitalizar(widget.autorizacion.tipoAutorizacion)),
              ],
            ),
            
            const SizedBox(height: 20),

            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.autorizacion.importe != 0.0)
                _infoItem("Importe", "\$${formatter.format(widget.autorizacion.importe).trim()}"),
                if (widget.autorizacion.porcentaje != 0.0)
                _infoItem("Descuento", "%${widget.autorizacion.porcentaje}"),
              ],
            ),

            const SizedBox(height: 20),

            _btnRechazar()
          ],
        ),
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.semantics.text.secondary,
              fontSize: Fontsize.h3
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppColors.semantics.text.body,
              fontSize: Fontsize.h3
            ),
          ),
        ],
      ),
    );
  }

  Widget _btnRechazar() {
    return SubtleButton(
      type: SubtleButtonType.error,
      text: "Rechazar",
      onPressed: () async {
        bool ok = await con.autorizar(widget.autorizacion.idAutorizacion, 0, widget.autorizacion.porcentaje, widget.autorizacion.importe);
        if (ok) {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => EstadoAutorizacion(
                entidad: widget.entidad,
                autorizacion: widget.autorizacion,
                label: "Acción exitosa",
                icon: Icons.check_circle_outline_rounded,
                color: AppColors.semantics.text.success,
              ),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
        }
        else {
          con.mostrarSnackbar(esError: true, mensaje: "Hubo un error de conexión, intentelo de nuevo mas tarde.", titulo: "Error");
        }
      },
    );
  }

  Widget _btnAutorizar() {
    return SolidButton(
      type: SolidButtonType.primary,
      text: "Autorizar",
      onPressed: () async {
        bool ok = await con.autorizar(widget.autorizacion.idAutorizacion, 1, null, null);
        if (ok) {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => EstadoAutorizacion(
                entidad: widget.entidad,
                autorizacion: widget.autorizacion,
                label: "Acción exitosa",
                icon: Icons.check_circle_outline_rounded,
                color: AppColors.semantics.text.success,
              ),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
        }
        else {
          con.mostrarSnackbar(esError: true, mensaje: "Hubo un error de conexión, intentelo de nuevo mas tarde.", titulo: "Error");
        }
      },
    );
  }

}