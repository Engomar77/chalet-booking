import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ReplycomScreen extends StatefulWidget {
  final String chaletName;
  final String userName;

  ReplycomScreen({required this.chaletName, required this.userName});

  @override
  _ReplycomScreenState createState() => _ReplycomScreenState();
}

class _ReplycomScreenState extends State<ReplycomScreen> {
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
      // إرسال الرد على الشكوى إلى مجموعة بيانات جديدة للردود
      await FirebaseFirestore.instance.collection('complaint_replies').add({
        'chaletName': widget.chaletName,
        'userName': widget.userName,
        'reply': reply,
        'senderEmail': currentUserEmail,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reply sent successfully!'),
          duration: Duration(seconds: 2),
        ),
      );

      replyController.clear();
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
                hintText: 'Your reply...', // تغيير نص النصائح ليناسب الرد على الشكوى
                border: OutlineInputBorder(),
              ),
              maxLines: 8,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: sendReply, // تغيير الوظيفة المسؤولة عن إرسال الرد
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
