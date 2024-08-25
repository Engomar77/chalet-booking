import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ComplaintPage extends StatefulWidget {
  ComplaintPage({Key? key, required this.chaletName, required this.chaletImageUrl,required this.userEmail}) : super(key: key);
  final String chaletName;
  final String chaletImageUrl;
  final String userEmail;
  @override
  _ComplaintPageState createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ComplaintPage> {
  TextEditingController addComplaintController = TextEditingController();

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
              SizedBox(height: 22.0),
              Text('Write Your Complaint', style: TextStyle(fontSize: 18.0)),
              SizedBox(height: 13.0),
              TextField(
                controller: addComplaintController,
                decoration: InputDecoration(
                  hintText: 'Add Complaint',
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
        bottomNavigationBar: _buildWriteComplaintButton(context),
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
      title: Text('Complaints'),
    );
  }

  Widget _buildWriteComplaintButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        saveComplaint();
      },
      child: Text('Submit Complaint'),
    );
  }

  Future<void> saveComplaint() async {
    String complaint = addComplaintController.text;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Create a new complaint document
        await FirebaseFirestore.instance.collection('complaints').add({
          'complaint': complaint,
          'chaletName': widget.chaletName, // اسم الشالية
          'chaletImageUrl': widget.chaletImageUrl, // رابط صورة الشالية
          'userEmail':widget.userEmail,
          'userId': user.uid, // معرف المستخدم الذي قام بالشكوى
          'userName': user.displayName ?? user.email, // اسم المستخدم
          'timestamp': FieldValue.serverTimestamp(), // تاريخ ووقت إضافة الشكوى
        });

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Complaint submitted successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      } catch (error) {
        // Error occurred while saving the complaint
        // Handle the error or show an error message
      }
    }
  }

  void onTapArrowLeft(BuildContext context) {
    Navigator.pop(context);
  }
}
