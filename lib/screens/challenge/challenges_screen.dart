import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/challenge/challenge_model.dart';
import '../../providers/challenge_provider.dart';
import '../../widgets/custom_error_widget.dart';
import '../../widgets/challenge_card.dart';
import 'challenge_detail_screen.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({Key? key}) : super(key: key);

  @override
  _ChallengesScreenState createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ChallengeProvider _challengeProvider;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _challengeProvider = Provider.of<ChallengeProvider>(context);
      _loadInitialData();
      _isInit = true;
    }
    
    // Kiểm tra xem phiên đăng nhập đã hết hạn chưa
    if (_challengeProvider.sessionExpired) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleSessionExpired();
      });
    }
  }

  Future<void> _loadInitialData() async {
    await _challengeProvider.fetchActiveChallenges();
    await _challengeProvider.fetchUpcomingChallenges();
    await _challengeProvider.fetchCompletedChallenges();
  }

  void _handleSessionExpired() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Phiên đăng nhập hết hạn'),
        content: const Text('Phiên đăng nhập của bạn đã hết hạn. Vui lòng đăng nhập lại.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil('/login', (route) => false);
            },
            child: const Text('Đăng nhập'),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshChallenges() async {
    await _challengeProvider.refreshChallenges();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeChallenges = _challengeProvider.activeChallenges;
    final upcomingChallenges = _challengeProvider.upcomingChallenges;
    final completedChallenges = _challengeProvider.completedChallenges;
    final isLoading = _challengeProvider.isLoading;
    final error = _challengeProvider.error;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thử thách'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshChallenges,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? CustomErrorWidget(
                  error: error,
                  onRetry: _refreshChallenges,
                )
              : Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'Đang diễn ra'),
                        Tab(text: 'Sắp tới'),
                        Tab(text: 'Đã hoàn thành'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildChallengesList(
                            activeChallenges,
                            'Không có thử thách nào đang diễn ra.\nHãy quay lại sau để tham gia các thử thách mới!',
                          ),
                          _buildChallengesList(
                            upcomingChallenges,
                            'Không có thử thách nào sắp diễn ra.\nChúng tôi đang chuẩn bị những thử thách mới hấp dẫn!',
                          ),
                          _buildChallengesList(
                            completedChallenges,
                            'Bạn chưa hoàn thành thử thách nào.\nHãy tham gia và hoàn thành các thử thách để nhận phần thưởng!',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildChallengesList(List<Challenge> challenges, String emptyMessage) {
    if (challenges.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.sports_score_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshChallenges,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: challenges.length,
        itemBuilder: (context, index) {
          final challenge = challenges[index];
          return ChallengeCard(
            challenge: challenge, 
            onTap: () => _navigateToChallengeDetail(challenge),
            onJoin: () => _joinChallenge(challenge.id),
          );
        },
      ),
    );
  }

  Future<void> _joinChallenge(int challengeId) async {
    final result = await _challengeProvider.joinChallenge(challengeId);
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result 
              ? 'Tham gia thử thách thành công!' 
              : 'Không thể tham gia thử thách. ${_challengeProvider.error ?? "Vui lòng thử lại sau."}',
        ),
        backgroundColor: result ? Colors.green : Colors.red,
      ),
    );
  }

  void _navigateToChallengeDetail(Challenge challenge) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChallengeDetailScreen(challengeId: challenge.id),
      ),
    );
  }
} 