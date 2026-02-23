// ignore_for_file: use_build_context_synchronously

import 'package:get_storage/get_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vientri/pages/contacto/contacto_controller.dart';
import 'package:vientri/pages/contacto/detalle_contacto_page.dart';
import 'package:vientri/src/models/contacto.dart';
import 'package:vientri/src/models/entidad.dart';
import 'package:vientri/src/models/pedido.dart';

// ignore: must_be_immutable
class NuevoContactoPage extends StatefulWidget {
  final String ult4dig;
  final String nombreContacto;
  Entidad entidad;
  Pedido pedido;
  NuevoContactoPage({super.key, required this.ult4dig, required this.nombreContacto, required this.entidad, required this.pedido});
  @override
  State<NuevoContactoPage> createState() => _NuevoContactoPageState();
}

class _NuevoContactoPageState extends State<NuevoContactoPage> {
  final FocusNode _focusNode = FocusNode();
  var nuevoNumero = "".obs;
  final RxBool isFocused = false.obs;
  var completo = false.obs;
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controllerNombre = TextEditingController();
  late ContactoController con;
  final _input = "".obs;
  final RxBool isPressed = false.obs;
  final RxString pressedKey = ''.obs;
  final FocusNode _focusNodeNumero = FocusNode();
  var tecladoNativo = false.obs;
  var tecladoGrilla = false.obs;
  final _fontSize = 30.obs;
  final double _minFontSize = 14;
  final double _maxWidth = 250;

  String formatPhoneFragment(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');

    if (digits.length >= 10) {
      return '${digits.substring(0, 3)} ${digits.substring(3, 6)} ${digits.substring(6, 10)}';
    } else if (digits.length > 6) {
      return '${digits.substring(0, 3)} ${digits.substring(3, 6)} ${digits.substring(6)}';
    } else if (digits.length > 3) {
      return '${digits.substring(0, 3)} ${digits.substring(3)}';
    } else {
      return digits;
    }
  }

  String quitarTildes(String texto) {
    const conTildes  = 'áéíóúÁÉÍÓÚñÑüÜ';
    const sinTildes = 'aeiouAEIOUnNuU';

    for (int i = 0; i < conTildes.length; i++) {
      texto = texto.replaceAll(conTildes[i], sinTildes[i]);
    }
    return texto;
  }

  void _requestFocus() {
    if (!_focusNode.hasFocus) {
      FocusScope.of(context).requestFocus(_focusNode);
      tecladoGrilla.value = false;
    }
  }

