import 'package:flutter/material.dart';

class ShopPage extends StatelessWidget {
  final List<Product> products = [
    Product(
        name: 'Flex Seeds 100gms',
        price: 100.0,
        image: 'https://api.greatshark.tech/uploads/flexSeed.png'),
    Product(
        name: 'Goat Food 10kg',
        price: 200.0,
        image: 'https://api.greatshark.tech/uploads/goatnutrients.png'),
    Product(
        name: 'Horse Food 10kg',
        price: 300.0,
        image: 'https://api.greatshark.tech/uploads/horseFood.png'),
    Product(
        name: 'Organic Fertilizer 1kg',
        price: 400.0,
        image: 'https://api.greatshark.tech/uploads/khaad.png'),
    Product(
        name: 'Spade(Faavda)',
        price: 500.0,
        image: 'https://api.greatshark.tech/uploads/tool1.png'),
    Product(
        name: 'Plant Nutrients',
        price: 600.0,
        image: 'https://api.greatshark.tech/uploads/Nutrients.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shop'),
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(8.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return ProductItem(product: products[index]);
        },
      ),
    );
  }
}

class Product {
  final String name;
  final double price;
  final String image;

  Product({required this.name, required this.price, required this.image});
}

class ProductItem extends StatelessWidget {
  final Product product;

  ProductItem({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Image.network(
                product.image,
                width: 150,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4.0),
                Text(
                  '\₹${product.price.toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
