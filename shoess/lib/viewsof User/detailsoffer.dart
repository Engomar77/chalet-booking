import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../components/my_button.dart';
import 'CustomDateRangePicker.dart';

class ChaletDetailsofferPage extends StatefulWidget {
  final Map<String, dynamic> chalet;
  final String imageUrl;
  DateTime? startDate;
  DateTime? endDate;

  ChaletDetailsofferPage({
    required this.chalet,
    required this.imageUrl, required provider,
  });

  @override
  _ChaletDetailsofferPageState createState() => _ChaletDetailsofferPageState();
}

class _ChaletDetailsofferPageState extends State<ChaletDetailsofferPage> {
  ReservationStatus _reservationStatus = ReservationStatus.pending;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text(
          'Chalet offer Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.grey[300],

      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.network(
                widget.imageUrl,
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildDetailItem(context, 'ايميل المالك', widget.chalet['provider']['email'] ?? ''),
                  _buildDetailItem(context, 'اسم الشالية', widget.chalet['nameofchalet'] ?? ''),
                  _buildDetailItem(context, 'سعر الشالية', widget.chalet['price'].toString() ?? ''),
                  _buildDetailItem(context, 'وصف الشالية', widget.chalet['describtion'] ?? ''),
                  _buildDetailItem(context, 'موقع الشالية', widget.chalet['location'] ?? ''),
                  _buildDetailItem(context, 'الخصم بمقدار', widget.chalet['discount'].toString() ?? ''),
                  _buildDetailItem(context, 'تاريخ بداية العرض', widget.chalet['startDate'].toDate() != null ? '${widget.chalet['startDate'].toDate().day}/${widget.chalet['startDate'].toDate().month}/${widget.chalet['startDate'].toDate().year}' : 'Not selected'),
                  _buildDetailItem(context, 'تاريخ نهاية العرض', widget.chalet['endDate'].toDate() != null ? '${widget.chalet['endDate'].toDate().day}/${widget.chalet['endDate'].toDate().month}/${widget.chalet['endDate'].toDate().year}' : 'Not selected'),


                  SizedBox(height: 20),
                  Text(

                    'Booking Dates:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,


                    ),

                  ),
                  SizedBox(height: 8),
                  CustomDateRangePicker(
                    onSelectedDateRange: (startDate, endDate) {
                      setState(() {
                        widget.startDate = startDate;
                        widget.endDate = endDate;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  _buildBookingButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildDetailItem(BuildContext context, String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.0),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 16.0),
      ],
    );
  }

  Widget _buildBookingButton(BuildContext context) {
    switch (_reservationStatus) {
      case ReservationStatus.pending:
        return MyButton(
          onTap: () => _createPendingReservation(context),
          text: 'REQUEST BOOKING',
        );
      case ReservationStatus.confirmed:
        return Text(
          'Reservation Confirmed!',
          style: TextStyle(color: Colors.green),
        );
      case ReservationStatus.rejected:
        return Text(
          'Reservation Rejected',
          style: TextStyle(color: Colors.red),
        );
    }
  }

  void _createPendingReservation(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _reservationStatus = ReservationStatus.pending;
      });

      // Check if there is already a reservation for the selected dates
      final querySnapshot = await FirebaseFirestore.instance
          .collection('reservation')
          .where('chalet', isEqualTo: widget.chalet)
          .where('start_date', isEqualTo: widget.startDate)
          .where('end_date', isEqualTo: widget.endDate)
          .where('status', isEqualTo:'مقبول') // تحقق من حالة الحجز
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Show a message that the period is already booked and confirmed
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('المعذرة'),
              content: Text('هذا التاريخ محجوز من قبل مستخدم اخر'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
        return; // Exit function to prevent further execution
      }

      try {
        // Create a new reservation document with "pending" status
        await FirebaseFirestore.instance.collection('reservation').add({
          'chalet': widget.chalet,
          'start_date': widget.startDate,
          'end_date': widget.endDate,
          'user': {
            'uid': user.uid,
            'email': user.email,
          },
          'status': ReservationStatus.pending.toString(),
        });

        // Show a message indicating that the request is pending
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('ارسال طلب حجزك'),
              content: Text('تم إرسال طلب الحجز الخاص بك. سيراجع مزود الشاليه الطلب وسيتم إعلامك بقرارهم.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } catch (e) {
        print('Error creating reservation: $e');
        setState(() {
          _reservationStatus = ReservationStatus.rejected;
        });
      }
    }
  }



  // التحقق من وجود حجز مسبق للتواريخ المحددة

}

enum ReservationStatus { pending, confirmed, rejected }