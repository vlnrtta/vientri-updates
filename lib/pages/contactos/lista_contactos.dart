import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vientri/components/listed_element/listed_element.dart';
import 'package:vientri/components/solid_button/solid_button.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/pages/comunes/master/master_principal.dart';
import 'package:vientri/pages/comunes/permisos/permisos_page.dart';
import 'package:vientri/pages/contactos/detalle_contacto.dart';
import 'package:vientri/pages/contactos/identificar_contacto.dart';
import 'package:vientri/pages/controller.dart';
import 'package:vientri/src/models/contacto.dart';
import 'package:vientri/src/models/entidad.dart';
import 'package:flutter/material.dart';

class ListaContactos extends StatefulWidget {
  final Entidad entidad;
  const ListaContactos({super.key, required this.entidad});

  @override
  State<ListaContactos> createState() => _ListaContactosState();
}

class _ListaContactosState extends State<ListaContactos> {
  late Controller con;
  late Future<List<Contacto>> _futureContactos;
  List<Contacto> contactosRecientes = [];

  final box = GetStorage();
  final String cacheKey = "contactosGuardados";

  @override
  void initState() {
    super.initState();
    con = Get.put(Controller(widget.entidad));
    _futureContactos = _cargarContactos();
  }

  Future<List<Contacto>> _cargarContactos({bool forzarRefresh = false}) async {
    final datosCache = box.read(cacheKey);

    if (!forzarRefresh && datosCache != null && datosCache.isNotEmpty) {
      return Contacto.fromJsonList(List<Map<String, dynamic>>.from(datosCache));
    }

    final contactos = await con.listaContactos();
    await box.write(cacheKey, contactos.map((c) => c.toJson()).toList());
    return contactos;
  }

  Future<void> _actualizarContactos() async {
    setState(() {
      _futureContactos = _cargarContactos(forzarRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final contactosGuardados = box.read("visualizados${widget.entidad.usuario}") ?? [];
    contactosRecientes = Contacto.fromJsonList(contactosGuardados);

    if (contactosRecientes.isNotEmpty) {
      contactosRecientes.sort((a, b) => a.des.toLowerCase().compareTo(b.des.toLowerCase()));
    }

    return MasterPage(
      title: "Contactos",
      onBack: () => Navigator.pop(context, true),
      onKeyTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) => PermisosPage(entidad: widget.entidad, titulo: "Permisos", idApp: 5),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end)
                .chain(CurveTween(curve: Curves.ease));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        )).then((value) {
          setState(() {
            Get.delete<Controller>();
            con = Get.put(Controller(widget.entidad));
            setState(() {
              _futureContactos = _cargarContactos(forzarRefresh: true);
            });
          });
        });
      }, //con.screenPermisos(context, widget.entidad, "Permisos", 5),
      floatingButton: SolidButton(
        text: "Buscar o añadir contacto",
        type: SolidButtonType.primary,
        onPressed: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => IdentificarContacto(entidad: widget.entidad),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
                return SlideTransition(position: animation.drive(tween), child: child);
              },
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          if (contactosRecientes.isNotEmpty) _buildRecientes(),
          _buildContactosAZ(),
        ],
      ),
    );
  }

  Widget _buildRecientes() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Vistos recientemente",
            style: TextStyle(
              color: AppColors.semantics.text.body,
              fontSize: Fontsize.h2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ListedElement(
            column1Content: ListedElementTextContent(text: "Nombre", fontWeight: FontWeight.bold),
            column2Content: ListedElementTextContent(text: "Teléfono", fontWeight: FontWeight.bold),
            column3Content: ListedElementTextContent(text: "Cant. Cbtes.", fontWeight: FontWeight.bold),
          ),
          Column(children: contactosRecientes.map((c) => _buildContactoItem(c)).toList()),
        ],
      ),
    );
  }

  Widget _buildContactosAZ() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "A - Z",
                style: TextStyle(
                  color: AppColors.semantics.text.body,
                  fontSize: Fontsize.h2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              InkWell(
                onTap: _actualizarContactos,
                child: const Icon(Icons.refresh, color: Colors.blue, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ListedElement(
            column1Content: ListedElementTextContent(text: "Nombre", fontWeight: FontWeight.bold),
            column2Content: ListedElementTextContent(text: "Teléfono", fontWeight: FontWeight.bold),
            column3Content: ListedElementTextContent(text: "Cant. Cbtes.", fontWeight: FontWeight.bold),
          ),
          FutureBuilder<List<Contacto>>(
            future: _futureContactos,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text("Error al cargar contactos"),
                );
              }

              final contactos = snapshot.data ?? [];
              contactos.sort((a, b) => a.des.toLowerCase().compareTo(b.des.toLowerCase()));

              if (contactos.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text("No hay contactos disponibles"),
                );
              }

              return Column(
                children: contactos.map((c) => _buildContactoItem(c)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContactoItem(Contacto c) {
    return Material(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          final key = "visualizados${widget.entidad.usuario}";
          final List storedList = box.read(key) ?? [];
          final contactoMap = c.toJson();
          final yaExiste = storedList.any((e) => e["id"] == c.id);
          if (!yaExiste) {
            storedList.add(contactoMap);
            box.write(key, storedList);
          }
          setState(() {});

          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => DetalleContacto(entidad: widget.entidad, contacto: c),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
                return SlideTransition(position: animation.drive(tween), child: child);
              },
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );

        },
        child: Container(
          height: 70,
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black12)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  c.des.isEmpty ? "Sin nombre" : con.capitalizar(c.des.trim()),
                  style: TextStyle(
                    color: AppColors.semantics.text.body,
                    fontSize: Fontsize.h3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 2,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                flex: 3,
                child: Text(
                  c.telefono.isEmpty ? "Sin teléfono" : con.telefonoFormateado(c.telefono),
                  style: TextStyle(
                    color: AppColors.semantics.text.secondary,
                    fontSize: Fontsize.h3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 2,
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  "0",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: AppColors.semantics.text.secondary,
                    fontSize: Fontsize.body,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _boxDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: Colors.black12),
  );
}
