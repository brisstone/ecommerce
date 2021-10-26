
import 'dart:io';
import 'dart:math';

import 'package:ecommerce/constants.dart';
import 'package:ecommerce/mart_objects/mart_item.dart';
import 'package:ecommerce/screens/edit_item_screen.dart';
import 'package:ecommerce/screens/preview_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PromoListItem extends StatelessWidget {


  String title;
  String price;
  String image;
  MartItem mitem;
  Function onPressedFunc;
  BuildContext context;
  bool isOnline;

  PromoListItem({this.price='1000', this.title='Test title', this.image='images/jewelpic.jpg'
    , this.onPressedFunc, this.mitem, @required this.context}) {
    if (mitem != null) {
      image = mitem.q;
      title = mitem.t;
      price = mitem.m;
      if (mitem.h != null && mitem.h.isNotEmpty && mitem.h.contains(':'))
        isOnline = true;
      if (price != null && price.contains('<')) {
        List<String> strList = price.split('<');
        price = strList[0];
      }
      if (image != null) {
        if (image.startsWith(',')) {
          image = image.substring(1);
        }
        image = image.split(',')[0];
      }
      onPressedFunc = () {
        if (isOnline) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
            return PreviewScreen(martItem: mitem,);
          }));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
            return EditItemScrren(context,martItem: mitem,);
          }));
        }
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
//      splashColor: kLightBlue,
      onTap: onPressedFunc!=null?onPressedFunc:(){},
      child: Container(
        height: 300,
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
        boxShadow: [BoxShadow(blurRadius: 15, color: Colors.grey)]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              flex: 7,
              child: Hero(
                tag: 'item${Random().nextInt(30)}',
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child:Image.file(File(image), fit: BoxFit.cover, width: 100, )),
                    Container(
                        margin: EdgeInsets.all(8),
                        child: Icon(CupertinoIcons.star_fill, color: kThemeOrange, size: 16,))
                  ]
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(left:8.0),
                child: Text(title, style: TextStyle( fontWeight: FontWeight.bold, color: kThemeBlue, fontSize: 12)),
              ),
            ),
            SizedBox(height: 5,),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(left:8.0),
                child: Text('\u20a6$price', style: TextStyle( color: kThemeOrange, fontWeight: FontWeight.bold),),
              ),
            ),
            SizedBox(height: 5,)
          ],
        ),
      ),
    );
  }
}
