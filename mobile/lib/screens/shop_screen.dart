import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'store_state.dart';

class ShopScreen extends StatefulWidget {
  @override
  _StoreScreenState createState() => _StoreScreenState();
}

class _StoreScreenState extends State<ShopScreen> {
  @override
  void initState() {
    super.initState();
    final storeState = Provider.of<StoreState>(context, listen: false);
    storeState.user = User("123"); // Replace with actual user info
    if (storeState.user != null) {
      storeState.fetchProducts(storeState.user!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Store')),
      body: Consumer<StoreState>(
        builder: (context, storeState, child) {
          if (storeState.loading) {
            return Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: storeState.products.length,
                  itemBuilder: (context, index) {
                    final product = storeState.products[index];
                    return ListTile(
                      title: Text(product['name']),
                      subtitle: Text(product['price'] != null ? '\$${product['price'].toStringAsFixed(2)}' : 'Price not available'),
                      trailing: ElevatedButton(
                        onPressed: () => storeState.addToCart(product),
                        child: Text('Add to Cart'),
                      ),
                    );
                  },
                ),
                ElevatedButton(
                  onPressed: () => storeState.handleCheckout(storeState.user!.id),
                  child: Text('Checkout'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}