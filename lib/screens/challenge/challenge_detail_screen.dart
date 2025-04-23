import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/challenge/challenge_model.dart';
import '../../providers/challenge_provider.dart';
import 'package:intl/intl.dart';

class ChallengeDetailScreen extends StatefulWidget {
  final int challengeId;

  const ChallengeDetailScreen({
    Key? key,
    required this.challengeId,
  }) : super(key: key);

  @override
  State<ChallengeDetailScreen> createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends State<ChallengeDetailScreen> {
  bool _isLoading = true;
  Challenge? _challenge;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadChallengeDetails();
  }

  Future<void> _loadChallengeDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final challengeProvider = Provider.of<ChallengeProvider>(context, listen: false);
      final challenge = await challengeProvider.getChallengeById(widget.challengeId);
      
      setState(() {
        _challenge = challenge;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = 'Không thể tải thông tin thử thách: ${error.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _joinChallenge() async {
    if (_challenge == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final challengeProvider = Provider.of<ChallengeProvider>(context, listen: false);
      final success = await challengeProvider.joinChallenge(_challenge!.id);
      
      if (success) {
        // Reload challenge details to update the status
        await _loadChallengeDetails();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tham gia thử thách thành công')),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Không thể tham gia thử thách. Vui lòng thử lại sau.';
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Không thể tham gia thử thách: ${error.toString()}';
        _isLoading = false;
      });
    }
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'Đã xảy ra lỗi',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadChallengeDetails,
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildChallengeDetailsView() {
    final challenge = _challenge!;
    final theme = Theme.of(context);
    final hasJoined = challenge.hasJoined ?? false;
    final isActive = challenge.isActive;
    final isUpcoming = challenge.isUpcoming;
    final isCompleted = challenge.isCompleted;

    return RefreshIndicator(
      onRefresh: _loadChallengeDetails,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header image
            Container(
              height: 180,
              width: double.infinity,
              color: theme.primaryColor.withOpacity(0.2),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.fitness_center,
                    size: 80,
                    color: Colors.white70,
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      color: Colors.black.withOpacity(0.4),
                      child: Text(
                        challenge.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Status indicator
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              color: _getStatusColor(challenge),
              child: Text(
                _getStatusText(challenge),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  Text(
                    'Mô tả',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    challenge.description,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),

                  // Details
                  Text(
                    'Chi tiết',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailItem(
                    'Thời gian',
                    _formatDateRange(challenge.startDate, challenge.endDate),
                    Icons.date_range,
                  ),
                  _buildDetailItem(
                    'Người tham gia',
                    '${challenge.participantCount ?? 0} người',
                    Icons.people,
                  ),
                  _buildDetailItem(
                    'Phần thưởng',
                    challenge.rewardDescription ?? 'Không có phần thưởng',
                    Icons.card_giftcard,
                  ),
                  _buildDetailItem(
                    'Điểm thưởng',
                    '${challenge.rewardPoints ?? 0} điểm',
                    Icons.stars,
                  ),
                  const SizedBox(height: 24),

                  // Progress section (only if joined and active)
                  if (hasJoined && (isActive || isCompleted)) ...[
                    Text(
                      'Tiến độ của bạn',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Hoàn thành',
                                style: theme.textTheme.bodyMedium,
                              ),
                              Text(
                                '${challenge.completedTasks}/${challenge.totalTasks}',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: challenge.totalTasks > 0
                                ? challenge.completedTasks / challenge.totalTasks
                                : 0,
                            backgroundColor: Colors.grey.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                                theme.primaryColor),
                            borderRadius: BorderRadius.circular(10),
                            minHeight: 10,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            isCompleted
                                ? 'Thử thách đã kết thúc'
                                : 'Tiếp tục hoàn thành các nhiệm vụ để nhận phần thưởng',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Action buttons
                  SizedBox(
                    width: double.infinity,
                    child: _buildActionButton(challenge),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(Challenge challenge) {
    final isActive = challenge.isActive;
    final isUpcoming = challenge.isUpcoming;
    final isCompleted = challenge.isCompleted;
    final hasJoined = challenge.hasJoined ?? false;

    if (isActive && !hasJoined) {
      return ElevatedButton(
        onPressed: _joinChallenge,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text('Tham gia thử thách'),
      );
    } else if (isActive && hasJoined) {
      return OutlinedButton(
        onPressed: () {
          // Navigate to the tasks screen or update progress
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text('Cập nhật tiến độ'),
      );
    } else if (isUpcoming) {
      return OutlinedButton(
        onPressed: null,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          'Thử thách bắt đầu sau ${_getDaysUntil(challenge.startDate)} ngày',
        ),
      );
    } else {
      // Completed challenge
      return OutlinedButton(
        onPressed: null,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text('Thử thách đã kết thúc'),
      );
    }
  }

  Color _getStatusColor(Challenge challenge) {
    if (challenge.isActive) return Colors.green;
    if (challenge.isUpcoming) return Colors.blue;
    return Colors.grey; // completed
  }

  String _getStatusText(Challenge challenge) {
    if (challenge.isActive) return 'Đang diễn ra';
    if (challenge.isUpcoming) return 'Sắp diễn ra';
    return 'Đã kết thúc';
  }

  String _formatDateRange(DateTime? start, DateTime? end) {
    if (start == null || end == null) return 'Chưa có thời gian';
    
    final dateFormat = DateFormat('dd/MM/yyyy');
    return '${dateFormat.format(start)} - ${dateFormat.format(end)}';
  }

  int _getDaysUntil(DateTime? date) {
    if (date == null) return 0;
    
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    return difference > 0 ? difference : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết thử thách'),
      ),
      body: _isLoading
          ? _buildLoadingView()
          : _errorMessage != null
              ? _buildErrorView()
              : _challenge != null
                  ? _buildChallengeDetailsView()
                  : _buildErrorView(),
    );
  }
} 