import 'package:flutter/material.dart';
import 'package:vientri/components/solid_button/solid_button.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/pages/controller.dart';

// ignore: must_be_immutable
class EstadoContacto extends StatefulWidget {
  String label;
  IconData icon;
  String titulo;
  Color color;
  EstadoContacto({super.key, required this.label, required this.icon, required this.color, required this.titulo});

  @override
  State<EstadoContacto> createState() => _EstadoContactoState();
}

class _EstadoContactoState extends State<EstadoContacto> {
  late Controller con;

  @override
  void initState() {
    super.initState();
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
                    widget.titulo,
                    style: TextStyle(
                      color: AppColors.semantics.text.body,
                      fontSize: Fontsize.h3,
                      fontWeight: FontWeight.w200
                    ),
                  ),
                  Text(
                    widget.label,
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