  @override
  void initState() {
    super.initState();
    con = Get.put(ContactoController(widget.entidad));
    _controllerNombre.addListener(_adjustFontSize);
    _input.value = "351";
    _controller.text += _input.value; 
    _controllerNombre.text += widget.nombreContacto;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestFocus();
    });

    Future.delayed(Duration.zero, () {
      _focusNodeNumero.requestFocus();
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
          tecladoGrilla.value = true;
      }
    });

    // Si pierde el foco, lo vuelve a solicitar (hace que se vuelva loco)
    /*_focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) _requestFocus();
        });
      }
    });*/
  }

  void _adjustFontSize() {
    String text = _controllerNombre.text;
    int newFontSize = 25;
    final TextPainter tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: newFontSize.toDouble())),
      textDirection: TextDirection.ltr,
    );

    tp.layout();

    while (tp.width >= _maxWidth && newFontSize > _minFontSize) {
      newFontSize -= 3;
      tp.text = TextSpan(text: text, style: TextStyle(fontSize: newFontSize.toDouble()));
      tp.layout();
    }

      _fontSize.value = newFontSize;
  }

  void _onKeyTap(BuildContext context, String value) {
    isPressed.value = true;
    if (value == '⌫') {
        completo.value = false;
      if (_input.value.length > 1) {
        _input.value = _input.substring(0, _input.value.length - 1);
        _controller.text = _input.value;
        con.fetchContactos(_input.value, "", widget.entidad);
      } else if (_input.value.length == 1){
        _input.value = _input.substring(0, _input.value.length - 1);
        _controller.text = _input.value;
        con.fetchContactos(GetStorage().read("ultContacto${widget.entidad.usuario}"), "", widget.entidad);
      }
    } else if (value == '➤') {
      if (_input.value.length == 6) {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
              DetalleContactoPage(entidad: widget.entidad, contacto: Contacto(id: 0, idPer: 0, idArea: 0, email: "", telefono: "", horario: "", ccsiempre: false, obs: "", enviarDocumentos: false, des: "", idTipoClasificacion: 0, fecsys: "", fecins: "", nomCliente: ""), pedido: widget.pedido),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              final tween = Tween(begin: begin, end: end)
                  .chain(CurveTween(curve: Curves.ease));
              return SlideTransition(position: animation.drive(tween), child: child);
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
        GetStorage().write("ultContacto${widget.entidad.usuario}", _input.value);
        _input.value = "";
        con.search.value = _input.value;
        _controller.text = _input.value;
      } else {}
    } else {
      if (widget.nombreContacto == "") {
        if (_input.value.length < 6) {
          if (_input.value.length == 5) {
            completo.value = true;
          }
          _input.value += value;
          _controller.text = _input.value;
          /*if (_input.value.length.isEven) {
            con.fetchContactos(_input.value, "");
          }*/
        }
      } else {
        if (_input.value.length < 10) {
          if (_input.value.length == 9) {
            completo.value = true;
          }
          _input.value += value;
          _controller.text = _input.value;
          /*if (_input.value.length.isEven) {
            con.fetchContactos(_input.value, "");
          }*/
        }
      }
      
    }
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );
  }
  
  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _requestFocus,
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context, true);
                      },
                      child: Text(
                        'Volver',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.green,
                          color: Colors.green,
                          fontSize: MediaQuery.sizeOf(context).width * 0.04,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text("Nuevo contacto", style: TextStyle(fontSize: MediaQuery.sizeOf(context).width * 0.045, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 5),
              Text("Complete el número del celular", style: TextStyle(fontSize: MediaQuery.sizeOf(context).width * 0.04, color: Colors.black87)),
              const SizedBox(height: 10),
              Expanded(child: _nuevoContacto()),
              _btnNuevoContacto(context),
              tecladoGrilla.value ? _teclado() : const SizedBox()
            ],
          )),
        ),
      )
    );
  }

  Widget _nuevoContacto() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.phone, size: MediaQuery.sizeOf(context).height * 0.032),
            const SizedBox(width: 10),
            SizedBox(
              width: widget.ult4dig.isEmpty ? 250 : 140,
              child: TextField(
                onTap: () {
                  tecladoNativo.value = false;
                  tecladoGrilla.value = false;
                  Future.delayed(const Duration(milliseconds: 400), () {
                    if (mounted && _focusNodeNumero.hasFocus) {
                      tecladoGrilla.value = true;
                    }
                  });
                },
                focusNode: _focusNodeNumero,
                readOnly: true,
                showCursor: true,
                keyboardType: TextInputType.none,
                maxLength: widget.ult4dig.isEmpty ? 11 : 7,
                style: TextStyle(fontSize: MediaQuery.sizeOf(context).height * 0.032 , letterSpacing: 2),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                controller: _controller,
                decoration: const InputDecoration(
                  counterText: "",
                  border: UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 15, 105, 12))),
                  contentPadding: EdgeInsets.only(bottom: 0),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(widget.ult4dig, style: TextStyle(fontSize: MediaQuery.sizeOf(context).height * 0.032, color: Colors.black87)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.person, size: MediaQuery.sizeOf(context).height * 0.032),
            const SizedBox(width: 10),
            SizedBox(
              width: _maxWidth,
              child: TextField(
                onTap: () {
                  tecladoGrilla.value = false;
                  tecladoNativo.value = true;
                  _focusNodeNumero.unfocus();
                  Future.delayed(const Duration(milliseconds: 100), () {
                    FocusScope.of(context).requestFocus(_focusNode);
                  });
                },
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                focusNode: _focusNode,
                controller: _controllerNombre,
                style: TextStyle(fontSize: _fontSize.toDouble()),
                decoration: const InputDecoration(
                  labelText: "Nombre (opcional)",
                  border: UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 15, 105, 12))),
                  contentPadding: EdgeInsets.all(0)
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _btnNuevoContacto(BuildContext context) {
    return Obx(() => Padding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
      child: SizedBox(
        width: double.infinity,
        height: MediaQuery.sizeOf(context).height * 0.065,
        child: ElevatedButton.icon(
          onPressed: completo.value ? () {
            widget.ult4dig == "" 
            ? con.registrarContacto(context, quitarTildes(_controllerNombre.text.toUpperCase()), "", _input.value, true, widget.entidad, widget.pedido)
            : con.registrarContacto(context, quitarTildes(_controllerNombre.text.toUpperCase()), "", _input.value + widget.ult4dig, true, widget.entidad, widget.pedido);
          } : null,
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.disabled)) {
                  return const Color.fromARGB(59, 76, 175, 79);
                }
                return Colors.green;
              },
            ),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          label: const Center(
            child: Text('Agregar contacto',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white
              )
            ),
          ),
        ),
      ),
    ));
  }

  Widget _teclado() {
    const keyStyle = TextStyle(fontSize: 24, fontWeight: FontWeight.w600);

    Widget buildKey(
      String key, {
      Color? color,
      Color? textColor,
      IconData? icon,
      bool? agregar,
      double? height,
      double? width,
    }) {
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
            height: height,
            width: width,
            margin: const EdgeInsets.only(left: 1.5, right: 1.5, bottom: 3),
            duration: const Duration(milliseconds: 10),
            decoration: BoxDecoration(
              color: isPressedKey
              ? key == '➤' || key == '⌫'
                ? color!.withOpacity(0.3)
                : Colors.grey[300]
              : key == '➤' || key == '⌫'
                ? color
                : const Color.fromARGB(255, 255, 255, 255),
              borderRadius: BorderRadius.circular(8),
              //border: Border.all(color: textColor ?? Colors.transparent, width: 2),
              boxShadow: isPressedKey
              ? []
              : [
                /*BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),*/
              ],
            ),
            child: Center(
              child: icon != null
                ? agregar != null
                  ? agregar
                    ? Icon(icon, color: textColor, size: 24)
                    : Icon(icon, color: textColor ?? Colors.black, size: 24,)
                  : Icon(icon, color: textColor ?? Colors.black, size: 24,)
                : Text(key, style: keyStyle.copyWith(color: textColor, fontSize: 24, fontWeight: FontWeight.w500 )),
            ),
          ),
        );
      });
    }

    final keyWidth = MediaQuery.sizeOf(context).width / 3.5;
    final keyHeight = MediaQuery.sizeOf(context).height * 0.06;
    return Container(
      color: const Color.fromARGB(255, 236, 236, 236),
      padding: const EdgeInsets.only(left: 1.5, right: 1.5, top: 3, bottom: 30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Table(
              defaultColumnWidth: const FlexColumnWidth(1),
              children: [
                TableRow(children: [
                  buildKey('1', width: keyWidth, height: keyHeight),
                  buildKey('2', width: keyWidth, height: keyHeight),
                  buildKey('3', width: keyWidth, height: keyHeight),
                ]),
                TableRow(children: [
                  buildKey('4', width: keyWidth, height: keyHeight),
                  buildKey('5', width: keyWidth, height: keyHeight),
                  buildKey('6', width: keyWidth, height: keyHeight),
                ]),
                TableRow(children: [
                  buildKey('7', width: keyWidth, height: keyHeight),
                  buildKey('8', width: keyWidth, height: keyHeight),
                  buildKey('9', width: keyWidth, height: keyHeight),
                ]),
                TableRow(children: [
                  const SizedBox.shrink(),
                  buildKey('0', width: keyWidth, height: keyHeight),
                  const SizedBox.shrink(),
                ]),
              ],
            ),
          ),
          Column(
            children: [
              buildKey('⌫', width: MediaQuery.sizeOf(context).width / 4,
                color: Colors.white, //const Color.fromARGB(255, 248, 217, 216),
                textColor: CupertinoColors.destructiveRed,
                icon: Icons.backspace_outlined,
                height: MediaQuery.sizeOf(context).height * 0.06
              ),
              buildKey('➤', width: MediaQuery.sizeOf(context).width / 4,
                height: (3 * MediaQuery.sizeOf(context).height * 0.06) + 4.5,
                color: Colors.white, //const Color.fromARGB(255, 207, 247, 208),
                textColor: Colors.green,
                icon: Icons.keyboard_return_rounded,
                agregar: true
              ),
            ],
          ),
        ],
      ),
    );
  }

}
