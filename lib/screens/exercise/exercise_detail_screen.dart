import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../providers/exercise_provider.dart';
import '../../utils/constants.dart';
import 'exercise_form_screen.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final int exerciseId;

  const ExerciseDetailScreen({
    super.key,
    required this.exerciseId,
  });

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  bool _isInit = false;
  bool _showDelete = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      _isInit = true;
      _loadExerciseDetail();
    }
    super.didChangeDependencies();
  }

  Future<void> _loadExerciseDetail() async {
    try {
      await Provider.of<ExerciseProvider>(context, listen: false)
          .fetchExerciseDetail(widget.exerciseId);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể tải chi tiết bài tập: $error'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );

    if (pickedFile == null) {
      return;
    }

    final imageFile = File(pickedFile.path);
    final provider = Provider.of<ExerciseProvider>(context, listen: false);
    
    try {
      final imageUrl = await provider.uploadExerciseImage(imageFile);
      if (imageUrl != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tải lên ảnh thành công'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh danh sách ảnh
        await provider.fetchExerciseImages(widget.exerciseId);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi tải lên ảnh: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa bài tập này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _deleteExercise();
            },
            child: const Text(
              'Xóa',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteExercise() async {
    try {
      final exercise = Provider.of<ExerciseProvider>(context, listen: false).selectedExercise;
      if (exercise == null) return;

      final success = await Provider.of<ExerciseProvider>(context, listen: false)
          .deleteExercise(exercise.id);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa bài tập thành công'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể xóa bài tập: $error'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ExerciseProvider>(
        builder: (ctx, exerciseProvider, _) {
          if (exerciseProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final exercise = exerciseProvider.selectedExercise;
          final images = exerciseProvider.exerciseImages;

          if (exercise == null) {
            if (exerciseProvider.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error.withOpacity(0.7),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Đã xảy ra lỗi:',
                      style: AppTextStyles.heading3,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        exerciseProvider.errorMessage!,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loadExerciseDetail,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Không tìm thấy bài tập'),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Quay lại'),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    exercise.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 3,
                          color: Color.fromARGB(130, 0, 0, 0),
                        ),
                      ],
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (images.isNotEmpty)
                        Image.network(
                          images.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.primary,
                              child: const Icon(
                                Icons.fitness_center,
                                color: Colors.white,
                                size: 64,
                              ),
                            );
                          },
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withOpacity(0.8),
                              ],
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.fitness_center,
                              color: Colors.white,
                              size: 64,
                            ),
                          ),
                        ),
                      // Gradient overlay để làm nổi bật tiêu đề
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: 80,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.7),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.of(context)
                          .push(
                            MaterialPageRoute(
                              builder: (ctx) => ExerciseFormScreen(exerciseId: exercise.id),
                            ),
                          )
                          .then((_) => _loadExerciseDetail());
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: _showDeleteConfirmDialog,
                  ),
                ],
              ),

              // Nội dung chi tiết
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thông tin người tạo
                      if (exercise.createdByUsername != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.person,
                                size: 16,
                                color: AppColors.textLight,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Tạo bởi: ${exercise.createdByUsername}',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 20),

                      // Thẻ thông số
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
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
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatCard(
                              title: 'Hiệp',
                              value: '${exercise.sets}',
                              icon: Icons.repeat,
                              color: AppColors.primary,
                            ),
                            _buildVerticalDivider(),
                            _buildStatCard(
                              title: 'Lần',
                              value: '${exercise.reps}',
                              icon: Icons.fitness_center,
                              color: AppColors.accent,
                            ),
                            _buildVerticalDivider(),
                            _buildStatCard(
                              title: 'Nghỉ',
                              value: '${exercise.restTime}s',
                              icon: Icons.timer,
                              color: AppColors.secondary,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Nhóm cơ
                      Row(
                        children: [
                          const Icon(
                            Icons.category,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Nhóm cơ:',
                            style: AppTextStyles.heading3,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          exercise.muscleGroup.isEmpty
                              ? 'Chưa phân loại'
                              : exercise.muscleGroup,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Mô tả bài tập
                      Row(
                        children: [
                          const Icon(
                            Icons.description,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Mô tả bài tập:',
                            style: AppTextStyles.heading3,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.divider,
                          ),
                        ),
                        child: Text(
                          exercise.description.isEmpty
                              ? 'Không có mô tả chi tiết.'
                              : exercise.description,
                          style: AppTextStyles.body,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Hình ảnh bài tập
                      Row(
                        children: [
                          const Icon(
                            Icons.image,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Hình ảnh:',
                            style: AppTextStyles.heading3,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (images.isEmpty)
                        Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.divider,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported,
                                size: 48,
                                color: AppColors.textLight.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Chưa có hình ảnh cho bài tập này',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.textLight,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: images.length,
                            itemBuilder: (ctx, index) {
                              return Container(
                                margin: const EdgeInsets.only(right: 12),
                                width: 280,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.divider,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    images[index],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: AppColors.surface,
                                        child: const Center(
                                          child: Icon(
                                            Icons.broken_image,
                                            size: 48,
                                            color: AppColors.textLight,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.heading2,
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: AppTextStyles.caption,
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 50,
      width: 1,
      color: AppColors.divider,
    );
  }
} 