
import 'dart:io';

import 'package:ecommerce/constants.dart';
import 'package:ecommerce/mart_objects/mart_item.dart';
import 'package:ecommerce/screens/edit_item_screen.dart';
import 'package:ecommerce/screens/preview_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ListItem extends StatelessWidget {
  Function promoteItem;
  MartItem mitem;
  BuildContext context;
  String title;
  String price;
  String image;
  bool isOnline=false;
  Function onPressedFunc;
  bool isPromoted=false;


  ListItem({this.mitem, @required this.context,this.price='0', this.title='Test title', this.image='images/img.jpg'
    , this.onPressedFunc, this.promoteItem, this.isPromoted}){
    if(mitem!=null) {
      image=mitem.q;
      title=mitem.t;
      price=mitem.m;
      if(mitem.h!=null && mitem.h.isNotEmpty && mitem.h.contains(':'))isOnline=true;
      if (price!=null&&price.contains('<')) {
        List<String> strList = price.split('<');
        price = strList[0];
      }
      print('image start: $image');
      if(image!=null) {
        if (image.startsWith(',')) {
          image = image.substring(1);
        }
        List<String> imsplits=image.split(',');
        int dex=0;
        image = imsplits[dex];
        while(dex!=imsplits.length&&image.trim().isEmpty){
          image=imsplits[dex];
          dex++;
        }
        print('image final: $image');
      }
      onPressedFunc=(){
      if(isOnline){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
          return PreviewScreen(martItem: mitem,);
        }));
      }else {
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
      onTap: onPressedFunc!=null? onPressedFunc :(){},
      child: Container(
        height: double.minPositive,
        margin: EdgeInsets.all(3),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 3)]
        ),
        child: ListTile(
          leading: AspectRatio(
            aspectRatio: 5/5,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child:Hero(
                    tag: mitem.l,
                    child: Image.file(File(image), height: 50,  fit: BoxFit.cover,))),
          ),
          tileColor: Colors.white,
          title: Text(title, style: TextStyle(color: kThemeBlue, fontWeight: FontWeight.bold),),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
              children:
          [Text('\u20a6 $price', textAlign:TextAlign.start, style: TextStyle(color: kThemeOrange, fontWeight: FontWeight.bold),),
          Container(
              alignment: Alignment.centerRight,
              child: Text(isOnline?'online ✔':'draft', textAlign:TextAlign.right, style: TextStyle(color: isOnline?Colors.green:Colors.grey,),)),
          ]
          ),

          trailing: getTrailingWidget(),
        ),
      ),
    );
  }

  Widget getTrailingWidget(){
    if(!isPromoted && isOnline){
      return GestureDetector(
        onTap: promoteItem,
        child: Container(
          height: 25,
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: kThemeOrange, width: 1.5)
          ),
          child: Text('promote', style: TextStyle(color: kThemeOrange, fontWeight: FontWeight.bold),),
        ),
      );
    }else if(isPromoted){
      return Icon(CupertinoIcons.star, color: kThemeOrange,size: 25,);
    }else{
      return Container(width: 1,height: 1,);
    }
  }
}