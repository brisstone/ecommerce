import 'package:ecommerce/databases/favorite_item_db.dart';
import 'package:ecommerce/mart_objects/mart_item.dart';
import 'package:ecommerce/mart_objects/small_mitem.dart';
import 'package:flutter/cupertino.dart';

class FavoriteProvider extends ChangeNotifier{

   Map<String, SmallMitem> statMap={};

  Future<void> fillUpFavoritesMap() async {
    FavoriteItemsDb favDb= FavoriteItemsDb();
    List<SmallMitem> favList= (await favDb.getMartItems())??[];
    statMap = {};
    for(SmallMitem smitem in favList){
      statMap[smitem.I]=smitem;
    }
    notifyListeners();
  }

   Future<void> addItemToMap(SmallMitem smitem) async {
    FavoriteItemsDb favDb= FavoriteItemsDb();
    await favDb.insertItem(smitem);
    statMap[smitem.I]=smitem;
    notifyListeners();
  }

   Future<void> addLargeItemToMap(MartItem mitem) async {
     SmallMitem smitem=mitem.getSmallUpload();
     smitem.I=mitem.l;
      FavoriteItemsDb favDb= FavoriteItemsDb();
      await favDb.insertItem(smitem);
      statMap[smitem.I]=smitem;
      notifyListeners();
  }

  Future<void> removeItemFromFavorite(String itemId) async {
    FavoriteItemsDb favDb= FavoriteItemsDb();
    await favDb.deleteItem(itemId);
    statMap.remove(itemId);
    notifyListeners();
  }

  bool isItemFavorite(SmallMitem smitem){
    return statMap.containsKey(smitem.I);
  }

  bool isItemIdFavorite(String sId){
    return statMap.containsKey(sId);
  }

  void clearAll(){
    statMap = {};
    notifyListeners();
  }
}
