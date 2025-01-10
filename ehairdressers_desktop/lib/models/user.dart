import 'dart:ffi';

import 'package:json_annotation/json_annotation.dart';
part 'user.g.dart';

@JsonSerializable()
class User {
  int? userid;
  String? name;
  String? surname;
  String? email;
  String? phone;
  String? username;
  String? password;
  String? passwordconfirm;
  String? image;
  String? citizenshipnumber;

  User(
      this.userid,
      this.name,
      this.surname,
      this.email,
      this.phone,
      this.username,
      this.password,
      this.passwordconfirm,
      this.image,
      this.citizenshipnumber);

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
