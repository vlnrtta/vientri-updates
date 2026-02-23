import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart'; 
import 'package:intl/intl.dart';
import 'package:vientri/components/heading/heading.dart';
import 'package:vientri/components/solid_button/solid_button.dart';
import 'package:vientri/constants/app_colors.dart';
import 'package:vientri/constants/app_fontsize.dart';
import 'package:vientri/constants/app_shadows.dart';
import 'package:vientri/constants/cronometro.dart';
import 'package:vientri/constants/notificaciones.dart';
import 'package:vientri/pages/controller.dart';
import 'package:vientri/pages/stock/estado_control.dart';
import 'package:vientri/src/models/control.dart';
import 'package:vientri/src/models/entidad.dart';

// ignore: must_be_immutable
class NuevoControl extends StatefulWidget {
  Entidad entidad;
  Control control;
  NuevoControl({super.key, required this.entidad, required this.control});

  @override
  State<NuevoControl> createState() => _NuevoControlState();
}

class _NuevoControlState extends State<NuevoControl> {
  late Controller con;
  final cronometro = Get.put(CronometroController());
  late ScrollController _scrollController;

  int activeIndex = 0;
  final Map<int, GlobalKey> itemKeys = {};
  final RxMap<int, int> cantidades = <int, int>{}.obs;
  final RxMap<int, String> horas = <int, String>{}.obs;
  RxBool habilitado = false.obs;

  final RxBool isPressed = false.obs;
  final RxString pressedKey = ''.obs;
  final value = 0.obs;

  final box = GetStorage();

  // temporizador
  late DateTime horaIni;
  late Timer timer;
  String tiempoFormateado = "00:00:00";

