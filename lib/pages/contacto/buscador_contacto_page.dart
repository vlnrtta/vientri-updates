// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:vientri/constants/skeleton.dart';
import 'package:vientri/pages/contacto/contacto_controller.dart';
import 'package:vientri/pages/contacto/detalle_contacto_page.dart';
import 'package:vientri/pages/contacto/nuevo_contacto_page.dart';
import 'package:vientri/pages/contacto/reciente_contacto_page.dart';
import 'package:vientri/pages/controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:vientri/src/models/contacto.dart';
import 'package:vientri/src/models/entidad.dart';
import 'package:vientri/src/models/pedido.dart';

// ignore: must_be_immutable
class BuscadorContactoPage extends StatefulWidget {
  Entidad entidad;
  Pedido pedido;
  BuscadorContactoPage({super.key, required this.entidad, required this.pedido});

  @override
  State<BuscadorContactoPage> createState() => _BuscadorContactoPageState();
}

class _BuscadorContactoPageState extends State<BuscadorContactoPage> {
  late ContactoController con;
  late Controller cont;

  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controllerNombre = TextEditingController();
  final _input = "".obs;
  final _inputNombre = "".obs;
  final RxBool isFocused = false.obs;
  final RxBool isPressed = false.obs;
  final RxString pressedKey = ''.obs;
  String valor = "";
  var selectedIndex = 0.obs;
  List<Contacto> visualizados = [];
  late FocusNode _focusNode;
  late FocusNode _focusNombre;
  Timer? _debounce;
  var buscando = false.obs;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNombre = FocusNode();
    con = Get.put(ContactoController(widget.entidad));
    cont = Get.put(Controller(widget.entidad));
    con.search.value = GetStorage().read("ultContacto${widget.entidad.usuario}") ?? "";
    con.fetchContactos(GetStorage().read("ultContacto${widget.entidad.usuario}") ?? "", "", widget.entidad);

