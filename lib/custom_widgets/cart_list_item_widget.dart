import 'dart:io';

import 'package:ecommerce/constants.dart';
import 'package:ecommerce/mart_objects/cart_item.dart';
import 'package:ecommerce/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartListItem extends StatelessWidget {


  CartListItem({@required this.oItem, @required this.onPressedFunc,
    @required this.context, this.image = '', this.onRemoveItemPressed}){
    title=oItem.n;
    price=oItem.p;
    units=oItem.u;
  }

  BuildContext context;
  String title = '';
  String price = '';
  String image='';
  String units='';
  CartItem oItem;
  Function(CartItem) onPressedFunc;
  Function(CartItem) onRemoveItemPressed = (_){};

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: EdgeInsets.all(4),
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
        ),
        child: ListTile(
          leading: GestureDetector(
            onTap: onPressedFunc!=null? (){onPressedFunc(oItem);} :(){},
            child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child:Provider.of<CartProvider>(context).imgMap.containsKey(oItem.i)&&
                    Provider.of<CartProvider>(context).imgMap[oItem.i].isNotEmpty?
                Image.network(Provider.of<CartProvider>(context).imgMap[oItem.i]??''):
                Icon(Icons.description, color: kThemeOrange,size: 30,)),
          ),
          tileColor: Colors.white,
          title: Text(title, style: TextStyle(color: kThemeBlue, fontWeight: FontWeight.bold),),
          subtitle: Container(
            constraints: BoxConstraints(maxHeight: 60),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 5,),
                  Text('\u20a6 $price', textAlign: TextAlign.start, style: TextStyle(color: kThemeOrange, fontWeight: FontWeight.bold),),
                  Spacer(),
                  Container(
                    height: 30,
                    alignment: Alignment.bottomRight,
                    child:  Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                            onTap:(){ if(onRemoveItemPressed != null)onRemoveItemPressed(oItem);},
                            child: Text('remove item', textAlign: TextAlign.start, style: TextStyle(color: kThemeOrange),)),
                        GestureDetector(
                            onTap:(){ if(onRemoveItemPressed != null)onRemoveItemPressed(oItem);},
                            child: Icon(Icons.remove_shopping_cart_outlined, color: kThemeOrange,))
                      ],
                    ),
                  ),
                  SizedBox(height: 8,)
                ]),
          ),
          trailing: Container(
            height: 25,
            width: 40,
            alignment: Alignment.bottomRight,
            child: Text('X$units', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
          ),
        ),
      ),
    );
  }


}