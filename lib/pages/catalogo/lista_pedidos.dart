import 'package:flutter_svg/svg.dart';
import 'package:vientri/pages/catalogo/carrito_page.dart';
import 'package:vientri/src/models/pedido.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vientri/components/badge/badge.dart';
import 'package:vientri/components/heading/heading.dart';
import 'package:intl/intl.dart';
import 'package:vientri/components/listed_element/listed_element.dart';
import 'package:vientri/components/subtle_button/subtle_button.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/constants/app_shadows.dart';
import 'package:vientri/pages/controller.dart';
import 'package:vientri/pages/comunes/login/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:vientri/pages/catalogo/rubros_page.dart';
import 'package:vientri/src/models/entidad.dart';

// ignore: must_be_immutable
class ListaPedidos extends StatefulWidget {
  Entidad entidad;
  Pedido? pedido;
  ListaPedidos({super.key, required this.entidad, this.pedido});

  @override
  State<ListaPedidos> createState() => _ListaPedidosState();
}

class _ListaPedidosState extends State<ListaPedidos> {
  final LoginController con = LoginController();
  late Controller cont;
  late Future<List<Pedido>> _futurePedidos;
  int cant = 10;
  final List<String> opciones = ["5", "10", "20", "50", "todos"];
  bool _isExpanded = false;
  
  String formatearFecha(String fechaStr) {
    // Separar año, mes y día
    final partes = fechaStr.split('-');
    if (partes.length != 3) return fechaStr;

    final year = int.tryParse(partes[0]);
    final month = int.tryParse(partes[1]);
    final day = int.tryParse(partes[2]);

    if (year == null || month == null || day == null) return fechaStr;

    final fecha = DateTime(year, month, day);

    final hoy = DateTime.now();
    final ayer = hoy.subtract(const Duration(days: 1));

    final fechaSolo = DateTime(fecha.year, fecha.month, fecha.day);
    final hoySolo = DateTime(hoy.year, hoy.month, hoy.day);
    final ayerSolo = DateTime(ayer.year, ayer.month, ayer.day);

    if (fechaSolo == hoySolo) {
      return 'Hoy';
    } else if (fechaSolo == ayerSolo) {
      return 'Ayer';
    } else {
      return DateFormat('d MMM. yyyy', 'es_ES').format(fecha);
    }
  }
    
  @override
  void initState() {
    super.initState();
    cont = Get.put(Controller(widget.entidad));
    _futurePedidos = cont.listaPedidos();
  }

  void _recargar() {
    setState(() {
      _futurePedidos = cont.listaPedidos();
    });
  }

