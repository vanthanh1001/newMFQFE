import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../goal/goal_model.dart';
import '../challenge.dart';
import '../../services/goal_service.dart';
import '../../services/challenge_service.dart';

// Trạng thái kết hợp quản lý cả mục tiêu và thử thách
class GoalChallengeState {
  // Mục tiêu
  final List<GoalModel> goals;
  final bool isLoadingGoals;
  
  // Thử thách
  final List<Challenge> activeChallenges;
  final List<Challenge> upcomingChallenges;
  final List<Challenge> completedChallenges;
  final bool isLoadingActiveChallenges;
  final bool isLoadingUpcomingChallenges;
  final bool isLoadingCompletedChallenges;
  
  // Chung
  final String? errorMessage;
  final bool sessionExpired;

  GoalChallengeState({
    // Mục tiêu
    required this.goals,
    required this.isLoadingGoals,
    
    // Thử thách
    required this.activeChallenges,
    required this.upcomingChallenges,
    required this.completedChallenges,
    required this.isLoadingActiveChallenges,
    required this.isLoadingUpcomingChallenges,
    required this.isLoadingCompletedChallenges,
    
    // Chung
    this.errorMessage,
    required this.sessionExpired,
  });

  // Hàm tạo bản sao với các giá trị mới
  GoalChallengeState copyWith({
    // Mục tiêu
    List<GoalModel>? goals,
    bool? isLoadingGoals,
    
    // Thử thách
    List<Challenge>? activeChallenges,
    List<Challenge>? upcomingChallenges,
    List<Challenge>? completedChallenges,
    bool? isLoadingActiveChallenges,
    bool? isLoadingUpcomingChallenges,
    bool? isLoadingCompletedChallenges,
    
    // Chung
    String? errorMessage,
    bool? sessionExpired,
  }) {
    return GoalChallengeState(
      // Mục tiêu
      goals: goals ?? this.goals,
      isLoadingGoals: isLoadingGoals ?? this.isLoadingGoals,
      
      // Thử thách
      activeChallenges: activeChallenges ?? this.activeChallenges,
      upcomingChallenges: upcomingChallenges ?? this.upcomingChallenges,
      completedChallenges: completedChallenges ?? this.completedChallenges,
      isLoadingActiveChallenges: isLoadingActiveChallenges ?? this.isLoadingActiveChallenges,
      isLoadingUpcomingChallenges: isLoadingUpcomingChallenges ?? this.isLoadingUpcomingChallenges,
      isLoadingCompletedChallenges: isLoadingCompletedChallenges ?? this.isLoadingCompletedChallenges,
      
      // Chung
      errorMessage: errorMessage,
      sessionExpired: sessionExpired ?? this.sessionExpired,
    );
  }
}

// Notifier quản lý state cho cả Goal và Challenge
class GoalChallengeNotifier extends StateNotifier<GoalChallengeState> {
  final GoalService _goalService = GoalService();
  final ChallengeService _challengeService = ChallengeService();

  GoalChallengeNotifier() : super(GoalChallengeState(
    // Mục tiêu
    goals: [],
    isLoadingGoals: false,
    
    // Thử thách
    activeChallenges: [],
    upcomingChallenges: [],
    completedChallenges: [],
    isLoadingActiveChallenges: false,
    isLoadingUpcomingChallenges: false,
    isLoadingCompletedChallenges: false,
    
    // Chung
    errorMessage: null,
    sessionExpired: false,
  ));

