import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/goal/goal_model.dart';
import '../utils/constants.dart';
import '../services/api_service.dart';
import '../services/endpoint_service.dart';

class GoalService {
  final ApiService _apiService = ApiService();
  final EndpointService _endpoints = EndpointService();
  final _secureStorage = const FlutterSecureStorage();

  // Lấy danh sách mục tiêu
  Future<List<Goal>> getGoals() async {
    try {
      final token = await _secureStorage.read(key: 'authToken');
      if (token == null) {
        throw Exception('Chưa đăng nhập');
      }

      final response = await _apiService.get(
        '${_endpoints.goalEndpoint}',
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Goal.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập hết hạn');
      } else {
        throw Exception('Không thể lấy danh sách mục tiêu');
      }
    } catch (e) {
      print('Lỗi khi lấy danh sách mục tiêu: $e');
      rethrow;
    }
  }

  // Lấy chi tiết mục tiêu theo ID
  Future<Goal> getGoalById(String id) async {
    try {
      final token = await _secureStorage.read(key: 'authToken');
      if (token == null) {
        throw Exception('Chưa đăng nhập');
      }

      final response = await _apiService.get(
        '${_endpoints.goalEndpoint}/$id',
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        return Goal.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập hết hạn');
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy mục tiêu');
      } else {
        throw Exception('Không thể lấy chi tiết mục tiêu');
      }
    } catch (e) {
      print('Lỗi khi lấy chi tiết mục tiêu: $e');
      rethrow;
    }
  }

  // Tạo mục tiêu mới
  Future<Goal> createGoal(Goal goal) async {
    try {
      final token = await _secureStorage.read(key: 'authToken');
      if (token == null) {
        throw Exception('Chưa đăng nhập');
      }

      final response = await _apiService.post(
        _endpoints.goalEndpoint,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(goal.toJson()),
      );

      if (response.statusCode == 201) {
        final dynamic data = json.decode(response.body);
        return Goal.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập hết hạn');
      } else {
        throw Exception('Không thể tạo mục tiêu mới');
      }
    } catch (e) {
      print('Lỗi khi tạo mục tiêu mới: $e');
      rethrow;
    }
  }

  // Cập nhật mục tiêu
  Future<Goal> updateGoal(String id, Goal goal) async {
    try {
      final token = await _secureStorage.read(key: 'authToken');
      if (token == null) {
        throw Exception('Chưa đăng nhập');
      }

      final response = await _apiService.put(
        '${_endpoints.goalEndpoint}/$id',
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(goal.toJson()),
      );

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        return Goal.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập hết hạn');
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy mục tiêu');
      } else {
        throw Exception('Không thể cập nhật mục tiêu');
      }
    } catch (e) {
      print('Lỗi khi cập nhật mục tiêu: $e');
      rethrow;
    }
  }

  // Cập nhật tiến độ mục tiêu
  Future<Goal> updateGoalProgress(String id, int newValue) async {
    try {
      final token = await _secureStorage.read(key: 'authToken');
      if (token == null) {
        throw Exception('Chưa đăng nhập');
      }

      final response = await _apiService.patch(
        '${_endpoints.goalEndpoint}/$id/progress',
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'currentValue': newValue}),
      );

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        return Goal.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập hết hạn');
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy mục tiêu');
      } else {
        throw Exception('Không thể cập nhật tiến độ mục tiêu');
      }
    } catch (e) {
      print('Lỗi khi cập nhật tiến độ mục tiêu: $e');
      rethrow;
    }
  }

  // Xóa mục tiêu
  Future<bool> deleteGoal(String id) async {
    try {
      final token = await _secureStorage.read(key: 'authToken');
      if (token == null) {
        throw Exception('Chưa đăng nhập');
      }

      final response = await _apiService.delete(
        '${_endpoints.goalEndpoint}/$id',
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 204) {
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập hết hạn');
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy mục tiêu');
      } else {
        throw Exception('Không thể xóa mục tiêu');
      }
    } catch (e) {
      print('Lỗi khi xóa mục tiêu: $e');
      rethrow;
    }
  }

  // Đánh dấu mục tiêu là hoàn thành
  Future<Goal> completeGoal(String id) async {
    try {
      final token = await _secureStorage.read(key: 'authToken');
      if (token == null) {
        throw Exception('Chưa đăng nhập');
      }

      final response = await _apiService.patch(
        '${_endpoints.goalEndpoint}/$id/complete',
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        return Goal.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập hết hạn');
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy mục tiêu');
      } else {
        throw Exception('Không thể đánh dấu mục tiêu là hoàn thành');
      }
    } catch (e) {
      print('Lỗi khi đánh dấu mục tiêu là hoàn thành: $e');
      rethrow;
    }
  }

  // Kiểm tra tính hợp lệ của token
  Future<bool> checkTokenValidity() async {
    try {
      final token = await _secureStorage.read(key: 'authToken');
      if (token == null) {
        debugPrint('Token không tồn tại');
        return false;
      }

      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/User/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        debugPrint('Token hợp lệ');
        return true;
      } else {
        debugPrint('Token không hợp lệ: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Lỗi khi kiểm tra token: $e');
      return false;
    }
  }
} 