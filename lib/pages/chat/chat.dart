// ignore_for_file: avoid_print, no_leading_underscores_for_local_identifiers
import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vientri/components/action_sheet_options/action_sheet_options.dart';
import 'package:vientri/components/badge/badge.dart';
import 'package:vientri/components/heading/heading.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/pages/chat/ayuda_chat.dart';
import 'package:vientri/pages/controller.dart';
import 'package:vientri/src/models/entidad.dart';
import 'package:vientri/src/models/opcion.dart';
import 'package:permission_handler/permission_handler.dart';

class Chat extends StatefulWidget {
  final Entidad entidad;
  const Chat({super.key, required this.entidad});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> with TickerProviderStateMixin {
  late Controller con;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  StreamSubscription? _playerSub;
  final Map<int, int> _durationsMs = {};
  Timer? _recordTimer;
  int _recordSeconds = 0;
  bool verPrevisualizacion = false;
  var duracion = "";
  String? tempPath;
  String? tempDuration;

  late AnimationController _controllerAnimation;
  late Animation<double> _scaleAnimation;

  String typingText = "";
  bool isTyping = false;

  final box = GetStorage();
  final FlutterSoundRecorder recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer player = FlutterSoundPlayer();

  List<Map<String, dynamic>> audios = [];

  bool isRecording = false;
  int? playingIndex;
  double progress = 0.0;

  int previewPosMs = 0;
  int previewDurMs = 1;
  StreamSubscription? _previewSub;
  late bool motorWpp;

  var loading = false.obs; // loading en boton de msj ia

  final NumberFormat formatter = NumberFormat("#,##0.00", "en_US");

  bool _canStopRecording = false;
  bool _requestingPermission = false;


  @override
  void initState() {
    super.initState();
    con = Get.put(Controller(widget.entidad));

    audios = box.read<List>('mensajes${widget.entidad.nombre}')?.cast<Map<String, dynamic>>() ?? [];
    motorWpp = GetStorage().read('usaMotorWpp${widget.entidad.usuario}') ?? false;
    initRecorder();
    player.openPlayer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom(1);
    });

