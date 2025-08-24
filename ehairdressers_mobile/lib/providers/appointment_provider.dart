import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:ehairdressers_mobile/models/appointment.dart';
import 'package:ehairdressers_mobile/models/appointment_insert_request.dart';
import 'package:ehairdressers_mobile/models/search_result.dart';
import 'base_provider.dart';

class AppointmentProvider extends BaseProvider<Appointment> {
  AppointmentProvider() : super("Appointment");

  @override
  Appointment fromJson(data) {
    try {
      print("Converting appointment data: $data");
      return Appointment.fromJson(data);
    } catch (e) {
      print("Error converting appointment data: $e");
      print("Data type: ${data.runtimeType}");
      rethrow;
    }
  }

  // Override getResult to handle path parameters for user ID
  @override
  Future<SearchResult<Appointment>> getResult({dynamic filter}) async {

    print("Filter: $filter");
    print("Filter type: ${filter.runtimeType}");
    print("Endpoint: Appointment");
    
    // Check if filter contains UserId and construct URL accordingly
    if (filter != null && filter is Map && filter.containsKey('UserId')) {
      // Use path parameter format: /Appointment/{userId}
      var userId = filter['UserId'];
      var url = "http://10.0.2.2:7051/Appointment/$userId";
      print("Using path parameter URL: $url");
      
      // Make the HTTP request directly for path parameter
      var uri = Uri.parse(url);
      var headers = createHeaders();
      
             // Create HTTP client with SSL certificate bypass for development
       var client = http.Client();
       if (Platform.isAndroid) {
         // For Android, we need to handle SSL certificate issues
         try {
           // Try with HTTPS first
           var response = await client.get(uri, headers: headers);
          print("Response status: ${response.statusCode}");
          print("Response body: ${response.body}");
          
          if (isValidResponse(response)) {
            var data = jsonDecode(response.body);
            var result = SearchResult<Appointment>();

            // Check if data and required fields exist
            if (data != null && data['Count'] != null) {
              result.count = data['Count'];
            }

            if (data != null && data['Result'] != null) {
              for (var item in data['Result']) {
                result.result?.add(fromJson(item));
              }
            } else {
              print("Warning: data['Result'] is null in getResult");
            }

            print("=== APPOINTMENT PROVIDER RESULT ===");
            print("Count: ${result.count}");
            print("Result length: ${result.result?.length}");
            if (result.result != null) {
              for (var appointment in result.result!) {
                print("Appointment ID: ${appointment.id}");
                print("  Date: ${appointment.appointmentDate}");
                print("  Time: ${appointment.appointmentTime}");
                print("  Service: ${appointment.serviceName}");
                print("  Employee: ${appointment.employeeName}");
                print("  Status: ${appointment.status}");
                print("  Duration: ${appointment.duration}");
                print("---");
              }
            }
            
            return result;
          } else {
            throw Exception("Failed to fetch appointments");
          }
                 } catch (e) {
           print("SSL Error: $e");
                        // Try with HTTP instead of HTTPS for development
             try {
               var httpUrl = url.replaceFirst('https://', 'http://');
               print("Trying HTTP URL: $httpUrl");
               var httpUri = Uri.parse(httpUrl);
               var response = await client.get(httpUri, headers: headers).timeout(
                 Duration(seconds: 10),
                 onTimeout: () {
                   throw Exception("HTTP request timed out");
                 },
               );
             print("HTTP Response status: ${response.statusCode}");
             print("HTTP Response body: ${response.body}");
             
             if (isValidResponse(response)) {
               var data = jsonDecode(response.body);
               var result = SearchResult<Appointment>();

               if (data != null && data['Count'] != null) {
                 result.count = data['Count'];
               }

               if (data != null && data['Result'] != null) {
                 for (var item in data['Result']) {
                   result.result?.add(fromJson(item));
                 }
               } else {
                 print("Warning: data['Result'] is null in getResult");
               }

               print("=== APPOINTMENT PROVIDER RESULT ===");
               print("Count: ${result.count}");
               print("Result length: ${result.result?.length}");
               if (result.result != null) {
                 for (var appointment in result.result!) {
                   print("Appointment ID: ${appointment.id}");
                   print("  Date: ${appointment.appointmentDate}");
                   print("  Time: ${appointment.appointmentTime}");
                   print("  Service: ${appointment.serviceName}");
                   print("  Employee: ${appointment.employeeName}");
                   print("  Status: ${appointment.status}");
                   print("  Duration: ${appointment.duration}");
                   print("---");
                 }
               }
               
               return result;
             } else {
               throw Exception("Failed to fetch appointments");
             }
                       } catch (httpError) {
              print("HTTP Error: $httpError");
              // If both HTTPS and HTTP fail, try with a different approach
              print("Both HTTPS and HTTP failed. Trying with base provider...");
                                            // Try with base provider using path parameter format
               try {
                 // Use the base provider's getById method which has SSL bypass
                 print("Trying base provider getById method for user ID: $userId");
                 var appointments = await getById(userId);
                 print("Base provider getById result: ${appointments.length} appointments");
                 
                 var result = SearchResult<Appointment>();
                 result.count = appointments.length;
                 result.result = appointments;
                 
                 print("=== BASE PROVIDER RESULT ===");
                 print("Count: ${result.count}");
                 print("Result length: ${result.result?.length}");
                 if (result.result != null) {
                   for (var appointment in result.result!) {
                     print("Appointment ID: ${appointment.id}");
                     print("  Date: ${appointment.appointmentDate}");
                     print("  Time: ${appointment.appointmentTime}");
                     print("  Service: ${appointment.serviceName}");
                     print("  Employee: ${appointment.employeeName}");
                     print("  Status: ${appointment.status}");
                     print("  Duration: ${appointment.duration}");
                     print("---");
                   }
                 }
                 
                 return result;
               } catch (baseError) {
                 print("Base provider error: $baseError");
                 // Final fallback: try query parameter format
                 var queryFilter = {'UserId': userId.toString()};
                 print("Final fallback: Using query parameter filter: $queryFilter");
                 return await super.getResult(filter: queryFilter);
               }
            }
        } finally {
          client.close();
        }
      } else {
        // For other platforms, use regular HTTP request
        var response = await http.get(uri, headers: headers);
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");
        
        if (isValidResponse(response)) {
          var data = jsonDecode(response.body);
          print("getResult decoded data: $data");
          var result = SearchResult<Appointment>();

          // Check if data and required fields exist
          if (data != null && data['Count'] != null) {
            result.count = data['Count'];
          }

          if (data != null && data['Result'] != null) {
            for (var item in data['Result']) {
              result.result?.add(fromJson(item));
            }
          } else {
            print("Warning: data['Result'] is null in getResult");
          }

          print("=== APPOINTMENT PROVIDER RESULT ===");
          print("Count: ${result.count}");
          print("Result length: ${result.result?.length}");
          if (result.result != null) {
            for (var appointment in result.result!) {
              print("Appointment ID: ${appointment.id}");
              print("  Date: ${appointment.appointmentDate}");
              print("  Time: ${appointment.appointmentTime}");
              print("  Service: ${appointment.serviceName}");
              print("  Employee: ${appointment.employeeName}");
              print("  Status: ${appointment.status}");
              print("  Duration: ${appointment.duration}");
              print("---");
            }
          }
          
          return result;
        } else {
          throw Exception("Failed to fetch appointments");
        }
      }
    } else {
      // Use the base provider for other filters
      print("Using base provider for non-UserId filters");
      return await super.getResult(filter: filter);
    }
  }

