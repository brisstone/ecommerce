import 'package:flutter/material.dart';

class ShopItem extends StatelessWidget {

  Color backColor;
  String title;

  ShopItem({this.title='Test title', @required this.backColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: backColor,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 3)]
      ),
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 50),
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Text(title, style: TextStyle(fontSize: 20, color: Colors.white),),
    );
  }
}
