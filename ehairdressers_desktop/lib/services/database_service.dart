import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/util.dart';

class DatabaseService {
  static String? _baseUrl;

  static String get baseUrl {
    _baseUrl ??= const String.fromEnvironment("baseUrl",
        defaultValue: "http://localhost:7051/");
    return _baseUrl!;
  }

  static Map<String, String> _createHeaders() {
    String token = Authorization.token ?? "";

    var headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    };

    return headers;
  }

  static bool _isValidResponse(http.Response response) {
    if (response.statusCode < 299) {
      return true;
    } else if (response.statusCode == 401) {
      throw Exception("Unauthorized");
    } else {
      throw Exception(_extractErrorMessage(response));
    }
  }

  static String _extractErrorMessage(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        if (decoded['message'] != null) {
          return decoded['message'].toString();
        }

        final validationMessages = <String>[];
        decoded.forEach((field, errors) {
          if (errors is List) {
            for (final e in errors) {
              validationMessages.add('$field: $e');
            }
          }
        });
        if (validationMessages.isNotEmpty) {
          return validationMessages.join('; ');
        }
      }
    } catch (_) {
    }

    if (response.body.isNotEmpty) {
      return 'Server error (${response.statusCode}): ${response.body}';
    }

    return 'Server error (${response.statusCode})';
  }

  static Future<dynamic> createEmployee(Map<String, dynamic> employeeData, String endpoint) async {
    try {
      var url = "$baseUrl$endpoint";
      var uri = Uri.parse(url);
      var headers = _createHeaders();

      var jsonRequest = jsonEncode(employeeData);
      
      // Debug logging - print what we're sending to the backend
      print("=== EMPLOYEE DATA BEING SENT TO BACKEND ===");
      print("URL: $url");
      print("Headers: $headers");
      print("Request Body: $jsonRequest");
      print("==========================================");
      
      var response = await http.post(uri, headers: headers, body: jsonRequest);

      // Debug logging - print response from backend
      print("=== BACKEND RESPONSE ===");
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");
      print("========================");

      if (_isValidResponse(response)) {
        var data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception("Failed to create employee");
      }
    } catch (e) {
      throw Exception('Failed to create employee: $e');
    }
  }

  static Future<dynamic> createCompleteEmployee(Map<String, dynamic> request, String endpoint) async {
    try {
      // Debug logging - print raw request data
      print("=== RAW REQUEST DATA FROM FORM ===");
      print("Raw request: $request");
      print("==================================");

      // Send data directly to the CreateEmployee endpoint in the exact format specified
      var employeeData = {
        'Name': request['name'],
        'Surname': request['surname'],
        'Email': request['email'],
        'BirthDate': request['birthDate'] ?? DateTime.now().toIso8601String().split('T')[0],
        'HireDate': request['hireDate'] ?? DateTime.now().toIso8601String().split('T')[0],
        'Address': request['address'] ?? '',
        'CitizenshipNumber': request['citizenshipNumber'],
        'Phone': request['phone'],
        'Username': request['username'],
        'Password': request['password'],
        'Image': request['image'] != null ? request['image'].split(',').last : '', // Remove data:image/jpeg;base64, prefix and send as base64 string
        'Salary': request['salary'] != null ? int.tryParse(request['salary'].toString()) ?? 0 : 0,
      };

      // Debug logging - print processed employee data
      print("=== PROCESSED EMPLOYEE DATA ===");
      print("Processed data: $employeeData");
      print("===============================");
      
      // Use only the CreateEmployee endpoint - it handles everything
      var employee = await createEmployee(employeeData, endpoint);
      return employee;
    } catch (e) {
      throw Exception('Failed to create complete employee: $e');
    }
  }
}
