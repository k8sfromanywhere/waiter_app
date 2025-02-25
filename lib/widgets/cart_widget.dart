import 'package:flutter/material.dart';
import '../models/product.dart';

class CartWidget extends StatelessWidget {
  final Map<Product, int> cartItems;
  final Function(Product) onRemoveFromCart;
  final VoidCallback onSaveOrder;

  const CartWidget({
    super.key,
    required this.cartItems,
    required this.onRemoveFromCart,
    required this.onSaveOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.all(10),
      height: 250,
      child: Column(
        children: [
          Text(
            "Корзина",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final product = cartItems.keys.elementAt(index);
                final quantity = cartItems[product]!;
                return ListTile(
                  title: Text(product.name),
                  subtitle: Text("Количество: $quantity"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () => onRemoveFromCart(product),
                      ),
                      Text(quantity.toString(), style: TextStyle(fontSize: 18)),
                    ],
                  ),
                );
              },
            ),
          ),
          ElevatedButton(onPressed: onSaveOrder, child: Text("Оформить заказ")),
        ],
      ),
    );
  }
}
