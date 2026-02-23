import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vientri/components/solid_button/solid_button.dart';
import 'package:vientri/components/subtle_button/subtle_button.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/pages/controller.dart';
import 'package:vientri/pages/remito_devolucion/comprobante_remito.dart';
import 'package:vientri/src/models/articulo.dart';
import 'package:vientri/src/models/entidad.dart';
import 'package:vientri/src/models/remitoDevolucion.dart';

// ignore: must_be_immutable
class EstadoRemito extends StatefulWidget {
  Entidad entidad;
  RemitoDevolucion remitoDevolucion;
  List<Articulo> articulos;
  String titulo;
  String texto;
  IconData icon;
  Color color;
  String observacion;
  EstadoRemito({super.key, required this.entidad, required this.titulo, required this.texto, required this.icon, required this.color, required this.observacion, required this.remitoDevolucion, required this.articulos});

  @override
  State<EstadoRemito> createState() => _EstadoRemitoState();
}

class _EstadoRemitoState extends State<EstadoRemito> {
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
                  Text(
                    "Artículos devueltos",
                    style: TextStyle(
                      color: AppColors.semantics.text.body,
                      fontSize: Fontsize.h3,
                      fontWeight: FontWeight.bold
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
              child: SafeArea(child: Column(
                children: [
                  SubtleButton(
                    text: "Ver comprobante",
                    onPressed: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => ComprobanteRemito(entidad: widget.entidad, remitoDevolucion: widget.remitoDevolucion, articulos: widget.articulos),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0);
                            const end = Offset.zero;
                            final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
                            return SlideTransition(position: animation.drive(tween), child: child);
                          },
                          transitionDuration: const Duration(milliseconds: 400),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _btnBottom(),
                ],
              ))
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
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pop(context);
        });
      }
    );
  }

}