  @override
  Future<Appointment?> insert(dynamic request) async {
    if (request is AppointmentInsertRequest) {
      // Convert AppointmentInsertRequest to JSON before sending
      var jsonRequest = request.toJson();
      return await super.insert(jsonRequest);
    } else {
      // Handle regular insert requests
      return await super.insert(request);
    }
  }

  /// Get available appointments for review for a specific user
  Future<SearchResult<Appointment>> getAvailableForReview(int userId) async {
    print('🔥🔥🔥 APPOINTMENT PROVIDER: getAvailableForReview CALLED 🔥🔥🔥');
    print('=== GETTING AVAILABLE APPOINTMENTS FOR REVIEW ===');
    print('User ID: $userId');
    
    try {
      var url = "http://10.0.2.2:7051/Review/available-appointments/$userId";
      print("URL: $url");
      
      var uri = Uri.parse(url);
      var headers = createHeaders();
      
     
      var client = http.Client();
      
      try {
        // Try with HTTPS first
        var response = await client.get(uri, headers: headers);
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");
        
                       if (isValidResponse(response)) {
                 var data = jsonDecode(response.body);
                 var result = SearchResult<Appointment>();

                 print("Response data type: ${data.runtimeType}");
                 print("Response data: $data");

                 // Handle direct array response (new Review endpoint format)
                 if (data is List) {
                   print("Processing direct array response with ${data.length} items");
                   result.count = data.length;
                   for (var item in data) {
                     result.result?.add(fromJson(item));
                   }
                 }
                 // Handle SearchResult format (fallback for other endpoints)
                 else if (data is Map) {
                   print("Processing SearchResult format response");
                   if (data['Count'] != null) {
                     result.count = data['Count'];
                   }
                   if (data['Result'] != null) {
                     for (var item in data['Result']) {
                       result.result?.add(fromJson(item));
                     }
                   } else {
                     print("Warning: data['Result'] is null in getAvailableForReview");
                   }
                 }

          print("=== AVAILABLE FOR REVIEW RESULT ===");
          print("Count: ${result.count}");
          print("Result length: ${result.result?.length}");
          if (result.result != null) {
            for (var appointment in result.result!) {
              print("Appointment ID: ${appointment.id}");
              print("  Date: ${appointment.appointmentDate}");
              print("  Time: ${appointment.appointmentTime}");
              print("  Service: ${appointment.serviceName}");
              print("  Employee: ${appointment.employeeName}");
              print("  Status: ${appointment.status}");
              print("  Duration: ${appointment.duration}");
              print("---");
            }
          }
          
          return result;
        } else {
          throw Exception("Failed to fetch available appointments for review");
        }
      } catch (e) {
        print("HTTPS Error: $e");
        
        // Try with HTTP instead of HTTPS for development
        try {
          var httpUrl = url.replaceFirst('https://', 'http://');
          print("Trying HTTP URL: $httpUrl");
          var httpUri = Uri.parse(httpUrl);
          var response = await client.get(httpUri, headers: headers).timeout(
            Duration(seconds: 10),
            onTimeout: () {
              throw Exception("HTTP request timed out");
            },
          );
          
          print("HTTP Response status: ${response.statusCode}");
          print("HTTP Response body: ${response.body}");
          
                           if (isValidResponse(response)) {
                   var data = jsonDecode(response.body);
                   var result = SearchResult<Appointment>();

                   print("HTTP Response data type: ${data.runtimeType}");
                   print("HTTP Response data: $data");

                   // Handle direct array response (new Review endpoint format)
                   if (data is List) {
                     print("Processing direct array response with ${data.length} items (HTTP)");
                     result.count = data.length;
                     for (var item in data) {
                       result.result?.add(fromJson(item));
                     }
                   }
                   // Handle SearchResult format (fallback for other endpoints)
                   else if (data is Map) {
                     print("Processing SearchResult format response (HTTP)");
                     if (data['Count'] != null) {
                       result.count = data['Count'];
                     }
                     if (data['Result'] != null) {
                       for (var item in data['Result']) {
                         result.result?.add(fromJson(item));
                       }
                     } else {
                       print("Warning: data['Result'] is null in getAvailableForReview (HTTP)");
                     }
                   }

            print("=== AVAILABLE FOR REVIEW RESULT (HTTP) ===");
            print("Count: ${result.count}");
            print("Result length: ${result.result?.length}");
            
            return result;
          } else {
            throw Exception("Failed to fetch available appointments for review (HTTP)");
          }
        } catch (httpError) {
          print("HTTP Error: $httpError");
          throw Exception("Both HTTPS and HTTP failed for available-appointments endpoint");
        }
      } finally {
        client.close();
      }
    } catch (e) {
      print("Error in getAvailableForReview: $e");
      rethrow;
    }
  }
}