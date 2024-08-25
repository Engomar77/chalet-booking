import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shoess/viewsof%20User/search.dart';

import 'CustomerChaletList.dart';
import 'NotificationsPage.dart';
import 'contact.dart';
import 'home.dart';
import 'massegecus.dart';
import 'mybooking.dart';
import 'offer.dart';




class welcome extends StatefulWidget {
  const welcome({super.key});

  @override
  State<welcome> createState() => _welcomeState();
}

class _welcomeState extends State<welcome> {
  int myCurrentIndex = 0;
  List pages =  [
    CustomerChaletPage(),
    CustomerChaletofferPage(),
    SearchChaletsScreen(),
    ProfilePage(),
    NotificationsPage(),
    ContactPage(),
    massegecast(currentUserEmail: '',),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
       automaticallyImplyLeading: false,
       title: Text('Customer CHALET'),
       actions: [
         IconButton(
           icon: Icon(Icons.exit_to_app),
           onPressed: ()async {
             GoogleSignIn googleSignIn = GoogleSignIn();
             googleSignIn.disconnect();
             await FirebaseAuth.instance.signOut();
             Navigator.push(
               context,
               MaterialPageRoute(builder: (context) =>HomePage()),
             );
             // معالجة حدث ضغط الزر
             }
         )

       ],
     ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 25,
              offset: const Offset(8, 20))
        ]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            // backgroundColor: Colors.transparent,
              selectedItemColor: Colors.redAccent,
              unselectedItemColor: Colors.black,
              currentIndex: myCurrentIndex,
              onTap: (index) {
                setState(() {
                  myCurrentIndex = index;
                });
              },
              items: [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
                BottomNavigationBarItem(icon: Icon(Icons.local_offer), label: "offer"),
                BottomNavigationBarItem(icon: Icon(Icons.search), label: "search"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.book), label: "MY BOOKING"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.notifications), label: "notifications"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.contacts), label: "contact"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.message), label: "Massege"),
              ]),
        ),
      ),
      body: pages[myCurrentIndex],
    );
  }
}

