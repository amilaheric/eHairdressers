import 'dart:convert';
import 'package:ehairdressers_mobile/models/user.dart';
import 'package:ehairdressers_mobile/utils/util.dart';
import 'package:http/http.dart' as http;
import 'BaseProvider.dart';

class UserProvider extends BaseProvider<User> {
  UserProvider() : super("User");

  @override
  User fromJson(data) {
    return User.fromJson(data);
  }

  Future<bool> logout() async {
    var serverRevoked = false;

    try {
      final uri = Uri.parse('${baseUrl}User/logout');
      final response = await http.post(uri, headers: createHeaders());

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        serverRevoked = data['success'] == true;
      }
    } catch (_) {
    }

    Authorization.clear();
    return serverRevoked;
  }
}
