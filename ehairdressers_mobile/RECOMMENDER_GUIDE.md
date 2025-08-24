# 🎯 eHairdressers Mobile App - Recommender System Guide

## 📋 Overview
The eHairdressers mobile app features a sophisticated recommender system that provides personalized product suggestions using multiple strategies including collaborative filtering, content-based filtering, and hybrid approaches.

## 🏗️ Architecture

### Core Components
- **RecommendationProvider**: Main provider class handling API calls
- **BaseProvider**: Common functionality for all providers
- **Data Models**: Recommendation, SimilarUser, Product models
- **API Layer**: HTTP communication with backend services

### Data Flow
```
User Request → Flutter App → API Endpoint → Backend Algorithm → Database → Response → UI Display
```

## 🔧 Implementation

### 1. Provider Registration
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => RecommendationProvider()),
  ],
  child: MyApp(),
)
```

### 2. Basic Usage
```dart
// Get popular products
final recommendations = await provider.getPopularProducts(numberOfProducts: 10);

// Get personalized recommendations
final personalized = await provider.getRecommendations(
  userId: 123,
  numberOfRecommendations: 15,
  includeSimilarUsers: true,
);

// Get similar users
final similarUsers = await provider.getSimilarUsers(123);
```

### 3. UI Integration
```dart
Consumer<RecommendationProvider>(
  builder: (context, provider, child) {
    return FutureBuilder<List<Recommendation>>(
      future: provider.getRecommendations(userId: currentUserId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final rec = snapshot.data![index];
              return RecommendationCard(recommendation: rec);
            },
          );
        }
        return CircularProgressIndicator();
      },
    );
  },
)
```

## 🔌 API Endpoints

### Base URL: `http://10.0.2.2:7052/api/Recommendation/`

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/popular-products` | Most popular products |
| POST | `/recommendations` | Personalized recommendations |
| GET | `/similar-users/{userId}` | Users with similar preferences |
| GET | `/new-user-recommendations` | General recommendations for new users |
| GET | `/category-recommendations/{userId}` | Category-based suggestions |

### Authentication
All endpoints use Basic Authentication with user credentials stored in the `Authorization` static class.

## 📱 Data Models

### Recommendation Model
```dart
class Recommendation {
  final int productId;
  final String productName;
  final String? description;
  final double? price;
  final String? imageUrl;
  final double? recommendationScore;
  final String? reason;
  final List<String>? similarUsers;
}
```

### SimilarUser Model
```dart
class SimilarUser {
  final int userId;
  final String userName;
  final double similarityScore;
  final List<int> commonProducts;
}
```

## 🎯 Recommendation Strategies

### 1. Popular Products (Collaborative Filtering)
- Recommends products popular across all users
- Useful for new users or limited personalization data

### 2. Personalized Recommendations (Hybrid)
- Combines user history, preferences, and behavior patterns
- Core recommendation engine for returning users

### 3. Similar Users (User-Based Collaborative)
- Identifies users with similar preferences
- Social discovery through peer recommendations

### 4. New User Recommendations (Cold Start)
- General recommendations for first-time users
- Based on overall popularity and category preferences

### 5. Category-Based (Content-Based)
- Analyzes user's preferred product categories
- Helps explore areas of interest

## 🔍 Error Handling

### Comprehensive Error Management
```dart
try {
  var response = await http!.get(uri, headers: headers);
  
  if (isValidResponseCode(response)) {
    var jsonData = json.decode(response.body);
    if (jsonData is List) {
      return jsonData.map((item) => Recommendation.fromJson(item)).toList();
    }
    return [];
  } else {
    print('Error: ${response.statusCode}');
    return [];
  }
} catch (e) {
  print('Exception: $e');
  return [];
}
```

### Common Issues & Solutions

#### Empty Recommendation Lists
- **Cause**: User not authenticated, backend services down, API configuration issues
- **Solution**: Check authentication, verify API endpoints, ensure backend running

#### Slow Loading
- **Cause**: Network issues, large datasets, inefficient queries
- **Solution**: Implement caching, optimize database queries, use pagination

#### Authentication Errors
- **Cause**: Missing credentials, expired tokens, malformed headers
- **Solution**: Verify user login, check token validity, ensure proper header format

## 🚀 Performance Optimization

### 1. Caching Strategy
- In-memory caching during app session
- Separate caches for popular products and user-specific recommendations
- Configurable cache expiration times

### 2. Lazy Loading
- On-demand loading when screens accessed
- Pagination support for large recommendation lists
- Background loading for improved UX

### 3. Network Optimization
- HTTP client with connection pooling
- Request timeout handling
- Error retry mechanisms

## 📊 Monitoring & Debugging

### Logging
```dart
print('Popular products response: ${response.statusCode}');
print('Recommendations response: ${response.statusCode}');
print('Similar users response: ${response.statusCode}');
```

### Error Tracking
- HTTP status code monitoring
- Exception logging with stack traces
- Response validation and categorization

## 🔒 Security

### Authentication
- Basic Authentication for all API calls
- Credential validation before requests
- Secure header management

### Data Privacy
- User preference controls
- Personalization opt-out options
- Data sanitization for privacy compliance

## 📈 Future Enhancements

### Planned Features
1. **Real-time Updates**: SignalR integration for live recommendations
2. **Machine Learning**: Advanced ML algorithms for better predictions
3. **A/B Testing**: Framework for testing recommendation strategies
4. **Analytics Dashboard**: Performance insights and metrics
5. **Offline Support**: Local caching for offline access

### Scalability Considerations
- Microservices architecture for recommendation engine
- Redis caching for high-performance data access
- Load balancing for API endpoints
- Database optimization for large datasets

## 📚 Best Practices

### Development Guidelines
1. Always handle API errors gracefully with user-friendly messages
2. Implement proper loading states for better UX
3. Use appropriate data models for type safety
4. Follow Flutter provider patterns for state management
5. Implement proper error boundaries and fallback UI

### API Design Principles
1. Use consistent endpoint naming conventions
2. Implement proper HTTP status codes
3. Provide meaningful error messages
4. Support pagination for large datasets
5. Use appropriate HTTP methods

## 🔗 Integration Points

### Dependencies
- **BaseProvider**: Common API functionality and authentication
- **Product Model**: Product data structure and serialization
- **Authorization Class**: User credential management
- **HTTP Client**: Network communication layer

### Related Systems
- **User Authentication**: Login and session management
- **Product Catalog**: Product information and images
- **Shopping Cart**: Purchase flow integration
- **User Profile**: Preference and history tracking

## ⚠️ Troubleshooting Checklist

- [ ] Verify user authentication status
- [ ] Check API endpoint configuration
- [ ] Ensure backend services are running
- [ ] Validate network connectivity
- [ ] Review error logs and status codes
- [ ] Test with different user accounts
- [ ] Verify data model serialization
- [ ] Check provider registration

## 📞 Support

For technical questions or issues:
- **Development Team**: Contact the development team
- **API Documentation**: Refer to backend API documentation
- **Flutter Resources**: [flutter.dev](https://flutter.dev)
- **Provider Package**: [pub.dev](https://pub.dev/packages/provider)

---

**Document Version**: 1.0  
**Last Updated**: December 2024  
**Maintained By**: Development Team
