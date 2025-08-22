import 'package:json_annotation/json_annotation.dart';

part 'appointment.g.dart';

@JsonSerializable()
class Appointment {
 @JsonKey(name: 'AppointmentId')
  final int id;

  @JsonKey(name: 'EmployeeId')
  final int employeeId;

  @JsonKey(name: 'EmployeeName')
  final String? employeeName;

  @JsonKey(name: 'UserId')
  final int userId;

  @JsonKey(name: 'Username')
  final String? username;

  @JsonKey(name: 'ServiceId')
  final int serviceId;

  @JsonKey(name: 'ServiceName')
  final String? serviceName;

  @JsonKey(name: 'AppointmentDate')
  final String appointmentDate;

  @JsonKey(name: 'AppointmentTime')
  final String appointmentTime;

  @JsonKey(name: 'Status')
  final String? status;

  @JsonKey(name: 'Duration')
  final int? duration;

  Appointment(
    this.id,
    this.employeeId,
    this.employeeName,
    this.userId,
    this.username,
    this.serviceId,
    this.serviceName,
    this.appointmentDate,
    this.appointmentTime, {
    this.status = 'Scheduled',
    this.duration = 60,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) =>
      _$AppointmentFromJson(json);

  Map<String, dynamic> toJson() => _$AppointmentToJson(this);
}
