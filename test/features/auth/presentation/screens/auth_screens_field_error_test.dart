import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laan_task/features/auth/presentation/auth_notifier.dart';
import 'package:laan_task/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:laan_task/features/auth/presentation/screens/sign_up_screen.dart';

class _FakeAuthNotifier extends AuthNotifier {
  @override
  AuthState build() {
    return const AuthState(isLoggedIn: false, isInitialized: true);
  }
}

void main() {
  group('SignInScreen Field Error Clearing & Keyboard Dismissal Tests', () {
    testWidgets('clears username and password field errors when user starts typing',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authNotifierProvider.overrideWith(_FakeAuthNotifier.new),
          ],
          child: const MaterialApp(
            home: SignInScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Sign In button with empty fields to trigger validation errors
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pump();

      expect(find.text('Username is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);

      // Start typing in the Username field
      final usernameField = find.byType(TextFormField).first;
      await tester.enterText(usernameField, 'm');
      await tester.pump();

      // Username error should be cleared immediately
      expect(find.text('Username is required'), findsNothing);
      // Password error remains since user has not typed in password yet
      expect(find.text('Password is required'), findsOneWidget);

      // Start typing in the Password field
      final passwordField = find.byType(TextFormField).last;
      await tester.enterText(passwordField, 'p');
      await tester.pump();

      // Password error should also be cleared immediately
      expect(find.text('Password is required'), findsNothing);
    });

    testWidgets('unfocuses keyboard when tapping Sign In button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authNotifierProvider.overrideWith(_FakeAuthNotifier.new),
          ],
          child: const MaterialApp(
            home: SignInScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Focus username field
      final usernameField = find.byType(TextFormField).first;
      await tester.tap(usernameField);
      await tester.pump();
      final usernameEditable = tester.widget<EditableText>(
        find.descendant(of: usernameField, matching: find.byType(EditableText)),
      );
      expect(usernameEditable.focusNode.hasFocus, isTrue);

      // Tap Sign In button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pump();

      // Keyboard / text field focus should be dismissed
      expect(usernameEditable.focusNode.hasFocus, isFalse);
    });
  });

  group('SignUpScreen Field Error Clearing & Keyboard Dismissal Tests', () {
    testWidgets('clears field errors when user starts typing in SignUpScreen',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authNotifierProvider.overrideWith(_FakeAuthNotifier.new),
          ],
          child: const MaterialApp(
            home: SignUpScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Create Account button with empty fields
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pump();

      expect(find.text('Username is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);

      // Type in Username
      final usernameField = find.byType(TextFormField).at(0);
      await tester.enterText(usernameField, 'alice');
      await tester.pump();

      expect(find.text('Username is required'), findsNothing);
      expect(find.text('Password is required'), findsOneWidget);

      // Type in Password
      final passwordField = find.byType(TextFormField).at(1);
      await tester.enterText(passwordField, 'secret123');
      await tester.pump();

      expect(find.text('Password is required'), findsNothing);

      // Tap Create Account again to trigger password mismatch error
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pump();

      expect(find.text('Passwords do not match'), findsOneWidget);

      // Type in Confirm Password
      final confirmField = find.byType(TextFormField).at(2);
      await tester.enterText(confirmField, 's');
      await tester.pump();

      // Error should clear as soon as typing begins
      expect(find.text('Passwords do not match'), findsNothing);
    });

    testWidgets('unfocuses keyboard when tapping Create Account button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authNotifierProvider.overrideWith(_FakeAuthNotifier.new),
          ],
          child: const MaterialApp(
            home: SignUpScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Focus username field
      final usernameField = find.byType(TextFormField).first;
      await tester.tap(usernameField);
      await tester.pump();
      final usernameEditable = tester.widget<EditableText>(
        find.descendant(of: usernameField, matching: find.byType(EditableText)),
      );
      expect(usernameEditable.focusNode.hasFocus, isTrue);

      // Tap Create Account button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pump();

      // Keyboard / text field focus should be dismissed
      expect(usernameEditable.focusNode.hasFocus, isFalse);
    });
  });
}
