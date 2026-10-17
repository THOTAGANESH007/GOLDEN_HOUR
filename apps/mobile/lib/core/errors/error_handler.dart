import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppErrorHandler {
  static String getUserFriendlyMessage(dynamic error) {
    if (error == null) return 'An unexpected error occurred. Please try again.';

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'The connection timed out. Please check your network and try again.';
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final data = error.response?.data;
          if (data is Map<String, dynamic> && data['detail'] != null) {
            return data['detail'].toString();
          }
          if (statusCode == 401) {
            return 'Your session has expired. Please verify your phone number again.';
          } else if (statusCode == 403) {
            return 'You do not have permission to perform this action.';
          } else if (statusCode == 404) {
            return 'Requested information was not found.';
          } else if (statusCode != null && statusCode >= 500) {
            return 'Golden Hour emergency servers are currently undergoing maintenance. Please retry in a moment.';
          }
          return 'Service request failed ($statusCode). Please try again.';
        case DioExceptionType.connectionError:
          return 'Unable to connect to Golden Hour. Please verify your mobile data or Wi-Fi connection.';
        case DioExceptionType.cancel:
          return 'The operation was cancelled.';
        default:
          return 'Network communication error. Please check your internet connection.';
      }
    }

    if (error is SocketException) {
      return 'No internet connection detected. Please connect to the internet.';
    }

    final message = error.toString().replaceAll('Exception: ', '').trim();
    if (message.isNotEmpty && !message.contains('Instance of')) {
      return message;
    }

    return 'Something went wrong. Please try again.';
  }
}

class AppFeedback {
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  static void showError(BuildContext context, dynamic error) {
    final friendlyMessage = AppErrorHandler.getUserFriendlyMessage(error);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(friendlyMessage)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
