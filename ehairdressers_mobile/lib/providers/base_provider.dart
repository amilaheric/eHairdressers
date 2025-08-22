import 'dart:convert';
import 'dart:io';

import 'package:ehairdressers_mobile/models/search_result.dart';
import 'package:ehairdressers_mobile/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';

abstract class BaseProvider<T> with ChangeNotifier {
  static String? _baseUrl;
  String? _endpoint;

  HttpClient client = new HttpClient();
  IOClient? http;

  BaseProvider(String endpoint) {
    _baseUrl = const String.fromEnvironment("baseUrl",
        defaultValue: "https://10.0.2.2:7051/");


    if (_baseUrl!.endsWith("/") == false) {
      _baseUrl = _baseUrl! + "/";
    }

    _endpoint = endpoint;
    client.badCertificateCallback = (cert, host, port) => true;
    http = IOClient(client);
  }

  Future<List<T>> getById(int id, [dynamic additionalData]) async {
    var url = Uri.parse("$_baseUrl$_endpoint/$id");

    Map<String, String> headers = createHeaders();

    var response = await http!.get(url, headers: headers);

    if (isValidResponseCode(response)) {
      var data = jsonDecode(response.body);
      return data.map((x) => fromJson(x)).cast<T>().toList();
    } else {
      throw Exception("Exception... handle this gracefully");
    }
  }

  Future<List<TimeOfDay>> getTime(String date, [dynamic additionalData]) async {
    var url = Uri.parse("$_baseUrl$_endpoint/available-times?date=${date}");

    Map<String, String> headers = createHeaders();

    var response = await http!.get(url, headers: headers);
    if (isValidResponseCode(response)) {
      var data = jsonDecode(response.body) as List<dynamic>;
      return data.map((timeSpan) => _convertToTimeOfDay(timeSpan)).toList();
    } else {
      throw Exception("Exception... handle this gracefully");
    }
  }

  TimeOfDay _convertToTimeOfDay(String timeSpan) {
    var parts = timeSpan.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Future<List<T>> get([dynamic search]) async {
    var url = "$_baseUrl$_endpoint";

    if (search != null) {
      String queryString = getQueryString(search);
      url = url + "?" + queryString;
    }

    var uri = Uri.parse(url);

    Map<String, String> headers = createHeaders();

    var response = await http!.get(uri, headers: headers);
    if (isValidResponseCode(response)) {
      var data = jsonDecode(response.body);
      
      // Check if data and data['Result'] or data['result'] exist before calling map
      var resultData = data?['Result'] ?? data?['result'];
      if (data != null && resultData != null) {
        return resultData.map((x) => fromJson(x)).cast<T>().toList();
      } else {
        print("Warning: data['Result'] and data['result'] are both null in get method");
        print("Available keys: ${data?.keys.toList()}");
        return <T>[]; // Return empty list instead of crashing
      }
    } else {
      throw Exception("Exception... handle this gracefully");
    }
  }

  Future<SearchResult<T>> getResult({dynamic filter}) async {
    var url = "$_baseUrl$_endpoint";
    if (filter != null) {
      var queryString = getQueryString(filter);
      url = "$url?$queryString";
    }

    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http!.get(uri, headers: headers);
    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      
      // Debug: Log the actual response structure
      print("DEBUG: API Response for $_endpoint:");
      print("DEBUG: Response status: ${response.statusCode}");
      print("DEBUG: Response body: ${response.body}");
      print("DEBUG: Parsed data: $data");
      print("DEBUG: Data keys: ${data?.keys.toList()}");
      print("DEBUG: Data['Result']: ${data?['Result']}");
  
      var result = SearchResult<T>();

      // Check if data and required fields exist
      if (data != null && data['Count'] != null) {
        result.count = data['Count'];
      }

      // Try both 'Result' and 'result' keys (case sensitivity issue)
      var resultData = data?['Result'] ?? data?['result'];
      if (data != null && resultData != null) {
        for (var item in resultData) {
          result.result?.add(fromJson(item));
        }
      } else {
        print("Warning: data['Result'] and data['result'] are both null in getResult");
        print("Available keys: ${data?.keys.toList()}");
      }

      return result;
    } else
      throw new Exception("Unknown error");
  }

  bool isValidResponse(Response response) {
    if (response.statusCode < 299) {
      return true;
    } else if (response.statusCode == 401) {
      throw new Exception("Unauthorized");
    } else {
      print(response.body);
      throw new Exception("Something bad happened please try again");
    }
  }

  Future<T?> insert(dynamic request) async {
    var url = "$_baseUrl$_endpoint";
    var uri = Uri.parse(url);
    Map<String, String> headers = createHeaders();
    var jsonRequest = jsonEncode(request);
    
    print('DEBUG: BaseProvider.insert for $_endpoint');
    print('DEBUG: URL: $url');
    print('DEBUG: Request JSON: $jsonRequest');
    print('DEBUG: Headers: $headers');
    
    var response = await http!.post(uri, headers: headers, body: jsonRequest);
    
    print('DEBUG: Response status: ${response.statusCode}');
    print('DEBUG: Response body: ${response.body}');

    if (isValidResponseCode(response)) {
      var data = jsonDecode(response.body);
      print('DEBUG: Parsed response data: $data');
      return fromJson(data) as T;
    } else {
      print('DEBUG: Response not valid, returning null');
      return null;
    }
  }

  Future<T?> update(int id, [dynamic request]) async {
    var url = "$_baseUrl$_endpoint/$id";
    var uri = Uri.parse(url);

    Map<String, String> headers = createHeaders();

    var response =
        await http!.put(uri, headers: headers, body: jsonEncode(request));

    if (isValidResponseCode(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data) as T;
    } else {
      return null;
    }
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
    
    print('DEBUG: Creating headers for user: $username');
    print('DEBUG: Authorization header: $basicAuth');
    
    return headers;
  }

  T fromJson(data) {
    throw Exception("Override method");
  }

  String getQueryString(Map params,
      {String prefix = '&', bool inRecursion = false}) {
    String query = '';
    params.forEach((key, value) {
      if (inRecursion) {
        if (key is int) {
          key = '[$key]';
        } else if (value is List || value is Map) {
          key = '.$key';
        } else {
          key = '.$key';
        }
      }
      if (value is String || value is int || value is double || value is bool) {
        var encoded = value;
        if (value is String) {
          encoded = Uri.encodeComponent(value);
        }
        query += '$prefix$key=$encoded';
      } else if (value is DateTime) {
        query += '$prefix$key=${(value as DateTime).toIso8601String()}';
      } else if (value is List || value is Map) {
        if (value is List) value = value.asMap();
        value.forEach((k, v) {
          query +=
              getQueryString({k: v}, prefix: '$prefix$key', inRecursion: true);
        });
      }
    });
    return query;
  }

  bool isValidResponseCode(Response response) {
    if (response.statusCode == 200) {
      if (response.body != "") {
        return true;
      } else {
        return false;
      }
    } else if (response.statusCode == 204) {
      return true;
    } else if (response.statusCode == 400) {
      throw Exception("Bad request");
    } else if (response.statusCode == 401) {
      throw Exception("Unauthorized");
    } else if (response.statusCode == 403) {
      throw Exception("Forbidden");
    } else if (response.statusCode == 404) {
      throw Exception("Not found");
    } else if (response.statusCode == 500) {
      throw Exception("Internal server error");
    } else {
      throw Exception("Exception... handle this gracefully");
    }
  }
}
