
import 'package:ecommerce/mart_objects/cart_item.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class CartItemsDb{
  Future<Database> createDatabase() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'cartems.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE CartItemsDb(i TEXT PRIMARY KEY, t TEXT, n TEXT, u TEXT, p TEXT, s TEXT, c TEXT, y TEXT, z TEXT, d TEXT, k TEXT)",);
      },
      version: 1,);
  }

  Future<void> insertItem(CartItem item) async {
    // Get a reference to the database.
    final Database db = await createDatabase();

    await db.insert(
      'CartItemsDb',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> clearAllItems() async {
    List<CartItem> list = await this.getCartItems();
    print('items list: ${list.length}');
    int c =0 ;
    for(CartItem item in list){
      c++;
      await deleteItem(item.i);
    }
    print('clearAllItems count: $c');
  }

  Future<void> deleteItem(String id) async {
    // Get a reference to the database.
    final db = await createDatabase();

    // Remove the Dog from the Database.
    await db.delete(
      'CartItemsDb',
      // Use a `where` clause to delete a specific dog.
      where: "i = ?",
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }

  Future<CartItem> getItem(String id) async {
    // Get a reference to the database.
    final db = await createDatabase();

    // Remove the Dog from the Database.
    final List<Map<String, dynamic>> maps = await db.query(
      'CartItemsDb',
      // Use a `where` clause to check a specific dog.
      where: "i = ?",
      whereArgs: [id],
    );

    if(maps.isEmpty) return null;
    List<CartItem> mList= List.generate(maps.length, (i) {
      return CartItem.fromMap(maps[i]);
    });

    if(mList.isEmpty) return null;

    return mList[0];
  }

  Future<List<CartItem>> getCartItems() async {
    // Get a reference to the database.
    final Database db = await createDatabase();

    // Query the table for all The Itemss.
    final List<Map<String, dynamic>> maps = await db.query('CartItemsDb');

    // Convert the List<Map<String, dynamic> into a List<MartItem>.
    return List.generate(maps.length, (i) {
      return CartItem.fromMap(maps[i]);
    });
  }

  Future<List<CartItem>> getSellerItems(String s) async {
    // Get a reference to the databases
    final db = await createDatabase();

    // Remove the Dog from the Database.
    final List<Map<String, dynamic>> maps = await db.query(
      'CartItemsDb',
      // Use a `where` clause to check a specific dog.
      where: "s = ?",
      whereArgs: [s],
    );

    if(maps.isEmpty) return [];
    List<CartItem> mList= List.generate(maps.length, (i) {
      return CartItem.fromMap(maps[i]);
    });
    return mList;
  }
}