import 'dart:convert';
import 'dart:io';
import 'package:ehairdressers_mobile/models/employees.dart';
import 'package:ehairdressers_mobile/models/search_result.dart';
import 'package:http/io_client.dart';
import 'package:ehairdressers_mobile/utils/util.dart';
import 'package:flutter/material.dart';

class EmployeesProvider extends ChangeNotifier {
  HttpClient client = new HttpClient();
  IOClient? http;

  EmployeesProvider() {
    client.badCertificateCallback = (cert, host, port) => true;
    http = IOClient(client);
  }

  // Get base API URL
  String get baseApiUrl {
    const String baseUrl = String.fromEnvironment("baseUrl", defaultValue: "http://10.0.2.2:7051/");
    return baseUrl.endsWith("/") ? baseUrl : "$baseUrl/";
  }

  Map<String, String> createHeaders() {
    String? username = Authorization.username;
    String? password = Authorization.password;

    if (username == null || password == null) {
      throw Exception("Authorization credentials not set. Please log in first.");
    }

    String basicAuth =
        "Basic ${base64Encode(utf8.encode('$username:$password'))}";

    var headers = {
      "Content-Type": "application/json",
      "Authorization": basicAuth
    };
    return headers;
  }

  Future<List<Employees>> getEmployees() async {
    try {
      var url = "${baseApiUrl}api/Employee";
      var uri = Uri.parse(url);
      Map<String, String> headers = createHeaders();

      print('DEBUG: Fetching employees from: $url');
      var response = await http!.get(uri, headers: headers);
      print('DEBUG: Employees response status: ${response.statusCode}');
      print('DEBUG: Employees response body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        print('DEBUG: Parsed employees data: $jsonData');
        
        if (jsonData is List) {
          return jsonData.map((item) => Employees.fromJson(item)).toList();
        } else if (jsonData is Map && jsonData['data'] != null) {
          return (jsonData['data'] as List).map((item) => Employees.fromJson(item)).toList();
        } else if (jsonData is Map && jsonData['Result'] != null) {
          return (jsonData['Result'] as List).map((item) => Employees.fromJson(item)).toList();
        } else if (jsonData is Map && jsonData['result'] != null) {
          return (jsonData['result'] as List).map((item) => Employees.fromJson(item)).toList();
        } else {
          print('DEBUG: No employees data found in response');
          print('DEBUG: Available keys: ${jsonData is Map ? jsonData.keys.toList() : 'Not a Map'}');
          return [];
        }
      } else {
        print('DEBUG: Error getting employees: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('DEBUG: Exception getting employees: $e');
      return [];
    }
  }

  Future<SearchResult<Employees>> getResult({dynamic filter}) async {
    try {
      var employees = await getEmployees();
      var result = SearchResult<Employees>();
      result.result = employees;
      result.count = employees.length;
      return result;
    } catch (e) {
      print('DEBUG: Exception in getResult: $e');
      var result = SearchResult<Employees>();
      result.result = [];
      result.count = 0;
      return result;
    }
  }
}
