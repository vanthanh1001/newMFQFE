import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';

part 'challenge_model.freezed.dart';
part 'challenge_model.g.dart';

@freezed
class Challenge with _$Challenge {
  const factory Challenge({
    required int id,
    required String name,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    @Default(0) int participantCount,
    String? rewardDescription,
    int? rewardPoints,
    @Default(false) bool hasJoined,
    @Default(0) int totalTasks,
    @Default(0) int completedTasks,
  }) = _Challenge;

  factory Challenge.fromJson(Map<String, dynamic> json) => _$ChallengeFromJson(json);

  const Challenge._();

  // Kiểm tra xem challenge có đang active không
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  // Kiểm tra xem challenge đã kết thúc chưa
  bool get isCompleted {
    return DateTime.now().isAfter(endDate);
  }

  // Kiểm tra xem challenge sắp diễn ra
  bool get isUpcoming {
    return DateTime.now().isBefore(startDate);
  }

  // Tính phần trăm thời gian đã trôi qua của challenge
  double get progressPercentage {
    if (isUpcoming) return 0;
    if (isCompleted) return 100;
    
    final now = DateTime.now();
    final totalDuration = endDate.difference(startDate).inSeconds;
    final elapsedDuration = now.difference(startDate).inSeconds;
    
    return (elapsedDuration / totalDuration * 100).clamp(0.0, 100.0);
  }

  // Tính phần trăm hoàn thành nhiệm vụ
  double get taskProgressPercentage {
    if (totalTasks == 0) return 0;
    return (completedTasks / totalTasks * 100).clamp(0.0, 100.0);
  }
  
  // Format thời gian còn lại
  String get remainingTimeText {
    final now = DateTime.now();
    
    if (isCompleted) return 'Đã kết thúc';
    
    Duration remaining;
    String prefix;
    
    if (isUpcoming) {
      remaining = startDate.difference(now);
      prefix = 'Bắt đầu sau';
    } else {
      remaining = endDate.difference(now);
      prefix = 'Còn lại';
    }
    
    if (remaining.inDays > 0) {
      return '$prefix ${remaining.inDays} ngày';
    } else if (remaining.inHours > 0) {
      return '$prefix ${remaining.inHours} giờ';
    } else {
      return '$prefix ${remaining.inMinutes} phút';
    }
  }

  // Format ngày tháng
  String get formattedDateRange {
    final formatter = DateFormat('dd/MM/yyyy');
    return '${formatter.format(startDate)} - ${formatter.format(endDate)}';
  }

  // Getters cho định dạng thời gian
  String get formattedStartDate => _formatDate(startDate);
  String get formattedEndDate => _formatDate(endDate);
  
  // Kiểm tra và tính toán tiến độ
  bool get hasProgress => totalTasks > 0;
  double get progress => totalTasks > 0 ? completedTasks / totalTasks : 0;
  
  // Hàm định dạng ngày tháng
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 