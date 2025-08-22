// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Appointment _$AppointmentFromJson(Map<String, dynamic> json) => Appointment(
      (json['AppointmentId'] as num).toInt(),
      (json['EmployeeId'] as num).toInt(),
      json['EmployeeName'] as String?,
      (json['UserId'] as num).toInt(),
      json['Username'] as String?,
      (json['ServiceId'] as num).toInt(),
      json['ServiceName'] as String?,
      json['AppointmentDate'] as String,
      json['AppointmentTime'] as String,
      status: json['Status'] as String? ?? 'Scheduled',
      duration: (json['Duration'] as num?)?.toInt() ?? 60,
    );

Map<String, dynamic> _$AppointmentToJson(Appointment instance) =>
    <String, dynamic>{
      'AppointmentId': instance.id,
      'EmployeeId': instance.employeeId,
      'EmployeeName': instance.employeeName,
      'UserId': instance.userId,
      'Username': instance.username,
      'ServiceId': instance.serviceId,
      'ServiceName': instance.serviceName,
      'AppointmentDate': instance.appointmentDate,
      'AppointmentTime': instance.appointmentTime,
      'Status': instance.status,
      'Duration': instance.duration,
    };
