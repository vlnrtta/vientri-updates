import 'package:vientri/pages/contacto/contacto_controller.dart';
import 'package:vientri/pages/contacto/detalle_contacto_page.dart';
import 'package:vientri/pages/controller.dart';
import 'package:vientri/src/models/contacto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:vientri/src/models/entidad.dart';
import 'package:vientri/src/models/pedido.dart';

// ignore: must_be_immutable
class RecienteContactoPage extends StatefulWidget {
  Entidad entidad;
  Pedido pedido;
  RecienteContactoPage({super.key, required this.entidad, required this.pedido});

  @override
  State<RecienteContactoPage> createState() => _RecienteContactoPageState();
}

class _RecienteContactoPageState extends State<RecienteContactoPage> {
  var selectedIndex = 0.obs;
  late ContactoController con;
  late Controller cont;
  late Future<List<Pedido>> _futurePedidos;

  final ScrollController _scrollController = ScrollController();
  final RxBool _showShadow = false.obs;

  @override
  void initState() {
    super.initState();
    con = Get.put(ContactoController(widget.entidad));
    cont = Get.put(Controller(widget.entidad));
    _scrollController.addListener(() {
      _showShadow.value = _scrollController.offset > 0;
    });
    _futurePedidos = cont.listaPedidos();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

  DateTime parseFecha(String fecha) {
    final partes = fecha.split('-');
    final dia = int.parse(partes[2]);
    final mes = int.parse(partes[1]);
    final anio = int.parse(partes[0]);
    return DateTime(anio, mes, dia);
  }


  List<Pedido> pedidosUnicosPorPersona(List<Pedido> pedidos) {
    final Map<String, Pedido> mapa = {};

    for (var pedido in pedidos) {
      final key = pedido.telefono;
      final fechaPedido = parseFecha(pedido.fecha);

      if (!mapa.containsKey(key)) {
        mapa[key] = pedido;
      } else {
        final actual = mapa[key]!;
        final fechaActual = parseFecha(actual.fecha);

        if (fechaPedido.isAfter(fechaActual)) {
          mapa[key] = pedido;
        }
      }
    }

    return mapa.values.toList();
  }


  List<Map<String, dynamic>> mapearPedidos(List<Pedido> pedidos) {
    return pedidos.map((p) => {
          "nombre": p.nameContacto != "" ? p.nameContacto : p.namePer != "" ? p.namePer : "Sin nombre",
          "telefono": p.telefono,
          "cliente": "",
          "fecha": p.fecha,
          "monto": p.total,
          "detalle": p.items != 1 ? "${p.items} Arts." : "${p.items} Art.",
        }).toList();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
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
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text("Contactos recientes", style: TextStyle(fontSize: MediaQuery.sizeOf(context).width * 0.07, fontWeight: FontWeight.bold, color: Colors.black87)),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _switch(),
            ),

            Expanded(
              child: Stack(
                children: [
                  ListView(
                    controller: _scrollController,
                    padding: EdgeInsets.zero,
                    children: [
                      selectedIndex.value == 0
                        ? Dismissible(
                          key: const Key("0"),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.endToStart) {
                              selectedIndex.value = 1;
                            }
                            return false;
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _visualizados(),
                          ),
                        )
                        : Dismissible(
                          key: const Key("1"),
                          direction: DismissDirection.startToEnd,
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.startToEnd) {
                              selectedIndex.value = 0;
                            }
                            return false;
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: FutureBuilder<List<Pedido>>(
                              future: _futurePedidos,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Center(child: Text("Error: ${snapshot.error}"));
                                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                  return const Center(child: Text("No hay pedidos"));
                                } else {
                                  return _atendidos(snapshot.data!);
                                }
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                  Obx(() => AnimatedOpacity(
                    opacity: _showShadow.value ? 0.3 : 0.0,
                    duration: const Duration(milliseconds: 400),
                    child: Container(
                      height: 20,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color.fromARGB(122, 138, 138, 138),
                            Color.fromARGB(186, 255, 255, 255),
                          ],
                        ),
                      ),
                    ),
                  )),
                ],
              ),
            )
          ],
        )),
      ),
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
          _buildOption("Visualizados", 0),
          _buildOption("Atendidos", 1),
        ],
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
            fontSize: MediaQuery.sizeOf(context).width * 0.035,
            color: isSelected ? Colors.green : Colors.black54,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _visualizados() {
    final box = GetStorage();
    final rawList = box.read("visualizados${widget.entidad.usuario}") as List? ?? [];
    List<Contacto> datos = rawList
        .map((e) => e is Contacto ? e : Contacto.fromJson(e as Map<String, dynamic>))
        .toList();
    final hoy = DateFormat('dd/MM/yyyy').format(DateTime.now());
    final ayer = DateFormat('dd/MM/yyyy').format(DateTime.now().subtract(const Duration(days: 1)));

    List<Contacto> contactosHoy = [];
    List<Contacto> contactosAyer = [];
    Map<String, List<Contacto>> contactosPorFecha = {};

    final fechaActual = DateTime.now();

    List<Contacto> contactosValidos = [];

    for (Contacto item in datos) {
      final fechaStr = item.fecha ?? '';
      final soloFecha = fechaStr.toString().split(' ').first;

      // Parsear fecha del contacto, manejar posible error
      DateTime? fechaContacto;
      try {
        fechaContacto = DateFormat('dd/MM/yyyy HH:mm').parse(fechaStr);
      } catch (_) {
        // Si no puede parsear, saltar este contacto
        continue;
      }

      // Calcular diferencia en meses
      int diferenciaMeses = (fechaActual.year - fechaContacto.year) * 12 + (fechaActual.month - fechaContacto.month);

      if (diferenciaMeses > 1) {
        // Si la diferencia es mayor a 1 mes, no incluir este contacto y no agregar a contactosValidos (se eliminará)
        continue;
      }

      // Si llegamos acá, el contacto es válido (menor o igual a 1 mes de diferencia)
      contactosValidos.add(item);

      Contacto contacto = Contacto(
        id: item.id,
        idPer: item.idPer,
        idArea: item.idArea,
        email: item.email,
        telefono: item.telefono,
        horario: item.horario,
        ccsiempre: item.ccsiempre,
        obs: item.obs,
        enviarDocumentos: item.enviarDocumentos,
        des: item.des,
        nomCliente: item.nomCliente,
        idTipoClasificacion: item.idTipoClasificacion,
        fecsys: item.fecsys,
        fecins: item.fecins,
        fecha: fechaStr,
      );

      if (soloFecha == hoy) {
        contactosHoy.add(contacto);
      } else if (soloFecha == ayer) {
        contactosAyer.add(contacto);
      } else {
        contactosPorFecha.putIfAbsent(soloFecha, () => []).add(contacto);
      }
    }

    // Guardar solo los contactos válidos para eliminar los viejos
    //box.write("visualizados${widget.entidad.usuario}", contactosValidos.map((c) => c.toJson()).toList());

    DateFormat formato = DateFormat('dd/MM/yyyy HH:mm');

    void ordenarPorFecha(List<Contacto> lista) {
      lista.sort((a, b) {
        final fa = formato.parse(a.fecha!);
        final fb = formato.parse(b.fecha!);
        return fb.compareTo(fa);
      });
    }

    ordenarPorFecha(contactosHoy);
    ordenarPorFecha(contactosAyer);
    contactosPorFecha.forEach((key, lista) => ordenarPorFecha(lista));

    Widget grupo(String titulo, List<Contacto> lista) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          titulo == "Hoy" || titulo == "Ayer"
          ? Text(
              titulo, 
              style: TextStyle(
                fontSize: MediaQuery.sizeOf(context).width * 0.07,
                fontWeight: FontWeight.bold,
                color: Colors.black87
              )
            )
          : Container(
            margin: const EdgeInsets.only(top: 15),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[300]
            ),
            child: Text(
                titulo, 
                style: TextStyle(
                  fontSize: MediaQuery.sizeOf(context).width * 0.045,
                  fontWeight: FontWeight.bold,
                  color: Colors.white
                )
              ),
          ),
          const SizedBox(height: 8),
          ...lista.map((contact) {
            final tel = contact.telefono;
            final parts = tel.toString().split('');
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => DetalleContactoPage(entidad: widget.entidad, pedido: widget.pedido, contacto: Contacto(
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
                      ),
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
                  )
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 200,
                          child: Text(
                            con.capitalizarNombre(contact.des),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          children: [
                            Text('${parts.sublist(0, 3).join()} ${parts.sublist(3, 6).join()} ', style: const TextStyle(fontSize: 16)),
                            Text(parts.sublist(6).join(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        SizedBox(
                          width: 200,
                          child: Text(
                            con.capitalizarNombre(contact.nomCliente ?? ""),
                            style: const TextStyle(color: Colors.black38, fontSize: 12.5),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => con.enviarMensajeWhatsApp(contact.telefono, ""),
                      child: Container(
                        height: 45,
                        width: 45,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black45, width: 1.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SvgPicture.asset("assets/whatsapp.svg"),
                      ),
                    )
                  ],
                ),
              ),
            );
          })
        ],
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (contactosHoy.isNotEmpty) grupo("Hoy", contactosHoy),
          if (contactosAyer.isNotEmpty) grupo("Ayer", contactosAyer),
          ...contactosPorFecha.entries.map((entry) {
            final titulo = formatearFecha(entry.key);
            return grupo(titulo, entry.value);
          }),
        ],
      ),
    );
  }

  Widget _atendidos(List<Pedido> pedidos) {
    Widget grupo(String titulo, List<Map<String, dynamic>> lista) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(titulo, style: TextStyle(fontSize: MediaQuery.sizeOf(context).width * 0.07, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          ...lista.map((c) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c["nombre"], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              c["telefono"].toString(),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(c["cliente"], style: const TextStyle(fontSize: 13, color: Colors.black45), maxLines: 1, overflow: TextOverflow.ellipsis,),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Info derecha
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(c["fecha"], style: const TextStyle(fontSize: 13, color: Colors.black)),
                      const SizedBox(height: 4),
                      Text('\$${c["monto"].toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        c["detalle"],
                        style: const TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),
            );
          })
        ],
      );
    }

    final unicos = pedidosUnicosPorPersona(pedidos);

    final hoy = unicos.where((p) => DateUtils.isSameDay(parseFecha(p.fecha), DateTime.now())).toList();
    final ayer = unicos.where((p) => DateUtils.isSameDay(parseFecha(p.fecha), DateTime.now().subtract(Duration(days: 1)))).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        grupo("Hoy", mapearPedidos(hoy)),
        grupo("Ayer", mapearPedidos(ayer)),
      ],
    );
  }

  String formatearFecha(String fechaOriginal) {
    DateTime fecha = DateFormat('dd/MM/yyyy').parse(fechaOriginal);
    // Obtener día
    final dia = fecha.day;
    // Obtener nombre completo del mes en español (minúscula)
    final nombreMes = DateFormat.MMMM('es').format(fecha).toLowerCase();
    // Formatear como "16 de mayo"
    return '$dia de $nombreMes';
  }
}







  