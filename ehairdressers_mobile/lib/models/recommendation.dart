class Recommendation {
  final int productId;
  final String productName;
  final String? description;
  final double? price;
  final String? imageUrl;
  final double? recommendationScore;
  final String? reason;
  final List<String>? similarUsers;

  Recommendation({
    required this.productId,
    required this.productName,
    this.description,
    this.price,
    this.imageUrl,
    this.recommendationScore,
    this.reason,
    this.similarUsers,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      productId: json['productId'] ?? json['ProductId'] ?? 0,
      productName: json['productName'] ?? json['ProductName'] ?? '',
      description: json['description'] ?? json['Description'],
      price: (json['price'] ?? json['Price'])?.toDouble(),
      imageUrl: json['imageUrl'] ?? json['ImageUrl'] ?? json['Image'],
      recommendationScore: (json['recommendationScore'] ?? json['RecommendationScore'])?.toDouble(),
      reason: json['reason'] ?? json['Reason'],
      similarUsers: json['similarUsers'] != null 
          ? List<String>.from(json['similarUsers']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'recommendationScore': recommendationScore,
      'reason': reason,
      'similarUsers': similarUsers,
    };
  }

  // Getter for backward compatibility
  double? get score => recommendationScore;
}

class RecommendationRequest {
  final int userId;
  final int? limit;
  final String? type;

  RecommendationRequest({
    required this.userId,
    this.limit,
    this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'limit': limit,
      'type': type,
    };
  }
}

class SimilarUser {
  final int userId;
  final String userName;
  final double similarityScore;
  final List<int> commonProducts;

  SimilarUser({
    required this.userId,
    required this.userName,
    required this.similarityScore,
    required this.commonProducts,
  });

  factory SimilarUser.fromJson(Map<String, dynamic> json) {
    return SimilarUser(
      userId: json['userId'] ?? json['UserId'] ?? 0,
      userName: json['userName'] ?? json['UserName'] ?? '',
      similarityScore: (json['similarityScore'] ?? json['SimilarityScore'] ?? 0.0).toDouble(),
      commonProducts: List<int>.from(json['commonProducts'] ?? json['CommonProducts'] ?? []),
    );
  }
}
