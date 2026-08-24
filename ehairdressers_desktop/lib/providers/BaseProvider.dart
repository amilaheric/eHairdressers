import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/SearchResult.dart';
import '../utils/util.dart';

class BaseProvider<T> with ChangeNotifier {
  static String? _baseUrl;

  String endpoint = "";

  BaseProvider(String _endpoint) {
    endpoint = _endpoint;
    _baseUrl = const String.fromEnvironment("baseUrl",
        defaultValue: "http://localhost:7051/");
  }

  String get baseUrl => _baseUrl ??
      const String.fromEnvironment("baseUrl", defaultValue: "http://localhost:7051/");

  Future<SearchResult<T>> get({dynamic filter}) async {
    try {
      var url = "$_baseUrl$endpoint";
      if (filter != null) {
        var queryString = getQueryString(filter);
        // Remove the leading & and add ? instead
        if (queryString.startsWith('&')) {
          queryString = queryString.substring(1);
        }
        url = "$url?$queryString";
      }

      print("Making API call to: $url");
      print("Filter parameters: $filter");

      var uri = Uri.parse(url);
      var headers = createHeaders();

      var response = await http.get(uri, headers: headers);
      
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print("Raw API response: $data");
        print("Response keys: ${data.keys.toList()}");
        
        // Use the new SearchResult.fromJson method
        var result = SearchResult<T>.fromJson(data, fromJson);
        
        return result;
      } else if (response.statusCode == 401) {
        throw Exception("Unauthorized - Please check your credentials");
      } else if (response.statusCode == 404) {
        throw Exception("Endpoint not found: $url");
      } else if (response.statusCode >= 500) {
        throw Exception("Server error (${response.statusCode}): ${response.body}");
      } else {
        throw Exception("API error (${response.statusCode}): ${response.body}");
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception("Network error: $e");
      }
    }
  }

  Future<T> insert(dynamic request) async {
    var url = "$_baseUrl$endpoint";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var jsonRequest = jsonEncode(request);
    
    var response = await http.post(uri, headers: headers, body: jsonRequest);
    

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw new Exception("Unknown error");
    }
  }

  Future<void> delete(int id, [dynamic request]) async {
    var url = "$_baseUrl$endpoint/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.delete(uri, headers: headers);

    if (response.statusCode == 200) {
    } else {
      throw Exception('Failed to delete appointment');
    }
  }

  Future<T> update(int id, [dynamic request]) async {
    var url = "$_baseUrl$endpoint/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var jsonRequest = jsonEncode(request);
    var response = await http.put(uri, headers: headers, body: jsonRequest);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw new Exception("Unknown error");
    }
  }

  T fromJson(data) {
    throw Exception("Method not implemented");
  }

  bool isValidResponse(http.Response response) {
    if (response.statusCode < 299) {
      return true;
    } else if (response.statusCode == 401) {
      throw new Exception("Unauthorized");
    } else {
      throw new Exception(_extractErrorMessage(response));
    }
  }

  String _extractErrorMessage(http.Response response) {
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
    } catch (_) {}

    if (response.body.isNotEmpty) {
      return 'Server error (${response.statusCode}): ${response.body}';
    }

    return 'Server error (${response.statusCode})';
  }

  Map<String, String> createHeaders() {
    String token = Authorization.token ?? "";

    var headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    };

    return headers;
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
}


