import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vientri/components/solid_button/solid_button.dart';
import 'package:vientri/components/subtle_button/subtle_button.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/pages/controller.dart';
import 'package:vientri/src/models/entidad.dart';
import 'package:vientri/src/models/ordenEntrega.dart';

// ignore: must_be_immutable
class EstadoOrdenEntrega extends StatefulWidget {
  Entidad entidad;
  OrdenEntrega ordenEntrega;
  String titulo;
  String texto;
  IconData icon;
  Color color;
  EstadoOrdenEntrega({super.key, required this.entidad, required this.titulo, required this.texto, required this.icon, required this.color, required this.ordenEntrega});

  @override
  State<EstadoOrdenEntrega> createState() => _EstadoOrdenEntregaState();
}

class _EstadoOrdenEntregaState extends State<EstadoOrdenEntrega> {
  late Controller con;

  @override
  void initState() {
    super.initState();
    con = Get.put(Controller(widget.entidad));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFF5F5F5),
                    Color(0xFFF5F5F5),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
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
                  Text(
                    widget.titulo,
                    style: TextStyle(
                      color: AppColors.semantics.text.body,
                      fontSize: Fontsize.h1,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.texto,
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
              child: SafeArea(child: Column(
                children: [
                  _btnVerComprobante(),
                  const SizedBox(height: 8),
                  _btnBottom(),
                ],
              ))
            )
          ],
        ),
      ),
    );
  }

  Widget _btnVerComprobante() {
    return SubtleButton(
      type: SubtleButtonType.brand,
      text: "Ver comprobante",
      onPressed: () {
        Navigator.pop(context);
      }
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