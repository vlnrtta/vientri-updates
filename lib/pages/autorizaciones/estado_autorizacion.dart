import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vientri/components/solid_button/solid_button.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/pages/controller.dart';
import 'package:vientri/src/models/autorizacion.dart';
import 'package:vientri/src/models/entidad.dart';

// ignore: must_be_immutable
class EstadoAutorizacion extends StatefulWidget {
  Entidad entidad;
  Autorizacion autorizacion;
  String label;
  IconData icon;
  Color color;
  EstadoAutorizacion({super.key, required this.entidad, required this.autorizacion, required this.label, required this.icon, required this.color});

  @override
  State<EstadoAutorizacion> createState() => _EstadoAutorizacionState();
}

class _EstadoAutorizacionState extends State<EstadoAutorizacion> {
  late Controller con;

  @override
  void initState() {
    super.initState();
    con = Get.put(Controller(widget.entidad));
  }

  final formatter = NumberFormat.currency(
    locale: 'es_AR',
    decimalDigits: 2,
    symbol: '',
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              color: Color(0xFFF5F5F5),
            ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.icon,
                    color: widget.color,
                    size: 120,
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      widget.label,
                      style: TextStyle(
                        color: AppColors.semantics.text.body,
                        fontSize: Fontsize.h2,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  if (widget.autorizacion.importe != 0.0)
                  Text(
                    "Importe: \$${formatter.format(widget.autorizacion.importe).trim()}",
                    style: TextStyle(
                      color: AppColors.semantics.text.body,
                      fontSize: Fontsize.h3,
                      fontWeight: FontWeight.w200
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: SafeArea(child: _btnBottom())
            )
          ],
        ),
      ),
    );
  }

  Widget _btnBottom() {
    return SolidButton(
      type: SolidButtonType.primary,
      text: "Inicio",
      onPressed: () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pop(context, true);
          Navigator.pop(context, true);
        });
      }
    );
  }

}