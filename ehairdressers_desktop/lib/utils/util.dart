class Authorization {
  static String? token;
  static String? username;
  static int currentUserId = 1;
  static String? userRole;
  static List<String> roles = [];

  static bool get isLoggedIn => token != null && token!.isNotEmpty;

  static void clear() {
    token = null;
    username = null;
    currentUserId = 1;
    userRole = null;
    roles = [];
  }
}
