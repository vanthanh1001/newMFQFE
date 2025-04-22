import 'package:flutter/material.dart';
import '../models/workout_plan.dart';
import '../models/workout_session.dart';
import '../models/exercise.dart';
import '../services/workout_service.dart';

class WorkoutProvider extends ChangeNotifier {
  final WorkoutService _workoutService = WorkoutService();
  
  // Workout Plans
  List<WorkoutPlan> _workoutPlans = [];
  WorkoutPlan? _selectedWorkoutPlan;
  bool _isLoadingPlans = false;
  String? _errorPlans;
  
  // Exercises
  List<Exercise> _exercises = [];
  bool _isLoadingExercises = false;
  String? _errorExercises;
  
  // Workout History
  WorkoutHistory? _workoutHistory;
  bool _isLoadingHistory = false;
  String? _errorHistory;
  
  // Getters
  List<WorkoutPlan> get workoutPlans => _workoutPlans;
  WorkoutPlan? get selectedWorkoutPlan => _selectedWorkoutPlan;
  bool get isLoadingPlans => _isLoadingPlans;
  String? get errorPlans => _errorPlans;
  
  List<Exercise> get exercises => _exercises;
  bool get isLoadingExercises => _isLoadingExercises;
  String? get errorExercises => _errorExercises;
  
  WorkoutHistory? get workoutHistory => _workoutHistory;
  bool get isLoadingHistory => _isLoadingHistory;
  String? get errorHistory => _errorHistory;
  
  // Fetch Workout Plans
  Future<void> fetchWorkoutPlans() async {
    _isLoadingPlans = true;
    _errorPlans = null;
    notifyListeners();
    
    try {
      _workoutPlans = await _workoutService.getWorkoutPlans();
      _errorPlans = null;
    } catch (e) {
      _errorPlans = e.toString();
    } finally {
      _isLoadingPlans = false;
      notifyListeners();
    }
  }
  
  // Fetch Workout Plan Detail
  Future<WorkoutPlan?> fetchWorkoutPlanDetail(int planId) async {
    _isLoadingPlans = true;
    _errorPlans = null;
    notifyListeners();
    
    try {
      _selectedWorkoutPlan = await _workoutService.getWorkoutPlanDetail(planId);
      _errorPlans = null;
      return _selectedWorkoutPlan;
    } catch (e) {
      _errorPlans = e.toString();
      return null;
    } finally {
      _isLoadingPlans = false;
      notifyListeners();
    }
  }
  
  // Create Workout Plan
  Future<WorkoutPlan?> createWorkoutPlan(CreateWorkoutPlanRequest request) async {
    _isLoadingPlans = true;
    _errorPlans = null;
    notifyListeners();
    
    try {
      final workoutPlan = await _workoutService.createWorkoutPlan(request);
      _workoutPlans.add(workoutPlan);
      _errorPlans = null;
      notifyListeners();
      return workoutPlan;
    } catch (e) {
      _errorPlans = e.toString();
      notifyListeners();
      return null;
    } finally {
      _isLoadingPlans = false;
      notifyListeners();
    }
  }
  
  // Delete Workout Plan
  Future<bool> deleteWorkoutPlan(int planId) async {
    _isLoadingPlans = true;
    _errorPlans = null;
    notifyListeners();
    
    try {
      final success = await _workoutService.deleteWorkoutPlan(planId);
      if (success) {
        _workoutPlans.removeWhere((plan) => plan.id == planId);
        if (_selectedWorkoutPlan?.id == planId) {
          _selectedWorkoutPlan = null;
        }
      }
      _errorPlans = null;
      notifyListeners();
      return success;
    } catch (e) {
      _errorPlans = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoadingPlans = false;
      notifyListeners();
    }
  }
  
  // Fetch Public Exercises
  Future<void> fetchPublicExercises() async {
    _isLoadingExercises = true;
    _errorExercises = null;
    notifyListeners();
    
    try {
      _exercises = await _workoutService.getPublicExercises();
      _errorExercises = null;
    } catch (e) {
      _errorExercises = e.toString();
    } finally {
      _isLoadingExercises = false;
      notifyListeners();
    }
  }
  
  // Search Exercises
  Future<void> searchExercises(String query) async {
    if (query.isEmpty) {
      fetchPublicExercises();
      return;
    }
    
    _isLoadingExercises = true;
    _errorExercises = null;
    notifyListeners();
    
    try {
      _exercises = await _workoutService.searchExercises(query);
      _errorExercises = null;
    } catch (e) {
      _errorExercises = e.toString();
    } finally {
      _isLoadingExercises = false;
      notifyListeners();
    }
  }
  
  // Fetch Workout History
  Future<void> fetchWorkoutHistory() async {
    _isLoadingHistory = true;
    _errorHistory = null;
    notifyListeners();
    
    try {
      _workoutHistory = await _workoutService.getWorkoutHistory();
      _errorHistory = null;
    } catch (e) {
      _errorHistory = e.toString();
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }
  
  // Create Workout Session
  Future<WorkoutSession?> createWorkoutSession(CreateWorkoutSessionRequest request) async {
    try {
      final session = await _workoutService.createWorkoutSession(request);
      
      // Cập nhật lịch sử nếu đã tải
      if (_workoutHistory != null) {
        await fetchWorkoutHistory();
      }
      
      return session;
    } catch (e) {
      return null;
    }
  }
} 