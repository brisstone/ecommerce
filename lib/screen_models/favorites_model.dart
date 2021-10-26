
import 'dart:math';

import 'package:ecommerce/custom_widgets/fav_list_item.dart';
import 'package:ecommerce/custom_widgets/shop_item.dart';
import 'package:ecommerce/screens/item_description_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FavoritesModel{

  FavoritesModel(){
   _random=Random();
  }

  Random _random;
  List colors=[Color(0xAAFFAAFF), Color(0x55AAFFAA), Color(0x55FFAAAA), Colors.deepPurple, Colors.teal, Colors.lightGreen, Colors.pink, Colors.lightGreen, Colors.red, Colors.indigo, Colors.amber, Colors.blueGrey];

  List<Widget> getDummyItems(int i, BuildContext context){

    List<Widget> res=[];
    for(int k=0; k<i; k++){
      res.add(FavListItem(heroTag: 'fav$k', onPressedFunc: (){
        Navigator.push(context,
            MaterialPageRoute(builder: (context){
              return ItemDescriptionScreen(heroTag: 'fav$k', image: 'images/tiepic.jpg', smallMitem: null, martItem: null,);
            }));
      },));
    }
    return res;
  }
  List<Widget> getDummyShops(int i){

    List<Widget> res=[];
    for(int k=0; k<i; k++){
      res.add(ShopItem(backColor: colors[_random.nextInt(colors.length)]));
    }
    return res;
  }
}