    if (selectedIndex.value == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(_focusNode);
      });
    }
  }

  void _onKeyTap(BuildContext context, String value) {
    isPressed.value = true;
    if (value == '⌫') {
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
      if (_input.value.length == 4) {
        valor = _input.value;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NuevoContactoPage(ult4dig: valor, nombreContacto: _inputNombre.value, entidad: widget.entidad, pedido: widget.pedido),
          ),
        );
        GetStorage().write("ultContacto${widget.entidad.usuario}", _input.value);
        _input.value = "";
        con.search.value = _input.value;
        _controller.text = _input.value;
      } else {}
    } else {
      if (_input.value.length < 4) {
        _input.value += value;
        _controller.text = _input.value;
        if (_input.value.length.isEven) {
          con.fetchContactos(_input.value, "", widget.entidad);
        }
      } else {}
    }
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );
  }
  
  @override
  void dispose() {
    _focusNode.dispose();
    _focusNombre.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => selectedIndex.value == 0 
          ? FocusScope.of(context).requestFocus(_focusNode)
          : FocusScope.of(context).requestFocus(_focusNombre),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
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
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => RecienteContactoPage(entidad: widget.entidad, pedido: widget.pedido),
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
                            )
                          );
                        },
                        child: Text(
                          'Recientes',
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
                Text(
                  "Identificar contacto",
                  style: TextStyle(
                    fontSize: MediaQuery.sizeOf(context).width * 0.045,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    overflow: TextOverflow.ellipsis
                  ),
                  maxLines: 1
                ),
                _switch(),
                const SizedBox(height: 5),
                selectedIndex.value == 0
                  ? Text(
                    "Ingrese los últimos 4 dígitos del celular",
                    style: TextStyle(
                      fontSize: MediaQuery.sizeOf(context).width * 0.04,
                      color: Colors.black87
                    )
                  )
                  : Text(
                    "Ingrese el nombre",
                    style: TextStyle(
                      fontSize: MediaQuery.sizeOf(context).width * 0.04,
                      color: Colors.black87
                    )
                  ),
                const SizedBox(height: 4),
                Expanded(
                  child: Container(
                    color: Colors.transparent,
                    width: MediaQuery.sizeOf(context).width,
                    child: _buscaContactos()
                  ),
                ),
                _btnBuscar(context),
                selectedIndex.value == 0
                  ? _teclado()
                  : const SizedBox(),
              ],
            ),
          ),
        ),
      )),
    );
  }

  Widget _switch() {
    return Obx(() => Container(
      height: MediaQuery.sizeOf(context).height * 0.042,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOption("Por número", 0),
          _buildOption("Por nombre", 1),
        ],
      ),
    ));
  }

  Widget _buscaContactos() {
    return Column(
      children: [ 
        selectedIndex.value == 0
        ? _buscadorNumerico()
        : _buscadorNombre(),
        const SizedBox(height: 10),
        Expanded(
          child: Obx(() {
            if (buscando.value) {
              return ListView.builder(
                itemCount: 1,
                itemBuilder: (context, index) {
                  return SkeletonShimmer(
                    width: MediaQuery.sizeOf(context).width * 0.9,
                    height: 60,
                  );
                },
              );
            } else {
              return ListView.builder(
                itemCount: con.filteredContacts.length + 1,
                itemBuilder: (context, index) {
                  if (index == con.filteredContacts.length) {
                    return const SizedBox.shrink();
                  }
                  final contact = con.filteredContacts[index];
                  final rawNumber = contact.telefono;
                  final lastTen = rawNumber.length >= 10
                      ? rawNumber.substring(rawNumber.length - 10)
                      : rawNumber.padLeft(10, '*');
                  final phoneParts = lastTen.split('');
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final box = GetStorage();
                          DateTime ahora = DateTime.now();
                          String fecha = DateFormat('dd/MM/yyyy HH:mm').format(ahora);
                          String soloFecha = DateFormat('dd/MM/yyyy').format(ahora);

                          String key = "visualizados${widget.entidad.usuario}";
                          final rawList = box.read(key) as List?;
                          List<Contacto> visualizados = rawList != null
                            ? rawList.map((e) => e is Contacto ? e : Contacto.fromJson(e as Map<String, dynamic>)).toList()
                            : [];
                          Contacto contacto = Contacto(
                            fecha: fecha,
                            id: contact.id,
                            idPer: contact.idPer,
                            idArea: contact.idArea,
                            email: contact.email,
                            telefono: contact.telefono,
                            horario: contact.horario,
                            ccsiempre: contact.ccsiempre,
                            obs: contact.obs,
                            enviarDocumentos: contact.enviarDocumentos,
                            des: contact.des,
                            idTipoClasificacion: contact.idTipoClasificacion,
                            fecsys: contact.fecsys,
                            fecins: contact.fecins,
                            nomCliente: contact.nomCliente
                          );

                          // Buscar todos los que coinciden por teléfono
                          int indexMismoDia = -1;
                          for (int i = 0; i < visualizados.length; i++) {
                            final v = visualizados[i];
                            if (v.telefono == contact.telefono) {
                              final fechaGuardada = v.fecha;
                              final fechaSoloGuardada = fechaGuardada.toString().split(" ").first;
                              if (fechaSoloGuardada == soloFecha) {
                                indexMismoDia = i;
                                break;
                              }
                            }
                          }

                          if (indexMismoDia != -1) {
                            visualizados[indexMismoDia] = contacto;
                          } else {
                            visualizados.insert(0, contacto);
                          }

                          box.write(key, visualizados.map((c) => c.toJson()).toList());
                          box.write("ultContacto${widget.entidad.usuario}", contact.telefono.substring(contact.telefono.length - 4));
                          GetStorage().write("contacto", contacto.toJson());
                          final data = GetStorage().read("contacto");
                          contacto = data != null ? Contacto.fromJson(data) : Contacto(email: "", telefono: "", horario: "", obs: "", des: "", fecsys: "", fecins: "", nomCliente: "", id: -1, idPer: -1, idArea: -1);
                          widget.pedido.idContactoPer = contacto.id;
                          widget.pedido.nameContacto = contacto.des;
                          widget.pedido.telefono = contacto.telefono;
                          widget.pedido.idPer = contacto.idPer;
                          widget.pedido.id = await cont.actualizarPedido(context, widget.entidad, widget.pedido);

                          Navigator.pop(context, true);
                        },

                        child: Container(
                          width: MediaQuery.sizeOf(context).width * 0.9,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 248, 248, 248),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: MediaQuery.sizeOf(context).width * 0.7,
                                    child: Text(
                                      con.capitalizarNombre(contact.des), 
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: MediaQuery.sizeOf(context).width * 0.035
                                      ),
                                      overflow: TextOverflow.ellipsis, maxLines: 2
                                    )
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '${phoneParts.sublist(0, 3).join()} '
                                        '${phoneParts.sublist(3, 6).join()} ',
                                        style: TextStyle(fontSize: MediaQuery.sizeOf(context).width * 0.035, color: Colors.black),
                                      ),
                                      Text(
                                        phoneParts.sublist(6).join(),
                                        style: TextStyle(fontSize: MediaQuery.sizeOf(context).width * 0.035, fontWeight: FontWeight.bold, color: Colors.black),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: MediaQuery.sizeOf(context).width * 0.5,
                                    child: Text(
                                      con.capitalizarNombre(contact.nomCliente ?? ""),
                                      style: TextStyle(
                                        color: Colors.black38,
                                        fontSize: MediaQuery.sizeOf(context).width * 0.034
                                      ),
                                      overflow: TextOverflow.ellipsis
                                    )
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation, secondaryAnimation) => DetalleContactoPage(contacto: contact, entidad: widget.entidad, pedido: widget.pedido),
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
                                      //con.enviarMensajeWhatsApp(contact.telefono!, "");
                                    },
                                  child: Icon(CupertinoIcons.info, color: Colors.green, size: MediaQuery.sizeOf(context).width * 0.08),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            }
          }
        )
      )
    ]);
  }

  Widget _btnBuscar(BuildContext context) {
    return Obx(() => Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        color: Colors.transparent,
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: selectedIndex.value == 0
          ? _input.value.length == 4 ? () {
              valor = _input.value;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NuevoContactoPage(ult4dig: valor, nombreContacto: _inputNombre.value, entidad: widget.entidad, pedido: widget.pedido),
                ),
              );
              GetStorage().write("ultContacto${widget.entidad.usuario}", valor);
              _input.value = "";
              con.search.value = _input.value;
              _controller.text = _input.value;
            } : null
          : _inputNombre.value.isNotEmpty ? () {
              valor = _inputNombre.value;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NuevoContactoPage(ult4dig: "", nombreContacto: valor, entidad: widget.entidad, pedido: widget.pedido),
                ),
              );
              //GetStorage().write("ultContacto${entidad.nombre}", valor);
              _inputNombre.value = "";
              con.search.value = _inputNombre.value;
              _controllerNombre.text = _inputNombre.value;
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
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          label: selectedIndex.value == 0
          ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Agregar *** ***',
                    style: TextStyle(
                      fontSize: MediaQuery.sizeOf(context).width * 0.05,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                    )
                  ),
                  Text(' ${_input.value}',
                    style: TextStyle(
                      fontSize: MediaQuery.sizeOf(context).width * 0.05,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                    )
                  ),
                ],
              ),
          )
          : Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Agregar a',
                  style: TextStyle(
                    fontSize: MediaQuery.sizeOf(context).width * 0.05,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                  )
                ),
                Text(' "${_inputNombre.value}"',
                  style: TextStyle(
                    fontSize: MediaQuery.sizeOf(context).width * 0.05,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                  )
                ),
              ],
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

  Widget _buildOption(String text, int index) {
    final isSelected = selectedIndex.value == index;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        _input.value = "";
        _controller.text = "";
        _inputNombre.value = "";
        _controllerNombre.text = "";
        selectedIndex.value = index;
        
        if (selectedIndex.value == 1) {
          _focusNode.unfocus();
          Future.delayed(const Duration(milliseconds: 300), () {
            FocusScope.of(context).requestFocus(_focusNombre);
          });
        } else { 
          _focusNombre.unfocus();
          FocusScope.of(context).requestFocus(_focusNode);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        height: double.infinity,
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.withOpacity(0.1) : Colors.transparent,
          border: isSelected ? Border.all(color: Colors.green) : Border.all(color: const Color.fromARGB(244, 166, 168, 166)),
          borderRadius: index == 0
          ? const BorderRadius.only(
            topLeft: Radius.circular(8),
            bottomLeft: Radius.circular(8),
          )
          : const BorderRadius.only(
            topRight: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontSize: MediaQuery.sizeOf(context).width * 0.035,
            color: isSelected ? Colors.green : Colors.black54,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buscadorNumerico() {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.phone, size: MediaQuery.sizeOf(context).width * 0.07),
          const SizedBox(width: 10),
          Text("*** ***", style: TextStyle(fontSize: MediaQuery.sizeOf(context).width * 0.065, color: Colors.black87, letterSpacing: 5)),
          const SizedBox(width: 10),
          SizedBox(
            width: 80,
            child: TextField(
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              focusNode: _focusNode,
              showCursor: true,
              readOnly: true,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              maxLength: 4,
              style: const TextStyle(fontSize: 30),
              controller: _controller,
              decoration: const InputDecoration(
                counterText: "",
                border: UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 15, 105, 12))),
                contentPadding: EdgeInsets.only(bottom: 0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buscadorNombre() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(width: 10),
        Icon(CupertinoIcons.person, size: MediaQuery.sizeOf(context).width * 0.09),
        const SizedBox(width: 10),
        SizedBox(
          width: MediaQuery.sizeOf(context).width * 0.75,
          child: TextField(
            controller: _controllerNombre,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            showCursor: true,
            focusNode: _focusNombre,
            readOnly: false,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            style: TextStyle(fontSize: MediaQuery.sizeOf(context).width * 0.06),
            onChanged: (value) {
              _inputNombre.value = _controllerNombre.text;

              buscando.value = true;

              if (_debounce?.isActive ?? false) _debounce!.cancel();

              _debounce = Timer(const Duration(seconds: 3), () {
                con.fetchContactos("", _controllerNombre.text, widget.entidad);
                buscando.value = false;
              });
            },
            decoration: const InputDecoration(
              counterText: "",
              border: UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 15, 105, 12))),
              contentPadding: EdgeInsets.all(0),
            ),
          ),
        ),
      ],
    );
  }

}