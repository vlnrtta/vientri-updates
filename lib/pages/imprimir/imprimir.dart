// ignore_for_file: deprecated_member_use
import 'dart:io';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:vientri/components/action_sheet/action_sheet.dart';
import 'package:vientri/pages/comunes/master/master_principal.dart';
import 'package:vientri/pages/controller.dart';
import 'package:vientri/services/impresora_service.dart';
import 'package:vientri/src/models/entidad.dart';
import 'package:vientri/src/models/impresora.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// ignore: must_be_immutable
class Imprimir extends StatefulWidget {
  final Entidad entidad;
  const Imprimir({super.key, required this.entidad});

  @override
  State<Imprimir> createState() => _ImprimirState();
}

class _ImprimirState extends State<Imprimir> {
  late Controller con;
  List<int> bytes = [];
  List<ImpresoraRed> impresoras = [];
  final impresoraService = ImpresoraService();

  @override
  void initState() {
    super.initState();
    con = Get.put(Controller(widget.entidad));

    cargarImpresoras();
  }

  void cargarImpresoras() {
    impresoras = impresoraService.obtenerImpresoras();
    if (mounted) setState(() {});
  }

  void imprimir() {
    _mostrarPopupImpresoras();
  }

  Future<void> imprimirA4() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'MI EMPRESA S.A.',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text('CUIT: 30-12345678-9'),
              pw.Text('Av. Siempre Viva 742'),
              pw.Divider(),

              pw.Text('Comprobante: REMITO'),
              pw.Text('N°: 0001-00001234'),
              pw.Text('Fecha: 07/01/2026'),
              pw.SizedBox(height: 12),

              pw.Table.fromTextArray(
                headers: ['Descripción', 'Cant.', 'Precio'],
                data: [
                  ['Producto A', '2', '\$1.500'],
                  ['Producto B', '1', '\$2.000'],
                  ['Servicio C', '1', '\$3.500'],
                ],
              ),

              pw.Divider(),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'TOTAL: \$8.470',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  Future<List<int>> generarTiquet() async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);

    List<int> bytes = [];

    bytes += generator.text(
      'MI EMPRESA S.A.',
      styles: PosStyles(align: PosAlign.center, bold: true),
    );

    bytes += generator.text(
      'CUIT 30-12345678-9',
      styles: PosStyles(align: PosAlign.center),
    );

    bytes += generator.hr();

    bytes += generator.row([
      PosColumn(text: 'Producto A', width: 6),
      PosColumn(text: '2', width: 2),
      PosColumn(text: '\$1500', width: 4),
    ]);

    bytes += generator.hr();

    bytes += generator.text(
      'TOTAL: \$8470',
      styles: PosStyles(
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );

    bytes += generator.feed(2);
    bytes += generator.cut();

    return bytes;
  }

  Future<void> imprimirLAN(ImpresoraRed impresora) async {
    try {
      final bytes = await generarTiquet();

      final socket = await Socket.connect(
        impresora.ip,
        impresora.puerto,
        timeout: const Duration(seconds: 2),
      );

      socket.add(bytes);
      await socket.flush();
      socket.destroy();
      con.mostrarSnackbar(titulo: "Impresión", mensaje: "Ticket enviado correctamente", esError: false);
    } catch (e) {
      con.mostrarSnackbar(titulo: "Error de impresión", mensaje: e.toString(), esError: true, seconds: 3000);
    }
  }

  void _mostrarPopupImpresoras() {
    ActionSheet.show(
      context,
      title: "Imprimir",
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text("Impresora térmica"),
            subtitle: const Text("Tickets / Comprobantes"),
            onTap: () {
              Navigator.pop(context);
              _mostrarImpresorasTermicas();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.print),
            title: const Text("Impresora A4 (Wi-Fi)"),
            subtitle: const Text("PDF / Hoja completa"),
            onTap: () {
              Navigator.pop(context);
              imprimirA4();
            },
          ),
        ],
      ),
    );
  }

  void _mostrarImpresorasTermicas() {
    ActionSheet.show(
      context,
      title: "Impresoras térmicas",
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...impresoras.map(
            (imp) => _itemImpresora(
              imp.nombre,
              '${imp.ip}:${imp.puerto}',
              imp,
            ),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.add),
            title: const Text("Agregar impresora"),
            onTap: () {
              Navigator.pop(context);
              _mostrarAgregarImpresora();
            },
          ),
        ],
      ),
    );
  }

  void _mostrarAgregarImpresora() {
    final nombreCtrl = TextEditingController();
    final ipCtrl = TextEditingController();
    final puertoCtrl = TextEditingController(text: "9100");

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Agregar impresora"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreCtrl,
              decoration: const InputDecoration(labelText: "Nombre"),
            ),
            TextField(
              controller: ipCtrl,
              decoration: const InputDecoration(labelText: "IP"),
              keyboardType: TextInputType.text,
            ),
            TextField(
              controller: puertoCtrl,
              decoration: const InputDecoration(labelText: "Puerto"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Guardar"),
            onPressed: () async {
              await impresoraService.agregar(
                ImpresoraRed(
                  nombre: nombreCtrl.text,
                  ip: ipCtrl.text,
                  puerto: int.parse(puertoCtrl.text),
                  protocolo: "ESC/POS",
                ),
              );

              Navigator.pop(context);
              cargarImpresoras();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterPage(
      title: "Imprimir",
      onBack: () => Navigator.pop(context, true),
      showKey: false,
      showPrint: true,
      onPrint: _mostrarPopupImpresoras,
      fondo: Colors.white,
      child: Center(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                "MI EMPRESA S.A.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "CUIT: 30-12345678-9",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
              const Text(
                "Av. Siempre Viva 742",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
      
              const SizedBox(height: 12),
              const Divider(thickness: 1),
      
              _filaDato("Comprobante", "REMITO"),
              _filaDato("N°", "0001-00001234"),
              _filaDato("Fecha", "07/01/2026"),
              _filaDato("Hora", "10:32"),
      
              const Divider(thickness: 1),
      
              _filaDato("Cliente", "Juan Pérez"),
              _filaDato("CUIT", "20-33445566-7"),
      
              const SizedBox(height: 12),
      
              _filaItem("Producto A", "2", "\$1.500"),
              _filaItem("Producto B", "1", "\$2.000"),
              _filaItem("Servicio C", "1", "\$3.500"),
      
              const Divider(thickness: 1),
      
              _filaTotal("Subtotal", "\$7.000"),
              _filaTotal("IVA", "\$1.470"),
              const SizedBox(height: 4),
              _filaTotal("TOTAL", "\$8.470", bold: true),
      
              const SizedBox(height: 12),
              const Divider(thickness: 1),
      
              const Text(
                "Gracias por su compra",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 4),
              const Text(
                "Documento no válido como factura",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filaDato(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            titulo,
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _filaItem(String descripcion, String cantidad, String precio) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              descripcion,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              cantidad,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              precio,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filaTotal(String titulo, String valor, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          titulo,
          style: TextStyle(
            fontSize: 13,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          valor,
          style: TextStyle(
            fontSize: 13,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _itemImpresora(String nombre, String ip, ImpresoraRed impresora) {
    return ListTile(
      leading: const Icon(Icons.print),
      title: Text(nombre),
      subtitle: Text(ip),
      onTap: () {
        Navigator.pop(context);
        imprimirLAN(impresora);
      },
      onLongPress: () async {
        await impresoraService.eliminar(impresora);
        cargarImpresoras();
      },
    );
  }

}

