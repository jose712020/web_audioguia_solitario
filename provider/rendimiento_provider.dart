import 'package:audioguia_web/model/stats_model.dart';
import 'package:audioguia_web/service/rendimiento_service.dart';
import 'package:flutter/material.dart';

class RendimientoProvider with ChangeNotifier {
  final RendimientoService _apiService = RendimientoService();

  StatsModel? _data;
  bool _isLoading = false;
  String? _error;

  StatsModel? get data => _data;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchRendimiento() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final descargas = await _apiService.obtenerDescargas();
      final rutas = await _apiService.obtenerRutasActivas();
      final ia = await _apiService.obtenerEstadisticasIA();
      final monuments = await _apiService.obtenerMonumentos();

      final List<dynamic> descargasData = descargas;
      final List<dynamic> iaData = ia;
      final List<dynamic> rutasData = rutas;
      final List<dynamic> monumentosData = monuments;

      final general = descargasData.firstWhere(
        (i) => i['name'] == 'general',
        orElse: () => {'totalDownloads': 0},
      );
      int totalDescargas = general['totalDownloads'];

      final iaExitosa = iaData.firstWhere(
        (i) => i['nameCount'] == 'peticiones_completas',
        orElse: () => {'count': 0},
      );
      int totalIA = iaExitosa['count'];

      _data = StatsModel(
        totalUsuarios: totalDescargas,
        peticionesIA: totalIA,
        rutasActivas: rutasData.length,
        monumentosPopulares: monumentosData
            .map((m) => MonumentStat.fromJson(m))
            .toList(),
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
