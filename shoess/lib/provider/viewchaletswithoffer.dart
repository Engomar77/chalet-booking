import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import '../components/my_button.dart';

class ChaletsWithOffersPage extends StatefulWidget {
  @override
  _ChaletsWithOffersPageState createState() => _ChaletsWithOffersPageState();
}

class _ChaletsWithOffersPageState extends State<ChaletsWithOffersPage> {
  late final CollectionReference chaletsref;
  late Stream<QuerySnapshot> _chaletsStream;

  @override
  void initState() {
    super.initState();
    chaletsref = FirebaseFirestore.instance.collection('chalets');

    _chaletsStream = FirebaseFirestore.instance
        .collection('chalets')
        .where('provider.email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
        .where('hasOffers', isEqualTo: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chalet List'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _chaletsStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final chalets = snapshot.data!.docs;
            return ListView.builder(
              itemCount: chalets.length,
              itemBuilder: (context, index) {
                final chalet = chalets[index].data() as Map<String, dynamic>;
                return Card(
                  elevation: 2,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(0),
                    leading: _buildLeadingImage(chalet),
                    title: Text(
                      'nameofchalet: ${chalet['nameofchalet']}',
                      textAlign: TextAlign.start,
                      textDirection: TextDirection.ltr,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Price: ${chalet['price']}'),
                        SizedBox(height: 5),
                        Text('Discount: ${chalet['discount']}'),
                        SizedBox(height: 5),
                        Text('Availability: ${chalet['isAvailable'] ? 'Available' : 'Closed'}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Delete Chalet'),
                                  content: Text(
                                      'Are you sure you want to delete ${chalet['nameofchalet']}?'),
                                  actions: [
                                    TextButton(
                                      child: Text('Cancel'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: Text('Delete'),
                                      onPressed: () async {
                                        // Delete the chalet from Firestore
                                        await chaletsref.doc(chalets[index].id).delete();

                                        // Delete offers associated with this chalet
                                        await FirebaseFirestore.instance.collection('offers')
                                            .where('chaletId', isEqualTo: chalets[index].id)
                                            .get()
                                            .then((querySnapshot) {
                                          querySnapshot.docs.forEach((doc) {
                                            doc.reference.delete();
                                          });
                                        });

                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            // Navigate to the edit chalet screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditChaletScreen(
                                  chalet: chalet,
                                  chaletId: chalets[index].id,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }

  Widget _buildLeadingImage(Map<String, dynamic> chalet) {
    return Container(
      width: 100,
      child: AspectRatio(
        aspectRatio: 1,
        child: Image.network(
          chalet['imageUrl'] ?? 'https://via.placeholder.com/200',
          fit: BoxFit.cover,
          errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
            return Center(
              child: Text(
                'No Image',
                style: TextStyle(color: Colors.grey),
              ),
            );
          },
        ),
      ),
    );
  }
}

class EditChaletScreen extends StatefulWidget {
  final Map<String, dynamic> chalet;
  final String chaletId;
  final TextEditingController nameofchaletController;
  final TextEditingController describtionController;
  final TextEditingController locationController;
  final TextEditingController priceController;
  final TextEditingController discountController;

  EditChaletScreen({
    required this.chalet,
    required this.chaletId,
  })  : nameofchaletController = TextEditingController(text: chalet['nameofchalet']),
        describtionController = TextEditingController(text: chalet['describtion']),
        locationController = TextEditingController(text: chalet['location']),
        priceController = TextEditingController(text: chalet['price'].toString()),
        discountController = TextEditingController(text: chalet['discount'].toString());

  @override
  _EditChaletScreenState createState() => _EditChaletScreenState();
}

class _EditChaletScreenState extends State<EditChaletScreen> {
  File? _imageFile;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isAvailable = false;

  @override
  void initState() {
    super.initState();
    // Initialize start date and end date if they exist in the chalet data
    _startDate = widget.chalet['startDate']?.toDate();
    _endDate = widget.chalet['endDate']?.toDate();
    _isAvailable = widget.chalet['isAvailable'] ?? false;
  }

  void _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }

  Future<void> _updateChalet() async {
    if (_imageFile != null) {
      // Upload the new image to Firebase Storage
      final ref = FirebaseStorage.instance.ref().child('chalet_images').child('${widget.chaletId}.jpg');
      await ref.putFile(_imageFile!);

      // Get the download URL for the new image
      final imageUrl = await ref.getDownloadURL();

      // Update the 'imageUrl' field in Firestore with the new URL
      await FirebaseFirestore.instance
          .collection('chalets')
          .doc(widget.chaletId)
          .update({'imageUrl': imageUrl});
    }

    // Update the availability of the chalet
    await FirebaseFirestore.instance
        .collection('chalets')
        .doc(widget.chaletId)
        .update({'isAvailable': _isAvailable});

    // Get the updated values from the text controllers
    String updatedName = widget.nameofchaletController.text;
    String updatedDescription = widget.describtionController.text;
    String updatedLocation = widget.locationController.text;
    double updatedPrice = double.parse(widget.priceController.text);
    double updatedDiscount = double.parse(widget.discountController.text);

    // Update the chalet document in Firestore
    await FirebaseFirestore.instance
        .collection('chalets')
        .doc(widget.chaletId)
        .update({
      'nameofchalet': updatedName,
      'describtion': updatedDescription,
      'location': updatedLocation,
      'price': updatedPrice,
      if (_startDate != null) 'startDate': _startDate,
      if (_endDate != null) 'endDate': _endDate,
      if (_startDate != null && _endDate != null) 'discount': updatedDiscount,
    });

    // Show a success message
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Chalet updated successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pop(context); // Back to previous screen
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Chalet'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Chalet ID: ${widget.chaletId}'),
            SizedBox(height: 16.0),
            _imageFile != null
                ? Image.file(
              _imageFile!,
              height: 200.0,
              fit: BoxFit.cover,
            )
                : Image.network(
              widget.chalet['imageUrl'] ?? 'https://via.placeholder.com/200',
              height: 200.0,
              fit: BoxFit.cover,
              errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                return Center(
                  child: Text(
                    'No Image',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              },
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Choose Image'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: widget.nameofchaletController,
              decoration: InputDecoration(
                labelText: 'Name of Chalet',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: widget.describtionController,
              decoration: InputDecoration(
                labelText: 'Description',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: widget.locationController,
              decoration: InputDecoration(
                labelText: 'Location',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: widget.priceController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Price',
              ),
            ),
            SizedBox(height: 16.0),
            if (widget.chalet['hasOffers'] == true) ...[
              SizedBox(height: 16.0),
              Text('Select Start Date:'),
              ElevatedButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _startDate!,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null) {
                    setState(() {
                      _startDate = picked;
                    });
                  }
                },
                child: Text(_startDate != null ? '$_startDate' : 'Select Start Date'),
              ),
              SizedBox(height: 16.0),
              Text('Select End Date:'),
              ElevatedButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _endDate!,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null) {
                    setState(() {
                      _endDate = picked;
                    });
                  }
                },
                child: Text(_endDate != null ? '$_endDate' : 'Select End Date'),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: widget.discountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Discount',
                ),
              ),
            ],
            SizedBox(height: 16.0),
            Text('Availability:'),
            Row(
              children: [
                Radio(
                  value: true,
                  groupValue: _isAvailable,
                  onChanged: (value) {
                    setState(() {
                      _isAvailable = value as bool;
                    });
                  },
                ),
                Text('Available'),
                Radio(
                  value: false,
                  groupValue: _isAvailable,
                  onChanged: (value) {
                    setState(() {
                      _isAvailable = value as bool;
                    });
                  },
                ),
                Text('Closed'),
              ],
            ),
            SizedBox(height: 16.0),
            MyButton(
              onTap: _updateChalet,
              text: 'UPDATE CHALET',
            ),
          ],
        ),
      ),
    );
  }
}
