import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../utils/constants.dart';
import '../models/user.dart';

class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String baseUrl = AppConstants.apiBaseUrl;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // Đăng nhập và lấy token
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('Gọi API login với email: $email');
      final loginEndpoint = '$baseUrl/Auth/login';
      print('Endpoint: $loginEndpoint');
      
      // Cấu trúc request body theo Swagger API
      final requestBody = {
        'email': email,
        'password': password,
      };
      
      print('REQUEST BODY:');
      print(jsonEncode(requestBody));
      
      // Cấu hình HTTP client với timeout
      final client = http.Client();
      http.Response? response;
      
      try {
        // Sử dụng http.post trực tiếp với headers phù hợp
        print('Đang gửi request đến server...');
        response = await client.post(
          Uri.parse(loginEndpoint),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(requestBody),
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            print('REQUEST TIMEOUT: Không nhận được phản hồi sau 30 giây');
            throw TimeoutException('Thời gian kết nối quá lâu. Vui lòng thử lại sau.');
          },
        );
      } catch (e) {
        if (e is TimeoutException) {
          print('Timeout exception: $e');
          return {
            'success': false,
            'message': 'Kết nối đến server quá lâu. Vui lòng thử lại sau.',
          };
        }
        print('Lỗi kết nối: ${e.toString()}');
        return {
          'success': false,
          'message': 'Lỗi kết nối đến server: ${e.toString()}',
        };
      } finally {
        // Đảm bảo client được đóng
        client.close();
      }
      
      print('======= PHẢN HỒI TỪ SERVER =======');
      print('Status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');
      print('===================================');
      
      if (response.body.isEmpty) {
        print('Lỗi: Phản hồi trống từ server');
        return {
          'success': false,
          'message': 'Phản hồi trống từ server. Vui lòng thử lại sau.',
        };
      }
      
      // Trích xuất dữ liệu từ phản hồi
      final responseData = jsonDecode(response.body);
      print('Phân tích phản hồi: $responseData');
      
      // Kiểm tra status code và cấu trúc phản hồi
      if (response.statusCode == 200 && responseData['success'] == true) {
        // Xử lý đúng cấu trúc phản hồi từ Azure API
        final token = responseData['data']['token'];
        final userData = responseData['data']['user'];
        
        // Lưu token và dữ liệu người dùng
        await _storage.write(key: 'token', value: token);
        await _storage.write(key: 'userData', value: jsonEncode(userData));
        
        print('Đăng nhập thành công, đã lưu token và thông tin người dùng');
        
        return {
          'success': true,
          'token': token,
          'user': User.fromJson(userData),
        };
      } else {
        // Xử lý lỗi từ server
        String errorMessage = 'Đăng nhập thất bại';
        if (responseData.containsKey('message')) {
          errorMessage = responseData['message'];
        }
        
        print('Lỗi đăng nhập: $errorMessage');
        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      print('Lỗi không xác định khi đăng nhập: $e');
      print('Stack trace: ${e is Error ? e.stackTrace : "No stack trace"}');
      return {
        'success': false,
        'message': 'Đã xảy ra lỗi: ${e.toString()}',
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
  }

  // Kiểm tra đã đăng nhập chưa
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'token');
    return token != null;
  }

  // Lấy thông tin user đã lưu
  Future<User?> getUserData() async {
    final userData = await _storage.read(key: 'userData');
    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }
    return null;
  }
} 