// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Employee _$EmployeeFromJson(Map<String, dynamic> json) => Employee(
      employeeId: (json['employeeId'] as num?)?.toInt(),
      userId: (json['userId'] as num?)?.toInt(),
      name: json['name'] as String?,
      surname: json['surname'] as String?,
      hireDate: json['hireDate'] as String?,
      birthDate: json['birthDate'] as String?,
      address: json['address'] as String?,
      citizenshipNumber: json['citizenshipNumber'] as String?,
      phone: json['phone'] as String?,
      salary: (json['salary'] as num?)?.toInt(),
    );

Map<String, dynamic> _$EmployeeToJson(Employee instance) => <String, dynamic>{
      'employeeId': instance.employeeId,
      'userId': instance.userId,
      'name': instance.name,
      'surname': instance.surname,
      'hireDate': instance.hireDate,
      'birthDate': instance.birthDate,
      'address': instance.address,
      'citizenshipNumber': instance.citizenshipNumber,
      'phone': instance.phone,
      'salary': instance.salary,
    };
