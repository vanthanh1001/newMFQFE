import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/login_screen.dart';
import '../../providers/auth_provider.dart';
import '../../providers/exercise_provider.dart';
import '../../providers/challenge_provider.dart';
import '../../utils/constants.dart';
import '../exercise/exercise_list_screen.dart';
import '../exercise/exercise_detail_screen.dart';
import '../challenge/challenges_screen.dart';
import '../../models/challenge/challenge_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = 0;
    
    // Dùng Future.microtask để đảm bảo context đã sẵn sàng
    Future.microtask(() {
      _loadInitialData();
    });
  }

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      _isInit = true;
      _loadInitialData();
    }
    super.didChangeDependencies();
  }

  Future<void> _loadInitialData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      
      try {
        // Kiểm tra token có hợp lệ không
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        bool isValid = await authProvider.isTokenValid();
        
        if (!isValid) {
          _handleSessionExpired();
          return;
        }
        
        // Tải dữ liệu bài tập
        final exerciseProvider = Provider.of<ExerciseProvider>(context, listen: false);
        await exerciseProvider.fetchExercises();
        
        // Tải thử thách
        final challengeProvider = Provider.of<ChallengeProvider>(context, listen: false);
        await challengeProvider.fetchActiveChallenges();
      } catch (e) {
        debugPrint('Lỗi khi tải dữ liệu ban đầu: $e');
        if (e.toString().contains('401') || 
            e.toString().contains('unauthorized') ||
            e.toString().contains('hết hạn')) {
          _handleSessionExpired();
        }
      }
    });
  }
  
  // Tách các phương thức tải dữ liệu riêng biệt
  Future<void> _loadExercises() async {
    if (!mounted) return;
    try {
      final exerciseProvider = Provider.of<ExerciseProvider>(context, listen: false);
      await exerciseProvider.fetchExercises();
    } catch (e) {
      debugPrint('Lỗi khi tải bài tập: $e');
    }
  }
  
  Future<void> _loadChallenges() async {
    if (!mounted) return;
    try {
      final challengeProvider = Provider.of<ChallengeProvider>(context, listen: false);
      await challengeProvider.fetchActiveChallenges();
    } catch (e) {
      debugPrint('Lỗi khi tải thử thách: $e');
      // Kiểm tra nếu session đã hết hạn
      if (e.toString().contains('401') || 
          e.toString().contains('unauthorized') ||
          e.toString().contains('hết hạn')) {
        final challengeProvider = Provider.of<ChallengeProvider>(context, listen: false);
        if (challengeProvider.sessionExpired) {
          _handleSessionExpired();
        }
      }
    }
  }
  
  void _handleSessionExpired() {
    // Sử dụng Future.microtask để tránh gọi setState trong build
    Future.microtask(() async {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final challengeProvider = Provider.of<ChallengeProvider>(context, listen: false);
        
        // Đăng xuất người dùng
        await authProvider.logout();
        
        // Reset trạng thái phiên
        if (challengeProvider.sessionExpired) {
          challengeProvider.resetSessionState();
        }
        
        // Chuyển hướng đến màn hình đăng nhập với hướng dẫn
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
          
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        debugPrint('Lỗi khi xử lý phiên hết hạn: $e');
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    // Danh sách các màn hình
    final List<Widget> _screens = [
      _buildHomeScreen(),
      const ExerciseListScreen(),
      _buildWorkoutPlanScreen(),
      const ChallengesScreen(),
      _buildProfileScreen(),
    ];

    // Kiểm tra trạng thái phiên
    final challengeProvider = Provider.of<ChallengeProvider>(context);
    if (challengeProvider.sessionExpired) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleSessionExpired();
      });
    }

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Bài tập',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note_alt),
            label: 'Lịch tập',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Thử thách',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Hồ sơ',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user?.name ?? 'User'),
              accountEmail: Text(user?.email ?? 'email@example.com'),
              currentAccountPicture: CircleAvatar(
                backgroundImage: user?.profilePicture != null
                    ? NetworkImage(user!.profilePicture!)
                    : null,
                child: user?.profilePicture == null
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Cài đặt'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement settings screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Đăng xuất'),
              onTap: () => _handleLogout(),
            ),
          ],
        ),
      ),
    );
  }

  // Home Screen
  Widget _buildHomeScreen() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(),
            const SizedBox(height: 24),
            
            _buildWorkoutStats(),
            const SizedBox(height: 24),
            
            _buildFeaturedExercises(),
            const SizedBox(height: 24),
            
            _buildActiveChallenges(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Welcome Header
  Widget _buildWelcomeHeader() {
    final user = Provider.of<AuthProvider>(context).user;
    final greeting = _getGreeting();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting,',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        Text(
          user?.name ?? 'Người dùng',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Workout Stats
  Widget _buildWorkoutStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thống kê tuần này',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem(
                icon: Icons.fitness_center,
                title: 'Buổi tập',
                value: '5',
              ),
              _buildStatItem(
                icon: Icons.local_fire_department,
                title: 'Calories',
                value: '1200',
              ),
              _buildStatItem(
                icon: Icons.timelapse,
                title: 'Thời gian',
                value: '4h 20m',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Stat Item
  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.blue,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // Featured Exercises
  Widget _buildFeaturedExercises() {
    final exerciseProvider = Provider.of<ExerciseProvider>(context);
    final exercises = exerciseProvider.exercises;
    final featuredExercises = exercises.length > 5 
        ? exercises.sublist(0, 5) 
        : exercises;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Bài tập phổ biến',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedIndex = 1; // Switch to Exercises tab
                });
              },
              child: const Text('Xem tất cả'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        exerciseProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : featuredExercises.isEmpty
                ? const Center(
                    child: Text('Không có bài tập nào'),
                  )
                : SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: featuredExercises.length,
                      itemBuilder: (context, index) {
                        final exercise = featuredExercises[index];
                        return _buildExerciseCard(exercise);
                      },
                    ),
                  ),
      ],
    );
  }

  // Exercise Card
  Widget _buildExerciseCard(dynamic exercise) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExerciseDetailScreen(exerciseId: exercise.id),
          ),
        );
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise Image or Icon
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.fitness_center,
                  size: 40,
                  color: Colors.blue,
                ),
              ),
            ),
            
            // Exercise Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name?.toString() ?? 'Bài tập',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    exercise.muscleGroup?.toString() ?? 'Chưa phân loại',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Active Challenges
  Widget _buildActiveChallenges() {
    return Consumer<ChallengeProvider>(
      builder: (context, provider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Thử thách đang diễn ra',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 3; // Chuyển đến tab Thử thách
                    });
                  },
                  child: const Text('Xem tất cả'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            if (provider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (provider.error != null)
              Center(
                child: Text(
                  'Lỗi: ${provider.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              )
            else if (provider.activeChallenges.isEmpty)
              const Center(
                child: Text('Không có thử thách nào đang diễn ra'),
              )
            else
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: provider.activeChallenges.length > 3 
                    ? 3 : provider.activeChallenges.length,
                  itemBuilder: (context, index) {
                    final challenge = provider.activeChallenges[index];
                    return _buildChallengeCard(challenge);
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  // Challenge Card
  Widget _buildChallengeCard(Challenge challenge) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Challenge image or banner
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.emoji_events,
                size: 40,
                color: Colors.blue,
              ),
            ),
          ),
          
          // Challenge info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  challenge.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Placeholder for workout plan screen
  Widget _buildWorkoutPlanScreen() {
    return const Center(
      child: Text('Màn hình lịch tập đang được phát triển'),
    );
  }

  // Placeholder for profile screen
  Widget _buildProfileScreen() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Thêm ảnh đại diện hoặc icon người dùng
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.blue,
            child: Icon(
              Icons.person,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Thông tin người dùng',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),
          // Nút đăng xuất
          ElevatedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('Đăng xuất'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 15,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: _handleLogout,
          ),
        ],
      ),
    );
  }

  // Get greeting based on time of day
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Chào buổi sáng';
    } else if (hour < 18) {
      return 'Chào buổi chiều';
    } else {
      return 'Chào buổi tối';
    }
  }

  // Handle logout
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _confirmLogout();
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final challengeProvider = Provider.of<ChallengeProvider>(context, listen: false);
    
    await authProvider.logout();
    challengeProvider.resetSessionState();
    
    if (!mounted) return;
    
    // Chuyển về màn hình đăng nhập
    Navigator.of(context).pushReplacementNamed(LoginScreen.routePath);
  }
} 
