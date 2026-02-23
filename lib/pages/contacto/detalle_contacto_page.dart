import 'package:vientri/pages/contacto/buscador_contacto_page.dart';
import 'package:vientri/pages/contacto/contacto_controller.dart';
import 'package:vientri/pages/contacto/editar_contacto_page.dart';
import 'package:vientri/src/models/contacto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vientri/src/models/entidad.dart';
import 'package:vientri/src/models/pedido.dart';


// ignore: must_be_immutable
class DetalleContactoPage extends StatefulWidget {
  Entidad entidad;
  final Contacto contacto;
  Pedido pedido;

  DetalleContactoPage({super.key, required this.contacto, required this.entidad, required this.pedido});

  @override
  State<DetalleContactoPage> createState() => _DetalleContactoPageState();
}

class _DetalleContactoPageState extends State<DetalleContactoPage> {
  late ContactoController con;
  var selectedIndex = 0.obs;
  final Color headerColor = const Color(0xFF4CAF50);
  final ScrollController _scrollController = ScrollController();
  final RxBool _showShadow = false.obs;
  var id = 0.obs;
  List<Map<String, dynamic>> _articulos = [];

  void buscarIdUltCompra() async {
    id.value = await con.detalleContacto(widget.contacto.id, widget.entidad);
  }

  void cargarCompras() async {
    // 2870943 id.value
    final compras = await con.ultCompras(id.value, widget.entidad);
    setState(() {
      _articulos = compras;
    });
  }

  @override
  void initState() {
    super.initState();
    con = Get.put(ContactoController(widget.entidad));
    _scrollController.addListener(() {
      _showShadow.value = _scrollController.offset > 0;
    });
    buscarIdUltCompra(); 
    cargarCompras();
  }

  String formatPhoneNumber(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), ''); // Solo números
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
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BuscadorContactoPage(entidad: widget.entidad, pedido: widget.pedido),
          ),
        );
        return false;
      },
      child: Obx(() => Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
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
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => EditarContactoPage(entidad: widget.entidad, contacto: widget.contacto, pedido: widget.pedido),
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
                            });
                          }
                        });
                      },
                      child: Text(
                        'Editar',
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
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
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
                    Expanded(
                      child: Text(
                        (widget.contacto.des == "") 
                          ? formatPhoneNumber(widget.contacto.telefono)
                          : con.capitalizarNombre(widget.contacto.des),
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              _switch(),
              const SizedBox(height: 24),
              selectedIndex.value == 1
              ? _articulos.isNotEmpty
                ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Artículos de la última compra',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: headerColor,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildColumnHeader('Últ.\ncompra\n(\$monto)', headerColor),
                            _buildColumnHeader('Últ. 3\nmeses\n(\$monto)', headerColor),
                            _buildColumnHeader('Últ. 6\nmeses\n(\$monto)', headerColor),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                : const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text("Aún no hay compras", style: TextStyle(color: Colors.black87, fontSize: 28, fontWeight: FontWeight.bold)),
                )
              : const SizedBox(),
              Expanded(
                child: selectedIndex.value == 0 
                ? _contacto()
                : _compras(),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _infoRow(String label1, String value1, String label2, String value2) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 180, child: _buildInfoItem(label1, value1)),
          _buildInfoItem(label2, value2),
        ],
      ),
    );
  }

  Widget _infoRowDoble(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildInfoItem(label, value)),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 4),
        label != "Celular"
        ? label != "Empresas" 
          ? Text(
              value.isEmpty ? '--' : value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            )
          : value == "Cliente Sd"
            ? Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            )
          : Text.rich(
              TextSpan(children: buildEmpresaSpans(value)),
            )
        : GestureDetector(
          onTap: () {
            con.enviarMensajeWhatsApp(value, "");
          },
          child: Row(
            children: [
              SvgPicture.asset("assets/whatsapp.svg", width: 22, height: 22,),
              const SizedBox(width: 5),
              Text(
                value.isEmpty ? '--' : value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.green,
                  color: Colors.green,
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _switch() {
    return Obx(() => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 35,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOption("Contacto", 0),
            _buildOption("Última compra", 1),
          ],
        ),
      ),
    ));
  }

  Widget _buildOption(String text, int index) {
    final isSelected = selectedIndex.value == index;
    return GestureDetector(
      onTap: () {
        selectedIndex.value = index;
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
            color: isSelected ? Colors.green : Colors.black54,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _contacto() {
    return Column(children: [
      _infoRow('ID', widget.contacto.id.toString(), 'Rol', 'Contacto'),
      const SizedBox(height: 20),
      _infoRowDoble('Empresas', con.capitalizarNombre(widget.contacto.nomCliente ?? "")),
      const SizedBox(height: 20),
      _infoRow('Celular', formatPhoneNumber(widget.contacto.telefono), 'Teléfono', ""),
      const SizedBox(height: 20),
      _infoRowDoble('Email', widget.contacto.email ?? ""),
      const SizedBox(height: 20),
      _infoRowDoble('Horario', widget.contacto.horario ?? ""),
      const SizedBox(height: 20),
      _infoRow('Última compra', "dd Month yyyy", 'Monto', "\$--"),
    ]);
  }

  Widget _compras() {
    final List<Map<String, dynamic>> articulos = _articulos;
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: articulos.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: Colors.grey.shade300,
                ),
                itemBuilder: (context, index) {
                  final item = articulos[index];
                  return _buildListItem(item);
                },
              ),
            ),
          ],
        ),
        Obx(() => AnimatedOpacity(
              opacity: _showShadow.value ? 0.3 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                height: 20,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromARGB(157, 138, 138, 138),
                      Color.fromARGB(0, 255, 255, 255),
                    ],
                  ),
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildColumnHeader(String text, Color color) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color,
      ),
    );
  }

  Widget _buildListItem(Map<String, dynamic> article) {
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${article["nombre"]} | ${article["marca"]}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '#${article["id"]} | ${article["descripcion"]}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Purchase data (right side)
          Expanded(
            flex: 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDataValue(article["ultimacompra"].toString()),
                _buildDataValue(article["ultimos3meses"].toString()),
                _buildDataValue(article["ultimos6meses"].toString()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataValue(String value) {
    return SizedBox(
      width: 40,
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  List<InlineSpan> buildEmpresaSpans(String empresas) {
    List<String> listaEmpresas = empresas.split(',');
    List<InlineSpan> spans = [];

    for (int i = 0; i < listaEmpresas.length; i++) {
      final empresa = listaEmpresas[i].trim();

      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: underlineSeparado(empresa, () {
            Fluttertoast.showToast(
              msg: empresa,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
            );
          }),
        ),
      );

      if (i < listaEmpresas.length - 1) {
        spans.add(const TextSpan(
          text: ', ',
          style: TextStyle(color: Colors.black87, fontSize: 18),
        ));
      }
    }

    return spans;
  }

  Widget underlineSeparado(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          Text(
            text,
            style: const TextStyle(color: Colors.green, fontSize: 18),
          ),
          Positioned(
            bottom: 2,
            left: 2,
            right: 2,
            child: Container(
              height: 1,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

}
