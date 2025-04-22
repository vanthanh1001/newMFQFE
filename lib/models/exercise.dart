class Exercise {
  final int id;
  final String name;
  final String description;
  final int sets;
  final int reps;
  final int restTime; // in seconds
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int? createdById;
  final String? createdByUsername;
  final String muscleGroup;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.sets,
    required this.reps,
    required this.restTime,
    required this.createdAt,
    this.updatedAt,
    this.createdById,
    this.createdByUsername,
    this.muscleGroup = 'Chưa phân loại',
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      sets: json['sets'],
      reps: json['reps'],
      restTime: json['restTime'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      createdById: json['createdById'],
      createdByUsername: json['createdByUsername'],
      muscleGroup: json['muscleGroup'] ?? 'Chưa phân loại',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'sets': sets,
      'reps': reps,
      'restTime': restTime,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'createdById': createdById,
      'createdByUsername': createdByUsername,
      'muscleGroup': muscleGroup,
    };
  }
} 