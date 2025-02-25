import 'package:flutter/material.dart';
import 'package:sqlite_test/databases/database_helper.dart';
import 'package:sqlite_test/screens/orders_screen.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../widgets/cart_widget.dart';
import '../widgets/product_list_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final dbHelper = DatabaseHelper.instance;
  List<Category> _categories = [];
  List<Product> _products = [];
  Map<Product, int> _cartItems = {};
  Category? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await dbHelper.getCategories();
    setState(() {
      _categories = categories;
      if (_categories.isNotEmpty) {
        _selectedCategory = _categories.first;
        _loadProducts(_selectedCategory!.id);
      }
    });
  }

  Future<void> _loadProducts(int categoryId) async {
    final products = await dbHelper.getProductsByCategory(categoryId);
    setState(() {
      _products = products;
    });
  }

  void _addToCart(Product product) {
    setState(() {
      _cartItems[product] = (_cartItems[product] ?? 0) + 1;
    });
  }

  void _removeFromCart(Product product) {
    setState(() {
      if (_cartItems.containsKey(product) && _cartItems[product]! > 1) {
        _cartItems[product] = _cartItems[product]! - 1;
      } else {
        _cartItems.remove(product);
      }
    });
  }

  Future<void> _saveOrder() async {
    if (_cartItems.isEmpty) return;
    final db = await dbHelper.database;
    int orderId = await db.insert('orders', {
      'created_at': DateTime.now().toIso8601String(),
    });

    for (var entry in _cartItems.entries) {
      for (int i = 0; i < entry.value; i++) {
        await db.insert('order_items', {
          'order_id': orderId,
          'product_id': entry.key.id,
        });
      }
    }

    setState(() {
      _cartItems.clear();
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Заказ №$orderId оформлен!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Меню кафе'),
        actions: [
          IconButton(
            icon: Icon(Icons.receipt_long),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OrdersScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 15.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Категории",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white, //
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<Category>(
                      value: _selectedCategory,
                      isExpanded: true,
                      icon: Icon(Icons.arrow_drop_down, color: Colors.orange),
                      style: TextStyle(fontSize: 16, color: Colors.black),
                      items:
                          _categories.map((Category category) {
                            return DropdownMenuItem<Category>(
                              value: category,
                              child: Text(category.name),
                            );
                          }).toList(),
                      onChanged: (Category? newCategory) {
                        if (newCategory != null) {
                          setState(() {
                            _selectedCategory = newCategory;
                          });
                          _loadProducts(newCategory.id);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ProductListWidget(
              products: _products,
              onAddToCart: _addToCart,
            ),
          ),
          if (_cartItems.isNotEmpty)
            CartWidget(
              cartItems: _cartItems,
              onRemoveFromCart: _removeFromCart,
              onSaveOrder: _saveOrder,
            ),
        ],
      ),
    );
  }
}
