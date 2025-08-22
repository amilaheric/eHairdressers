// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_sales_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductSalesReport _$ProductSalesReportFromJson(Map<String, dynamic> json) =>
    ProductSalesReport(
      productId: (json['ProductId'] as num?)?.toInt(),
      productName: json['ProductName'] as String?,
      productCode: json['ProductCode'] as String?,
      quantitySold: (json['TotalQuantitySold'] as num?)?.toInt(),
      totalRevenue: (json['TotalRevenue'] as num?)?.toDouble(),
      orderCount: (json['SalesFrequency'] as num?)?.toInt(),
      averagePrice: (json['AveragePrice'] as num?)?.toDouble(),
      startDate: json['ReportStartDate'] == null
          ? null
          : DateTime.parse(json['ReportStartDate'] as String),
      endDate: json['ReportEndDate'] == null
          ? null
          : DateTime.parse(json['ReportEndDate'] as String),
      reportType: json['ReportType'] as String?,
    );

Map<String, dynamic> _$ProductSalesReportToJson(ProductSalesReport instance) =>
    <String, dynamic>{
      'ProductId': instance.productId,
      'ProductName': instance.productName,
      'ProductCode': instance.productCode,
      'TotalQuantitySold': instance.quantitySold,
      'TotalRevenue': instance.totalRevenue,
      'SalesFrequency': instance.orderCount,
      'AveragePrice': instance.averagePrice,
      'ReportStartDate': instance.startDate?.toIso8601String(),
      'ReportEndDate': instance.endDate?.toIso8601String(),
      'ReportType': instance.reportType,
    };

SalesReportRequest _$SalesReportRequestFromJson(Map<String, dynamic> json) =>
    SalesReportRequest(
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      reportType: json['reportType'] as String,
    );

Map<String, dynamic> _$SalesReportRequestToJson(SalesReportRequest instance) =>
    <String, dynamic>{
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'reportType': instance.reportType,
    };

SalesReportResponse _$SalesReportResponseFromJson(Map<String, dynamic> json) =>
    SalesReportResponse(
      success: json['success'] as bool?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => ProductSalesReport.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SalesReportResponseToJson(
        SalesReportResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data,
    };
