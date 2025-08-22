import 'package:json_annotation/json_annotation.dart';
part 'user.g.dart';

@JsonSerializable()
class User {
  @JsonKey(name: 'UserId')
  int? userId;
  
  @JsonKey(name: 'Name')
  String? name;
  
  @JsonKey(name: 'Surname')
  String? surname;
  
  @JsonKey(name: 'Email')
  String? email;
  
  @JsonKey(name: 'Phone')
  String? phone;
  
  @JsonKey(name: 'Username')
  String? username;
  
  @JsonKey(name: 'Password')
  String? password;
  
  @JsonKey(name: 'PasswordConfirm')
  String? passwordconfirm;
  
  @JsonKey(name: 'Image')
  String? image;
  
  @JsonKey(name: 'ImageThumb')
  String? imageThumb;
  
  @JsonKey(name: 'CitizenshipNumber')
  String? citizenshipnumber;
  
  @JsonKey(name: 'BirthDate')
  String? birthDate;
  
  @JsonKey(name: 'Address')
  String? address;
  
  @JsonKey(name: 'Status')
  bool? status;
  
  @JsonKey(name: 'UserRoles')
  List<dynamic>? userRoles;

  User({
    this.userId,
    this.name,
    this.surname,
    this.email,
    this.phone,
    this.username,
    this.password,
    this.passwordconfirm,
    this.image,
    this.imageThumb,
    this.citizenshipnumber,
    this.birthDate,
    this.address,
    this.status,
    this.userRoles,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
