// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GoalImpl _$$GoalImplFromJson(Map<String, dynamic> json) => _$GoalImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      targetDate: DateTime.parse(json['targetDate'] as String),
      category: json['category'] as String,
      targetValue: (json['targetValue'] as num).toInt(),
      currentValue: (json['currentValue'] as num).toInt(),
      isCompleted: json['isCompleted'] as bool? ?? false,
      userId: json['userId'] as String?,
      unit: json['unit'] as String?,
      completedDate: json['completedDate'] == null
          ? null
          : DateTime.parse(json['completedDate'] as String),
    );

Map<String, dynamic> _$$GoalImplToJson(_$GoalImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'startDate': instance.startDate.toIso8601String(),
      'targetDate': instance.targetDate.toIso8601String(),
      'category': instance.category,
      'targetValue': instance.targetValue,
      'currentValue': instance.currentValue,
      'isCompleted': instance.isCompleted,
      'userId': instance.userId,
      'unit': instance.unit,
      'completedDate': instance.completedDate?.toIso8601String(),
    };
