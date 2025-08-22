// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employees.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Employees _$EmployeesFromJson(Map<String, dynamic> json) => Employees(
      (json['EmployeeId'] as num?)?.toInt(),
      json['Name'] as String?,
      json['Surname'] as String?,
    );

Map<String, dynamic> _$EmployeesToJson(Employees instance) => <String, dynamic>{
      'EmployeeId': instance.employeeId,
      'Name': instance.firstName,
      'Surname': instance.surname,
    };
