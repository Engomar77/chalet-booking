



import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shoess/provider/loginpro.dart';
import 'package:shoess/provider/providercontact.dart';
import 'package:shoess/provider/viewchaletswithoffer.dart';
import 'package:shoess/provider/viwe.dart';

import '../viewsof User/home.dart';
import 'ReviewsScreen.dart';
import 'chalet.dart';
import 'manage.dart';
import 'massegeviwe.dart';

class homepro extends StatelessWidget {
  const homepro({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('PROVIDER CHALET'),
        actions: [
          IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: ()async {
                await FirebaseAuth.instance.signOut();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
                // معالجة حدث ضغط الزر
              }
          )

        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 2.0),
        child: GridView.count(
          crossAxisCount: 2,
          padding: EdgeInsets.all(3.0),
          children: <Widget>[
            makeDashboardItem(
              "ADD SHALET",
              Icons.add_home,
                  () {
                // توجيه المستخدم إلى شاشة ADD SHALET
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddChalet()),
                );
              },
            ),
            makeDashboardItem(
              "UPDATE AND DELET",
              Icons.update,
                  () {
                // توجيه المستخدم إلى شاشة UPDATE AND DELET
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChaletList()),
                );
              },
            ),
            makeDashboardItem(
              "UPDATE AND DELET with offer",
              Icons.local_offer,
                  () {
                // توجيه المستخدم إلى شاشة UPDATE AND DELET
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChaletsWithOffersPage()),
                );
              },
            ),
            makeDashboardItem(
              "ACCEPT AND REJECT BOOKING",
              Icons.manage_accounts,
                  () {
                // توجيه المستخدم إلى شاشة UPDATE AND DELET
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RequestsPage()),
                );
              },
            ),
            makeDashboardItem(
              "SEE ALL REVIEW",
              Icons.reviews,
                  () {
                // توجيه المستخدم إلى شاشة ADD SHALET
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReviewsScreen()),
                );
              },
            ),
            makeDashboardItem(
              "send massege",
              Icons.mark_as_unread_sharp,
                  () {
                // توجيه المستخدم إلى شاشة ADD SHALET
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProviderMessagesPage()),
                );
              },
            ),
            makeDashboardItem(
              "reseive massege",
              Icons.mail,
                  () {
                // توجيه المستخدم إلى شاشة ADD SHALET
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  massegeviewprovider(currentUserEmail: '',)),
                );
              },
            ),
          ],
        ),
      ),
    );

  }
  Card makeDashboardItem(String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 1.0,
      margin: EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(color: Color.fromRGBO(220, 220, 220, 1.0)),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            verticalDirection: VerticalDirection.down,
            children: <Widget>[
              SizedBox(height: 50.0),
              Center(
                child: Icon(
                  icon,
                  size: 40.0,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20.0),
              Center(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 18.0, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
