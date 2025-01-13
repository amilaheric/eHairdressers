// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Appointment _$AppointmentFromJson(Map<String, dynamic> json) => Appointment(
      (json['id'] as num?)?.toInt(),
      json['date'] as String?,
      json['time'] as String?,
      json['employee'] as String?,
      json['service'] as String?,
      (json['employeeId'] as num?)?.toInt(),
      (json['serviceId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AppointmentToJson(Appointment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date,
      'time': instance.time,
      'employee': instance.employee,
      'service': instance.service,
      'serviceId': instance.serviceId,
      'employeeId': instance.employeeId,
    };
