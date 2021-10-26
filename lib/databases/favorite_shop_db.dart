import 'package:ecommerce/mart_objects/shop_data.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class FavShopDb{

  Future<Database> createDatabase() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'doggie_databasefants.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE FavShopDb(l TEXT PRIMARY KEY, e TEXT)",);
      },
      version: 1,);
  }

  Future<void> clearAllItems() async {
    final Database db = await createDatabase();
    // await db.delete('FavShopDb');
    var result = await db.delete('FavShopDb', where: '1');
  }

  Future<void> insertItem({String id,String item}) async {
    // Get a reference to the database.
    final Database db = await createDatabase();
    ShopData ed=ShopData.withDetails(id, item);
    await db.insert(
      'FavShopDb',
      ed.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteItem(String id) async {
    // Get a reference to the database.
    final db = await createDatabase();

    // Remove the Dog from the Database.
    await db.delete(
      'FavShopDb',
      // Use a `where` clause to delete a specific dog.
      where: "l = ?",
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }

  Future<ShopData> getItem(String id) async {
    // Get a reference to the database.
    final db = await createDatabase();

    // Remove the Dog from the Database.
    final List<Map<String, dynamic>> maps = await db.query(
      'FavShopDb',
      // Use a `where` clause to check a specific dog.
      where: "l = ?",
      whereArgs: [id],
    );

    if(maps.isEmpty) return null;
    List<ShopData> mList= List.generate(maps.length, (i) {
      return ShopData.fromMap(maps[i]);
    });

    if(mList.isEmpty) return null;

    return mList[0];
  }

  Future<List<ShopData>> getEvents() async {
    // Get a reference to the database.
    final Database db = await createDatabase();

    // Query the table for all The Itemss.
    final List<Map<String, dynamic>> maps = await db.query('FavShopDb');

    // Convert the List<Map<String, dynamic> into a List<MartItem>.
    return List.generate(maps.length, (i) {
      return ShopData.fromMap(maps[i]);
    });
  }

  Future<List<String>> getEventsStrings() async {
    // Get a reference to the database.
    final Database db = await createDatabase();

    // Query the table for all The Itemss.
    final List<Map<String, dynamic>> maps = await db.query('FantasyDb');

    // Convert the List<Map<String, dynamic> into a List<MartItem>.
    return List.generate(maps.length, (i) {
      return(maps[i].toString());
    });
  }
}