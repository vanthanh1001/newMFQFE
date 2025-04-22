import 'exercise.dart';

class ExercisePlan {
  final int id;
  final String name;
  final String description;
  final String muscleGroup;
  final int sets;
  final int reps;
  final int restTimeInSeconds;
  final Exercise exercise;

  ExercisePlan({
    required this.id,
    required this.name,
    required this.description,
    required this.muscleGroup,
    required this.sets,
    required this.reps,
    required this.restTimeInSeconds,
    required this.exercise,
  });

  factory ExercisePlan.fromJson(Map<String, dynamic> json) {
    return ExercisePlan(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      muscleGroup: json['muscleGroup'] ?? 'Chưa phân loại',
      sets: json['sets'] ?? 3,
      reps: json['reps'] ?? 10,
      restTimeInSeconds: json['restTimeInSeconds'] ?? 60,
      exercise: json['exercise'] != null 
        ? Exercise.fromJson(json['exercise']) 
        : Exercise(
            id: json['id'] ?? 0,
            name: json['name'] ?? '',
            description: json['description'] ?? '',
            sets: json['sets'] ?? 3,
            reps: json['reps'] ?? 10,
            restTime: json['restTimeInSeconds'] ?? 60,
            createdAt: DateTime.now(),
          ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'muscleGroup': muscleGroup,
      'sets': sets,
      'reps': reps,
      'restTimeInSeconds': restTimeInSeconds,
      'exercise': exercise.toJson(),
    };
  }
} 