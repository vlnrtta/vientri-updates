// ignore_for_file: use_build_context_synchronously

import 'package:vientri/constants/notificaciones.dart';
import 'package:vientri/pages/contacto/buscador_contacto_page.dart';
import 'package:vientri/pages/contacto/contacto_controller.dart';
import 'package:vientri/pages/contacto/detalle_contacto_page.dart';
import 'package:vientri/src/models/contacto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vientri/src/models/entidad.dart';
import 'package:vientri/src/models/pedido.dart';

// ignore: must_be_immutable
class EditarContactoPage extends StatefulWidget {
  Entidad entidad;
  final Contacto contacto;
  Pedido pedido;
  EditarContactoPage({super.key, required this.contacto, required this.entidad, required this.pedido});

  @override
  State<EditarContactoPage> createState() => _EditarContactoPageState();
}

class _EditarContactoPageState extends State<EditarContactoPage> {
  late ContactoController con;
  final _formKey = GlobalKey<FormState>();
  final _controllerNombre = TextEditingController();
  final TextEditingController _controllerRol = TextEditingController();
  final TextEditingController _controllerCelular = TextEditingController();
  final TextEditingController _controllerTelefono = TextEditingController();
  TimeOfDay? _desde;
  TimeOfDay? _hasta;
  final TextEditingController _controllerHorario = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();
  final EmpresaController empresaController = Get.put(EmpresaController());
  final EmpresaController controller = Get.put(EmpresaController());
  final TextEditingController textController = TextEditingController();

  // Estado de errores para cada campo
  Map<String, String> errorMessages = {
    'nombre': '',
    'rol': '',
    'celular': '',
    'telefono': '',
    'horario': '',
    'email': '',
    'empresas': '',
  };

  // Estado para controlar si el formulario ha sido enviado
  bool _formSubmitted = false;

  String quitarTildes(String texto) {
    const conTildes  = 'áéíóúÁÉÍÓÚñÑüÜ';
    const sinTildes = 'aeiouAEIOUnNuU';

    for (int i = 0; i < conTildes.length; i++) {
      texto = texto.replaceAll(conTildes[i], sinTildes[i]);
    }
    return texto;
  }

  @override
  void initState() {
    super.initState();
    con = Get.put(ContactoController(widget.entidad));
    controller.focusNode.addListener(() {
      controller.isFocused.value = controller.focusNode.hasFocus;
      if (!controller.focusNode.hasFocus) {
        controller.isDropdownOpen.value = false;
      }
    });

    // Inicializar los controladores con los valores del contacto
    _controllerNombre.text = widget.contacto.des != "" ? con.capitalizarNombre(widget.contacto.des) : formatPhoneNumber(widget.contacto.telefono);
    _controllerCelular.text = formatPhoneNumber(widget.contacto.telefono);
    _controllerEmail.text = widget.contacto.email ?? "";
    
    // Agregar listeners para validación en tiempo real
    _controllerNombre.addListener(() {
      if (_formSubmitted && _controllerNombre.text.trim().isNotEmpty) {
        setState(() {
          errorMessages['nombre'] = '';
        });
      }
    });
    
    _controllerRol.addListener(() {
      if (_formSubmitted && _controllerRol.text.trim().isNotEmpty) {
        setState(() {
          errorMessages['rol'] = '';
        });
      }
    });
    
    _controllerCelular.addListener(() {
      if (_formSubmitted && _controllerCelular.text.trim().isNotEmpty) {
        setState(() {
          errorMessages['celular'] = '';
        });
      }
    });

    _controllerTelefono.addListener(() {
      if (_formSubmitted && _controllerTelefono.text.trim().isNotEmpty) {
        setState(() {
          errorMessages['telefono'] = '';
        });
      }
    });
    
    _controllerEmail.addListener(() {
      if (_formSubmitted && _controllerEmail.text.trim().isNotEmpty) {
        setState(() {
          errorMessages['email'] = '';
        });
      }
    });
    
    _controllerHorario.addListener(() {
      if (_formSubmitted && _controllerHorario.text.trim().isNotEmpty) {
        setState(() {
          errorMessages['horario'] = '';
        });
      }
    });
  }

