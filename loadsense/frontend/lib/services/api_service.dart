import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppStrings.tokenKey);
  }

  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await _getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static dynamic _handleResponse(http.Response response) {
    if (response.body.isEmpty) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {};
      } else {
        throw ApiException('Server returned empty error response', statusCode: response.statusCode);
      }
    }

    dynamic decoded;
    try {
      decoded = json.decode(response.body);
    } catch (e) {
      throw ApiException('Invalid JSON response: ${response.body}', statusCode: response.statusCode);
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    } else {
      final msg = (decoded is Map) ? (decoded['message'] ?? decoded['error'] ?? 'Request failed') : 'Request failed';
      debugPrint('ApiService Error: ${response.statusCode} - $msg - Path: ${response.request?.url}');
      throw ApiException(msg, statusCode: response.statusCode);
    }
  }

  static Future<dynamic> get(String endpoint, {bool auth = true}) async {
    final headers = await _headers(auth: auth);
    final url = '${ApiConstants.baseUrl}$endpoint';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 30));
      return _handleResponse(response);
    } catch (e) {
      debugPrint('ApiService GET Error: $url -> $e');
      rethrow;
    }
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> body, {bool auth = true}) async {
    final headers = await _headers(auth: auth);
    final url = '${ApiConstants.baseUrl}$endpoint';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      ).timeout(const Duration(seconds: 30));
      return _handleResponse(response);
    } catch (e) {
      debugPrint('ApiService POST Error: $url -> $e');
      rethrow;
    }
  }

  static Future<dynamic> put(String endpoint, Map<String, dynamic> body, {bool auth = true}) async {
    final headers = await _headers(auth: auth);
    final url = '${ApiConstants.baseUrl}$endpoint';
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      ).timeout(const Duration(seconds: 30));
      return _handleResponse(response);
    } catch (e) {
      debugPrint('ApiService PUT Error: $url -> $e');
      rethrow;
    }
  }

  static Future<dynamic> patch(String endpoint, Map<String, dynamic> body, {bool auth = true}) async {
    final headers = await _headers(auth: auth);
    final url = '${ApiConstants.baseUrl}$endpoint';
    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      ).timeout(const Duration(seconds: 30));
      return _handleResponse(response);
    } catch (e) {
      debugPrint('ApiService PATCH Error: $url -> $e');
      rethrow;
    }
  }

  static Future<dynamic> delete(String endpoint, {bool auth = true}) async {
    final headers = await _headers(auth: auth);
    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: headers,
    ).timeout(const Duration(seconds: 30));
    return _handleResponse(response);
  }

  static Future<dynamic> multipartPatch(String endpoint, Map<String, String> fields, {File? imageFile}) async {
    final url = '${ApiConstants.baseUrl}$endpoint';
    try {
      final token = await _getToken();
      final request = http.MultipartRequest('PATCH', Uri.parse(url));
      
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      request.fields.addAll(fields);
      
      if (imageFile != null) {
        final ext = imageFile.path.split('.').last.toLowerCase();
        late String mimeType;
        late String subType;
        
        if (ext == 'png') {
          mimeType = 'image';
          subType = 'png';
        } else if (ext == 'jpg' || ext == 'jpeg') {
          mimeType = 'image';
          subType = 'jpeg';
        } else {
          mimeType = 'application';
          subType = 'octet-stream';
        }

        request.files.add(await http.MultipartFile.fromPath(
          'avatar',
          imageFile.path,
          contentType: MediaType(mimeType, subType),
        ));
      }

      final streamedRes = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamedRes);
      return _handleResponse(response);
    } catch (e) {
      debugPrint('ApiService MultiPart Error: $url -> $e');
      rethrow;
    }
  }
}
