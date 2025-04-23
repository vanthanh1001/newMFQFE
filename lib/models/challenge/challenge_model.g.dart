// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChallengeImpl _$$ChallengeImplFromJson(Map<String, dynamic> json) =>
    _$ChallengeImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      participantCount: (json['participantCount'] as num?)?.toInt() ?? 0,
      rewardDescription: json['rewardDescription'] as String?,
      rewardPoints: (json['rewardPoints'] as num?)?.toInt(),
      hasJoined: json['hasJoined'] as bool? ?? false,
      totalTasks: (json['totalTasks'] as num?)?.toInt() ?? 0,
      completedTasks: (json['completedTasks'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$ChallengeImplToJson(_$ChallengeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'participantCount': instance.participantCount,
      'rewardDescription': instance.rewardDescription,
      'rewardPoints': instance.rewardPoints,
      'hasJoined': instance.hasJoined,
      'totalTasks': instance.totalTasks,
      'completedTasks': instance.completedTasks,
    };
