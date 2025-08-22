import 'package:json_annotation/json_annotation.dart';

part 'product_sales_report.g.dart';

@JsonSerializable()
class ProductSalesReport {
  @JsonKey(name: 'ProductId')
  int? productId;
  
  @JsonKey(name: 'ProductName')
  String? productName;
  
  @JsonKey(name: 'ProductCode')
  String? productCode;
  
  @JsonKey(name: 'TotalQuantitySold')
  int? quantitySold;
  
  @JsonKey(name: 'TotalRevenue')
  double? totalRevenue;
  
  @JsonKey(name: 'SalesFrequency')
  int? orderCount;
  
  @JsonKey(name: 'AveragePrice')
  double? averagePrice;
  
  @JsonKey(name: 'ReportStartDate')
  DateTime? startDate;
  
  @JsonKey(name: 'ReportEndDate')
  DateTime? endDate;
  
  @JsonKey(name: 'ReportType')
  String? reportType;

  ProductSalesReport({
    this.productId,
    this.productName,
    this.productCode,
    this.quantitySold,
    this.totalRevenue,
    this.orderCount,
    this.averagePrice,
    this.startDate,
    this.endDate,
    this.reportType,
  });

  factory ProductSalesReport.fromJson(Map<String, dynamic> json) => _$ProductSalesReportFromJson(json);
  Map<String, dynamic> toJson() => _$ProductSalesReportToJson(this);
}

@JsonSerializable()
class SalesReportRequest {
  @JsonKey(name: 'startDate')
  DateTime startDate;
  
  @JsonKey(name: 'endDate')
  DateTime endDate;
  
  @JsonKey(name: 'reportType')
  String reportType; // 'sales', 'revenue', 'frequency'

  SalesReportRequest({
    required this.startDate,
    required this.endDate,
    required this.reportType,
  });

  factory SalesReportRequest.fromJson(Map<String, dynamic> json) => _$SalesReportRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SalesReportRequestToJson(this);
}

@JsonSerializable()
class SalesReportResponse {
  @JsonKey(name: 'success')
  bool? success;
  
  @JsonKey(name: 'data')
  List<ProductSalesReport>? data;

  SalesReportResponse({
    this.success,
    this.data,
  });

  factory SalesReportResponse.fromJson(Map<String, dynamic> json) => _$SalesReportResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SalesReportResponseToJson(this);
}
