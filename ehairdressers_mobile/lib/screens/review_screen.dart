import 'package:flutter/material.dart';
import 'package:ehairdressers_mobile/models/review.dart';
import 'package:ehairdressers_mobile/providers/review_provider.dart';
import 'package:provider/provider.dart';

class ReviewScreen extends StatefulWidget {
  final int appointmentId;
  final int userId;
  final int serviceId;
  final int employeeId;
  final String serviceName;
  final String employeeName;
  final String appointmentDate;
  final String appointmentTime;
  final int? duration;

  const ReviewScreen({
    Key? key,
    required this.appointmentId,
    required this.userId,
    required this.serviceId,
    required this.employeeId,
    required this.serviceName,
    required this.employeeName,
    required this.appointmentDate,
    required this.appointmentTime,
    this.duration,
  }) : super(key: key);

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  late ReviewProvider _reviewProvider;
  double _rating = 0.0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reviewProvider = context.read<ReviewProvider>();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_rating == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a rating')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final review = Review(
        reviewId: null,
        appointmentId: widget.appointmentId,
        userId: widget.userId,
        serviceId: widget.serviceId,
        employeeId: widget.employeeId,
        rating: _rating.toInt(),
        comment: _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
        reviewDate: DateTime.now().toUtc().toIso8601String(),
        isActive: true,
      );

      final result = await _reviewProvider.insertReview(review);

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Review submitted successfully!')),
        );
        Navigator.of(context).pop(true); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit review. Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting review: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Submit Review'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Appointment Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildDetailRow('Service', widget.serviceName),
                    _buildDetailRow('Employee', widget.employeeName),
                    _buildDetailRow('Date', widget.appointmentDate),
                    _buildDetailRow('Time', widget.appointmentTime),
                    if (widget.duration != null)
                      _buildDetailRow('Duration', '${widget.duration} minutes'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

           
            Text(
              'Rate your experience',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _rating = index + 1.0;
                    });
                  },
                  child: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    size: 40,
                    color: Colors.orange,
                  ),
                );
              }),
            ),
            SizedBox(height: 8),
            Center(
              child: Text(
                _rating == 0.0 
                    ? 'Tap to rate' 
                    : '${_rating.toInt()} star${_rating == 1 ? '' : 's'}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ),
            SizedBox(height: 24),

           
            Text(
              'Share your experience (optional)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tell us about your experience...',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange),
                ),
              ),
            ),
            SizedBox(height: 32),

                
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: _isSubmitting
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Submit Review',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
