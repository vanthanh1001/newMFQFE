import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/login_screen.dart';
import '../../providers/auth_provider.dart';
import '../../providers/exercise_provider.dart';
import '../../utils/constants.dart';
import '../exercise/exercise_list_screen.dart';
import '../exercise/exercise_detail_screen.dart';

// Tạm comment import này và làm placeholder
// import '../exercise/exercise_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      _isInit = true;
      // Tải dữ liệu bài tập khi vào app
      _loadExercises();
    }
    super.didChangeDependencies();
  }

  Future<void> _loadExercises() async {
    try {
      await Provider.of<ExerciseProvider>(context, listen: false).fetchExercises();
    } catch (error) {
      // Xử lý lỗi nếu cần
    }
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
      _buildProfileScreen(),
    ];

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
            icon: Icon(Icons.person),
            label: 'Hồ sơ',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textLight,
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
                color: AppColors.primary,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Cài đặt'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to settings screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Đăng xuất'),
              onTap: () async {
                Navigator.pop(context);
                await authProvider.logout();
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeScreen() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header với lời chào
              const SizedBox(height: 8),
              _buildWelcomeHeader(),
              const SizedBox(height: 24),
              
              // Thống kê tập luyện
              _buildWorkoutStats(),
              const SizedBox(height: 24),
              
              // Bài tập nổi bật
              _buildFeaturedExercises(),
              const SizedBox(height: 24),
              
              // Mục tiêu tập luyện
              _buildWorkoutGoals(),
              const SizedBox(height: 24),
              
              // Tips và tin tức
              _buildTipsAndNews(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    final user = Provider.of<AuthProvider>(context).user;
    final greeting = _getGreeting();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting,',
          style: AppTextStyles.body.copyWith(
            color: AppColors.textLight,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user?.name ?? 'User',
          style: AppTextStyles.heading1,
        ),
        const SizedBox(height: 8),
        const Text(
          'Hãy tiếp tục phát triển bản thân với MFQuest!',
          style: AppTextStyles.body,
        ),
      ],
    );
  }

  Widget _buildWorkoutStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Thống kê tập luyện',
              style: AppTextStyles.heading2,
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to detailed stats
              },
              child: const Text('Xem thêm'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Buổi tập',
                value: '12',
                icon: Icons.fitness_center,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'Bài tập',
                value: '36',
                icon: Icons.sports_gymnastics,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'Phút',
                value: '345',
                icon: Icons.timer,
                color: AppColors.accent,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.heading2.copyWith(
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

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
            Text(
              'Bài tập nổi bật',
              style: AppTextStyles.heading2,
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedIndex = 1; // Chuyển đến tab Bài tập
                });
              },
              child: const Text('Xem tất cả'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (exerciseProvider.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (exercises.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: Column(
                children: [
                  Icon(
                    Icons.fitness_center,
                    size: 48,
                    color: AppColors.textLight.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Chưa có bài tập nào',
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 1; // Chuyển đến tab Bài tập
                      });
                    },
                    child: const Text('Khám phá bài tập'),
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: featuredExercises.length,
              itemBuilder: (ctx, index) {
                final exercise = featuredExercises[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => ExerciseDetailScreen(exerciseId: exercise.id),
                      ),
                    );
                  },
                  child: Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Biểu tượng nhóm cơ
                        Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: _getIconForMuscleGroup(exercise.muscleGroup),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exercise.name,
                                style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${exercise.sets} Set • ${exercise.reps} Rep',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildWorkoutGoals() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mục tiêu của bạn',
          style: AppTextStyles.heading2,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.directions_run,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tập luyện 5 ngày/tuần',
                      style: AppTextStyles.heading3,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bạn đã hoàn thành 3/5 ngày tuần này',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: 0.6,
                      backgroundColor: AppColors.surface,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTipsAndNews() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mẹo & tin tức',
          style: AppTextStyles.heading2,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(
                    Icons.lightbulb_outline,
                    color: AppColors.accent,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '5 mẹo tăng hiệu quả tập luyện',
                      style: AppTextStyles.heading3,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tìm hiểu các phương pháp giúp tăng hiệu quả tập luyện và đạt kết quả tốt hơn.',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textLight,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutPlanScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.calendar_today,
            size: 100,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          const Text(
            'Lịch tập luyện',
            style: AppTextStyles.heading1,
          ),
          const SizedBox(height: 8),
          const Text(
            'Tính năng đang được phát triển',
            style: TextStyle(color: AppColors.textLight),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tính năng lịch tập đang được phát triển'),
                ),
              );
            },
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileScreen() {
    final user = Provider.of<AuthProvider>(context).user;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 32),
          CircleAvatar(
            radius: 60,
            backgroundImage: user?.profilePicture != null 
                ? NetworkImage(user!.profilePicture!) 
                : null,
            child: user?.profilePicture == null 
                ? const Icon(Icons.person, size: 60) 
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            user?.name ?? 'User',
            style: AppTextStyles.heading1,
            textAlign: TextAlign.center,
          ),
          Text(
            user?.email ?? 'email@example.com',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 32),
          
          // Thông tin cá nhân
          _buildProfileInfoCard(),
          const SizedBox(height: 24),
          
          // Các tùy chọn khác
          _buildProfileOptions(),
        ],
      ),
    );
  }

  Widget _buildProfileInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildProfileInfoItem(
            icon: Icons.person,
            title: 'Họ tên',
            value: 'Nguyễn Văn A',
          ),
          const Divider(),
          _buildProfileInfoItem(
            icon: Icons.calendar_today,
            title: 'Ngày sinh',
            value: '01/01/1990',
          ),
          const Divider(),
          _buildProfileInfoItem(
            icon: Icons.height,
            title: 'Chiều cao',
            value: '170 cm',
          ),
          const Divider(),
          _buildProfileInfoItem(
            icon: Icons.monitor_weight,
            title: 'Cân nặng',
            value: '65 kg',
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.caption,
              ),
              Text(
                value,
                style: AppTextStyles.body,
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(
              Icons.edit,
              color: AppColors.secondary,
              size: 18,
            ),
            onPressed: () {
              // TODO: Implement edit profile
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOptions() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildProfileOptionItem(
            icon: Icons.settings,
            title: 'Cài đặt tài khoản',
            onTap: () {
              // TODO: Implement settings
            },
          ),
          const Divider(height: 1),
          _buildProfileOptionItem(
            icon: Icons.language,
            title: 'Ngôn ngữ',
            onTap: () {
              // TODO: Implement language settings
            },
          ),
          const Divider(height: 1),
          _buildProfileOptionItem(
            icon: Icons.help_outline,
            title: 'Trợ giúp & Hỗ trợ',
            onTap: () {
              // TODO: Implement help
            },
          ),
          const Divider(height: 1),
          _buildProfileOptionItem(
            icon: Icons.info_outline,
            title: 'Về ứng dụng',
            onTap: () {
              // TODO: Implement about
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOptionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: AppTextStyles.body,
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textLight,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _getIconForMuscleGroup(String muscleGroup) {
    IconData iconData;
    switch (muscleGroup) {
      case 'Ngực':
        iconData = Icons.fitness_center;
        break;
      case 'Lưng':
        iconData = Icons.accessibility_new;
        break;
      case 'Vai':
        iconData = Icons.accessibility;
        break;
      case 'Tay':
        iconData = Icons.sports_gymnastics;
        break;
      case 'Chân':
        iconData = Icons.directions_run;
        break;
      case 'Bụng':
        iconData = Icons.sports_martial_arts;
        break;
      default:
        iconData = Icons.fitness_center;
        break;
    }
    
    return Icon(
      iconData,
      size: 48,
      color: AppColors.primary,
    );
  }

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
} 