// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vientri/components/heading/heading.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/pages/controller.dart';
import 'package:vientri/src/models/entidad.dart';
import 'package:vientri/src/models/acceso.dart';
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:http/http.dart' as http;

class PermisosPage extends StatefulWidget {
  final Entidad entidad;
  final String titulo;
  final int idApp;

  const PermisosPage({
    super.key,
    required this.entidad,
    required this.titulo,
    required this.idApp,
  });

  @override
  State<PermisosPage> createState() => _PermisosPageState();
}

class _PermisosPageState extends State<PermisosPage> {
  late Controller con;
  final box = GetStorage();
  bool usaInternet = true;
  bool usaDesarrollo = false;
  bool isLoading = false;

  List<Acceso> accesosPorApp = [];
  List<int> permisosUsuario = [];
  List<Acceso> habilitados = [];
  List<Acceso> noHabilitados = [];

  bool isUpdating = false;
  double downloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    con = Controller(widget.entidad);
    _cargarPermisos();
    usaInternet = box.read('modoConexion${widget.entidad.usuario}') ?? true;
    usaDesarrollo = box.read('modoDesarrollo${widget.entidad.usuario}') ?? false;
  }

  void toggleConexion() {
    setState(() => usaInternet = !usaInternet);
    box.remove('modoConexion${widget.entidad.usuario}');
    box.write('modoConexion${widget.entidad.usuario}', usaInternet);
    Get.delete<Controller>();
    con = Get.put(Controller(widget.entidad));

    if(!usaInternet) {
      setState(() => usaDesarrollo = false);
      box.remove('modoDesarrollo${widget.entidad.usuario}');
      box.write('modoDesarrollo${widget.entidad.usuario}', usaDesarrollo);
      Get.delete<Controller>();
      con = Get.put(Controller(widget.entidad));
    }

    _cargarPermisos();
  }
  
  void toggleDesarrollo() {
    setState(() => usaDesarrollo = !usaDesarrollo);
    box.remove('modoDesarrollo${widget.entidad.usuario}');
    box.write('modoDesarrollo${widget.entidad.usuario}', usaDesarrollo);
    Get.delete<Controller>();
    con = Get.put(Controller(widget.entidad));
    //_cargarPermisos();
    con.obtenerAccesosPorApp(widget.idApp);
  }

  void _cargarPermisos() async {
    
    setState(() => isLoading = true);
    await con.obtenerAccesosPorApp(widget.idApp);
    var data = box.read("accesosApp${widget.entidad.usuario}");

    setState(() => isLoading = false);

    final List<dynamic> jsonList = jsonDecode(data);
    final accesos = jsonList.map((e) => Acceso.fromJson(e)).toList();

    accesosPorApp = accesos.where((a) => a.appId == widget.idApp).toList();

    permisosUsuario = (widget.entidad.permisos as List<dynamic>? ?? [])
        .map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0)
        .toList();

    final resultado = compararPermisos(accesosPorApp, permisosUsuario);
    habilitados = resultado['habilitados']!;
    noHabilitados = resultado['noHabilitados']!;

    setState(() {});
  }

  Map<String, List<Acceso>> compararPermisos(List<Acceso> accesosRequeridos, List<int> permisosUsuario) {
    final habilitados = <Acceso>[];
    final noHabilitados = <Acceso>[];

    for (final acceso in accesosRequeridos) {
      if (permisosUsuario.contains(acceso.accesoId) || widget.entidad.esAdmin) {
        habilitados.add(acceso);
      } else {
        noHabilitados.add(acceso);
      }
    }

    return {
      "habilitados": habilitados,
      "noHabilitados": noHabilitados,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(),
            Center(
              child: CircularProgressIndicator(),
            ),
            _footerUsuario()
          ],
        ),
      );
    }
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF5F5F5), Color(0xFFF5F5F5)],
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
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, true),
                    child: const Icon(Icons.arrow_back, size: 26),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AppHeading(
                  label: widget.titulo != "Accesos" ? accesosPorApp.isNotEmpty ? "Permisos para ${con.capitalizar(accesosPorApp.first.appDes.trim())}" : "Permisos" : widget.titulo,
                  fontSize: Fontsize.h1,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: accesosPorApp.isEmpty
                ? const Center(child: Text("No se encontraron permisos para esta app"))
                : ListView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    if (habilitados.isNotEmpty) ...[
                      Text(
                        "Habilitados",
                        style: TextStyle(
                          color: AppColors.semantics.text.success,
                          fontSize: Fontsize.h3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...(habilitados.toList()
                        ..sort((a, b) => a.accesoId.compareTo(b.accesoId)))
                        .map((a) => _itemPermiso(a, true)),
                      const SizedBox(height: 24),
                    ] else if (habilitados.isEmpty) ...[
                      Text(
                        "Habilitados",
                        style: TextStyle(
                          color: AppColors.semantics.text.success,
                          fontSize: Fontsize.h3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 18),
                        child: Text(
                          "No registra ningún permiso habilitado para esta aplicación.",
                          style: TextStyle(
                            color: AppColors.semantics.text.body,
                            fontSize: Fontsize.h3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (noHabilitados.isNotEmpty) ...[
                      Text(
                        "No habilitados",
                        style: TextStyle(
                          color: AppColors.semantics.text.error,
                          fontSize: Fontsize.h3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...(noHabilitados.toList()
                        ..sort((a, b) => a.accesoId.compareTo(b.accesoId)))
                        .map((a) => _itemPermiso(a, false)),
                    ],
                  ],
                ),
              ),
              _footerUsuario(),
              const SizedBox(height: 24),
            ],
          ),

          if (isUpdating)
          Positioned.fill(
            child: Stack(
              children: [
                /// Blur real del fondo
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: Container(
                    color: Colors.grey.withOpacity(0.35),
                  ),
                ),

                /// Popup centrado
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Descargando actualización...",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.semantics.text.body,
                          ),
                        ),
                        const SizedBox(height: 24),

                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: downloadProgress,
                            minHeight: 10,
                          ),
                        ),

                        const SizedBox(height: 16),

                        Text(
                          "${(downloadProgress * 100).toStringAsFixed(0)}%",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.semantics.text.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemPermiso(Acceso acceso, bool habilitado) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
      decoration: BoxDecoration(
        color: habilitado
            ? AppColors.semantics.surface.success.withOpacity(0.1)
            : AppColors.semantics.surface.error.withOpacity(0.1),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "${acceso.accesoId.toString()} - ${con.capitalizar(acceso.accesoDes)}",
              style: TextStyle(
                fontSize: Fontsize.h3,
                color: AppColors.semantics.text.body,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _footerUsuario() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (usaDesarrollo)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 24,
                  color: AppColors.semantics.text.warning,
                ),
                const SizedBox(width: 8),
                Text(
                  "BASE DE DATOS DE DESARROLLO",
                  style: TextStyle(
                    color: AppColors.semantics.text.warning,
                    fontSize: Fontsize.body,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
          ),
          Text(
            "${con.capitalizarNombre(widget.entidad.nombre.replaceAll('.', ' '))} (${widget.entidad.usuario})",
            style: TextStyle(
              color: AppColors.semantics.text.secondary,
              fontSize: Fontsize.body,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "ID ${widget.entidad.id} | ${widget.entidad.usuarioId}",
            style: TextStyle(
              color: AppColors.semantics.text.secondary,
              fontSize: Fontsize.body,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "BD ${widget.entidad.idbasededatos} | ${widget.entidad.cliente}",
            style: TextStyle(
              color: AppColors.semantics.text.secondary,
              fontSize: Fontsize.body,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            con.url,
            style: TextStyle(
              color: AppColors.semantics.text.secondary,
              fontSize: Fontsize.body,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            con.url == widget.entidad.urlVientriHttp ? "SRV: Pruebas | Desarrollo | Vientri" : "SRV: ${widget.entidad.domicilio} | Producción",
            style: TextStyle(
              color: AppColors.semantics.text.secondary,
              fontSize: Fontsize.body,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                con.version,
                style: TextStyle(
                  color: AppColors.semantics.text.secondary,
                  fontSize: Fontsize.body,
                ),
              ),
              const SizedBox(width: 24),
              InkWell(
                onTap: () => actualizarApp(),
                child: Text(
                  'Actualizar',
                  style: TextStyle(
                    color: AppColors.semantics.text.action,
                    fontSize: Fontsize.body,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.semantics.text.action,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Row(
                children: [
                  Text(
                    usaInternet ? 'Usando Internet' : 'Usando Red Local',
                    style: TextStyle(
                      color: AppColors.semantics.text.secondary,
                      fontSize: Fontsize.body
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    usaInternet ? Icons.wifi_rounded : Icons.lan_rounded,
                    color: usaInternet ? AppColors.semantics.text.information : AppColors.semantics.text.action,
                    size: 24,
                  ),
                ],
              ),
              const SizedBox(width: 24),
              InkWell(
                onTap: () => toggleConexion(),
                child: Text(
                  'Cambiar',
                  style: TextStyle(
                    color: AppColors.semantics.text.action,
                    fontSize: Fontsize.body,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.semantics.text.action
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Row(
                children: [
                  Text(
                    usaDesarrollo ? 'Modo desarrollo' : 'Modo producción',
                    style: TextStyle(
                      color: AppColors.semantics.text.secondary,
                      fontSize: Fontsize.body
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    usaDesarrollo ? Icons.warning_amber_rounded : Icons.check,
                    color: usaDesarrollo
                      ? usaInternet ? AppColors.semantics.text.warning : AppColors.semantics.text.secondary
                      : usaInternet ? AppColors.semantics.text.success : AppColors.semantics.text.secondary,
                    size: 24,
                  ),
                ],
              ),
              const SizedBox(width: 24),
              InkWell(
                onTap: usaInternet ? () => toggleDesarrollo() : null,
                child: Text(
                  'Cambiar',
                  style: TextStyle(
                    color: usaInternet ? AppColors.semantics.text.action : AppColors.semantics.text.secondary,
                    fontSize: Fontsize.body,
                    decoration: TextDecoration.underline,
                    decorationColor: usaInternet ? AppColors.semantics.text.action : AppColors.semantics.text.secondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> actualizarApp() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final response = await http.get(
        Uri.parse(
          "https://raw.githubusercontent.com/vlnrtta/vientri-updates/main/version.json",
        ),
      );

      if (response.statusCode != 200) {
        print("Error al obtener version.json");
        return;
      }

      final data = jsonDecode(response.body);

      final latestVersion = data["version"];
      final apkUrl = data["apk_url"];

      print("Versión actual: $currentVersion");
      print("Última versión: $latestVersion");

      // 3️⃣ Comparar versiones
      if (latestVersion != currentVersion) {
        final dir = await getExternalStorageDirectory();
        final filePath = "${dir!.path}/update.apk";

        setState(() {
          isUpdating = true;
          downloadProgress = 0.0;
        });

        await Dio().download(
          apkUrl,
          filePath,
          onReceiveProgress: (rec, total) {
            if (total != -1) {
              setState(() {
                downloadProgress = rec / total;
              });
            }
          },
        );

        setState(() {
          isUpdating = false;
        });

        await OpenFilex.open(filePath);
      } else {
        print("La app está actualizada");
      }
    } catch (e) {
      print("Error actualizando app: $e");
    }
  }

 
}

