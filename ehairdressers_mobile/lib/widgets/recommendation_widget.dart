import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ehairdressers_mobile/models/recommendation.dart';
import 'package:ehairdressers_mobile/models/product.dart';
import 'package:ehairdressers_mobile/providers/cart_provider.dart';
import 'package:ehairdressers_mobile/providers/recommendation_provider.dart';
import 'package:ehairdressers_mobile/utils/util.dart';
import 'package:provider/provider.dart';

class RecommendationWidget extends StatelessWidget {
  final List<Recommendation> recommendations;
  final String title;
  final String? subtitle;
  final VoidCallback? onProductTap;

  const RecommendationWidget({
    Key? key,
    required this.recommendations,
    required this.title,
    this.subtitle,
    this.onProductTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (recommendations.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12),
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              return _buildRecommendationCard(context, recommendations[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard(BuildContext context, Recommendation recommendation) {
    return Container(
      width: 160,
      margin: EdgeInsets.symmetric(horizontal: 4),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () {
            if (onProductTap != null) {
              onProductTap!();
            }
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Viewing ${recommendation.productName}'),
                duration: Duration(seconds: 1),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

               Container(
                 height: 100,
                 width: double.infinity,
                 decoration: BoxDecoration(
                   borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                   color: Colors.grey[100],
                 ),
                                   child: recommendation.imageUrl != null && recommendation.imageUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                          child: SizedBox(
                            width: double.infinity,
                            height: 100,
                            child: Image.memory(
                              base64Decode(recommendation.imageUrl!),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 100,
                            ),
                          ),
                        )
                      : _buildImagePlaceholder(),
               ),
    
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    Text(
                      recommendation.productName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    if (recommendation.price != null) ...[
                      Text(
                        '\$${recommendation.price!.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                                         if (recommendation.recommendationScore != null) ...[
                       SizedBox(height: 4),
                       Row(
                         children: [
                           Icon(
                             Icons.trending_up,
                             size: 16,
                             color: Colors.green,
                           ),
                           SizedBox(width: 4),
                           Text(
                             '${recommendation.recommendationScore!.toStringAsFixed(0)}',
                             style: TextStyle(
                               fontSize: 12,
                               fontWeight: FontWeight.bold,
                               color: Colors.green[700],
                             ),
                           ),
                         ],
                       ),
                     ],
                     if (recommendation.reason != null) ...[
                       SizedBox(height: 2),
                       Text(
                         recommendation.reason!,
                         style: TextStyle(
                           fontSize: 10,
                           color: Colors.grey[600],
                         ),
                         maxLines: 1,
                         overflow: TextOverflow.ellipsis,
                       ),
                     ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[50]!, Colors.purple[50]!],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag,
              size: 30,
              color: Colors.grey[400],
            ),
            SizedBox(height: 4),
            Text(
              'Product',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecommendationSection extends StatefulWidget {
  final int userId;
  final List<Product> allProducts;

  const RecommendationSection({
    Key? key,
    required this.userId,
    required this.allProducts,
  }) : super(key: key);

  @override
  State<RecommendationSection> createState() => _RecommendationSectionState();
}

class _RecommendationSectionState extends State<RecommendationSection> {
  List<Recommendation> popularProducts = [];
  List<Recommendation> personalizedRecommendations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadRecommendations();
  }

  Future<void> loadRecommendations() async {
    setState(() {
      isLoading = true;
    });

    try {
      
      var popular = await context.read<RecommendationProvider>().getPopularProductsWithImages(
        allProducts: widget.allProducts,
        numberOfProducts: 10,
      );
      
      
      var personalized = await context.read<RecommendationProvider>().getRecommendationsWithImages(
        userId: widget.userId,
        allProducts: widget.allProducts,
        numberOfRecommendations: 10,
        includeSimilarUsers: true,
        fromDate: "2024-01-01T00:00:00",
        toDate: "2024-12-31T23:59:59",
      );

      
      if (personalized.isEmpty) {
        var categoryRecs = await context.read<RecommendationProvider>().getCategoryRecommendations(widget.userId);
        if (categoryRecs.isNotEmpty) {
          personalized = categoryRecs;
        }
      }

      
      if (personalized.isEmpty) {
        var newUserRecs = await context.read<RecommendationProvider>().getNewUserRecommendations();
        if (newUserRecs.isNotEmpty) {
          personalized = newUserRecs;
        }
      }

      setState(() {
        popularProducts = popular;
        personalizedRecommendations = personalized;
        isLoading = false;
      });
    } catch (e) {
      
      setState(() {
        popularProducts = [];
        personalizedRecommendations = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      children: [
        
        if (personalizedRecommendations.isNotEmpty)
          RecommendationWidget(
            recommendations: personalizedRecommendations,
            title: 'Recommended for You',
            subtitle: 'Based on your preferences',
          ),
        
        SizedBox(height: 16),
        
        if (popularProducts.isNotEmpty)
          RecommendationWidget(
            recommendations: popularProducts,
            title: 'Popular Products',
            subtitle: 'Trending now',
          ),
      ],
    );
  }
}
