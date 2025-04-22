import 'dart:io';
import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../services/exercise_service.dart';

class ExerciseProvider with ChangeNotifier {
  final ExerciseService _exerciseService = ExerciseService();
  List<Exercise> _exercises = [];
  List<Exercise> _filteredExercises = [];
  Exercise? _selectedExercise;
  bool _isLoading = false;
  String? _errorMessage;
  List<String> _exerciseImages = [];

  List<Exercise> get exercises => _exercises;
  List<Exercise> get filteredExercises => _filteredExercises.isEmpty ? _exercises : _filteredExercises;
  Exercise? get selectedExercise => _selectedExercise;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<String> get exerciseImages => _exerciseImages;

  // Lấy danh sách tất cả bài tập
  Future<void> fetchExercises() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _exercises = await _exerciseService.getExercises();
      _filteredExercises = [];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Lấy chi tiết của một bài tập
  Future<void> fetchExerciseDetail(int id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _selectedExercise = await _exerciseService.getExerciseById(id);
      
      // Lấy ảnh của bài tập
      await fetchExerciseImages(id);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Lấy ảnh của bài tập
  Future<void> fetchExerciseImages(int exerciseId) async {
    try {
      _exerciseImages = [];
      notifyListeners();

      _exerciseImages = await _exerciseService.getExerciseImages(exerciseId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Không thể tải ảnh bài tập: ${e.toString()}';
      notifyListeners();
    }
  }

  // Tạo bài tập mới
  Future<bool> createExercise({
    required String name,
    required String description,
    required int sets,
    required int reps,
    required int restTime,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final newExercise = await _exerciseService.createExercise(
        name: name,
        description: description,
        sets: sets,
        reps: reps,
        restTime: restTime,
      );

      _exercises.add(newExercise);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Cập nhật bài tập
  Future<bool> updateExercise({
    required int id,
    required String name,
    required String description,
    required int sets,
    required int reps,
    required int restTime,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _exerciseService.updateExercise(
        id: id,
        name: name,
        description: description,
        sets: sets,
        reps: reps,
        restTime: restTime,
      );

      // Cập nhật phiên bản cục bộ
      final index = _exercises.indexWhere((exercise) => exercise.id == id);
      if (index != -1) {
        final oldExercise = _exercises[index];
        final updatedExercise = Exercise(
          id: id,
          name: name,
          description: description,
          sets: sets,
          reps: reps,
          restTime: restTime,
          createdAt: oldExercise.createdAt,
          updatedAt: DateTime.now(),
          createdById: oldExercise.createdById,
          createdByUsername: oldExercise.createdByUsername,
          muscleGroup: oldExercise.muscleGroup,
        );
        _exercises[index] = updatedExercise;
        
        if (_selectedExercise?.id == id) {
          _selectedExercise = updatedExercise;
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Xóa bài tập
  Future<bool> deleteExercise(int id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _exerciseService.deleteExercise(id);

      // Xóa khỏi danh sách cục bộ
      _exercises.removeWhere((exercise) => exercise.id == id);
      if (_selectedExercise?.id == id) {
        _selectedExercise = null;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Tìm kiếm bài tập
  Future<void> searchExercises(String query) async {
    if (query.isEmpty) {
      _filteredExercises = [];
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _filteredExercises = await _exerciseService.searchExercises(query);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Filter exercises theo muscle group
  void filterByMuscleGroup(String muscleGroup) {
    if (muscleGroup.isEmpty || muscleGroup == 'Tất cả') {
      _filteredExercises = [];
    } else {
      _filteredExercises = _exercises.where(
        (exercise) => exercise.muscleGroup == muscleGroup
      ).toList();
    }
    notifyListeners();
  }

  // Upload ảnh cho bài tập
  Future<String?> uploadExerciseImage(File image) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final imageUrl = await _exerciseService.uploadExerciseImage(image);
      
      if (_selectedExercise != null) {
        // Nếu đang xem chi tiết bài tập, thêm ảnh vào danh sách
        _exerciseImages.add(imageUrl);
      }

      _isLoading = false;
      notifyListeners();
      return imageUrl;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
} 