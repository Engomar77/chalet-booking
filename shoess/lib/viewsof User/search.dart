import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'chaletsdetails.dart';

class SearchChaletsScreen extends StatefulWidget {
  @override
  _SearchChaletsScreenState createState() => _SearchChaletsScreenState();
}

class _SearchChaletsScreenState extends State<SearchChaletsScreen> {
  late TextEditingController _searchController;
  String _searchKeyword = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Search Chalets'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _search,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchKeyword = value;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('chalets').where('nameofchalet', isEqualTo: _searchKeyword).snapshots(),
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
                  final chalets = snapshot.data!.docs;
                  if (chalets.isEmpty) {
                    return Center(
                      child: Text('No chalets found.'),
                    );
                  }
                  return ListView.builder(
                    itemCount: chalets.length,
                    itemBuilder: (context, index) {
                      final chaletData = chalets[index].data() as Map<String, dynamic>;
                      final chaletName = chaletData['nameofchalet'];
                      final imageUrl = chaletData['imageUrl'];
                      final price = chaletData['price'];

                      // Add more data if needed

                      return ListTile(
                        title: Text(chaletName),
                        subtitle: Text('Price: $price'),
                        leading: imageUrl.isNotEmpty ? Image.network(
                          imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ) : null,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChaletDetailsPage(
                                chalet: chaletData,
                                imageUrl: imageUrl, provider: null,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _search() {
    setState(() {
      _searchKeyword = _searchController.text.trim();
    });
  }
}
