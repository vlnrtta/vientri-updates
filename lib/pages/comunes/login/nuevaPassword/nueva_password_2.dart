import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:vientri/pages/comunes/login/nuevaPassword/nueva_password_3.dart';
import 'package:vientri/src/models/entidad.dart';

// ignore: must_be_immutable
class NuevaPasswordDos extends StatefulWidget {
  String ruta;
  Entidad entidad;
  String email;
  NuevaPasswordDos({super.key, required this.ruta, required this.entidad, required this.email});

  @override
  State<NuevaPasswordDos> createState() => _NuevaPasswordDosState();
}

class _NuevaPasswordDosState extends State<NuevaPasswordDos> {
  var valor = "";

  // CONTADOR
  final _contador = 60.obs;
  final _puedeReenviar = false.obs;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _iniciarContador();
  }

  void _iniciarContador() {
    _puedeReenviar.value = false;
    _contador.value = 60;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_contador.value > 0) {
        _contador.value--;
      } else {
        _puedeReenviar.value = true;
        timer.cancel();
      }
    });
  }

  void _reenviarCodigo() {
    // Ejecuta la acción de reenviar código aquí
    print("Código reenviado a: ${widget.email}");
    _iniciarContador();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            // Esto hace que no se oculte contenido al aparecer el teclado
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              _buildHeader(),
              const Text(
                "Ingresá el código que te enviamos",
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Enviamos un código de verificación a v******@gmail.com",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 30),
              _codigo(context),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "No recibí el código. ",
                    style: TextStyle(
                      color: Colors.black87,
                    ),
                  ),
                  Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _puedeReenviar.value ? _reenviarCodigo : null,
                        child: Text(
                          "Reenviar código",
                          style: TextStyle(
                            fontSize: 16,
                            color: _puedeReenviar.value ? Colors.green : Colors.grey,
                            decoration: TextDecoration.underline,
                            decorationColor:
                                _puedeReenviar.value ? Colors.green : Colors.grey,
                          ),
                        ),
                      ),
                      if (!_puedeReenviar.value) ...[
                        const SizedBox(width: 8),
                        Text(
                          "(${_contador.value}s)",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ],
                  ))
                ],
              ),
            ],
          ),
        ),
      ),
      /*bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: _btnAccion(),
      ),*/
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black87.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
                /*Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => NuevaPasswordUno(ruta: widget.ruta, entidad: widget.entidad),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(-1.0, 0.0);
                      const end = Offset.zero;
                      final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
                      return SlideTransition(position: animation.drive(tween), child: child);
                    },
                    transitionDuration: const Duration(milliseconds: 400),
                  ),
                );*/
              },
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _codigo(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width * 0.7,
        child: PinCodeTextField(
          appContext: context,
          length: 4,
          keyboardType: TextInputType.number,
          animationType: AnimationType.fade,
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(12),
            fieldHeight: 60,
            fieldWidth: 55,
            activeColor: Colors.green,
            selectedColor: Colors.green,
            inactiveColor: Colors.grey.shade300,
            activeFillColor: Colors.white,
            selectedFillColor: Colors.white,
            inactiveFillColor: Colors.grey.shade50,
          ),
          cursorColor: Colors.green,
          animationDuration: const Duration(milliseconds: 300),
          enableActiveFill: true,
          onChanged: (value) {
          },
          onCompleted: (value) {
            setState(() {
              valor = value;
            });
            bool ok = valor == value; //con.compare(value);
            if (ok) {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => NuevaPasswordTres(ruta: widget.ruta, entidad: widget.entidad, email: widget.email),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
                    return SlideTransition(position: animation.drive(tween), child: child);
                  },
                  transitionDuration: const Duration(milliseconds: 400),
                ),
              );
            } else {
              Get.snackbar(
                'Código incorrecto', 
                'El código ingresado no es válido. Por favor, inténtelo nuevamente.',
                backgroundColor: Colors.red.shade100,
                colorText: Colors.red.shade900,
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(20),
                borderRadius: 10,
                duration: const Duration(seconds: 3),
              );
            }
          },
        ),
      ),
    );
  }

}