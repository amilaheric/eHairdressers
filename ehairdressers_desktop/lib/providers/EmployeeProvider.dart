import 'package:ehairdressers_mobile/providers/BaseProvider.dart';

import '../models/user.dart';

class EmployeeProvider extends BaseProvider<User> {
  EmployeeProvider() : super("User");

  @override
  User fromJson(data) {
    // TODO: implement fromJson
    return User.fromJson(data);
  }
}
