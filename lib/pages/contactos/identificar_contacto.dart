import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vientri/components/heading/heading.dart';
import 'package:vientri/components/solid_button/solid_button.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/constants/app_shadows.dart';
import 'package:vientri/pages/contactos/nuevo_contacto.dart';
import 'package:vientri/pages/controller.dart';
import 'package:flutter/material.dart';
import 'package:vientri/src/models/contacto.dart';
import 'package:vientri/src/models/entidad.dart';

// ignore: must_be_immutable
class IdentificarContacto extends StatefulWidget {
  final Entidad entidad;
  const IdentificarContacto({super.key, required this.entidad});

  @override
  State<IdentificarContacto> createState() => _IdentificarContactoState();
}

class _IdentificarContactoState extends State<IdentificarContacto> {
  late Controller con;
  String selectedFilter = 'Nombre';
  bool checked = false;
  String? _numeroCompleto;
  final String _prefijo = "*** *** ";
  var equis = false.obs;
  bool numeroValido = false;

  final box = GetStorage();
  final String cacheKey = "contactosGuardados";

  final TextEditingController _controllerNombre = TextEditingController();
  final TextEditingController _controllerCelular = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final FocusNode _focusNodeNombre = FocusNode();

  final RxBool isPressed = false.obs;
  final RxString pressedKey = ''.obs;

