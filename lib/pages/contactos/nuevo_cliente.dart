// ignore_for_file: use_build_context_synchronously, avoid_print
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:vientri/components/heading/heading.dart';
import 'package:vientri/components/solid_button/solid_button.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/constants/app_shadows.dart';
import 'package:vientri/pages/controller.dart';
import 'package:flutter/material.dart';
import 'package:vientri/src/models/cliente.dart';
import 'package:vientri/src/models/entidad.dart';

// ignore: must_be_immutable
class NuevoCliente extends StatefulWidget {
  final Entidad entidad;
  String nombre = '';
  String celular = '';
  NuevoCliente({super.key, required this.entidad, required this.nombre, required this.celular});

  @override
  State<NuevoCliente> createState() => _NuevoClienteState();
}

class _NuevoClienteState extends State<NuevoCliente> {
  late Controller con;

  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerTelefono = TextEditingController();
  final TextEditingController _controllerCuil = TextEditingController();
  final FocusNode _focusNodeName = FocusNode();
  final FocusNode _focusNodeTelefono = FocusNode();
  final FocusNode _focusNodeCuil = FocusNode();

  Cliente cliente = Cliente(id: -1, cuit: 0, des: "", inscripcion: "", idsexo: 0, idciva: 0, idtipper: 0, idiigg: 0, empleador: false, intsoc: false, catmonotributo: "", actmonotributo: "");

  bool numeroValido = false;
  final RxBool isPressed = false.obs;
  final RxString pressedKey = ''.obs;
  bool isButtonEnabled = false;
  bool showCustomKeyboard = true;
  bool showFormulario = false;

  @override
  void initState() {
    super.initState();
    con = Get.put(Controller(widget.entidad));
    _controllerTelefono.text = widget.celular.replaceAll("*** *** ", "").length == 10 ? widget.celular.replaceAll("*** *** ", "") : "";
    _controllerName.text = widget.nombre;
  }

  @override
  void dispose() {
    _focusNodeName.dispose();
    _focusNodeTelefono.dispose();
    _focusNodeCuil.dispose();
    _controllerName.dispose();
    _controllerTelefono.dispose();
    _controllerCuil.dispose();
    super.dispose();
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
                    label: "Nuevo cliente",
                    fontSize: Fontsize.h1,
                    leadingIcon: Icons.arrow_back,
                    onLeadingIconPressed: () => Navigator.pop(context, true),
                  ),
                ),
              ),
              _buildPhoneBar(),
              const SizedBox(height: 16),
              _buildNameBar(),
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
                child: Text(
                  "CUIT/CUIL",
                  style: TextStyle(color: AppColors.semantics.text.body, fontSize: Fontsize.body),
                ),
              ),
              _buildCuilBar(),
              const SizedBox(height: 16),
              if (showFormulario)
              formulario(),
              const Spacer(),
              _btnBottom(),

              if (!showCustomKeyboard)
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


  Widget _buildPhoneBar() {
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
            CupertinoIcons.phone,
            size: 24,
            color: AppColors.semantics.text.action,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              focusNode: _focusNodeTelefono,
              controller: _controllerTelefono,
              onChanged: (a) => _validateForm(),
              decoration: InputDecoration(
                hintText: "Teléfono",
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

  Widget _buildNameBar() {
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

  Widget _buildCuilBar() {
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
          Expanded(
            child: TextField(
              focusNode: _focusNodeCuil,
              controller: _controllerCuil,
              onChanged: (a) => _validateForm(),
              keyboardType: TextInputType.numberWithOptions(),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Icon(
            CupertinoIcons.cloud_download,
            size: 24,
            color: AppColors.semantics.text.action,
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
            //_onKeyTap(context, key);
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
        text: "Agregar cliente",
        leftIcon: FontAwesomeIcons.userPlus,
        type: SolidButtonType.primary,
        onPressed: isButtonEnabled
        ? () async {
          cliente = await con.buscarPorCuilArca(_controllerCuil.text) ?? Cliente(id: 0, cuit: 0, des: "", inscripcion: "", idsexo: 0, idciva: 0, idtipper: 0, idiigg: 0, empleador: false, intsoc: false, catmonotributo: "", actmonotributo: "");
          if (cliente.id != -1) {
            setState(() {
              showFormulario= true;
            });
            print(cliente.toJson());
          } else {
            con.mostrarSnackbar(esError: true, titulo: "Error", mensaje: "Hubo un error, vuelve a intentarlo mas tarde");
          }
        }
        : null
      ),
    );
  }

  Widget formulario() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fila("Des", con.capitalizarNombre(cliente.des)),
          _fila("Inscripción", cliente.inscripcion),
        ]
      ),
    );
  }

  Widget _fila(String label, String content) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black12),
        ),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: Fontsize.h3,
              fontWeight: FontWeight.bold,
              color: AppColors.semantics.text.body,
            ),
          ),
          Expanded(
            child: Text(
              content,
              style: TextStyle(
                color: AppColors.semantics.text.body,
                fontSize: Fontsize.body,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  void _validateForm() {
    setState(() {
      isButtonEnabled = _controllerName.text.trim().isNotEmpty && _controllerTelefono.text.trim().length == 10;
    });
  }

}
