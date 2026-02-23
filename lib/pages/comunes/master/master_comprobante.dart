// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';

class MasterComprobante extends StatefulWidget {
  final String title;
  final Widget child;
  final VoidCallback? onBack;
  final IconData? icon;
  final VoidCallback? onIconTap;
  final Widget? appBadge;
  final String? label1;
  final String? label2;
  final String? label3;
  final String? label4;
  final String? label5;
  final String? cab1;
  final String? cab2;
  final String? cab3;
  final String? cab4;
  final String? cab5;
  final Widget? floatingButton;
  final Color? fondo;

  const MasterComprobante({
    super.key,
    required this.title,
    required this.child,
    this.onBack,
    this.icon,
    this.onIconTap,
    this.appBadge,
    this.label1,
    this.label2,
    this.label3,
    this.label4,
    this.label5,
    this.cab1,
    this.cab2,
    this.cab3,
    this.cab4,
    this.cab5,
    this.floatingButton,
    this.fondo,
  });

  @override
  State<MasterComprobante> createState() => _MasterPageState();
}

class _MasterPageState extends State<MasterComprobante> {
  final ScrollController _scrollController = ScrollController();
  double _offset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _offset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double t = (_offset / 80).clamp(0, 1);
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: widget.fondo ?? const Color(0xFFF5F2FA)
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverAppBar(
                      pinned: true,
                      automaticallyImplyLeading: false,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      toolbarHeight: lerpDouble(100, 60, t)!,
                      collapsedHeight: lerpDouble(100, 60, t)!,
                      expandedHeight: lerpDouble(100, 60, t)!,
                      flexibleSpace: LayoutBuilder(
                        builder: (context, constraints) {
                          return ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: 3.3 * t,
                                sigmaY: 3.3 * t,
                              ),
                              child: Container(
                                padding: EdgeInsets.only(top: lerpDouble(0, 40, t)!),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.5 * t),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Align(
                                      alignment: Alignment.lerp(
                                        Alignment.centerLeft,
                                        Alignment.center,
                                        t.clamp(0.0, 1.0),
                                      )!,
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          left: lerpDouble(16, 0, t)!,
                                          top: lerpDouble(80, 0, t)!,
                                          right: lerpDouble(10, 0, t)!,
                                        ),
                                        child: Transform.scale(
                                          scale: lerpDouble(1, 0.8, t)!,
                                          alignment: Alignment.center,
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              widget.title.trim(),
                                              maxLines: 1,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: lerpDouble(Fontsize.h1, Fontsize.h2, t)!,
                                                color: AppColors.semantics.text.body,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
              
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.arrow_back,
                                          color: AppColors.semantics.text.action,
                                          size: 26,
                                        ),
                                        onPressed: widget.onBack ?? () => Navigator.pop(context),
                                      ),
                                    ),
              
                                    if (widget.icon != null)
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: IconButton(
                                        icon: Icon(
                                          widget.icon,
                                          color: AppColors.semantics.text.action,
                                          size: 26,
                                        ),
                                        onPressed: widget.onIconTap,
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
              
                    SliverToBoxAdapter(
                      child: Container(
                        margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.appBadge != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: widget.appBadge!,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (widget.label1 != null && widget.cab1 != null)
                                  _cabecera(widget.label1!, widget.cab1!),
                                  if (widget.label2 != null && widget.cab2 != null)
                                  _cabecera(widget.label2!, widget.cab2!),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (widget.label3 != null && widget.cab3 != null)
                                  _cabecera(widget.label3!, widget.cab3!),
                                  if (widget.label4 != null && widget.cab4 != null)
                                  _cabecera(widget.label4!, widget.cab4!),
                                  if (widget.label5 != null && widget.cab5 != null)
                                  _cabecera(widget.label5!, widget.cab5!),
                                ],
                              ),
                            ),
                          ],
                        )
                      ),
                    ),
                    
                    SliverToBoxAdapter(
                      child: SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            margin: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom + 30,
                            ),
                            child: widget.child,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 🔹 Botón flotante opcional
          if (widget.floatingButton != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: SafeArea(child: widget.floatingButton!),
            ),
        ],
      ),
    );
  }

  Widget _cabecera(String label, String cab) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppColors.semantics.text.secondary,
                fontSize: Fontsize.body,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              cab,
              style: TextStyle(
                color: AppColors.semantics.text.body,
                fontSize: Fontsize.body,
                fontWeight: FontWeight.w600
              ),
            ),
          ],
        ),
      )
    );
  }

}
