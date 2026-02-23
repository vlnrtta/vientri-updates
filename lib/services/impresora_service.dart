import 'package:get_storage/get_storage.dart';
import 'package:vientri/src/models/impresora.dart';

class ImpresoraService {
  final _box = GetStorage();
  final _key = 'impresoras_red';

  List<ImpresoraRed> obtenerImpresoras() {
    final data = _box.read<List>(_key) ?? [];
    return data.map((e) => ImpresoraRed.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<void> agregar(ImpresoraRed impresora) async {
    final lista = obtenerImpresoras();
    lista.add(impresora);
    await _guardar(lista);
  }

  Future<void> eliminar(ImpresoraRed impresora) async {
    final lista = obtenerImpresoras();
    lista.removeWhere((i) =>
        i.ip == impresora.ip && i.puerto == impresora.puerto);
    await _guardar(lista);
  }

  Future<void> _guardar(List<ImpresoraRed> lista) async {
    await _box.write(_key, lista.map((e) => e.toJson()).toList());
  }
}

