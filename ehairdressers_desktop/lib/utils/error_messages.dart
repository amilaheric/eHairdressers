import 'package:flutter/material.dart';

class ErrorMessages {
  static String extractMessage(Object error) {
    final raw = error.toString();

    final parts = raw
        .split('Exception: ')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
    var message = parts.isNotEmpty ? parts.last : raw.trim();

    message = message.replaceAll(RegExp(r'^(Failed to [^:]+:\s*)+'), '').trim();

    return _friendly(message);
  }

  static String _friendly(String message) {
    if (message.isEmpty) {
      return 'Something went wrong. Please try again.';
    }

    final lower = message.toLowerCase();

    if (lower.contains('citizenship number already exists')) {
      return 'This citizenship number is already registered to another employee. Please double-check the number and try again.';
    }
    if (lower.contains('username already exists')) {
      return 'This username is already taken. Please choose a different one.';
    }
    if (lower.contains('email already exists') ||
        lower.contains('email already registered')) {
      return 'This email address is already registered to another account.';
    }
    if (lower.contains('code already exists')) {
      return 'This product code is already in use. Please choose a different one.';
    }
    if (lower == 'unauthorized' || lower.contains('unauthorized')) {
      return 'You are not authorized to do this. Please log in again.';
    }
    if (lower.contains('failed host lookup') ||
        lower.contains('socketexception') ||
        lower.contains('connection refused')) {
      return 'Could not reach the server. Please check your connection and try again.';
    }

    var polished = message[0].toUpperCase() + message.substring(1);
    if (!polished.endsWith('.') &&
        !polished.endsWith('!') &&
        !polished.endsWith('?')) {
      polished += '.';
    }
    return polished;
  }

  static void show(BuildContext context, Object error,
      {String title = 'Error'}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(extractMessage(error)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
