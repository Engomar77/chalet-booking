import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'package:shoess/provider/loginpro.dart';

import '../admin/adminlogin.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Stack(
      children: [
        Positioned(
          top: 150,
          left: 50,
          child: Image.asset('images/chalet.jpg', width: 300, height: 200),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 250),
          child: Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => loginadmin()),
                    );
                  },
                  child: const Text('Login as an admin',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: BorderSide(color: Colors.brown),
                    minimumSize: Size(350, 50),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, 'LoginPage');

                  },
                  child: const Text('Login as a Customer',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: BorderSide(color: Colors.brown),
                    minimumSize: Size(350, 50),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, 'LoginPro');


                  },
                  child: const Text('Login as a provider',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: BorderSide(color: Colors.brown),
                    minimumSize: Size(350, 50),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
    );
  }
}