    _controllerAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(CurvedAnimation(parent: _controllerAnimation, curve: Curves.easeInOut));
  }

  Future<void> initRecorder() async {
    await recorder.openRecorder();
    await recorder.setSubscriptionDuration(const Duration(milliseconds: 200));
  }

  @override
  void dispose() {
    _playerSub?.cancel();
    recorder.closeRecorder();
    player.closePlayer();
    _focusNode.dispose();
    _controller.dispose();
    _controllerAnimation.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  String formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDate = DateTime(date.year, date.month, date.day);

    if (msgDate == today) return "Hoy";
    if (msgDate == today.subtract(const Duration(days: 1))) return "Ayer";

    return "${msgDate.day.toString().padLeft(2,'0')}/${msgDate.month.toString().padLeft(2,'0')}/${msgDate.year}";
  }

  Future<bool> _checkAudioPermission(BuildContext context) async {
    final status = await Permission.microphone.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await Permission.microphone.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      _showPermissionDialog(context);
      return false;
    }

    return false;
  }

  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Permiso requerido"),
        content: const Text(
          "Para grabar audio necesitás habilitar el acceso al micrófono en la configuración de la app.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: const Text("Abrir configuración"),
          ),
        ],
      ),
    );
  }

  Future<void> startRecording({required bool tap}) async {
    // Evitar dobles ejecuciones
    if (_requestingPermission || isRecording) return;

    _requestingPermission = true;

    final hasPermission = await _checkAudioPermission(context);

    _requestingPermission = false;

    if (!hasPermission || !mounted) return;

    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';

    try {
      await recorder.startRecorder(toFile: path);

      if (!mounted) return;

      setState(() {
        isRecording = true;
        _canStopRecording = true; // 👈 CLAVE
        _recordSeconds = 0;
        duracion = "";
      });

      _controllerAnimation.repeat(reverse: true);

      _recordTimer?.cancel();
      _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() => _recordSeconds++);
      });
    } catch (e) {
      debugPrint("Error al iniciar grabación: $e");
      _canStopRecording = false;
    }
  }

  Future<void> stopRecording() async {
    // 🔴 SI NO SE INICIÓ DE VERDAD → NO HACER NADA
    if (!_canStopRecording || !isRecording) return;

    _canStopRecording = false;

    duracion = _formatTime(_recordSeconds);
    _recordTimer?.cancel();

    final path = await recorder.stopRecorder();
    if (path == null || !mounted) return;

    _controllerAnimation.stop();
    _controllerAnimation.reset();

    audios.add({
      "type": "audio",
      "path": path,
      "duration": duracion,
      "timestamp": DateTime.now().toIso8601String(),
      "fromUser": true,
      "isPreview": true,
      "isText": false,
      "currentSeconds": 0,
      "totalSeconds": _secondsFromDurationString(duracion),
      "transcripcion": null,
    });

    setState(() {
      isRecording = false;
      verPrevisualizacion = true;
      tempPath = path;
      tempDuration = duracion;
    });

    final textoTraducido = await con.transcribirAudio(path);
    final index = audios.lastIndexWhere((a) => a["isPreview"] == true);

    if (index != -1 && mounted) {
      setState(() {
        audios[index]["transcripcion"] =
            textoTraducido.isEmpty ? "No se pudo traducir" : textoTraducido;
      });
    }
  }

  int _secondsFromDurationString(String mmss) {
    try {
      final parts = mmss.split(':');
      final min = int.parse(parts[0]);
      final sec = int.parse(parts[1]);
      return min * 60 + sec;
    } catch (e) {
      return 0;
    }
  }

  void _scrollToBottom(int seg) {
    if (!_scrollController.hasClients) return;

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 1000,
      duration: Duration(milliseconds: seg),
      curve: Curves.easeOut,
    );
  }

  Future<void> togglePlay(String path, int index, String duration) async {
    if (playingIndex == index) {
      await player.stopPlayer();
      await _playerSub?.cancel();


      setState(() {
        playingIndex = null;
        progress = 0.0;
      });
      return;
    }

    if (playingIndex != null) {
      await player.stopPlayer();
      await _playerSub?.cancel();


      setState(() {
        playingIndex = null;
        progress = 0.0;
      });
    }

    playingIndex = index;
    progress = 0;
    setState(() {});


    await player.startPlayer(
      fromURI: path,
      whenFinished: () async {
        await _playerSub?.cancel();
        if (!mounted) return;

        setState(() {
          playingIndex = null;
          progress = 0.0;
        });

      },
    );

    _playerSub = player.onProgress?.listen((event) {
      final durMs = event.duration.inMilliseconds;
      final posMs = event.position.inMilliseconds;

      if (durMs > 0) {
        _durationsMs[index] = durMs;
      }

      if (!mounted) return;

      setState(() {
        progress = durMs > 0 ? posMs / durMs : 0;

        // segundos transcurridos
        audios[index]["currentSeconds"] = (posMs / 1000).floor();
        audios[index]["totalSeconds"] = (durMs / 1000).floor();
      });
    });
  }

  Stream<String> contadorHasta(String maxTime) async* {
    // Parsear "MM:SS"
    final parts = maxTime.split(":");
    final minutos = int.parse(parts[0]);
    final segundos = int.parse(parts[1]);
    final totalSegundos = minutos * 60 + segundos;

    // Contador desde 1 hasta totalSegundos
    for (int i = 1; i <= totalSegundos; i++) {
      final m = (i ~/ 60).toString().padLeft(2, '0');
      final s = (i % 60).toString().padLeft(2, '0');
      yield "$m:$s";
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  Future<void> previewPlay() async {
    if (tempPath == null) return;

    // Si ya está en modo preview playback → detener
    if (playingIndex == -1) {
      await player.stopPlayer();
      await _previewSub?.cancel();

      setState(() {
        playingIndex = null;
        previewPosMs = 0;
      });
      return;
    }

    // Iniciar preview playback
    playingIndex = -1;
    previewPosMs = 0;
    previewDurMs = 1;
    setState(() {});

    await player.startPlayer(
      fromURI: tempPath!,
      whenFinished: () async {
        await _previewSub?.cancel();
        if (!mounted) return;
        setState(() {
          playingIndex = null;
          previewPosMs = 0;
        });
      },
    );

    // Listener de progreso
    _previewSub = player.onProgress?.listen((event) {
      if (!mounted) return;

      setState(() {
        previewPosMs = event.position.inMilliseconds;
        previewDurMs = event.duration.inMilliseconds > 0
            ? event.duration.inMilliseconds
            : previewDurMs; // evitar dividir por cero
      });
    });
  }

  void previewDelete() {
    if (tempPath != null) {
      try { File(tempPath!).deleteSync(); } catch (_) {}
    }

    audios.removeWhere((m) => m["isPreview"] == true);

    box.write('mensajes${widget.entidad.nombre}', audios);

    tempPath = null;
    tempDuration = null;

    setState(() {
      verPrevisualizacion = false;
      playingIndex = null;
    });
  }

  void previewSend() async {
    if (tempPath == null) return;

    final index = audios.indexWhere((m) => m["isPreview"] == true);
    if (index == -1) return;

    final msg = audios[index];

    msg["isPreview"] = false;

    box.write('mensajes${widget.entidad.nombre}', audios);

    setState(() {
      verPrevisualizacion = false;
      playingIndex = null;
    });

    await procesarMensaje(msg);
  }

  void sendTextMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final now = DateTime.now();

    final mensaje = {
      "type": "text",
      "text": text,
      "timestamp": now.toIso8601String(),
      "isText": true,
      "fromUser": true,
    };

    audios.add(mensaje);

    box.write('mensajes${widget.entidad.nombre}', audios);

    _controller.clear();
    setState(() {});
    _scrollToBottom(300);

    await procesarMensaje(mensaje);
  }

  Future<void> procesarMensaje(Map<String, dynamic> mensajeUsuario) async {
    setState(() {});
    _scrollToBottom(200);

    // 2. Inserto un mensaje vacío de IA (LOADING)
    audios.add({
      "fromUser": false,
      "isText": false,
      "isLoading": true,
      "titulo": "",
      "campos": [],
      "timestamp": DateTime.now().toIso8601String(),
    });

    final int indexIa = audios.length - 1;

    setState(() {});
    _scrollToBottom(200);

    // 3. Espero respuesta IA
    final respuesta = await obtenerRespuestaIA(mensajeUsuario["type"] == "text" ? mensajeUsuario["text"] : mensajeUsuario["transcripcion"]);

    // 4. Reemplazo LOADING con la respuesta real
    audios[indexIa] = {
      "fromUser": false,
      "isText": false,
      "isLoading": false,
      "timestamp": DateTime.now().toIso8601String(),
      "titleGeneral": respuesta["titleGeneral"],
      "blocks": respuesta["blocks"],
    };


    box.write('mensajes${widget.entidad.nombre}', audios);

    setState(() {});
    _scrollToBottom(200);
  }

  Future<Map<String, dynamic>> obtenerRespuestaIA(String mensaje) async {
    if (motorWpp) {
      if (await con.enviarWpp(context, "5493513891754", mensaje, "", "")) {
        return {
          "messageId": "abc123",
          "titleGeneral": "Lo sentimos.",
          "blocks": [
            {
              "type": "error",
              "title": "No se pudo enviar tu mensaje.",
            }
          ]
        };
      }
      return {
        "titulo": "Lo sentimos.",
      };
    } else {
      var rta = await con.enviarMsjBackend();
      if (rta.isNotEmpty) {
        print("RTA BACKEND: $rta");
        return rta;
      }
      return {
        "titulo": "Lo sentimos.",
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            children: [
              _header(),
          
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.zero,
                  itemCount: audios.length,
                  itemBuilder: (context, index) {
                    final msg = audios[index];
          
                    if (msg["isPreview"] == true) {
                      return const SizedBox(); 
                    }
          
                    final date = DateTime.parse(msg["timestamp"]);
                    final bool isText = msg["isText"] == true;
                    final bool fromUser = msg["fromUser"] == true;
          
                    final String? textMsg = msg["text"];
                    final String? path = msg["path"];
                    final String? duration = msg["duration"];
          
                    final currentDate = formatDate(date);
                    final bool showHeader = index == 0 || formatDate(DateTime.parse(audios[index - 1]["timestamp"])) != currentDate;
          
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showHeader)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                              decoration: BoxDecoration(
                                color: AppColors.semantics.surface.secondaryAction,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                currentDate,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: Fontsize.body,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
          
                        fromUser
                        ? isText
                          ? _buildTextMessage(textMsg!, date, true)
                          : _buildAudioMessage(path!, duration!, index, date, true, msg)
                        : _buildIaMessage(index)
                      ],
                    );
                  },
                ),
              ),
          
              _recordBar()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStaticBars() {
    return Row(
      children: List.generate(
        10,
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

  Widget _buildAnimatedBars() {
    return Row(
      children: List.generate(
        10,
        (i) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 3,
          height: (8 + (i % 3) * 4).toDouble(),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

  Widget _recordBar() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: isRecording ? AppColors.semantics.text.action : Colors.transparent,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: Colors.black12),
          ),
          child: verPrevisualizacion
          ? _buildPreviewBar()
          : _buildNormalBar(),
        ),

        if (isRecording)
          Positioned(
            right: 8,
            child: GestureDetector(
              onTap: stopRecording,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 25,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Icon(
                    CupertinoIcons.mic_fill,
                    size: 34,
                    color: AppColors.semantics.text.action,
                  ),
                ),
              ),
            )
          ),

      ],
    );
  }

  Widget _buildPreviewBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        audios.last["transcripcion"] == null
        ? CircularProgressIndicator(constraints: BoxConstraints(minHeight: 10, maxHeight: 10, maxWidth: 10, minWidth: 10), strokeWidth: 2)
        : Text(
          audios.last["transcripcion"] ?? "Espere un segundo",
          style: TextStyle(
            color: AppColors.semantics.text.body,
            fontSize: Fontsize.body
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            GestureDetector(
              onTap: previewDelete,
              child: Icon(
                CupertinoIcons.delete,
                color: AppColors.semantics.text.error,
                size: 30,
              ),
            ),
        
            Expanded(
              child: GestureDetector(
                onTap: previewPlay,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.semantics.text.action,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        playingIndex == -1
                            ? CupertinoIcons.pause
                            : CupertinoIcons.play,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        duracion,
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        
            GestureDetector(
              onTap: previewSend,
              child: Icon(
                CupertinoIcons.paperplane,
                color: AppColors.semantics.text.action,
                size: 30,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNormalBar() {
    return Row(
      children: [
        Expanded(
          child: isRecording
          ? Text(
              _formatTime(_recordSeconds),
              style: TextStyle(
                color: Colors.white,
                fontSize: Fontsize.h3,
              ),
            )
          : TextField(
              focusNode: _focusNode,
              controller: _controller,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: "Escribí una petición",
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: Fontsize.body,
                ),
                isDense: true,
              ),
            ),
        ),

        const SizedBox(width: 8),

        GestureDetector(
          onTap: _controller.text.trim().isNotEmpty ? sendTextMessage : null,
          onLongPress: _controller.text.trim().isEmpty
              ? () => startRecording(tap: false)
              : null,
          onLongPressUp: _controller.text.trim().isEmpty
              ? stopRecording
              : null,
          child: Icon(
            _controller.text.trim().isNotEmpty
                ? CupertinoIcons.paperplane
                : CupertinoIcons.mic,
            color: AppColors.semantics.text.action,
            size: 30,
          ),
        ),
      ],
    );
  }

  Widget _buildTextMessage(String text, DateTime date, bool fromUser) {

    final alignment = fromUser ? MainAxisAlignment.end : MainAxisAlignment.start;
    final bubbleColor = fromUser
        ? AppColors.semantics.text.action
        : Colors.grey.shade300;
    final textColor = fromUser ? Colors.white : Colors.black87;
    final timePadding = fromUser
        ? const EdgeInsets.only(bottom: 10, right: 8, top: 2)
        : const EdgeInsets.only(bottom: 10, left: 8, top: 2);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: alignment,
        children: [
          Column(
            crossAxisAlignment: fromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: fromUser
                      ? BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20), bottomLeft: Radius.circular(20))
                      : BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20), bottomRight: Radius.circular(20))
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: Fontsize.body,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: timePadding,
                child: Text(
                  "${date.hour.toString().padLeft(2,'0')}:${date.minute.toString().padLeft(2,'0')}",
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: Fontsize.body,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAudioMessage(String path, String duration, int index, DateTime date, bool fromUser, dynamic msg) {
    final isPlaying = playingIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: fromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: fromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: fromUser
                      ? AppColors.semantics.text.action
                      : Colors.grey.shade300,
                    borderRadius: fromUser
                      ? BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20), bottomLeft: Radius.circular(20))
                      : BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20), bottomRight: Radius.circular(20))
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        duration,
                        style: TextStyle(fontSize: Fontsize.body, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      isPlaying ? _buildAnimatedBars() : _buildStaticBars(),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: () {
                          togglePlay(path, index, duration);
                        },
                        child: Icon(
                          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: fromUser ? Colors.white : Colors.black87,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: fromUser
                    ? const EdgeInsets.only(bottom: 10, right: 8, top: 2)
                    : const EdgeInsets.only(bottom: 10, left: 8, top: 2),
                child: Text(
                  "${date.hour.toString().padLeft(2,'0')}:${date.minute.toString().padLeft(2,'0')}",
                  style: TextStyle(color: Colors.black45, fontSize: Fontsize.body),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: AppHeading(
                label: "Chat",
                fontSize: Fontsize.h1,
                leadingIcon: Icons.arrow_back,
                iconSize: 30,
                onLeadingIconPressed: () => Navigator.pop(context, true),
              ),
            ),

            // Toggle WhatsApp
            Row(
              children: [
                Icon(FontAwesomeIcons.whatsapp, color: motorWpp ? AppColors.semantics.text.success : AppColors.semantics.text.secondary),
                Transform.scale(
                  scale: 0.85,
                  child: Switch(
                    value: motorWpp,
                    onChanged: (value) {
                      setState(() {
                        motorWpp = value;
                        GetStorage().write('usaMotorWpp${widget.entidad.usuario}', motorWpp);
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),

            // Botón Ayuda
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        AyudaChat(entidad: widget.entidad),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      final tween = Tween(begin: begin, end: end)
                          .chain(CurveTween(curve: Curves.ease));
                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 400),
                  ),
                );
              },
              child: Icon(Icons.help_outline_rounded,
                  color: AppColors.semantics.text.body, size: 30),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIaMessage(int index) {
    final msg = audios[index];

    if (msg["isLoading"] == true) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 12),
            Text("Procesando..."),
          ],
        ),
      );
    }
    
    final String titleGeneral = msg["titleGeneral"] ?? "";

    final Map<String, dynamic> blocksMap =
        Map<String, dynamic>.from(msg["blocks"] ?? {});

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blocksMap.values.map<Widget>((block) {
        final Map<String, dynamic> b = Map<String, dynamic>.from(block);

        // 🔒 NORMALIZAR DATA
        final rawData = b["data"];
        final List<Map<String, dynamic>> dataList =
            rawData is List
                ? rawData.map<Map<String, dynamic>>(
                    (e) => Map<String, dynamic>.from(e),
                  ).toList()
                : [];

        // 🔒 NORMALIZAR SCHEME
        final rawScheme = b["scheme"];
        final List<Map<String, dynamic>> schemeList =
            rawScheme is List
                ? rawScheme.map<Map<String, dynamic>>(
                    (e) => Map<String, dynamic>.from(e),
                  ).toList()
                : [];

        return _datosListadosCard(
          titleGeneral,
          dataList,
          schemeList,
        );
      }).toList(),
    );
  }

  Widget _datosListadosCard(
    String title,
    List<Map<String, dynamic>> dataList,
    List<Map<String, dynamic>> scheme,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          ...dataList.map<Widget>((row) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                children: scheme.map<Widget>((s) {
                  final String field = s["content"]; // 👈 OJO: se llama content
                  final String label = s["label"];

                  final value = row[field];

                  if (value == null || value.toString().isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text(
                            label,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        Expanded(child: Text(value.toString())),
                      ],
                    ),
                  );
                }).toList(),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget listaComprobantesCard(String title, List items, List? options) {
    final bool hasAnyOptionEnabled = options != null && options.isNotEmpty && (options.first as Map<String, dynamic>).values.any((v) => v == true);
    final List<Opcion> _options = [];

    if (options != null && options.isNotEmpty) {
      final Map<String, dynamic> opts =
          options.first as Map<String, dynamic>;

      opts.forEach((key, value) {
        if (value == true) {
          _options.add(
            Opcion(
              id: _mapOptionToId(key),
              nombre: _mapOptionToLabel(key),
            ),
          );
        }
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.semantics.text.body),
          ),
        ),
        ...items.map((item) {
          final List data = item["data"] ?? [];
          String? campo1;
          String? campo2;
          String? campo3;
          dynamic campo4;
          dynamic campo5;

          if (data.isNotEmpty) campo1 = data.isNotEmpty ? data[0]["content"]?.toString() : null;
          if (data.length > 1) campo2 = data.isNotEmpty ? data[1]["content"]?.toString() : null;
          if (data.length > 2) campo3 = data.isNotEmpty ? data[2]["content"]?.toString() : null;
          if (data.length > 3) campo4 = data.isNotEmpty ? data[3]["content"]?.toString() : null;
          if (data.length > 4) campo5 = data.isNotEmpty ? data[4]["content"]?.toString() : null;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Campo 1 → título principal
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Text(
                        campo1 ?? "",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: Fontsize.body,
                          color: AppColors.semantics.text.body,
                        ),
                      ),
                    ),

                    /// Campo 4 → badge (si existe)
                    if (campo4 != null)
                      Expanded(
                        flex: 3,
                        child: AppBadge(
                          text: campo4.toString(),
                          type: campo4.toString() == "vencido"
                              ? AppBadgeType.error
                              : AppBadgeType.information,
                        ),
                      ),

                    if (hasAnyOptionEnabled)
                      GestureDetector(
                        onTap: () {
                          ActionSheetOptions.show(
                            context,
                            title: campo1 ?? title,
                            options: _options,
                            onOptionSelected: (_) {},
                          );
                        },
                        child: Icon(Icons.more_vert_rounded,
                            color: AppColors.semantics.text.action),
                      ),
                  ],
                ),

                // Campo 2 → importe
                Text(
                  "\$${formatter.format(double.parse(campo2!))}",
                  style: TextStyle(
                    fontSize: Fontsize.body,
                    color: AppColors.semantics.text.body,
                  ),
                ),

                // Campo 3 + Campo 5 → info secundaria
                _tablaIconos(
                  campo3 ?? "",
                  3,
                  campo5 != null ? "\$${formatter.format(double.parse(campo5))}" : "",
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        })
      ]
    );
  }

  int _mapOptionToId(String key) {
    switch (key) {
      case "facturar":
        return 1;
      case "descargarPdf":
        return 2;
      case "enviarWpp":
        return 3;
      case "resumenCtaCte":
        return 4;
      case "verEstadoCuenta":
        return 5;
      default:
        return 0;
    }
  }

  String _mapOptionToLabel(String key) {
    switch (key) {
      case "facturar":
        return "Facturar";
      case "descargarPdf":
        return "Descargar PDF";
      case "enviarWpp":
        return "Enviar por WhatsApp";
      case "resumenCtaCte":
        return "Resumen Cta. Cte.";
      case "verEstadoCuenta":
        return "Ver estado de cuenta";
      default:
        return key;
    }
  }

  Widget accionesCard(Map<String, dynamic> block) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          if (block["resumenCtaCte"] == true)
            _accionButton("Resumen de cuenta corriente", Icons.menu_rounded, "resumenCtaCte"),

          if (block["verEstadoCuenta"] == true)
            _accionButton("Ver estado de cuenta", CupertinoIcons.arrow_up_right, "verEstadoCuenta"),

          if (block["facturar"] == true)
            _accionButton("Facturar", Icons.receipt_long, "facturar"),
          
          if (block["descargarPdf"] == true)
            _accionButton("Descargar PDF", Icons.picture_as_pdf, "descargarPdf"),

          if (block["enviarWpp"] == true)
            _accionButton("Enviar por WhatsApp", FontAwesomeIcons.whatsapp, "enviarWpp"),
        ],
      ),
    );
  }

  Widget errorCard(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: Fontsize.body, color: AppColors.semantics.text.secondary),
          ),
        ],
      ),
    );
  }

  Widget _accionButton(String label, IconData icon, String action) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _onIaAction(action),
        child: Container(
          height: 50,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black12)),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: AppColors.semantics.text.action,
                size: 24,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.semantics.text.action
                ),
              )
            ],
          ),
        ),
      )
    );
  }

  void _onIaAction(String action) {
    switch (action) {
      case "descargarPdf":
        print("Descargar PDF");
        break;

      case "enviarWpp":
        print("Enviar WhatsApp");
        break;

      case "facturar":
        print("Facturar");
        break;

      case "verEstadoCuenta":
        print("Ver estado de cuenta");
        break;

      case "resumenCtaCte":
        print("Ver resumen de cuenta corriente");
        break;
    }
  }

  Widget _tablaIconos(String fecha, int items, String monto) {
    return Wrap(
      spacing: 16,
      runSpacing: 0,
      children: [
        _cellIcon(
          const Icon(CupertinoIcons.calendar, size: 18),
          fecha.toString(),
        ),
        _cellIcon(
          const Icon(CupertinoIcons.cube_box, size: 18),
          items.toString(),
        ),
        if (monto.isNotEmpty)
          _cellIcon(
            const Icon(CupertinoIcons.info_circle, size: 18),
            monto,
            AppColors.semantics.text.error,
          ),
      ],
    );
  }

  Widget _cellIcon(Icon icon, String text, [Color? color]) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon.icon, size: 18, color: color ?? AppColors.semantics.text.secondary),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: color ?? AppColors.semantics.text.secondary,
            fontSize: 14,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

}