  @override
  void dispose() {
    // Limpiar los controladores cuando se destruya el widget
    _controllerNombre.dispose();
    _controllerRol.dispose();
    _controllerCelular.dispose();
    _controllerTelefono.dispose();
    _controllerHorario.dispose();
    _controllerEmail.dispose();
    super.dispose();
  }

  // Validar el formulario
  bool _validateForm() {
    bool isValid = true;
    setState(() {
      _formSubmitted = true;
      
      // Validar nombre
      /*if (_controllerNombre.text.trim().isEmpty) {
        errorMessages['nombre'] = 'Ingrese un nombre válido';
        isValid = false;
      } else {
        errorMessages['nombre'] = '';
      }*/
      
      // Validar rol
      /*if (_controllerRol.text.trim().isEmpty) {
        errorMessages['rol'] = 'Seleccione un rol';
        isValid = false;
      } else {
        errorMessages['rol'] = '';
      }*/
      
      // Validar celular
      if (_controllerCelular.text.trim().isEmpty) {
        errorMessages['celular'] = 'Ingrese un número de teléfono válido';
        isValid = false;
      } else {
        errorMessages['celular'] = '';
      }

      /*if (_controllerTelefono.text.trim().isEmpty) {
        errorMessages['telefono'] = 'Ingrese un número de teléfono válido';
        isValid = false;
      } else {
        errorMessages['telefono'] = '';
      }*/
      
      // Validar email (opcional si decides que este campo sea requerido)
      /*if (_controllerEmail.text.trim().isEmpty) {
        errorMessages['email'] = 'Ingrese un email válido';
        isValid = false;
      } else {
        errorMessages['email'] = '';
      }*/
      
      // Validar horario (opcional si decides que este campo sea requerido)
      /*if (_controllerHorario.text.trim().isEmpty) {
        errorMessages['horario'] = 'Seleccione un horario';
        isValid = false;
      } else {
        errorMessages['horario'] = '';
      }*/
      
      // Validar empresas
      /*if (controller.empresasSeleccionadas.isEmpty) {
        errorMessages['empresas'] = 'Seleccione mínimo una empresa';
        isValid = false;
      } else {
        errorMessages['empresas'] = '';
      }*/
    });
    
    return isValid;
  }

  String _formatearHorario(TimeOfDay time) {
    return time.format(context).replaceAll(':00', '');
  }

  Future<void> _seleccionarHorarios() async {
    final desde = await showTimePicker(
      context: context,
      initialTime: _desde ?? const TimeOfDay(hour: 7, minute: 0),
    );

    if (desde == null) return;

    final hasta = await showTimePicker(
      context: context,
      initialTime: _hasta ?? const TimeOfDay(hour: 18, minute: 0),
    );

    if (hasta == null) return;

    setState(() {
      _desde = desde;
      _hasta = hasta;
      _controllerHorario.text =
          '${_formatearHorario(_desde!)} a ${_formatearHorario(_hasta!)}hs';
      if (_formSubmitted) {
        errorMessages['horario'] = '';
      }
    });
  }
  
