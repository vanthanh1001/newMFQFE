import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../components/custom_text_field.dart';
import '../../components/primary_button.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';
import '../register/register_screen.dart';
import '../../utils/colors.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final isLoading = useState(false);
    final errorMessage = useState('');
    final authProvider = ref.watch(authProvider);

    void login() async {
      if (emailController.text.isEmpty || passwordController.text.isEmpty) {
        errorMessage.value = 'Vui lòng nhập email và mật khẩu';
        return;
      }

      errorMessage.value = '';
      isLoading.value = true;

      try {
        final result = await ref.read(authProvider).login(
          emailController.text.trim(),
          passwordController.text,
        );

        isLoading.value = false;

        if (result) {
          print('Đăng nhập thành công - Chuyển hướng đến HomeScreen');
          // Nếu đăng nhập thành công, chuyển hướng đến màn hình chính
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          // Lấy thông báo lỗi từ provider
          errorMessage.value = authProvider.errorMessage;
          print('Đăng nhập thất bại: ${errorMessage.value}');
        }
      } catch (e) {
        isLoading.value = false;
        errorMessage.value = 'Đã xảy ra lỗi: $e';
        print('Lỗi đăng nhập: $e');
      }
    }

    void loginWithGoogle() async {
      try {
        errorMessage.value = '';
        isLoading.value = true;
        
        final result = await ref.read(authProvider).googleSignIn();
        
        isLoading.value = false;
        
        if (result) {
          print('Đăng nhập Google thành công - Chuyển hướng đến HomeScreen');
          // Nếu đăng nhập thành công, chuyển hướng đến màn hình chính
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          // Lấy thông báo lỗi từ provider
          errorMessage.value = authProvider.errorMessage;
          print('Đăng nhập Google thất bại: ${errorMessage.value}');
        }
      } catch (e) {
        isLoading.value = false;
        errorMessage.value = 'Đã xảy ra lỗi: $e';
        print('Lỗi đăng nhập Google: $e');
      }
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              // Logo và tiêu đề
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 120,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Đăng nhập',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Trường nhập email
              CustomTextField(
                controller: emailController,
                hintText: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Trường nhập mật khẩu
              CustomTextField(
                controller: passwordController,
                hintText: 'Mật khẩu',
                icon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 8),

              // Quên mật khẩu
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // TODO: Navigate to forgot password screen
                  },
                  child: const Text(
                    'Quên mật khẩu?',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Hiển thị lỗi nếu có
              if (errorMessage.value.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    errorMessage.value,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Nút đăng nhập
              PrimaryButton(
                text: 'ĐĂNG NHẬP',
                isLoading: isLoading.value,
                onPressed: login,
              ),
              const SizedBox(height: 20),

              // Đăng nhập với Google
              OutlinedButton.icon(
                onPressed: loginWithGoogle,
                icon: Image.asset(
                  'assets/images/google_logo.png',
                  height: 24,
                ),
                label: const Text(
                  'Đăng nhập với Google',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Chuyển đến đăng ký
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Chưa có tài khoản? ',
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Đăng ký ngay',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 