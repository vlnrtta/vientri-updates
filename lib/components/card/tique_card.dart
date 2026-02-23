// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:vientri/components/badge/badge.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/pages/controller.dart';
import 'package:vientri/src/models/entidad.dart';
import 'package:vientri/src/models/tique.dart';

class TiqueCard extends StatefulWidget {
  final Tique t;
  final VoidCallback onTap;
  Entidad entidad;

  TiqueCard({
    super.key,
    required this.t,
    required this.onTap,
    required this.entidad,
  });

  @override
  State<TiqueCard> createState() => _TiqueCardState();
}

class _TiqueCardState extends State<TiqueCard> with TickerProviderStateMixin {
  bool expanded = false;
  late Controller cont;

  @override
  void initState() {
    super.initState();
    cont = Get.put(Controller(widget.entidad));
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;

    return Material(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black12)),
          ),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        "${cont.capitalizarNombre(t.empresa)} | ${cont.capitalizarNombre(t.usuarioSolicitante)}",
                        style: TextStyle(
                          color: AppColors.semantics.text.body,
                          fontSize: Fontsize.body,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: expanded ? 3 : 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(width: 8),
                    if (t.idEstado >= 0)
                      AppBadge(
                        text: cont.capitalizar(t.estado),
                        type: t.estado != "ABIERTO" && t.estado != "CERRADO"
                            ? AppBadgeType.information
                            : t.estado == "ABIERTO"
                            ? AppBadgeType.action
                            : AppBadgeType.success,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        cont.capitalizar(t.asunto.replaceFirst("| • ", "")),
                        style: TextStyle(
                          color: AppColors.semantics.text.body,
                          fontSize: Fontsize.body,
                        ),
                        maxLines: expanded ? null : 1,
                        overflow: expanded
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: _tablaIconos(t)),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        expanded ? Icons.expand_less : Icons.expand_more,
                        color: AppColors.semantics.text.body,
                      ),
                      onPressed: () {
                        setState(() {
                          expanded = !expanded;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tablaIconos(Tique t) {
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: const {
        0: IntrinsicColumnWidth(),
        1: IntrinsicColumnWidth(),
        2: IntrinsicColumnWidth(),
        3: IntrinsicColumnWidth(),
      },
      children: [
        TableRow(
          children: [
            _cellIcon(
              Icon(
                Icons.warning_rounded,
                size: 18,
                color: t.urgente
                    ? AppColors.semantics.text.error
                    : AppColors.semantics.text.warning,
              ),
              t.urgente ? "Alta" : "Media",
              t.urgente
                  ? AppColors.semantics.text.error
                  : AppColors.semantics.text.warning,
            ),
            if (t.usuarioElegido != "")
              _cellIcon(
                Icon(
                  FontAwesomeIcons.user,
                  size: 15,
                  color: AppColors.semantics.text.secondary,
                ),
                cont.capitalizarNombre(t.usuarioElegido),
              ),

            _cellIcon(
              Icon(
                FontAwesomeIcons.calendar,
                size: 15,
                color: AppColors.semantics.text.secondary,
              ),
              cont.formatearFechayDia3(t.fecSys ?? ""),
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
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
