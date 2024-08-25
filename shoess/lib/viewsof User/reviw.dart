import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WriteReviewFillScreen extends StatefulWidget {
  WriteReviewFillScreen({Key? key, required this.chaletName, required this.chaletImageUrl}) : super(key: key);
  final String chaletName;
  final String chaletImageUrl;

  @override
  _WriteReviewFillScreenState createState() => _WriteReviewFillScreenState();
}

class _WriteReviewFillScreenState extends State<WriteReviewFillScreen> {
  TextEditingController addReviewController = TextEditingController();
  int rating = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: _buildAppBar(context),
        body: Container(
          width: double.maxFinite,
          padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 27.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReview(context),
              SizedBox(height: 22.0),
              Text('Write Your Review', style: TextStyle(fontSize: 18.0)),
              SizedBox(height: 13.0),
              TextField(
                controller: addReviewController,
                decoration: InputDecoration(
                  hintText: 'Add Review',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 17.0),
                ),
                maxLines: 8,
                textInputAction: TextInputAction.done,
              ),
              SizedBox(height: 5.0),
            ],
          ),
        ),
        bottomNavigationBar: _buildWriteReviewButton(context),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          onTapArrowLeft(context);
        },
      ),
      title: Text('Write Review'),
    );
  }

  Widget _buildReview(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 343.0,
          child: Text(
            'تقييماتك تهمنا لمزيد من التقدم',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 16.0),
          ),
        ),
        SizedBox(height: 13.0),
        Row(
          children: [
            _buildStarIcon(context, 1),
            _buildStarIcon(context, 2),
            _buildStarIcon(context, 3),
            _buildStarIcon(context, 4),
            _buildStarIcon(context, 5),
          ],
        ),
      ],
    );
  }

  Widget _buildStarIcon(BuildContext context, int starRating) {
    return GestureDetector(
      onTap: () {
        setState(() {
          rating = starRating;
        });
      },
      child: Icon(
        Icons.star,
        size: 32.0,
        color: starRating <= rating ? Colors.amber : Colors.grey,
      ),
    );
  }

  Widget _buildWriteReviewButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        saveReview();
      },
      child: Text('Write Review'),
    );
  }

  Future<void> saveReview() async {
    String review = addReviewController.text;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Create a new review document
        await FirebaseFirestore.instance.collection('reviews').add({
          'rating': rating,
          'review': review,
          'chaletName': widget.chaletName, // اسم الشالية
          'chaletImageUrl': widget.chaletImageUrl, // رابط صورة الشالية
          'userId': user.uid, // معرف المستخدم الذي قام بالتقييم والتعليق
          'userName': user.displayName ?? user.email, // اسم المستخدم
          'timestamp': FieldValue.serverTimestamp(), // تاريخ ووقت إضافة التقييم
        });

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Review saved successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      } catch (error) {
        // Error occurred while saving the review
        // Handle the error or show an error message
      }
    }
  }

  void onTapArrowLeft(BuildContext context) {
    Navigator.pop(context);
  }
}
