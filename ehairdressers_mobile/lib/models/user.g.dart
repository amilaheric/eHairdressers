// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      userId: (json['UserId'] as num?)?.toInt(),
      name: json['Name'] as String?,
      surname: json['Surname'] as String?,
      email: json['Email'] as String?,
      phone: json['Phone'] as String?,
      username: json['Username'] as String?,
      password: json['Password'] as String?,
      passwordconfirm: json['PasswordConfirm'] as String?,
      image: json['Image'] as String?,
      imageThumb: json['ImageThumb'] as String?,
      citizenshipnumber: json['CitizenshipNumber'] as String?,
      birthDate: json['BirthDate'] as String?,
      address: json['Address'] as String?,
      status: json['Status'] as bool?,
      userRoles: json['UserRoles'] as List<dynamic>?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'UserId': instance.userId,
      'Name': instance.name,
      'Surname': instance.surname,
      'Email': instance.email,
      'Phone': instance.phone,
      'Username': instance.username,
      'Password': instance.password,
      'PasswordConfirm': instance.passwordconfirm,
      'Image': instance.image,
      'ImageThumb': instance.imageThumb,
      'CitizenshipNumber': instance.citizenshipnumber,
      'BirthDate': instance.birthDate,
      'Address': instance.address,
      'Status': instance.status,
      'UserRoles': instance.userRoles,
    };
