// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'salon_operations_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SalonOperationsReport _$SalonOperationsReportFromJson(
        Map<String, dynamic> json) =>
    SalonOperationsReport(
      reportId: (json['ReportId'] as num?)?.toInt(),
      reportDate: json['ReportDate'] == null
          ? null
          : DateTime.parse(json['ReportDate'] as String),
      totalCustomers: (json['TotalCustomers'] as num?)?.toInt(),
      newCustomers: (json['NewCustomers'] as num?)?.toInt(),
      totalAppointments: (json['TotalAppointments'] as num?)?.toInt(),
      reportPeriod: json['ReportPeriod'] as String?,
      startDate: json['StartDate'] == null
          ? null
          : DateTime.parse(json['StartDate'] as String),
      endDate: json['EndDate'] == null
          ? null
          : DateTime.parse(json['EndDate'] as String),
      dailyOperations: json['DailyOperations'] as List<dynamic>?,
      servicePerformance: json['ServicePerformance'] as List<dynamic>?,
    );

Map<String, dynamic> _$SalonOperationsReportToJson(
        SalonOperationsReport instance) =>
    <String, dynamic>{
      'ReportId': instance.reportId,
      'ReportDate': instance.reportDate?.toIso8601String(),
      'TotalCustomers': instance.totalCustomers,
      'NewCustomers': instance.newCustomers,
      'TotalAppointments': instance.totalAppointments,
      'ReportPeriod': instance.reportPeriod,
      'StartDate': instance.startDate?.toIso8601String(),
      'EndDate': instance.endDate?.toIso8601String(),
      'DailyOperations': instance.dailyOperations,
      'ServicePerformance': instance.servicePerformance,
    };

SalonReportRequest _$SalonReportRequestFromJson(Map<String, dynamic> json) =>
    SalonReportRequest(
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      reportType: json['reportType'] as String,
    );

Map<String, dynamic> _$SalonReportRequestToJson(SalonReportRequest instance) =>
    <String, dynamic>{
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'reportType': instance.reportType,
    };

SalonReportResponse _$SalonReportResponseFromJson(Map<String, dynamic> json) =>
    SalonReportResponse(
      success: json['success'] as bool?,
      data: json['data'] == null
          ? null
          : SalonOperationsReport.fromJson(
              json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SalonReportResponseToJson(
        SalonReportResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data,
    };
