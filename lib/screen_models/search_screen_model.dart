import 'dart:convert';

import 'package:ecommerce/custom_widgets/grid_item.dart';
import 'package:ecommerce/custom_widgets/mart_grid_item.dart';
import 'package:ecommerce/mart_objects/small_mitem.dart';
import 'package:ecommerce/screens/item_description_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../constants.dart';

class SearchScreenModel{

  static FirebaseDatabase  database = FirebaseDatabase.instance;
  static DatabaseReference myRef = database.reference();

  SearchScreenModel(){

     myRef = database.reference().child('S');
  }

  List<Widget> getEmptyGridItems(int n, BuildContext context){
    List<Widget> res=[];
    for(int i=0; i<n; i++){
      res.add(GridItem(title: 'Item$i', heroTagNum: i, price: '\u20a6 price$i', onPressedFunc: (){
        Navigator.push(context,
            MaterialPageRoute(builder: (context){
              return ItemDescriptionScreen(heroTag: 'itemImage$i', image: 'images/watchpic.jpg', martItem: null, smallMitem: null,);
            }));
      },));
    }
    return res;
  }

  Future<List<Widget>> getAllMarketItems(BuildContext context) async {
    List<Widget> itemList=[];
    List<SmallMitem> objList=[];

    print('near value');
    DataSnapshot snapShot=await myRef.once();
    print('gotten value');
    print(snapShot.value.toString());

    Map<dynamic , dynamic> maps= Map.from(snapShot.value);
    for(var k in maps.entries){
      SmallMitem item=SmallMitem.fromJson(k.value);
      item.I=k.key.toString();
      objList.add(item);
    }
    for(SmallMitem smit in objList){
      itemList.add(MartGridItem(smitem: smit, onPressedFunc: (){
        Navigator.push(context, MaterialPageRoute(builder: (context){
          return ItemDescriptionScreen(heroTag: smit.I, smallMitem: smit, martItem: null,);
        }));
      },));
    }
    return itemList;
  }


}