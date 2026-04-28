import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

String _requiredEnv(String key) {
  final value = dotenv.env[key]?.trim();
  if (value == null || value.isEmpty) {
    throw StateError('Missing required Firebase env var: $key');
  }
  return value;
}

String? _optionalEnv(String key) {
  final value = dotenv.env[key]?.trim();
  if (value == null || value.isEmpty) {
    return null;
  }
  return value;
}

FirebaseOptions createFirebaseOptionsByEnv() {
  return FirebaseOptions(
    apiKey: _requiredEnv('FIREBASE_API_KEY'),
    appId: _requiredEnv('FIREBASE_APP_ID'),
    messagingSenderId: _requiredEnv('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: _requiredEnv('FIREBASE_PROJECT_ID'),
    authDomain: _optionalEnv('FIREBASE_AUTH_DOMAIN'),
    storageBucket: _optionalEnv('FIREBASE_STORAGE_BUCKET'),
    iosBundleId: _optionalEnv('FIREBASE_IOS_BUNDLE_ID'),
    measurementId: _optionalEnv('FIREBASE_MEASUREMENT_ID'),
    androidClientId: _optionalEnv('FIREBASE_ANDROID_CLIENT_ID'),
    iosClientId: _optionalEnv('FIREBASE_IOS_CLIENT_ID'),
    appGroupId: _optionalEnv('FIREBASE_APP_GROUP_ID'),
    databaseURL: _optionalEnv('FIREBASE_DATABASE_URL'),
    deepLinkURLScheme: _optionalEnv('FIREBASE_DEEP_LINK_URL_SCHEME'),
  );
}
