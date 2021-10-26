import 'dart:async';

import 'package:ecommerce/mart_objects/order_item.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SellerOrdersDb{

  Future<Database> createDatabase() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'doggie_database_order_seller.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE SellerOrdersDb(i TEXT PRIMARY KEY, t TEXT, n TEXT, u TEXT, p TEXT, s TEXT, c TEXT, y TEXT, z TEXT, d TEXT, k TEXT)",);
      },
      version: 1,);
  }

  Future<void> insertItem(OrderItem item) async {
    // Get a reference to the database.
    final Database db = await createDatabase();

    await db.insert(
      'SellerOrdersDb',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> clearAllItems() async {
    final Database db = await createDatabase();
    await db.delete('SellerOrdersDb');
  }

  Future<void> deleteItem(String id) async {
    // Get a reference to the database.
    final db = await createDatabase();

    // Remove the Dog from the Database.
    await db.delete(
      'SellerOrdersDb',
      // Use a `where` clause to delete a specific dog.
      where: "i = ?",
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }

  Future<OrderItem> getItem(String id) async {
    // Get a reference to the database.
    final db = await createDatabase();

    // Remove the Dog from the Database.
    final List<Map<String, dynamic>> maps = await db.query(
      'SellerOrdersDb',
      // Use a `where` clause to check a specific dog.
      where: "i = ?",
      whereArgs: [id],
    );

    if(maps.isEmpty) return null;
    List<OrderItem> mList= List.generate(maps.length, (i) {
      return OrderItem.fromMap(maps[i]);
    });

    if(mList.isEmpty) return null;

    return mList[0];
  }

  Future<List<OrderItem>> getMartItems() async {
    // Get a reference to the database.
    final Database db = await createDatabase();

    // Query the table for all The Itemss.
    final List<Map<String, dynamic>> maps = await db.query('SellerOrdersDb');

    // Convert the List<Map<String, dynamic> into a List<MartItem>.
    return List<OrderItem>.generate(maps.length, (i) {
      return OrderItem.fromMap(maps[i]);
    });
  }

  Future<List<OrderItem>> getSellerItems(String s) async {
    // Get a reference to the databases
    final db = await createDatabase();

    // Remove the Dog from the Database.
    final List<Map<String, dynamic>> maps = await db.query(
      'SellerOrdersDb',
      // Use a `where` clause to check a specific dog.
      where: "s = ?",
      whereArgs: [s],
    );

    if(maps.isEmpty) return [];
    List<OrderItem> mList= List.generate(maps.length, (i) {
      return OrderItem.fromMap(maps[i]);
    });
    return mList;
  }
}