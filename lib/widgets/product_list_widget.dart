import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductListWidget extends StatelessWidget {
  final List<Product> products;
  final Function(Product) onAddToCart;

  const ProductListWidget({required this.products, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    return products.isEmpty
        ? Center(child: Text("Нет блюд в этой категории"))
        : ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return Card(
              child: ListTile(
                leading: Image.asset(
                  'assets/images/${product.imageName}',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.image_not_supported,
                      size: 50,
                      color: Colors.grey,
                    );
                  },
                ),
                title: Text(product.name),
                trailing: IconButton(
                  icon: Icon(Icons.add_shopping_cart, color: Colors.green),
                  onPressed: () => onAddToCart(product),
                ),
              ),
            );
          },
        );
  }
}
