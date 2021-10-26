import 'package:flutter/material.dart';
import 'package:ecommerce/constants.dart';

class VariantListItem extends StatelessWidget {


  VariantListItem({this.onPressedFunc, this.title='dum', this.price , this.selected=false});

  Function onPressedFunc;
  String title;
  String price;
  bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: kThemeOrange, width: 1.5),
          borderRadius: BorderRadius.circular(20),
          color: selected?kThemeOrange:Colors.white
        ),
        child: RawMaterialButton(
          splashColor: kThemeOrange,
            onPressed: onPressedFunc!=null?onPressedFunc:(){},
            child: Text(title, style: TextStyle(color: selected?Colors.white:kThemeOrange),)),
      ),
    );
  }
}
