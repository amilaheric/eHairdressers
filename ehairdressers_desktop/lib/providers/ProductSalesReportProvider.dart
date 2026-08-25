import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ehairdressers_mobile/providers/BaseProvider.dart';
import '../models/product_sales_report.dart';

class ProductSalesReportProvider extends BaseProvider<ProductSalesReport> {
  ProductSalesReportProvider() : super("api/ProductSalesReport/ProductSalesReport");

  @override
  ProductSalesReport fromJson(data) {
    return ProductSalesReport.fromJson(data);
  }

  Future<List<ProductSalesReport>> _getReportData(DateTime startDate, DateTime endDate, String reportType) async {
    var url = "${baseUrl}api/ProductSalesReport/ProductSalesReport";
    var queryParams = {
      'startDate': startDate.toIso8601String().split('T')[0],
      'endDate': endDate.toIso8601String().split('T')[0],
      'reportType': reportType,
    };
    
    var uri = Uri.parse(url).replace(queryParameters: queryParams);
    var headers = createHeaders();
    
    try {
      var response = await http.get(uri, headers: headers);
      
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        
        if (data['success'] == true && data['data'] != null) {
          var reportData = <ProductSalesReport>[];
          for (var item in data['data']) {
            try {
              var parsedItem = fromJson(item);
              reportData.add(parsedItem);
            } catch (e) {
              
            }
          }
          return reportData;
        } else {
          return [];
        }
      } else {
        throw Exception("API call failed");
      }
    } catch (e) {
      throw e;
    }
  }

  Future<List<ProductSalesReport>> generateSalesReport(DateTime startDate, DateTime endDate) async {
    return await _getReportData(startDate, endDate, 'sales');
  }

  Future<List<ProductSalesReport>> generateRevenueReport(DateTime startDate, DateTime endDate) async {
    return await _getReportData(startDate, endDate, 'revenue');
  }

  Future<List<ProductSalesReport>> generateFrequencyReport(DateTime startDate, DateTime endDate) async {
    return await _getReportData(startDate, endDate, 'frequency');
  }
}
