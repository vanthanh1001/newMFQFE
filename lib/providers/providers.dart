import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mfquest_flutter/providers/challenge_provider.dart';
import 'package:mfquest_flutter/providers/auth_provider.dart';

// Auth providers
final authProvider = ChangeNotifierProvider<AuthProvider>((ref) => AuthProvider());

// Challenge providers
final challengeProvider = ChangeNotifierProvider<ChallengeProvider>((ref) => ChallengeProvider()); 