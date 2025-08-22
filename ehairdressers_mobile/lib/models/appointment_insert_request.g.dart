// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment_insert_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppointmentInsertRequest _$AppointmentInsertRequestFromJson(
        Map<String, dynamic> json) =>
    AppointmentInsertRequest(
      employeeId: (json['EmployeeId'] as num).toInt(),
      employeeName: json['EmployeeName'] as String,
      userId: (json['UserId'] as num).toInt(),
      username: json['Username'] as String,
      serviceId: (json['ServiceId'] as num).toInt(),
      serviceName: json['ServiceName'] as String,
      appointmentDate: json['AppointmentDate'] as String,
      appointmentTime: json['AppointmentTime'] as String,
    );

Map<String, dynamic> _$AppointmentInsertRequestToJson(
        AppointmentInsertRequest instance) =>
    <String, dynamic>{
      'EmployeeId': instance.employeeId,
      'EmployeeName': instance.employeeName,
      'UserId': instance.userId,
      'Username': instance.username,
      'ServiceId': instance.serviceId,
      'ServiceName': instance.serviceName,
      'AppointmentDate': instance.appointmentDate,
      'AppointmentTime': instance.appointmentTime,
    };
