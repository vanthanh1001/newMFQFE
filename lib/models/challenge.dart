class Challenge {
  final int id;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final int participantCount;
  final String? rewardDescription;
  final int? rewardPoints;
  final bool hasJoined;
  
  Challenge({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.participantCount,
    this.rewardDescription,
    this.rewardPoints,
    this.hasJoined = false,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      participantCount: json['participantCount'] ?? 0,
      rewardDescription: json['rewardDescription'],
      rewardPoints: json['rewardPoints'],
      hasJoined: json['hasJoined'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'participantCount': participantCount,
      'rewardDescription': rewardDescription,
      'rewardPoints': rewardPoints,
      'hasJoined': hasJoined,
    };
  }

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
} 