  Future<void> _pullToRefresh() async {
    _recargar();
    await _futurePedidos;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFF0E4FF),
                    Color(0xFFF5F5F5),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context, true),
                          child: const Icon(
                            Icons.arrow_back,
                            size: 26,
                          ),
                        ),

                        GestureDetector(
                          onTap: () => cont.screenPermisos(context, widget.entidad, "Permisos", 2),
                          child: SvgPicture.asset("assets/key.svg", width: 30, height: 30),
                        )
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AppHeading(
                    label: "Pedidos",
                    fontSize: Fontsize.h1,
                    trailingIcon: Icons.add_rounded,
                    iconSize: 32,
                    onTrailingIconPressed: () {
                      GetStorage().remove("contacto");

                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => RubroPage(entidad: widget.entidad, pedido: Pedido(id: 0, idUsr: -1, detalle: [], namePer: '', idPer: -1, idContactoPer: -1, nameContacto: '', nameUsr: '', estado: 'EN CURSO', estadoId: 0, fecha: '', total: 0, pdto: 0, telefono: '', items: 0)),
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
                      ).then((value) {
                        if (value == true) {
                          setState(() {
                            _recargar();
                          });
                        }
                      });
                    },
                  ),
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _pullToRefresh,
                    child: FutureBuilder<List<Pedido>>(
                      future: _futurePedidos,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        final errorText = snapshot.error.toString();
    
                        // Detectar error de conexión VIENTRI
                        final isConnectionError = errorText.contains("ClientException with SocketException") &&
                                                  errorText.contains("net.vientri.com");
                        final headerText = isConnectionError
                            ? "Error de conexión: se recomienda avisar a VIENTRI"
                            : "Error";
    
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 42),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                                  border: Border.all(color: Colors.black12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () => setState(() => _isExpanded = !_isExpanded),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              headerText,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            _isExpanded ? Icons.expand_less : Icons.expand_more,
                                            size: 24,
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (_isExpanded) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        errorText,
                                        style: TextStyle(
                                          color: AppColors.semantics.text.secondary,
                                          fontSize: Fontsize.h3,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              SubtleButton(
                                text: "Volver a cargar",
                                onPressed: _recargar,
                              ),
                            ],
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text("No hay pedidos"));
                      }
                            
                        final pedidos = snapshot.data!;
                                  
                        final vigentes = pedidos
                            .where((p) => p.estado.toUpperCase() == "EN CURSO")
                            .toList()
                          ..sort((a, b) => b.id.compareTo(a.id));
                                  
                        final anteriores = pedidos
                            .where((p) => p.estado.toUpperCase() != "EN CURSO")
                            .toList()
                          ..sort((a, b) => b.id.compareTo(a.id));
                                  
                        final anterioresLimitados = anteriores.take(cant).toList();
                                  
                        return ListView(
                          padding: const EdgeInsets.all(0),
                          physics: const ClampingScrollPhysics(),
                          children: [
                            vigentes.isNotEmpty
                              ? Container(
                                margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                                padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.semantics.border.action),
                                  boxShadow: AppShadows.elementFocusShadow,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          CupertinoIcons.info_circle,
                                          size: 28,
                                          color: AppColors.semantics.border.action,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Vigentes",
                                          style: TextStyle(
                                            color: AppColors.semantics.text.body,
                                            fontSize: Fontsize.h2,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    ...vigentes.map((v) => InkWell(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation, secondaryAnimation) => RubroPage(entidad: widget.entidad, pedido: v),
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
                                        ).then((value) {
                                          if (value == true) {
                                            setState(() {
                                              _recargar();
                                            });
                                          }
                                        });
                                      },
                                      child: ListedElement(
                                        column1Content: ListedElementDoubleTextContent(
                                          topText: v.nameContacto != ""
                                            ? v.nameContacto
                                            : v.telefono,
                                          bottomText: v.telefono
                                        ),
                                        column2Content: ListedElementTextContent(
                                          text: v.items == 1
                                            ? "${v.items} Art."
                                            : "${v.items} Arts.",
                                        ),
                                        column3Content: ListedElementBadgeContent(
                                          text: v.estado.toUpperCase() == "EN CURSO"
                                            ? "En curso"
                                            : "Sin determinar",
                                          type: v.estado.toUpperCase() == "EN CURSO"
                                            ? AppBadgeType.action
                                            : AppBadgeType.information
                                        ),
                                      ),
                                    )
                                  ),
                                ],
                              ),
                            )
                            : Container(
                              margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                              padding: const EdgeInsets.all(16),
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
                              child: Column(
                                children: [
                                  const AppHeading(label: "Vigentes", fontSize: Fontsize.h2),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    child: Text(
                                      "No hay envíos vigentes",
                                      style: TextStyle(
                                        color: AppColors.semantics.text.secondary,
                                        fontSize: Fontsize.h3
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ),
                            
                            if (anteriores.isNotEmpty)
                            Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                                  padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
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
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Anteriores",
                                            style: TextStyle(
                                              color: AppColors.semantics.text.body,
                                              fontSize: Fontsize.h2,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "Mostrar: ",
                                                style: TextStyle(
                                                  color: AppColors.semantics.text.secondary,
                                                  fontSize: Fontsize.body
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              DropdownButton<String>(
                                                value: cant == 99999 ? "todos" : cant.toString(),
                                                items: opciones.map((opcion) {
                                                  return DropdownMenuItem<String>(
                                                    value: opcion,
                                                    child: Text(opcion),
                                                  );
                                                }).toList(),
                                                onChanged: (value) {
                                                  setState(() {
                                                    if (value == "todos") {
                                                      cant = 99999;
                                                    } else {
                                                      cant = int.parse(value!);
                                                    }
                                                  });
                                                },
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      ...anterioresLimitados.map((a) => InkWell(
                                        onTap: () {
                                          if (a.estado.toLowerCase() != "cancelado" ) {
                                            Navigator.of(context).push(
                                              PageRouteBuilder(
                                                pageBuilder: (context, animation, secondaryAnimation) => CarritoPage(entidad: widget.entidad, pedido: a),
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
                                            ).then((value) {
                                              if (value == true) {
                                                setState(() {
                                                  _recargar();
                                                });
                                              }
                                            });
                                          } else {
                                            null;
                                          }
                                        },
                                        child: ListedElement(
                                          column1Content: ListedElementDoubleTextContent(
                                            topText:  a.nameContacto != ""
                                            ? a.nameContacto
                                            : a.telefono,
                                            bottomText: a.telefono
                                          ),
                                          column2Content: ListedElementTextContent(
                                            text: a.items == 1
                                              ? "${a.items} Art."
                                              : "${a.items} Arts.",
                                          ),
                                          column3Content: ListedElementBadgeContent(
                                            text: a.estado.toUpperCase() == "EN CAJA"
                                              ? "En caja"
                                              : a.estado.toUpperCase() == "COBRADO"
                                                ? "Cobrado"
                                                : "S/D",
                                            type: a.estado.toUpperCase() == "EN CAJA" || a.estado.toUpperCase() == "COBRADO"
                                              ? AppBadgeType.success
                                              : AppBadgeType.information,
                                          ),
                                        ),
                                      )),
                                    ],
                                  ),
                                ),
                              
                                const SizedBox(height: 8),
                        
                                anteriores.length > 10

                                ? anteriores.length < cant 
                                  ? Center(
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          cant = 10;
                                        });
                                      },
                                      child: Text(
                                        "Ver menos",
                                        style: TextStyle(
                                          color: AppColors.semantics.text.action,
                                          fontSize: Fontsize.h3
                                        ),
                                      ),
                                    ),
                                  )
                                  : Center(
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          cant += 10;
                                        });
                                      },
                                      child: Text(
                                        "Ver más",
                                        style: TextStyle(
                                          color: AppColors.semantics.text.action,
                                          fontSize: Fontsize.h3
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox(),
                                const SizedBox(height: 64),
                        
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                )
              ]
            )
          ]
        )
      )
    );
  }
  

}