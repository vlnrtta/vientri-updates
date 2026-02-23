// ignore_for_file: library_private_types_in_public_api
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vientri/components/badge/badge.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/pages/controller.dart';
import 'package:vientri/src/models/control.dart';
import 'package:vientri/src/models/entidad.dart';

class CronometroListedElement extends StatefulWidget {
  final dynamic control;
  final VoidCallback funcion;

  const CronometroListedElement({super.key, required this.control, required this.funcion});
  @override
  _CronometroListedElementState createState() => _CronometroListedElementState();
}

class _CronometroListedElementState extends State<CronometroListedElement> {
  late Controller cont;
  late DateTime horaIni;
  late Timer timer;
  String tiempoFormateado = "00:00:00";

  @override
  void initState() {
    super.initState();
    cont = Get.put(Controller(
      Entidad(
          id: -1,
          cliente: "",
          nombre: "",
          usuario: "",
          usuarioId: 0,
          password: "",
          token: "",
          idbasededatos: 0,
          basededatos: [],
          urlApi: "",
          urlApiHttp: "",
          urlVientri: "",
          urlVientriHttp: "",
          urlApiLocal: "",
          domicilio: "",
          logo: "",
          ubicacion: "NAVE 2",
          ubicacionId: 10,
          color: "",
          esAdmin: false,
          rol: "",
          rolId: 0,
          permisos: [],
          salones: []
        )
      )
    );

    try {
      horaIni = DateTime.parse(widget.control.horaIni!);
    } catch (e) {
      horaIni = DateTime.now();
    }

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final ahora = DateTime.now().toUtc().add(const Duration(hours: -3));
      final duracion = ahora.difference(horaIni);

      final horas = duracion.inHours.toString().padLeft(2, '0');
      final minutos = (duracion.inMinutes % 60).toString().padLeft(2, '0');
      final segundos = (duracion.inSeconds % 60).toString().padLeft(2, '0');

      setState(() {
        tiempoFormateado = "$horas:$minutos:$segundos";
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _card(
      widget.control,
      widget.funcion,
      AppBadge(text: "En curso", type: AppBadgeType.action)
    );
    
  }

  Widget _card(Control control, VoidCallback funcion, Widget badge) {
    return Material(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: funcion,
        child: Container(
          height: 90,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 5,
                    child: Text(
                      cont.capitalizar(control.ubicacion.trim()),
                      style: TextStyle(
                        color: AppColors.semantics.text.body,
                        fontSize: Fontsize.body,
                        fontWeight: FontWeight.bold
                      ),
                    )
                  ),
                  Expanded(
                    flex: 3,
                    child: badge
                  ),
                ],
              ),
              Expanded(
                child: Text(
                  cont.capitalizarNombre(control.empleado.trim()),
                  style: TextStyle(
                    color: AppColors.semantics.text.body,
                    fontSize: Fontsize.body,
                  ),
                )
              ),
              Expanded(
                child: _tablaIconos(control),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tablaIconos(Control control) {
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: const {
        0: IntrinsicColumnWidth(), // fecha-hora
        1: IntrinsicColumnWidth(), // items
        2: IntrinsicColumnWidth(), // cronometro
      },
      children: [
        TableRow(
          children: [
            _cellIcon(
              Icon(CupertinoIcons.time, size: 18, color: AppColors.semantics.text.secondary),
              "${cont.formatearFechayDia2(control.fecha)}, ${control.hora}",
            ),

            _cellIcon(
              Icon(CupertinoIcons.cube_box, size: 18, color: AppColors.semantics.text.secondary),
              control.items.toString(),
            ),

            // Cronómetro (siempre ocupa columna)
            _cellIcon(
              Icon(CupertinoIcons.stopwatch, size: 18, color: AppColors.semantics.text.action),
              tiempoFormateado,
              AppColors.semantics.text.action
            ),
          ],
        ),
      ],
    );
  }

  Widget _cellIcon(Icon icon, String text, [Color? color]) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color ?? AppColors.semantics.text.secondary,
              fontSize: Fontsize.body,
            ),
          ),
        ],
      ),
    );
  }

}
