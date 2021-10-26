import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class NavButton extends StatelessWidget {


  NavButton({this.onTapFunc, @required this.icon, @required this.label, this.selected,
  this.alignment=Alignment.center, this.heroTag='img'});

  final Function onTapFunc;
  final IconData icon;
  final String label;
  final Alignment alignment;
  final heroTag;

  bool selected=false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapFunc!=null?onTapFunc:(){},
      child: Container(
        alignment: alignment,
        padding: EdgeInsets.only(left:16),
        child: Row(
          children: [
            Hero(
              tag: heroTag,
              child: Icon(icon,
                color: Colors.white,
                size: 26,),
            ),
            SizedBox(width: 30,),
            Text(label,
              style:kNavTextStyle,)
          ],
        ),
      ),
    );
  }
}