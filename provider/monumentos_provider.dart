import 'package:audioguia_web/service/monumento_service.dart';
import 'package:audioguia_web/service/supabase_service.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import '../model/monumento_model.dart';

class GestionMonumentoProvider extends ChangeNotifier {
  final MonumentoService _monumentoService = MonumentoService();
  final SupabaseService _supabaseService = SupabaseService();

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  Uint8List? _imagenBytes;
  String? _imagenNombre;
  Uint8List? _audioBytes;
  String? _audioNombre;

  Uint8List? get imagenBytes => _imagenBytes;
  String? get imagenNombre => _imagenNombre;
  Uint8List? get audioBytes => _audioBytes;
  String? get audioNombre => _audioNombre;

  Future<void> seleccionarImagen() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      _imagenBytes = result.files.single.bytes;
      _imagenNombre = result.files.single.name;
      notifyListeners();
    }
  }

  Future<void> seleccionarAudio() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'm4a'],
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      _audioBytes = result.files.single.bytes;
      _audioNombre = result.files.single.name;
      notifyListeners();
    }
  }

  void limpiarArchivos() {
    _imagenBytes = null;
    _imagenNombre = null;
    _audioBytes = null;
    _audioNombre = null;
    notifyListeners();
  }

  Future<bool> guardarMonumento(Monumento monumento) async {
    _isSaving = true;
    notifyListeners();

    try {
      String? urlImagenSubida;
      String? urlAudioSubido;

      if (_imagenBytes != null && _imagenNombre != null) {
        urlImagenSubida = await _supabaseService.subirImagen(
          'monumentos',
          _imagenBytes!,
          _imagenNombre!,
        );
        if (urlImagenSubida == null) {
          throw Exception("Error al subir la imagen a Supabase");
        }
      }

      if (_audioBytes != null && _audioNombre != null) {
        urlAudioSubido = await _supabaseService.subirAudio(
          'monumentos',
          _audioBytes!,
          _audioNombre!,
        );
        if (urlAudioSubido == null) {
          throw Exception("Error al subir el archivo de audio a Supabase");
        }
      }

      final exito = await _monumentoService.crearMonumento(
        monumento: monumento,
        imagenUrl: urlImagenSubida,
        audioUrl: urlAudioSubido,
      );

      if (exito) limpiarArchivos();
      return exito;
    } catch (e) {
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<Monumento> cargarMonumento(String id) async {
    return await _monumentoService.obtenerMonumentoPorId(id);
  }

  Future<bool> editarMonumento(Monumento monumento) async {
    _isSaving = true;
    notifyListeners();

    try {
      final exito = await _monumentoService.editarMonumento(monumento);
      return exito;
    } catch (e) {
      _isSaving = false;
      notifyListeners();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> eliminarMonumento(String id) async {
    _isSaving = true;
    notifyListeners();

    try {
      final exito = await _monumentoService.eliminarMonumento(id);
      return exito;
    } catch (e) {
      _isSaving = false;
      notifyListeners();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
