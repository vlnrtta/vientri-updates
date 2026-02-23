// ignore_for_file: use_build_context_synchronously
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:vientri/components/heading/heading.dart';
import 'package:vientri/components/solid_button/solid_button.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/constants/app_shadows.dart';
import 'package:vientri/pages/contactos/estado_contacto.dart';
import 'package:vientri/pages/contactos/nuevo_cliente.dart';
import 'package:vientri/pages/controller.dart';
import 'package:flutter/material.dart';
import 'package:vientri/src/models/entidad.dart';

// ignore: must_be_immutable
class NuevoContacto extends StatefulWidget {
  final Entidad entidad;
  String nombre = '';
  String celular = '';
  NuevoContacto({super.key, required this.entidad, required this.nombre, required this.celular});

  @override
  State<NuevoContacto> createState() => _NuevoContactoState();
}

class _NuevoContactoState extends State<NuevoContacto> {
  late Controller con;

  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerTelefono = TextEditingController();
  final FocusNode _focusNodeName = FocusNode();
  final FocusNode _focusNodeTelefono = FocusNode();

  bool numeroValido = false;
  final RxBool isPressed = false.obs;
  final RxString pressedKey = ''.obs;
  bool isButtonEnabled = false;
  bool showCustomKeyboard = true;

  @override
  void initState() {
    super.initState();
    con = Get.put(Controller(widget.entidad));
    _controllerTelefono.text = widget.celular.replaceAll("*** *** ", "").length == 10 ? widget.celular.replaceAll("*** *** ", "") : "";
    _controllerName.text = widget.nombre;
    _controllerName.addListener(_validateForm);
    _controllerTelefono.addListener(_validateForm);

    if (widget.celular.length == 10 || widget.nombre == "") {
      showCustomKeyboard = false;

      Future.delayed(Duration(milliseconds: 300), () {
        _focusNodeName.requestFocus();
      });
    } else {
      Future.delayed(Duration(milliseconds: 300), () {
        _focusNodeTelefono.requestFocus();
      });
    }

    _focusNodeName.addListener(() {
      if (_focusNodeName.hasFocus) {
        setState(() {
          showCustomKeyboard = false;
        });
      }
    });

    _focusNodeTelefono.addListener(() {
      if (_focusNodeTelefono.hasFocus) {
        setState(() {
          showCustomKeyboard = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNodeName.dispose();
    _focusNodeTelefono.dispose();
    _controllerName.dispose();
    _controllerTelefono.dispose();
    super.dispose();
  }

  int maxLength() {
    if (widget.celular.length == 10) return 0;
    if (widget.celular.replaceAll('*** *** ', '').trim().length == 4) {
      return 6;
    }
    return 10;
  }

  void _onKeyTap(BuildContext context, String value) {
    int max = maxLength(); // será 6 si faltan 6 dígitos

    // Si no puede escribir más
    if (max == 0) return;

    // BORRAR
    if (value == '⌫') {
      if (_controllerTelefono.text.isNotEmpty) {
        _controllerTelefono.text = _controllerTelefono.text.substring(0, _controllerTelefono.text.length - 1);
        setState(() {});
      }

      _controllerTelefono.selection = TextSelection.fromPosition(
        TextPosition(offset: _controllerTelefono.text.length),
      );
      return;
    }

    if (!RegExp(r'^[0-9]$').hasMatch(value)) return;

    if (_controllerTelefono.text.length >= max) return;

    _controllerTelefono.text += value;

    _controllerTelefono.selection = TextSelection.fromPosition(
      TextPosition(offset: _controllerTelefono.text.length),
    );

    setState(() {});

    if (_controllerTelefono.text.length == max) {
      showCustomKeyboard = false;

      setState(() {});

      Future.delayed(const Duration(milliseconds: 200), () {
        _focusNodeName.requestFocus();
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF5F2FA)
            ),
          ),
    
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: AppHeading(
                    label: "Nuevo contacto",
                    fontSize: Fontsize.h1,
                    leadingIcon: Icons.arrow_back,
                    onLeadingIconPressed: () => Navigator.pop(context, true),
                  ),
                ),
              ),

              InkWell(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  Future.delayed(const Duration(milliseconds: 200), () {
                    if (mounted) {
                      FocusScope.of(context).requestFocus(_focusNodeTelefono);
                    }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          focusNode: _focusNodeTelefono,
                          controller: _controllerTelefono,
                          cursorHeight: 50,
                          keyboardType: TextInputType.phone,
                          readOnly: true,
                          showCursor: true,
                          cursorWidth: 3,
                          style: TextStyle(fontSize: 50, color: Colors.black26),
                          decoration: InputDecoration(
                            hintText: widget.celular.replaceAll("*** *** ", "").length == 4 ? "*** *** " : "*** *** ****",
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: AppColors.semantics.text.secondary, fontSize: 50),
                            isDense: true,
                          ),
                        ),
                      ),
                      if(widget.celular.replaceAll("*** *** ", "").isNotEmpty && widget.celular.replaceAll("*** *** ", "").length < 10)
                      Expanded(
                        child: Text(
                          widget.celular.replaceAll('*** *** ', ''),
                          style: TextStyle(
                            color: _controllerTelefono.text.length == 6 ? Colors.black26 : AppColors.semantics.text.body,
                            fontSize: 50,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          
              const SizedBox(height: 16),
              
              _buildTextBar(),

              const Spacer(),

              _btnBottomCliente(),
              _btnBottom(),

              if (showCustomKeyboard)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _teclado(),
                ),
              )
              
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.semantics.text.action),
        boxShadow: AppShadows.elementFocusShadow,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(
            FontAwesomeIcons.user,
            size: 20,
            color: AppColors.semantics.text.action,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              focusNode: _focusNodeName,
              controller: _controllerName,
              onChanged: (a) => _validateForm(),
              decoration: InputDecoration(
                hintText: "Nombre completo",
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _teclado() {
    const keyStyle = TextStyle(fontSize: 24, fontWeight: FontWeight.w600);
    final keyHeight = MediaQuery.sizeOf(context).height * 0.06;
    
    Widget buildKey(String key) {
      return Obx(() {
        final isPressedKey = pressedKey.value == key;
        return GestureDetector(
          onTapDown: (_) => pressedKey.value = key,
          onTapUp: (_) {
            Future.delayed(const Duration(milliseconds: 100), () {
              pressedKey.value = '';
            });
            _onKeyTap(context, key);
          },
          onTapCancel: () => pressedKey.value = '',
          child: AnimatedContainer(
            margin: const EdgeInsets.only(bottom: 16),
            height: keyHeight,
            duration: const Duration(milliseconds: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              boxShadow: isPressedKey
              ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 0,
                  offset: const Offset(0, 0),
                ),
              ]
              : []
            ),
            child: Center(
              child: Text(key, style: keyStyle.copyWith(color: AppColors.semantics.text.body, fontSize: 24, fontWeight: FontWeight.w600)),
            ),
          ),
        );
      });
    }

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Table(
              defaultColumnWidth: const FlexColumnWidth(1),
              children: [
                TableRow(children: [
                  buildKey('1'),
                  buildKey('2'),
                  buildKey('3'),
                ]),
                TableRow(children: [
                  buildKey('4'),
                  buildKey('5'),
                  buildKey('6'),
                ]),
                TableRow(children: [
                  buildKey('7'),
                  buildKey('8'),
                  buildKey('9'),
                ]),
                TableRow(children: [
                  buildKey('.'),
                  buildKey('0'),
                  buildKey('⌫'),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _btnBottom() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SolidButton(
        text: "Agregar contacto",
        leftIcon: FontAwesomeIcons.userPlus,
        type: SolidButtonType.primary,
        onPressed: isButtonEnabled
        ? () async {
          bool ok = await con.registrarContacto(context, _controllerName.text.toUpperCase(), "", _controllerTelefono.text, true);
          if (ok) {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => EstadoContacto(
                  titulo: "Contacto guardado",
                  label: "${con.capitalizarNombre(_controllerName.text)} es contacto",
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
          } else {
            con.mostrarSnackbar(esError: true, titulo: "Error", mensaje: "Hubo un error, vuelve a intentarlo mas tarde");
          }
        }
        : null
      ),
    );
  }

  Widget _btnBottomCliente() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SolidButton(
        text: "Agregar como cliente",
        type: SolidButtonType.secondary,
        onPressed: isButtonEnabled
        ? () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => NuevoCliente(
                nombre: _controllerName.text,
                celular: _controllerTelefono.text,
                entidad: widget.entidad,
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
        : null
      ),
    );
  }

  void _validateForm() {
    setState(() {
      isButtonEnabled = _controllerName.text.trim().isNotEmpty && _controllerTelefono.text.trim().length == 10;
    });
  }

}
