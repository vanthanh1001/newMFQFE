import 'package:flutter/material.dart';
import 'package:mfquest_flutter/providers/auth_provider.dart';
import 'package:mfquest_flutter/screens/auth/login_screen.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ người dùng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutConfirmation(context),
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Màn hình hồ sơ'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _showLogoutConfirmation(context),
              child: const Text('Đăng xuất'),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => _handleLogout(context),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    // Đóng hộp thoại
    Navigator.pop(context);
    
    // Thực hiện đăng xuất
    Provider.of<AuthProvider>(context, listen: false).logout();
    
    // Chuyển về màn hình đăng nhập
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }
} 