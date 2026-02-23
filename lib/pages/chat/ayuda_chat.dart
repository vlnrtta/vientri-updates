import 'package:flutter/material.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/pages/controller.dart';
import 'package:vientri/src/models/entidad.dart';
import 'package:vientri/components/heading/heading.dart';

class AyudaChat extends StatefulWidget {
  final Entidad entidad;

  const AyudaChat({
    super.key,
    required this.entidad,
  });

  @override
  State<AyudaChat> createState() => _AyudaChatState();
}

class _AyudaChatState extends State<AyudaChat> {
  late Controller con;

  @override
  void initState() {
    super.initState();
    con = Controller(widget.entidad);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black12))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: AppHeading(
                        label: "Ayuda",
                        fontSize: Fontsize.h1,
                        leadingIcon: Icons.arrow_back,
                        iconSize: 30,
                        onLeadingIconPressed: () => Navigator.pop(context, true),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "🎙️ GUÍA PARA GRABAR AUDIOS QUE EL SISTEMA ENTIENDE BIEN",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.semantics.text.body
                      ),
                    ),

                    SizedBox(height: 26),

                    Text(
                      "✅ 1. Empezá diciendo qué querés hacer",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.semantics.text.body
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Arrancá el audio con la acción.\n\n"
                      "Ejemplos:\n\n"
                      "• “Quiero dar de alta un proveedor”\n"
                      "• “Necesito crear un pedido nuevo”\n"
                      "• “Quiero actualizar un producto”\n"
                      "• “Quiero cargar un cliente nuevo”\n\n"
                      "Esto ayuda al sistema a saber el contexto.",
                      style: TextStyle(fontSize: 16, color: AppColors.semantics.text.body),
                    ),

                    SizedBox(height: 26),

                    Text(
                      "✅ 2. Después decí los datos uno por uno",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.semantics.text.body
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "No los digas juntos ni mezclados.\n"
                      "Decilos como si estuvieras completando un formulario.\n\n"
                      "Ejemplos:\n\n"
                      "Alta proveedor:\n"
                      "• “Nombre: Juan Pérez”\n"
                      "• “CUIT: veinte tres treinta tres cinco cinco cinco seis seis seis”\n"
                      "• “Teléfono: tres cinco uno, seis seis nueve, uno cuatro dos siete”\n\n"
                      "Pedido:\n"
                      "• “Cliente: Herrera SA”\n"
                      "• “Producto: A123”\n"
                      "• “Cantidad: 4 unidades”",
                      style: TextStyle(fontSize: 16, color: AppColors.semantics.text.body),
                    ),

                    SizedBox(height: 26),

                    Text(
                      "✅ 3. Mantené el orden",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.semantics.text.body
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "El orden es muy importante para maximizar la precisión.\n\n"
                      "Ejemplo (proveedor):\n\n"
                      "Acción → “Quiero dar de alta un proveedor”\n"
                      "Nombre\n"
                      "CUIT\n"
                      "Teléfono\n"
                      "Datos extra si hacen falta\n\n"
                      "Ejemplo (pedido):\n\n"
                      "Acción → “Quiero crear un pedido”\n"
                      "Cliente\n"
                      "Lista de productos\n"
                      "Cantidades\n"
                      "Fecha estimada si corresponde",
                      style: TextStyle(fontSize: 16, color: AppColors.semantics.text.body),
                    ),

                    SizedBox(height: 26),

                    Text(
                      "✅ 4. Evitá frases largas o mezcladas",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.semantics.text.body
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "❌ “Quiero dar de alta a Juan Pérez que es proveedor y su CUIT no me lo acuerdo pero creo que era 20333 algo…”\n\n"
                      "✔ “Quiero dar de alta un proveedor. Nombre Juan Pérez. CUIT 20333555666. Teléfono 3516691427.”",
                      style: TextStyle(fontSize: 16, color: AppColors.semantics.text.body),
                    ),

                    SizedBox(height: 26),

                    Text(
                      "✅ 5. Si no sabés un dato, decilo claro",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.semantics.text.body
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Ejemplos:\n"
                      "• “No tengo el CUIT.”\n"
                      "• “El teléfono no lo sé.”\n"
                      "• “La cantidad no la tengo, solo el producto.”\n\n"
                      "La IA sabrá dejar el campo vacío o pedirlo.",
                      style: TextStyle(fontSize: 16, color: AppColors.semantics.text.body),
                    ),

                    SizedBox(height: 26),

                    Text(
                      "✅ 6. Hablá normal y con pausas cortas",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.semantics.text.body
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "No hace falta hablar lento.\n\n"
                      "Sí conviene separar cada dato con una pequeña pausa.\n\n"
                      "No es necesario ser formal.",
                      style: TextStyle(fontSize: 16, color: AppColors.semantics.text.body),
                    ),

                    SizedBox(height: 26),

                    Text(
                      "📌 EJEMPLO COMPLETO (proveedor)",
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: AppColors.semantics.text.body
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Audio ideal:\n\n"
                      "“Quiero dar de alta un proveedor.\n"
                      "Nombre: Juan Pérez.\n"
                      "CUIT: veinte tres cero dos tres tres tres cinco cinco cinco seis seis seis.\n"
                      "Teléfono: tres cinco uno, seis seis nueve, uno cuatro dos siete.”",
                      style: TextStyle(fontSize: 16, color: AppColors.semantics.text.body),
                    ),

                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
