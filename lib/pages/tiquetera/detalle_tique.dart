// ignore_for_file: use_build_context_synchronously, deprecated_member_use
import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vientri/components/action_sheet/action_sheet.dart';
import 'package:vientri/components/action_sheet_options/action_sheet_options.dart';
import 'package:vientri/components/badge/badge.dart';
import 'package:vientri/components/solid_button/solid_button.dart';
import 'package:vientri/components/subtle_button/subtle_button.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/constants/app_shadows.dart';
import 'package:vientri/pages/comunes/inicio/inicio.dart';
import 'package:vientri/pages/comunes/login/login_page.dart';
import 'package:vientri/pages/comunes/master/master_principal.dart';
import 'package:vientri/pages/controller.dart';
import 'package:vientri/pages/tiquetera/animated_bars.dart';
import 'package:vientri/pages/tiquetera/textExpandible.dart';
import 'package:vientri/src/models/entidad.dart';
import 'package:vientri/src/models/opcion.dart';
import 'dart:convert';
import 'package:vientri/src/models/tiqueDetalle.dart';
import 'package:vientri/src/models/tiqueMensaje.dart';
import 'package:flutter/foundation.dart';

// ignore: must_be_immutable
class DetalleTique extends StatefulWidget {
  Entidad entidad;
  int idTique;

  DetalleTique({
    super.key,
    required this.entidad,
    required this.idTique,
  });

  @override
  State<DetalleTique> createState() => _DetalleTiqueState();
}

class _DetalleTiqueState extends State<DetalleTique> {
  late Controller con;
  late TextEditingController _controller;
  late FocusNode _focusNode;
  int _estadoSeleccionado = 0;
  late Future<TiqueDetalle> _futureDetalle;
  late Future<List<TiqueMensaje>> _futureMensajes;
  bool _isExpanded = false;
  List<Opcion> _rtasRapidas = [];
  bool _conversacionExpandida = false;
  Timer? _audioTimer;
  final RxInt _audioSeconds = 0.obs;
  final RxBool _isRecording = false.obs;
  final RxBool _isPaused = false.obs;
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  String? _currentAudioPath;
  late TiqueDetalle detalle;
  final TextEditingController _controllerTelefono = TextEditingController();
  final FocusNode _focusNodeTelefono = FocusNode();
  final RxBool _transcribiendo = false.obs;
  final RxString _transcripcion = ''.obs;
  String _transcripcionOriginal = '';
  final RxString _resumen = ''.obs;
  final RxBool _transcripcionEditada = false.obs;
  final TextEditingController _transcripcionCtrl = TextEditingController();
  final FocusNode _transcripcionFocus = FocusNode();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ValueNotifier<String?> _audioIdActivo = ValueNotifier(null);
  final ValueNotifier<bool> _audioPlaying = ValueNotifier(false);
  String? _audioIdEnPlayer;
  final RxString base64 = ''.obs;
  final RxBool _existeWpp = true.obs;
  final RxBool _loading = true.obs;
  final RxBool _loadingSend = false.obs;
  final String base64ImagenVacia = "/9j/4AAQSkZJRgABAQEBLAEsAAD/4QBWRXhpZgAATU0AKgAAAAgABAEaAAUAAAABAAAAPgEbAAUAAAABAAAARgEoAAMAAAABAAIAAAITAAMAAAABAAEAAAAAAAAAAAEsAAAAAQAAASwAAAAB/+0ALFBob3Rvc2hvcCAzLjAAOEJJTQQEAAAAAAAPHAFaAAMbJUccAQAAAgAEAP/hDW9odHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvADw/eHBhY2tldCBiZWdpbj0n77u/JyBpZD0nVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkJz8+Cjx4OnhtcG1ldGEgeG1sbnM6eD0nYWRvYmU6bnM6bWV0YS8nIHg6eG1wdGs9J0ltYWdlOjpFeGlmVG9vbCAxMi40MCc+CjxyZGY6UkRGIHhtbG5zOnJkZj0naHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyc+CgogPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9JycKICB4bWxuczp0aWZmPSdodHRwOi8vbnMuYWRvYmUuY29tL3RpZmYvMS4wLyc+CiAgPHRpZmY6UmVzb2x1dGlvblVuaXQ+MjwvdGlmZjpSZXNvbHV0aW9uVW5pdD4KICA8dGlmZjpYUmVzb2x1dGlvbj4zMDAvMTwvdGlmZjpYUmVzb2x1dGlvbj4KICA8dGlmZjpZUmVzb2x1dGlvbj4zMDAvMTwvdGlmZjpZUmVzb2x1dGlvbj4KIDwvcmRmOkRlc2NyaXB0aW9uPgoKIDxyZGY6RGVzY3JpcHRpb24gcmRmOmFib3V0PScnCiAgeG1sbnM6eG1wPSdodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvJz4KICA8eG1wOkNyZWF0b3JUb29sPkFkb2JlIFN0b2NrIFBsYXRmb3JtPC94bXA6Q3JlYXRvclRvb2w+CiA8L3JkZjpEZXNjcmlwdGlvbj4KCiA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0nJwogIHhtbG5zOnhtcE1NPSdodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvbW0vJz4KICA8eG1wTU06RG9jdW1lbnRJRD54bXAuaWlkOjBiZWVmNjZkLTU1NWUtNDY0ZS04NzMyLTQ3ODBjNGQyOThkYjwveG1wTU06RG9jdW1lbnRJRD4KICA8eG1wTU06SW5zdGFuY2VJRD5hZG9iZTpkb2NpZDpzdG9jazo5M2RkNmJlMC00NDQyLTRjN2EtOTM2ZS05Y2RkYTMyMWQyNGI8L3htcE1NOkluc3RhbmNlSUQ+CiAgPHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD5hZG9iZTpkb2NpZDpzdG9jazoxNjc5NDQyMTk2PC94bXBNTTpPcmlnaW5hbERvY3VtZW50SUQ+CiA8L3JkZjpEZXNjcmlwdGlvbj4KPC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKPD94cGFja2V0IGVuZD0ndyc/Pv/bAEMA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AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD//Z";
  
