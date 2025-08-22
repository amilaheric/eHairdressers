// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      userId: (json['userId'] as num?)?.toInt(),
      name: json['name'] as String?,
      surname: json['surname'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      username: json['username'] as String?,
      birthDate: json['birthDate'] as String?,
      address: json['address'] as String?,
      citizenshipNumber: json['citizenshipNumber'] as String?,
      image: (json['image'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      imageThumb: (json['imageThumb'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      status: json['status'] as bool?,
      userRoles: (json['userRoles'] as List<dynamic>?)
          ?.map((e) => UserRole.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'userId': instance.userId,
      'name': instance.name,
      'surname': instance.surname,
      'email': instance.email,
      'phone': instance.phone,
      'username': instance.username,
      'birthDate': instance.birthDate,
      'address': instance.address,
      'citizenshipNumber': instance.citizenshipNumber,
      'image': instance.image,
      'imageThumb': instance.imageThumb,
      'status': instance.status,
      'userRoles': instance.userRoles,
    };

UserRole _$UserRoleFromJson(Map<String, dynamic> json) => UserRole(
      userRoleId: (json['userRoleId'] as num?)?.toInt(),
      userId: (json['userId'] as num?)?.toInt(),
      roleId: (json['roleId'] as num?)?.toInt(),
      dateChange: json['dateChange'] as String?,
      role: json['role'] == null
          ? null
          : Role.fromJson(json['role'] as Map<String, dynamic>),
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserRoleToJson(UserRole instance) => <String, dynamic>{
      'userRoleId': instance.userRoleId,
      'userId': instance.userId,
      'roleId': instance.roleId,
      'dateChange': instance.dateChange,
      'role': instance.role,
      'user': instance.user,
    };

Role _$RoleFromJson(Map<String, dynamic> json) => Role(
      roleId: (json['roleId'] as num?)?.toInt(),
      roleName: json['roleName'] as String?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$RoleToJson(Role instance) => <String, dynamic>{
      'roleId': instance.roleId,
      'roleName': instance.roleName,
      'description': instance.description,
    };
