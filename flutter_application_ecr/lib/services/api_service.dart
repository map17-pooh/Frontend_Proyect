import 'dart:convert';

import 'package:http/http.dart' as http;
import 'session_service.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  static Future<Map<String, String>> _authHeaders() async {
    final session = await SessionService.getSession();
    final token = session?['token'] ?? '';
    return {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Token $token',
    };
  }

  static Future<Map<String, dynamic>> solicitarResetPassword(String email) async {
    final uri = Uri.parse('$baseUrl/api/password-reset/');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    final body = jsonDecode(response.body);
    if (response.statusCode == 200) return body as Map<String, dynamic>;
    throw ApiException.fromResponse(body);
  }

  static Future<Map<String, dynamic>> confirmarResetPassword(
      String token, String newPassword) async {
    final uri = Uri.parse('$baseUrl/api/password-reset/confirm/');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': token, 'new_password': newPassword}),
    );
    final body = jsonDecode(response.body);
    if (response.statusCode == 200) return body as Map<String, dynamic>;
    throw ApiException.fromResponse(body);
  }

  static Future<Map<String, dynamic>> crearAsesoria(Map<String, dynamic> payload) async {
    final uri = Uri.parse('$baseUrl/api/asesorias/');
    final response = await http.post(
      uri,
      headers: await _authHeaders(),
      body: jsonEncode(payload),
    );
    final body = jsonDecode(response.body);
    if (response.statusCode == 201) return body as Map<String, dynamic>;
    throw ApiException.fromResponse(body);
  }

  static Future<List<dynamic>> getAsesorias() async {
    final uri = Uri.parse('$baseUrl/api/asesorias/');
    final response = await http.get(uri, headers: await _authHeaders());
    final body = jsonDecode(response.body);
    if (response.statusCode == 200) return body as List<dynamic>;
    throw ApiException.fromResponse(body);
  }

  static Future<Map<String, dynamic>> getEstadisticas() async {
    final uri = Uri.parse('$baseUrl/api/estadisticas/');
    final response = await http.get(uri, headers: await _authHeaders());
    final body = jsonDecode(response.body);
    if (response.statusCode == 200) return body as Map<String, dynamic>;
    throw ApiException.fromResponse(body);
  }

  static Future<List<dynamic>> getUsuarios() async {
    final uri = Uri.parse('$baseUrl/api/usuarios/');
    final response = await http.get(uri, headers: await _authHeaders());
    final body = jsonDecode(response.body);
    if (response.statusCode == 200) return body as List<dynamic>;
    throw ApiException.fromResponse(body);
  }

  static Future<Map<String, dynamic>> registerUsuario(Map<String, dynamic> payload) async {
    final uri = Uri.parse('$baseUrl/api/register/');
    print('ApiService.registerUsuario -> $uri');
    print('payload: ${jsonEncode(payload)}');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return body as Map<String, dynamic>;
    }

    throw ApiException.fromResponse(body);
  }

  static Future<Map<String, dynamic>> loginUsuario(String email, String password) async {
    final uri = Uri.parse('$baseUrl/api/login/');
    print('ApiService.loginUsuario -> $uri');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return body as Map<String, dynamic>;
    }

    throw ApiException.fromResponse(body);
  }

  static Future<Map<String, dynamic>> registerInterno(Map<String, dynamic> payload) async {
    final uri = Uri.parse('$baseUrl/api/internos/');
    print('ApiService.registerInterno -> $uri');
    print('payload: ${jsonEncode(payload)}');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return body as Map<String, dynamic>;
    }

    throw ApiException.fromResponse(body);
  }

  static Future<Map<String, dynamic>> loginInterno(String email, String password) async {
    final uri = Uri.parse('$baseUrl/api/login-interno/');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final body = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return body as Map<String, dynamic>;
    }
    throw ApiException.fromResponse(body);
  }

  static Future<Map<String, dynamic>> registerAdministrador(Map<String, dynamic> payload) async {
    final uri = Uri.parse('$baseUrl/api/administradores/');
    print('ApiService.registerAdministrador -> $uri');
    print('payload: ${jsonEncode(payload)}');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return body as Map<String, dynamic>;
    }

    throw ApiException.fromResponse(body);
  }

  static Future<Map<String, dynamic>> refreshAccessToken(String refreshToken) async {
    final uri = Uri.parse('$baseUrl/api/token/refresh/');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh_token': refreshToken}),
    );
    final body = jsonDecode(response.body);
    if (response.statusCode == 200) return body as Map<String, dynamic>;
    throw ApiException.fromResponse(body);
  }

  static Future<Map<String, dynamic>> getMiPerfil() async {
    final uri = Uri.parse('$baseUrl/api/mi-perfil/');
    final response = await http.get(uri, headers: await _authHeaders());
    final body = jsonDecode(response.body);
    if (response.statusCode == 200) return body as Map<String, dynamic>;
    throw ApiException.fromResponse(body);
  }

  static Future<Map<String, dynamic>> getCaracterizacion(String userId) async {
    final uri = Uri.parse('$baseUrl/api/caracterizacion/$userId/');
    final response = await http.get(uri, headers: await _authHeaders());
    final body = jsonDecode(response.body);
    if (response.statusCode == 200) return body as Map<String, dynamic>;
    throw ApiException.fromResponse(body);
  }

  static Future<Map<String, dynamic>> saveCaracterizacion(Map<String, dynamic> payload) async {
    final uri = Uri.parse('$baseUrl/api/caracterizacion/');
    final response = await http.post(
      uri,
      headers: await _authHeaders(),
      body: jsonEncode(payload),
    );
    final body = jsonDecode(response.body);
    if (response.statusCode == 201) return body as Map<String, dynamic>;
    throw ApiException.fromResponse(body);
  }

  static Future<Map<String, dynamic>> updateCaracterizacion(String userId, Map<String, dynamic> payload) async {
    final uri = Uri.parse('$baseUrl/api/caracterizacion/$userId/');
    final response = await http.put(
      uri,
      headers: await _authHeaders(),
      body: jsonEncode(payload),
    );
    final body = jsonDecode(response.body);
    if (response.statusCode == 200) return body as Map<String, dynamic>;
    throw ApiException.fromResponse(body);
  }

  static Future<Map<String, dynamic>> getHistorialClinico(String userId) async {
    final uri = Uri.parse('$baseUrl/api/historial-clinico/$userId/');
    final response = await http.get(uri, headers: await _authHeaders());
    final body = jsonDecode(response.body);
    if (response.statusCode == 200) return body as Map<String, dynamic>;
    throw ApiException.fromResponse(body);
  }

  static Future<Map<String, dynamic>> saveHistorialClinico(Map<String, dynamic> payload) async {
    final uri = Uri.parse('$baseUrl/api/historial-clinico/');
    final response = await http.post(
      uri,
      headers: await _authHeaders(),
      body: jsonEncode(payload),
    );
    final body = jsonDecode(response.body);
    if (response.statusCode == 201) return body as Map<String, dynamic>;
    throw ApiException.fromResponse(body);
  }

  static Future<Map<String, dynamic>> updateHistorialClinico(String userId, Map<String, dynamic> payload) async {
    final uri = Uri.parse('$baseUrl/api/historial-clinico/$userId/');
    final response = await http.put(
      uri,
      headers: await _authHeaders(),
      body: jsonEncode(payload),
    );
    final body = jsonDecode(response.body);
    if (response.statusCode == 200) return body as Map<String, dynamic>;
    throw ApiException.fromResponse(body);
  }
}

class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  factory ApiException.fromResponse(dynamic body) {
    if (body is Map<String, dynamic>) {
      if (body.containsKey('detail')) {
        return ApiException(body['detail'].toString());
      }
      if (body.containsKey('email')) {
        return ApiException(body['email'].toString());
      }
      if (body.containsKey('password')) {
        return ApiException(body['password'].toString());
      }
      return ApiException(body.toString());
    }
    return ApiException('Error desconocido');
  }

  @override
  String toString() => message;
}
