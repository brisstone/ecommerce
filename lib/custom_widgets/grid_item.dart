
import 'package:ecommerce/constants.dart';
import 'package:flutter/material.dart';

class GridItem extends StatelessWidget {

  GridItem({this.imageUrl='images/watchpic.jpg', this.title, this.price, this.heroTagNum, this.onPressedFunc});

  String imageUrl;
  int heroTagNum;
  String title;
  String price;
  Function onPressedFunc;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressedFunc!=null?onPressedFunc:(){},
      child: Container(
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
//        boxShadow: [BoxShadow(blurRadius: 15, color: Colors.grey)]
        ),
        child: Column(
          children: [
            Expanded(
              flex: 7,
              child: Hero(
                tag: 'itemImage$heroTagNum',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                    child:Image.asset(imageUrl, fit: BoxFit.fill, height: 150, width: 150, )),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: Text(title, style: TextStyle( fontWeight: FontWeight.bold, color: kThemeBlue)),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(price, style: TextStyle( color: kThemeOrange, fontWeight: FontWeight.bold),),
            )
          ],
        ),
      ),
    );
  }
}
