import 'dart:async';

import 'package:ecommerce/mart_objects/small_mitem.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class FavoriteItemsDb{

  Future<Database> createDatabase() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'doggie_databasefav.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE FavoriteItemsDb(i TEXT PRIMARY KEY, p TEXT, n TEXT, m TEXT, s TEXT, t TEXT, e TEXT)",);
      },
      version: 1,);
  }
  Future<void> clearAllItems() async {
    final Database db = await createDatabase();

    // await db.delete('FavoriteItemsDb');
    var result = await db.delete('FavoriteItemsDb', where: '1');
  }

  Future<void> insertItem(SmallMitem item) async {
    // Get a reference to the database.
    final Database db = await createDatabase();

    await db.insert(
      'FavoriteItemsDb',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteItem(String id) async {
    // Get a reference to the database.
    final db = await createDatabase();

    // Remove the Dog from the Database.
    await db.delete(
      'FavoriteItemsDb',
      // Use a `where` clause to delete a specific dog.
      where: "i = ?",
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }

  Future<SmallMitem> getItem(String id) async {
    // Get a reference to the database.
    final db = await createDatabase();

    // Remove the Dog from the Database.
    final List<Map<String, dynamic>> maps = await db.query(
      'FavoriteItemsDb',
      // Use a `where` clause to check a specific dog.
      where: "i = ?",
      whereArgs: [id],
    );

    if(maps.isEmpty) return null;
    List<SmallMitem> mList= List.generate(maps.length, (i) {
      return SmallMitem.fromJson(maps[i]);
    });

    if(mList.isEmpty) return null;

    return mList[0];
  }

  Future<List<SmallMitem>> getMartItems() async {
    // Get a reference to the database.
    final Database db = await createDatabase();

    // Query the table for all The Itemss.
    final List<Map<String, dynamic>> maps = await db.query('FavoriteItemsDb');

    // Convert the List<Map<String, dynamic> into a List<MartItem>.
    return List<SmallMitem>.generate(maps.length, (i) {
      return SmallMitem.fromJson(maps[i]);
    });
  }
}