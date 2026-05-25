import 'dart:convert';

import 'package:http/http.dart' as http;

class RendimientoService {
  final String _baseUrl = 'https://backend-tfg.fly.dev/api/v1';

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Basic ${base64Encode(utf8.encode('admin:admin123'))}',
    'Access-Control-Allow-Origin': '*',
  };

  Future<List<dynamic>> obtenerEstadisticasIA() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/admin/stats/all-ia'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }

  Future<List<dynamic>> obtenerRutasActivas() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/public/route?isActive=true'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }

  Future<List<dynamic>> obtenerDescargas() async {
    final String anio = DateTime.now().year.toString();
    final response = await http.get(
      Uri.parse('$_baseUrl/admin/stats/summary?period=$anio'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }

  Future<List<dynamic>> obtenerMonumentos() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/public/monuments?orderBy=desc'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }
}
