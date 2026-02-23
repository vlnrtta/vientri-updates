// ignore_for_file: use_build_context_synchronously, deprecated_member_use
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vientri/components/action_sheet/action_sheet.dart';
import 'package:vientri/components/solid_button/solid_button.dart';
import 'package:vientri/components/subtle_button/subtle_button.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/pages/comunes/login/login_page.dart';
import 'package:vientri/pages/controller.dart';
import 'package:vientri/pages/tiquetera/textExpandible.dart';
import 'package:vientri/src/models/entidad.dart';
import 'dart:convert';
import 'package:vientri/src/models/tiqueDetalle.dart';
import 'package:flutter/foundation.dart';
import 'package:vientri/pages/tiquetera/audio_recorder.dart';
import 'package:vientri/pages/tiquetera/audio_recorder_mobile.dart';
import 'package:universal_html/html.dart' as html;

// ignore: must_be_immutable
class AudioDetalleTique extends StatefulWidget {
  Entidad entidad;
  int idTique;

  AudioDetalleTique({
    super.key,
    required this.entidad,
    required this.idTique,
  });

  @override
  State<AudioDetalleTique> createState() => _AudioDetalleTiqueState();
}

class _AudioDetalleTiqueState extends State<AudioDetalleTique> {
  late Controller con;
  late Future<TiqueDetalle> _futureDetalle;
  bool _isExpanded = false;
  Timer? _audioTimer;
  late TiqueDetalle detalle;
  final TextEditingController _transcripcionCtrl = TextEditingController();
  final FocusNode _transcripcionFocus = FocusNode();
  late AudioRecorder _audioRecorder;
  RxBool isRecording = false.obs;
  RxBool isPaused = false.obs;
  RxBool transcribiendo = false.obs;
  RxBool transcripcionEditada = false.obs;
  RxString transcripcion = ''.obs;
  RxString resumen = ''.obs;
  RxInt audioSeconds = 0.obs;
  String _transcripcionOriginal = '';
  bool _abrioApp = false;