  @override
  void initState() {
    super.initState();
    con = Get.put(Controller(widget.entidad));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });

    Future.delayed(Duration(milliseconds: 300), () {
        _focusNodeNombre.requestFocus();
      });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _focusNodeNombre.dispose();
    _controllerCelular.dispose();
    _controllerNombre.dispose();
    super.dispose();
  }

  void _onKeyTap(BuildContext context, String value) {
    if (value == '⌫') {
      if (_controllerCelular.text.isEmpty) return;
      setState(() {
        numeroValido = false;
      });
      // Si está el check y hay prefijo, no borrar el prefijo
      if (checked && _controllerCelular.text.startsWith(_prefijo)) {
        final sinPrefijo =
            _controllerCelular.text.substring(_prefijo.length);
        if (sinPrefijo.isNotEmpty) {
          _controllerCelular.text =
              _prefijo + sinPrefijo.substring(0, sinPrefijo.length - 1);
        }

        setState(() {});
        return;
      }

      // Si no hay prefijo
      if (_controllerCelular.text.isNotEmpty) {
        _controllerCelular.text = _controllerCelular.text
            .substring(0, _controllerCelular.text.length - 1);
      }
    } else {
      if (!checked && _controllerCelular.text.replaceAll("*** *** ", "").length == 9) {
        numeroValido = true;
        setState(() {});
      } else if (_controllerCelular.text.replaceAll("*** *** ", "").length == 3) {
        numeroValido = true;
        setState(() {});
      }

      if (!RegExp(r'^[0-9]$').hasMatch(value)) return;

      final currentText = _controllerCelular.text;
      String sinPrefijo = checked && currentText.startsWith(_prefijo)
          ? currentText.substring(_prefijo.length)
          : currentText;

      final maxLength = checked ? 4 : 10;
      if (sinPrefijo.length >= maxLength) return;

      sinPrefijo += value;

      _controllerCelular.text = checked ? "$_prefijo$sinPrefijo" : sinPrefijo;
      setState(() {});
    }

    _controllerCelular.selection = TextSelection.fromPosition(
      TextPosition(offset: _controllerCelular.text.length),
    );
  }

  Future<List<Contacto>> _buscarContactos(String telefono) async {
    if (telefono.isEmpty) return [];

    final datosCache = box.read(cacheKey);
    List<Contacto> contactosLocales = [];
    if (datosCache != null && datosCache.isNotEmpty) {
      contactosLocales = Contacto.fromJsonList(
        List<Map<String, dynamic>>.from(datosCache),
      );
    }

    final coincidenciasLocales = contactosLocales.where((c) {
      if (c.telefono == "") return false;
      final tel = c.telefono.replaceAll(RegExp(r'\D'), '');
      return checked ? tel.endsWith(telefono) : tel.contains(telefono);
    }).toList();

    if (coincidenciasLocales.isNotEmpty) return coincidenciasLocales;

    final contactosRemotos = await con.listaContactos();

    await box.write(cacheKey, contactosRemotos.map((c) => c.toJson()).toList());

    final coincidenciasRemotas = contactosRemotos.where((c) {
      if (c.telefono == "") return false;
      final tel = c.telefono.replaceAll(RegExp(r'\D'), '');
      return checked ? tel.endsWith(telefono) : tel.contains(telefono);
    }).toList();

    return coincidenciasRemotas;
  }

  Future<List<Contacto>> _buscarContactosNombre(String nombre) async {
    if (nombre.isEmpty) return [];

    final datosCache = box.read(cacheKey);
    List<Contacto> contactosLocales = [];
    if (datosCache != null && datosCache.isNotEmpty) {
      contactosLocales = Contacto.fromJsonList(
        List<Map<String, dynamic>>.from(datosCache),
      );
    }

    final coincidenciasLocales = contactosLocales.where((c) {
      if (c.des == "") return false;
      return c.des.toLowerCase().contains(nombre.toLowerCase());
    }).toList();

    if (coincidenciasLocales.isNotEmpty) return coincidenciasLocales;

    final contactosRemotos = await con.listaContactos();

    await box.write(cacheKey, contactosRemotos.map((c) => c.toJson()).toList());

    final coincidenciasRemotas = contactosRemotos.where((c) {
      if (c.des == "") return false;
      return c.des.contains(nombre);
    }).toList();

    return coincidenciasRemotas;
  }

  List<TextSpan> _resaltarCoincidencia(String texto, String busqueda, bool ultimos4) {
    final textoPlano = texto.replaceAll(RegExp(r'[^0-9]'), '');

    if (busqueda.isEmpty || !textoPlano.contains(busqueda)) {
      return [TextSpan(text: texto)];
    }

    int index;
    if (ultimos4) {
      index = textoPlano.lastIndexOf(busqueda);
    } else {
      index = textoPlano.indexOf(busqueda);
    }

    if (index == -1) return [TextSpan(text: texto)];

    int count = 0;
    int matchStart = -1;
    int matchEnd = -1;

    for (int i = 0; i < texto.length; i++) {
      if (RegExp(r'\d').hasMatch(texto[i])) {
        if (count == index) matchStart = i;
        if (count == index + busqueda.length - 1) {
          matchEnd = i;
          break;
        }
        count++;
      }
    }

    if (matchStart == -1 || matchEnd == -1) {
      return [TextSpan(text: texto)];
    }

    return [
      TextSpan(text: texto.substring(0, matchStart)),
      TextSpan(
        text: texto.substring(matchStart, matchEnd + 1),
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black45),
      ),
      TextSpan(text: texto.substring(matchEnd + 1)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                    label: "Identificar contacto según",
                    fontSize: Fontsize.h1,
                    leadingIcon: Icons.arrow_back,
                    onLeadingIconPressed: () => Navigator.pop(context, true),
                  ),
                ),
              ),
    
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 16, right: 16),
                child: Wrap(
                  spacing: 8,
                  children: ["Nombre", "Celular"].map((filtro) {
                    final selected = filtro == selectedFilter;
                    return Theme(
                      data: Theme.of(context).copyWith(
                        chipTheme: Theme.of(context).chipTheme.copyWith(
                          side: BorderSide.none,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: ChoiceChip(
                          label: Text(
                            filtro,
                            style: TextStyle(
                              color: selected ? Colors.white : AppColors.semantics.text.body,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          selected: selected,
                          onSelected: (_) {
                            setState(() {
                              selectedFilter = filtro;

                              if (selectedFilter == "Celular") {
                                FocusScope.of(context).unfocus();

                                Future.delayed(const Duration(milliseconds: 200), () {
                                  if (mounted) {
                                    FocusScope.of(context).requestFocus(_focusNode);
                                  }
                                }); 
                              } else if (selectedFilter == "Nombre") {
                                Future.delayed(const Duration(milliseconds: 200), () {
                                  if (mounted) {
                                    FocusScope.of(context).requestFocus(_focusNodeNombre);
                                  }
                                });
                              }
                            });
                          },
                          selectedColor: AppColors.semantics.surface.action,
                          backgroundColor: AppColors.semantics.surface.disabled,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide.none,
                          ),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
    
              if (selectedFilter == "Nombre")
              _buildSearchBar(),

              if (selectedFilter == "Nombre")
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        flex: 3,
                        child: _buildSugerencias()
                      ),
                  
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: SolidButton(
                          text: "Agregar “${selectedFilter == "Celular" ? _controllerCelular.text : _controllerNombre.text}”",
                          leftIcon: Icons.person_add_rounded,
                          type: SolidButtonType.primary,
                          onPressed: _controllerNombre.text != ""
                          ? () {
                            _irNuevoContacto();
                          }
                          : null
                        ),
                      ),
                  
                    ],
                  ),
                ),
              ),
              
              if (selectedFilter == "Celular")
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      checked = !checked;
    
                      final textoActual = _controllerCelular.text.replaceAll(_prefijo, "");
    
                      if (checked) {
                        _numeroCompleto = textoActual;
                        String ultimos4 = textoActual.length > 4
                            ? textoActual.substring(textoActual.length - 4)
                            : textoActual;
                        _controllerCelular.text = "$_prefijo$ultimos4";
                      } else {
                        if (_numeroCompleto != null) {
                          _controllerCelular.text = _numeroCompleto!;
                        } else {
                          _controllerCelular.text = textoActual; 
                        }
                        _numeroCompleto = null; 
                      }
    
                      _controllerCelular.selection = TextSelection.fromPosition(
                        TextPosition(offset: _controllerCelular.text.length),
                      );
    
                      FocusScope.of(context).requestFocus(_focusNode);
       
                      numeroValido = false;
                      if (!checked && _controllerCelular.text.replaceAll("*** *** ", "").length == 10) {
                        numeroValido = true;
                      } else if (_controllerCelular.text.replaceAll("*** *** ", "").length == 4) {
                        numeroValido = true;
                      }
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: checked ? AppColors.semantics.surface.action : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: checked ? AppColors.semantics.surface.action : Colors.black12,
                            width: 1,
                          ),
                        ),
                        child: checked
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: Fontsize.body,
                            )
                          : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Últimos 4 dígitos del celular",
                        style: TextStyle(
                          color: AppColors.semantics.text.body,
                          fontSize: Fontsize.body,
                        ),
                      ),
                    ],
                  ),
                )
              ),
    
              if (selectedFilter == "Celular")
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _controllerCelular,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.number,
                  cursorHeight: 60,
                  readOnly: true,
                  showCursor: true,
                  cursorWidth: 3,
                  cursorColor: AppColors.semantics.text.body,
                  style: TextStyle(
                    fontSize: 50,
                    color: AppColors.semantics.text.body
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    _controllerCelular.text = value;
                  },
                )
              ),

              if (selectedFilter == "Celular")
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (selectedFilter == "Celular")
                    Flexible(
                      flex: 3,
                      fit: FlexFit.loose,
                      child: FutureBuilder<List<Contacto>>(
                        future: _buscarContactos(_controllerCelular.text.replaceAll(_prefijo, "")),
                        builder: (context, snapshot) {
                          if (selectedFilter != "Celular" || _controllerCelular.text.isEmpty) {
                            return const SizedBox.shrink();
                          }
                        
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                        
                          if (snapshot.hasError) {
                            return Center(child: Text("Error: ${snapshot.error}"));
                          }
                        
                          final contactos = snapshot.data ?? [];
                        
                          if (contactos.isEmpty) {
                            return const Center(child: Text("No se encontraron contactos."));
                          }
                        
                          return Container(
                            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const ClampingScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: contactos.length,
                              itemBuilder: (context, index) {
                                final contacto = contactos[index];
                                return Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  margin: const EdgeInsets.symmetric(horizontal: 16),
                                  decoration: const BoxDecoration(
                                    border: Border(bottom: BorderSide(color: Colors.black12))
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 4,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              contacto.des.trim() == "" ? "Sin nombre" : con.capitalizar(contacto.des),
                                              style: TextStyle(
                                                color: AppColors.semantics.text.body,
                                                fontSize: Fontsize.h3,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              maxLines: 1,
                                            ),
                                            RichText(
                                              text: TextSpan(
                                                children: _resaltarCoincidencia(
                                                  con.telefonoFormateado(contacto.telefono),
                                                  _controllerCelular.text.replaceAll(RegExp(r'\D'), ''), // lo que escribe el usuario
                                                  checked,
                                                ),
                                                style: TextStyle(
                                                  color: AppColors.semantics.text.secondary,
                                                  fontSize: Fontsize.h3,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          con.capitalizar(contacto.nomCliente ?? ""),
                                          style: TextStyle(
                                            color: AppColors.semantics.text.secondary,
                                            fontSize: Fontsize.body,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          maxLines: 2,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Icon(
                                          Icons.info_outlined,
                                          color: AppColors.semantics.text.action,
                                        )
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                
                    Column(
                      children: [
                        if (selectedFilter == "Celular")
                        Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                          child: SolidButton(
                            text: "Agregar “${_controllerCelular.text}”",
                            leftIcon: Icons.person_add_rounded,
                            type: SolidButtonType.primary,
                            onPressed: checked 
                            ? _controllerCelular.text.replaceAll("*", "").replaceAll(" ", "").length == 4
                              ? () {
                                _irNuevoContacto();
                              }
                              : null
                            : _controllerCelular.text.replaceAll("*", "").replaceAll(" ", "").length == 10
                              ? () {
                                _irNuevoContacto();
                              }
                              : null
                          ),
                        ),
                        if (selectedFilter == "Celular")
                        _teclado(),
                      ],
                    ),
                  ],
                ),
              ),
    
            ],
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

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.semantics.text.action),
        boxShadow: AppShadows.elementFocusShadow,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            size: 20,
            color: Colors.grey.shade500,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onSubmitted: (value) {},
              focusNode: _focusNodeNombre,
              controller: _controllerNombre,
              onChanged: (value) => {
                if (value != "") {
                  equis.value = true,
                  setState(() {
                    _controllerNombre.text = value;
                  })
                } else {
                  equis.value = false,
                  setState(() {
                    _controllerNombre.text = value;
                  })
                }
              },
              decoration: InputDecoration(
                hintText: "Buscar",
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                isDense: true,
              ),
            ),
          ),
          if (equis.value)
          GestureDetector(
            onTap: () {
              _controllerNombre.clear();
              equis.value = false;
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSugerencias() {
    return FutureBuilder<List<Contacto>>(
      future: _buscarContactosNombre(_controllerNombre.text),
      builder: (context, snapshot) {
        if (selectedFilter != "Nombre" || _controllerNombre.text.isEmpty) {
          return const SizedBox.shrink();
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final contactos = snapshot.data ?? [];

        if (contactos.isEmpty) {
          return const Center(child: Text("No se encontraron contactos."));
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
              boxShadow: AppShadows.containerShadow,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: contactos.length,
              itemBuilder: (context, index) {
                final contacto = contactos[index];
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.black12))
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  contacto.des.trim() == "" ? "Sin nombre" : con.capitalizar(contacto.des),
                                  style: TextStyle(
                                    color: AppColors.semantics.text.body,
                                    fontSize: Fontsize.h3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  maxLines: 1,
                                ),
                                Text(
                                  con.telefonoFormateado(contacto.telefono),
                                  style: TextStyle(
                                    color: AppColors.semantics.text.secondary,
                                    fontSize: Fontsize.h3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            flex: 2,
                            child: Text(
                              con.capitalizar(contacto.nomCliente ?? ""),
                              style: TextStyle(
                                color: AppColors.semantics.text.secondary,
                                fontSize: Fontsize.body,
                                overflow: TextOverflow.ellipsis,
                              ),
                              maxLines: 2,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Icon(
                              Icons.info_outlined,
                              color: AppColors.semantics.text.action,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _irNuevoContacto() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => NuevoContacto(entidad: widget.entidad, nombre: _controllerNombre.text, celular: _controllerCelular.text),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

}
