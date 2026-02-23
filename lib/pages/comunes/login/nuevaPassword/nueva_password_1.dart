import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vientri/pages/comunes/login/nuevaPassword/nueva_password_2.dart';
import 'package:vientri/src/models/entidad.dart';

// ignore: must_be_immutable
class NuevaPasswordUno extends StatefulWidget {
  String ruta;
  Entidad entidad;
  NuevaPasswordUno({super.key, required this.ruta, required this.entidad});

  @override
  State<NuevaPasswordUno> createState() => _NuevaPasswordUnoState();
}

class _NuevaPasswordUnoState extends State<NuevaPasswordUno> {
  final TextEditingController _mailController = TextEditingController();
  final _emailText = ''.obs;
  final FocusNode _mailFocusNode = FocusNode();
  final _isFocused = false.obs;

  @override
  void initState() {
    super.initState();
    _mailController.addListener(() {
      _emailText.value = _mailController.text;
    });

    _mailFocusNode.addListener(() {
      _isFocused.value = _mailFocusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _mailController.dispose();
    _mailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          const Text(
                            "Restablecer contraseña",
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Ingresá el correo electrónico asociado a tu cuenta y te enviaremos un código para verificar que sos vos.",
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _inputMail(),
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
      ),
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
                    pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
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

  Widget _inputMail() {
    return Obx(() => Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: _isFocused.value ? Colors.green : Colors.grey.shade300, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Text(
            'Email',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _mailController,
              focusNode: _mailFocusNode,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none, 
              ),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _btnAccion() {
    return Obx(() => SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _emailText.value.isNotEmpty
        ? () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => NuevaPasswordDos(ruta: widget.ruta, entidad: widget.entidad, email: _emailText.value),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                final tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: Curves.ease));
                return SlideTransition(
                    position: animation.drive(tween), child: child);
              },
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
        }
        : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _emailText.value.isNotEmpty
              ? Colors.black87
              : const Color.fromARGB(255, 221, 220, 220),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Text(
            'Enviar código',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ),
    ));
  }

}