import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:expense_tracker/firebase_options.dart';

void main() {
  group('Firebase & Database Integration Tests', () {
    setUp(() {
      dotenv.testLoad(fileInput: '''
FIREBASE_PROJECT_ID=expense-tracker-flyrankai
FIREBASE_MESSAGING_SENDER_ID=1234567890
FIREBASE_STORAGE_BUCKET=expense-tracker-flyrankai.appspot.com
FIREBASE_WEB_API_KEY=test_web_api_key_123
FIREBASE_WEB_APP_ID=1:1234567890:web:abcdef123456
FIREBASE_WEB_AUTH_DOMAIN=expense-tracker-flyrankai.firebaseapp.com
FIREBASE_ANDROID_API_KEY=test_android_api_key_123
FIREBASE_ANDROID_APP_ID=1:1234567890:android:abcdef123456
FIREBASE_IOS_API_KEY=test_ios_api_key_123
FIREBASE_IOS_APP_ID=1:1234567890:ios:abcdef123456
FIREBASE_IOS_BUNDLE_ID=com.example.expenseTracker
''');
    });

    test('DefaultFirebaseOptions reads options from loaded .env configuration', () {
      final webOptions = DefaultFirebaseOptions.web;
      expect(webOptions.projectId, equals('expense-tracker-flyrankai'));
      expect(webOptions.apiKey, equals('test_web_api_key_123'));

      final androidOptions = DefaultFirebaseOptions.android;
      expect(androidOptions.projectId, equals('expense-tracker-flyrankai'));
      expect(androidOptions.apiKey, equals('test_android_api_key_123'));
    });

    test('DefaultFirebaseOptions throws descriptive StateError if a key is missing', () {
      dotenv.testLoad(fileInput: 'FIREBASE_PROJECT_ID=expense-tracker-flyrankai');

      expect(
        () => DefaultFirebaseOptions.web,
        throwsA(isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('Missing required environment variable'),
        )),
      );
    });

    test('firestore.rules exists and defines isolated security rules', () {
      final rulesFile = File('firestore.rules');
      expect(rulesFile.existsSync(), isTrue, reason: 'firestore.rules must exist');

      final content = rulesFile.readAsStringSync();

      expect(content, contains('rules_version = \'2\';'));
      expect(content, contains('isAuthenticated()'));
      expect(content, contains('isOwner(userId)'));
      expect(content, contains('isValidExpense('));
      expect(content, contains('match /users/{userId}/expenses/{expenseId}'));
      expect(content, contains('allow read: if isOwner(userId);'));
      expect(content, contains('allow create: if isOwner(userId)'));
    });
  });
}
