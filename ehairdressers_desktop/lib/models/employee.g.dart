// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Employee _$EmployeeFromJson(Map<String, dynamic> json) => Employee(
      employeeId: (json['EmployeeId'] as num?)?.toInt(),
      userId: (json['UserId'] as num?)?.toInt(),
      name: json['Name'] as String?,
      surname: json['Surname'] as String?,
      hireDate: json['HireDate'] as String?,
      birthDate: json['BirthDate'] as String?,
      address: json['Address'] as String?,
      citizenshipNumber: json['CitizenshipNumber'] as String?,
      phone: json['Phone'] as String?,
      salary: (json['Salary'] as num?)?.toInt(),
    );

Map<String, dynamic> _$EmployeeToJson(Employee instance) => <String, dynamic>{
      'EmployeeId': instance.employeeId,
      'UserId': instance.userId,
      'Name': instance.name,
      'Surname': instance.surname,
      'HireDate': instance.hireDate,
      'BirthDate': instance.birthDate,
      'Address': instance.address,
      'CitizenshipNumber': instance.citizenshipNumber,
      'Phone': instance.phone,
      'Salary': instance.salary,
    };
