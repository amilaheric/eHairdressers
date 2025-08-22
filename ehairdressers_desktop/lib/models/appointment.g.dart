// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Appointment _$AppointmentFromJson(Map<String, dynamic> json) => Appointment(
      (json['AppointmentId'] as num?)?.toInt(),
      (json['EmployeeId'] as num?)?.toInt(),
      (json['UserId'] as num?)?.toInt(),
      (json['ServiceId'] as num?)?.toInt(),
      json['Comment'] as String?,
      json['EmployeeName'] as String?,
      json['Username'] as String?,
      json['ServiceName'] as String?,
      json['AppointmentDate'] as String?,
      json['AppointmentTime'] as String?,
      json['Approved'] as bool?,
    );

Map<String, dynamic> _$AppointmentToJson(Appointment instance) =>
    <String, dynamic>{
      'AppointmentId': instance.appointmentId,
      'EmployeeId': instance.employeeId,
      'UserId': instance.userId,
      'ServiceId': instance.serviceId,
      'Comment': instance.comment,
      'EmployeeName': instance.employeeName,
      'Username': instance.username,
      'ServiceName': instance.serviceName,
      'AppointmentDate': instance.appointmentDate,
      'AppointmentTime': instance.appointmentTime,
      'Approved': instance.approved,
    };
