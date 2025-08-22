import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ehairdressers_mobile/providers/BaseProvider.dart';
import '../models/employee.dart';
import '../services/database_service.dart';

class EmployeeProvider extends BaseProvider<Employee> {
  EmployeeProvider() : super("Employee");

  @override
  Employee fromJson(data) {
    return Employee.fromJson(data);
  }

  Future<Employee> createEmployeeWithRole(Map<String, dynamic> request) async {
    try {
      var result = await DatabaseService.createCompleteEmployee(request, "api/Employee/CreateEmployee");
      return fromJson(result);
    } catch (e) {
      throw Exception('Failed to create employee with role: $e');
    }
  }


  @override
  Future<Employee> insert(dynamic request) async {
    var url = "$endpoint/CreateEmployee";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var jsonRequest = jsonEncode(request);
    
    var response = await http.post(uri, headers: headers, body: jsonRequest);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Failed to create employee");
    }
  }
}
