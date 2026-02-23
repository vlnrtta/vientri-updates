// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:vientri/pages/comunes/login/login_page.dart';
import 'package:vientri/src/models/entidad.dart';

class NuevaPasswordCuatro extends StatefulWidget {
  String ruta;
  Entidad entidad;
  NuevaPasswordCuatro({super.key, required this.ruta, required this.entidad});

  @override
  State<NuevaPasswordCuatro> createState() => _NuevaPasswordCuatroState();
}

class _NuevaPasswordCuatroState extends State<NuevaPasswordCuatro> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              reverse: true,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.only(left: 20, right: 20, top: MediaQuery.sizeOf(context).height * 0.2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          color: Colors.green,
                          size: 70,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Listo",
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.sizeOf(context).width * 0.05,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Nueva contraseña guardada",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: MediaQuery.sizeOf(context).width * 0.045,
                          ),
                        ),
                        const Spacer(),
                        _btnAccion(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _btnAccion() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pushAndRemoveUntil(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
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
            (route) => route.settings.name == '/'
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:Colors.black87,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Text(
            'Ir al inicio',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}