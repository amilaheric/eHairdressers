import 'package:json_annotation/json_annotation.dart';

part 'appointment.g.dart';

@JsonSerializable()
class Appointment {
  @JsonKey(name: 'AppointmentId')
  int? appointmentId;
  
  @JsonKey(name: 'EmployeeId')
  int? employeeId;
  
  @JsonKey(name: 'UserId')
  int? userId;
  
  @JsonKey(name: 'ServiceId')
  int? serviceId;
  
  @JsonKey(name: 'Comment')
  String? comment;
  
  @JsonKey(name: 'EmployeeName')
  String? employeeName;
  
  @JsonKey(name: 'Username')
  String? username;
  
  @JsonKey(name: 'ServiceName')
  String? serviceName;
  
  @JsonKey(name: 'AppointmentDate')
  String? appointmentDate;
  
  @JsonKey(name: 'AppointmentTime')
  String? appointmentTime;
  
  @JsonKey(name: 'Approved')
  bool? approved;

  Appointment(this.appointmentId, this.employeeId, this.userId, this.serviceId,
      this.comment, this.employeeName, this.username, this.serviceName, 
      this.appointmentDate, this.appointmentTime, this.approved);

  factory Appointment.fromJson(Map<String, dynamic> json) =>
      _$AppointmentFromJson(json);

  Map<String, dynamic> toJson() => _$AppointmentToJson(this);
}
