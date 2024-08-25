import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../components/my_button.dart';
import '../components/my_textfield.dart';
import '../components/square_tile.dart';
import 'adminhome.dart';

class loginadmin extends StatefulWidget {
  loginadmin({Key? key}) : super(key: key);

  @override
  _loginadminState createState() => _loginadminState();
}

class _loginadminState extends State<loginadmin> {
  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isPasswordHidden = true;
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

                // logo
                const Icon(
                  Icons.lock,
                  size: 100,
                ),

                const SizedBox(height: 50),

                // welcome back, you've been missed!
                Text(
                  'WWLCOME ADMIN BACK YOU\'VE BEEN MISSED!',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 25),

                // username textfield
                MyTextField(
                  controller: emailController,
                  hintText: 'ENTER YOUR Email',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                // password textfield
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

                // forgot password?


                const SizedBox(height: 25),

                // sign in button

                MyButton(
                  onTap: () async {
                    try {
                      // التحقق مما إذا كان البريد الإلكتروني غير موجود في مجموعة "users"
                      final userExistence = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: emailController.text).get();
                      // التحقق مما إذا كان البريد الإلكتروني غير موجود في مجموعة "PROVIDER"
                      final PROVIDERExistence = await FirebaseFirestore.instance.collection('PROVIDER').where('email', isEqualTo: emailController.text).get();
                      // التحقق مما إذا كان البريد الإلكتروني موجود في مجموعة "admin"
                      final adminExistence = await FirebaseFirestore.instance.collection('admin').where('email', isEqualTo: emailController.text).get();

                      if (userExistence.docs.isNotEmpty || PROVIDERExistence.docs.isNotEmpty) {
                        // إذا كان البريد الإلكتروني موجودًا في أحد المجموعتين، فعرض رسالة للمستخدم وانهي الوظيفة
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("خطأ في تسجيل الدخول"),
                              content: Text("لا يمكن لك الدخول لهذه الصفحة. ليس لديك الصلاحية."),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text("موافق"),
                                ),
                              ],
                            );
                          },
                        );
                        return; // انهاء الوظيفة لمنع الدخول
                      }

                      // إذا كان البريد الإلكتروني موجودًا في مجموعة "admin"، قم بتسجيل الدخول وانتقل إلى واجهة المستخدم الخاصة بالمسؤول
                      if (adminExistence.docs.isNotEmpty) {
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                          email: emailController.text,
                          password: passwordController.text,
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => adminhome()),
                        );
                        return;
                      }

                      // إذا لم يكن البريد الإلكتروني موجودًا في أي من المجموعات، عرض رسالة خطأ
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("خطأ في تسجيل الدخول"),
                            content: Text("البريد الإلكتروني أو كلمة المرور غير صحيحة."),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text("موافق"),
                              ),
                            ],
                          );
                        },
                      );
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'user-not-found') {
                        print('No user found for that email.');
                      } else if (e.code == 'wrong-password') {
                        print('Wrong password provided for that user.');
                      }
                    } catch (e) {
                      print(e);
                    }
                  },
                  text: 'Sign Up',
                ),

                const SizedBox(height: 50),

                // or continue with

              ],
            ),
          ),
        ),
      ),
    );
  }
}
