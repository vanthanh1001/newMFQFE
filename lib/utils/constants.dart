import 'package:flutter/material.dart';

class AppConstants {
  // API
  static const String apiBaseUrl = 'https://mfquest-api-windows.azurewebsites.net/api';
  
  // Auth endpoints
  static const String loginEndpoint = 'Auth/login';
  static const String registerEndpoint = 'Auth/register';
  static const String googleEndpoint = 'Auth/google';
  
  // User endpoints
  static const String profileEndpoint = 'User/profile';
  static const String statisticsEndpoint = 'User/statistics';
  
  // Workout endpoints
  static const String workoutPlansEndpoint = 'Workout/plans';
  static const String exerciseCategoriesEndpoint = 'Workout/exercises/categories';
  static const String shareWorkoutPlanEndpoint = 'Workout/plans/share';
  static const String clientsEndpoint = 'Workout/trainer/clients';
  static const String trainerExercisesEndpoint = 'Workout/trainer/exercises';
  static const String publicExercisesEndpoint = 'Workout/public-exercises';
  
  // WorkoutSession endpoints
  static const String workoutSessionEndpoint = 'WorkoutSession';
  static const String workoutHistoryEndpoint = 'WorkoutSession/history';
  
  // Nutrition endpoints
  static const String nutritionEndpoint = 'Nutrition';
  static const String mealPlansEndpoint = 'Nutrition/meal-plans';
  
  // Challenge endpoints
  static const String challengeEndpoint = 'Challenge';
  
  // Goal endpoints
  static const String goalEndpoint = 'Goal';
  
  // Storage keys
  static const String tokenKey = 'jwt_token';
  static const String userDataKey = 'user_data';
  
  // App settings
  static const int itemsPerPage = 10;
}

class AppColors {
  static const Color primary = Color(0xFF3F51B5);
  static const Color primaryDark = Color(0xFF303F9F);
  static const Color accent = Color(0xFFFF5722);
  static const Color secondary = Color(0xFF2196F3);
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFB00020);
  static const Color success = Color(0xFF4CAF50);
  
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFF757575);
  static const Color divider = Color(0xFFBDBDBD);
}

class AppSizes {
  static const double padding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 10.0;
  static const double buttonHeight = 50.0;
  static const double cardElevation = 2.0;
}

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold, 
    color: AppColors.textDark,
  );
  
  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: AppColors.textDark,
  );
  
  static const TextStyle bodyBold = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    color: AppColors.textDark,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.textLight,
  );
  
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}

// Constants cho Theme
const double kDefaultPadding = 16.0;
const double kDefaultMargin = 16.0;
const double kDefaultRadius = 8.0;

// Constants cho Animation
const Duration kDefaultDuration = Duration(milliseconds: 300);

// Constants cho Text Style
const double kHeadingTextSize = 24.0;
const double kTitleTextSize = 18.0;
const double kBodyTextSize = 14.0;
const double kSmallTextSize = 12.0;

// Constants cho Image
const String kDefaultAvatar = 'assets/images/default_avatar.png';
const String kLogoImage = 'assets/images/logo.png';

// Constants cho Shared Preferences Keys
const String kTokenKey = 'token';
const String kUserIdKey = 'user_id';
const String kUserNameKey = 'user_name';
const String kUserEmailKey = 'user_email';
const String kUserAvatarKey = 'user_avatar';
const String kIsLoggedInKey = 'is_logged_in';
const String kIsFirstTimeKey = 'is_first_time'; 