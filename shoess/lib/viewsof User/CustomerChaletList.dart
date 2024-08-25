import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shoess/viewsof%20User/chaletsdetails.dart';

import ' CustomerLikedPage.dart';

class CustomerChaletPage extends StatefulWidget {
  @override
  _CustomerChaletPageState createState() => _CustomerChaletPageState();
}

class _CustomerChaletPageState extends State<CustomerChaletPage> {
  int? selectedCardIndex;
  Map<int, bool> likedIndexes = {};
  List<Map<String, dynamic>> likedChalets = [];

  int get index => 0;

  bool isCardSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('chalets')
            .where('hasOffers', isEqualTo: false)
            .where('isAvailable', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final chalets = snapshot.data!.docs;
            return ListView.builder(
              itemCount: chalets.length,
              itemBuilder: (context, index) {
                final chalet = chalets[index].data() as Map<String, dynamic>;
                final chaletId = chalet['id'];
                final imageUrl = chalet['imageUrl'] ?? '';
                final nameofchalet = chalet['nameofchalet'] ?? '';
                final location = chalet['location'] ?? '';
                final price = chalet['price'] as double? ?? 0.0;

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('reviews').where('chaletName', isEqualTo: nameofchalet).snapshots(),

                  builder: (context, reviewSnapshot) {
                    if (reviewSnapshot.hasData) {
                      final reviews = reviewSnapshot.data!.docs;
                      if (reviews.isNotEmpty) {
                        final averageRating = calculateAverageRating(reviews);
                        return buildCardWithReviews(chalet, imageUrl, nameofchalet, location,price, averageRating);
                      } else {
                        return buildCardWithoutReviews(chalet, imageUrl, nameofchalet,location, price);
                      }
                    } else {
                      return buildCardWithoutReviews(chalet, imageUrl, nameofchalet, location,price);
                    }
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CustomerLikedPage(
                likedChalets: likedChalets,
              ),
            ),
          );
        },
        child: Icon(Icons.favorite),
      ),
    );
  }

  double calculateAverageRating(List<DocumentSnapshot> reviews) {
    double totalRating = 0;
    for (var review in reviews) {
      totalRating += review['rating'];
    }
    return totalRating / reviews.length;
  }

  Widget buildCardWithReviews(Map<String, dynamic> chalet, String imageUrl, String nameofchalet,String location, double price, double averageRating) {
    final isCardSelected = likedIndexes.containsKey(index) ? likedIndexes[index]! : false;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChaletDetailsPage(
              chalet: chalet,
              imageUrl: imageUrl,
              provider: chalet['provider'],
            ),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 2.0,
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        imageUrl,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.fill,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      nameofchalet,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      location,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      price.toString(),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 24,
                    ),
                    SizedBox(height: 4),
                    Text(
                      averageRating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 8.0),
                    IconButton(
                      icon: isCardSelected
                          ? Icon(Icons.favorite, color: Colors.red)
                          : Icon(Icons.favorite_border),
                      onPressed: () {
                        setState(() {
                          if (likedIndexes.containsKey(index)) {
                            likedIndexes.remove(index);
                          } else {
                            likedIndexes[index] = true;
                            likedChalets.add(chalet);
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCardWithoutReviews(Map<String, dynamic> chalet, String imageUrl, String nameofchalet, String location,double price) {
    return GestureDetector(
        onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChaletDetailsPage(
            chalet: chalet,
            imageUrl: imageUrl,
            provider: chalet['provider'],
          ),
        ),
      );
    },
    child: Card(
    color: Colors.white,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(15.0),
    ),
    elevation: 2.0,
    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
    children: [
    Expanded(
    flex: 3,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
    children: [
    ClipRRect(
    borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
    child: Image.network
      (
      imageUrl,
      height: 150,
      width: double.infinity,
      fit: BoxFit.cover,
    ),
    ),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              nameofchalet,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              location,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              price.toString(),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    ],
    ),
    ),
      Expanded(
        flex: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'No reviews yet',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 16),
              IconButton(
                icon: isCardSelected
                    ? Icon(Icons.favorite, color: Colors.red)
                    : Icon(Icons.favorite_border),
                onPressed: () {
                  setState(() {
                    if (likedIndexes.containsKey(index)) {
                      likedIndexes.remove(index);
                      likedChalets.remove(chalet);
                    } else {
                      likedIndexes[index] = true;
                      likedChalets.add(chalet);
                    }
                  });
                },
              ),
            ],
          ),
        ),
      ),
    ],
    ),
    ),
    );
  }
}
