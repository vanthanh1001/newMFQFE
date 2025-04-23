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
      notifyListeners();
      
      // Đọc token từ bộ nhớ an toàn
      final token = await _storage.read(key: 'token');
      
      if (token == null || token.isEmpty) {
        debugPrint('Không tìm thấy token, cần đăng nhập lại');
        _isLoading = false;
        _initialized = true;
        notifyListeners();
        return false;
      }
      
      // Kiểm tra token có còn hợp lệ
      final isValid = await _authService.isTokenValid();
      if (!isValid) {
        debugPrint('Token không hợp lệ hoặc đã hết hạn');
        // Xóa token không hợp lệ
        await _storage.delete(key: 'token');
        _token = null;
        _user = null;
        _isLoading = false;
        _initialized = true;
        notifyListeners();
        return false;
      }
      
      // Token hợp lệ
      _token = token;
      debugPrint('Token hợp lệ: $_token');
      
      // Lấy thông tin người dùng từ bộ nhớ an toàn
      try {
        final userDataString = await _storage.read(key: 'userData');
        if (userDataString != null) {
          final userData = jsonDecode(userDataString);
          _user = User.fromJson(userData);
          debugPrint('Đã load thông tin người dùng từ bộ nhớ');
        } else {
          // Nếu không có dữ liệu người dùng đã lưu, gọi API để lấy
          _user = await _authService.getUserData();
          debugPrint('Đã load thông tin người dùng từ API');
        }
      } catch (e) {
        debugPrint('Lỗi khi lấy thông tin người dùng: $e');
        // Vẫn coi là đăng nhập thành công nếu token hợp lệ
      }

      _isLoading = false;
      _initialized = true;
      notifyListeners();
      
      return true;
    } catch (error) {
      debugPrint('Lỗi trong tryAutoLogin: $error');
      _isLoading = false;
      _initialized = true;
      _token = null;
      _user = null;
      notifyListeners();
      
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _authService.login(email, password);
      
      if (response != null && response['success'] == true) {
        // Lấy token từ response
        final token = response['data']?['token'];
        
        if (token == null) {
          debugPrint('LỖI: Không tìm thấy token trong phản hồi');
          _errorMessage = 'Không thể lấy token từ phản hồi';
          _isLoading = false;
          notifyListeners();
          return false;
        }
        
        // Lưu token vào secure storage
        await _storage.write(key: 'token', value: token);
        _token = token;
        
        // Lấy thông tin người dùng từ response
        final userData = response['data']?['user'];
        if (userData != null) {
          try {
            _user = User.fromJson(userData);
            await _storage.write(key: 'userData', value: jsonEncode(_user!.toJson()));
            debugPrint('USER DATA ĐÃ LƯU: ${_user!.toJson()}');
          } catch (e) {
            debugPrint('LỖI KHI XỬ LÝ USER DATA: $e');
            // Vẫn tiếp tục vì đã có token
          }
        }
        
        // Debug logs
        debugPrint('ĐĂNG NHẬP THÀNH CÔNG: true');
        debugPrint('Token đã lưu: ${token.substring(0, min(20, token.length))}...');
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response != null 
            ? response['message'] ?? 'Đăng nhập thất bại' 
            : 'Không nhận được phản hồi từ máy chủ';
        debugPrint('ĐĂNG NHẬP THÀNH CÔNG: false - $_errorMessage');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('EXCEPTION TRONG LOGIN: $_errorMessage');
      _isLoading = false;
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
    try {
      await _storage.delete(key: 'token');
      await _storage.delete(key: 'refreshToken');
      await _storage.delete(key: 'userEmail');
      await _storage.delete(key: 'userName');
      await _storage.delete(key: 'userId');
      await _storage.delete(key: 'userProfilePicture');
      
      _user = null;
      _token = null;
      notifyListeners();
      
      print('Đã đăng xuất thành công');
    } catch (e) {
      print('Lỗi khi đăng xuất: $e');
      throw Exception('Đăng xuất thất bại');
    }
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

  Future<bool> isTokenValid() async {
    try {
      return await _authService.isTokenValid();
    } catch (e) {
      print('Lỗi kiểm tra token: $e');
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? value) {
    _errorMessage = value;
    notifyListeners();
  }

  Future<void> fetchUserProfile() async {
    try {
      debugPrint('fetchUserProfile: Đang lấy thông tin người dùng...');
      
      // Lấy token đã lưu
      final token = await _storage.read(key: 'token');
      if (token == null) {
        debugPrint('fetchUserProfile: Không tìm thấy token');
        return;
      }
      
      // Lưu token vào biến thành viên
      _token = token;
      
      // Lấy thông tin người dùng từ API
      final userData = await _authService.getUserData();
      if (userData != null) {
        _user = userData;
        await _storage.write(key: 'userData', value: jsonEncode(_user!.toJson()));
        debugPrint('fetchUserProfile: Đã lưu thông tin người dùng');
      } else {
        debugPrint('fetchUserProfile: Không thể lấy thông tin người dùng');
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('fetchUserProfile: Lỗi $e');
    }
  }

  /// Xác thực tự động
  Future<bool> autoLogin() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _storage.read(key: 'token');
      
      if (token == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      debugPrint('autoLogin: Tìm thấy token, kiểm tra hợp lệ');
      
      // Kiểm tra token có hợp lệ không bằng cách lấy thông tin người dùng
      final user = await _authService.getUserData();
      
      if (user == null) {
        debugPrint('autoLogin: Token không hợp lệ hoặc hết hạn');
        await _storage.delete(key: 'token');
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Lưu thông tin người dùng
      _user = user;
      _token = token;
      
      debugPrint('autoLogin: Đăng nhập tự động thành công');
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('autoLogin: Lỗi $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  int min(int a, int b) => a < b ? a : b;
} 