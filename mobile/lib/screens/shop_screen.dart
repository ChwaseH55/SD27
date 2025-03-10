import 'package:flutter/material.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Screen'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Item 1
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: const DecorationImage(
                            image: NetworkImage(
                                'https://picsum.photos/id/237/200/300'), // Replace with your image URL
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Item 1',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8.0),
                            Text('Description for Item 1', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8.0),
                            Text('Price: \$19.99', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Item 2
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: const DecorationImage(
                            image: NetworkImage(
                                'https://picsum.photos/id/237/200/300'), // Replace with your image URL
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Item 2',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8.0),
                            Text('Description for Item 2', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8.0),
                            Text('Price: \$14.50', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Item 3
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: const DecorationImage(
                            image: NetworkImage(
                                'https://picsum.photos/id/237/200/300'), // Replace with your image URL
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Item 3',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8.0),
                            Text('Description for Item 3', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8.0),
                            Text('Price: \$24.95', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}