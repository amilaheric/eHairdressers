import 'package:json_annotation/json_annotation.dart';

part 'appointment.g.dart';

@JsonSerializable()
class Appointment {
  int? appointmentId;
  int? employeeId;
  int? userId;
  int? serviceId;
  String? comment;
  String? employeeName;
  String? username;
  String? serviceName;

  Appointment(this.appointmentId, this.employeeId, this.userId, this.serviceId,
      this.comment, this.employeeName, this.username, this.serviceName);

  factory Appointment.fromJson(Map<String, dynamic> json) =>
      _$AppointmentFromJson(json);

  Map<String, dynamic> toJson() => _$AppointmentToJson(this);
}
