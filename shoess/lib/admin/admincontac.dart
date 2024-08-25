import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../components/my_button.dart';
class AdminMessagesPage extends StatefulWidget {
  @override
  _AdminMessagesPageState createState() => _AdminMessagesPageState();
}

class _AdminMessagesPageState extends State<AdminMessagesPage> {
  String _selectedRole = '';
  String _selectedEmail = '';

  List<String> _roles = ['PROVIDER', 'users'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Provider Messages'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Role:'),
            DropdownButtonFormField<String>(
              value: _selectedRole.isNotEmpty ? _selectedRole : null,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedRole = newValue!;
                  _selectedEmail = ''; // Clear selected email when role changes
                });
              },
              items: _roles.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Choose Role',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20.0),
            _selectedRole.isNotEmpty
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Select Email:'),
                FutureBuilder<List<String>>(
                  future: _getEmails(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      List<String>? emails = snapshot.data;
                      return DropdownButtonFormField<String>(
                        value: _selectedEmail.isNotEmpty ? _selectedEmail : null,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedEmail = newValue!;
                          });
                        },
                        items: emails!.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          labelText: 'Choose Email',
                          border: OutlineInputBorder(),
                        ),
                      );
                    }
                  },
                ),
                SizedBox(height: 20.0),
                MyButton(
                  onTap: (){
                    // Navigate to contact form page
                    if (_selectedEmail.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ContactFormPage(email: _selectedEmail),
                        ),
                      );
                    }
                  },
                  text: 'Continue',
                ),
              ],
            )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Future<List<String>> _getEmails() async {
    List<String> emails = [];
    try {
      String collectionName = _selectedRole; // Use the selected role directly

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(collectionName).get();
      querySnapshot.docs.forEach((doc) {
        emails.add(doc['email']);
      });
    } catch (error) {
      print('Error fetching emails: $error');
    }
    return emails;
  }
}




class ContactFormPage extends StatelessWidget {
  final String email;
  final TextEditingController _messageController = TextEditingController();

  ContactFormPage({required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Form'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('To: $email'),
            SizedBox(height: 20.0),
            Text('Message:'),
            TextField(
              controller: _messageController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Type your message here...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20.0),
            MyButton(
              onTap: () {
                _sendMessage(context);
              },
              text: 'SEND',
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage(BuildContext context) {
    String messageText = _messageController.text.trim();

    if (messageText.isNotEmpty) {
      // Create a new document in Firestore to save the message data
      FirebaseFirestore.instance.collection('user_messages').add({
        'sender': FirebaseAuth.instance.currentUser!.email,
        'recipient': email,
        'message': messageText,
        'timestamp': DateTime.now(),
      }).then((value) {
        // After successfully saving the message, display a confirmation message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Message sent successfully'),
          ),
        );
        // Clear the message field content after sending
        _messageController.clear();
      }).catchError((error) {
        // In case of an error while saving the message, display the error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending message: $error'),
          ),
        );
      });
    } else {
      // If the message field is empty, display an alert message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a message'),
        ),
      );
    }
  }
}
