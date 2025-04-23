import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

part 'goal_model.freezed.dart';
part 'goal_model.g.dart';

@freezed
class Goal with _$Goal {
  const factory Goal({
    required String id,
    required String name,
    required String description,
    required DateTime startDate,
    required DateTime targetDate,
    required String category,
    required int targetValue,
    required int currentValue,
    @Default(false) bool isCompleted,
    String? userId,
    String? unit,
    DateTime? completedDate,
  }) = _Goal;

  factory Goal.fromJson(Map<String, dynamic> json) => _$GoalFromJson(json);

  // Thêm các phương thức bổ sung
  const Goal._();

  // Định dạng ngày để hiển thị
  String get formattedStartDate {
    return DateFormat('dd/MM/yyyy').format(startDate);
  }

  String get formattedTargetDate {
    return DateFormat('dd/MM/yyyy').format(targetDate);
  }

  String? get formattedCompletedDate {
    return completedDate != null
        ? DateFormat('dd/MM/yyyy').format(completedDate!)
        : null;
  }

  // Tính toán tiến độ dưới dạng phần trăm
  double get progressPercentage {
    if (targetValue == 0) return 0;
    double progress = (currentValue / targetValue) * 100;
    return progress > 100 ? 100 : progress;
  }

  // Kiểm tra xem mục tiêu đã đạt được chưa
  bool get isAchieved => currentValue >= targetValue;

  // Số ngày còn lại để đạt mục tiêu
  int get daysRemaining {
    final now = DateTime.now();
    if (now.isAfter(targetDate)) return 0;
    return targetDate.difference(now).inDays;
  }

  // Kiểm tra xem mục tiêu đã hết hạn chưa
  bool get isExpired {
    return DateTime.now().isAfter(targetDate) && !isCompleted;
  }

  // Cập nhật giá trị hiện tại của mục tiêu
  Goal updateProgress(int newValue) {
    return copyWith(
      currentValue: newValue,
      isCompleted: newValue >= targetValue,
      completedDate: newValue >= targetValue ? DateTime.now() : completedDate,
    );
  }

  // Đánh dấu mục tiêu là hoàn thành
  Goal markAsCompleted() {
    return copyWith(
      isCompleted: true,
      completedDate: DateTime.now(),
      currentValue: targetValue,
    );
  }
} 