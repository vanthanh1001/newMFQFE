import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../models/goal/goal_model.dart';
import '../../providers/goal_provider.dart';
import '../../utils/constants.dart';
import '../auth/login_screen.dart';

class GoalDetailScreen extends HookConsumerWidget {
  final int goalId;

  const GoalDetailScreen({Key? key, required this.goalId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalNotifier = ref.read(goalProvider.notifier);
    final goalState = ref.watch(goalProvider);
    
    // State local để lưu trữ thông tin chi tiết mục tiêu
    final goalDetails = useState<GoalModel?>(null);
    final isLoading = useState(true);
    final error = useState<String?>(null);
    
    // Lấy và cập nhật chi tiết mục tiêu
    final fetchGoalDetails = useCallback(() async {
      isLoading.value = true;
      error.value = null;
      
      try {
        final result = await goalNotifier.getGoalById(goalId);
        goalDetails.value = result;
        isLoading.value = false;
      } catch (e) {
        error.value = e.toString();
        isLoading.value = false;
      }
    }, [goalId]);
    
    // Hook để load dữ liệu khi màn hình được tạo
    useEffect(() {
      fetchGoalDetails();
      return null;
    }, [fetchGoalDetails]);
    
    // Xử lý session expired
    useEffect(() {
      if (goalState.sessionExpired) {
        Future.microtask(() => _handleSessionExpired(context, ref));
      }
      return null;
    }, [goalState.sessionExpired]);
    
    // Hiển thị trạng thái loading
    if (isLoading.value) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết mục tiêu')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    // Hiển thị lỗi
    if (error.value != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết mục tiêu')),
        body: Center(
          child: SelectableText.rich(
            TextSpan(
              text: 'Lỗi: ${error.value}',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      );
    }
    
    // Hiển thị khi không tìm thấy mục tiêu
    if (goalDetails.value == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết mục tiêu')),
        body: const Center(
          child: Text('Không tìm thấy thông tin mục tiêu'),
        ),
      );
    }
    
    final goal = goalDetails.value!;
    
    // Controller cho việc cập nhật tiến độ
    final progressController = useTextEditingController(
      text: (goal.progressPercentage * 100).toStringAsFixed(0),
    );
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết mục tiêu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Tải lại',
            onPressed: fetchGoalDetails,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await fetchGoalDetails();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header với tên và trạng thái
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(goal.statusColor).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(goal.statusColor), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            goal.name,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Color(goal.statusColor),
                            borderRadius: BorderRadius.circular(20),
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
                    const SizedBox(height: 8),
                    Text(
                      goal.remainingTimeText,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Color(goal.statusColor),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Thông tin mục tiêu
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thông tin mục tiêu',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Divider(),
                      const SizedBox(height: 8),
                      
                      // Mô tả
                      Text(
                        'Mô tả:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        goal.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      
                      // Thời gian
                      Text(
                        'Thời gian:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Bắt đầu: ${goal.formattedStartDate}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.event, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Kết thúc: ${goal.formattedEndDate}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      if (goal.category != null) ...[
                        const SizedBox(height: 16),
                        
                        // Danh mục
                        Text(
                          'Danh mục:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.category, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              goal.category!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Tiến độ mục tiêu
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tiến độ',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Divider(),
                      const SizedBox(height: 16),
                      
                      // Hiển thị tiến độ
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Hoàn thành:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '${goal.progressPercent}%',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Color(goal.statusColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: goal.progressPercentage,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(goal.statusColor),
                          ),
                          minHeight: 12,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Form cập nhật tiến độ
                      Text(
                        'Cập nhật tiến độ',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: progressController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Phần trăm hoàn thành',
                                hintText: 'Nhập giá trị từ 0-100',
                                suffixText: '%',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () => _updateProgress(
                              context, 
                              ref, 
                              goalId, 
                              progressController.text,
                              fetchGoalDetails,
                            ),
                            child: const Text('Cập nhật'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Cập nhật tiến độ mục tiêu
  Future<void> _updateProgress(
    BuildContext context, 
    WidgetRef ref, 
    int goalId, 
    String progressText,
    Function fetchGoalDetails,
  ) async {
    // Kiểm tra và chuyển đổi giá trị
    int progressValue;
    try {
      progressValue = int.parse(progressText);
      if (progressValue < 0) progressValue = 0;
      if (progressValue > 100) progressValue = 100;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập một giá trị số từ 0-100'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Chuyển đổi từ phần trăm sang tỷ lệ 0-1
    final progressPercentage = progressValue / 100;
    
    // Gọi API cập nhật tiến độ
    final result = await ref.read(goalProvider.notifier).updateGoalProgress(
      goalId, 
      progressPercentage,
    );
    
    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật tiến độ thành công'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Tải lại dữ liệu
      fetchGoalDetails();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ref.read(goalProvider).errorMessage ?? 
            'Không thể cập nhật tiến độ mục tiêu',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
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