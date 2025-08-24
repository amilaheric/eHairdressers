import 'dart:convert';
import 'package:ehairdressers_mobile/models/recommendation.dart';
import 'package:ehairdressers_mobile/models/product.dart';
import 'package:ehairdressers_mobile/providers/base_provider.dart';

class RecommendationProvider extends BaseProvider<Recommendation> {
  RecommendationProvider() : super("Recommendation");

  // Get base API URL
  String get baseApiUrl {
    const String baseUrl = String.fromEnvironment("baseUrl", defaultValue: "http://10.0.2.2:7051/");
    return baseUrl.endsWith("/") ? baseUrl : "$baseUrl/";
  }

  // Get popular products
  Future<List<Recommendation>> getPopularProducts({int? numberOfProducts}) async {
    try {
      var url = "${baseApiUrl}api/Recommendation/popular-products";
      if (numberOfProducts != null) {
        url = "$url?numberOfProducts=$numberOfProducts";
      }

      var uri = Uri.parse(url);
      Map<String, String> headers = createHeaders();

      var response = await http!.get(uri, headers: headers);
      print('Popular products response: ${response.statusCode}');

      if (isValidResponseCode(response)) {
        var jsonData = json.decode(response.body);
        if (jsonData is List) {
          return jsonData.map((item) => Recommendation.fromJson(item)).toList();
        }
        return [];
      } else {
        print('Error getting popular products: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Exception getting popular products: $e');
      return [];
    }
  }

  // Get personalized recommendations
  Future<List<Recommendation>> getRecommendations({
    required int userId,
    int? numberOfRecommendations,
    bool? includeSimilarUsers,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      var url = "${baseApiUrl}api/Recommendation/recommendations";
      var uri = Uri.parse(url);
      
      // Create request body matching your API format
      Map<String, dynamic> requestBody = {
        "userId": userId,
      };
      
      if (numberOfRecommendations != null) {
        requestBody["numberOfRecommendations"] = numberOfRecommendations;
      }
      if (includeSimilarUsers != null) {
        requestBody["includeSimilarUsers"] = includeSimilarUsers;
      }
      if (fromDate != null) {
        requestBody["fromDate"] = fromDate;
      }
      if (toDate != null) {
        requestBody["toDate"] = toDate;
      }

      Map<String, String> headers = createHeaders();

      var response = await http!.post(
        uri,
        headers: headers,
        body: json.encode(requestBody),
      );

      print('Recommendations response: ${response.statusCode}');

      if (isValidResponseCode(response)) {
        var jsonData = json.decode(response.body);
        if (jsonData is List) {
          return jsonData.map((item) => Recommendation.fromJson(item)).toList();
        }
        return [];
      } else {
        print('Error getting recommendations: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Exception getting recommendations: $e');
      return [];
    }
  }

  // Get similar users
  Future<List<SimilarUser>> getSimilarUsers(int userId) async {
    try {
      var url = "${baseApiUrl}api/Recommendation/similar-users/$userId";
      var uri = Uri.parse(url);
      
      Map<String, String> headers = createHeaders();

      var response = await http!.get(uri, headers: headers);
      print('Similar users response: ${response.statusCode}');

      if (isValidResponseCode(response)) {
        var jsonData = json.decode(response.body);
        if (jsonData is List) {
          return jsonData.map((item) => SimilarUser.fromJson(item)).toList();
        }
        return [];
      } else {
        print('Error getting similar users: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Exception getting similar users: $e');
      return [];
    }
  }

  // Get new user recommendations
  Future<List<Recommendation>> getNewUserRecommendations() async {
    try {
      var url = "${baseApiUrl}api/Recommendation/new-user-recommendations";
      var uri = Uri.parse(url);
      
      Map<String, String> headers = createHeaders();

      var response = await http!.get(uri, headers: headers);
      print('New user recommendations response: ${response.statusCode}');

      if (isValidResponseCode(response)) {
        var jsonData = json.decode(response.body);
        if (jsonData is List) {
          return jsonData.map((item) => Recommendation.fromJson(item)).toList();
        }
        return [];
      } else {
        print('Error getting new user recommendations: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Exception getting new user recommendations: $e');
      return [];
    }
  }

  // Get category recommendations
  Future<List<Recommendation>> getCategoryRecommendations(int userId) async {
    try {
      var url = "${baseApiUrl}api/Recommendation/category-recommendations/$userId";
      var uri = Uri.parse(url);
      
      Map<String, String> headers = createHeaders();

      var response = await http!.get(uri, headers: headers);
      print('Category recommendations response: ${response.statusCode}');

      if (isValidResponseCode(response)) {
        var jsonData = json.decode(response.body);
        if (jsonData is List) {
          return jsonData.map((item) => Recommendation.fromJson(item)).toList();
        }
        return [];
      } else {
        print('Error getting category recommendations: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Exception getting category recommendations: $e');
      return [];
    }
  }

  // Get full product details by ID
  Future<Product?> getProductById(int productId) async {
    try {
      var url = "${baseApiUrl}api/Products/$productId";
      var uri = Uri.parse(url);
      Map<String, String> headers = createHeaders();

      var response = await http!.get(uri, headers: headers);
      print('Product details response: ${response.statusCode}');

      if (isValidResponseCode(response)) {
        var jsonData = json.decode(response.body);
        if (jsonData is Map<String, dynamic>) {
          return Product.fromJson(jsonData);
        }
      }
      return null;
    } catch (e) {
      print('Exception getting product details: $e');
      return null;
    }
  }

  // Get recommendations with images (API already provides images)
  Future<List<Recommendation>> getRecommendationsWithImages({
    required int userId,
    required List<Product> allProducts,
    int? numberOfRecommendations,
    bool? includeSimilarUsers,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      // Get recommendations directly (API already provides images)
      var recommendations = await getRecommendations(
        userId: userId,
        numberOfRecommendations: numberOfRecommendations,
        includeSimilarUsers: includeSimilarUsers,
        fromDate: fromDate,
        toDate: toDate,
      );



      return recommendations;
    } catch (e) {
      print('Exception getting recommendations with images: $e');
      return [];
    }
  }

  // Get popular products with images (API already provides images)
  Future<List<Recommendation>> getPopularProductsWithImages({
    required List<Product> allProducts,
    int? numberOfProducts,
  }) async {
    try {
      // Get popular products directly (API already provides images)
      var recommendations = await getPopularProducts(numberOfProducts: numberOfProducts);



      return recommendations;
    } catch (e) {
      print('Exception getting popular products with images: $e');
      return [];
    }
  }

  @override
  Recommendation fromJson(data) {
    return Recommendation.fromJson(data);
  }
}