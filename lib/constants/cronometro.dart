import 'dart:async';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vientri/src/models/control.dart';

class CronometroController extends GetxController {
  final control = Rx<Control?>(null);

  void setControl(Control nuevo) {
    control.value = nuevo;
  }

  final box = GetStorage();

  /// Map de cronómetros activos por ID
  final Map<String, Rx<Duration>> tiempos = {};
  final Map<String, Timer?> _timers = {};
  final Map<String, DateTime?> _startTimes = {};

  @override
  void onInit() {
    super.onInit();

    // Restaurar cronómetros desde storage
    final savedData = box.read<Map>("cronometros") ?? {};
    savedData.forEach((id, startIso) {
      if (startIso != null) {
        final start = DateTime.parse(startIso);
        _startTimes[id] = start;
        _iniciarTimer(id);
      }
    });
  }

  /// Inicia cronómetro por ID
  void iniciar(String id) {
    if (_startTimes[id] != null) return; // Ya estaba iniciado

    DateTime horaIni;
    try {
      horaIni = DateTime.parse(
        control.value!.horaIni,
      ).toUtc().add(const Duration(hours: -3));
    } catch (e) {
      horaIni = DateTime.now().toUtc().add(const Duration(hours: -3));
    }

    _startTimes[id] = horaIni;
    tiempos[id] = Duration.zero.obs;

    _guardar();
    _iniciarTimer(id);
  }

  void _iniciarTimer(String id) {
    _timers[id]?.cancel();
    _timers[id] = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_startTimes[id] != null) {
        final diff = DateTime.now()
            .toUtc()
            .add(const Duration(hours: -3))
            .difference(_startTimes[id]!);
        tiempos[id] ??= Duration.zero.obs;
        tiempos[id]!.value = diff;
      }
    });
  }

  /// Detiene cronómetro y devuelve la duración final
  Duration detener(String id) {
    _timers[id]?.cancel();
    _timers.remove(id);

    final duracion = tiempos[id]?.value ?? Duration.zero;

    _startTimes.remove(id);
    _guardar();

    return duracion;
  }

  /// Guarda los cronómetros en storage
  void _guardar() {
    final data = _startTimes.map(
      (id, start) => MapEntry(id, start?.toIso8601String()),
    );
    box.write("cronometros", data);
  }

  /// Formatea cualquier duración como HH:mm:ss
  String formatear(Duration d) {
    final horas = d.inHours.toString().padLeft(2, '0');
    final minutos = (d.inMinutes % 60).toString().padLeft(2, '0');
    final segundos = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$horas:$minutos:$segundos";
  }

  /// Obtiene el texto formateado en vivo de un cronómetro
  String tiempoFormateado(String id) {
    final duracion = tiempos[id]?.value ?? Duration.zero;
    return formatear(duracion);
  }
}
