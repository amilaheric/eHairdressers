import 'package:json_annotation/json_annotation.dart';

part 'appointment_insert_request.g.dart';

@JsonSerializable()
class AppointmentInsertRequest {
  @JsonKey(name: 'EmployeeId')
  final int employeeId;

  @JsonKey(name: 'EmployeeName')
  final String employeeName;

  @JsonKey(name: 'UserId')
  final int userId;

  @JsonKey(name: 'Username')
  final String username;

  @JsonKey(name: 'ServiceId')
  final int serviceId;

  @JsonKey(name: 'ServiceName')
  final String serviceName;

  @JsonKey(name: 'AppointmentDate')
  final String appointmentDate;

  @JsonKey(name: 'AppointmentTime')
  final String appointmentTime;

  AppointmentInsertRequest({
    required this.employeeId,
    required this.employeeName,
    required this.userId,
    required this.username,
    required this.serviceId,
    required this.serviceName,
    required this.appointmentDate,
    required this.appointmentTime,
  });

  factory AppointmentInsertRequest.fromJson(Map<String, dynamic> json) =>
      _$AppointmentInsertRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AppointmentInsertRequestToJson(this);
}