  @override
  void initState() {
    super.initState();
    con = Get.put(Controller(widget.entidad));

    _futureDetalle = con.detalleTique(widget.idTique);
    _futureMensajes = con.listaMensajesTique(widget.idTique);
    _controller = TextEditingController();
    _focusNode = FocusNode();

    _initRecorder();
    cargarRtasRapidas();

    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (_audioIdActivo.value == _audioIdEnPlayer) {
          _audioPlaying.value = false;
          _audioIdActivo.value = null;
          _audioIdEnPlayer = null;
        }
      }
    });
    _cargarInicial();
  }
  
  Future<void> _cargarInicial() async {
    cargarDetalle();
    _recargarMensajes();
    setState(() {
    });
    _loading.value = false;
  }

  Uint8List _base64ToBytes(String base64) {
    final cleaned = base64.contains(',')
        ? base64.split(',').last
        : base64;
    return base64Decode(cleaned);
  }

  Future<void> _playBase64(String base64, String mensajeId) async {
    try {
      // UI inmediata
      _audioIdActivo.value = mensajeId;
      _audioPlaying.value = true;

      _audioIdEnPlayer = mensajeId; // 👈 CLAVE

      final bytes = _base64ToBytes(base64);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/audio_$mensajeId.aac');

      await file.writeAsBytes(bytes, flush: true);

      await _audioPlayer.stop();
      await _audioPlayer.setFilePath(file.path);
      await _audioPlayer.play();
    } catch (e) {
      _audioPlaying.value = false;
      _audioIdActivo.value = null;
      _audioIdEnPlayer = null;
    }
  }

  void cargarDetalle() async {
    detalle = await _futureDetalle;
    _existeWpp.value = await con.validarNroWpp(detalle.usuarioSolicitante!.telefono!);
    detalle.usuarioElegido!.contextId = await con.asignarContextId(detalle.usuarioElegido!.des!);
  }
 
  Future<void> _initRecorder() async {
    await _recorder.openRecorder();
  }

  void cargarRtasRapidas() async {
    final data = await con.listaRtasRapidas();
    setState(() {
      _rtasRapidas = data;
    });
  }

  void _recargar() {
    setState(() {
      _futureDetalle = con.detalleTique(widget.idTique);
      cargarDetalle();
      _recargarMensajes();
    });
  }

  void _recargarMensajes() {
    _futureMensajes = con.listaMensajesTique(widget.idTique).then((mensajes) async {
      return await _inyectarAudios(mensajes);
    });
    setState(() {});
  }

  Future<List<TiqueMensaje>> _inyectarAudios(List<TiqueMensaje> mensajes) async {
    final futures = mensajes.map((m) async {
      if (m.adjunto == "AUDIO" && (m.audio == null || m.audio!.isEmpty)) {
        final String base64 = await con.obtenerAudioMensaje(m.id);
        m.audio = base64;
      }
      return m;
    });

    return Future.wait(futures);
  }

  Future<void> _startRecording() async {
    _transcripcion.value = '';
    _resumen.value = '';

    final perm = await Permission.microphone.request();
    if (!perm.isGranted) return;

    final dir = await getTemporaryDirectory();
    _currentAudioPath =
        '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';

    await _recorder.startRecorder(toFile: _currentAudioPath);

    _audioSeconds.value = 0;
    _isRecording.value = true;
    _isPaused.value = false;

    _audioTimer?.cancel();
    _audioTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _audioSeconds.value++,
    );
  }

  Future<void> _pauseRecording() async {
    if (!_isRecording.value || _isPaused.value) return;

    await _recorder.pauseRecorder();
    _audioTimer?.cancel();
    _isPaused.value = true;
  }

  Future<void> _resumeRecording() async {
    if (!_isRecording.value || !_isPaused.value) return;

    await _recorder.resumeRecorder();
    _isPaused.value = false;

    _audioTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _audioSeconds.value++,
    );
  }

  Future<String> _stopAndGetBase64() async {
    _audioTimer?.cancel();

    final path = await _recorder.stopRecorder();
    _isRecording.value = false;
    _isPaused.value = false;
    _transcripcionEditada.value = false;

    if (path == null) return "";

    final bytes = await File(path).readAsBytes();
    _transcribiendo.value = true;
    _transcripcion.value = await con.transcribirAudio(path);
    _transcripcionCtrl.text = _transcripcion.value;
    _resumen.value = await con.generarResumenIaAudio(_transcripcion.value);
    _transcribiendo.value = false;

    return base64Encode(bytes);
  }

  String _formatSeconds(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _audioTimer?.cancel();
    if (_recorder.isRecording) {
      _recorder.stopRecorder();
    }
    _recorder.closeRecorder();
    _controller.dispose();
    _focusNode.dispose();
    _focusNodeTelefono.dispose();
    _controllerTelefono.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading.value) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } 
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
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => InicioPage(entidad: widget.entidad),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
          return MasterPage(
            title: "Error",
            onBack: () => Navigator.pop(context, true),
            showKey: false,
            showMore: true,
            onMoreTap: () => _more(),
            fondo: Colors.white,
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
                            GetStorage().write('pending_route', '/tiquet/${widget.idTique}');
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
            )
          );
        }

        final tiqueDetalle = snapshot.data!;
        return _contenido(context, tiqueDetalle);
      },
    );
  }

  Widget _contenido(BuildContext context, TiqueDetalle tiqueDetalle) {
    return MasterPage(
      title: con.capitalizarNombre(tiqueDetalle.usuarioSolicitante!.des!),
      onBack: () => Navigator.pop(context, true),
      showKey: false,
      showMore: true,
      onRefresh: () async { _recargar(); },
      onMoreTap: () => _more(),
      fondo: Colors.white,
      child: Obx(() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fila("WEB", "No"),
          _fila("kIsWeb", kIsWeb ? "Si" : "No"),
          _fila("ID Tique", tiqueDetalle.id.toString()),
          _fila("Cliente", con.capitalizarNombre(tiqueDetalle.empresa)),
          if (!_existeWpp.value)
          Text(
            "Atención: El número de telefono del solicitante no se encuentra en WhatsApp. (${detalle.usuarioSolicitante!.telefono!.trim()})",
            style: TextStyle(
              color: AppColors.semantics.text.error,
              fontSize: Fontsize.body
            ),
          ),
          if (!_existeWpp.value)
          GestureDetector(
            onTap: () {
              _agregarEditarNumero(detalle.usuarioSolicitante!.telefono!.trim());
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _focusNodeTelefono.requestFocus();
              });
            },
            child: Text(
              "Editar",
              style: TextStyle(
                decoration: TextDecoration.underline,
                decorationColor: AppColors.semantics.text.action,
                color: AppColors.semantics.text.action,
                fontSize: Fontsize.body
              ),
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
                    Text(
                      con.formatearFechayDia3(tiqueDetalle.fecsys),
                      style: TextStyle(
                        color: AppColors.semantics.text.secondary,
                        fontSize: Fontsize.body
                      ),
                    ),
                    const SizedBox(width: 8),
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
          const SizedBox(height: 16),
          Row(
            children: [
              if (tiqueDetalle.idestadovientri >= 0)
              Expanded(
                child: AppBadge(
                  text: con.capitalizar(tiqueDetalle.estado!.des ?? ""),
                  type: tiqueDetalle.estado!.des!.trim() == "ABIERTO" ? AppBadgeType.action : AppBadgeType.success,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _existeWpp.value
                ? () {
                  _enviarMsjPredeterminado();
                }
                : null,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.bolt,
                      size: 22,
                      color: _existeWpp.value ? AppColors.semantics.surface.actionPressed : AppColors.semantics.surface.secondaryAction,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Acción solicitada",
                      style: TextStyle(
                        color: _existeWpp.value ? AppColors.semantics.surface.actionPressed : AppColors.semantics.surface.secondaryAction,
                        fontSize: Fontsize.h3,
                        fontWeight: FontWeight.bold,
                      ),
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
            onTap: () => _verImagenFullscreen(decodeBase64Seguro(tiqueDetalle.img), tiqueDetalle.img),
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
                    tiqueDetalle.img.isNotEmpty
                        ? decodeBase64Seguro(tiqueDetalle.img)
                        : decodeBase64Seguro(base64ImagenVacia),
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) {
                      return Image.memory(
                        decodeBase64Seguro(base64ImagenVacia),
                        fit: BoxFit.contain,
                      );
                    },
                  )
                ),
              ),
            ),
          ),
          if (tiqueDetalle.img != "")
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Conversación",
                style: TextStyle(
                  color: AppColors.semantics.text.body,
                  fontSize: Fontsize.h3,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(
                  _conversacionExpandida
                      ? Icons.expand_less
                      : Icons.expand_more,
                  color: AppColors.semantics.text.body,
                ),
                onPressed: () {
                  setState(() {
                    _conversacionExpandida = !_conversacionExpandida;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_conversacionExpandida) _mensajes(tiqueDetalle),
          const SizedBox(height: 20),
          SizedBox(
            width: MediaQuery.sizeOf(context).width,
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 16,
              runSpacing: 8,
              children: [
                InkWell(
                  onTap: () => _enviarMsj(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        FontAwesomeIcons.message,
                        size: 18,
                        color: AppColors.semantics.surface.actionPressed,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Enviar mensaje",
                        style: TextStyle(
                          color: AppColors.semantics.surface.actionPressed,
                          fontSize: Fontsize.h3,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                InkWell(
                  onTap: () {
                    _comenzarAudio();
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.mic,
                        size: 22,
                        color: AppColors.semantics.surface.actionPressed,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Audio",
                        style: TextStyle(
                          color: AppColors.semantics.surface.actionPressed,
                          fontSize: Fontsize.h3,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.black12),
          const SizedBox(height: 16),
        ],
      )),
    );
  }

  Widget _fila(String label, String content) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppColors.semantics.text.secondary,
                  fontSize: Fontsize.h3,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                content,
                style: TextStyle(
                  color: AppColors.semantics.text.body,
                  fontSize: Fontsize.h3,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _mensajes(TiqueDetalle t) {
    return FutureBuilder<List<TiqueMensaje>>(
      future: _futureMensajes,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        if (snapshot.hasError || snapshot.hasData == false) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Error al obtener los mensajes",
                  style: TextStyle(
                    color: AppColors.semantics.text.secondary,
                    fontSize: Fontsize.h3,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _recargarMensajes,
                  child: Icon(Icons.refresh, color: AppColors.semantics.text.action),
                )
              ],
            ),
          );
        }

        final tiqueMensajes = snapshot.data!;

        return ListView(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            ...tiqueMensajes.map((m) =>              
              m.usuario == "" && m.mensaje.trim() != ""
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        con.formatearFechayDia3(m.fecSys),
                        style: TextStyle(
                          color: AppColors.semantics.text.body,
                          fontSize: Fontsize.body,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      if (t.usuarioSolicitante!.des! != "")
                      Text(
                        " | ${con.capitalizarNombre(t.usuarioSolicitante!.des!)}",
                        style: TextStyle(
                          color: AppColors.semantics.text.body,
                          fontSize: Fontsize.body,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextoExpandable(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    aligment: TextAlign.start,
                    texto: m.mensaje,
                    maxLines: 3,
                    style: TextStyle(
                      color: AppColors.semantics.text.body,
                      fontSize: Fontsize.body,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              )
              : m.adjunto == ""
                ? Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (m.usuario != "")
                        Text(
                          "${con.capitalizarNombre(m.usuario)} | ",
                          style: TextStyle(
                            color: AppColors.semantics.surface.actionPressed,
                            fontSize: Fontsize.body,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        Text(
                          con.formatearFechayDia3(m.fecSys),
                          style: TextStyle(
                            color: AppColors.semantics.surface.actionPressed,
                            fontSize: Fontsize.body,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextoExpandable(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      aligment: TextAlign.end,
                      texto: m.mensaje,
                      maxLines: 3,
                      style: TextStyle(
                        color: AppColors.semantics.text.action,
                        fontSize: Fontsize.body,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "${con.capitalizarNombre(m.usuario)} | ",
                        style: TextStyle(
                          color: AppColors.semantics.surface.actionPressed,
                          fontSize: Fontsize.body,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      Text(
                        con.formatearFechayDia3(m.fecSys),
                        style: TextStyle(
                          color: AppColors.semantics.surface.actionPressed,
                          fontSize: Fontsize.body,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.semantics.surface.action
                    ),
                    child: ValueListenableBuilder<String?>(
                      valueListenable: _audioIdActivo,
                      builder: (_, audioId, __) {
                        final activo = audioId == m.id.toString();

                        return ValueListenableBuilder<bool>(
                          valueListenable: _audioPlaying,
                          builder: (_, playing, __) {
                            final reproduciendo = activo && playing;

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    if (reproduciendo) {
                                      await _audioPlayer.pause();
                                      _audioPlaying.value = false;
                                      _audioIdEnPlayer = null;
                                    } else {
                                      await _playBase64(m.audio!, m.id.toString());
                                    }
                                  },
                                  child: Icon(
                                    reproduciendo
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    size: 35,
                                    color: Colors.white,
                                  ),
                                ),

                                reproduciendo
                                    ? const AnimatedBars()
                                    : _buildStaticBars(),

                                const Icon(
                                  CupertinoIcons.mic,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                  if (m.audio == "")
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "No es posible reproducir este audio",
                        style: TextStyle(
                          color: AppColors.semantics.text.error,
                          fontSize: Fontsize.body
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                  TextoExpandable(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    aligment: TextAlign.end,
                    texto: m.mensaje,
                    maxLines: 3,
                    style: TextStyle(
                      color: AppColors.semantics.text.action,
                      fontSize: Fontsize.body,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              )
            )
          ],
        );
      }
    );
  }

  Widget _buildStaticBars() {
    return Row(
      children: List.generate(
        15,
        (i) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 3,
          height: (8 + (i % 3) * 4).toDouble(),
          decoration: BoxDecoration(
            color: Colors.white60,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

  Uint8List decodeBase64Seguro(String base64) {
    final cleaned = base64.contains(',')
        ? base64.split(',').last
        : base64;
    return base64Decode(cleaned);
  }

  void _enviarMsjPredeterminado() {
    if (_rtasRapidas.isEmpty) return;
    ActionSheet.show(
      context,
      title: "Acción solicitada",
      content: StatefulBuilder(
        builder: (context, setState) {
          return SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.6,
            child: Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    itemCount: _rtasRapidas.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: Colors.transparent),
                    itemBuilder: (context, index) {
                      final opcion = _rtasRapidas[index];

                      return InkWell(
                        onTap: () {
                          setState(() => _estadoSeleccionado = index);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Radio<int>(
                                value: index,
                                groupValue: _estadoSeleccionado,
                                onChanged: (v) {
                                  setState(() => _estadoSeleccionado = v!);
                                },
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  con.capitalizar(opcion.nombre),
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.4,
                                    color: index == _estadoSeleccionado
                                        ? AppColors.semantics.text.body
                                        : AppColors.semantics.text.secondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SolidButton(
                    text: "Enviar",
                    leftIcon: CupertinoIcons.paperplane,
                    onPressed: () async {
                      final textoSeleccionado = _rtasRapidas[_estadoSeleccionado].nombre;
                      final idRespuesta = _rtasRapidas[_estadoSeleccionado].id;
                      bool ok = await con.responderTique(widget.idTique, idRespuesta, detalle.usuarioElegido!.contextId!.trim(), detalle.usuarioSolicitante!.telefono!.trim(), textoSeleccionado, "00", -1, detalle.usuarioElegido!.idUsr!,  widget.entidad.usuarioId);
                      if (ok) {
                        setState(() {
                          _recargar();
                        });
                        Navigator.pop(context, textoSeleccionado);
                      } else {
                        con.mostrarSnackbar(titulo: "Error", mensaje: "Vuelve a intentarlo mas tarde", esError: true);
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _enviarMsj() {
    ActionSheet.show(
      context,
      title: "Enviar mensaje",
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 348.0),
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: AppColors.semantics.border.action),
                boxShadow: AppShadows.elementFocusShadow,
                color: Colors.white,
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                style: TextStyle(
                  fontSize: Fontsize.body,
                  fontWeight: FontWeight.w400,
                  color: AppColors.semantics.text.body,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.fromLTRB(16.0, 13.0, 16.0, 13.0),
                  hintText: "Escribí un mensaje...",
                  hintStyle: TextStyle(
                    fontSize: Fontsize.body,
                    color: AppColors.semantics.text.secondary,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SubtleButton(
                    text: "Cancelar",
                    type: SubtleButtonType.brand,
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ),
                Expanded(
                  child: SolidButton(
                    text: "Enviar",
                    leftIcon: CupertinoIcons.paperplane,
                    onPressed: () async {
                      bool ok = await con.enviarMensajeTique(widget.idTique, _controller.text);
                      if (ok) {
                        setState(() {
                          _recargarMensajes();
                        });
                        Navigator.pop(context, true);
                      } else {
                        con.mostrarSnackbar(titulo: "Error", mensaje: "Vuelve a intentarlo", esError: true);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      _focusNode.requestFocus();
    });
  }

  void _comenzarAudio() async {
    await _startRecording();
    ActionSheet.show(
      context,
      title: "Grabar audio",
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Obx(
          () => Column(
            children: [
              Text(
                _formatSeconds(_audioSeconds.value),
                style: TextStyle(
                  fontSize: Fontsize.h3,
                  color: AppColors.semantics.text.body,
                ),
              ),

              const SizedBox(height: 12),

              if (_transcribiendo.value) ...[
                const SizedBox(height: 12),
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
                ),
              ]

              else if (_resumen.value.isNotEmpty)
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
                      keyboardType: TextInputType.multiline,
                      style: TextStyle(
                        fontSize: Fontsize.body,
                        color: AppColors.semantics.text.body,
                      ),
                      maxLines: 3,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (value) {
                        _transcripcion.value = value;
                        _transcripcionEditada.value = value.trim() != _transcripcionOriginal.trim();
                      },
                    ),

                    Obx(() {
                      if (!_transcripcionEditada.value) return const SizedBox.shrink();

                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                _transcripcionCtrl.text = _transcripcionOriginal;
                                _transcripcion.value = _transcripcionOriginal;
                                _transcripcionEditada.value = false;
                                _transcripcionFocus.unfocus();
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Icon(
                                  Icons.close,
                                  size: 18,
                                  color: AppColors.semantics.text.secondary,
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () async {
                                _transcribiendo.value = true;
                                _transcripcionOriginal = _transcripcionCtrl.text;
                                _transcripcionEditada.value = false;
                                _transcripcionFocus.unfocus();
                                _resumen.value = await con.generarResumenIaAudio(_transcripcion.value);
                                _transcribiendo.value = false;
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Icon(
                                  Icons.check,
                                  size: 18,
                                  color: AppColors.semantics.text.success,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 20),
                    Text(
                      "Resumen",
                      style: TextStyle(
                        fontSize: Fontsize.body,
                        color: AppColors.semantics.text.secondary,
                      ),
                    ),
                    Text(
                      _resumen.value,
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
                  /// DELETE
                  IconButton(
                    icon: Icon(
                      CupertinoIcons.delete,
                      color: AppColors.semantics.text.error,
                    ),
                    onPressed: () async {
                      if (_isRecording.value) {
                        await _recorder.stopRecorder();
                      }
                      _audioTimer?.cancel();
                      _isRecording.value = false;
                      Navigator.pop(context);
                    },
                  ),

                  /// PAUSE / RESUME
                  if (_isRecording.value)
                  IconButton(
                    icon: Icon(
                      _isPaused.value
                          ? Icons.play_arrow_rounded
                          : Icons.pause_rounded,
                      size: 32,
                    ),
                    onPressed: () async {
                      if (_isPaused.value) {
                        await _resumeRecording();
                      } else {
                        await _pauseRecording();
                      }
                    },
                  ),

                  /// OBTENER TRANSCRIPCION
                  if (_isRecording.value)
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
                        base64.value = await _stopAndGetBase64();
                        if (base64.value == "") return;
                      },
                    ),
                  ),

                  /// SEND
                  if (!_isRecording.value && !_transcribiendo.value)
                  !_loadingSend.value
                  ? Container(
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
                        _loadingSend.value = true;
                        dynamic rta = await con.enviarResumenAudioTique(
                          widget.idTique,
                          _resumen.value,
                          detalle.usuarioElegido!.des!,
                          "AUDIO"
                        );
                        if (rta["success"]) {
                          final rta2 = await con.adjuntarArchivoMsj(rta["data"]["id"], base64.value);
                          if (rta2["success"]) {
                            _recargarMensajes();
                            Navigator.pop(context);
                            _loadingSend.value = false;
                          } else {
                            con.mostrarSnackbar(
                              titulo: "Error",
                              mensaje: "No se pudo adjuntar el audio",
                              esError: true,
                            );
                            _loadingSend.value = false;
                          }
                        } else {
                          con.mostrarSnackbar(
                            titulo: "Error",
                            mensaje: "No se pudo enviar el audio",
                            esError: true,
                          );
                          _loadingSend.value = false;
                        }
                      },
                    )
                  )
                  : CircularProgressIndicator(color: AppColors.semantics.text.action, constraints: BoxConstraints(maxHeight: 20, minHeight: 20, maxWidth: 20, minWidth: 20))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _more() {
    setState(() {
      cargarDetalle();
    });
    ActionSheetOptions.show(
      context,
      title: "Acciones",
      options: [
        Opcion(id: 0, nombre: "Delegar"),
        Opcion(id: 1, nombre: "Cerrar tique"),
        if (detalle.usuarioSolicitante!.telefono!.trim() == "")
        Opcion(id: 2, nombre: "Añadir celular (WhatsApp)"),
        if (detalle.usuarioSolicitante!.telefono!.trim() != "")
        Opcion(id: 3, nombre: "Enviár mensaje a ${con.capitalizarNombre(detalle.usuarioSolicitante!.des!)}"),
        if (detalle.usuarioSolicitante!.telefono!.trim() != "")
        Opcion(id: 4, nombre: "Editar número (${detalle.usuarioSolicitante!.telefono!.trim()})"),
      ],
      onOptionSelected: (s) async {
        if (s.id == 0) {
          _delegar();
        } else if (s.id == 1) {
          bool ok = await con.responderTique(widget.idTique, 11, detalle.usuarioElegido!.contextId!.trim(), detalle.usuarioSolicitante!.telefono!.trim(), "SOLUCIONADO", "00", -1, detalle.usuarioElegido!.idUsr!,  widget.entidad.usuarioId);
          if (ok) {
            setState(() {
              _recargar();
            });
            con.mostrarSnackbar(titulo: "Éxito", mensaje: "Tique cerrado", esError: false);
          } else {
            con.mostrarSnackbar(titulo: "Error", mensaje: "No se pudo cerrar el tique", esError: true);
          }
        } else if (s.id == 2) {
          _agregarEditarNumero("");
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _focusNodeTelefono.requestFocus();
          });
        } else if (s.id == 3) {
          con.enviarMensajeWhatsApp(detalle.usuarioSolicitante!.telefono!.trim(), "Respondiendo tique N°${widget.idTique}\n\n");
        } else if (s.id == 4) {
          _agregarEditarNumero(detalle.usuarioSolicitante!.telefono!.trim());
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _focusNodeTelefono.requestFocus();
          });
        }
      },
    );

  }

  void _delegar() {
    final personas = [
      Opcion(
        id: 1,
        nombre: "Seba",
      ),
      Opcion(
        id: 2,
        nombre: "Leo",
      ),
      Opcion(
        id: 3,
        nombre: "Hernán",
      ),
    ];
    ActionSheet.show(
      context,
      title: "Delegar tique a:",
      content: StatefulBuilder(
        builder: (context, setState) {
          return SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.6,
            child: Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    itemCount: personas.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.transparent),
                    itemBuilder: (context, index) {
                      final estado = personas[index];
                      return InkWell(
                        onTap: () {
                          setState(() => _estadoSeleccionado = index);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 8,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Radio<int>(
                                value: index,
                                groupValue: _estadoSeleccionado,
                                onChanged: (v) {
                                  setState(() => _estadoSeleccionado = v!);
                                },
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  estado.nombre,
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.4,
                                    color: index == _estadoSeleccionado
                                      ? AppColors.semantics.text.body
                                      : AppColors.semantics.text.secondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SolidButton(
                    text: "Confirmar",
                    onPressed: () async {
                      final id = personas[_estadoSeleccionado].id;
                  
                      bool ok = await con.cambiarUsuarioEncargadoTique(widget.idTique, id);
                      if (ok) {
                        setState((){
                          _recargar();
                          Navigator.pop(context);
                        });
                      } else {
                        con.mostrarSnackbar(titulo: "Error", mensaje: "No se pudo delegar tique", esError: true);
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

  }

  void _agregarEditarNumero(String telefono) async {
    setState(() {
      _controllerTelefono.text = telefono;
    });
    ActionSheet.show(
      context,
      title: telefono == "" ? "Añadir número" : "Editar número",
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "WhatsApp",
              style: TextStyle(
                color: AppColors.semantics.text.body,
                fontSize: Fontsize.body
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: _existeWpp.value ? AppColors.semantics.text.success : AppColors.semantics.text.error),
                boxShadow: AppShadows.elementFocusShadow,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.chat_bubble,
                    size: 20,
                    color: AppColors.semantics.text.action,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      onSubmitted: (value) {},
                      focusNode: _focusNodeTelefono,
                      controller: _controllerTelefono,
                      keyboardType: TextInputType.number,
                      onChanged: (value) async {
                        setState(() {
                          _controllerTelefono.text = value;
                        });
                        _existeWpp.value = await con.validarNroWpp(value);
                      },
                      decoration: InputDecoration(
                        hintText: "WhatsApp",
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _existeWpp.value
              ? "El número está registrado en WhatsApp"
              : "El número no está registrado en WhatsApp",
              style: TextStyle(
                color: _existeWpp.value ? AppColors.semantics.text.success : AppColors.semantics.text.error,
                fontSize: Fontsize.body
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SubtleButton(
                    text: "Cancelar",
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                  ),
                ),
                Expanded(
                  child: SolidButton(
                    text: "Guardar",
                    leftIcon: Icons.save_rounded,
                    onPressed: _existeWpp.value
                    ? () async {
                      bool ok = await con.editarAgregarTelefono(_controllerTelefono.text, detalle.usuarioSolicitante!.idUsr!, detalle.usuarioSolicitante!.idbasededatos!);
                      if (ok) {
                        Navigator.pop(context, true);
                        setState(() {
                          _recargar();
                        });
                      } else {
                        con.mostrarSnackbar(titulo: "Error", mensaje: telefono == "" ? "No se pudo agendar el número" : "No se pudo editar el número", esError: true);
                      }
                    }
                    : null,
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ));
  }

  void _verImagenFullscreen(Uint8List imagen, String img) {
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
                    imagen.isNotEmpty
                        ? decodeBase64Seguro(img)
                        : decodeBase64Seguro(base64ImagenVacia),
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) {
                      return Image.memory(
                        decodeBase64Seguro(base64ImagenVacia),
                        fit: BoxFit.contain,
                      );
                    },
                  )
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
