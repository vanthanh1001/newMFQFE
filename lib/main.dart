import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/auth/login_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/workout_provider.dart';
import 'providers/exercise_provider.dart';
import 'providers/challenge_provider.dart';
import 'screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ExerciseProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
        ChangeNotifierProvider(create: (_) => ChallengeProvider()),
      ],
      child: const AppWithAuth(),
    );
  }
}

class AppWithAuth extends StatefulWidget {
  const AppWithAuth({Key? key}) : super(key: key);

  @override
  State<AppWithAuth> createState() => _AppWithAuthState();
}

class _AppWithAuthState extends State<AppWithAuth> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    setState(() {
      _isInitialized = false;
    });

    // WidgetsBinding.instance giúp chạy code sau khi build hoàn thành
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.tryAutoLogin();
      } catch (e) {
        debugPrint('Lỗi khi tự động đăng nhập: $e');
      } finally {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Fitness Quest',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: _isInitialized
          ? _buildHomeOrLogin()
          : const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
      routes: {
        LoginScreen.routePath: (context) => const LoginScreen(),
      },
    );
  }

  Widget _buildHomeOrLogin() {
    return Consumer<AuthProvider>(
      builder: (ctx, authProvider, _) {
        return authProvider.isAuth
            ? const HomeScreen()
            : const LoginScreen();
      },
    );
  }
}
