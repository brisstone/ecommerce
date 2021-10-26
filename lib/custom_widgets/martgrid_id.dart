import 'package:ecommerce/databases/mart_item_db.dart';
import 'package:ecommerce/mart_objects/mart_item.dart';
import 'package:ecommerce/mart_objects/small_mitem.dart';
import 'package:ecommerce/providers/favorite_provider.dart';
import 'package:ecommerce/screens/item_description_screen.dart';
import 'package:ecommerce/utility_functions.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants.dart';

class MartGridWithID extends StatefulWidget {
  String id;
  SmallMitem smitem;

  MartGridWithID({this.id, this.smitem});
  @override
  _MartGridWithIDState createState() => _MartGridWithIDState();
}

class _MartGridWithIDState extends State<MartGridWithID> {
  SmallMitem smitem;
  String imageUrl='';
  String heroTagNum='';
  String title='';
  String price='';
  Function onPressedFunc;


  @override
  void initState() {
    if(widget.id!=null&& widget.id.isNotEmpty){
      getItemWithID(widget.id);
    }else if(widget.smitem!=null){
      smitem=widget.smitem;
      setMainDetails();
    }
  }

  Future<void> getItemWithID(String id) async {
    LargeMartItemsDb lDb = LargeMartItemsDb();
    MartItem martItem = await lDb.getItem(id);
    if (martItem != null) {
      for(var v in martItem.toMap().entries){
        print('${v.key} : ${v.value.runtimeType.toString()} : ${v.value}');
      }
      print('returned from db');
      return martItem;
    }
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference myRef = database.reference().child('R').child(id);
    DatabaseReference mySmallRef = database.reference().child('S').child(id);
    var snapShot = await myRef.once();
    var snapShotSmall = await mySmallRef.once();

    SmallMitem smitem=SmallMitem.fromJson(snapShotSmall.value);
    martItem = MartItem(snapShot:snapShot, smitem: smitem);

    await lDb.insertItem(martItem);
    print('returned from firebase');
    this.smitem=martItem.getSmallUpload();
  }

  Future<void> setMainDetails() async {
    heroTagNum=smitem.I;
    title=smitem.N;
    price='\u20a6 ${smitem.M}';
    imageUrl=await uGetPicDownloadUrl(smitem.P);//kUrlStart+smitem.P.replaceAll(kUrlStart, '');
    onPressedFunc= (){
    Navigator.push(context, MaterialPageRoute(builder: (context){
    return ItemDescriptionScreen(heroTag: smitem.I, smallMitem: smitem,);
    }));
    };
    print('item name:$title pic:$imageUrl');
    if(this.mounted)
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Stack(
          alignment: Alignment.bottomRight,
          children:[
            GestureDetector(
              onTap: onPressedFunc!=null?onPressedFunc:(){},
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 7,
                  child: Hero(
                    tag: heroTagNum,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child:FadeInImage.assetNetwork(
                          placeholder: 'assets/fading.gif',
                          image:imageUrl, fit: BoxFit.fill, height: 150, width: double.infinity, )),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding:  EdgeInsets.symmetric(vertical:2.0, horizontal: 5),
                    child: Text(title, textAlign: TextAlign.left, style: TextStyle( fontWeight: FontWeight.bold, color: kThemeBlue)),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding:  EdgeInsets.symmetric(vertical:2.0, horizontal: 5),
                    child: Text(price, textAlign: TextAlign.left, style: TextStyle( color: kThemeOrange, fontWeight: FontWeight.bold),),
                  ),
                )
              ],
          ),
            ),
            GestureDetector(
              onTap: () async {
                await uToggleFavoriteStatus(context: context, smitem: smitem);
              },
              child:Provider.of<FavoriteProvider>(context).isItemFavorite(smitem)?
              Icon(Icons.favorite, color: Colors.red,) : Icon(Icons.favorite_border , color:kThemeOrange)
            )
          ]
        ),
      ),
    );
  }
}
