import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recruitu_app/main.dart';
import 'package:recruitu_app/core/themes/app_theme.dart';
import 'package:recruitu_app/core/navigation/app_router.dart';

void main() {
  group('RecruitU App Tests', () {
    testWidgets('Welcome screen loads correctly', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        MaterialApp(
          theme: RecruitUTheme.lightTheme,
          home: const WelcomeScreen(),
        ),
      );

      // Verify that welcome text is displayed
      expect(find.text('Welcome to RecruitU'), findsOneWidget);
      expect(find.text('College Soccer Player-Coach Matching Platform'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('Already have an account?'), findsOneWidget);
    });

    testWidgets('Get Started button navigates to login', (WidgetTester tester) async {
      // Build the welcome screen
      await tester.pumpWidget(
        MaterialApp(
          theme: RecruitUTheme.lightTheme,
          home: const WelcomeScreen(),
        ),
      );

      // Tap the Get Started button
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // Verify that we navigated to login screen
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign in to your RecruitU account'), findsOneWidget);
    });

    testWidgets('Error app displays error message', (WidgetTester tester) async {
      const errorMessage = 'Test error message';
      
      // Build the error app
      await tester.pumpWidget(const ErrorApp(error: errorMessage));

      // Verify that error message is displayed
      expect(find.text('Failed to start RecruitU'), findsOneWidget);
      expect(find.text('Error: $errorMessage'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}