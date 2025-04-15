class CartItem {
  final String id;
  final String name;
  final String priceId;
  final double price;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.priceId,
    required this.price,
    this.quantity = 1,
  });

  // Make sure this includes all fields required by your backend
  Map<String, dynamic> toJson() => {
    'price': priceId,
    'quantity': quantity,
    'name': name,
  };
}