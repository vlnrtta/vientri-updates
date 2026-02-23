// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class ScannerBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ScannerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 16,
  });

  @override
  State<ScannerBox> createState() => _ScannerBoxState();
}

class _ScannerBoxState extends State<ScannerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  // anima la linea de escaneo (0..1)
  late final Animation<double> _scanAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _scanAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          // fondo con sombra y leve degradado
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.black.withOpacity(0.18),
                  Colors.black.withOpacity(0.06),
                ],
              ),
            ),
          ),

          // area enmascarada: borde y contenido interno
          ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(
                  width: 1.8,
                  color: Colors.white.withOpacity(0.18),
                ),
                color: Colors.transparent,
              ),
            ),
          ),


          // bordes interiores brillantes (glow) usando ShaderMask
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.borderRadius - 6),
                  gradient: RadialGradient(
                    center: const Alignment(-0.5, -0.6),
                    radius: 1.2,
                    colors: [
                      Colors.white.withOpacity(0.06),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // linea de escaneo animada
          AnimatedBuilder(
            animation: _scanAnim,
            builder: (context, child) {
              final dy =
                  (widget.height * (0.1 + 0.8 * _scanAnim.value)).clamp(0.0, widget.height);
              return Positioned(
                left: 0,
                right: 0,
                top: dy - 1,
                child: Opacity(
                  opacity: 0.95,
                  child: Container(
                    height: 2.6,
                    // efecto degradado para la linea
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.transparent,
                          const Color.fromARGB(255, 163, 105, 240).withOpacity(0.95),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromARGB(255, 163, 105, 240).withOpacity(0.18),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

        ],
      ),
    );
  }
}


