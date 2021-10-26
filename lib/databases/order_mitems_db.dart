
import 'package:ecommerce/mart_objects/mart_item.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class OrderItemsDb{
  Future<Database> createDatabase() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'doggie_databasemoorde.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE OrderItemsDb(l TEXT PRIMARY KEY, t TEXT, d TEXT, s TEXT, i TEXT, p TEXT, k TEXT, b TEXT, h TEXT, m TEXT, n TEXT, q TEXT)",);
      },
      version: 1,);
  }

  Future<void> clearAllItems() async {
    final Database db = await createDatabase();
    // await db.delete('OrderItemsDb');
   await db.delete('OrderItemsDb', where: '1');
  }

  Future<void> insertItem(MartItem item) async {
    // Get a reference to the database.
    final Database db = await createDatabase();

    await db.insert(
      'OrderItemsDb',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteItem(String id) async {
    // Get a reference to the database.
    final db = await createDatabase();

    // Remove the Dog from the Database.
    await db.delete(
      'OrderItemsDb',
      // Use a `where` clause to delete a specific dog.
      where: "l = ?",
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }

  Future<MartItem> getItem(String id) async {
    // Get a reference to the database.
    final db = await createDatabase();

    // Remove the Dog from the Database.
    final List<Map<String, dynamic>> maps = await db.query(
      'OrderItemsDb',
      // Use a `where` clause to check a specific dog.
      where: "l = ?",
      whereArgs: [id],
    );

    if(maps.isEmpty) return null;
    List<MartItem> mList= List.generate(maps.length, (i) {
      return MartItem.fromMap(maps[i]);
    });

    if(mList.isEmpty) return null;

    return mList[0];
  }

  Future<List<MartItem>> getMartItems() async {
    // Get a reference to the database.
    final Database db = await createDatabase();

    // Query the table for all The Itemss.
    final List<Map<String, dynamic>> maps = await db.query('OrderItemsDb');

    // Convert the List<Map<String, dynamic> into a List<MartItem>.
    return List.generate(maps.length, (i) {
      return MartItem.fromMap(maps[i]);
    });
  }

  Future<List<MartItem>> getSellerItems(String s) async {
    // Get a reference to the databases
    final db = await createDatabase();

    // Remove the Dog from the Database.
    final List<Map<String, dynamic>> maps = await db.query(
      'OrderItemsDb',
      // Use a `where` clause to check a specific dog.
      where: "i = ?",
      whereArgs: [s],
    );

    if(maps.isEmpty) return [];
    List<MartItem> mList= List.generate(maps.length, (i) {
      return MartItem.fromMap(maps[i]);
    });
    return mList;
  }
}