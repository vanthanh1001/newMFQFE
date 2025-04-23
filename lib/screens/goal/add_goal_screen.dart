import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import '../../providers/goal_provider.dart';

class AddGoalScreen extends HookConsumerWidget {
  const AddGoalScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Form key để validate form
    final formKey = useMemoized(() => GlobalKey<FormState>());
    
    // State cho các trường nhập liệu
    final nameController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final categoryController = useTextEditingController();
    
    // State cho thời gian
    final startDate = useState<DateTime>(DateTime.now());
    final endDate = useState<DateTime>(DateTime.now().add(const Duration(days: 30)));
    
    // State loading
    final isLoading = useState(false);
    
    // Format ngày tháng
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm mục tiêu mới'),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Trường tên mục tiêu
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Tên mục tiêu',
                hintText: 'Nhập tên mục tiêu của bạn',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.flag),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập tên mục tiêu';
                }
                if (value.length < 3) {
                  return 'Tên mục tiêu phải có ít nhất 3 ký tự';
                }
                return null;
              },
              maxLength: 100,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
            ),
            
            const SizedBox(height: 16),
            
            // Trường mô tả
            TextFormField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Mô tả',
                hintText: 'Mô tả chi tiết về mục tiêu của bạn',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập mô tả mục tiêu';
                }
                if (value.length < 10) {
                  return 'Mô tả phải có ít nhất 10 ký tự';
                }
                return null;
              },
              maxLength: 500,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
            ),
            
            const SizedBox(height: 16),
            
            // Trường danh mục (tùy chọn)
            TextFormField(
              controller: categoryController,
              decoration: const InputDecoration(
                labelText: 'Danh mục (tùy chọn)',
                hintText: 'Ví dụ: Sức khỏe, Học tập, Công việc',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
            ),
            
            const SizedBox(height: 24),
            
            // Ngày bắt đầu
            _buildDatePicker(
              context: context,
              label: 'Ngày bắt đầu',
              value: startDate.value,
              formattedValue: dateFormat.format(startDate.value),
              icon: Icons.calendar_today,
              onPressed: () => _selectDate(
                context: context,
                initialDate: startDate.value,
                onSelected: (date) {
                  startDate.value = date;
                  // Nếu ngày kết thúc nhỏ hơn ngày bắt đầu, cập nhật ngày kết thúc
                  if (endDate.value.isBefore(date)) {
                    endDate.value = date.add(const Duration(days: 1));
                  }
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Ngày kết thúc
            _buildDatePicker(
              context: context,
              label: 'Ngày kết thúc',
              value: endDate.value,
              formattedValue: dateFormat.format(endDate.value),
              icon: Icons.event,
              onPressed: () => _selectDate(
                context: context,
                initialDate: endDate.value,
                // Ngày tối thiểu phải lớn hơn hoặc bằng ngày bắt đầu
                firstDate: startDate.value,
                onSelected: (date) {
                  endDate.value = date;
                },
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Nút tạo mục tiêu
            ElevatedButton(
              onPressed: isLoading.value
                ? null
                : () => _createGoal(
                    context: context,
                    ref: ref,
                    formKey: formKey,
                    nameController: nameController,
                    descriptionController: descriptionController,
                    categoryController: categoryController,
                    startDate: startDate.value,
                    endDate: endDate.value,
                    setLoading: (value) => isLoading.value = value,
                  ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isLoading.value
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'TẠO MỤC TIÊU',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Widget chọn ngày tháng
  Widget _buildDatePicker({
    required BuildContext context,
    required String label,
    required DateTime value,
    required String formattedValue,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 16),
                Text(
                  formattedValue,
                  style: const TextStyle(fontSize: 16),
                ),
                const Spacer(),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  // Hiển thị dialog chọn ngày
  Future<void> _selectDate({
    required BuildContext context,
    required DateTime initialDate,
    DateTime? firstDate,
    required Function(DateTime) onSelected,
  }) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate ?? DateTime.now(),
      lastDate: DateTime(2100),
    );
    
    if (pickedDate != null) {
      onSelected(pickedDate);
    }
  }
  
  // Xử lý tạo mục tiêu
  Future<void> _createGoal({
    required BuildContext context,
    required WidgetRef ref,
    required GlobalKey<FormState> formKey,
    required TextEditingController nameController,
    required TextEditingController descriptionController,
    required TextEditingController categoryController,
    required DateTime startDate,
    required DateTime endDate,
    required Function(bool) setLoading,
  }) async {
    // Validate form
    if (!formKey.currentState!.validate()) {
      return;
    }
    
    setLoading(true);
    
    try {
      // Gọi API tạo mục tiêu mới
      final result = await ref.read(goalProvider.notifier).createGoal(
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        startDate: startDate,
        endDate: endDate,
        category: categoryController.text.isNotEmpty ? categoryController.text.trim() : null,
      );
      
      setLoading(false);
      
      if (result != null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tạo mục tiêu thành công'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Quay lại màn hình trước
          Navigator.pop(context);
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                ref.read(goalProvider).errorMessage ?? 
                'Không thể tạo mục tiêu',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setLoading(false);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 