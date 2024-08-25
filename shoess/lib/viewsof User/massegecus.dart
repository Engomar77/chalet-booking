import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class massegecast extends StatelessWidget {
  final String currentUserEmail;
   massegecast({required this.currentUserEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Messages'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('user_messages')
            .where('recipient', isEqualTo: FirebaseAuth.instance.currentUser!.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            List<QueryDocumentSnapshot> messages = snapshot.data!.docs;

            if (messages.isEmpty) {
              return Center(
                child: Text('No messages found.'),
              );
            }

            return ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                var message = messages[index];
                String senderEmail = message['sender'] ?? 'Unknown';
                String messageContent = message['message'] ?? 'No content';

                return Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8), // إضافة مسافة بين العناصر
                        Text(
                          'Sender: $senderEmail', // عنصر label لبريد المرسل
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8), // إضافة مسافة بين العناصر
                        Text(
                          'Message:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20, // تحديد حجم الخط
                          ),
                        ),
                        SizedBox(height: 4), // إضافة مسافة بين العناصر
                        Text(
                          messageContent,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18, // تحديد حجم الخط
                          ),
                        ),
                        SizedBox(height: 8), // إضافة مسافة بين العناصر
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
