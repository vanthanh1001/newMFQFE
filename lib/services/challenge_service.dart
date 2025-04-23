import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/challenge/challenge_model.dart';
import '../constants/api_constants.dart';

class ChallengeService {
  final String baseUrl = ApiConstants.baseUrl;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Lấy danh sách thử thách đang hoạt động
  Future<List<Challenge>> getActiveChallenges() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại.');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/Challenge/active'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Challenge.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        debugPrint('Lỗi xác thực khi lấy danh sách thử thách đang hoạt động');
        throw Exception('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại.');
      } else {
        debugPrint('Lỗi khi lấy danh sách thử thách đang hoạt động: ${response.statusCode}, ${response.body}');
        throw Exception('Không thể lấy danh sách thử thách đang hoạt động, mã lỗi: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Không có kết nối mạng, vui lòng kiểm tra lại.');
    } catch (e) {
      debugPrint('Lỗi không xác định khi lấy danh sách thử thách đang hoạt động: $e');
      throw Exception('Đã xảy ra lỗi: $e');
    }
  }

  // Lấy danh sách thử thách sắp diễn ra
  Future<List<Challenge>> getUpcomingChallenges() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại.');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/Challenge/upcoming'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Challenge.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        debugPrint('Lỗi xác thực khi lấy danh sách thử thách sắp diễn ra');
        throw Exception('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại.');
      } else {
        debugPrint('Lỗi khi lấy danh sách thử thách sắp diễn ra: ${response.statusCode}, ${response.body}');
        throw Exception('Không thể lấy danh sách thử thách sắp diễn ra, mã lỗi: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Không có kết nối mạng, vui lòng kiểm tra lại.');
    } catch (e) {
      debugPrint('Lỗi không xác định khi lấy danh sách thử thách sắp diễn ra: $e');
      throw Exception('Đã xảy ra lỗi: $e');
    }
  }

  // Lấy danh sách thử thách đã hoàn thành 
  Future<List<Challenge>> getCompletedChallenges() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại.');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/Challenge/completed'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Challenge.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        debugPrint('Lỗi xác thực khi lấy danh sách thử thách đã hoàn thành');
        throw Exception('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại.');
      } else {
        debugPrint('Lỗi khi lấy danh sách thử thách đã hoàn thành: ${response.statusCode}, ${response.body}');
        throw Exception('Không thể lấy danh sách thử thách đã hoàn thành, mã lỗi: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Không có kết nối mạng, vui lòng kiểm tra lại.');
    } catch (e) {
      debugPrint('Lỗi không xác định khi lấy danh sách thử thách đã hoàn thành: $e');
      throw Exception('Đã xảy ra lỗi: $e');
    }
  }

  // Tham gia thử thách
  Future<bool> joinChallenge(int challengeId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại.');
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Challenge/$challengeId/join'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else if (response.statusCode == 401) {
        debugPrint('Lỗi xác thực khi tham gia thử thách');
        throw Exception('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại.');
      } else {
        debugPrint('Lỗi khi tham gia thử thách: ${response.statusCode}, ${response.body}');
        final errorMsg = _parseErrorMessage(response.body);
        throw Exception(errorMsg ?? 'Không thể tham gia thử thách, mã lỗi: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Không có kết nối mạng, vui lòng kiểm tra lại.');
    } catch (e) {
      debugPrint('Lỗi không xác định khi tham gia thử thách: $e');
      throw Exception('Đã xảy ra lỗi: $e');
    }
  }

  // Lấy chi tiết thử thách
  Future<Challenge> getChallengeById(int id) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại.');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/Challenge/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Challenge.fromJson(json);
      } else if (response.statusCode == 401) {
        debugPrint('Lỗi xác thực khi lấy chi tiết thử thách');
        throw Exception('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại.');
      } else {
        debugPrint('Lỗi khi lấy chi tiết thử thách: ${response.statusCode}, ${response.body}');
        throw Exception('Không thể lấy chi tiết thử thách, mã lỗi: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Không có kết nối mạng, vui lòng kiểm tra lại.');
    } catch (e) {
      debugPrint('Lỗi không xác định khi lấy chi tiết thử thách: $e');
      throw Exception('Đã xảy ra lỗi: $e');
    }
  }

  // Kiểm tra tính hợp lệ của token
  Future<bool> checkTokenValidity() async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      return false;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/User/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Lỗi khi kiểm tra token: $e');
      return false;
    }
  }

  // Lấy token từ bộ nhớ an toàn
  Future<String?> _getToken() async {
    try {
      return await _secureStorage.read(key: 'token');
    } catch (e) {
      debugPrint('Lỗi khi đọc token: $e');
      return null;
    }
  }

  // Phân tích thông báo lỗi từ response body
  String? _parseErrorMessage(String body) {
    try {
      final data = json.decode(body);
      if (data['message'] != null) {
        return data['message'];
      }
      if (data['error'] != null) {
        return data['error'];
      }
      if (data['errors'] != null) {
        if (data['errors'] is List) {
          return (data['errors'] as List).join(', ');
        } else if (data['errors'] is Map) {
          return (data['errors'] as Map).values.join(', ');
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
} 