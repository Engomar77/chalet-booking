import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoess/admin/replaycomplement.dart';
import 'package:shoess/provider/reply.dart';
class ComplaintsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complaints'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('complaints').snapshots(),
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
          final complaints = snapshot.data!.docs;
          return ListView.builder(
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              final complaint = complaints[index].data() as Map<String, dynamic>;
              return Card(
                elevation: 3,
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(
                    'Chalet name: ${complaint['chaletName']}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5),
                      Text(
                        'Complaint: ${complaint['complaint']}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'User Email: ${complaint['userName']}',
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
                          builder: (context) => ReplycomScreen(
                            chaletName: complaint['chaletName'], // اسم الشالية
                            userName: complaint['userName'], // اسم المستخدم الذي قام بالشكوى
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black, // خلفية الزر سوداء
                      foregroundColor: Colors.white, // لون النص أبيض
                      elevation: 3, // الرفعة
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), // شكل الزر مستدير
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.reply, color: Colors.white), // إضافة أيقونة الرد
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
