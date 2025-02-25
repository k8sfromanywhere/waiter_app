import 'package:flutter/material.dart';
import 'package:sqlite_test/databases/database_helper.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final orders = await dbHelper.getOrders();
    setState(() {
      _orders = orders;
    });
  }

  Future<void> _deleteOrder(int orderId) async {
    await dbHelper.deleteOrder(orderId);
    _loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Сохраненные заказы')),
      body:
          _orders.isEmpty
              ? Center(child: Text('Нет заказов'))
              : ListView.builder(
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  final order = _orders[index];
                  return Card(
                    child: ListTile(
                      title: Text("Заказ ${order['id']}"),
                      subtitle: Text("Товары: ${order['products']}"),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteOrder(order['id']),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
