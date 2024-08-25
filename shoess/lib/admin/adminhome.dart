import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shoess/admin/viewmassege.dart';

import '../viewsof User/home.dart';

import 'admincontac.dart';
import 'manageaccount.dart';
import 'omplantscrren.dart';

class adminhome extends StatelessWidget {
  const adminhome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('ADMIN HOME'),
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
              "Manage user",
              Icons.manage_accounts,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => manageadmin()),
                );

              },
            ),
            makeDashboardItem(
              "REPLAY COMPLANT",
              Icons.reply,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ComplaintsScreen()),
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
                  MaterialPageRoute(builder: (context) =>  AdminMessagesPage()),
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
                  MaterialPageRoute(builder: (context) =>  UserMessagesPage(currentUserEmail: '',)),
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
