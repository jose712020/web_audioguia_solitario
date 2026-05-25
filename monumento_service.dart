import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/monumento_model.dart';

class MonumentoService {
  final String _urlPublic = 'https://backend-tfg.fly.dev/api/v1/public/monuments';
  final String _urlAdmin = 'https://backend-tfg.fly.dev/api/v1/admin/monuments';

  Future<List<Monumento>?> obtenerTodos() async {
    try {
      final response = await http.get(Uri.parse(_urlPublic));
      if (response.statusCode == 200) {
        final List<dynamic> lista = json.decode(
          utf8.decode(response.bodyBytes),
        );
        return lista
            .map((item) => Monumento.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> toggleActivo(String id, String authHeader) async {
    try {
      final response = await http.patch(
        Uri.parse('$_urlAdmin/$id/activate'),
        headers: {
          'Authorization': authHeader,
          'Content-Type': 'application/json',
        },
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Basic ${base64Encode(utf8.encode('admin:admin123'))}',
    'Access-Control-Allow-Origin': '*',
  };

  Future<bool> crearMonumento({
    required Monumento monumento,
    String? imagenUrl,
    String? audioUrl,
    int localidadId = 1,
  }) async {
    try {
      final uri = Uri.parse(_urlAdmin);

      final Map<String, dynamic> bodyJson = {
        'name': monumento.nombre,
        'description': (monumento.descripcionContenido.isNotEmpty || monumento.descripcionNombre.isNotEmpty)
            ? [
                {
                  "complete": monumento.sinopsis,
                  "contenido": monumento.descripcionContenido,
                  "kids": monumento.paraNinos,
                  "language": monumento.idioma,
                  "name": monumento.descripcionNombre,
                }
              ]
            : [],
        "coordenates": {"lon": monumento.longitud, "lat": monumento.latitud},
        'accessibility': monumento.accesible,
        'isActive': monumento.activo,
        'maps_url':
            'https://www.google.com/maps?q=${monumento.latitud},${monumento.longitud}',
        'tag': {'id': int.tryParse(monumento.categoria) ?? 1},
        "picture": imagenUrl != null
            ? [
                {"url": imagenUrl},
              ]
            : [],
        'audio': audioUrl != null
            ? [
                {
                  "url": audioUrl,
                  "kids": monumento.paraNinos,
                  "language": monumento.idioma,
                },
              ]
            : [],
        'localidad_id': localidadId,
        'NLikes': monumento.likes,
      };

      debugPrint("Enviando JSON completo y corregido al backend...");

      final response = await http.post(
        uri,
        headers: _headers,
        body: jsonEncode(bodyJson),
      );

      debugPrint(
        "Respuesta servidor crear: ${response.statusCode} - ${response.body}",
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Error al crear monumento: ${response.body}');
      }
    } catch (e) {
      debugPrint("Excepción en crearMonumento: $e");
      rethrow;
    }
  }

  Future<bool> editarMonumento(
    Monumento monumento, {
    int localidadId = 1,
  }) async {
    final uri = Uri.parse('$_urlAdmin/${monumento.id}'); 
    final bodyMapeado = {
      "name": monumento.nombre,
      "coordenates": {"lon": monumento.longitud, "lat": monumento.latitud},
      "accessibility": monumento.accesible,
      "isActive": monumento.activo,
      "tag": {"id": int.tryParse(monumento.categoria) ?? 1},
      "maps_url":
          'https://www.google.com/maps?q=${monumento.latitud},${monumento.longitud}',
      "description": (monumento.descripcionContenido.isNotEmpty || monumento.descripcionNombre.isNotEmpty)
          ? [
              {
                if (monumento.descripcionId != null) "id": monumento.descripcionId, 
                "complete": monumento.sinopsis,
                "contenido": monumento.descripcionContenido,
                "kids": monumento.paraNinos,
                "language": monumento.idioma,
                "name": monumento.descripcionNombre,
              }
            ]
          : [],
      "picture": monumento.imagenUrl != null
          ? [
              {
                if (monumento.pictureId != null) "id": monumento.pictureId,
                "url": monumento.imagenUrl
              },
            ]
          : [],

      "audio": monumento.audioUrl != null
          ? [
              {
                if (monumento.audioId != null) "id": monumento.audioId,
                "url": monumento.audioUrl,
                "kids": monumento.paraNinos,
                "language": monumento.idioma,
              },
            ]
          : [],
      "localidad_id": localidadId,
      "NLikes": monumento.likes,
    };

    try {
      final response = await http.put(
        uri,
        headers: _headers,
        body: jsonEncode(bodyMapeado),
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint("Error en editarMonumento HTTP: $e");
      return false;
    }
  }

  Future<bool> eliminarMonumento(String id) async {
    final uri = Uri.parse('$_urlAdmin/$id');
    final response = await http.delete(uri, headers: _headers);
    return response.statusCode == 200 || response.statusCode == 204;
  }

  Future<Monumento> obtenerMonumentoPorId(String id) async {
    final response = await http.get(
      Uri.parse('$_urlPublic/$id'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return Monumento.fromJson(json.decode(response.body));
    } else {
      throw Exception('No se pudo cargar el monumento');
    }
  }
}
