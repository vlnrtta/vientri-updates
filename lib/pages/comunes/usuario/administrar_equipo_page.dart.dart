import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/pages/controller.dart';
import 'package:vientri/src/models/entidad.dart';

// ignore: must_be_immutable
class AdministrarEquipoPage extends StatefulWidget {
  Entidad entidad;
  AdministrarEquipoPage({super.key, required this.entidad});

  @override
  State<AdministrarEquipoPage> createState() => _AdministrarEquipoPage();
}

class _AdministrarEquipoPage extends State<AdministrarEquipoPage> {
  late Controller con;
  List<Entidad> listaUsuarios = [
    Entidad(id: -1, cliente: "", basededatos: [], nombre: "Martín Pereyra", usuario: "usuario 1", usuarioId: 0, password: "", token: "", idbasededatos: 0, urlApi: "", urlApiHttp: "", urlVientri: "", urlVientriHttp: "", urlApiLocal: "", domicilio: "", logo: "", ubicacion: "DEPÓSITO CENTRAL", ubicacionId: 1, color: "", esAdmin: false, rol: "", rolId: 0, permisos: [], salones: []),
    Entidad(id: -1, cliente: "", basededatos: [], nombre: "Rosario Menéndez", usuario: "usuario 2", usuarioId: 0, password: "", token: "", idbasededatos: 0, urlApi: "", urlApiHttp: "", urlVientri: "", urlVientriHttp: "", urlApiLocal: "", domicilio: "", logo: "", ubicacion: "DEPÓSITO CENTRAL", ubicacionId: 1, color: "", esAdmin: false, rol: "", rolId: 0, permisos: [], salones: []),
    Entidad(id: -1, cliente: "", basededatos: [], nombre: "Lorenzo Khon", usuario: "usuario 3", usuarioId: 0, password: "", token: "", idbasededatos: 0, urlApi: "", urlApiHttp: "", urlVientri: "", urlVientriHttp: "", urlApiLocal: "", domicilio: "", logo: "", ubicacion: "NAVE 2", ubicacionId: 10, color: "", esAdmin: false, rol: "", rolId: 0, permisos: [], salones: []),
    Entidad(id: -1, cliente: "", basededatos: [], nombre: "Julio Ferraro", usuario: "usuario 4", usuarioId: 0, password: "", token: "", idbasededatos: 0, urlApi: "", urlApiHttp: "", urlVientri: "", urlVientriHttp: "", urlApiLocal: "", domicilio: "", logo: "", ubicacion: "NAVE 2", ubicacionId: 10, color: "", esAdmin: false, rol: "", rolId: 0, permisos: [], salones: []),
    Entidad(id: -1, cliente: "", basededatos: [], nombre: "Arturo Pellizarro", usuario: "usuario 5", usuarioId: 0, password: "", token: "", idbasededatos: 0, urlApi: "", urlApiHttp: "", urlVientri: "", urlVientriHttp: "", urlApiLocal: "", domicilio: "", logo: "", ubicacion: "NAVE 2", ubicacionId: 10, color: "", esAdmin: false, rol: "", rolId: 0, permisos: [], salones: []),
    Entidad(id: -1, cliente: "", basededatos: [], nombre: "Miriam Alarcón", usuario: "usuario 6", usuarioId: 0, password: "", token: "", idbasededatos: 0, urlApi: "", urlApiHttp: "", urlVientri: "", urlVientriHttp: "", urlApiLocal: "", domicilio: "", logo: "", ubicacion: "NAVE 7", ubicacionId: 12, color: "", esAdmin: false, rol: "", rolId: 0, permisos: [], salones: []),
    Entidad(id: -1, cliente: "", basededatos: [], nombre: "Horacio Edinier", usuario: "usuario 7", usuarioId: 0, password: "", token: "", idbasededatos: 0, urlApi: "", urlApiHttp: "", urlVientri: "", urlVientriHttp: "", urlApiLocal: "", domicilio: "", logo: "", ubicacion: "NAVE 7", ubicacionId: 12, color: "", esAdmin: false, rol: "", rolId: 0, permisos: [], salones: []),
    Entidad(id: -1, cliente: "", basededatos: [], nombre: "Fausto Vera", usuario: "usuario 8", usuarioId: 0, password: "", token: "", idbasededatos: 0, urlApi: "", urlApiHttp: "", urlVientri: "", urlVientriHttp: "", urlApiLocal: "", domicilio: "", logo: "", ubicacion: "NAVE 7", ubicacionId: 12, color: "", esAdmin: false, rol: "", rolId: 0, permisos: [], salones: []),
  ];

  @override
  void initState() {
    super.initState();
    con = Get.put(Controller(widget.entidad));
  }

  String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Entidad>> usuariosPorUbicacion = {};
    for (var usuario in listaUsuarios) {
      usuariosPorUbicacion.putIfAbsent(usuario.ubicacion, () => []);
      usuariosPorUbicacion[usuario.ubicacion]!.add(usuario);
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.arrow_back, color: AppColors.semantics.text.body),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Administrar equipo",
                    style: TextStyle(
                      color: AppColors.semantics.text.body,
                      fontWeight: FontWeight.bold,
                      fontSize: Fontsize.h2
                    )
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Expanded(
                child: ListView(
                  children: usuariosPorUbicacion.entries.map((entry) {
                    final ubicacion = entry.key;
                    final usuarios = entry.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            capitalize(ubicacion),
                            style: TextStyle(
                              fontSize: Fontsize.h2,
                              fontWeight: FontWeight.bold,
                              color: AppColors.semantics.text.body,
                            ),
                          ),
                        ),

                        Column(
                          children: usuarios.map((usuario) {
                            return InkWell(
                              onTap: () {
                                
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Colors.black12),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      usuario.nombre,
                                      style: TextStyle(
                                        fontSize: Fontsize.body,
                                        color: AppColors.semantics.text.body,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      capitalize(usuario.ubicacion),
                                      style: TextStyle(
                                        color: AppColors.semantics.text.secondary,
                                        fontSize: Fontsize.body,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: AppColors.semantics.text.body,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
