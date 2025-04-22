import 'exercise_plan.dart';

class WorkoutPlan {
  final int id;
  final String name;
  final String description;
  final String difficulty;
  final int durationInMinutes;
  final DateTime createdAt;
  final List<ExercisePlan> exercises;

  WorkoutPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.difficulty,
    required this.durationInMinutes,
    required this.createdAt,
    required this.exercises,
  });

  // Thuộc tính tính toán để lấy số lượng bài tập
  int get exerciseCount => exercises.length;

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    List<ExercisePlan> exercisesList = [];
    if (json['exercises'] != null) {
      exercisesList = List<ExercisePlan>.from(
        json['exercises'].map((exercise) => ExercisePlan.fromJson(exercise)),
      );
    }

    return WorkoutPlan(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      difficulty: json['difficulty'],
      durationInMinutes: json['durationInMinutes'],
      createdAt: DateTime.parse(json['createdAt']),
      exercises: exercisesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'difficulty': difficulty,
      'durationInMinutes': durationInMinutes,
      'createdAt': createdAt.toIso8601String(),
      'exercises': exercises.map((exercise) => exercise.toJson()).toList(),
    };
  }
}

class CreateWorkoutPlanRequest {
  final String name;
  final String description;
  final String difficulty;
  final int durationInMinutes;
  final List<int>? exerciseIds;

  CreateWorkoutPlanRequest({
    required this.name,
    required this.description,
    required this.difficulty,
    required this.durationInMinutes,
    this.exerciseIds,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'description': description,
      'difficulty': difficulty,
      'durationInMinutes': durationInMinutes,
    };

    if (exerciseIds != null) {
      data['exerciseIds'] = exerciseIds;
    }

    return data;
  }
} 