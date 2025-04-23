import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/goal_provider.dart';
import '../providers/challenge_provider.dart';
import '../models/challenge/challenge_model.dart';
import '../models/goal/goal_model.dart';
import '../services/goal_service.dart';
import '../services/challenge_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../screens/auth/login_screen.dart';

// Provider chung cho cả Goal và Challenge
final combinedGoalChallengeProvider = 
    ChangeNotifierProvider<GoalChallengeProvider>((ref) {
  return GoalChallengeProvider(
    ref.watch(goalProvider.notifier),
    ref.watch(challengeProvider.notifier),
  );
});

class GoalChallengeProvider extends ChangeNotifier {
  final GoalProvider _goalProvider;
  final ChallengeProvider _challengeProvider;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  bool _isLoading = false;
  bool _hasError = false;
  bool _sessionExpired = false;
  String _errorMessage = '';

  // Constructor
  GoalChallengeProvider(this._goalProvider, this._challengeProvider);

  // Getters
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  bool get sessionExpired => _sessionExpired || 
      _goalProvider.sessionExpired || 
      _challengeProvider.sessionExpired;
  String get errorMessage => _errorMessage;
  
  List<Goal> get activeGoals => _goalProvider.activeGoals;
  List<Goal> get completedGoals => _goalProvider.completedGoals;
  List<Challenge> get activeChallenges => _challengeProvider.activeChallenges;
  List<Challenge> get upcomingChallenges => _challengeProvider.upcomingChallenges;
  List<Challenge> get myChallenges => _challengeProvider.myChallenges;

  // Fetch tất cả dữ liệu
  Future<void> fetchAllData() async {
    await _checkTokenStatus();
    if (_sessionExpired) return;
    
    _isLoading = true;
    _hasError = false;
    _errorMessage = '';
    notifyListeners();
    
    try {
      // Fetch đồng thời goals và challenges
      await Future.wait([
        _goalProvider.fetchActiveGoals(),
        _goalProvider.fetchCompletedGoals(),
        _challengeProvider.fetchActiveChallenges(),
        _challengeProvider.fetchUpcomingChallenges(),
        _challengeProvider.fetchMyChallenges(),
      ]);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _hasError = true;
      _errorMessage = 'Lỗi tải dữ liệu: $e';
      notifyListeners();
    }
  }
  
  // Các phương thức goal
  Future<void> addGoal(Goal goal) async {
    await _checkTokenStatus();
    if (_sessionExpired) return;
    
    await _goalProvider.addGoal(goal);
    notifyListeners();
  }
  
  Future<void> updateGoal(Goal goal) async {
    await _checkTokenStatus();
    if (_sessionExpired) return;
    
    await _goalProvider.updateGoal(goal);
    notifyListeners();
  }
  
  Future<void> deleteGoal(String goalId) async {
    await _checkTokenStatus();
    if (_sessionExpired) return;
    
    await _goalProvider.deleteGoal(goalId);
    notifyListeners();
  }
  
  Future<void> completeGoal(String goalId) async {
    await _checkTokenStatus();
    if (_sessionExpired) return;
    
    await _goalProvider.completeGoal(goalId);
    notifyListeners();
  }
  
  // Các phương thức challenge
  Future<void> joinChallenge(String challengeId) async {
    await _checkTokenStatus();
    if (_sessionExpired) return;
    
    await _challengeProvider.joinChallenge(challengeId);
    notifyListeners();
  }
  
  Future<void> updateChallengeProgress(String challengeId, int completedTasks) async {
    await _checkTokenStatus();
    if (_sessionExpired) return;
    
    await _challengeProvider.updateChallengeProgress(challengeId, completedTasks);
    notifyListeners();
  }
  
  // Kiểm tra token và session
  Future<void> _checkTokenStatus() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null || token.isEmpty) {
        _sessionExpired = true;
        notifyListeners();
        return;
      }
      
      // Thử gọi API đơn giản để kiểm tra token
      final goalService = GoalService();
      final challengeService = ChallengeService();
      
      final isGoalTokenValid = await goalService.checkTokenValidity();
      final isChallengeTokenValid = await challengeService.checkTokenValidity();
      
      if (!isGoalTokenValid || !isChallengeTokenValid) {
        _sessionExpired = true;
        notifyListeners();
      }
    } catch (e) {
      _sessionExpired = true;
      notifyListeners();
    }
  }
  
  // Reset trạng thái session
  void resetSessionState() {
    _sessionExpired = false;
    _goalProvider.resetSessionState();
    _challengeProvider.resetSessionState();
    notifyListeners();
  }
  
  // Function để điều hướng người dùng đến màn hình đăng nhập khi token hết hạn
  void navigateToLogin(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }
} 