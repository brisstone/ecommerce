import 'package:ecommerce/constants.dart';
import 'package:flutter/material.dart';

class RoundIconButton extends StatelessWidget{

  RoundIconButton({this.icon, this.onPressedFun});

  final IconData icon;
  final Function onPressedFun;

  @override
  Widget build(BuildContext context) {

    return RawMaterialButton(
      onPressed: onPressedFun,

      elevation: 16,
        disabledElevation: 16,
      constraints: BoxConstraints.tightFor(
          width: 46.0,
          height: 46.0
      ),
      child: Icon(icon, color: kThemeBlue,),
      shape: CircleBorder(),
      fillColor: Color(0xFFFFFFFF),
    );
  }

}
