import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/exercise.dart';
import '../utils/constants.dart';

class ExerciseService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String baseUrl = AppConstants.apiBaseUrl;

  // Lấy danh sách bài tập
  Future<List<Exercise>> getExercises() async {
    try {
      final token = await _storage.read(key: 'token');
      if (token == null) {
        throw Exception('Chưa đăng nhập');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/Exercise'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((exerciseJson) => Exercise.fromJson(exerciseJson)).toList();
      } else {
        throw Exception('Không thể lấy danh sách bài tập: ${response.body}');
      }
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách bài tập: $e');
    }
  }

  // Lấy chi tiết bài tập theo ID
  Future<Exercise> getExerciseById(int id) async {
    try {
      final token = await _storage.read(key: 'token');
      if (token == null) {
        throw Exception('Chưa đăng nhập');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/Exercise/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return Exercise.fromJson(data);
      } else {
        throw Exception('Không thể lấy thông tin bài tập: ${response.body}');
      }
    } catch (e) {
      throw Exception('Lỗi khi lấy thông tin bài tập: $e');
    }
  }

  // Tạo bài tập mới
  Future<Exercise> createExercise({
    required String name,
    required String description,
    required int sets,
    required int reps,
    required int restTime,
  }) async {
    try {
      final token = await _storage.read(key: 'token');
      if (token == null) {
        throw Exception('Chưa đăng nhập');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/Exercise'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': name,
          'description': description,
          'sets': sets,
          'reps': reps,
          'restTime': restTime,
        }),
      );

      if (response.statusCode == 201) {
        Map<String, dynamic> data = json.decode(response.body);
        return Exercise.fromJson(data);
      } else {
        throw Exception('Không thể tạo bài tập: ${response.body}');
      }
    } catch (e) {
      throw Exception('Lỗi khi tạo bài tập: $e');
    }
  }

  // Cập nhật bài tập
  Future<void> updateExercise({
    required int id,
    required String name,
    required String description,
    required int sets,
    required int reps,
    required int restTime,
  }) async {
    try {
      final token = await _storage.read(key: 'token');
      if (token == null) {
        throw Exception('Chưa đăng nhập');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/Exercise/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': name,
          'description': description,
          'sets': sets,
          'reps': reps,
          'restTime': restTime,
        }),
      );

      if (response.statusCode != 204) {
        throw Exception('Không thể cập nhật bài tập: ${response.body}');
      }
    } catch (e) {
      throw Exception('Lỗi khi cập nhật bài tập: $e');
    }
  }

  // Xóa bài tập
  Future<void> deleteExercise(int id) async {
    try {
      final token = await _storage.read(key: 'token');
      if (token == null) {
        throw Exception('Chưa đăng nhập');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/Exercise/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 204) {
        throw Exception('Không thể xóa bài tập: ${response.body}');
      }
    } catch (e) {
      throw Exception('Lỗi khi xóa bài tập: $e');
    }
  }

  // Tìm kiếm bài tập
  Future<List<Exercise>> searchExercises(String name) async {
    try {
      final token = await _storage.read(key: 'token');
      if (token == null) {
        throw Exception('Chưa đăng nhập');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/Exercise/search?name=$name'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((exerciseJson) => Exercise.fromJson(exerciseJson)).toList();
      } else {
        throw Exception('Không thể tìm kiếm bài tập: ${response.body}');
      }
    } catch (e) {
      throw Exception('Lỗi khi tìm kiếm bài tập: $e');
    }
  }

  // Upload ảnh cho bài tập
  Future<String> uploadExerciseImage(File image) async {
    try {
      final token = await _storage.read(key: 'token');
      if (token == null) {
        throw Exception('Chưa đăng nhập');
      }

      // Tạo multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/ExerciseImages/upload'),
      );

      // Thêm headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      // Thêm file
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          image.path,
        ),
      );

      // Gửi request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return data['imageUrl'];
      } else {
        throw Exception('Không thể tải lên ảnh: ${response.body}');
      }
    } catch (e) {
      throw Exception('Lỗi khi tải lên ảnh: $e');
    }
  }

  // Lấy danh sách ảnh của bài tập
  Future<List<String>> getExerciseImages(int exerciseId) async {
    try {
      final token = await _storage.read(key: 'token');
      if (token == null) {
        throw Exception('Chưa đăng nhập');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/ExerciseImages/$exerciseId/images'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((url) => url.toString()).toList();
      } else {
        throw Exception('Không thể lấy ảnh bài tập: ${response.body}');
      }
    } catch (e) {
      throw Exception('Lỗi khi lấy ảnh bài tập: $e');
    }
  }
} 