  @override
  void initState() {
    super.initState();
    con = Get.put(Controller(widget.entidad));
    cargarControl();
    _cargarDesdeMemoria(); 
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToItem(activeIndex);
    });
    cronometro.setControl(widget.control);
    cronometro.iniciar(widget.control.id.toString());

    for (var i = 0; i < widget.control.articulos.length; i++) {
      itemKeys[i] = GlobalKey();
    }

    // temporizador
    try {
      horaIni = DateTime.parse(widget.control.horaIni);
    } catch (e) {
      horaIni = DateTime.now().toUtc().add(const Duration(hours: -3));
    }

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final ahora = DateTime.now().toUtc().add(const Duration(hours: -3));
      final duracion = ahora.difference(horaIni);

      final horas = duracion.inHours.toString().padLeft(2, '0');
      final minutos = (duracion.inMinutes % 60).toString().padLeft(2, '0');
      final segundos = (duracion.inSeconds % 60).toString().padLeft(2, '0');

      setState(() {
        tiempoFormateado = "$horas:$minutos:$segundos";
      });
    });
    _todosConHoraAsignada();
  }

  void cargarControl() async {
    final data = await con.detalleControl(widget.control.id);
    setState(() {
      widget.control = data;
    });
  }

  void _cargarDesdeMemoria() {
    final saved = box.read("control_${widget.control.id}");
    if (saved != null) {
      final decoded = jsonDecode(saved);
      final savedCantidades = Map<String, dynamic>.from(decoded["cantidades"]);
      final savedHoras = Map<String, dynamic>.from(decoded["horas"]);
      cantidades.clear();
      horas.clear();
      savedCantidades.forEach((k, v) => cantidades[int.parse(k)] = v);
      savedHoras.forEach((k, v) => horas[int.parse(k)] = v);
      _todosConHoraAsignada();
    }
  }

  void _guardarEnMemoria() {
    final data = {
      "cantidades": cantidades.map((k, v) => MapEntry(k.toString(), v)),
      "horas": horas.map((k, v) => MapEntry(k.toString(), v)),
    };
    box.write("control_${widget.control.id}", jsonEncode(data));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    timer.cancel();
    super.dispose();
  }
  
  void scrollToItem(int index) {
    final double itemHeight = 80;
    final double targetPosition = itemHeight * (index - 1);

    double offset = targetPosition;
    if (offset < 0) offset = 0;
    if (offset > _scrollController.position.maxScrollExtent) {
      offset = _scrollController.position.maxScrollExtent;
    }

    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  void _todosConHoraAsignada() {
    final todos = List.generate(widget.control.articulos.length, (i) => i)
        .every((i) => horas[i] != null && horas[i]!.isNotEmpty);

    habilitado.value = todos;
  }

  void _onKeyTap(BuildContext context, String key) {
    if (activeIndex == -1) return;

    final currentValue = cantidades[activeIndex] ?? 0;

    if (key == '⌫') {
      if (currentValue > 0) {
        final str = currentValue.toString();
        cantidades[activeIndex] =
            str.length > 1 ? int.parse(str.substring(0, str.length - 1)) : 0;

        horas[activeIndex] = con.getHoraActual();
        _guardarEnMemoria();
      }

      _todosConHoraAsignada();
      return;
    }

    if (key == '↵') {
      if (activeIndex < widget.control.articulos.length - 1) {
        setState(() => activeIndex += 1);
        scrollToItem(activeIndex);
      }

      _todosConHoraAsignada();
      return;
    }

    // NÚMERO PRESIONADO
    final newValue = currentValue == 0 ? key : '$currentValue$key';
    final parsed = int.parse(newValue);

    if (parsed <= 9999997) {
      cantidades[activeIndex] = parsed;
      horas[activeIndex] = con.getHoraActual();
      _guardarEnMemoria();

      if (activeIndex < widget.control.articulos.length - 1) {
        final next = activeIndex + 1;
        Future.delayed(const Duration(milliseconds: 50), () {
          scrollToItem(next);
        });
      }
    }

    _todosConHoraAsignada();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: NotificationWrapper(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: Stack(
            children: [
              Container(color: Colors.white),

              Column(
                children: [
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: AppHeading(
                        label: con.capitalizar(widget.control.ubicacion),
                        fontSize: Fontsize.h1,
                        leadingIcon: Icons.arrow_back,
                        iconSize: 26,
                        onLeadingIconPressed: () {
                          Navigator.pop(context, true);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              color: AppColors.semantics.text.body,
                              size: Fontsize.h2,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Cronómetro",
                              style: TextStyle(
                                color: AppColors.semantics.text.body,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          tiempoFormateado,
                          style: TextStyle(
                            fontSize: Fontsize.body,
                            color: AppColors.semantics.text.body,
                          ),
                        )
                        /*Obx(() => Text(
                          cronometro.tiempoFormateado(widget.control.id.toString()),
                          style: TextStyle(
                            fontSize: Fontsize.body,
                            color: AppColors.semantics.text.body,
                          ),
                        )),*/
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 16 + MediaQuery.of(context).viewInsets.bottom),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        controller: _scrollController,
                        physics: const ClampingScrollPhysics(),
                        itemCount: widget.control.articulos.length,
                        itemBuilder: (context, index) {
                          final result = widget.control.articulos[index];
                          final isActive = index == activeIndex;

                          return GestureDetector(
                            key: itemKeys[index],
                            onTap: () {
                              setState(() => activeIndex = index);
                              scrollToItem(index); 
                            },
                            child: Container(
                              height: 80,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: const BoxDecoration(
                                border: Border(bottom: BorderSide(color: Colors.black12)),
                                color:Colors.white,
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 48,
                                    height: 48,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: _buildFruitImageFull(result.foto),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Wrap(
                                          crossAxisAlignment: WrapCrossAlignment.center,
                                          spacing: 8,
                                          runSpacing: 4,
                                          children: [
                                            Text(
                                              con.capitalizar(result.rubroDes.trim()),
                                              style: TextStyle(
                                                fontSize: Fontsize.bodySmall,
                                                color: AppColors.semantics.text.body,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              "#${result.articuloCod.trim()}",
                                              style: TextStyle(
                                                color: AppColors.semantics.text.secondary,
                                                fontSize: Fontsize.bodySmall,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                        Text(
                                          con.capitalizar(result.articuloDes.trim()),
                                          style: TextStyle(
                                            fontSize: Fontsize.body,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.semantics.text.body,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Obx(() {
                                        final hora = horas[index] ?? "";
                                        return Text(
                                          hora,
                                          style: TextStyle(
                                            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                            color: isActive ? AppColors.semantics.text.body : AppColors.semantics.text.secondary,
                                          ),
                                        );
                                      }),
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 80,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                          border: isActive ? Border.all(color: AppColors.semantics.border.action) : Border.all(color: Colors.black12),
                                          boxShadow: isActive ? AppShadows.elementFocusShadow : [],
                                        ),
                                        child: Obx(() {
                                          final cantidad = cantidades[index] ?? 0;
                                          return Center(
                                            child: Text(
                                              cantidad.toString(),
                                              style: TextStyle(
                                                fontSize: Fontsize.body,
                                                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                                color: isActive ? AppColors.semantics.text.body : AppColors.semantics.text.secondary,
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        }
                      ),
                    ),
                  ),
                
                  Padding(
                    padding: EdgeInsets.only(bottom:  MediaQuery.of(context).viewInsets.bottom),
                    child: _teclado(),
                  ),
                  SafeArea(child: _btnBottom()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFruitImageFull(String base64Image) {
    final Uint8List decodedBytes;
    if (base64Image == "") {
      return Container(
        color: Colors.grey.shade100,
        child: Icon(
          Icons.image_not_supported_outlined,
          color: const Color.fromARGB(255, 223, 223, 223),
          size: MediaQuery.sizeOf(context).height * 0.05,
        ),
      );
    } else {
      decodedBytes = base64Decode(base64Image);
      try {
        return Image.memory(
          decodedBytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade100,
              child: Icon(
                Icons.image_not_supported_outlined,
                color: Colors.grey.shade400,
                size: MediaQuery.sizeOf(context).height * 0.05,
              ),
            );
          },
        );
      } catch (e) {
        return Container(
          color: Colors.grey.shade100,
          child: Icon(
            Icons.image_not_supported_outlined,
            color: Colors.grey.shade400,
            size: MediaQuery.sizeOf(context).height * 0.05,
          ),
        );
      }
    }
  }

  Widget _btnBottom() {
    return Container(
      padding: const EdgeInsets.only(bottom: 16, right: 16, left: 16),
      color: Colors.white,
      child: SolidButton(
        type: SolidButtonType.primary,
        text: "Enviar",
        leftIcon: CupertinoIcons.paperplane,
        onPressed: List.generate(widget.control.articulos.length, (i) => i).every((i) => horas[i] != null && horas[i]!.isNotEmpty)
        ? () async {
          final duracion = cronometro.detener(widget.control.id.toString());
          setState(() {
            widget.control.duracion = cronometro.formatear(duracion);
          });
          
          for (var i = 0; i < widget.control.articulos.length; i++) {
            widget.control.articulos[i].cantidad = cantidades[i] ?? 0;
            widget.control.articulos[i].hora = horas[i] ?? "";
          }

          widget.control.horaFin = con.getFechaHoraActual();
          widget.control.horaIni = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(widget.control.horaFin).subtract(duracion));
          widget.control.estadoId = 10824;
          final now = DateTime.now();
          String fecha = now.toIso8601String().split('T').first;
          String hora = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
          widget.control.fecha = fecha;
          widget.control.hora = hora;

          con.actualizaControl(context, widget.control);
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => EstadoControl(
                entidad: widget.entidad,
                control: widget.control,
                label: "Conteo de stock enviado",
                icon: Icons.check_circle_outline_rounded,
                color: AppColors.semantics.text.success,
              ),
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
        }
        : null,
      ),
    );
  }

  Widget _teclado() {
    const keyStyle = TextStyle(fontSize: 24, fontWeight: FontWeight.w600);

    Widget buildKey(
      String key, {
      Color? color,
      Color? textColor,
      IconData? icon,
      double? height,
      double? width,
    }) {
      return Obx(() {
        final isPressedKey = pressedKey.value == key;
        return GestureDetector(
          onTapDown: (_) => pressedKey.value = key,
          onTapUp: (_) {
            Future.delayed(const Duration(milliseconds: 100), () {
              pressedKey.value = '';
            });
            _onKeyTap(context, key);
          },
          onTapCancel: () => pressedKey.value = '',
          child: AnimatedContainer(
            margin: const EdgeInsets.all(8),
            height: height,
            width: width,
            duration: const Duration(milliseconds: 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: isPressedKey ? const Color.fromARGB(255, 238, 238, 238) : Colors.transparent,
            ),
            child: Center(
              child: icon != null
              ? Icon(icon, color: textColor ?? Colors.black, size: 28)
              : Text(key,
                  style: keyStyle.copyWith(
                    color: textColor ?? Colors.black,
                    fontWeight: FontWeight.w500
                  )
                ),
            ),
          ),
        );
      });
    }

    final keyWidth = MediaQuery.sizeOf(context).width / 5;
    final keyHeight = MediaQuery.sizeOf(context).height * 0.05;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => {
                    if (activeIndex > 0) {
                      setState(() {
                        activeIndex -= 1;
                      }),
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        scrollToItem(activeIndex);
                      })
                    }
                  },
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Icon(
                      Icons.chevron_left,
                      color: AppColors.semantics.text.body,
                      size: 34,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => {
                    if (activeIndex < widget.control.articulos.length - 1) {
                      setState(() {
                        activeIndex += 1;
                      }),
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        scrollToItem(activeIndex);
                      })
                    }
                  },
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Icon(
                      Icons.chevron_right,
                      color: AppColors.semantics.text.body,
                      size: 34,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Table(
          defaultColumnWidth: const FlexColumnWidth(1),
          children: [
            TableRow(children: [
              buildKey('1', width: keyWidth, height: keyHeight),
              buildKey('2', width: keyWidth, height: keyHeight),
              buildKey('3', width: keyWidth, height: keyHeight),
              buildKey('⌫',
                  width: keyWidth,
                  height: keyHeight,
                  icon: Icons.backspace_outlined,
                  textColor: Colors.black87),
            ]),
            TableRow(children: [
              buildKey('4', width: keyWidth, height: keyHeight),
              buildKey('5', width: keyWidth, height: keyHeight),
              buildKey('6', width: keyWidth, height: keyHeight),
              buildKey('↵',
                  width: keyWidth,
                  height: keyHeight,
                  icon: Icons.keyboard_return,
                  textColor: Colors.green),
            ]),
            TableRow(children: [
              buildKey('7', width: keyWidth, height: keyHeight),
              buildKey('8', width: keyWidth, height: keyHeight),
              buildKey('9', width: keyWidth, height: keyHeight),
              const SizedBox.shrink(),
            ]),
            TableRow(children: [
              const SizedBox.shrink(),
              buildKey('0', width: keyWidth, height: keyHeight),
              const SizedBox.shrink(),
              const SizedBox.shrink(),
            ]),
          ],
        ),
      ],
    );
  }

}