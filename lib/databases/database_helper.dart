import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'database_filling.dart';
import '../models/category.dart';
import '../models/product.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cafe_orders.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    await deleteDatabase(path);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        image_name TEXT NOT NULL,
        category_id INTEGER NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        created_at TEXT NOT NULL
      );
    ''');

    await db.execute('''
  CREATE TABLE order_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE
  );
''');

    await DatabaseFilling.populateDB(db);
  }

  Future<List<Map<String, dynamic>>> getOrders() async {
    final db = await database;
    final result = await db.rawQuery('''
    SELECT orders.id, orders.created_at, 
           GROUP_CONCAT(products.name || ' (x' || item_counts.count || ')', ', ') AS products
    FROM orders
    JOIN (
        SELECT order_id, product_id, COUNT(product_id) AS count
        FROM order_items
        GROUP BY order_id, product_id
    ) AS item_counts ON orders.id = item_counts.order_id
    JOIN products ON item_counts.product_id = products.id
    GROUP BY orders.id
    ORDER BY orders.created_at DESC;
  ''');

    return result;
  }

  Future<List<Category>> getCategories() async {
    final db = await database;
    final result = await db.query('categories');
    return result.map((map) => Category.fromMap(map)).toList();
  }

  Future<int> createOrder(List<int> productIds) async {
    final db = await database;
    int orderId = await db.insert('orders', {
      'created_at': DateTime.now().toIso8601String(),
    });
    for (int productId in productIds) {
      await db.insert('order_items', {
        'order_id': orderId,
        'product_id': productId,
      });
    }
    return orderId;
  }

  Future<int> deleteOrder(int orderId) async {
    final db = await database;

    await db.delete('order_items', where: 'order_id = ?', whereArgs: [orderId]);

    return await db.delete('orders', where: 'id = ?', whereArgs: [orderId]);
  }

  Future<List<Product>> getProductsByCategory(int categoryId) async {
    final db = await database;
    final result = await db.query(
      'products',
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
    return result.map((map) => Product.fromMap(map)).toList();
  }
}
