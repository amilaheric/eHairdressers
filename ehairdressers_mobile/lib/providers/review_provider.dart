import 'dart:convert';
import 'package:http/http.dart';
import 'package:ehairdressers_mobile/models/review.dart';
import 'package:ehairdressers_mobile/models/search_result.dart';
import 'base_provider.dart';

class ReviewProvider extends BaseProvider<Review> {
  ReviewProvider() : super("Review");

  @override
  Review fromJson(data) {
    return Review.fromJson(data);
  }

  // Submit a new review (custom implementation for Review)
  Future<Review?> insertReview(Review review) async {
    try {
      print('=== SUBMITTING REVIEW TO DATABASE ===');
      print('Appointment ID: ${review.appointmentId}');
      print('User ID: ${review.userId}');
      print('Service ID: ${review.serviceId}');
      print('Employee ID: ${review.employeeId}');
      print('Rating: ${review.rating} stars');
      print('Comment: ${review.comment ?? "No comment"}');
      print('Review.toJson(): ${review.toJson()}');
      
      var url = "${baseUrl}Review";
      var uri = Uri.parse(url);
      Map<String, String> headers = createHeaders();
      var jsonRequest = jsonEncode(review.toJson());
      
      print('Sending POST request to: $url');
      print('Request JSON: $jsonRequest');
      
      var response = await http!.post(uri, headers: headers, body: jsonRequest);
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (isValidResponseCode(response)) {
        var data = jsonDecode(response.body);
        print('SUCCESS! Parsed response: $data');
        
        // The API response doesn't match the Review model structure exactly
        // So we'll return the original review with the ID from the response
        if (data['ReviewId'] != null) {
          return Review(
            reviewId: data['ReviewId'],
            appointmentId: review.appointmentId,
            userId: review.userId,
            serviceId: review.serviceId,
            employeeId: review.employeeId,
            rating: review.rating,
            comment: review.comment,
            reviewDate: review.reviewDate,
            isActive: review.isActive,
          );
        }
        
        return review; // Return the original review if no ID in response
      } else {
        print('Failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error submitting review: $e');
      return null;
    }
  }

  // Submit a new review (legacy method for compatibility)
  Future<ReviewResponse?> submitReview(ReviewRequest request) async {
    try {
      print('=== SUBMITTING REVIEW TO DATABASE ===');
      print('Appointment ID: ${request.appointmentId}');
      print('User ID: ${request.userId}');
      print('Service ID: ${request.serviceId}');
      print('Employee ID: ${request.employeeId}');
      print('Rating: ${request.rating} stars');
      print('Comment: ${request.comment ?? "No comment"}');
      print('ReviewRequest.toJson(): ${request.toJson()}');
      print('Rating type: ${request.rating.runtimeType}');
      print('Rating value: ${request.rating}');
      
      // Try multiple endpoints and data formats
      List<Map<String, dynamic>> dataVariations = [
        // Variation 1: Standard format (from ReviewRequest.toJson())
        request.toJson(),
        
                 // Variation 2: Lowercase field names
         {
           'appointmentId': request.appointmentId,
           'userId': request.userId,
           'serviceId': request.serviceId,
           'employeeId': request.employeeId,
           'rate': request.rating,
           'comment': request.comment ?? '',
         },
         
         // Variation 3: Using 'Rate' (PascalCase)
         {
           'AppointmentId': request.appointmentId,
           'UserId': request.userId,
           'ServiceId': request.serviceId,
           'EmployeeId': request.employeeId,
           'Rate': request.rating,
           'Comment': request.comment ?? '',
         },
         
         // Variation 4: Minimal data (only what's absolutely necessary)
         {
           'AppointmentId': request.appointmentId,
           'UserId': request.userId,
           'Rate': request.rating,
         },
      ];
      
      List<String> endpoints = [
        "${baseUrl}Review",
        "${baseUrl}Review/submit",
        "${baseUrl}api/Review",
        "${baseUrl}api/Review/submit",
      ];
      
      for (int i = 0; i < dataVariations.length; i++) {
        var reviewData = dataVariations[i];
        print('Trying data variation ${i + 1}: $reviewData');
        
        for (int j = 0; j < endpoints.length; j++) {
          var url = endpoints[j];
          print('Trying endpoint ${j + 1}: $url');
          
          try {
            var uri = Uri.parse(url);
            Map<String, String> headers = createHeaders();
                         var jsonRequest = jsonEncode(reviewData);
             print('JSON Request: $jsonRequest');
             print('JSON Request length: ${jsonRequest.length}');
             print('ReviewData keys: ${reviewData.keys.toList()}');
             print('ReviewData values: ${reviewData.values.toList()}');
            
            print('Sending POST request to: $url');
            var response = await http!.post(uri, headers: headers, body: jsonRequest);
            
            print('Response status: ${response.statusCode}');
            print('Response body: ${response.body}');
            
                         if (isValidResponseCode(response)) {
               var data = jsonDecode(response.body);
               print('SUCCESS! Parsed response: $data');
               
               return ReviewResponse(
                 reviewId: data['ReviewId'] ?? DateTime.now().millisecondsSinceEpoch,
                 appointmentId: request.appointmentId,
                 message: 'Review submitted successfully!',
                 success: true,
               );
             } else {
               print('Failed with status: ${response.statusCode}');
               
               // Check if it's an "already reviewed" error
               if (response.statusCode == 500 && response.body.contains('already reviewed')) {
                 print('User has already reviewed this appointment');
                 return ReviewResponse(
                   reviewId: DateTime.now().millisecondsSinceEpoch,
                   appointmentId: request.appointmentId,
                   message: 'You have already reviewed this appointment.',
                   success: false,
                 );
               }
               
               continue; // Try next endpoint
             }
          } catch (endpointError) {
            print('Error with endpoint $url: $endpointError');
            continue; // Try next endpoint
          }
        }
      }
      
      // If all attempts fail, try using the base provider's insert method
      print('All direct HTTP attempts failed. Trying base provider insert...');
      try {
        var review = Review(
          appointmentId: request.appointmentId,
          userId: request.userId,
          serviceId: request.serviceId,
          employeeId: request.employeeId,
          rating: request.rating,
          comment: request.comment,
          reviewDate: DateTime.now().toUtc().toIso8601String(),
        );
        
        var result = await insert(review);
        print('Base provider insert result: $result');
        
        if (result != null) {
          return ReviewResponse(
            reviewId: result.reviewId ?? DateTime.now().millisecondsSinceEpoch,
            appointmentId: request.appointmentId,
            message: 'Review submitted successfully via base provider!',
            success: true,
          );
        }
      } catch (baseError) {
        print('Base provider insert also failed: $baseError');
      }
      
      // Final fallback - return error
      print('All methods failed. Returning error response...');
      return ReviewResponse(
        reviewId: DateTime.now().millisecondsSinceEpoch,
        appointmentId: request.appointmentId,
        message: 'Review submission failed. Please check your backend endpoint.',
        success: false,
      );
    } catch (e) {
      print('Error submitting review: $e');
      
      return ReviewResponse(
        reviewId: DateTime.now().millisecondsSinceEpoch,
        appointmentId: request.appointmentId,
        message: 'Review submission failed: $e',
        success: false,
      );
    }
  }

  // Get reviews for a specific service
  Future<List<Review>> getServiceReviews(int serviceId) async {
    try {
      var url = "${baseUrl}Review/service/$serviceId";
      var uri = Uri.parse(url);
      
      Map<String, String> headers = createHeaders();
      
      var response = await http!.get(uri, headers: headers);
      
      if (isValidResponseCode(response)) {
        var data = jsonDecode(response.body);
        if (data is List) {
          return data.map((item) => Review.fromJson(item)).toList();
        } else if (data['Result'] != null) {
          return data['Result'].map((item) => Review.fromJson(item)).toList();
        }
        return [];
      } else {
        print('Failed to get service reviews: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error getting service reviews: $e');
      return [];
    }
  }

  // Get reviews for a specific employee
  Future<List<Review>> getEmployeeReviews(int employeeId) async {
    try {
      var url = "${baseUrl}Review/employee/$employeeId";
      var uri = Uri.parse(url);
      
      Map<String, String> headers = createHeaders();
      
      var response = await http!.get(uri, headers: headers);
      
      if (isValidResponseCode(response)) {
        var data = jsonDecode(response.body);
        if (data is List) {
          return data.map((item) => Review.fromJson(item)).toList();
        } else if (data['Result'] != null) {
          return data['Result'].map((item) => Review.fromJson(item)).toList();
        }
        return [];
      } else {
        print('Failed to get employee reviews: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error getting employee reviews: $e');
      return [];
    }
  }

  // Check if user has already reviewed an appointment
  Future<bool> hasUserReviewed(int appointmentId, int userId) async {
    try {
      print('=== CHECKING IF USER HAS ALREADY REVIEWED ===');
      print('Appointment ID: $appointmentId');
      print('User ID: $userId');
      
      // Try multiple endpoints for checking review status
      List<String> checkEndpoints = [
        "${baseUrl}Review/check/$appointmentId/$userId",
        "${baseUrl}Review/exists/$appointmentId/$userId",
        "${baseUrl}api/Review/check/$appointmentId/$userId",
      ];
      
      for (String url in checkEndpoints) {
        try {
          print('Trying check endpoint: $url');
          var uri = Uri.parse(url);
          Map<String, String> headers = createHeaders();
          
          var response = await http!.get(uri, headers: headers);
          print('Check response status: ${response.statusCode}');
          print('Check response body: ${response.body}');
          
          if (isValidResponseCode(response)) {
            var data = jsonDecode(response.body);
            bool hasReviewed = data['HasReviewed'] ?? data['Exists'] ?? false;
            print('User has reviewed: $hasReviewed');
            return hasReviewed;
          }
        } catch (e) {
          print('Error with check endpoint $url: $e');
          continue;
        }
      }
      
      // If check endpoints fail, try to get reviews for this appointment
      print('Check endpoints failed, trying to get appointment reviews...');
      try {
        var reviews = await getAppointmentReviews(appointmentId);
        bool hasReviewed = reviews.any((review) => review.userId == userId);
        print('Found existing review: $hasReviewed');
        return hasReviewed;
      } catch (e) {
        print('Error getting appointment reviews: $e');
      }
      
      print('Could not determine review status, assuming not reviewed');
      return false;
    } catch (e) {
      print('Error checking review status: $e');
      return false;
    }
  }

  // Get reviews for a specific user
  Future<List<Review>> getUserReviews(int userId) async {
    try {
      var url = "${baseUrl}Review/user/$userId";
      var uri = Uri.parse(url);
      
      Map<String, String> headers = createHeaders();
      
      var response = await http!.get(uri, headers: headers);
      
      if (isValidResponseCode(response)) {
        var data = jsonDecode(response.body);
        if (data is List) {
          return data.map((item) => Review.fromJson(item)).toList();
        } else if (data['Result'] != null) {
          return data['Result'].map((item) => Review.fromJson(item)).toList();
        }
        return [];
      } else {
        print('Failed to get user reviews: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error getting user reviews: $e');
      return [];
    }
  }

  // Get reviews for a specific appointment
  Future<List<Review>> getAppointmentReviews(int appointmentId) async {
    try {
      var url = "${baseUrl}Review/appointment/$appointmentId";
      var uri = Uri.parse(url);
      
      Map<String, String> headers = createHeaders();
      
      var response = await http!.get(uri, headers: headers);
      
      if (isValidResponseCode(response)) {
        var data = jsonDecode(response.body);
        if (data is List) {
          return data.map((item) => Review.fromJson(item)).toList();
        } else if (data['Result'] != null) {
          return data['Result'].map((item) => Review.fromJson(item)).toList();
        }
        return [];
      } else {
        print('Failed to get appointment reviews: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error getting appointment reviews: $e');
      return [];
    }
  }

  // Test review submission (for development)
  Future<ReviewResponse?> submitTestReview(ReviewRequest request) async {
    try {
      print('Submitting TEST review for appointment: ${request.appointmentId}');
      print('Test rating: ${request.rating} stars');
      print('Test comment: ${request.comment ?? "No comment"}');
      
      // Simulate API delay
      await Future.delayed(Duration(seconds: 1));
      
      // Mock successful review response
      return ReviewResponse(
        reviewId: DateTime.now().millisecondsSinceEpoch,
        appointmentId: request.appointmentId,
        message: 'Test review submitted successfully!',
        success: true,
      );
    } catch (e) {
      print('Error submitting test review: $e');
      return null;
    }
  }
}
