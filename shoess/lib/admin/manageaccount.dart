import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class manageadmin extends StatefulWidget {
  const manageadmin({Key? key}) : super(key: key);

  @override
  _manageadminState createState() => _manageadminState();
}

class _manageadminState extends State<manageadmin> {
  late Future<List<DocumentSnapshot>> users;

  @override
  void initState() {
    super.initState();
    users = getUsers();
  }

  Future<List<DocumentSnapshot>> getUsers() async {
    try {
      QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();

      if (usersSnapshot.docs.isNotEmpty) {
        return usersSnapshot.docs;
      } else {
        print('No users found.');
        return [];
      }
    } catch (error) {
      print('Error fetching users: $error');
      return [];
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      print('User deleted successfully!');
    } catch (error) {
      print('Error deleting user: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Admins'),
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: users,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            List<DocumentSnapshot>? usersList = snapshot.data;
            return ListView.builder(
              itemCount: usersList!.length,
              itemBuilder: (context, index) {
                var userData = usersList[index].data() as Map<String, dynamic>;
                return Card(
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Name: ${userData['name'] ?? 'No Name'}'),
                        Text('Email: ${userData['email'] ?? 'No Email'}'),
                        Text('Address: ${userData['address'] ?? 'No Address'}'),
                        Text('Phone: ${userData['phone'] ?? 'No Phone'}'),
                      ],
                    ),
                    // Add other user details here
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      color: Colors.black, // تحديد لون الخلفية
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Delete User'),
                              content: Text('Are you sure you want to delete this user?'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    deleteUser(usersList[index].id);
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(
                                      color: Colors.black, // تحديد لون النص
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),

                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
