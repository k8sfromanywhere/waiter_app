import 'package:sqflite/sqflite.dart';

class DatabaseFilling {
  static Future<void> populateDB(Database db) async {
    int mains = await db.insert('categories', {'name': 'Основные блюда'});
    int desserts = await db.insert('categories', {'name': 'Десерты'});

    await db.insert('products', {
      'name': 'Стейк',
      'image_name': 'steak.jpg',
      'category_id': mains,
    });
    await db.insert('products', {
      'name': 'Форель',
      'image_name': 'trout.jpg',
      'category_id': mains,
    });
    await db.insert('products', {
      'name': 'Рёбра',
      'image_name': 'ribs.jpg',
      'category_id': mains,
    });

    await db.insert('products', {
      'name': 'Тирамису',
      'image_name': 'tiramisu.jpg',
      'category_id': desserts,
    });
    await db.insert('products', {
      'name': 'Чизкейк',
      'image_name': 'cheesecake.jpg',
      'category_id': desserts,
    });
    await db.insert('products', {
      'name': 'Эклер',
      'image_name': 'eclair.jpg',
      'category_id': desserts,
    });
  }
}
