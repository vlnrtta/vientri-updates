import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vientri/components/solid_button/solid_button.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/pages/controller.dart';
import 'package:vientri/src/models/control.dart';
import 'package:vientri/src/models/entidad.dart';

// ignore: must_be_immutable
class EstadoControl extends StatefulWidget {
  Entidad entidad;
  Control control;
  String label;
  IconData icon;
  Color color;
  EstadoControl({super.key, required this.entidad, required this.control, required this.label, required this.icon, required this.color});

  @override
  State<EstadoControl> createState() => _EstadoControlState();
}

class _EstadoControlState extends State<EstadoControl> {
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
                    con.capitalizar(widget.control.ubicacion.trim()),
                    style: TextStyle(
                      color: AppColors.semantics.text.body,
                      fontSize: Fontsize.h3,
                      fontWeight: FontWeight.w200
                    ),
                  ),
                  if (widget.control.articulos.isNotEmpty)
                  Text(
                    widget.control.articulos.length == 1
                    ? "${widget.control.articulos.length} Artículo"
                    : "${widget.control.articulos.length} Artículos",
                    style: TextStyle(
                      color: AppColors.semantics.text.body,
                      fontSize: Fontsize.h3,
                      fontWeight: FontWeight.w200
                    ),
                  ),
                  if (widget.control.duracion != "")
                  Text(
                    "Duración: ${widget.control.duracion}",
                    style: TextStyle(
                      color: AppColors.semantics.text.body,
                      fontSize: Fontsize.h3,
                      fontWeight: FontWeight.w200
                    ),
                  ),
                  Text(
                    widget.control.empleado,
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
        /*Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => ListaControles(entidad: widget.entidad),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(-1.0, 0.0);
              const end = Offset.zero;
              final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );*/
      }
    );
  }

}