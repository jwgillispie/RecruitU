/// Application-wide constants for RecruitU
class AppConstants {
  // App Information
  static const String appName = 'RecruitU';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'College Soccer Player-Coach Matching Platform';
  
  // API Configuration
  static const String baseUrlDev = 'https://api-dev.recruitu.com';
  static const String baseUrlStaging = 'https://api-staging.recruitu.com';
  static const String baseUrlProd = 'https://api.recruitu.com';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String playerProfilesCollection = 'player_profiles';
  static const String coachProfilesCollection = 'coach_profiles';
  static const String matchesCollection = 'matches';
  static const String conversationsCollection = 'conversations';
  static const String messagesCollection = 'messages';
  static const String userInteractionsCollection = 'user_interactions';
  static const String mediaUploadsCollection = 'media_uploads';
  
  // Storage Paths
  static const String profileImagesPath = 'profile_images';
  static const String additionalPhotosPath = 'additional_photos';
  static const String videoHighlightsPath = 'video_highlights';
  static const String achievementCertsPath = 'achievement_certs';
  
  // User Preferences Keys
  static const String userTypeKey = 'user_type';
  static const String onboardingCompletedKey = 'onboarding_completed';
  static const String themeKey = 'theme_mode';
  static const String notificationsEnabledKey = 'notifications_enabled';
  
  // Business Logic Constants
  static const int maxFreeSwipesPerDay = 10;
  static const int maxPremiumSwipesPerDay = 50;
  static const int maxVideoUploads = 2;
  static const int maxPremiumVideoUploads = 10;
  static const double minCompatibilityScore = 0.6;
  static const int messageMaxLength = 1000;
  static const int bioMaxLength = 500;
  static const int nameMaxLength = 50;
  
  // Validation Patterns
  static const String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const String phonePattern = r'^\+?[\d\s\-\(\)]+$';
  static const String passwordPattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$';
  
  // Sports and Positions
  static const List<String> supportedSports = ['Soccer', 'Football'];
  static const Map<String, List<String>> soccerPositions = {
    'Goalkeeper': ['GK'],
    'Defender': ['CB', 'LB', 'RB', 'LWB', 'RWB'],
    'Midfielder': ['CDM', 'CM', 'CAM', 'LM', 'RM'],
    'Forward': ['LW', 'RW', 'ST', 'CF'],
  };
  
  // Division Levels
  static const List<String> divisionLevels = [
    'Division I',
    'Division II',
    'Division III',
    'NAIA',
    'Junior College',
    'Community College',
  ];
  
  // Regions
  static const List<String> usRegions = [
    'Northeast',
    'Southeast',
    'Midwest',
    'Southwest',
    'West Coast',
    'Northwest',
    'Mountain West',
    'Great Lakes',
  ];
  
  // Error Messages
  static const String networkError = 'Network connection error. Please check your internet connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String unknownError = 'An unknown error occurred. Please try again.';
  static const String authError = 'Authentication failed. Please check your credentials.';
  static const String permissionError = 'Permission denied. Please check app permissions.';
  
  // Success Messages
  static const String profileUpdated = 'Profile updated successfully!';
  static const String messageSent = 'Message sent successfully!';
  static const String matchFound = 'New match found!';
  static const String accountCreated = 'Account created successfully!';
  
  // Feature Flags (can be overridden by Firebase Remote Config)
  static const bool enableVideoChat = false;
  static const bool enableAdvancedFilters = true;
  static const bool enablePushNotifications = true;
  static const bool enableAnalytics = true;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
  
  // Cache Durations
  static const Duration cacheShortDuration = Duration(minutes: 5);
  static const Duration cacheMediumDuration = Duration(minutes: 15);
  static const Duration cacheLongDuration = Duration(hours: 1);
  
  // Rate Limiting
  static const int maxApiRequestsPerMinute = 60;
  static const int maxSwipesPerMinute = 30;
  static const int maxMessagesPerMinute = 10;
}

/// User types enumeration
enum UserType { player, coach, scout, parent }

/// Match status enumeration
enum MatchStatus { pending, interested, connected, declined }

/// Connection status enumeration
enum ConnectionStatus { active, paused, blocked }

/// Message types enumeration
enum MessageType { text, image, video, system }

/// Subscription tiers enumeration
enum SubscriptionTier { free, premium, elite }

/// Environment types enumeration
enum Environment { development, staging, production }

/// Soccer position enumeration
enum SoccerPosition {
  // Goalkeeper
  gk('GK', 'Goalkeeper'),
  
  // Defenders
  cb('CB', 'Center Back'),
  lb('LB', 'Left Back'),
  rb('RB', 'Right Back'),
  lwb('LWB', 'Left Wing Back'),
  rwb('RWB', 'Right Wing Back'),
  
  // Midfielders
  cdm('CDM', 'Defensive Midfielder'),
  cm('CM', 'Central Midfielder'),
  cam('CAM', 'Attacking Midfielder'),
  lm('LM', 'Left Midfielder'),
  rm('RM', 'Right Midfielder'),
  
  // Forwards
  lw('LW', 'Left Winger'),
  rw('RW', 'Right Winger'),
  st('ST', 'Striker'),
  cf('CF', 'Center Forward');

  const SoccerPosition(this.code, this.displayName);
  
  final String code;
  final String displayName;
  
  /// Get position category
  String get category {
    switch (this) {
      case SoccerPosition.gk:
        return 'Goalkeeper';
      case SoccerPosition.cb:
      case SoccerPosition.lb:
      case SoccerPosition.rb:
      case SoccerPosition.lwb:
      case SoccerPosition.rwb:
        return 'Defender';
      case SoccerPosition.cdm:
      case SoccerPosition.cm:
      case SoccerPosition.cam:
      case SoccerPosition.lm:
      case SoccerPosition.rm:
        return 'Midfielder';
      case SoccerPosition.lw:
      case SoccerPosition.rw:
      case SoccerPosition.st:
      case SoccerPosition.cf:
        return 'Forward';
    }
  }
  
  /// Get positions by category
  static List<SoccerPosition> getPositionsByCategory(String category) {
    return SoccerPosition.values.where((pos) => pos.category == category).toList();
  }
}

/// Division level enumeration
enum DivisionLevel {
  divisionI('Division I'),
  divisionII('Division II'),
  divisionIII('Division III'),
  naia('NAIA'),
  juniorCollege('Junior College'),
  communityCollege('Community College');

  const DivisionLevel(this.displayName);
  
  final String displayName;
}