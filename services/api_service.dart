import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';
  static final _client = http.Client();

  static Future<dynamic> get(String path) async {
    final res = await _client.get(
      Uri.parse('$baseUrl$path'),
      headers: {'Content-Type': 'application/json'},
    );
    return _handle(res);
  }

  static Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final res = await _client.post(
      Uri.parse('$baseUrl$path'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _handle(res);
  }

  // 🔥 Eksik olan put metodu
  static Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final res = await _client.put(
      Uri.parse('$baseUrl$path'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _handle(res);
  }

  static dynamic _handle(http.Response res) {
    final body = jsonDecode(utf8.decode(res.bodyBytes));
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    final detail = body['detail'] ?? 'Bilinmeyen hata';
    throw ApiException(detail.toString(), res.statusCode);
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}