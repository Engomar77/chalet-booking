import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';



class CustomerLikedPage extends StatelessWidget {
  final List<Map<String, dynamic>> likedChalets;

  const CustomerLikedPage({
    Key? key,
    required this.likedChalets,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liked Chalets'),
      ),
      body: ListView.builder(
        itemCount: likedChalets.length,
        itemBuilder: (context, index) {
          final chalet = likedChalets[index];
          return ListTile(
            title: Text(chalet['nameofchalet']),
            subtitle: Text(chalet['price'].toString()),

            leading: Image.network(
              chalet['imageUrl'],
              width: 100, // تحديد عرض الصورة حسب الرغبة
              height: 100, // تحديد ارتفاع الصورة حسب الرغبة
              fit: BoxFit.cover, // ضبط تناسب الصورة داخل المساحة المخصصة لها
            ),
            // يمكنك إضافة المزيد من البيانات التي تريد عرضها هنا
          );
        },
      ),
    );
  }
}
