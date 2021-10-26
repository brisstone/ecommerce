import 'dart:io';

import 'package:ecommerce/constants.dart';
import 'package:ecommerce/mart_objects/order_item.dart';
import 'package:flutter/material.dart';
class OrderListItem extends StatelessWidget {

  OrderListItem({@required this.oItem, @required this.onPressedFunc, this.image}){
    title=oItem.n;
    price=oItem.p;
    units=oItem.u;
  }

  String title;
  String price;
  String image;
  String units;
  OrderItem oItem;
  Function onPressedFunc;

  @override
  Widget build(BuildContext context) {
    print('item image: $image');
    return GestureDetector(
      onTap: onPressedFunc!=null? onPressedFunc :(){},
      child: Container(
        height: double.minPositive,
        padding: EdgeInsets.all(4),
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 3)]
        ),
        child: ListTile(
          leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child:(image!=null&&image.isNotEmpty)?Image.file(File(image)):Icon(Icons.description, color: kThemeOrange,size: 30,)),
          tileColor: Colors.white,
          title: Text(title, style: TextStyle(color: kThemeBlue, fontWeight: FontWeight.bold),),
          subtitle: Container(
            constraints: BoxConstraints(maxHeight: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                SizedBox(height: 5,),
                Text('\u20a6 $price', textAlign: TextAlign.start, style: TextStyle(color: kThemeOrange, fontWeight: FontWeight.bold),),
//            Text('X$units', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                Spacer(),
                getActionText(oItem.k),
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

  Widget getActionText(String orderStat) {
    String text='';
    Color acColor=Colors.white;
    Color textColor=Colors.white;
    if(orderStat.startsWith('1')) {
      text='Paid-Pending';
      textColor=Colors.green;
    }else if(orderStat.startsWith('2')){
      text='Order Completed';
      acColor=Colors.transparent;
      textColor=Colors.blue;
    }else if(orderStat.startsWith('3')){

      text='Refund Approval Pending';
      acColor=Colors.transparent;
      textColor=Colors.brown;
    }else if(orderStat.startsWith('4')){
      text = 'Refund Approved';
      acColor = Colors.transparent;
      textColor=kThemeOrange;
    }else if(orderStat.startsWith('5')||orderStat.startsWith('6')){
      text = 'Order Settled';
      acColor = Colors.transparent;
      textColor=Colors.black;
    }
    return Text( text,textAlign: TextAlign.end,style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold) );
  }

}