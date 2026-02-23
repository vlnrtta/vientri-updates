import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:vientri/components/card/tique_card.dart';
import 'package:vientri/components/heading/heading.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/constants/app_shadows.dart';
import 'package:vientri/pages/comunes/master/master_principal.dart';
import 'package:vientri/pages/controller.dart';
import 'package:vientri/pages/tiquetera/detalle_tique.dart';
import 'package:vientri/pages/tiquetera/detalle_tique_web.dart';
import 'package:vientri/src/models/entidad.dart';
import 'package:vientri/src/models/tique.dart';
import 'package:vientri/src/providers/credenciales_provider.dart';

// ignore: must_be_immutable
class ListaTiques extends StatefulWidget {
  final Entidad entidad;
  const ListaTiques({super.key, required this.entidad});

  @override
  State<ListaTiques> createState() => _ListaTiquesState();
}

class _ListaTiquesState extends State<ListaTiques> {
  late Controller cont;

  final List<Tique> _tiques = [];
  int _page = 1;
  bool _loading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    cont = Get.put(Controller(widget.entidad));
    _cargarTiques();
  }

  Future<void> _cargarTiques({bool refresh = false}) async {
    if (_loading || (!_hasMore && !refresh)) return;

    if (refresh) {
      _page = 1;
      _hasMore = true;
      _tiques.clear();
    }

    setState(() => _loading = true);

    final nuevos = await cont.listaTiques(_page);

    setState(() {
      _tiques.addAll(nuevos);
      _loading = false;
      _page++;

      if (nuevos.isEmpty) {
        _hasMore = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterPage(
      title: "Tiques de soporte",
      onRefresh: () async {
        await _cargarTiques(refresh: true);
      },
      onLoadMore: () {
        _cargarTiques();
      },
      onBack: () => Navigator.pop(context, true),
      showKey: false,
      child: _buildContenido(),
    );
  }

  /// =========================
  /// UI
  /// =========================

  Widget _buildContenido() {
    if (_tiques.isEmpty && _loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_tiques.isEmpty && !_loading) {
      return _sinVigentes("Activos");
    }

    return Column(
      children: [
        _buildVigentes(_tiques),

        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }

  Widget _buildVigentes(List<Tique> vigentes) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(8),
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
                "Activos",
                style: TextStyle(
                  fontSize: Fontsize.h2,
                  fontWeight: FontWeight.bold,
                  color: AppColors.semantics.text.body,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          ...vigentes.map(
            (t) => TiqueCard(
              t: t,
              entidad: widget.entidad,
              onTap: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (_, a, b) => CredencialesProvider.isWeb ? DetalleTiqueWeb(entidad: widget.entidad, idTique: t.id) : DetalleTique(entidad: widget.entidad, idTique: t.id),
                    transitionsBuilder: (_, animation, __, child) {
                      return SlideTransition(
                        position: Tween(
                          begin: const Offset(1, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _sinVigentes(String titulo) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
        color: Colors.white,
      ),
      child: Column(
        children: [
          AppHeading(label: titulo, fontSize: Fontsize.h2),
          const SizedBox(height: 16),
          Text(
            "No hay ${titulo.toLowerCase()}",
            style: TextStyle(
              color: AppColors.semantics.text.secondary,
              fontSize: Fontsize.h3,
            ),
          ),
        ],
      ),
    );
  }
}

