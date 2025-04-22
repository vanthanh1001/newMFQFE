import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;
  bool _initialized = false;
  final _storage = const FlutterSecureStorage();
  final AuthService _authService = AuthService();

  bool get isAuth => _token != null;
  String? get token => _token;
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get initialized => _initialized;

  Future<bool> tryAutoLogin() async {
    try {
      _isLoading = true;
      
      final isLoggedIn = await _authService.isLoggedIn();
      if (!isLoggedIn) {
        _isLoading = false;
        _initialized = true;
        return false;
      }

      _token = await _authService.getToken();
      _user = await _authService.getUserData();

      _isLoading = false;
      _initialized = true;
      
      Future.microtask(() => notifyListeners());
      
      return true;
    } catch (error) {
      _isLoading = false;
      _initialized = true;
      
      Future.microtask(() => notifyListeners());
      
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print('AuthProvider: Bắt đầu gọi login() từ authService');
      final result = await _authService.login(email, password);
      
      _isLoading = false;
      
      if (result['success'] == true) {
        _token = result['token'];
        _user = result['user'];
        _errorMessage = null;
        print('AuthProvider: Đăng nhập thành công, token và user đã được lưu');
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Đăng nhập thất bại';
        print('AuthProvider: Đăng nhập thất bại - $_errorMessage');
        notifyListeners();
        return false;
      }
    } catch (error) {
      print('AuthProvider: Exception khi đăng nhập - ${error.toString()}');
      _isLoading = false;
      _errorMessage = 'Lỗi không xác định: ${error.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print('AuthProvider: Bắt đầu đăng nhập với Google');
      final result = await _authService.signInWithGoogle();
      
      _isLoading = false;
      
      if (result['success'] == true) {
        _token = result['token'];
        _user = result['user'];
        _errorMessage = null;
        print('AuthProvider: Đăng nhập Google thành công');
        
        if (result.containsKey('message')) {
          // Trường hợp demo/debug khi API chưa hỗ trợ
          print('Thông báo: ${result['message']}');
        }
        
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Đăng nhập Google thất bại';
        print('AuthProvider: Đăng nhập Google thất bại - $_errorMessage');
        notifyListeners();
        return false;
      }
    } catch (error) {
      print('AuthProvider: Exception khi đăng nhập Google - ${error.toString()}');
      _isLoading = false;
      _errorMessage = 'Lỗi không xác định: ${error.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _token = null;
    _user = null;
    notifyListeners();
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _authService.register(name, email, password);
      
      _isLoading = false;
      
      if (result['success'] == true) {
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Đăng ký thất bại';
        notifyListeners();
        return false;
      }
    } catch (error) {
      _isLoading = false;
      _errorMessage = 'Lỗi không xác định: ${error.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      // Giả lập API call - bạn cần thêm API này vào AuthService
      await Future.delayed(const Duration(seconds: 2));
      
      _isLoading = false;
      notifyListeners();
      
      // Giả sử thành công - trong thực tế, hãy gọi API thực
      return true;
    } catch (error) {
      _isLoading = false;
      _errorMessage = 'Lỗi không xác định: ${error.toString()}';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
} 