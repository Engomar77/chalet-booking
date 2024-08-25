
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shoess/provider/loginpro.dart';
import 'package:shoess/viewsof%20User/home.dart';
import 'package:shoess/viewsof%20User/login.dart';
import 'package:shoess/viewsof%20User/search.dart';
import 'package:shoess/viewsof%20User/sinup.dart';

import 'provider/ReviewsScreen.dart';
import 'admin/manageaccount.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(

  );
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),

      home: HomePage(),
    routes: {
      "LoginPage" :(context)=>LoginPage(),
        "SignupPage" :(context)=>SignupPage(),
      "LoginPro" :(context)=>LoginPro(),

    },
    );
  }
}
