import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ApiService {
  final String baseUrl = AppConstants.apiBaseUrl;

  // GET request
  Future<http.Response> get(String endpoint, {Map<String, String>? headers}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
      );
      return response;
    } catch (e) {
      throw Exception('Lỗi kết nối API: $e');
    }
  }

  // POST request
  Future<http.Response> post(String endpoint, {Map<String, String>? headers, dynamic body}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
        body: body,
      );
      return response;
    } catch (e) {
      throw Exception('Lỗi kết nối API: $e');
    }
  }

  // PUT request
  Future<http.Response> put(String endpoint, {Map<String, String>? headers, dynamic body}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
        body: body,
      );
      return response;
    } catch (e) {
      throw Exception('Lỗi kết nối API: $e');
    }
  }

  // PATCH request
  Future<http.Response> patch(String endpoint, {Map<String, String>? headers, dynamic body}) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
        body: body,
      );
      return response;
    } catch (e) {
      throw Exception('Lỗi kết nối API: $e');
    }
  }

  // DELETE request
  Future<http.Response> delete(String endpoint, {Map<String, String>? headers}) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
      );
      return response;
    } catch (e) {
      throw Exception('Lỗi kết nối API: $e');
    }
  }
} 