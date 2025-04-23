import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/goal/goal_model.dart';
import '../services/goal_service.dart';
import 'auth_provider.dart';
import '../screens/auth/login_screen.dart';

// Trạng thái để quản lý danh sách Goal
class GoalState {
  final List<GoalModel> goals;
  final bool isLoading;
  final String? errorMessage;
  final bool sessionExpired;

  GoalState({
    required this.goals,
    required this.isLoading,
    this.errorMessage,
    required this.sessionExpired,
  });

  GoalState copyWith({
    List<GoalModel>? goals,
    bool? isLoading,
    String? errorMessage,
    bool? sessionExpired,
  }) {
    return GoalState(
      goals: goals ?? this.goals,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      sessionExpired: sessionExpired ?? this.sessionExpired,
    );
  }
}

// Notifier quản lý state Goal
class GoalNotifier extends StateNotifier<GoalState> {
  final GoalService _goalService = GoalService();

  GoalNotifier() : super(GoalState(
    goals: [],
    isLoading: false,
    errorMessage: null,
    sessionExpired: false,
  ));

  // Lấy danh sách mục tiêu
  Future<void> fetchGoals() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      await _checkTokenStatus();
      if (state.sessionExpired) {
        state = state.copyWith(isLoading: false);
        return;
      }
      
      final goals = await _goalService.getAllGoals();
      state = state.copyWith(goals: goals, isLoading: false, errorMessage: null);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      debugPrint('Lỗi khi lấy danh sách mục tiêu: $e');
    }
  }

  // Lấy chi tiết mục tiêu theo ID
  Future<GoalModel?> getGoalById(int id) async {
    try {
      await _checkTokenStatus();
      if (state.sessionExpired) {
        return null;
      }
      
      return await _goalService.getGoalById(id);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      debugPrint('Lỗi khi lấy chi tiết mục tiêu: $e');
      return null;
    }
  }

  // Tạo mục tiêu mới
  Future<GoalModel?> createGoal({
    required String name,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    String? category,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      await _checkTokenStatus();
      if (state.sessionExpired) {
        state = state.copyWith(isLoading: false);
        return null;
      }
      
      final newGoal = await _goalService.createGoal(
        name: name,
        description: description,
        startDate: startDate,
        endDate: endDate,
        category: category,
      );
      
      // Cập nhật danh sách mục tiêu
      final updatedGoals = [...state.goals, newGoal];
      state = state.copyWith(goals: updatedGoals, isLoading: false);
      
      return newGoal;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      debugPrint('Lỗi khi tạo mục tiêu: $e');
      return null;
    }
  }

  // Cập nhật tiến độ mục tiêu
  Future<bool> updateGoalProgress(int id, double progressPercentage) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      await _checkTokenStatus();
      if (state.sessionExpired) {
        state = state.copyWith(isLoading: false);
        return false;
      }
      
      final updatedGoal = await _goalService.updateGoalProgress(id, progressPercentage);
      
      // Cập nhật danh sách
      final goalIndex = state.goals.indexWhere((goal) => goal.id == id);
      if (goalIndex != -1) {
        final updatedGoals = [...state.goals];
        updatedGoals[goalIndex] = updatedGoal;
        state = state.copyWith(goals: updatedGoals, isLoading: false);
      }
      
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      debugPrint('Lỗi khi cập nhật tiến độ mục tiêu: $e');
      return false;
    }
  }

  // Xóa mục tiêu
  Future<bool> deleteGoal(int id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      await _checkTokenStatus();
      if (state.sessionExpired) {
        state = state.copyWith(isLoading: false);
        return false;
      }
      
      final success = await _goalService.deleteGoal(id);
      if (success) {
        // Xóa mục tiêu khỏi danh sách
        final updatedGoals = state.goals.where((goal) => goal.id != id).toList();
        state = state.copyWith(goals: updatedGoals, isLoading: false);
      }
      
      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      debugPrint('Lỗi khi xóa mục tiêu: $e');
      return false;
    }
  }

  // Lọc danh sách mục tiêu theo trạng thái
  List<GoalModel> getActiveGoals() {
    return state.goals.where((goal) => goal.isActive).toList();
  }

  List<GoalModel> getUpcomingGoals() {
    return state.goals.where((goal) => goal.isUpcoming).toList();
  }

  List<GoalModel> getCompletedGoals() {
    return state.goals.where((goal) => goal.isCompleted).toList();
  }

  List<GoalModel> getPastDueGoals() {
    return state.goals.where((goal) => goal.isPastDue).toList();
  }

  // Kiểm tra trạng thái token
  Future<void> _checkTokenStatus() async {
    final isValid = await _goalService.checkTokenValidity();
    if (!isValid) {
      state = state.copyWith(
        sessionExpired: true,
        errorMessage: 'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại',
      );
    }
  }

  // Reset trạng thái phiên
  void resetSessionState() {
    state = state.copyWith(
      sessionExpired: false,
      errorMessage: null,
    );
  }
}

// Provider cho GoalNotifier
final goalProvider = StateNotifierProvider<GoalNotifier, GoalState>((ref) {
  return GoalNotifier();
}); 