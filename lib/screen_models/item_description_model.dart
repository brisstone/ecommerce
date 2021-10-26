
import 'package:ecommerce/custom_widgets/variant_list_item.dart';
import 'package:ecommerce/databases/mart_item_db.dart';
import 'package:ecommerce/mart_objects/mart_item.dart';
import 'package:ecommerce/mart_objects/small_mitem.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';

import '../constants.dart';

class ItemDescriptionModel {

  List<Widget> getDummyVariantsList(int i) {
    List<Widget> res = [];
    for (int k = 0; k < i; k++) {
      res.add(VariantListItem(title: 'dummy $k',));
    }
    return res;
  }

  Future<MartItem> getLargeItem(SmallMitem s) async {
    LargeMartItemsDb lDb = LargeMartItemsDb();
    MartItem martItem = await lDb.getItem(s.I);
    if (martItem != null) {
      for(var v in martItem.toMap().entries){
        print('${v.key} : ${v.value.runtimeType.toString()} : ${v.value}');
      }
      print('returned from db');
      return martItem;
    }

    Response response= await get('https://gmart-search.search.windows.net/indexes/gmart-dex/docs?api-version=2020-06-30&searchFields=d&search=${s.I}&select=n',
        headers:
        {'Content-Type':'application/json',
          'api-key':kSearchApiKey});
    if(response!=null && response.body!=null){
      martItem = MartItem.fromOgAzureIndex(responseBody: response.body);
    }
    if(martItem!=null) await lDb.insertItem(martItem);
    print('returned from Azure search');
    return martItem;
  }


  List<Widget> getVariantsList(String pricesAndVariants) {
    if (!pricesAndVariants.contains("<")) {
      return [];
    }
    List<String> variantsArray = pricesAndVariants.split("<");
    if (variantsArray.length <= 2) {
      return [];
    }

    List<Widget> variantsList = [];
    for (int i = 2; i < variantsArray.length; i++) {
      if(!variantsArray[i].contains('>') && !variantsArray[i].contains(','))continue;
      List variantDetails = variantsArray[i].contains('>')?variantsArray[i].split(">"):variantsArray[i].split(',');

      variantsList.add(
          VariantListItem(title: variantDetails[0],
              price:variantDetails[1]));
    }
    return variantsList;
  }

  void setVariantInList(String pricesAndVariants, String vTitle,
      BuildContext context) {
    if (!pricesAndVariants.contains("<")) {
      return;
    }
    List<String> variantsArray = pricesAndVariants.split("<");
    if (variantsArray.length <= 2) {
      return;
    }
    List<Widget> variantsList = [];
    for (int i = 2; i < variantsArray.length; i++) {
      List variantDetails = variantsArray[i].split(">");

      variantsList.add(
          VariantListItem(
              title: variantDetails[0], price: variantDetails[1],
              selected: vTitle == variantDetails[0] ? true : false)
      );
    }
  }
}
