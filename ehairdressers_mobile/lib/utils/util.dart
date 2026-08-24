import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class Authorization {
  // JWT bearer token returned by POST /User/login. Sent as
  // "Authorization: Bearer {token}" on every request (see base_provider.dart).
  // Raw username/password are never stored or resent after login.
  static String? token;
  static String? username;
  static int currentUserId = 1;
  static String? userRole;
  static List<String> roles = [];
  static String? userEmail;

  static bool get isLoggedIn => token != null && token!.isNotEmpty;

  static void clear() {
    token = null;
    username = null;
    currentUserId = 1;
    userRole = null;
    roles = [];
    userEmail = null;
  }
}

class StripeConfig {
  static const String publishableKey = String.fromEnvironment(
    'stripePublishableKey',
    defaultValue:
        'pk_test_51Sr3Jf0k64PF14h3oacyXOmu3I1DKD55HReDZqNRiKaCzUaS20NdVOHNPDnOo9bTYIKDBtjxKce8xeIU2b2B6LYo007KlJJ2UP',
  );
}

Image imageFromBase64String(String base64String) {
  return Image.memory(base64Decode(base64String));
}

String base64String(Uint8List data) {
  return base64Encode(data);
}

String formatNumber(dynamic) {
  var f = NumberFormat('###,00');
  if (dynamic == null) {
    return "";
  }

  return f.format(dynamic);
}
