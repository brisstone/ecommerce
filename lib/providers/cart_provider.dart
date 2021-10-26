import 'package:ecommerce/constants.dart';
import 'package:ecommerce/databases/cart_items_db.dart';
import 'package:ecommerce/mart_objects/cart_item.dart';
import 'package:ecommerce/singletons/az_single.dart';
import 'package:ecommerce/utility_functions.dart';
import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier{

  Map<String, CartItem> statMap={};
  Map<String, String> imgMap={};

  Future<void> downloadAndSetUserCartItems() async {
    List<CartItem> cartList = await AzSingle().fetchCustomerCartItems( await uGetSharedPrefValue(kIdKey));
    CartItemsDb cartDb= CartItemsDb();
    for(CartItem item in cartList){
      await cartDb.insertItem(item);
    }
    await fillUpCartMapFromDb();
  }

  Future<void> fillUpCartMapFromDb() async {
    CartItemsDb favDb= CartItemsDb();
    List<CartItem> favList= await favDb.getCartItems();
    statMap= {};
    for(CartItem smitem in favList){
      statMap[smitem.t]=smitem;
      loadPic(smitem);
    }
    notifyListeners();
  }

  Future<void> addItemToMap(CartItem item) async {
    CartItemsDb favDb= CartItemsDb();
    await favDb.insertItem(item);
    statMap[item.t]=item;
    loadPic(item);
    notifyListeners();
  }

  Future<void> removeItemFromCart(CartItem item) async {
    CartItemsDb favDb= CartItemsDb();
    await favDb.deleteItem(item.i);
    statMap.remove(item.t);
    notifyListeners();
  }

  bool isMartItemInCart(String itemId){
    return statMap.containsKey(itemId);
  }

  Future<void> loadPic(CartItem oItem) async {
    imgMap[oItem.i] = await AzSingle().getCartPictureUrl(oItem);
    notifyListeners();
  }

  void clearAll(){
    statMap = {};
    imgMap = {};
    notifyListeners();
  }

}
