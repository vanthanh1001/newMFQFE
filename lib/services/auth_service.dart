import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../utils/constants.dart';
import '../models/user.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String baseUrl = AppConstants.apiBaseUrl;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // Kiểm tra token hiện tại có còn hợp lệ không
  Future<bool> isTokenValid() async {
    try {
      final token = await _storage.read(key: 'token');
      
      if (token == null) {
        print('Token không tồn tại');
        return false;
      }
      
      print('Kiểm tra token: $token');
      
      // Kiểm tra token bằng cách gọi API lấy thông tin profile
      final response = await http.get(
        Uri.parse('$baseUrl/User/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));
      
      print('Kiểm tra token - Status code: ${response.statusCode}');
      if (response.statusCode != 200) {
        print('Nội dung phản hồi: ${response.body}');
      }
      
      // Nếu status code là 200, token vẫn hợp lệ
      return response.statusCode == 200;
    } catch (e) {
      print('Lỗi khi kiểm tra token: $e');
      return false;
    }
  }

  // Đăng nhập và lấy token
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final loginUrl = '$baseUrl/Auth/login';
      debugPrint('CALLING API: $loginUrl');
      
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      debugPrint('LOGIN RESPONSE STATUS: ${response.statusCode}');
      debugPrint('LOGIN RESPONSE BODY: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        
        // Lưu token vào storage nếu đăng nhập thành công
        if (responseData['success'] == true && responseData['data'] != null) {
          final token = responseData['data']['token'];
          final userData = responseData['data']['user'];
          
          debugPrint('SAVING TOKEN: $token');
          await _storage.write(key: 'token', value: token);
          await _storage.write(key: 'userData', value: jsonEncode(userData));
          
          // Kiểm tra token đã lưu
          final savedToken = await _storage.read(key: 'token');
          debugPrint('SAVED TOKEN: $savedToken');
        }
        
        return responseData;
      } else {
        // Trả về một map với status false và thông báo lỗi
        return {
          'success': false,
          'message': 'Lỗi ${response.statusCode}: ${response.reasonPhrase ?? "Không xác định"}',
        };
      }
    } catch (error) {
      debugPrint('LOGIN ERROR: $error');
      return {
        'success': false,
        'message': 'Không thể kết nối đến máy chủ: $error',
      };
    }
  }

  // Đăng nhập với Google
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      print('Bắt đầu đăng nhập với Google...');
      
      // Bước 1: Gọi Google Sign-in UI
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('Người dùng đã hủy đăng nhập Google');
        return {
          'success': false,
          'message': 'Đăng nhập Google đã bị hủy',
        };
      }
      
      print('Đã đăng nhập Google thành công: ${googleUser.email}');
      
      // Bước 2: Lấy thông tin authentication
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      
      if (idToken == null) {
        print('Không thể lấy idToken từ Google');
        return {
          'success': false,
          'message': 'Không thể xác thực với Google',
        };
      }
      
      try {
        // Bước 3: Gửi token lên server để xác thực và lấy token ứng dụng
        final loginEndpoint = '$baseUrl/Auth/google';
        print('Gọi API Google Login: $loginEndpoint');
        
        final response = await http.post(
          Uri.parse(loginEndpoint),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'idToken': idToken,
          }),
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw TimeoutException('Thời gian kết nối quá lâu. Vui lòng thử lại sau.');
          },
        );
        
        print('Phản hồi từ server: ${response.statusCode}');
        print('Body: ${response.body}');
        
        // Xử lý phản hồi
        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          
          if (responseData['success'] == true) {
            // Xử lý đăng nhập thành công
            final token = responseData['data']['token'];
            final userData = responseData['data']['user'];
            
            // Lưu token và thông tin user
            await _storage.write(key: 'token', value: token);
            await _storage.write(key: 'userData', value: jsonEncode(userData));
            
            // Kiểm tra token đã lưu
            final savedToken = await _storage.read(key: 'token');
            print('Token đã lưu: $savedToken');
            
            return {
              'success': true,
              'token': token,
              'user': User.fromJson(userData),
            };
          } else {
            throw Exception(responseData['message'] ?? 'Đăng nhập thất bại');
          }
        } else {
          throw Exception('Lỗi kết nối đến server: ${response.statusCode}');
        }
      } catch (e) {
        print('Lỗi khi kết nối API: $e');
        print('Sử dụng chế độ fallback với thông tin Google...');
        
        // Fallback: Tạo User tạm từ Google để hiển thị
        final tempUser = {
          'id': googleUser.id,
          'email': googleUser.email,
          'name': googleUser.displayName ?? googleUser.email.split('@')[0],
          'displayName': googleUser.displayName,
          'photoUrl': googleUser.photoUrl,
          'provider': 'google',
        };
        
        // Lưu thông tin user tạm (không có token thực)
        final tempToken = 'google_temp_token_${googleUser.id}';
        await _storage.write(key: 'token', value: tempToken);
        await _storage.write(key: 'userData', value: jsonEncode(tempUser));
        
        return {
          'success': true,
          'token': tempToken,
          'user': User.fromJson(tempUser),
          'message': 'Đăng nhập Google thành công (chế độ offline)',
        };
      }
    } catch (e) {
      print('Lỗi đăng nhập Google: $e');
      return {
        'success': false,
        'message': 'Lỗi khi đăng nhập với Google: ${e.toString()}',
      };
    }
  }

  // Đăng ký tài khoản mới
  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'displayName': name,
          'email': email,
          'password': password,
        }),
      );
      
      final responseData = jsonDecode(response.body);
      
      if (response.statusCode != 200 || responseData['success'] != true) {
        String errorMessage = responseData['message'] ?? 'Đăng ký thất bại';
        return {
          'success': false,
          'message': errorMessage,
        };
      }
      
      return {
        'success': true,
        'message': 'Đăng ký thành công',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Đã xảy ra lỗi: ${e.toString()}',
      };
    }
  }

  // Lấy token từ storage
  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  // Xóa token khi đăng xuất
  Future<void> logout() async {
    // Kiểm tra nếu đăng nhập bằng Google thì đăng xuất khỏi Google
    final userData = await _storage.read(key: 'userData');
    if (userData != null) {
      final user = User.fromJson(jsonDecode(userData));
      if (user.provider == 'google') {
        await _googleSignIn.signOut();
      }
    }
    
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'userData');
    print('Đã đăng xuất và xóa token');
  }

  // Kiểm tra đã đăng nhập chưa
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'token');
    return token != null;
  }

  /// Lấy thông tin người dùng từ API
  Future<User?> getUserData() async {
    try {
      final token = await _storage.read(key: 'token');
      if (token == null) {
        debugPrint('getUserData: Không tìm thấy token');
        return null;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/User/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('getUserData: Status code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        debugPrint('getUserData: Dữ liệu người dùng: $userData');
        return User.fromJson(userData);
      } else if (response.statusCode == 401) {
        debugPrint('getUserData: Token hết hạn hoặc không hợp lệ');
        return null;
      } else {
        debugPrint('getUserData: Lỗi ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('getUserData: Exception $e');
      return null;
    }
  }
} 