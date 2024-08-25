import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../viewsof User/CustomDateRangePicker.dart';

class RequestsPage extends StatefulWidget {
  @override
  _RequestsPageState createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  List<String> reservationStatusList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('قائمة الحجوزات'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:FirebaseFirestore.instance
            .collection('reservation')
            .where('status', whereNotIn: ['مقبول', 'مرفوض'])
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
                  final userEmail = reservation['user'] != null ? reservation['user']['email'] ?? '' : '';


                  final reservationStatus = reservationStatusList.length > index ? reservationStatusList[index] : '';

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
                              Text('بريد المستخدم: $userEmail'),
                            ],
                          ),
                        ),
                        if (reservationStatus.isEmpty)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              TextButton(
                                child: Text(
                                  'مقبول',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                                ),
                                onPressed: () {

                                  FirebaseFirestore.instance.collection('reservation').doc(reservations[index].id).update({
                                    'status': 'مقبول',
                                  });


                                },
                              ),
                              TextButton(
                                child: Text(
                                  'مرفوض',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                                ),
                                onPressed: () {
                                  // اتخاذ إجراء عند النقر على زر الرفض
                                  // يمكنك هنا عدم تخزين البيانات في Firestore

                                  // مثال على حفظ الحجز المرفوض في Firestore
                                  FirebaseFirestore.instance.collection('reservation').doc(reservations[index].id).update({
                                    'status': 'مرفوض',
                                  });


                                },
                              ),
                            ],
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