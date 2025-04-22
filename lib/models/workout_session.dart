class ExercisePerformance {
  final int id;
  final int exerciseId;
  final String exerciseName;
  final int actualSets;
  final int actualReps;
  final int weightUsed;
  final int actualRestTime;
  final String? notes;

  ExercisePerformance({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.actualSets,
    required this.actualReps,
    required this.weightUsed,
    required this.actualRestTime,
    this.notes,
  });

  factory ExercisePerformance.fromJson(Map<String, dynamic> json) {
    return ExercisePerformance(
      id: json['id'],
      exerciseId: json['exerciseId'],
      exerciseName: json['exerciseName'],
      actualSets: json['actualSets'],
      actualReps: json['actualReps'],
      weightUsed: json['weightUsed'],
      actualRestTime: json['actualRestTime'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'actualSets': actualSets,
      'actualReps': actualReps,
      'weightUsed': weightUsed,
      'actualRestTime': actualRestTime,
      'notes': notes,
    };
  }
}

class WorkoutSession {
  final int id;
  final int? workoutPlanId;
  final String? workoutPlanName;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationInMinutes;
  final String? notes;
  final List<ExercisePerformance> performances;

  WorkoutSession({
    required this.id,
    this.workoutPlanId,
    this.workoutPlanName,
    required this.startTime,
    this.endTime,
    required this.durationInMinutes,
    this.notes,
    required this.performances,
  });

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    var performancesList = <ExercisePerformance>[];
    if (json['performances'] != null) {
      performancesList = (json['performances'] as List)
          .map((performanceJson) => ExercisePerformance.fromJson(performanceJson))
          .toList();
    }

    return WorkoutSession(
      id: json['id'],
      workoutPlanId: json['workoutPlanId'],
      workoutPlanName: json['workoutPlanName'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      durationInMinutes: json['durationInMinutes'],
      notes: json['notes'],
      performances: performancesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workoutPlanId': workoutPlanId,
      'workoutPlanName': workoutPlanName,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'durationInMinutes': durationInMinutes,
      'notes': notes,
      'performances': performances.map((p) => p.toJson()).toList(),
    };
  }
}

class CreateExercisePerformanceRequest {
  final int exerciseId;
  final int actualSets;
  final int actualReps;
  final int weightUsed;
  final int actualRestTime;
  final String? notes;

  CreateExercisePerformanceRequest({
    required this.exerciseId,
    required this.actualSets,
    required this.actualReps,
    required this.weightUsed,
    required this.actualRestTime,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'actualSets': actualSets,
      'actualReps': actualReps,
      'weightUsed': weightUsed,
      'actualRestTime': actualRestTime,
      'notes': notes,
    };
  }
}

class CreateWorkoutSessionRequest {
  final int? workoutPlanId;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationInMinutes;
  final String? notes;
  final List<CreateExercisePerformanceRequest> performances;

  CreateWorkoutSessionRequest({
    this.workoutPlanId,
    required this.startTime,
    this.endTime,
    required this.durationInMinutes,
    this.notes,
    required this.performances,
  });

  Map<String, dynamic> toJson() {
    return {
      'workoutPlanId': workoutPlanId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'durationInMinutes': durationInMinutes,
      'notes': notes,
      'performances': performances.map((p) => p.toJson()).toList(),
    };
  }
}

class WorkoutHistory {
  final int totalWorkouts;
  final int totalDuration;
  final List<WorkoutSession> recentSessions;

  WorkoutHistory({
    required this.totalWorkouts,
    required this.totalDuration,
    required this.recentSessions,
  });

  factory WorkoutHistory.fromJson(Map<String, dynamic> json) {
    var sessionsList = <WorkoutSession>[];
    if (json['recentSessions'] != null) {
      sessionsList = (json['recentSessions'] as List)
          .map((sessionJson) => WorkoutSession.fromJson(sessionJson))
          .toList();
    }

    return WorkoutHistory(
      totalWorkouts: json['totalWorkouts'],
      totalDuration: json['totalDuration'],
      recentSessions: sessionsList,
    );
  }
} 