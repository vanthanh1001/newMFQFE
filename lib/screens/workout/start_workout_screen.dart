import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/workout_plan.dart';
import '../../models/workout_session.dart';
import '../../providers/workout_provider.dart';
import '../../utils/constants.dart';
import 'dart:async';

class StartWorkoutScreen extends StatefulWidget {
  final WorkoutPlan workoutPlan;

  const StartWorkoutScreen({super.key, required this.workoutPlan});

  @override
  State<StartWorkoutScreen> createState() => _StartWorkoutScreenState();
}

class _StartWorkoutScreenState extends State<StartWorkoutScreen> {
  late DateTime _startTime;
  Stopwatch _stopwatch = Stopwatch();
  late Timer _timer;
  String _timeDisplay = '00:00:00';
  int _currentExerciseIndex = 0;
  bool _isResting = false;
  int _restTimeLeft = 0;
  late Timer _restTimer;
  List<ExercisePerformanceResult> _performances = [];

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeDisplay = _formatTime(_stopwatch.elapsedMilliseconds);
      });
    });

    _initializePerformances();
  }

  void _initializePerformances() {
    if (widget.workoutPlan.exercises.isNotEmpty) {
      _performances = widget.workoutPlan.exercises.map((exercise) {
        return ExercisePerformanceResult(
          exerciseId: exercise.id,
          exerciseName: exercise.name,
          actualSets: exercise.sets,
          actualReps: exercise.reps,
          weightUsed: 0,
          actualRestTime: exercise.restTimeInSeconds,
          notes: '',
        );
      }).toList();
    }
  }

  @override
  void dispose() {
    _stopwatch.stop();
    _timer.cancel();
    if (_isResting) {
      _restTimer.cancel();
    }
    super.dispose();
  }

  String _formatTime(int milliseconds) {
    var secs = milliseconds ~/ 1000;
    var hours = (secs ~/ 3600).toString().padLeft(2, '0');
    var minutes = ((secs % 3600) ~/ 60).toString().padLeft(2, '0');
    var seconds = (secs % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }

  void _startRest() {
    setState(() {
      _isResting = true;
      _restTimeLeft = widget.workoutPlan.exercises[_currentExerciseIndex].restTimeInSeconds;
    });

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_restTimeLeft > 0) {
          _restTimeLeft--;
        } else {
          _isResting = false;
          _restTimer.cancel();
        }
      });
    });
  }

  void _nextExercise() {
    if (_isResting) {
      _restTimer.cancel();
    }

    if (_currentExerciseIndex < widget.workoutPlan.exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _isResting = false;
      });
    } else {
      _completeWorkout();
    }
  }

  void _previousExercise() {
    if (_isResting) {
      _restTimer.cancel();
    }

    if (_currentExerciseIndex > 0) {
      setState(() {
        _currentExerciseIndex--;
        _isResting = false;
      });
    }
  }

  void _updatePerformance(int index, {int? sets, int? reps, int? weight, String? notes}) {
    setState(() {
      if (sets != null) _performances[index].actualSets = sets;
      if (reps != null) _performances[index].actualReps = reps;
      if (weight != null) _performances[index].weightUsed = weight;
      if (notes != null) _performances[index].notes = notes;
    });
  }

  void _completeWorkout() async {
    _stopwatch.stop();
    _timer.cancel();

    final totalDurationInMinutes = _stopwatch.elapsedMilliseconds ~/ 60000;

    final request = CreateWorkoutSessionRequest(
      workoutPlanId: widget.workoutPlan.id,
      startTime: _startTime,
      endTime: DateTime.now(),
      durationInMinutes: totalDurationInMinutes,
      performances: _performances.map((p) => CreateExercisePerformanceRequest(
        exerciseId: p.exerciseId,
        actualSets: p.actualSets,
        actualReps: p.actualReps,
        weightUsed: p.weightUsed,
        actualRestTime: p.actualRestTime,
        notes: p.notes,
      )).toList(),
    );

    try {
      await Provider.of<WorkoutProvider>(context, listen: false)
          .createWorkoutSession(request);

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Bài tập hoàn thành!'),
            content: Text(
              'Bạn đã hoàn thành bài tập trong ${_timeDisplay}. Thông tin đã được lưu lại.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Đóng dialog
                  Navigator.pop(context); // Trở về màn hình chi tiết bài tập
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi lưu bài tập: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          widget.workoutPlan.name,
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => _showExitConfirmDialog(),
        ),
      ),
      body: Column(
        children: [
          // Timer
          Container(
            padding: const EdgeInsets.all(20),
            color: AppColors.primary,
            child: Column(
              children: [
                const Text(
                  'Thời gian',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _timeDisplay,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Exercise Status
          Expanded(
            child: Stack(
              children: [
                if (widget.workoutPlan.exercises.isEmpty)
                  const Center(
                    child: Text(
                      'Không có bài tập nào trong kế hoạch này',
                      style: TextStyle(fontSize: 16, color: AppColors.textLight),
                    ),
                  )
                else
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bài ${_currentExerciseIndex + 1}/${widget.workoutPlan.exercises.length}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textLight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.workoutPlan.exercises[_currentExerciseIndex].name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.workoutPlan.exercises[_currentExerciseIndex].description,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textLight,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildExerciseDetail(
                              'Sets',
                              _performances[_currentExerciseIndex].actualSets.toString(),
                              onIncrease: () {
                                _updatePerformance(
                                  _currentExerciseIndex,
                                  sets: _performances[_currentExerciseIndex].actualSets + 1,
                                );
                              },
                              onDecrease: () {
                                if (_performances[_currentExerciseIndex].actualSets > 1) {
                                  _updatePerformance(
                                    _currentExerciseIndex,
                                    sets: _performances[_currentExerciseIndex].actualSets - 1,
                                  );
                                }
                              },
                            ),
                            _buildExerciseDetail(
                              'Reps',
                              _performances[_currentExerciseIndex].actualReps.toString(),
                              onIncrease: () {
                                _updatePerformance(
                                  _currentExerciseIndex,
                                  reps: _performances[_currentExerciseIndex].actualReps + 1,
                                );
                              },
                              onDecrease: () {
                                if (_performances[_currentExerciseIndex].actualReps > 1) {
                                  _updatePerformance(
                                    _currentExerciseIndex,
                                    reps: _performances[_currentExerciseIndex].actualReps - 1,
                                  );
                                }
                              },
                            ),
                            _buildExerciseDetail(
                              'Weight (kg)',
                              _performances[_currentExerciseIndex].weightUsed.toString(),
                              onIncrease: () {
                                _updatePerformance(
                                  _currentExerciseIndex,
                                  weight: _performances[_currentExerciseIndex].weightUsed + 1,
                                );
                              },
                              onDecrease: () {
                                if (_performances[_currentExerciseIndex].weightUsed > 0) {
                                  _updatePerformance(
                                    _currentExerciseIndex,
                                    weight: _performances[_currentExerciseIndex].weightUsed - 1,
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Ghi chú',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          onChanged: (value) {
                            _updatePerformance(
                              _currentExerciseIndex,
                              notes: value,
                            );
                          },
                          decoration: InputDecoration(
                            hintText: 'Nhập ghi chú về bài tập này...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                if (_isResting)
                  Container(
                    color: Colors.black.withOpacity(0.7),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'NGHỈ NGƠI',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _formatTime(_restTimeLeft * 1000),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              _restTimer.cancel();
                              setState(() {
                                _isResting = false;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                            ),
                            child: const Text('BỎ QUA'),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Navigation Buttons
          if (widget.workoutPlan.exercises.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: _currentExerciseIndex > 0
                        ? _previousExercise
                        : null,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                      ),
                    ),
                    child: const Text('TRƯỚC'),
                  ),
                  if (!_isResting)
                    ElevatedButton(
                      onPressed: _startRest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                        ),
                      ),
                      child: const Text('BẮT ĐẦU NGHỈ'),
                    ),
                  if (_currentExerciseIndex < widget.workoutPlan.exercises.length - 1)
                    ElevatedButton(
                      onPressed: _nextExercise,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                        ),
                      ),
                      child: const Text('TIẾP'),
                    )
                  else
                    ElevatedButton(
                      onPressed: _completeWorkout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                        ),
                      ),
                      child: const Text('HOÀN THÀNH'),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showExitConfirmDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Kết thúc bài tập?'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Bạn có chắc muốn kết thúc bài tập hiện tại?'),
                Text('Tiến trình sẽ không được lưu.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('TIẾP TỤC TẬP'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('KẾT THÚC'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildExerciseDetail(String label, String value, {
    VoidCallback? onIncrease,
    VoidCallback? onDecrease,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textLight,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove, size: 18),
                onPressed: onDecrease,
                constraints: const BoxConstraints(
                  minWidth: 36,
                  minHeight: 36,
                ),
                padding: EdgeInsets.zero,
                color: AppColors.textLight,
              ),
              SizedBox(
                width: 40,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 18),
                onPressed: onIncrease,
                constraints: const BoxConstraints(
                  minWidth: 36,
                  minHeight: 36,
                ),
                padding: EdgeInsets.zero,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ExercisePerformanceResult {
  final int exerciseId;
  final String exerciseName;
  int actualSets;
  int actualReps;
  int weightUsed;
  final int actualRestTime;
  String notes;

  ExercisePerformanceResult({
    required this.exerciseId,
    required this.exerciseName,
    required this.actualSets,
    required this.actualReps,
    required this.weightUsed,
    required this.actualRestTime,
    required this.notes,
  });
} 