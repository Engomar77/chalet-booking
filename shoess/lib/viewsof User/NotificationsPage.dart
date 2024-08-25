import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<String> reservationStatusList = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,

        title: Text('قائمة الحجوزات'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:FirebaseFirestore.instance
              .collection('reservation')
          .where(
          'user.email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
          .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final reservations = snapshot.data!.docs;
            return SingleChildScrollView(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: reservations.length,
                itemBuilder: (context, index) {
                  final reservation = reservations[index].data() as Map<String, dynamic>;
                  final chaletName = reservation['chalet']['nameofchalet'] ?? '';
                  final startDate = reservation['start_date']?.toDate() ?? DateTime.now();
                  final endDate = reservation['end_date']?.toDate() ?? DateTime.now();
                  final userEmail = reservation['chalet']['provider'] ['email'] ?? '';


                  final state = reservation['status'];

                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text('اسم الشاليه: $chaletName'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('تاريخ البدء: $startDate'),
                              Text('تاريخ الانتهاء: $endDate'),
                              Text('الحالة:$state'),

                              Text('بريد صاحب الشالية: $userEmail'),
                            ],
                          ),
                        ),


                      ],
                    ),
                  );
                },
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('خطأ: ${snapshot.error}'),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}