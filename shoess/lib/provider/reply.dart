import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReplyScreen extends StatefulWidget {
  final String chaletName;
  final String userName;

  ReplyScreen({required this.chaletName, required this.userName});

  @override
  _ReplyScreenState createState() => _ReplyScreenState();
}

class _ReplyScreenState extends State<ReplyScreen> {
  TextEditingController replyController = TextEditingController();
  late String currentUserEmail;

  @override
  void initState() {
    super.initState();
    getUserEmail();
  }

  Future<void> getUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserEmail = user.email ?? '';
      });
    }
  }

  Future<void> sendReply() async {
    String reply = replyController.text;
    try {
      QuerySnapshot reviewSnapshot = await FirebaseFirestore.instance
          .collection('reviews')
          .where('userName', isEqualTo: widget.userName)
          .get();

      if (reviewSnapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot doc in reviewSnapshot.docs) {
          String commenterEmail = doc['userId'];

          await FirebaseFirestore.instance.collection('replies').add({
            'chaletName': widget.chaletName,
            'reviewId': widget.userName,
            'reply': reply,
            'senderEmail': currentUserEmail,
            'recipientEmail': commenterEmail,
            'timestamp': FieldValue.serverTimestamp(),
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Replies sent successfully!'),
            duration: Duration(seconds: 2),
          ),
        );

        replyController.clear();
      } else {
        throw 'Error: Unable to find the specified review!';
      }
    } catch (error) {
      print(error);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reply'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chalet name: ${widget.chaletName}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 10),
            TextField(
              controller: replyController,
              decoration: InputDecoration(
                hintText: 'Your reply...',
                border: OutlineInputBorder(),
              ),
              maxLines: 8,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: sendReply,
              style: ElevatedButton.styleFrom(
                primary: Colors.black, // خلفية الزر سوداء
                onPrimary: Colors.white, // لون النص أبيض
                elevation: 3, // الرفعة
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // شكل الزر مستدير
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.send, color: Colors.white), // إضافة أيقونة إرسال
                    SizedBox(width: 5), // تباعد بسيط بين الأيقونة والنص
                    Text(
                      'Send',
                      style: TextStyle(fontSize: 16), // حجم النص
                    ),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
