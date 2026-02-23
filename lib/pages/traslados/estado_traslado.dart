import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vientri/components/solid_button/solid_button.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/pages/controller.dart';
import 'package:vientri/src/models/entidad.dart';
import 'package:vientri/src/models/envio.dart';

// ignore: must_be_immutable
class EstadoTraslado extends StatefulWidget {
  Entidad entidad;
  Envio envio;
  String label;
  IconData icon;
  Color color;
  String observacion;
  EstadoTraslado({super.key, required this.entidad, required this.envio, required this.label, required this.icon, required this.color, required this.observacion});

  @override
  State<EstadoTraslado> createState() => _EstadoTrasladoState();
}

class _EstadoTrasladoState extends State<EstadoTraslado> {
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
                    widget.label,
                    style: TextStyle(
                      color: AppColors.semantics.text.body,
                      fontSize: Fontsize.h1,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Destino: ${con.capitalizar(widget.envio.destino.trim())}",
                    style: TextStyle(
                      color: AppColors.semantics.text.body,
                      fontSize: Fontsize.h3,
                      fontWeight: FontWeight.w200
                    ),
                  ),
                  Text(
                    "Chofer: ${con.capitalizarNombre(widget.envio.chofer.trim())}",
                    style: TextStyle(
                      color: AppColors.semantics.text.body,
                      fontSize: Fontsize.h3,
                      fontWeight: FontWeight.w200
                    ),
                  ),
                  Text(
                    widget.envio.articulos.length == 1 ? "${widget.envio.articulos.length} Artículo" : "${widget.envio.articulos.length} Artículos",
                    style: TextStyle(
                      color: AppColors.semantics.text.body,
                      fontSize: Fontsize.h3,
                      fontWeight: FontWeight.w200
                    ),
                  ),
                  Text(
                    widget.observacion != "" ? "Observaciones: ${widget.observacion}" : "",
                    style: TextStyle(
                      color: AppColors.semantics.text.body,
                      fontSize: Fontsize.h3,
                      fontWeight: FontWeight.w200,
                    ),
                    textAlign: TextAlign.center,
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
      text: "Listo",
      onPressed: () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pop(context);
          Navigator.pop(context);
        });
      }
    );
  }

}