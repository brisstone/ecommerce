import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../constants.dart';

class RatingRow extends StatelessWidget {

  RatingRow({this.rating, this.onPressed});

  int rating=0;

  Function(int) onPressed;

  Color selectedColor= kThemeOrange;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(onPressed:(){ onPressed(1);}, icon: Icon(rating>=1?Icons.star:Icons.star_border , color: selectedColor,)),
          IconButton(onPressed: (){onPressed(2);}, icon: Icon(rating>=2?Icons.star:Icons.star_border , color: selectedColor,)),
          IconButton(onPressed: (){onPressed(3);}, icon: Icon(rating>=3?Icons.star:Icons.star_border , color: selectedColor,)),
          IconButton(onPressed: (){onPressed(4);}, icon: Icon(rating>=4?Icons.star:Icons.star_border , color: selectedColor,)),
          IconButton(onPressed: (){onPressed(5);}, icon: Icon(rating>=5?Icons.star:Icons.star_border , color: selectedColor,)),
        ],
      ),
    );
  }
}