  @override
  void initState() {
    super.initState();
    con = Get.put(Controller(widget.entidad));
    _futureDetalle = con.detalleTique(widget.idTique);

    _audioRecorder = AudioRecorderMobile();
    cargarDetalle();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      abrirApp();
    });
  }

  void cargarDetalle() async {
    final d = await _futureDetalle;

    setState(() {
      detalle = d;
    });
  }
  
  Future<void> abrirApp() async {
    if (_abrioApp) return;
    _abrioApp = true;

    if (!kIsWeb) return;

    final userAgent = html.window.navigator.userAgent.toLowerCase();
    final isAndroid = userAgent.contains('android');

    if (!isAndroid) return;

    final uri = Uri.parse('vientri://tiquet/audio-tiquet/${widget.idTique}');

    try {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
    }
  }
 
  void _recargar() {
    setState(() {
      _futureDetalle = con.detalleTique(widget.idTique);
      cargarDetalle();
    });
  }

  Future<void> _startRecording() async {
    transcripcion.value = '';
    resumen.value = '';
    audioSeconds.value = 0;
    isRecording.value = true;
    isPaused.value = false;

    await _audioRecorder.start();

    _audioTimer?.cancel();
    _audioTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        audioSeconds.value++;
      }
    );
  }

  Future<void> _pauseRecording() async {
    if (!isRecording.value || isPaused.value) return;

    await _audioRecorder.pause();
    _audioTimer?.cancel();
    isPaused.value = true;
  }

  Future<void> _resumeRecording() async {
    if (!isRecording.value || !isPaused.value) return;

    await _audioRecorder.resume();
    isPaused.value = false;

    _audioTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        audioSeconds.value++;
      }
    );
  }

  Future<String?> _stopAndGetBase64() async {
    _audioTimer?.cancel();

    final base64 = await _audioRecorder.stopAndGetBase64();

    isRecording.value = false;
    isPaused.value = false;

    if (base64 == null) return null;

    transcribiendo.value = true;

    final texto = await con.base64ToText(base64);
    final resumenGenerado = await con.generarResumenIaAudio(texto);

    _transcripcionOriginal = texto;
    _transcripcionCtrl.text = texto;

    transcripcion.value = texto;
    resumen.value = resumenGenerado;

    transcripcionEditada.value = false;


    transcribiendo.value = false;

    return base64;
  }

  String _formatSeconds(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _audioTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TiqueDetalle>(
      future: _futureDetalle,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || snapshot.hasData == false) {
          final errorText = snapshot.error.toString();
          String headerText;
          if (errorText.contains("SocketException") || errorText.contains("Connection timed out")) {
            headerText = "Error de conexión: se recomienda avisar a VIENTRI";
          } else if (errorText.contains("Connection closed before full header")) {
            headerText = "Error de servidor: la conexión se cerró inesperadamente";
          } else if (errorText.contains("HttpException") || errorText.contains("Response status code")) {
            headerText = "Error HTTP: hubo un problema con la respuesta del servidor";
          } else {
            headerText = "Error";
          }
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 42),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(16)),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => _isExpanded = !_isExpanded),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    headerText,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Icon(
                                  _isExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                          if (_isExpanded) ...[
                            const SizedBox(height: 8),
                            Text(
                              errorText,
                              style: TextStyle(
                                color: AppColors.semantics.text.secondary,
                                fontSize: Fontsize.h3,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: SubtleButton(
                            type: SubtleButtonType.error,
                            text: "Cerrar sesión",
                            onPressed: () {
                              GetStorage().write('pending_route', '/audio-tiquet/${widget.idTique}');
                              GetStorage().remove('user');
                              Get.delete<Controller>();
                              con = Get.put(Controller(widget.entidad));
                              Get.offAll(() => const LoginPage());
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SolidButton(
                            text: "Volver a cargar",
                            onPressed: _recargar,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          );
        }

        final tiqueDetalle = snapshot.data!;
        return _contenido(context, tiqueDetalle);
      },
    );
  }

  Widget _contenido(BuildContext context, TiqueDetalle tiqueDetalle) {
    return  Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 22),
              child: ListView(
                padding: EdgeInsets.only(bottom: 100, top: 16),
                physics: ClampingScrollPhysics(),
                children: [
                  Text(
                    "Grabar audio y enviar tique a soporte",
                    style: TextStyle(
                      color: AppColors.semantics.text.body,
                      fontSize: Fontsize.h1,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "A continuación, grabá el audio, confirmá que la transcripción sea correcta y enviá el tique a soporte",
                    style: TextStyle(
                      color: AppColors.semantics.text.body,
                      fontSize: Fontsize.h3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Nuevo tique",
                    style: TextStyle(
                      color: AppColors.semantics.text.body,
                      fontSize: Fontsize.h3,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Icon(Icons.warning_rounded, size: 18, color: tiqueDetalle.urgente ? AppColors.semantics.text.error : AppColors.semantics.text.warning),
                            const SizedBox(width: 6),
                            Text(
                              tiqueDetalle.urgente ? "Alta" : "Media",
                              style: TextStyle(
                                color: tiqueDetalle.urgente ? AppColors.semantics.text.error : AppColors.semantics.text.warning,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              con.formatearFechayDia3(tiqueDetalle.fecsys),
                              style: TextStyle(
                                color: AppColors.semantics.text.secondary,
                                fontSize: Fontsize.body
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (tiqueDetalle.usuarioElegido!.des != "")
                            Icon(FontAwesomeIcons.user, size: 15, color: AppColors.semantics.text.secondary),
                            const SizedBox(width: 6),
                            Text(
                              con.capitalizarNombre(tiqueDetalle.usuarioElegido!.des!),
                              style: TextStyle(
                                color: AppColors.semantics.text.secondary,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
              
                  const Divider(color: Colors.black12),
              
                  const SizedBox(height: 16),
              
                  Text(
                    "Detalle",
                    style: TextStyle(
                      color: AppColors.semantics.text.body,
                      fontSize: Fontsize.h3,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        TextoExpandable(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          aligment: TextAlign.start,
                          texto:  con.capitalizar(tiqueDetalle.detalle),
                          maxLines: 3,
                          style: TextStyle(
                            color: AppColors.semantics.text.body,
                            fontSize: Fontsize.body,
                          ),
                        ),
                      ],
                    ),
                  ),
              
                  const SizedBox(height: 20),
                  if (tiqueDetalle.img != "")
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      "Imágen adjunta",
                      style: TextStyle(
                        color: AppColors.semantics.text.body,
                        fontSize: Fontsize.h3,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  if (tiqueDetalle.img != "")
                  InkWell(
                    onTap: () => _verImagenFullscreen(_decodeBase64(tiqueDetalle.img)),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: MediaQuery.sizeOf(context).width * 0.7,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.black12,
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Hero(
                          tag: 'imagen_tique',
                          child: Image.memory(
                            _decodeBase64(tiqueDetalle.img),
                            fit: BoxFit.contain,
                          )
                        ),
                      ),
                    ),
                  ),
              
                  if (tiqueDetalle.img != "")
                  const SizedBox(height: 16),
              
                  SolidButton(
                    text: "Grabar audio",
                    leftIcon: CupertinoIcons.mic,
                    onPressed: () => _comenzarAudio(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: SolidButton(
              text: "Enviar tique",
              leftIcon: CupertinoIcons.paperplane,
              onPressed: () {
                
              },
            )
          )
        ],
      ),
    );
  }

  Uint8List _decodeBase64(String base64String) {
    final cleaned = base64String.contains(',')
        ? base64String.split(',').last
        : base64String;
    return base64Decode(cleaned);
  }

  void _comenzarAudio() async {
    await _startRecording();

    ActionSheet.show(
      context,
      title: "Grabar audio",
      content: Obx(() {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Text(
                _formatSeconds(audioSeconds.value),
                style: TextStyle(
                  fontSize: Fontsize.h3,
                  color: AppColors.semantics.text.body,
                ),
              ),

              const SizedBox(height: 12),

              if (!isRecording.value && transcribiendo.value)
              Column(
                children: [
                  const CircularProgressIndicator(strokeWidth: 2),
                  const SizedBox(height: 8),
                  Text(
                    "Generando transcripción…",
                    style: TextStyle(
                      fontSize: Fontsize.body,
                      color: AppColors.semantics.text.secondary,
                    ),
                  ),
                ],
              )

              else if (_transcripcionOriginal != "")
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Transcripción (Tocá para editar)",
                      style: TextStyle(
                        fontSize: Fontsize.body,
                        color: AppColors.semantics.text.secondary,
                      ),
                    ),

                    TextField(
                      controller: _transcripcionCtrl,
                      focusNode: _transcripcionFocus,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      style: TextStyle(
                        fontSize: Fontsize.body,
                        color: AppColors.semantics.text.body,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (value) {
                        transcripcion.value = value;
                        transcripcionEditada.value = value.trim() != _transcripcionOriginal.trim();
                      },
                    ),


                    if (transcripcionEditada.value)
                    const SizedBox(height: 16),
                    if (transcripcionEditada.value)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () async {
                            transcripcion.value = "";
                            _transcripcionCtrl.text = _transcripcionOriginal;
                            FocusScope.of(context).unfocus();
                            final nuevo = await con.generarResumenIaAudio(_transcripcionCtrl.text);
                            resumen.value = nuevo;
                            transcripcion.value = _transcripcionCtrl.text;
                          },
                          child: Icon(
                            CupertinoIcons.xmark,
                            color: AppColors.semantics.text.secondary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        InkWell(
                          onTap: () async {
                            transcripcion.value = "";
                            final nuevo = await con.generarResumenIaAudio(_transcripcionCtrl.text);
                            resumen.value = nuevo;
                            transcripcion.value = _transcripcionCtrl.text;
                          },
                          child: Icon(
                            CupertinoIcons.check_mark,
                            color: AppColors.semantics.text.success,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Text(
                      "Resumen",
                      style: TextStyle(
                        fontSize: Fontsize.body,
                        color: AppColors.semantics.text.secondary,
                      ),
                    ),

                    Text(
                      resumen.value,
                      style: TextStyle(
                        fontSize: Fontsize.body,
                        color: AppColors.semantics.text.body,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      CupertinoIcons.delete,
                      color: AppColors.semantics.text.error,
                    ),
                    onPressed: () {
                      _audioTimer?.cancel();
                      isRecording.value = false;
                      Navigator.pop(context);
                    },
                  ),

                  if (isRecording.value)
                  IconButton(
                    icon: Icon(
                      isPaused.value
                          ? Icons.play_arrow_rounded
                          : Icons.pause_rounded,
                      size: 32,
                    ),
                    onPressed: () async {
                      if (isPaused.value) {
                        await _resumeRecording();
                      } else {
                        await _pauseRecording();
                      }
                    },
                  ),

                  /// CHECK: visible SOLO mientras se graba y todavía no se pidió transcripción
                  if (isRecording.value)
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.semantics.text.action,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          CupertinoIcons.check_mark_circled,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          /// Al presionar check:
                          /// - se detiene el audio
                          /// - comienza el proceso de transcripción
                          await _stopAndGetBase64();
                        },
                      ),
                    ),

                  if (!isRecording.value && transcripcion.value.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.semantics.text.action,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        CupertinoIcons.paperplane,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        final base64 = await _stopAndGetBase64();
                        if (base64 == null) return;

                        
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  void _verImagenFullscreen(Uint8List imagen) {
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (_) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  constrained: false,
                  minScale: 1,
                  maxScale: 4,
                  child: Image.memory(
                    imagen,
                    fit: BoxFit.none,
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 16,
                bottom: 18,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black54
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

}

class EstadoSoporte {
  final String texto;
  final bool activo;

  EstadoSoporte({required this.texto, this.activo = false});
}
