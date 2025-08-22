import 'package:json_annotation/json_annotation.dart';

part 'salon_operations_report.g.dart';

@JsonSerializable()
class SalonOperationsReport {
  @JsonKey(name: 'ReportId')
  int? reportId;
  
  @JsonKey(name: 'ReportDate')
  DateTime? reportDate;
  
  @JsonKey(name: 'TotalCustomers')
  int? totalCustomers;
  
  @JsonKey(name: 'NewCustomers')
  int? newCustomers;
  
  @JsonKey(name: 'ReturningCustomers')
  int? returningCustomers;
  
  @JsonKey(name: 'TotalRevenue')
  double? totalRevenue;
  
  @JsonKey(name: 'CompletedAppointments')
  int? completedAppointments;
  
  @JsonKey(name: 'CancelledAppointments')
  int? cancelledAppointments;
  
  @JsonKey(name: 'NoShowAppointments')
  int? noShowAppointments;
  
  @JsonKey(name: 'AverageAppointmentValue')
  double? averageAppointmentValue;
  
  @JsonKey(name: 'TotalAppointments')
  int? totalAppointments;
  
  @JsonKey(name: 'ReportPeriod')
  String? reportPeriod; // 'daily', 'weekly', 'monthly', 'yearly'
  
  @JsonKey(name: 'StartDate')
  DateTime? startDate;
  
  @JsonKey(name: 'EndDate')
  DateTime? endDate;

  // Additional fields that might be in the API response
  @JsonKey(name: 'DailyOperations')
  List<dynamic>? dailyOperations;
  
  @JsonKey(name: 'ServicePerformance')
  List<dynamic>? servicePerformance;

  SalonOperationsReport({
    this.reportId,
    this.reportDate,
    this.totalCustomers,
    this.newCustomers,
    this.returningCustomers,
    this.totalRevenue,
    this.completedAppointments,
    this.cancelledAppointments,
    this.noShowAppointments,
    this.averageAppointmentValue,
    this.totalAppointments,
    this.reportPeriod,
    this.startDate,
    this.endDate,
    this.dailyOperations,
    this.servicePerformance,
  });

  factory SalonOperationsReport.fromJson(Map<String, dynamic> json) => _$SalonOperationsReportFromJson(json);
  Map<String, dynamic> toJson() => _$SalonOperationsReportToJson(this);
}

@JsonSerializable()
class SalonReportRequest {
  @JsonKey(name: 'startDate')
  DateTime startDate;
  
  @JsonKey(name: 'endDate')
  DateTime endDate;
  
  @JsonKey(name: 'reportType')
  String reportType; // 'operations', 'customer', 'revenue', 'appointments'

  SalonReportRequest({
    required this.startDate,
    required this.endDate,
    required this.reportType,
  });

  factory SalonReportRequest.fromJson(Map<String, dynamic> json) => _$SalonReportRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SalonReportRequestToJson(this);
}

@JsonSerializable()
class SalonReportResponse {
  @JsonKey(name: 'success')
  bool? success;
  
  @JsonKey(name: 'data')
  SalonOperationsReport? data;

  SalonReportResponse({
    this.success,
    this.data,
  });

  factory SalonReportResponse.fromJson(Map<String, dynamic> json) => _$SalonReportResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SalonReportResponseToJson(this);
}