  String formatPhoneNumber(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length && i < 10; i++) {
      buffer.write(digits[i]);
      if (i == 2 || i == 5) {
        buffer.write(' ');
      }
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                DetalleContactoPage(contacto: widget.contacto, entidad: widget.entidad, pedido: widget.pedido),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(-1.0, 0.0);
              const end = Offset.zero;
              final tween = Tween(begin: begin, end: end)
                  .chain(CurveTween(curve: Curves.ease));
              return SlideTransition(position: animation.drive(tween), child: child);
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
        return false;
      },
      child: NotificationWrapper(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                // Botones superiores fijos
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context, true);                          
                        },
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.green,
                            color: Colors.green,
                            fontSize: MediaQuery.sizeOf(context).width * 0.04,
                          ),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          if (_validateForm()) {
                            con.registrarContacto(
                              context,
                              quitarTildes(_controllerNombre.text.toUpperCase()),
                              _controllerEmail.text,
                              _controllerCelular.text,
                              false,
                              widget.entidad,
                              widget.pedido,
                            );
                          }
                        },
                        child: Text(
                          'Guardar cambios',
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
        
                // Contenido scrolleable
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 201, 199, 199),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.person_rounded, size: 70, color: Colors.white),
                            ),
                            const SizedBox(width: 16),
                            _txtNombre(),
                          ],
                        ),
                        const SizedBox(height: 30),
                        _dropDownRol(),
                        const SizedBox(height: 30),
                        _numberCelular(),
                        const SizedBox(height: 30),
                        _numberTelefono(),
                        const SizedBox(height: 30),
                        _txtHorario(),
                        const SizedBox(height: 30),
                        _txtEmail(),
                        const SizedBox(height: 30),
                        _dropDownEmpresas(),
                        const SizedBox(height: 100), // Espacio para no tapar con el botón inferior
                      ],
                    ),
                  ),
                ),
        
                // Botón inferior fijo
                _btnEliminarContacto(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _btnEliminarContacto(BuildContext context) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () {
          NotificationHelper.showError(
            'Contacto eliminado',
            onUndo: () {
              setState(() {});
              NotificationHelper.showSuccess('Contacto restaurado');
            },
            onExpired: () {
              con.eliminarContacto(widget.contacto.id, widget.entidad);
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      BuscadorContactoPage(entidad: widget.entidad, pedido: widget.pedido),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(-1.0, 0.0);
                    const end = Offset.zero;
                    final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
                    return SlideTransition(position: animation.drive(tween), child: child);
                  },
                  transitionDuration: const Duration(milliseconds: 400),
                ),
              );
            },
          );
        },
        child: Container(
          height: 60,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            border: Border.all(color: CupertinoColors.destructiveRed),
          ),
          child: const Center(
            child: Text("Eliminar contacto", style: TextStyle(color: CupertinoColors.destructiveRed, fontSize: 20, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _txtNombre() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controllerNombre,
            keyboardType: TextInputType.name,
            maxLines: 1,
            decoration: const InputDecoration(
              labelText: 'Nombre',
              labelStyle: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
              floatingLabelStyle:  TextStyle(
                fontSize: 18,
                color: Colors.green,
              ),
              border:  UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 15, 105, 12))),
              contentPadding:  EdgeInsets.only(bottom: 0),
              hintStyle:  TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
              errorStyle:  TextStyle(height: 0), // Ocultar el mensaje de error predeterminado
            ),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          if (errorMessages['nombre']!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                errorMessages['nombre']!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _dropDownRol() {
    final List<String> roles = ['Contacto', 'Cliente', 'Personal'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          initialValue: _controllerRol.text.isEmpty ? null : _controllerRol.text,
          decoration: const InputDecoration(
            labelText: 'Rol',
            labelStyle: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
            floatingLabelStyle: TextStyle(
              fontSize: 18,
              color: Colors.green,
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 15, 105, 12)),
            ),
            contentPadding: EdgeInsets.only(bottom: 0),
            errorStyle: TextStyle(height: 0), // Ocultar el mensaje de error predeterminado
          ),
          icon: const Icon(CupertinoIcons.chevron_down),
          items: roles.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _controllerRol.text = newValue;
                if (_formSubmitted) {
                  errorMessages['rol'] = '';
                }
              });
            }
          },
          style: const TextStyle(
            fontSize: 20,
            color: Color(0xFF1A1A1A),
          ),
        ),
        if (errorMessages['rol']!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              errorMessages['rol']!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }

  Widget _numberCelular() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controllerCelular,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Celular (WhatsApp)',
            labelStyle: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
            floatingLabelStyle: TextStyle(
              fontSize: 18,
              color: Colors.green,
            ),
            counterText: "",
            border: UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 15, 105, 12))),
            contentPadding: EdgeInsets.only(bottom: 0),
            hintStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
            errorStyle: TextStyle(height: 0), // Ocultar el mensaje de error predeterminado
          ),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        if (errorMessages['celular']!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              errorMessages['celular']!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }

  Widget _numberTelefono() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controllerTelefono,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Teléfono',
            labelStyle: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
            floatingLabelStyle: TextStyle(
              fontSize: 18,
              color: Colors.green,
            ),
            counterText: "",
            border: UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 15, 105, 12))),
            contentPadding: EdgeInsets.only(bottom: 0),
            hintStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
            errorStyle: TextStyle(height: 0), // Ocultar el mensaje de error predeterminado
          ),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        if (errorMessages['telefono']!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              errorMessages['telefono']!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }

  Widget _txtHorario() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _controllerHorario,
          readOnly: true,
          onTap: _seleccionarHorarios,
          decoration: const InputDecoration(
            labelText: 'Horario',
            labelStyle: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
            floatingLabelStyle: TextStyle(
              fontSize: 18,
              color: Colors.green,
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 15, 105, 12)),
            ),
            contentPadding: EdgeInsets.only(bottom: 0),
            hintStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
            errorStyle: TextStyle(height: 0), // Ocultar el mensaje de error predeterminado
          ),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        if (errorMessages['horario']!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              errorMessages['horario']!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }

  Widget _txtEmail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controllerEmail,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            labelStyle: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
            floatingLabelStyle: TextStyle(
              fontSize: 18,
              color: Colors.green,
            ),
            border: UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 15, 105, 12))),
            contentPadding: EdgeInsets.only(bottom: 0),
            hintStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
            errorStyle: TextStyle(height: 0), // Ocultar el mensaje de error predeterminado
          ),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        if (errorMessages['email']!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              errorMessages['email']!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }

  Widget _dropDownEmpresas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Obx(() => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Empresas',
            style: TextStyle(
              fontSize: 14,
              color: controller.isFocused.value ? Colors.green : Colors.grey,
            ),
          ),
        )),
        
        // Chips seleccionadas
        Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: controller.empresasSeleccionadas.map((empresa) {
            return InputChip(
              label: Text(empresa, style: const TextStyle(fontSize: 16)),
              onDeleted: () {
                controller.quitarEmpresa(empresa);
                if (_formSubmitted && controller.empresasSeleccionadas.isEmpty) {
                  setState(() {
                    errorMessages['empresas'] = 'Seleccione mínimo una empresa';
                  });
                }
              },
              deleteIcon: const Icon(Icons.close, size: 18),
              backgroundColor: const Color.fromARGB(255, 247, 247, 247),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(
                  color: Color.fromARGB(255, 196, 196, 196),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            );
          }).toList(),
        )),

        // Campo de entrada
        Stack(
          alignment: Alignment.centerRight,
          children: [
            Obx(() => TextField(
              controller: textController,
              focusNode: controller.focusNode,
              onChanged: (value) {
                controller.searchText.value = value;
                controller.isDropdownOpen.value = true;
              },
              onTap: () {
                controller.isDropdownOpen.value = true;
              },
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  if (!controller.empresasDisponibles.contains(value)) {
                    controller.empresasDisponibles.add(value);
                  }
                  controller.agregarEmpresa(value);
                  textController.clear();
                  controller.searchText.value = '';
                  controller.isDropdownOpen.value = false;
                  
                  if (_formSubmitted) {
                    setState(() {
                      errorMessages['empresas'] = '';
                    });
                  }
                }
              },
              decoration: InputDecoration(
                hintText: controller.empresasSeleccionadas.isEmpty ? '' : null,
                border: const UnderlineInputBorder(),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.green, width: 2),
                ),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                contentPadding: const EdgeInsets.only(bottom: 8, right: 40),
              ),
              style: const TextStyle(fontSize: 16),
            )),

            // Icono
            Obx(() => IconButton(
              icon: Icon(
                controller.searchText.value.isEmpty && !controller.isDropdownOpen.value
                    ? Icons.add
                    : CupertinoIcons.chevron_up,
                color: Colors.grey,
                size: controller.searchText.value.isEmpty ? 24 : 18,
              ),
              onPressed: () {
                if (!controller.focusNode.hasFocus) {
                  controller.focusNode.requestFocus();
                }
                controller.isDropdownOpen.value = true;
              },
            )),
          ],
        ),

        // Mensaje de error para empresas
        if (errorMessages['empresas']!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              errorMessages['empresas']!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ),

        // Opciones desplegables
        Obx(() {
          final options = controller.filteredEmpresas;
          if (!controller.isDropdownOpen.value) return const SizedBox.shrink();

          return Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true, // importante para que el ListView no expanda infinito
              physics: const NeverScrollableScrollPhysics(), // desactiva scroll
              itemCount: options.length + (controller.searchText.value.isNotEmpty ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < options.length) {
                  final option = options[index];
                  return ListTile(
                    dense: true,
                    title: Text(option, style: const TextStyle(fontSize: 16)),
                    onTap: () {
                      controller.agregarEmpresa(option);
                      textController.clear();
                      controller.searchText.value = '';
                      controller.isDropdownOpen.value = false;
                      
                      if (_formSubmitted) {
                        setState(() {
                          errorMessages['empresas'] = '';
                        });
                      }
                    },
                  );
                } else {
                  // Agregar nueva opción
                  return ListTile(
                    dense: true,
                    title: Text.rich(TextSpan(children: [
                      const TextSpan(text: 'Agregar "', style: TextStyle(color: Colors.green)),
                      TextSpan(
                        text: controller.searchText.value,
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: '"', style: TextStyle(color: Colors.green)),
                    ])),
                    onTap: () {
                      final value = controller.searchText.value;
                      if (value.isNotEmpty) {
                        if (!controller.empresasDisponibles.contains(value)) {
                          controller.empresasDisponibles.add(value);
                        }
                        controller.agregarEmpresa(value);
                        textController.clear();
                        controller.searchText.value = '';
                        controller.isDropdownOpen.value = false;
                        
                        if (_formSubmitted) {
                          setState(() {
                            errorMessages['empresas'] = '';
                          });
                        }
                      }
                    },
                  );
                }
              },
            ),
          );
        }),
      ],
    );
  }

}

