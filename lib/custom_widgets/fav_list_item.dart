import 'dart:io';

import 'package:ecommerce/mart_objects/small_mitem.dart';
import 'package:ecommerce/screens/search_screen.dart';
import 'package:ecommerce/utility_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class FavListItem extends StatefulWidget {
  FavListItem({this.price='1000', this.title='Test title', this.image='images/tiepic.jpg', this.onPressedFunc, @required this.heroTag, this.smitem}) {
  }
    SmallMitem smitem;
    String heroTag;
    Function onPressedFunc;
    String image;
    String title;
    String price;

    @override
  _FavListItemState createState() =>
        _FavListItemState(price:this.price, title:this.title, image:this.image, onPressedFunc: this.onPressedFunc,
        heroTag: this.heroTag, smitem:this.smitem);
}

class _FavListItemState extends State<FavListItem>  {

  _FavListItemState({this.price='1000', this.title='Test title', this.image='images/tiepic.jpg', this.onPressedFunc, @required this.heroTag, this.smitem, this.shopDets}){

  }


  @override
  void initState() {

    if(smitem!=null){
      setItemValues();
    }
  }

  SmallMitem smitem;
  String heroTag;
  Function onPressedFunc;
  String image;
  String title;
  String price;
  String shopDets;//Shop details


  @override
  void didUpdateWidget(FavListItem oldWidget) {
    if(smitem!=null){
      setItemValues();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: TextButton(
        onPressed: onPressedFunc!=null?onPressedFunc:(){},
        child: Container(
          padding: EdgeInsets.all(1),
          margin: EdgeInsets.all(8),
//        decoration: BoxDecoration(
//            color: Colors.white,
//            borderRadius: BorderRadius.circular(10),
//          boxShadow: [BoxShadow(color: Colors.grey,blurRadius: 5)]
//        ),
          child: ListTile(
            leading: Hero(
              tag: smitem.I,
           // child: ClipRRect(
           //     borderRadius: BorderRadius.circular(7),
           //     child:Image.file(File(smitem.P.split(',').firstWhere((element) => element.isNotEmpty)), height: 90, width: 40,)),
            child: Icon(Icons.favorite, color: Colors.red, size: 40,),
            ),
            tileColor: Colors.white,
            title: Text(smitem.N, style: TextStyle(color: kThemeBlue, fontWeight: FontWeight.bold),),
            subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
            [
              SizedBox(height: 10,),
              Text('\u20a6 ${smitem.M.split('<')[0]}', style: TextStyle(color: kLightOrange, fontWeight: FontWeight.bold),),
              Container(
                width: double.infinity,
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                      onPressed: (){
                        searchForSellerItem();
                      },
                   child: Text('Other items by seller', textAlign: TextAlign.end, style: TextStyle(color: kLightBlue, fontSize: 10),)))
            ]),
          ),
        ),
      ),
    );
  }

  Future<void> setItemValues() async {
    image = await uGetPicDownloadUrl(smitem.P);
    title=smitem.N;
    price=smitem.M;
    setState(() {

    });
  }

  void searchForSellerItem() {
    Navigator.push(context, MaterialPageRoute(builder: ((context)=>SearchScreen( shopDets:shopDets, shopId:smitem.S))));
  }
}
