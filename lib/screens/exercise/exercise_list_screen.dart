import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/exercise.dart';
import '../../providers/exercise_provider.dart';
import '../../utils/constants.dart';
import 'exercise_detail_screen.dart';
import 'exercise_form_screen.dart';

class ExerciseListScreen extends StatefulWidget {
  const ExerciseListScreen({Key? key}) : super(key: key);

  @override
  State<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _selectedMuscleGroup = 'Tất cả';
  bool _isInit = false;

  final List<String> _muscleGroups = [
    'Tất cả',
    'Ngực',
    'Lưng',
    'Vai',
    'Tay',
    'Chân',
    'Bụng',
    'Chưa phân loại'
  ];

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      _isInit = true;
      _loadExercises();
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadExercises() async {
    try {
      await Provider.of<ExerciseProvider>(context, listen: false).fetchExercises();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể tải danh sách bài tập: $error'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _handleSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
      });
      _loadExercises();
    } else {
      setState(() {
        _isSearching = true;
      });
      Provider.of<ExerciseProvider>(context, listen: false).searchExercises(query);
    }
  }

  List<Exercise> _filterExercisesByMuscleGroup(List<Exercise> exercises) {
    if (_selectedMuscleGroup == 'Tất cả') {
      return exercises;
    } else {
      return exercises.where((exercise) => 
        exercise.muscleGroup == _selectedMuscleGroup
      ).toList();
    }
  }

  void _navigateToExerciseDetail(int exerciseId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => ExerciseDetailScreen(exerciseId: exerciseId),
      ),
    ).then((_) {
      _loadExercises();
    });
  }

  void _navigateToExerciseForm({int? exerciseId}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => ExerciseFormScreen(exerciseId: exerciseId),
      ),
    ).then((_) {
      _loadExercises();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching 
            ? TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm bài tập...',
                  hintStyle: const TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.white),
                autofocus: true,
                onChanged: _handleSearch,
              )
            : const Text('Danh sách bài tập'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _loadExercises();
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Danh mục cơ
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _muscleGroups.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (ctx, index) {
                final muscleGroup = _muscleGroups[index];
                final isSelected = _selectedMuscleGroup == muscleGroup;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMuscleGroup = muscleGroup;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.divider,
                      ),
                    ),
                    child: Text(
                      muscleGroup,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textDark,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Danh sách bài tập
          Expanded(
            child: Consumer<ExerciseProvider>(
              builder: (ctx, exerciseProvider, child) {
                if (exerciseProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (exerciseProvider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Đã xảy ra lỗi:',
                          style: AppTextStyles.heading3,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          exerciseProvider.errorMessage!,
                          style: AppTextStyles.body,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadExercises,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                }
                
                final filteredExercises = _filterExercisesByMuscleGroup(
                  _isSearching ? exerciseProvider.filteredExercises : exerciseProvider.exercises
                );
                
                if (filteredExercises.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: 64,
                          color: AppColors.textLight.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isSearching 
                              ? 'Không tìm thấy bài tập phù hợp'
                              : 'Chưa có bài tập nào',
                          style: AppTextStyles.heading3.copyWith(
                            color: AppColors.textLight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (!_isSearching)
                          ElevatedButton.icon(
                            onPressed: () => _navigateToExerciseForm(),
                            icon: const Icon(Icons.add),
                            label: const Text('Thêm bài tập mới'),
                          ),
                      ],
                    ),
                  );
                }
                
                return RefreshIndicator(
                  onRefresh: _loadExercises,
                  child: ListView.builder(
                    itemCount: filteredExercises.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (ctx, index) {
                      final exercise = filteredExercises[index];
                      return Card(
                        elevation: AppSizes.cardElevation,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                        ),
                        child: InkWell(
                          onTap: () => _navigateToExerciseDetail(exercise.id),
                          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    // Biểu tượng dựa trên nhóm cơ
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: Icon(
                                        _getIconForMuscleGroup(exercise.muscleGroup),
                                        color: AppColors.primary,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            exercise.name,
                                            style: AppTextStyles.heading3,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            exercise.muscleGroup,
                                            style: AppTextStyles.caption,
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: AppColors.secondary),
                                      onPressed: () => _navigateToExerciseForm(exerciseId: exercise.id),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  exercise.description,
                                  style: AppTextStyles.body,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildStatItem(
                                      Icons.repeat, 
                                      '${exercise.sets} Hiệp',
                                    ),
                                    _buildStatItem(
                                      Icons.fitness_center, 
                                      '${exercise.reps} Lần',
                                    ),
                                    _buildStatItem(
                                      Icons.timer, 
                                      '${exercise.restTime}s Nghỉ',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToExerciseForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textLight,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTextStyles.caption,
        ),
      ],
    );
  }
  
  IconData _getIconForMuscleGroup(String muscleGroup) {
    switch (muscleGroup) {
      case 'Ngực':
        return Icons.fitness_center;
      case 'Lưng':
        return Icons.accessibility_new;
      case 'Vai':
        return Icons.fitness_center;
      case 'Tay':
        return Icons.sports_gymnastics;
      case 'Chân':
        return Icons.directions_run;
      case 'Bụng':
        return Icons.sports_martial_arts;
      default:
        return Icons.fitness_center;
    }
  }
} 