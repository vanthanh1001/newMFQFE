import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/challenge/challenge_model.dart';
import '../services/challenge_service.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ChallengeProvider extends ChangeNotifier {
  final ChallengeService _challengeService = ChallengeService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  List<Challenge> _activeChallenges = [];
  List<Challenge> _upcomingChallenges = [];
  List<Challenge> _completedChallenges = [];
  Challenge? _selectedChallenge;
  
  bool _isLoading = false;
  bool _joiningChallenge = false;
  bool _sessionExpired = false;
  
  String? _error;
  
  // Getters
  List<Challenge> get activeChallenges => _activeChallenges;
  List<Challenge> get upcomingChallenges => _upcomingChallenges;
  List<Challenge> get completedChallenges => _completedChallenges;
  Challenge? get selectedChallenge => _selectedChallenge;
  
  bool get isLoading => _isLoading;
  bool get joiningChallenge => _joiningChallenge;
  bool get sessionExpired => _sessionExpired;
  
  String? get error => _error;
  String? get errorMessage => _error;
  
  // Lấy danh sách thử thách đang hoạt động
  Future<void> fetchActiveChallenges() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _checkTokenStatus();
      if (_sessionExpired) return;
      
      _activeChallenges = await _challengeService.getActiveChallenges();
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Lỗi khi lấy thử thách đang hoạt động: $e');
      if (e.toString().contains('Phiên đăng nhập đã hết hạn')) {
        _sessionExpired = true;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Lấy danh sách thử thách sắp diễn ra
  Future<void> fetchUpcomingChallenges() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _checkTokenStatus();
      if (_sessionExpired) return;
      
      _upcomingChallenges = await _challengeService.getUpcomingChallenges();
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Lỗi khi lấy thử thách sắp diễn ra: $e');
      if (e.toString().contains('Phiên đăng nhập đã hết hạn')) {
        _sessionExpired = true;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Lấy danh sách thử thách đã hoàn thành
  Future<void> fetchCompletedChallenges() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _checkTokenStatus();
      if (_sessionExpired) return;
      
      _completedChallenges = await _challengeService.getCompletedChallenges();
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Lỗi khi lấy thử thách đã hoàn thành: $e');
      if (e.toString().contains('Phiên đăng nhập đã hết hạn')) {
        _sessionExpired = true;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Tham gia thử thách
  Future<bool> joinChallenge(int challengeId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _checkTokenStatus();
      if (_sessionExpired) return false;
      
      final result = await _challengeService.joinChallenge(challengeId);
      if (result) {
        // Cập nhật lại danh sách thử thách sau khi tham gia
        await fetchActiveChallenges();
      }
      _error = null;
      return result;
    } catch (e) {
      _error = e.toString();
      debugPrint('Lỗi khi tham gia thử thách: $e');
      if (e.toString().contains('Phiên đăng nhập đã hết hạn')) {
        _sessionExpired = true;
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Lấy chi tiết thử thách
  Future<Challenge?> getChallengeById(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _checkTokenStatus();
      if (_sessionExpired) return null;
      
      _selectedChallenge = await _challengeService.getChallengeById(id);
      _error = null;
      return _selectedChallenge;
    } catch (e) {
      _error = e.toString();
      debugPrint('Lỗi khi lấy chi tiết thử thách: $e');
      if (e.toString().contains('Phiên đăng nhập đã hết hạn')) {
        _sessionExpired = true;
      }
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Xóa lỗi
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  // Tải lại tất cả dữ liệu
  Future<void> refreshChallenges() async {
    _error = null;
    try {
      await _checkTokenStatus();
      if (_sessionExpired) return;
      
      await Future.wait([
        fetchActiveChallenges(),
        fetchUpcomingChallenges(),
        fetchCompletedChallenges(),
      ]);
    } catch (e) {
      _error = e.toString();
      debugPrint('Lỗi khi làm mới dữ liệu: $e');
    }
  }
  
  // Kiểm tra trạng thái token
  Future<void> _checkTokenStatus() async {
    try {
      final isValid = await _challengeService.checkTokenValidity();
      if (!isValid && !_sessionExpired) {
        _sessionExpired = true;
        _error = 'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại.';
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Lỗi khi kiểm tra token: $e');
    }
  }
  
  // Đặt lại trạng thái phiên
  void resetSessionState() {
    _sessionExpired = false;
    _error = null;
    notifyListeners();
  }

  // Xử lý khi phiên đăng nhập hết hạn
  void handleSessionExpired(BuildContext context) {
    if (_sessionExpired) {
      // Chuyển đến màn hình đăng nhập
      Navigator.of(context).pushNamedAndRemoveUntil(
        LoginScreen.routePath,
        (route) => false,
      );
    }
  }
} 