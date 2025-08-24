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
    String username = Authorization.username ?? "";
    String password = Authorization.password ?? "";
    String basicAuth =
        "Basic ${base64Encode(utf8.encode('$username:$password'))}";

    var headers = {
      "Content-Type": "application/json",
      "Authorization": basicAuth
    };

    return headers;
  }

  static bool _isValidResponse(http.Response response) {
    if (response.statusCode < 299) {
      return true;
    } else if (response.statusCode == 401) {
      throw Exception("Unauthorized");
    } else {
      throw Exception("Something bad happened please try again");
    }
  }

  static Future<dynamic> createEmployee(Map<String, dynamic> employeeData, String endpoint) async {
    try {
      var url = "$baseUrl$endpoint";
      var uri = Uri.parse(url);
      var headers = _createHeaders();

      var jsonRequest = jsonEncode(employeeData);
      var response = await http.post(uri, headers: headers, body: jsonRequest);

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
      // Send data directly to the CreateEmployee endpoint in the exact format specified
      var employeeData = {
        'Name': request['name'],
        'Surname': request['surname'],
        'Email': request['email'],
        'BirthDate': request['birthDate'] ?? request['hireDate'] ?? DateTime.now().toIso8601String(),
        'Address': request['address'] ?? '',
        'CitizenshipNumber': request['citizenshipNumber'],
        'Phone': request['phone'],
        'Username': request['username'],
        'Password': request['password'],
        'Image': request['image'] ?? 'string', // Send as string like in product insert
        'Salary': request['salary'] != null ? int.tryParse(request['salary'].toString()) ?? 0 : 0,
      };
      
      // Use only the CreateEmployee endpoint - it handles everything
      var employee = await createEmployee(employeeData, endpoint);
      return employee;
    } catch (e) {
      throw Exception('Failed to create complete employee: $e');
    }
  }
}
