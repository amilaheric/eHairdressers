// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      (json['userid'] as num?)?.toInt(),
      json['name'] as String?,
      json['surname'] as String?,
      json['email'] as String?,
      json['phone'] as String?,
      json['username'] as String?,
      json['password'] as String?,
      json['passwordconfirm'] as String?,
      json['image'] as String?,
      json['citizenshipnumber'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'userid': instance.userid,
      'name': instance.name,
      'surname': instance.surname,
      'email': instance.email,
      'phone': instance.phone,
      'username': instance.username,
      'password': instance.password,
      'passwordconfirm': instance.passwordconfirm,
      'image': instance.image,
      'citizenshipnumber': instance.citizenshipnumber,
    };
