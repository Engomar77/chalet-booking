import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../components/my_button.dart';
import '../components/my_textfield.dart';
import 'homepro.dart';
class AddChalet extends StatefulWidget {
  AddChalet({Key? key}) : super(key: key);

  @override
  _AddChaletState createState() => _AddChaletState();
}

class _AddChaletState extends State<AddChalet> {
  File? file;
  String? imageUrl;
  final nameofchaletController = TextEditingController();
  final describtionController = TextEditingController();
  final locationController = TextEditingController();
  final priceController = TextEditingController();
  final discountController = TextEditingController();
  bool hasOffers = false;
  double? price;
  DateTime? startDate;
  DateTime? endDate;
  double? discount;

  // New variable to store availability status
  bool isAvailable = true; // Default to true

  // Function to get image from gallery
  Future<void> getImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        file = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ADD CHALET'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Button for selecting image
                IconButton(
                  onPressed: getImage,
                  icon: Icon(Icons.add_a_photo),
                  tooltip: 'Select Image',
                ),
                SizedBox(height: 10),
                // Show selected image
                if (file != null) ...[
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: FileImage(file!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
                // Text fields for chalet details
                MyTextField(controller: nameofchaletController, hintText: 'Enter the name of chalet', obscureText: false,),
                SizedBox(height: 10),
                MyTextField(controller: describtionController, hintText: 'Enter the description of chalet', obscureText: false,),
                SizedBox(height: 10),
                MyTextField(controller: locationController, hintText: 'Enter the location of chalet',obscureText: false,),
                SizedBox(height: 10),
                MyTextField(controller: priceController, hintText: 'Enter the price of chalet',obscureText: false,),
                SizedBox(height: 10),
                // حقل الإدخال لتحديد ما إذا كان هناك عروض للشالية أم لا
                Row(
                  children: [
                    Text('Has Offers: '),
                    Checkbox(
                      value: hasOffers,
                      onChanged: (value) {
                        setState(() {
                          hasOffers = value!;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 10),
                // Switch to determine availability
                Row(
                  children: [
                    Text('Is Available: '),
                    Switch(
                      value: isAvailable,
                      onChanged: (value) {
                        setState(() {
                          isAvailable = value;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 10),
                // حقول التاريخ
                if (hasOffers) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2101),
                          );
                          if (picked != null) {
                            setState(() {
                              startDate = picked;
                            });
                          }
                        },
                        child: Text('Select Start Date'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2101),
                          );
                          if (picked != null) {
                            setState(() {
                              endDate = picked;
                            });
                          }
                        },
                        child: Text('Select End Date'),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
                // Display selected dates
                SizedBox(height: 20),
                if (startDate != null && endDate != null) ...[
                  Text(
                    'Start Date: ${startDate!.day}/${startDate!.month}/${startDate!.year}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'End Date: ${endDate!.day}/${endDate!.month}/${endDate!.year}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                ],
                // حقل الخصم
                if (hasOffers) ...[
                  MyTextField(controller: discountController, hintText: 'Enter the discount', obscureText: false,),
                  SizedBox(height: 10),
                ],
                // Buttons for adding chalet
                MyButton(
                  onTap: () async {
                    try {
                      // Upload image to Firebase Storage
                      if (file != null) {
                        final ref = FirebaseStorage.instance.ref().child('chalet_images').child(nameofchaletController.text + '.jpg');
                        final uploadTask = await ref.putFile(file!);
                        imageUrl = await uploadTask.ref.getDownloadURL();
                      }

                      // Get price as double
                      price = double.tryParse(priceController.text) ?? 0.0;

                      // Get discount as double if offers available
                      if (hasOffers) {
                        discount = double.tryParse(discountController.text) ?? 0.0;
                      }

                      // Get current user
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        // Initialize Firestore
                        final firestore = FirebaseFirestore.instance;

                        // Start a Firestore transaction
                        await firestore.runTransaction((transaction) async {
                          // Add chalet data to Firestore collection 'chalets'
                          DocumentReference chaletRef = firestore.collection('chalets').doc();
                          await transaction.set(chaletRef, {
                            'nameofchalet': nameofchaletController.text,
                            'describtion': describtionController.text,
                            'location': locationController.text,
                            'price': price,
                            'imageUrl': imageUrl,
                            'hasOffers': hasOffers,
                            'isAvailable': isAvailable, // Add availability status
                            // Add start and end dates if offers are available
                            if (hasOffers) 'startDate': startDate,
                            if (hasOffers) 'endDate': endDate,
                            if (hasOffers)  'discount': discount,
                            'provider': {
                              'uid': user.uid,
                              'email': user.email,
                            },
                          });
                        });

                        // Show success message
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text('نجاح'),
                            content: Text('تم اضافة الشالية بنجاح'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => homepro()));
                                },
                                child: Text('OK'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        print('User not signed in');
                      }
                    } catch (e) {
                      print(e);
                    }
                  },
                  text: 'ADD CHALET',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
