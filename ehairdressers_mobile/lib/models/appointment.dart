import 'package:json_annotation/json_annotation.dart';

part 'appointment.g.dart';

@JsonSerializable()
class Appointment {
  int? id;
  String? date;
  String? time;
  String? employee;
  String? service;
  int? serviceId;
  int? employeeId;

  Appointment(this.id, this.date, this.time, this.employee, this.service,
      this.employeeId, this.serviceId);

  factory Appointment.fromJson(Map<String, dynamic> json) =>
      _$AppointmentFromJson(json);

  Map<String, dynamic> toJson() => _$AppointmentToJson(this);
}