  // ===== PHẦN QUẢN LÝ MỤC TIÊU =====
  // Lấy danh sách mục tiêu
  Future<void> fetchGoals() async {
    state = state.copyWith(isLoadingGoals: true, errorMessage: null);
    
    try {
      await _checkTokenStatus();
      if (state.sessionExpired) {
        state = state.copyWith(isLoadingGoals: false);
        return;
      }
      
      final goals = await _goalService.getAllGoals();
      state = state.copyWith(goals: goals, isLoadingGoals: false, errorMessage: null);
    } catch (e) {
      state = state.copyWith(
        isLoadingGoals: false,
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
    state = state.copyWith(isLoadingGoals: true, errorMessage: null);
    
    try {
      await _checkTokenStatus();
      if (state.sessionExpired) {
        state = state.copyWith(isLoadingGoals: false);
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
      state = state.copyWith(goals: updatedGoals, isLoadingGoals: false);
      
      return newGoal;
    } catch (e) {
      state = state.copyWith(
        isLoadingGoals: false,
        errorMessage: e.toString(),
      );
      debugPrint('Lỗi khi tạo mục tiêu: $e');
      return null;
    }
  }

  // Cập nhật tiến độ mục tiêu
  Future<bool> updateGoalProgress(int id, double progressPercentage) async {
    state = state.copyWith(isLoadingGoals: true, errorMessage: null);
    
    try {
      await _checkTokenStatus();
      if (state.sessionExpired) {
        state = state.copyWith(isLoadingGoals: false);
        return false;
      }
      
      final updatedGoal = await _goalService.updateGoalProgress(id, progressPercentage);
      
      // Cập nhật danh sách
      final goalIndex = state.goals.indexWhere((goal) => goal.id == id);
      if (goalIndex != -1) {
        final updatedGoals = [...state.goals];
        updatedGoals[goalIndex] = updatedGoal;
        state = state.copyWith(goals: updatedGoals, isLoadingGoals: false);
      }
      
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoadingGoals: false,
        errorMessage: e.toString(),
      );
      debugPrint('Lỗi khi cập nhật tiến độ mục tiêu: $e');
      return false;
    }
  }

  // Xóa mục tiêu
  Future<bool> deleteGoal(int id) async {
    state = state.copyWith(isLoadingGoals: true, errorMessage: null);
    
    try {
      await _checkTokenStatus();
      if (state.sessionExpired) {
        state = state.copyWith(isLoadingGoals: false);
        return false;
      }
      
      final success = await _goalService.deleteGoal(id);
      if (success) {
        // Xóa mục tiêu khỏi danh sách
        final updatedGoals = state.goals.where((goal) => goal.id != id).toList();
        state = state.copyWith(goals: updatedGoals, isLoadingGoals: false);
      }
      
      return success;
    } catch (e) {
      state = state.copyWith(
        isLoadingGoals: false,
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

  // ===== PHẦN QUẢN LÝ THỬ THÁCH =====
  // Lấy danh sách thử thách đang hoạt động
  Future<void> fetchActiveChallenges() async {
    state = state.copyWith(isLoadingActiveChallenges: true, errorMessage: null);
    
    try {
      await _checkTokenStatus();
      if (state.sessionExpired) {
        state = state.copyWith(isLoadingActiveChallenges: false);
        return;
      }
      
      final activeChallenges = await _challengeService.getActiveChallenges();
      state = state.copyWith(activeChallenges: activeChallenges, isLoadingActiveChallenges: false, errorMessage: null);
    } catch (e) {
      state = state.copyWith(
        isLoadingActiveChallenges: false,
        errorMessage: e.toString(),
      );
      debugPrint('Lỗi khi lấy thử thách đang hoạt động: $e');
    }
  }

  // Lấy danh sách thử thách sắp diễn ra
  Future<void> fetchUpcomingChallenges() async {
    state = state.copyWith(isLoadingUpcomingChallenges: true, errorMessage: null);
    
    try {
      await _checkTokenStatus();
      if (state.sessionExpired) {
        state = state.copyWith(isLoadingUpcomingChallenges: false);
        return;
      }
      
      final upcomingChallenges = await _challengeService.getUpcomingChallenges();
      state = state.copyWith(upcomingChallenges: upcomingChallenges, isLoadingUpcomingChallenges: false, errorMessage: null);
    } catch (e) {
      state = state.copyWith(
        isLoadingUpcomingChallenges: false,
        errorMessage: e.toString(),
      );
      debugPrint('Lỗi khi lấy thử thách sắp diễn ra: $e');
    }
  }

  // Lấy danh sách thử thách đã hoàn thành
  Future<void> fetchCompletedChallenges() async {
    state = state.copyWith(isLoadingCompletedChallenges: true, errorMessage: null);
    
    try {
      await _checkTokenStatus();
      if (state.sessionExpired) {
        state = state.copyWith(isLoadingCompletedChallenges: false);
        return;
      }
      
      final completedChallenges = await _challengeService.getCompletedChallenges();
      state = state.copyWith(completedChallenges: completedChallenges, isLoadingCompletedChallenges: false, errorMessage: null);
    } catch (e) {
      state = state.copyWith(
        isLoadingCompletedChallenges: false,
        errorMessage: e.toString(),
      );
      debugPrint('Lỗi khi lấy thử thách đã hoàn thành: $e');
    }
  }

  // Tham gia thử thách
  Future<bool> joinChallenge(int challengeId) async {
    state = state.copyWith(errorMessage: null);
    
    try {
      await _checkTokenStatus();
      if (state.sessionExpired) {
        return false;
      }
      
      final result = await _challengeService.joinChallenge(challengeId);
      
      // Nếu tham gia thành công, cập nhật lại danh sách
      if (result) {
        await fetchActiveChallenges();
      }
      
      return result;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      debugPrint('Lỗi khi tham gia thử thách: $e');
      return false;
    }
  }

  // Cập nhật tiến độ thử thách
  Future<bool> updateChallengeProgress(int challengeId, int pointsEarned) async {
    state = state.copyWith(errorMessage: null);
    
    try {
      await _checkTokenStatus();
      if (state.sessionExpired) {
        return false;
      }
      
      final result = await _challengeService.updateChallengeProgress(challengeId, pointsEarned);
      return result['isCompleted'] ?? false;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      debugPrint('Lỗi khi cập nhật tiến độ thử thách: $e');
      return false;
    }
  }

  // Lấy tất cả dữ liệu
  Future<void> fetchAllData() async {
    // Lấy dữ liệu mục tiêu
    await fetchGoals();
    
    // Lấy dữ liệu thử thách
    await fetchActiveChallenges();
    await fetchUpcomingChallenges();
    await fetchCompletedChallenges();
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

// Provider cho GoalChallengeNotifier
final goalChallengeProvider = StateNotifierProvider<GoalChallengeNotifier, GoalChallengeState>((ref) {
  return GoalChallengeNotifier();
}); 