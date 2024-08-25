import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:shoess/viewsof%20User/reviw.dart';

import 'compliemnt.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<String> reservationStatusList = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('حجوزاتي'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reservation')
            .where('user.email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
            .where('status', isEqualTo: 'مقبول')
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
                  final chaletprice = reservation['chalet']['price'] ?? '';
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
                          contentPadding: EdgeInsets.all(0),
                          leading: Container(
                            width: 100,
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Image.network(
                                reservation['chalet']['imageUrl'] ?? '',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          title: Text(
                            'name of chalet: $chaletName',
                            textAlign: TextAlign.start,
                            textDirection: TextDirection.ltr,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'start Date: $startDate',
                                textDirection: TextDirection.rtl,
                              ),
                              Text(
                                'End Date: $endDate',
                                textDirection: TextDirection.rtl,
                              ),
                              Text('الحالة: $state'),
                              Text('email of owner: $userEmail'),
                              Text('price of chalet: $chaletprice'),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [

                              SizedBox(width: 16),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: TextButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => WriteReviewFillScreen(
                                          chaletName: reservation['chalet']['nameofchalet'],
                                          chaletImageUrl: reservation['chalet']['imageUrl'],
                                          // قم بتمرير أي بيانات إضافية تحتاجها هنا
                                        ),
                                      ),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.star,
                                    color: Colors.white, // لون الأيقونة
                                  ),
                                  label: Text(
                                    'قم بتقيمنا',
                                    style: TextStyle(
                                      color: Colors.white, // لون النص
                                      fontWeight: FontWeight.bold, // خط عميق
                                    ),
                                  ),
                                  style: ButtonStyle(
                                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                                      EdgeInsets.symmetric(horizontal: 16),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: TextButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ComplaintPage(
                                          chaletName: reservation['chalet']['nameofchalet'],
                                          chaletImageUrl: reservation['chalet']['imageUrl'],
                                          userEmail: reservation['chalet']['provider']['email'] ,
                                          // قم بتمرير أي بيانات إضافية تحتاجها هنا
                                        ),
                                      ),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.report,
                                    color: Colors.white, // لون الأيقونة
                                  ),
                                  label: Text(
                                    'الشكاوي',
                                    style: TextStyle(
                                      color: Colors.white, // لون النص
                                      fontWeight: FontWeight.bold, // خط عميق
                                    ),
                                  ),
                                  style: ButtonStyle(
                                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                                      EdgeInsets.symmetric(horizontal: 16),
                                    ),
                                  ),
                                ),
                              ),
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