import 'package:flutter/material.dart';
import '../models/challenge/challenge_model.dart';
import 'package:intl/intl.dart';

class ChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final VoidCallback onTap;
  final VoidCallback onJoin;

  const ChallengeCard({
    Key? key,
    required this.challenge,
    required this.onTap,
    required this.onJoin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = challenge.isActive;
    final isUpcoming = challenge.isUpcoming;
    final isCompleted = challenge.isCompleted;
    final hasJoined = challenge.hasJoined ?? false;

    Color statusColor = Colors.green;
    String statusText = 'Đang diễn ra';
    
    if (isUpcoming) {
      statusColor = Colors.blue;
      statusText = 'Sắp diễn ra';
    } else if (isCompleted) {
      statusColor = Colors.grey;
      statusText = 'Đã kết thúc';
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with image and status label
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    color: theme.primaryColor.withOpacity(0.1),
                    child: const Icon(
                      Icons.fitness_center,
                      size: 60,
                      color: Colors.white54,
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Content section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    challenge.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    challenge.description,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  
                  // Stats and dates
                  Row(
                    children: [
                      _buildInfoItem(
                        Icons.people_outline,
                        '${challenge.participantCount ?? 0} người tham gia',
                        theme,
                      ),
                      const SizedBox(width: 16),
                      _buildInfoItem(
                        Icons.calendar_today,
                        _formatDateRange(challenge.startDate, challenge.endDate),
                        theme,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Progress indicator (only for active joined challenges)
                  if (isActive && hasJoined && challenge.totalTasks > 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tiến độ',
                              style: theme.textTheme.bodyMedium,
                            ),
                            Text(
                              '${challenge.completedTasks}/${challenge.totalTasks}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: challenge.totalTasks > 0
                              ? challenge.completedTasks / challenge.totalTasks
                              : 0,
                          backgroundColor: Colors.grey.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                          borderRadius: BorderRadius.circular(10),
                          minHeight: 8,
                        ),
                      ],
                    ),
                  
                  // Action buttons
                  const SizedBox(height: 16),
                  if (isActive && !hasJoined)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onJoin,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Tham gia ngay'),
                      ),
                    )
                  else if (isActive && hasJoined)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: onTap,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Xem chi tiết'),
                      ),
                    )
                  else if (isUpcoming)
                    Row(
                      children: [
                        const Icon(Icons.schedule, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          'Bắt đầu sau ${_getDaysUntil(challenge.startDate)} ngày',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _formatDateRange(DateTime? start, DateTime? end) {
    if (start == null || end == null) return 'Chưa có thời gian';
    
    final dateFormat = DateFormat('dd/MM');
    return '${dateFormat.format(start)} - ${dateFormat.format(end)}';
  }

  int _getDaysUntil(DateTime? date) {
    if (date == null) return 0;
    
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    return difference > 0 ? difference : 0;
  }
} 