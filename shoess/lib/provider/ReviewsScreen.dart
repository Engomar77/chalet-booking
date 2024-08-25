import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoess/provider/reply.dart';

class ReviewsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reviews'),
      ),
      
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('reviews').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          final reviews = snapshot.data!.docs;
          return ListView.builder(
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index].data() as Map<String, dynamic>;
              int rating = review['rating'];
              return Card(
                elevation: 3,
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Chalet name: ${review['chaletName']}',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      // Replace the Row widget with SingleChildScrollView
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Text(
                              'Rating: ',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            // Add star icons based on rating
                            Row(
                              children: List.generate(
                                rating,
                                    (index) => Icon(Icons.star, color: Colors.amber, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ),

                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5),
                      Text(
                        'Review: ${review['review']}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'User Email: ${review['userName']}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      SizedBox(height: 5),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      // عند النقر على الزر "رد"
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReplyScreen(
                            chaletName: review['chaletName'], // اسم الشالية
                            userName: review['userName'], // اسم المستخدم الذي قام بالتعليق
                          ),
                        ),
                      );


                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.black, // خلفية الزر سوداء
                      onPrimary: Colors.white, // لون النص أبيض
                      elevation: 3, // الرفعة
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), // شكل الزر مستدير
                      ),
                    ),
                    child: Padding(
                      padding:  EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.reply, color: Colors.white), // إضافة أيقونة
                          SizedBox(width: 1), // تباعد بسيط بين الأيقونة والنص
                          Text(
                            'Reply',
                            style: TextStyle(fontSize: 16), // حجم النص
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
