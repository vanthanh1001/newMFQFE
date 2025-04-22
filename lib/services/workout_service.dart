import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/workout_plan.dart';
import '../models/workout_session.dart';
import '../models/exercise.dart';
import '../utils/constants.dart';

class WorkoutService {
  final String baseUrl = AppConstants.apiBaseUrl;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Lấy danh sách workout plans của user
  Future<List<WorkoutPlan>> getWorkoutPlans() async {
    final token = await _storage.read(key: 'token');
    if (token == null) {
      throw Exception('Không tìm thấy token xác thực');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/workout/plans'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> plans = data['data'];
      
      return plans.map((plan) => WorkoutPlan.fromJson(plan)).toList();
    } else {
      throw Exception('Không thể lấy danh sách workout plans: ${response.statusCode}');
    }
  }
  
  // Lấy chi tiết workout plan bằng ID
  Future<WorkoutPlan> getWorkoutPlanDetail(int id) async {
    final token = await _storage.read(key: 'token');
    if (token == null) {
      throw Exception('Không tìm thấy token xác thực');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/workout/plans/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return WorkoutPlan.fromJson(data['data']);
    } else {
      throw Exception('Không thể lấy chi tiết workout plan: ${response.statusCode}');
    }
  }
  
  // Tạo workout plan mới
  Future<WorkoutPlan> createWorkoutPlan(CreateWorkoutPlanRequest request) async {
    final token = await _storage.read(key: 'token');
    if (token == null) {
      throw Exception('Không tìm thấy token xác thực');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/workout/plans'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> data = json.decode(response.body);
      return WorkoutPlan.fromJson(data['data']);
    } else {
      throw Exception('Không thể tạo workout plan: ${response.statusCode}');
    }
  }
  
  // Xóa workout plan
  Future<bool> deleteWorkoutPlan(int id) async {
    final token = await _storage.read(key: 'token');
    if (token == null) {
      throw Exception('Không tìm thấy token xác thực');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/workout/plans/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return response.statusCode == 200;
  }
  
  // Lấy danh sách public exercises
  Future<List<Exercise>> getPublicExercises() async {
    final token = await _storage.read(key: 'token');
    if (token == null) {
      throw Exception('Không tìm thấy token xác thực');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/workout/public-exercises'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> exercises = data['data'];
      
      return exercises.map((exercise) => Exercise.fromJson(exercise)).toList();
    } else {
      throw Exception('Không thể lấy danh sách bài tập: ${response.statusCode}');
    }
  }
  
  // Tìm kiếm exercises
  Future<List<Exercise>> searchExercises(String query) async {
    final token = await _storage.read(key: 'token');
    if (token == null) {
      throw Exception('Không tìm thấy token xác thực');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/exercise/search?name=$query'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> exercises = data['data'];
      
      return exercises.map((exercise) => Exercise.fromJson(exercise)).toList();
    } else {
      throw Exception('Không thể tìm kiếm bài tập: ${response.statusCode}');
    }
  }
  
  // Lấy lịch sử tập luyện
  Future<WorkoutHistory> getWorkoutHistory() async {
    final token = await _storage.read(key: 'token');
    if (token == null) {
      throw Exception('Không tìm thấy token xác thực');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/workoutsession/history'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return WorkoutHistory.fromJson(data['data']);
    } else {
      throw Exception('Không thể lấy lịch sử tập luyện: ${response.statusCode}');
    }
  }
  
  // Tạo workout session mới
  Future<WorkoutSession> createWorkoutSession(CreateWorkoutSessionRequest request) async {
    final token = await _storage.read(key: 'token');
    if (token == null) {
      throw Exception('Không tìm thấy token xác thực');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/workoutsession'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> data = json.decode(response.body);
      return WorkoutSession.fromJson(data['data']);
    } else {
      throw Exception('Không thể tạo phiên tập luyện: ${response.statusCode}');
    }
  }
} 