import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<String?> subirImagen(
    String bucket,
    Uint8List bytes,
    String nombreArchivo, {
    String carpeta = '',
  }) async {
    try {
      final extension = nombreArchivo.split('.').last;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueName = '${timestamp}_imagen.$extension';
      final ruta = carpeta.isNotEmpty ? '$carpeta/$uniqueName' : uniqueName;

      await _client.storage
          .from(bucket)
          .uploadBinary(
            ruta,
            bytes,
            fileOptions: FileOptions(
              contentType: _getContentType(extension),
              upsert: false,
            ),
          );

      final urlPublica = _client.storage.from(bucket).getPublicUrl(ruta);
      return urlPublica;
    } catch (e) {
      print('=== ERROR SUPABASE ===: $e');
      throw Exception(e.toString());
    }
  }

  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      default:
        return 'application/octet-stream';
    }
  }

  Future<String?> subirAudio(String bucket, Uint8List bytes, String nombreArchivo) async {
    try {
      final extension = nombreArchivo.split('.').last;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueName = '${timestamp}_audio.$extension';
      final ruta = uniqueName;

      await _client.storage
          .from(bucket)
          .uploadBinary(
            ruta,
            bytes,
            fileOptions: FileOptions(
              contentType: _getAudioContentType(extension),
              upsert: false,
            ),
          );

      final urlPublica = _client.storage.from(bucket).getPublicUrl(ruta);
      return urlPublica;
    } catch (e) {
      return null;
    }
  }

  String _getAudioContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      case 'm4a':
        return 'audio/x-m4a';
      case 'ogg':
        return 'audio/ogg';
      case 'aac':
        return 'audio/aac';
      default:
        return 'audio/mpeg';
    }
  }
}
