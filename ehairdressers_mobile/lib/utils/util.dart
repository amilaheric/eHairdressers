import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class Authorization {
  static String? username;
  static String? password;
  static int currentUserId = 1;
  static String? userRole;
  static String? userEmail;
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
