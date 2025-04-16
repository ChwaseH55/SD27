import 'package:coffee_card/widgets/appBar_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shop_provider.dart';
import '../providers/user_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeShop();
    });
  }

  Future<void> _initializeShop() async {
    if (!_isInitialized) {
      _isInitialized = true;
      await context.read<ShopProvider>().fetchItems();
    }
  }

  @override
  void dispose() {
    _isInitialized = false;
    super.dispose();
  }

  void _showCartBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: CartBottomSheet(controller: controller),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Shop',
        actions: [
          Consumer<ShopProvider>(
            builder: (context, shopProvider, child) {
              final itemCount = shopProvider.cartItems.length;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart, color: Colors.black,),
                    onPressed: () => _showCartBottomSheet(context),
                  ),
                  if (itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          itemCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<ShopProvider>(
        builder: (context, shopProvider, child) {
          if (shopProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (shopProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(shopProvider.error!),
                  ElevatedButton(
                    onPressed: () => shopProvider.fetchItems(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: shopProvider.items.length,
            itemBuilder: (context, index) {
              final item = shopProvider.items[index];
              return Card(
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(item['imageUrl'] ??
                                'https://dogsinc.org/wp-content/uploads/2021/08/extraordinary-dog.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'] ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${item['price']?.toString() ?? '0'}',
                            style: const TextStyle(
                              fontSize: 14,
                              color:  Color.fromRGBO(186, 155, 55, 1),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                shopProvider.addToCart(item);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Item added to cart'),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromRGBO(186, 155, 55, 1),
                                foregroundColor: Colors.black,
                              ),
                              child: const Text('Add to Cart'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class CartBottomSheet extends StatelessWidget {
  final ScrollController controller;

  const CartBottomSheet({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ShopProvider>(
      builder: (context, shopProvider, child) {
        final cartItems = shopProvider.cartItems;
        final total = cartItems.fold<double>(
          0,
          (sum, item) => sum + (item.price * item.quantity),
        );

        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Text(
                    'Shopping Cart',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 48), // For balance
                ],
              ),
              const SizedBox(height: 16),
              if (cartItems.isEmpty)
                const Text('Your cart is empty')
              else
                Expanded(
                  child: ListView.builder(
                    controller: controller,
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return ListTile(
                        title: Text(item.name),
                        subtitle: Text('\$${item.price}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                shopProvider.updateQuantity(
                                  item.id,
                                  item.quantity - 1,
                                );
                              },
                            ),
                            Text('${item.quantity}'),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                shopProvider.updateQuantity(
                                  item.id,
                                  item.quantity + 1,
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                shopProvider.removeFromCart(item.id);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () async {
                    final shopProvider =
                        Provider.of<ShopProvider>(context, listen: false);
                    final success = await shopProvider.launchCheckout(context);

                    if (success) {
                      if (context.mounted) {
                        Navigator.pop(context); // Close the bottom sheet
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Payment successful!')),
                        );
                      }
                    } else {
                      if (context.mounted) {
                        Navigator.pop(context); // Close the bottom sheet
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Checkout was not completed')),
                        );
                      }
                    }
                  },
                  child: const Text('CHECKOUT', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
