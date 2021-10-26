import 'dart:async';

import 'package:ecommerce/mart_objects/mart_item.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SellerLargeItemsDb{

  String _sellerTableTitle='SellerLargeItemsDb';
  Future<Database> createDatabase() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'seller_database.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE $_sellerTableTitle(l TEXT PRIMARY KEY, t TEXT, d TEXT, s TEXT, i TEXT, p TEXT, k TEXT, b TEXT, h TEXT, m TEXT, n TEXT, q TEXT)",);
      },
      version: 1,);
  }

  Future<void> clearAllItems() async {
    final Database db = await createDatabase();
    // await db.delete(_sellerTableTitle);
    var result = await db.delete(_sellerTableTitle, where: '1');
  }

  Future<void> insertItem(MartItem item) async {
    // Get a reference to the database.
    final Database db = await createDatabase();

    await db.insert(
      _sellerTableTitle,
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteItem(String id) async {
    // Get a reference to the database.
    final db = await createDatabase();

    // Remove the Dog from the Database.
    await db.delete(
      _sellerTableTitle,
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
      _sellerTableTitle,
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

  Future<List<MartItem>> getAllMartItems() async {
    // Get a reference to the database.
    final Database db = await createDatabase();

    // Query the table for all The Itemss.
    final List<Map<String, dynamic>> maps = await db.query(_sellerTableTitle);

    // Convert the List<Map<String, dynamic> into a List<MartItem>.
    return List.generate(maps.length, (i) {
      return MartItem.fromMap(maps[i]);
    });
  }
}