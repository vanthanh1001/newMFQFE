import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../goal/goal_screen.dart';
import '../challenge/challenges_screen.dart';
import '../../providers/goal_challenge_provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class GoalChallengeScreen extends HookConsumerWidget {
  const GoalChallengeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Màu sắc của tab được chọn
    final selectedColor = Theme.of(context).primaryColor;
    
    // Check trạng thái token
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkTokenStatus(context, ref);
      });
      return null;
    }, []);
    
    // Xử lý session hết hạn
    final goalProvider = ref.watch(combinedGoalChallengeProvider);
    useEffect(() {
      if (goalProvider.sessionExpired) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleSessionExpired(context, ref);
        });
      }
      return null;
    }, [goalProvider.sessionExpired]);
    
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mục tiêu & Thử thách'),
          bottom: TabBar(
            indicatorColor: selectedColor,
            labelColor: selectedColor,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(
                icon: Icon(Icons.flag),
                text: 'Mục tiêu',
              ),
              Tab(
                icon: Icon(Icons.emoji_events),
                text: 'Thử thách',
              ),
            ],
          ),
          actions: [
            // Nút refresh
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _refreshData(ref),
              tooltip: 'Làm mới dữ liệu',
            ),
          ],
        ),
        body: const TabBarView(
          children: [
            // Tab mục tiêu
            GoalScreen(),
            
            // Tab thử thách
            ChallengesScreen(),
          ],
        ),
      ),
    );
  }
  
  // Kiểm tra trạng thái token
  Future<void> _checkTokenStatus(BuildContext context, WidgetRef ref) async {
    final authProvider = ref.read(authNotifierProvider.notifier);
    final isLoggedIn = await authProvider.autoLogin();
    
    if (!isLoggedIn && context.mounted) {
      // Nếu không đăng nhập thì chuyển đến màn hình đăng nhập
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }
  
  // Xử lý phiên đăng nhập hết hạn
  void _handleSessionExpired(BuildContext context, WidgetRef ref) {
    // Đăng xuất người dùng
    ref.read(authNotifierProvider.notifier).logout();
    
    // Reset trạng thái phiên hết hạn
    ref.read(combinedGoalChallengeProvider.notifier).resetSessionState();
    
    // Chuyển đến màn hình đăng nhập
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }
  
  // Làm mới dữ liệu
  void _refreshData(WidgetRef ref) {
    ref.read(combinedGoalChallengeProvider.notifier).fetchAllData();
  }
} 