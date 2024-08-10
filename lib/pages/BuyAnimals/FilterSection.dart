import 'package:ckgoat/pages/BuyAnimals/AnimalPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FilterSection extends StatefulWidget {
  @override
  _FilterSectionState createState() => _FilterSectionState();
}

class _FilterSectionState extends State<FilterSection> {
  String? selectedCity = 'All';
  String? selectedAnimalType = 'All';

  final List<String> animalTypes = [
    'All',
    'Cow',
    'Buffalo',
    'Sheep',
    'Goat',
    'Horse',
    'Birds'
  ];
  final List<String> cities = [
    'All',
    'Pune',
    'Solapur',
  ];

  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance.collection('animals');

    if (selectedCity != 'All') {
      query = query.where('city', isEqualTo: selectedCity);
    }

    if (selectedAnimalType != 'All') {
      query = query.where('animalType', isEqualTo: selectedAnimalType);
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter by city (DropdownButton)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Filter City :"),
              SizedBox(
                width: 150,
                child: DropdownButton<String>(
                  value: selectedCity,
                  hint: Text('Select City'),
                  items: cities.map((String city) {
                    return DropdownMenuItem<String>(
                      value: city,
                      child: Text(city),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCity = newValue;
                    });
                  },
                  isExpanded: true,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          // Filter by animal type (Horizontal scrollable ElevatedButtons)
          SizedBox(
            height: 30,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: animalTypes.map((String type) {
                bool isSelected = selectedAnimalType == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor:
                          isSelected ? Colors.deepOrange : Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        selectedAnimalType = type;
                      });
                    },
                    child: Text(type),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: query.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No animals found.'));
                }

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      mainAxisExtent: 230,
                      mainAxisSpacing: 15,
                      crossAxisCount: 2,
                      crossAxisSpacing: 15),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    // Get the list of image URLs
                    final imageUrls =
                        data['uploadedUrls'] as List<dynamic>? ?? [];
                    final firstImageUrl =
                        imageUrls.isNotEmpty ? imageUrls[0] as String : null;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AnimalPage(animalId: doc.id),
                          ),
                        );
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.blue,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(10)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10)),
                                  child: Image.network(
                                    firstImageUrl!,
                                    fit: BoxFit.cover,
                                    height:
                                        150, // Ensure image height is constrained
                                    width: double
                                        .infinity, // Take full width of parent
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['title'],
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            'Breed : ',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            data['breed'],
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.normal),
                                          )
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            'Price : ',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            '${data['price']}',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.normal),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          Positioned(
                            right: 10,
                            bottom: 55,
                            child: Container(
                              width: 40,
                              decoration: BoxDecoration(boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ], shape: BoxShape.circle, color: Colors.white),
                              child: IconButton(
                                icon: Icon(
                                  Icons.favorite_outline,
                                  color: Colors.black45,
                                ),
                                onPressed: () {},
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
