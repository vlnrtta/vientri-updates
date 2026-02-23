// ignore_for_file: use_build_context_synchronously, deprecated_member_use
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/pages/controller.dart';
import 'package:vientri/src/models/contacto.dart';
import 'package:vientri/src/models/entidad.dart';
import 'package:vientri/voice/voice_router.dart';

// ignore: must_be_immutable
class CopilotPage extends StatefulWidget {
  Entidad entidad;
  String nombreContacto;

  CopilotPage({
    super.key,
    required this.entidad,
    required this.nombreContacto,
  });

  @override
  State<CopilotPage> createState() => _CopilotPageState();
}

class _CopilotPageState extends State<CopilotPage> {
  late Controller con;

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _grabando = false;
  late Future<List<Contacto>> contactoEncontrado;
  Contacto contactoSeleccionado = Contacto(id: -1, idPer: 0, email: "", telefono: "", horario: "", obs: "", des: "", fecsys: "", fecins: "", nomCliente: "");
  bool _buscandoContacto = false;

  @override
  void initState() {
    super.initState();
    con = Get.put(Controller(widget.entidad));
    _initRecorder();

    _buscarYSeleccionarContacto(widget.nombreContacto);

    VoiceRouter.pushHandler(_onVoiceCommandCopilot);
  }

  Future<void> _onVoiceCommandCopilot(MethodCall call) async {
    if (call.method == 'cancelar') {
      Navigator.pop(context);
      return;
    }

    if (call.method != 'nombre_contacto') return;

    final nombre = call.arguments as String?;
    if (nombre == null || nombre.isEmpty) return;

    _buscarYSeleccionarContacto(nombre);
  }

  Future<void> _buscarYSeleccionarContacto(String nombre) async {
    setState(() {
      _buscandoContacto = true;
      contactoSeleccionado = Contacto(id: -1, idPer: 0, email: "", telefono: "", horario: "", obs: "", des: "", fecsys: "", fecins: "", nomCliente: "");
    });

    final lista = await _buscarContactosNombre(nombre);

    if (!mounted) return;

    setState(() {
      _buscandoContacto = false;
      if (lista.isNotEmpty) {
        contactoSeleccionado = lista.first;
      } else {
        contactoSeleccionado = Contacto(
          id: -1,
          idPer: 0,
          email: "",
          telefono: "",
          horario: "",
          obs: "",
          des: "",
          fecsys: "",
          fecins: "",
          nomCliente: "",
        );
      }
    });
  }

  @override
  void dispose() {
    VoiceRouter.popHandler();
    _recorder.closeRecorder();
    super.dispose();
  }

  Future<List<Contacto>> _buscarContactosNombre(String nombre) async {
    if (nombre.isEmpty) return [];
    nombre = con.quitarTildes(nombre);

    final datosCache = GetStorage().read("contactosGuardados");
    List<Contacto> contactosLocales = [];
    if (datosCache != null && datosCache.isNotEmpty) {
      contactosLocales = Contacto.fromJsonList(
        List<Map<String, dynamic>>.from(datosCache),
      );
    }

    final coincidenciasLocales = contactosLocales.where((c) {
      if (c.des == "") return false;
      return c.des.toLowerCase().contains(nombre.toLowerCase());
    }).toList();

    if (coincidenciasLocales.isNotEmpty) return coincidenciasLocales;

    final contactosRemotos = await con.listaContactos();

    await GetStorage().write("contactosGuardados", contactosRemotos.map((c) => c.toJson()).toList());

    final coincidenciasRemotas = contactosRemotos.where((c) {
      if (c.des == "") return false;
      return c.des.contains(nombre);
    }).toList();

    return coincidenciasRemotas;
  }

  // =========================
  // INICIALIZACIÓN RECORDER
  // =========================
  Future<void> _initRecorder() async {
    final status = await Permission.microphone.request();

    if (!status.isGranted) {
      throw Exception('Permiso de micrófono denegado');
    }

    await _recorder.openRecorder();
  }


  // =========================
  // GRABACIÓN
  // =========================
  /*Future<void> iniciarGrabacion() async {
    await con.pausarEscuchaVoz();

    final dir = await getTemporaryDirectory();
    _rutaAudio =
        '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';

    await _recorder.startRecorder(
      toFile: _rutaAudio,
      codec: Codec.aacADTS,
      bitRate: 128000,
      sampleRate: 44100,
    );
  }

  Future<File> detenerGrabacion() async {
    await _recorder.stopRecorder();
    await con.reanudarEscuchaVoz();

    return File(_rutaAudio!);
  }*/

  // =========================
  // ENVÍO AUDIO
  // =========================
  Future<String> audioToBase64(File audioFile) async {
    final bytes = await audioFile.readAsBytes();
    return base64Encode(bytes);
  }

  Future<void> enviarAudio(File audioFile) async {
    final base64Audio = await audioToBase64(audioFile);

    try {
      final response = await http.post(
        Uri.parse("http://net.vientri.com:3004/whatsapp/sendvoice"),
        headers: {
          "x-access-token": widget.entidad.token,
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "contextId": "NEwdQjNuCukx4eoW",
          "phoneNumber": "5493515550158",
          "audio": {
            "base64": base64Audio,
            "mimetype": "audio/mp3",
              "filename": "voice.mp3"
          }
        }),
      );

      if (response.statusCode == 200) {
        debugPrint("Audio enviado correctamente");
      } else {
        debugPrint(
            "Error al enviar audio: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      debugPrint("Error enviando audio: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_buscandoContacto) ...[
                const SizedBox(height: 16),
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  "Buscando contacto...",
                  style: TextStyle(
                    fontSize: Fontsize.h3,
                    color: AppColors.semantics.text.secondary,
                  ),
                ),
              ],
              Text(
                _buscandoContacto
                  ? "Buscando contacto..."
                  : _grabando
                    ? "Escuchando..."
                    : contactoSeleccionado.id == -1
                      ? "No encontré el contacto.\nDecí: \"para nombre apellido\""
                      : "Enviar mensaje de voz a",
                style: TextStyle(
                  fontSize: Fontsize.h1,
                  fontWeight: FontWeight.bold,
                  color: AppColors.semantics.text.body,
                ),
                textAlign: TextAlign.center,
              ),
              if (contactoSeleccionado.id != -1)
              Container(
                margin: EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(12)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person_rounded
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          con.capitalizarNombre(contactoSeleccionado.des),
                          style: TextStyle(
                            fontSize: Fontsize.h2,
                            fontWeight: FontWeight.bold,
                            color: AppColors.semantics.text.body,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          contactoSeleccionado.telefono,
                          style: TextStyle(
                            fontSize: Fontsize.h3,
                            color: AppColors.semantics.text.secondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Icon(
                      CupertinoIcons.chevron_down,
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
    
              if (_grabando) ...[
                const SizedBox(height: 20),
                Text(
                  "Para enviar tocá el círculo",
                  style: TextStyle(
                    fontSize: Fontsize.h3,
                    color: AppColors.semantics.text.secondary,
                  ),
                ),
              ],
    
              const SizedBox(height: 80),
    
              GestureDetector(
                onTap: () async {
                  if (!_grabando) {
                    //await iniciarGrabacion();
                  } else {
                    //final audioFile = await detenerGrabacion();
                    //await enviarAudio(audioFile);
                    Navigator.pop(context);
                  }
    
                  setState(() {
                    _grabando = !_grabando;
                  });
                },
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _grabando ? Colors.red : AppColors.brand.c900,
                  ),
                  child: Icon(
                    _grabando ? Icons.stop : Icons.mic,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
