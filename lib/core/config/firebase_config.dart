import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Firebase configuration for RecruitU
class FirebaseConfig {
  /// Get Firebase options from environment variables with fallbacks
  static FirebaseOptions get currentPlatform {
    final apiKey = dotenv.env['FIREBASE_API_KEY'] ?? 'AIzaSyDjA8yB2P72i4dGPQH3DYwXGlSGIx6okuU';
    final authDomain = dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? 'recruitu-social.firebaseapp.com';
    final projectId = dotenv.env['FIREBASE_PROJECT_ID'] ?? 'recruitu-social';
    final storageBucket = dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? 'recruitu-social.firebasestorage.app';
    final messagingSenderId = dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '636135738196';
    final appId = dotenv.env['FIREBASE_APP_ID'] ?? '1:636135738196:web:8bb8199bd9ac6cf01f56c1';
    final measurementId = dotenv.env['FIREBASE_MEASUREMENT_ID'] ?? 'G-79BMV19KHW';

    return FirebaseOptions(
      apiKey: apiKey,
      authDomain: authDomain,
      projectId: projectId,
      storageBucket: storageBucket,
      messagingSenderId: messagingSenderId,
      appId: appId,
      measurementId: measurementId,
    );
  }

  /// Initialize Firebase with configuration
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: currentPlatform,
    );
  }
}