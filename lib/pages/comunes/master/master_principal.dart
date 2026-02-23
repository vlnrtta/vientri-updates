// ignore_for_file: deprecated_member_use
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/src/providers/credenciales_provider.dart';

class MasterPage extends StatefulWidget {
  final String title;
  final Widget child;
  final VoidCallback? onBack;
  final VoidCallback? onKeyTap;
  final VoidCallback? onMoreTap;
  final VoidCallback? onLoadMore;
  final VoidCallback? onPrint;
  final bool showKey;
  final bool showMore;
  final bool showPrint;
  final Widget? floatingButton;
  final Widget? appBadge;
  final Color? fondo;
  final bool appNuevoContacto;
  final bool showShare;
  final VoidCallback? onShare;

  final Future<void> Function()? onRefresh;

  const MasterPage({
    super.key,
    required this.title,
    required this.child,
    this.onBack,
    this.onKeyTap,
    this.onLoadMore,
    this.onMoreTap,
    this.onPrint,
    this.onShare,
    this.showKey = true,
    this.showPrint = false,
    this.showMore = false,
    this.showShare = false,
    this.floatingButton,
    this.appBadge,
    this.fondo,
    this.onRefresh,
    this.appNuevoContacto = false
  });

  @override
  State<MasterPage> createState() => _MasterPageState();
}

class _MasterPageState extends State<MasterPage> {
  final ScrollController _scrollController = ScrollController();
  double _offset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _offset = _scrollController.offset;
      });
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        widget.onLoadMore?.call();
      }
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
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: widget.fondo ?? const Color(0xFFF5F2FA)
            ),
            child: Padding(
              padding: EdgeInsets.only(bottom: widget.floatingButton != null ? 20 : 0),
              child: RefreshIndicator(
                onRefresh: widget.onRefresh ?? () async { setState(() {}); },
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverAppBar(
                      pinned: true,
                      automaticallyImplyLeading: false,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      toolbarHeight: CredencialesProvider.isWeb ? lerpDouble(120, 80, t)! : lerpDouble(100, 80, t)!,
                      collapsedHeight: CredencialesProvider.isWeb ? lerpDouble(120, 80, t)! : lerpDouble(100, 80, t)!,
                      expandedHeight: CredencialesProvider.isWeb ? lerpDouble(120, 80, t)! : lerpDouble(100, 80, t)!,
                      flexibleSpace: LayoutBuilder(
                        builder: (context, constraints) {
                          return ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: 3.3 * t,
                                sigmaY: 3.3 * t,
                              ),
                              child: Container(
                                padding: EdgeInsets.only(top: lerpDouble(0, 0, t)!),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.5 * t),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Align(
                                      alignment: Alignment.lerp(
                                        Alignment.bottomLeft,
                                        Alignment.center,
                                        t.clamp(0.0, 1.0),
                                      )!,
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          left: lerpDouble(16, 0, t)!,
                                          top: CredencialesProvider.isWeb
                                              ? lerpDouble(0, 0, t)!
                                              : lerpDouble(80, 0, t)!,
                                        ),
                                        child: Transform.scale(
                                          scale: lerpDouble(1, 0.8, t)!,
                                          alignment: Alignment.center,
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              widget.title,
                                              softWrap: true,
                                              maxLines: t < 0.5 ? 2 : 1,
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

                                    if (widget.showKey)
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.vpn_key_outlined,
                                            color: AppColors.semantics.text.action,
                                            size: 26,
                                          ),
                                          onPressed: widget.onKeyTap,
                                        ),
                                      ),

                                    if (widget.showMore)
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.more_vert,
                                            color: AppColors.semantics.text.action,
                                            size: 26,
                                          ),
                                          onPressed: widget.onMoreTap,
                                        ),
                                      ),

                                    if (widget.showPrint)
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.print_rounded,
                                            color: AppColors.semantics.text.action,
                                            size: 26,
                                          ),
                                          onPressed: widget.onPrint,
                                        ),
                                      ),

                                    if (widget.showShare)
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: IconButton(
                                          icon: Icon(
                                            CupertinoIcons.share,
                                            color: AppColors.semantics.text.action,
                                            size: 26,
                                          ),
                                          onPressed: widget.onShare,
                                        ),
                                      ),

                                    if (widget.appBadge != null)
                                      Padding(
                                        padding: const EdgeInsets.only(right: 16),
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: widget.appBadge!,
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
                      child: SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          child: Container(
                            margin: EdgeInsets.only(
                              bottom: widget.appNuevoContacto ? 30 : MediaQuery.of(context).viewInsets.bottom + 30,
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
}
