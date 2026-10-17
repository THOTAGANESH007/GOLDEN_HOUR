import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_hour/core/errors/error_handler.dart';
import 'package:golden_hour/shared/widgets/empty_state_widget.dart';
import 'package:golden_hour/shared/widgets/error_view_widget.dart';
import 'package:golden_hour/shared/widgets/golden_button.dart';
import 'package:golden_hour/shared/widgets/loading_indicator.dart';
import 'package:golden_hour/shared/widgets/status_pill.dart';

void main() {
  group('Shared Widgets & UI Polish Tests', () {
    testWidgets('GoldenButton renders label, handles tap, and renders loading indicator',
        (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoldenButton(
              label: 'Save Changes',
              icon: Icons.check,
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Save Changes'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);

      await tester.tap(find.text('Save Changes'));
      expect(tapped, isTrue);

      // Loading state
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GoldenButton(
              label: 'Save Changes',
              isLoading: true,
              onPressed: null,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Save Changes'), findsNothing);
    });

    testWidgets('StatusPill renders label and icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusPill(
              label: 'DELIVERED',
              icon: Icons.sms_outlined,
              type: StatusPillType.success,
            ),
          ),
        ),
      );

      expect(find.text('DELIVERED'), findsOneWidget);
      expect(find.byIcon(Icons.sms_outlined), findsOneWidget);
    });

    testWidgets('EmptyStateWidget renders illustration, title, copy, and action button',
        (tester) async {
      bool buttonClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.folder_open_rounded,
              title: 'No Medical Records',
              description: 'Your uploaded prescriptions will appear here.',
              buttonLabel: 'Upload Now',
              buttonIcon: Icons.add,
              onButtonPressed: () => buttonClicked = true,
            ),
          ),
        ),
      );

      expect(find.text('No Medical Records'), findsOneWidget);
      expect(find.text('Your uploaded prescriptions will appear here.'), findsOneWidget);
      expect(find.byIcon(Icons.folder_open_rounded), findsOneWidget);
      expect(find.text('Upload Now'), findsOneWidget);

      await tester.tap(find.text('Upload Now'));
      expect(buttonClicked, isTrue);
    });

    testWidgets('ErrorViewWidget renders error message and handles retry',
        (tester) async {
      bool retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorViewWidget(
              title: 'Connection Lost',
              message: 'Check your internet connection and retry.',
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      expect(find.text('Connection Lost'), findsOneWidget);
      expect(find.text('Check your internet connection and retry.'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      await tester.tap(find.text('Try Again'));
      expect(retried, isTrue);
    });

    testWidgets('GoldenLoadingIndicator renders spinner and optional message',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GoldenLoadingIndicator(
              message: 'Encrypting trauma records...',
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Encrypting trauma records...'), findsOneWidget);
    });

    test('AppErrorHandler translates system errors to human-friendly copy', () {
      const socketError = SocketException('Connection reset by peer');
      expect(
        AppErrorHandler.getUserFriendlyMessage(socketError),
        'No internet connection detected. Please connect to the internet.',
      );

      final timeoutDio = DioException(
        requestOptions: RequestOptions(path: '/profile'),
        type: DioExceptionType.connectionTimeout,
      );
      expect(
        AppErrorHandler.getUserFriendlyMessage(timeoutDio),
        contains('timed out'),
      );

      final unauthorizedDio = DioException(
        requestOptions: RequestOptions(path: '/profile'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/profile'),
          statusCode: 401,
        ),
      );
      expect(
        AppErrorHandler.getUserFriendlyMessage(unauthorizedDio),
        'Your session has expired. Please verify your phone number again.',
      );
    });
  });
}
