import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/pages/asignar_codigos_imagenes/scan_box.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Escanear código de barras', style: TextStyle(color: AppColors.semantics.text.body, fontSize: Fontsize.h2, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.black38,
        iconTheme: IconThemeData(color: AppColors.semantics.text.body),
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              final barcode = capture.barcodes.first;
              final String? code = barcode.rawValue;
          
              if (code != null && code.isNotEmpty) {
                Navigator.of(context).pop(code);
              }
            },
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.2,
            left: MediaQuery.of(context).size.width * 0.15,
            right: MediaQuery.of(context).size.width * 0.15,
            child: ScannerBox(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.height * 0.34,
              borderRadius: 18,
            ),
          ),
        ],
      ),
    );
  }
}
