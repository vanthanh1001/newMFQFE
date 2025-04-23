import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../models/goal/goal_model.dart';
import '../../providers/goal_provider.dart';
import '../../utils/constants.dart';
import 'goal_detail_screen.dart';
import 'add_goal_screen.dart';
import '../auth/login_screen.dart';

class GoalScreen extends HookConsumerWidget {
  const GoalScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalState = ref.watch(goalProvider);
    final goalNotifier = ref.read(goalProvider.notifier);
    
    // Tab controller với state hook
    final tabController = useTabController(initialLength: 4);
    
    // Hook để load dữ liệu khi màn hình được tạo
    useEffect(() {
      Future.microtask(() => goalNotifier.fetchGoals());
      return null;
    }, const []);
    
    // Xử lý session expired
    useEffect(() {
      if (goalState.sessionExpired) {
        Future.microtask(() => _handleSessionExpired(context, ref));
      }
      return null;
    }, [goalState.sessionExpired]);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mục tiêu'),
        bottom: TabBar(
          controller: tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'Đang thực hiện'),
            Tab(text: 'Sắp tới'),
            Tab(text: 'Đã hoàn thành'),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          _buildAllGoalsTab(goalState),
          _buildActiveGoalsTab(goalState, goalNotifier),
          _buildUpcomingGoalsTab(goalState, goalNotifier),
          _buildCompletedGoalsTab(goalState, goalNotifier),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddGoal(context),
        child: const Icon(Icons.add),
        tooltip: 'Thêm mục tiêu mới',
      ),
    );
  }
  
  // Tab hiển thị tất cả mục tiêu
  Widget _buildAllGoalsTab(GoalState goalState) {
    if (goalState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (goalState.errorMessage != null) {
      return Center(
        child: SelectableText.rich(
          TextSpan(
            text: goalState.errorMessage,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }
    
    if (goalState.goals.isEmpty) {
      return const Center(
        child: Text(
          'Chưa có mục tiêu nào.\nHãy tạo mục tiêu đầu tiên của bạn!',
          textAlign: TextAlign.center,
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 300));
        return ref.read(goalProvider.notifier).fetchGoals();
      },
      child: ListView.builder(
        itemCount: goalState.goals.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          return _buildGoalCard(context, goalState.goals[index]);
        },
      ),
    );
  }
  
  // Tab hiển thị mục tiêu đang hoạt động
  Widget _buildActiveGoalsTab(GoalState goalState, GoalNotifier goalNotifier) {
    if (goalState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    final activeGoals = goalNotifier.getActiveGoals();
    
    if (activeGoals.isEmpty) {
      return const Center(
        child: Text(
          'Không có mục tiêu đang thực hiện.\nHãy tạo mục tiêu mới!',
          textAlign: TextAlign.center,
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 300));
        return goalNotifier.fetchGoals();
      },
      child: ListView.builder(
        itemCount: activeGoals.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          return _buildGoalCard(context, activeGoals[index]);
        },
      ),
    );
  }
  
  // Tab hiển thị mục tiêu sắp tới
  Widget _buildUpcomingGoalsTab(GoalState goalState, GoalNotifier goalNotifier) {
    if (goalState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    final upcomingGoals = goalNotifier.getUpcomingGoals();
    
    if (upcomingGoals.isEmpty) {
      return const Center(
        child: Text(
          'Không có mục tiêu sắp tới.\nHãy lên kế hoạch cho tương lai!',
          textAlign: TextAlign.center,
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 300));
        return goalNotifier.fetchGoals();
      },
      child: ListView.builder(
        itemCount: upcomingGoals.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          return _buildGoalCard(context, upcomingGoals[index]);
        },
      ),
    );
  }
  
  // Tab hiển thị mục tiêu đã hoàn thành
  Widget _buildCompletedGoalsTab(GoalState goalState, GoalNotifier goalNotifier) {
    if (goalState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    final completedGoals = goalNotifier.getCompletedGoals();
    
    if (completedGoals.isEmpty) {
      return const Center(
        child: Text(
          'Chưa có mục tiêu nào hoàn thành.\nHãy cố gắng hoàn thành các mục tiêu của bạn!',
          textAlign: TextAlign.center,
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 300));
        return goalNotifier.fetchGoals();
      },
      child: ListView.builder(
        itemCount: completedGoals.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          return _buildGoalCard(context, completedGoals[index]);
        },
      ),
    );
  }
  
  // Widget hiển thị thẻ goal
  Widget _buildGoalCard(BuildContext context, GoalModel goal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => _navigateToGoalDetail(context, goal.id),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header với icon và trạng thái
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Color(goal.statusColor).withOpacity(0.1),
                border: Border(
                  left: BorderSide(
                    color: Color(goal.statusColor),
                    width: 4,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      goal.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(goal.statusColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      goal.statusText,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Nội dung mục tiêu
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mô tả mục tiêu
                  Text(
                    goal.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Thông tin thời gian
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${goal.formattedStartDate} - ${goal.formattedEndDate}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        goal.remainingTimeText,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Color(goal.statusColor),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Tiến độ
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tiến độ',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            '${goal.progressPercent}%',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: goal.progressPercentage,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(goal.statusColor),
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Nút xóa
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildDeleteButton(context, goal),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Nút xóa mục tiêu
  Widget _buildDeleteButton(BuildContext context, GoalModel goal) {
    return Consumer(
      builder: (context, ref, _) {
        return IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          tooltip: 'Xóa mục tiêu',
          onPressed: () => _showDeleteConfirmationDialog(context, ref, goal),
        );
      },
    );
  }
  
  // Hiển thị dialog xác nhận xóa
  void _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref, GoalModel goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa mục tiêu "${goal.name}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteGoal(context, ref, goal.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
  
  // Thực hiện xóa mục tiêu
  Future<void> _deleteGoal(BuildContext context, WidgetRef ref, int goalId) async {
    final goalNotifier = ref.read(goalProvider.notifier);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    final result = await goalNotifier.deleteGoal(goalId);
    
    if (result) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Đã xóa mục tiêu thành công'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(ref.read(goalProvider).errorMessage ?? 'Không thể xóa mục tiêu'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // Chuyển hướng đến màn hình chi tiết
  void _navigateToGoalDetail(BuildContext context, int goalId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GoalDetailScreen(goalId: goalId),
      ),
    );
  }
  
  // Chuyển hướng đến màn hình thêm mục tiêu
  void _navigateToAddGoal(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddGoalScreen(),
      ),
    );
  }
  
  // Xử lý khi phiên đăng nhập hết hạn
  Future<void> _handleSessionExpired(BuildContext context, WidgetRef ref) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    scaffoldMessenger.showSnackBar(
      const SnackBar(
        content: Text('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 3),
      ),
    );
    
    // Đợi hiển thị snackbar xong mới chuyển sang màn hình đăng nhập
    await Future.delayed(const Duration(seconds: 3));
    
    ref.read(goalProvider.notifier).resetSessionState();
    
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }
} 