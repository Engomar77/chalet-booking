import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shoess/viewsof%20User/welcome.dart';

import '../components/my_button.dart';
import '../components/my_textfield.dart';

import 'loginpro.dart';

class User {
  final String name;
  final String email;
  final String password;
  final String address;
  final String phone;

  User({
    required this.name,
    required this.email,
    required this.password,
    required this.address,
    required this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'address': address,
      'phone': phone,
    };
  }
}

class SignupPro extends StatefulWidget { // تحويل الفئة إلى StatefulWidget
  SignupPro({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPro> { // إضافة الحالة للفئة
  bool isPasswordHidden = true;

  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final adressController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                const Icon(Icons.person_add, size: 100),
                const SizedBox(height: 50),
                Text(
                  'Create a new account PROVIDER',
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                ),
                const SizedBox(height: 25),
                MyTextField(
                  controller: emailController,
                  hintText: 'ENTER YOUR Email',
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: nameController,
                  hintText: 'ENTER YOUR NAME',
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: passwordController,
                  hintText: 'ENTER YOUR PASSWORD',
                  obscureText: isPasswordHidden,
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordHidden ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordHidden = !isPasswordHidden;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: adressController,
                  hintText: 'ENTER YOUR ADRESS',
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: phoneController,
                  hintText: 'ENTER YOUR PHONE',
                  obscureText: false,
                ),
                const SizedBox(height: 25),

                MyButton(
                  onTap: () async {
                    final user = User(
                      name: nameController.text,
                      email: emailController.text,
                      password: passwordController.text,
                      address: adressController.text,
                      phone: phoneController.text,
                    );
                    try {
                      final userCredential = await FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                        email: user.email,
                        password: user.password,
                      );
                      final uid = userCredential.user?.uid;

                      await FirebaseFirestore.instance
                          .collection('PROVIDER')
                          .doc(uid)
                          .set(user.toMap());
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPro()),
                      );
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'weak-password') {
                        print('The password provided is too weak.');
                      } else if (e.code == 'email-already-in-use') {
                        print('The account already exists for that email.');
                      }
                    } catch (e) {
                      print(e);
                    }
                  },
                  text: 'Sign Up',
                ),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPro()),
                        );
                      },
                      child: const Text(
                        'Login now',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
