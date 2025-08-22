import 'package:json_annotation/json_annotation.dart';
part 'user.g.dart';

@JsonSerializable()
class User {
  int? userId;
  String? name;
  String? surname;
  String? email;
  String? phone;
  String? username;
  String? birthDate;
  String? address;
  String? citizenshipNumber;
  List<int>? image;
  List<int>? imageThumb;
  bool? status;
  List<UserRole>? userRoles;

  User({
    this.userId,
    this.name,
    this.surname,
    this.email,
    this.phone,
    this.username,
    this.birthDate,
    this.address,
    this.citizenshipNumber,
    this.image,
    this.imageThumb,
    this.status,
    this.userRoles,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class UserRole {
  int? userRoleId;
  int? userId;
  int? roleId;
  String? dateChange;
  Role? role;
  User? user;

  UserRole({
    this.userRoleId,
    this.userId,
    this.roleId,
    this.dateChange,
    this.role,
    this.user,
  });

  factory UserRole.fromJson(Map<String, dynamic> json) => _$UserRoleFromJson(json);

  Map<String, dynamic> toJson() => _$UserRoleToJson(this);
}

@JsonSerializable()
class Role {
  int? roleId;
  String? roleName;
  String? description;

  Role({
    this.roleId,
    this.roleName,
    this.description,
  });

  factory Role.fromJson(Map<String, dynamic> json) => _$RoleFromJson(json);

  Map<String, dynamic> toJson() => _$RoleToJson(this);
}
