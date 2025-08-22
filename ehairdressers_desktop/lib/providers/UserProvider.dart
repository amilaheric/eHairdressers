import 'package:ehairdressers_mobile/models/user.dart';
import 'BaseProvider.dart';

class UserProvider extends BaseProvider<User> {
  UserProvider() : super("User");

  @override
  User fromJson(data) {
    return User.fromJson(data);
  }
}
