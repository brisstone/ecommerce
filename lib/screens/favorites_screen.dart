
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce/custom_widgets/fav_list_item.dart';
import 'package:ecommerce/mart_objects/small_mitem.dart';
import 'package:ecommerce/providers/favorite_provider.dart';
import 'package:ecommerce/screen_models/favorites_model.dart';
import 'package:ecommerce/utility_functions.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import 'item_description_screen.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {

  FavoritesModel _favoritesModel;
  List<Widget> favList=[];
  FavOption itemsOption=FavOption.Item;
  BoxDecoration selectedDecoration= BoxDecoration(
    color: kLightBlue,
    borderRadius: BorderRadius.circular(20),
  );
  BoxDecoration unSelectedDecoration= BoxDecoration(
    color: Colors.black12,
    borderRadius: BorderRadius.circular(20),
  );

  @override
  void initState() {
    _favoritesModel= FavoritesModel();
  }

  @override
  void didChangeDependencies() {
    toggleOption(FavOption.Item, shouldReload:false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites', style: TextStyle(color: kThemeBlue),),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: kThemeBlue),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [

            SizedBox(height: 30,),
            if(favList.length>1)//Account for the swipe to delete indicator
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: favList.length,
                  itemBuilder:(context , index) {
                    return favList[index];
                  }),
              )
            else
              Expanded(child: Center(
                child: Icon(Icons.favorite_border_outlined, size: 100, color: kLightBlue,),
              ))
          ],
        ),
      ),
    );
  }

  Widget formerToggleRow(){
    return Row(
      children: [
        Expanded(
            child: Container(
              decoration: itemsOption==FavOption.Item?selectedDecoration:unSelectedDecoration,

              child: FlatButton(
                splashColor: Colors.white,
                onPressed: (){
                  toggleOption(FavOption.Item);
                },
                child: Text('Items', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),),
            )),
        Expanded(
            child: Container(
              decoration: itemsOption==FavOption.Shop?selectedDecoration:unSelectedDecoration,
              child: FlatButton(
                splashColor: Colors.white,
                onPressed: (){
                  toggleOption(FavOption.Shop);
                },
                child: Text('Shops', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),),
            )),
      ],
    );
  }

  void toggleOption(FavOption option, {bool shouldReload=true}){
    if(option==FavOption.Item){
//      favList=_favoritesModel.getDummyItems(5, this.context);
      setFavoriteItems();
    }else if(option==FavOption.Shop){
      favList=_favoritesModel.getDummyShops(4);
    }
    if(shouldReload)
    setState(() {
      itemsOption=option;
    });
  }

  void setFavoriteItems(){
    List<SmallMitem> smitemList=Provider.of<FavoriteProvider>(context).statMap.values.toList(growable: true);
    print('fav list length: ${smitemList.length}');
    favList=[Text('Swipe to delete', textAlign: TextAlign.center, style: kHintStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 11, color: kThemeBlue),)];
    for(SmallMitem smitem in smitemList){
      favList.add(Dismissible(
        key: Key(smitem.I),
        onDismissed: (_) async {
          await uToggleFavoriteStatus(context:context,smitem: smitem);
        },
        child: FavListItem(smitem: smitem, heroTag: smitem.I, onPressedFunc: (){
          Navigator.push(context, MaterialPageRoute(builder: (context){
            return ItemDescriptionScreen(heroTag: smitem.I, smallMitem: smitem,);
          }));
        }),
      ));
    }
    setState(() {
      print('fav list length after: ${favList.length}');
    });
  }

}

enum FavOption {Item, Shop}