class EmpresaController extends GetxController {
  var empresasDisponibles = <String>[
    'Diarco',
    'Almacor',
    'Libertad',
    'SuperMami',
    'Construluz',
    'Ferrocons',
    'Consanti',
    'Coniferal'
  ].obs;

  var empresasSeleccionadas = <String>[].obs;
  var searchText = ''.obs;
  var isDropdownOpen = false.obs;
  var focusNode = FocusNode();

  var isFocused = false.obs;

  @override
  void onInit() {
    super.onInit();
    focusNode.addListener(_onFocusChange);
  }

  @override
  void onClose() {
    focusNode.removeListener(_onFocusChange);
    focusNode.dispose();
    super.onClose();
  }

  void _onFocusChange() {
    isDropdownOpen.value = focusNode.hasFocus;
  }

  void agregarEmpresa(String empresa) {
    if (!empresasSeleccionadas.contains(empresa) && empresa.isNotEmpty) {
      empresasSeleccionadas.add(empresa);
      searchText.value = '';
    }
  }

  void quitarEmpresa(String empresa) {
    empresasSeleccionadas.remove(empresa);
  }

  List<String> get filteredEmpresas {
    final allFiltered = empresasDisponibles
        .where((empresa) => !empresasSeleccionadas.contains(empresa))
        .toList();

    if (searchText.value.isEmpty) {
      return allFiltered;
    }

    return allFiltered
        .where((empresa) =>
            empresa.toLowerCase().contains(searchText.value.toLowerCase()))
        .toList();
  }
}
