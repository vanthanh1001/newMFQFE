import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/exercise.dart';
import '../../providers/exercise_provider.dart';
import '../../utils/constants.dart';

class ExerciseFormScreen extends StatefulWidget {
  final int? exerciseId;

  const ExerciseFormScreen({
    super.key,
    this.exerciseId,
  });

  @override
  State<ExerciseFormScreen> createState() => _ExerciseFormScreenState();
}

class _ExerciseFormScreenState extends State<ExerciseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _setsController = TextEditingController();
  final _repsController = TextEditingController();
  final _restTimeController = TextEditingController();
  bool _isLoading = false;
  bool _isInit = false;
  String _selectedMuscleGroup = 'Chưa phân loại';

  final List<String> _muscleGroups = [
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
      _loadExercise();
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _restTimeController.dispose();
    super.dispose();
  }

  Future<void> _loadExercise() async {
    if (widget.exerciseId == null) {
      // Đang tạo mới
      _setsController.text = '3';
      _repsController.text = '10';
      _restTimeController.text = '60';
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Lấy thông tin bài tập hiện có
      final exerciseProvider = Provider.of<ExerciseProvider>(
        context,
        listen: false,
      );
      await exerciseProvider.fetchExerciseDetail(widget.exerciseId!);
      final exercise = exerciseProvider.selectedExercise;

      if (exercise != null) {
        _nameController.text = exercise.name;
        _descriptionController.text = exercise.description;
        _setsController.text = exercise.sets.toString();
        _repsController.text = exercise.reps.toString();
        _restTimeController.text = exercise.restTime.toString();
        _selectedMuscleGroup = exercise.muscleGroup;
      }
    } catch (e) {
      // Xử lý lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể tải thông tin bài tập: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveExercise() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final exerciseProvider = Provider.of<ExerciseProvider>(
        context,
        listen: false,
      );

      final name = _nameController.text;
      final description = _descriptionController.text;
      final sets = int.parse(_setsController.text);
      final reps = int.parse(_repsController.text);
      final restTime = int.parse(_restTimeController.text);

      bool success;
      if (widget.exerciseId == null) {
        // Tạo mới
        success = await exerciseProvider.createExercise(
          name: name,
          description: description,
          sets: sets,
          reps: reps,
          restTime: restTime,
        );
      } else {
        // Cập nhật
        success = await exerciseProvider.updateExercise(
          id: widget.exerciseId!,
          name: name,
          description: description,
          sets: sets,
          reps: reps,
          restTime: restTime,
        );
      }

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.exerciseId == null
                  ? 'Tạo bài tập thành công'
                  : 'Cập nhật bài tập thành công',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exerciseId == null
            ? 'Tạo Bài Tập Mới'
            : 'Chỉnh Sửa Bài Tập'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.padding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên bài tập
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Tên bài tập',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập tên bài tập';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Nhóm cơ
                    DropdownButtonFormField<String>(
                      value: _selectedMuscleGroup,
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedMuscleGroup = newValue;
                          });
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Nhóm cơ',
                        border: OutlineInputBorder(),
                      ),
                      items: _muscleGroups.map((group) {
                        return DropdownMenuItem<String>(
                          value: group,
                          child: Text(group),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Số set
                    TextFormField(
                      controller: _setsController,
                      decoration: const InputDecoration(
                        labelText: 'Số set',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập số set';
                        }
                        final number = int.tryParse(value);
                        if (number == null || number <= 0) {
                          return 'Vui lòng nhập số hợp lệ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Số lần lặp (reps)
                    TextFormField(
                      controller: _repsController,
                      decoration: const InputDecoration(
                        labelText: 'Số lần lặp (reps)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập số lần lặp';
                        }
                        final number = int.tryParse(value);
                        if (number == null || number <= 0) {
                          return 'Vui lòng nhập số hợp lệ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Thời gian nghỉ
                    TextFormField(
                      controller: _restTimeController,
                      decoration: const InputDecoration(
                        labelText: 'Thời gian nghỉ (giây)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập thời gian nghỉ';
                        }
                        final number = int.tryParse(value);
                        if (number == null || number < 0) {
                          return 'Vui lòng nhập số hợp lệ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Mô tả
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Mô tả',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                      minLines: 3,
                    ),
                    const SizedBox(height: 24),

                    // Nút lưu
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveExercise,
                        child: Text(
                          widget.exerciseId == null ? 'Tạo Bài Tập' : 'Lưu Thay Đổi',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 